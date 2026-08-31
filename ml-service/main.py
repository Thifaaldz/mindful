import json
import logging
import os
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Literal

from fastapi import FastAPI
from pydantic import BaseModel, Field


app = FastAPI(title="MindfulEdu Analytics", version="2.3.0")
logger = logging.getLogger("mindfuledu.ml")

SCORING_VERSION = "scoring-v2.3-mbsr"
MODEL_VERSION = "fastapi-rule-mbsr-v2.3"
MAX_SCORE = 100.0
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
GEMINI_MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash")
GEMINI_TIMEOUT_SECONDS = float(os.environ.get("GEMINI_TIMEOUT_SECONDS", "8"))
NEGATIVE_CHECKIN_MOODS = {"cemas", "sedih", "marah"}
NEGATIVE_CHECKOUT_MOODS = {"cemas", "sedih", "marah"}
PRESSURE_KEYWORDS = {
    "lelah",
    "capek",
    "stres",
    "stress",
    "tertekan",
    "pusing",
    "cemas",
    "takut",
    "marah",
    "sedih",
    "kewalahan",
    "burnout",
    "jenuh",
}
MOOD_KEYWORDS = {
    "cemas": ["cemas", "khawatir", "gugup", "takut", "deg-degan", "panik"],
    "sedih": ["sedih", "kecewa", "putus asa", "menangis", "murung", "sepi"],
    "marah": ["marah", "kesal", "jengkel", "benci", "emosi"],
    "senang": ["senang", "bahagia", "gembira", "semangat", "seru", "asik"],
    "lelah": ["lelah", "capek", "ngantuk", "burnout", "pusing", "stres", "stress"],
}
SUGGESTIONS = {
    "cemas": "Coba latihan napas 4-7-8 selama 5 menit untuk menenangkan tubuh.",
    "sedih": "Tuliskan satu hal kecil yang membuatmu nyaman hari ini, lalu coba sesi napas singkat.",
    "marah": "Coba tarik napas dalam 5 kali sebelum melanjutkan aktivitas.",
    "lelah": "Istirahat sejenak dan coba sesi napas 10 menit sebelum lanjut belajar.",
    "senang": "Pertahankan momen ini, catat apa yang membuatmu senang hari ini.",
    "netral": "Coba check-in mood harian dan sesi napas singkat untuk menjaga fokus.",
}
PRACTICE_CATALOG = {
    "stop_technique": {
        "title": "Teknik STOP",
        "practice": "Teknik STOP selama 2 menit.",
    },
    "grounding_321": {
        "title": "Grounding 3-2-1",
        "practice": "Grounding 3-2-1 selama 3 menit.",
    },
    "breathing_478": {
        "title": "Napas 4-7-8",
        "practice": "Napas 4-7-8 selama 5 menit.",
    },
    "breathing_space_3min": {
        "title": "Jeda Napas 3 Menit",
        "practice": "Jeda Napas 3 Menit untuk menata perhatian sebelum aktivitas berikutnya.",
    },
    "maintain_breath_awareness": {
        "title": "Awareness of Breathing",
        "practice": "Awareness of Breathing 2-3 menit sebelum aktivitas berikutnya.",
    },
    "sitting_meditation": {
        "title": "Sitting Meditation",
        "practice": "Sitting meditation fokus napas 10 menit.",
    },
    "body_scan_micro": {
        "title": "Body Scan Singkat",
        "practice": "Body Scan singkat 5-10 menit.",
    },
    "body_scan_full": {
        "title": "Body Scan Penuh",
        "practice": "Body scan 15-20 menit untuk pemulihan lebih dalam.",
    },
    "mindful_movement": {
        "title": "Mindful Movement",
        "practice": "Mindful movement ringan setelah aktivitas berat.",
    },
    "walking_meditation": {
        "title": "Walking Meditation",
        "practice": "Walking meditation 5 menit untuk jeda aktif.",
    },
    "rain_self_compassion": {
        "title": "RAIN",
        "practice": "RAIN untuk mengenali dan merawat emosi berat.",
    },
    "loving_kindness": {
        "title": "Loving-Kindness Meditation",
        "practice": "Loving-kindness meditation 7 menit.",
    },
    "reflective_journal": {
        "title": "Jurnal Reflektif Harian",
        "practice": "Jurnal reflektif harian untuk membaca pola tekanan.",
    },
}
CRISIS_KEYWORDS = [
    "bunuh diri",
    "mengakhiri hidup",
    "ingin mati",
    "ingin hilang saja",
    "menyakiti diri",
    "melukai diri",
    "tidak ingin hidup",
]
BURNOUT_DIMENSION_KEYWORDS = {
    "kelelahan_emosional": [
        "lelah",
        "capek",
        "habis energi",
        "terkuras",
        "menguras",
        "kelelahan",
        "burnout",
        "ngantuk",
        "pusing",
    ],
    "depersonalisasi": [
        "sinis",
        "malas",
        "percuma",
        "cuek",
        "acuh",
        "tidak peduli",
        "masa bodoh",
    ],
    "rendah_pencapaian_diri": [
        "gagal",
        "tidak berarti",
        "tidak kompeten",
        "meragukan",
        "tidak becus",
        "sia-sia",
        "tidak berguna",
    ],
}
VALID_ANALYSIS_MOODS = {"senang", "tenang", "cemas", "sedih", "marah", "lelah", "netral"}
VALID_DIMENSIONS = set(BURNOUT_DIMENSION_KEYWORDS)
GEMINI_PROMPT = """Kamu adalah asisten psikologi yang menganalisis satu entri jurnal
refleksi harian dari guru atau siswa di Indonesia. Balas HANYA dengan JSON valid,
tanpa markdown, tanpa penjelasan lain, persis struktur berikut:

{{
  "mood_detected": salah satu dari ["senang","tenang","cemas","sedih","marah","lelah","netral"],
  "suggestion": saran singkat 1-2 kalimat berbahasa Indonesia yang suportif dan actionable,
  "crisis_flag": true HANYA jika ada indikasi kuat menyakiti diri sendiri/bunuh diri, selain itu false,
  "burnout_dimensions": subset dari ["kelelahan_emosional","depersonalisasi","rendah_pencapaian_diri"], boleh kosong []
}}

Teks jurnal:
\"\"\"{text}\"\"\"
"""


class ActivityFeature(BaseModel):
    title: str | None = None
    category_name: str | None = None
    planned_hours: float = Field(ge=0)
    actual_hours: float = Field(ge=0)
    intensity_factor: float = Field(ge=0)
    checkin_mood: str | None = None
    checkin_intensity: int | None = Field(default=None, ge=1, le=10)
    checkin_trigger: str | None = None
    checkout_mood: str | None = None
    checkout_fact: str | None = None
    checkout_feeling: str | None = None
    checkout_pattern: str | None = None
    checkout_plan: str | None = None
    checkout_burnout_tags: list[str] | None = None
    checkout_auto_burnout_tags: list[str] | None = None
    checkout_mood_detected: str | None = None
    checkout_crisis_flag: bool = False


class BurnoutScoreRequest(BaseModel):
    period_type: str
    role_context: Literal["student", "teacher", "other"] = "other"
    period_capacity_hours: float = Field(gt=0)
    self_report_levels: list[int] = Field(default_factory=list)
    activities: list[ActivityFeature]
    scoring_version: str = SCORING_VERSION


class BurnoutRecommendationRequest(BaseModel):
    category: Literal["hijau", "kuning", "merah"] | None = None
    dominant_factors: list[str] = Field(default_factory=list)
    role_context: Literal["student", "teacher", "other"] = "other"


class JournalAnalysisRequest(BaseModel):
    text: str | None = None
    fact: str | None = None
    feeling: str | None = None
    pattern: str | None = None
    plan: str | None = None
    burnout_tags: list[str] | None = None


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "model_version": MODEL_VERSION}


@app.post("/analyze/journal")
def analyze_journal_endpoint(payload: JournalAnalysisRequest) -> dict[str, Any]:
    return analyze_journal(journal_text(payload), payload.burnout_tags or [])


@app.post("/score/burnout")
def score_burnout(payload: BurnoutScoreRequest) -> dict[str, Any]:
    weighted_planned = sum(item.planned_hours * item.intensity_factor for item in payload.activities)
    weighted_actual = sum(item.actual_hours * item.intensity_factor for item in payload.activities)
    workload_raw = weighted_actual / payload.period_capacity_hours * 100
    variance = ((weighted_actual - weighted_planned) / weighted_planned * 100) if weighted_planned > 0 else None

    completed_journals = [item for item in payload.activities if has_structured_checkout(item)]
    wellbeing = wellbeing_score(payload.activities, payload.self_report_levels)
    data_sufficiency = bool(completed_journals)
    final_score = min(
        MAX_SCORE,
        0.50 * min(MAX_SCORE, workload_raw) + 0.50 * wellbeing,
    ) if data_sufficiency else None
    factors = dominant_factors(payload.activities, workload_raw, wellbeing, payload.self_report_levels)
    if crisis_count(payload.activities) > 0 and final_score is not None:
        final_score = max(final_score, 75.0)
    final_score = apply_risk_floor(final_score, factors)
    category = category_for(final_score)
    recommendation = recommendation_for(category, factors, payload.role_context)

    return {
        "data_sufficiency": data_sufficiency,
        "weighted_planned_hours": round(weighted_planned, 2),
        "weighted_actual_hours": round(weighted_actual, 2),
        "workload_score_raw": round(workload_raw, 2),
        "workload_variance_pct": None if variance is None else round(variance, 2),
        "journal_score": round(wellbeing, 2),
        "wellbeing_score": round(wellbeing, 2),
        "final_burnout_risk_score": None if final_score is None else round(final_score, 2),
        "category": category,
        "dominant_factors": factors,
        "recommendation_codes": recommendation["codes"],
        "recommendation_summary": recommendation,
        "calculation": {
            "formula": "Final = 50% Workload Score + 50% Wellbeing Score",
            "workload_score": round(workload_raw, 2),
            "wellbeing_score": round(wellbeing, 2),
            "checkin_negative_ratio": round(checkin_negative_ratio(payload.activities), 2),
            "checkout_negative_ratio": round(checkout_negative_ratio(payload.activities), 2),
            "worsening_checkout": round(worsening_ratio(payload.activities), 2),
        },
        "model_version": MODEL_VERSION,
        "scoring_version": payload.scoring_version or SCORING_VERSION,
    }


@app.post("/recommendation/burnout")
def recommend_burnout(payload: BurnoutRecommendationRequest) -> dict[str, Any]:
    return recommendation_for(payload.category, payload.dominant_factors, payload.role_context)


def journal_text(payload: JournalAnalysisRequest) -> str:
    if payload.text and payload.text.strip():
        return payload.text.strip()
    parts = []
    if payload.fact and payload.fact.strip():
        parts.append(f"Fakta: {payload.fact.strip()}")
    if payload.feeling and payload.feeling.strip():
        parts.append(f"Perasaan: {payload.feeling.strip()}")
    if payload.pattern and payload.pattern.strip():
        parts.append(f"Pola: {payload.pattern.strip()}")
    if payload.plan and payload.plan.strip():
        parts.append(f"Rencana: {payload.plan.strip()}")
    return "\n".join(parts)


def analyze_journal(text: str, user_tags: list[str] | None = None) -> dict[str, Any]:
    local_result = local_journal_analysis(text)
    gemini_result = gemini_journal_analysis(text)
    result = gemini_result or local_result
    result["crisis_flag"] = bool(result.get("crisis_flag")) or bool(local_result["crisis_flag"])
    dimensions = unique([
        *[tag for tag in (user_tags or []) if tag in VALID_DIMENSIONS],
        *[tag for tag in result.get("burnout_dimensions", []) if tag in VALID_DIMENSIONS],
    ])
    result["burnout_dimensions"] = dimensions
    if "source" not in result:
        result["source"] = "gemini" if gemini_result else "mock"
    return result


def local_journal_analysis(text: str) -> dict[str, Any]:
    lower = text.lower()
    crisis_flag = any(keyword in lower for keyword in CRISIS_KEYWORDS)
    mood_scores = {mood: 0 for mood in MOOD_KEYWORDS}
    for mood, keywords in MOOD_KEYWORDS.items():
        for keyword in keywords:
            if keyword in lower:
                mood_scores[mood] += 1
    best_mood = max(mood_scores, key=mood_scores.get)
    mood_detected = best_mood if mood_scores[best_mood] > 0 else "netral"
    return {
        "mood_detected": mood_detected,
        "suggestion": SUGGESTIONS.get(mood_detected, SUGGESTIONS["netral"]),
        "crisis_flag": crisis_flag,
        "burnout_dimensions": detect_burnout_dimensions(text),
        "source": "mock",
        "raw_response": None,
    }


def gemini_journal_analysis(text: str) -> dict[str, Any] | None:
    if not GEMINI_API_KEY:
        return None
    try:
        query = urllib.parse.urlencode({"key": GEMINI_API_KEY})
        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{urllib.parse.quote(GEMINI_MODEL)}:generateContent?{query}"
        )
        body = json.dumps(
            {
                "contents": [
                    {"parts": [{"text": GEMINI_PROMPT.format(text=text)}]},
                ],
                "generationConfig": {"responseMimeType": "application/json"},
            }
        ).encode("utf-8")
        request = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(request, timeout=GEMINI_TIMEOUT_SECONDS) as response:
            payload = json.loads(response.read().decode("utf-8"))
        raw_text = (
            payload.get("candidates", [{}])[0]
            .get("content", {})
            .get("parts", [{}])[0]
            .get("text", "")
        )
        data = json.loads(raw_text)
        mood = data.get("mood_detected")
        return {
            "mood_detected": mood if mood in VALID_ANALYSIS_MOODS else "netral",
            "suggestion": data.get("suggestion") or SUGGESTIONS["netral"],
            "crisis_flag": bool(data.get("crisis_flag", False)),
            "burnout_dimensions": [
                dimension for dimension in data.get("burnout_dimensions", [])
                if dimension in VALID_DIMENSIONS
            ],
            "source": "gemini",
            "raw_response": raw_text,
        }
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, KeyError, IndexError):
        logger.exception("Panggilan Gemini gagal, fallback ke analisis jurnal lokal")
        return None


def detect_burnout_dimensions(text: str) -> list[str]:
    lower = text.lower()
    return [
        dimension for dimension, keywords in BURNOUT_DIMENSION_KEYWORDS.items()
        if any(keyword in lower for keyword in keywords)
    ]


def has_structured_checkout(item: ActivityFeature) -> bool:
    return bool((item.checkout_fact or "").strip() or (item.checkout_feeling or "").strip())


def checkin_negative(item: ActivityFeature) -> bool:
    return item.checkin_mood in NEGATIVE_CHECKIN_MOODS


def checkout_negative(item: ActivityFeature) -> bool:
    if not has_structured_checkout(item):
        return False
    return item.checkout_mood in NEGATIVE_CHECKOUT_MOODS or has_pressure_text(checkout_text(item))


def checkin_negative_ratio(items: list[ActivityFeature]) -> float:
    rows = [item for item in items if item.checkin_mood is not None]
    return count_ratio(rows, checkin_negative)


def checkout_negative_ratio(items: list[ActivityFeature]) -> float:
    rows = [item for item in items if has_structured_checkout(item)]
    return count_ratio(rows, checkout_negative)


def count_ratio(items: list[ActivityFeature], predicate) -> float:
    if not items:
        return 0.0
    return len([item for item in items if predicate(item)]) / len(items)


def negative_intensity_values(items: list[ActivityFeature]) -> list[float]:
    values = []
    for item in items:
        if checkin_negative(item):
            values.append((item.checkin_intensity or 5) / 10)
        if checkout_negative(item):
            values.append(0.7 if item.checkout_mood in NEGATIVE_CHECKOUT_MOODS else 0.5)
    return values


def dimension_density(items: list[ActivityFeature]) -> float:
    rows = [item for item in items if has_structured_checkout(item)]
    if not rows:
        return 0.0
    signal_count = len([
        item for item in rows
        if has_pressure_text(checkout_text(item)) or burnout_dimensions(item)
    ])
    return min(signal_count / len(rows), 1.0)


def worsening_ratio(items: list[ActivityFeature]) -> float:
    return max(0.0, checkout_negative_ratio(items) - checkin_negative_ratio(items))


def wellbeing_score(items: list[ActivityFeature], self_report_levels: list[int] | None = None) -> float:
    checkin_rows = [
        item for item in items
        if item.checkin_mood is not None
    ]
    checkout_rows = [item for item in items if has_structured_checkout(item)]
    total_sessions = len(checkin_rows) + len(checkout_rows)
    negative_sessions = len([item for item in checkin_rows if checkin_negative(item)])
    negative_sessions += len([item for item in checkout_rows if checkout_negative(item)])
    negative_ratio = negative_sessions / total_sessions if total_sessions else 0.0

    intensities = negative_intensity_values(items)
    avg_negative_intensity = sum(intensities) / len(intensities) if intensities else 0.0

    score = 0.0
    score += negative_ratio * 35
    score += avg_negative_intensity * 15
    score += worsening_ratio(items) * 15
    score += dimension_density(items) * 20
    valid_self_reports = [value for value in (self_report_levels or []) if 0 <= value <= 10]
    if valid_self_reports:
        score += (sum(valid_self_reports) / len(valid_self_reports) / 10) * 15
    else:
        score += negative_ratio * 15
    if crisis_count(items) > 0:
        score = max(score, 85.0)
    return min(MAX_SCORE, score)


def category_for(score: float | None) -> str | None:
    if score is None:
        return None
    if score >= 70:
        return "merah"
    if score >= 40:
        return "kuning"
    return "hijau"


def apply_risk_floor(score: float | None, factors: list[str]) -> float | None:
    if score is None or score >= 70:
        return score
    yellow_signals = {
        "checkout_negative_mood",
        "journal_pressure_terms",
        "teacher_self_report_high",
        "high_wellbeing_pressure",
    }
    if yellow_signals.intersection(factors):
        return max(score, 40.0)
    return score


def dominant_factors(
    items: list[ActivityFeature],
    workload_score: float,
    wellbeing: float,
    self_report_levels: list[int] | None = None,
) -> list[str]:
    factors: list[str] = []

    if workload_score > 100:
        factors.append("workload_over_capacity")
    elif workload_score >= 80:
        factors.append("dense_workload")

    if wellbeing >= 70:
        factors.append("high_wellbeing_pressure")

    valid_self_reports = [value for value in (self_report_levels or []) if 0 <= value <= 10]
    if valid_self_reports and sum(valid_self_reports) / len(valid_self_reports) >= 7:
        factors.append("teacher_self_report_high")

    if crisis_count(items) > 0:
        factors.append("crisis_flag")

    if checkout_negative_ratio(items) >= 0.5:
        factors.append("checkout_negative_mood")

    checkout_rows = [item for item in items if has_structured_checkout(item)]
    if checkout_rows and dimension_density(items) >= 0.5:
        factors.append("journal_pressure_terms")

    if len([item for item in items if item.intensity_factor >= 1.5]) >= 2:
        factors.append("consecutive_high_intensity")

    return unique(factors) or ["balanced_period"]


def checkout_text(item: ActivityFeature) -> str:
    return " ".join(
        value.strip()
        for value in (item.checkout_fact, item.checkout_feeling, item.checkout_pattern, item.checkout_plan)
        if value and value.strip()
    )


def burnout_dimensions(item: ActivityFeature) -> list[str]:
    return [
        dimension for dimension in [
            *(item.checkout_burnout_tags or []),
            *(item.checkout_auto_burnout_tags or []),
        ]
        if dimension in VALID_DIMENSIONS
    ]


def crisis_count(items: list[ActivityFeature]) -> int:
    return len([item for item in items if item.checkout_crisis_flag])


def has_pressure_text(text: str) -> bool:
    normalized = text.lower()
    return any(keyword in normalized for keyword in PRESSURE_KEYWORDS)


def unique(values: list[str]) -> list[str]:
    result = []
    for value in values:
        if value not in result:
            result.append(value)
    return result


def practice_code_for(category: str | None, factors: list[str], role: str) -> str:
    if "crisis_flag" in factors:
        return "grounding_321"
    if "teacher_self_report_high" in factors:
        return "body_scan_full"
    if "journal_pressure_terms" in factors:
        return "sitting_meditation"
    if "checkout_negative_mood" in factors:
        return "body_scan_micro"
    if "consecutive_high_intensity" in factors or "dense_workload" in factors:
        return "mindful_movement"
    if category == "merah":
        return "body_scan_full" if role != "student" else "grounding_321"
    if category == "kuning":
        return "body_scan_micro"
    if category == "hijau":
        return "breathing_space_3min" if role == "student" else "maintain_breath_awareness"
    return "breathing_space_3min"


def recommendation_for(category: str | None, factors: list[str], role: str) -> dict[str, Any]:
    if category is None:
        practice_code = "breathing_space_3min"
        practice = PRACTICE_CATALOG[practice_code]
        return {
            "codes": ["complete_activity_journal"],
            "headline": "Data belum cukup",
            "action": "Lengkapi check-in, check-out, dan jurnal pasca pada minimal satu aktivitas lalu jalankan analisis ulang.",
            "practice": practice["practice"],
            "practice_code": practice_code,
            "practice_title": practice["title"],
            "dominant_factors": factors,
            "theory_reference": "Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)",
        }

    role_is_student = role == "student"
    matrix = {
        "hijau": {
            "codes": ["maintain_breath_awareness", "mindful_transition"],
            "headline": "Risiko rendah",
            "action": "Pertahankan ritme aktivitas dan beri jeda transisi singkat antar kegiatan.",
            "practice": "Jeda Napas 3 Menit" if role_is_student else "Awareness of Breathing 2-3 menit sebelum masuk kelas.",
        },
        "kuning": {
            "codes": ["body_scan_micro", "recovery_break", "mindful_movement"],
            "headline": "Perlu jeda pemulihan",
            "action": "Identifikasi aktivitas paling menguras, kurangi multitasking, dan sisipkan recovery break.",
            "practice": "Body Scan singkat 5 menit" if role_is_student else "Body Scan 5-10 menit atau mindful stretch.",
        },
        "merah": {
            "codes": ["guided_breathing", "workload_adjustment", "support_check"],
            "headline": "Prioritaskan pemulihan",
            "action": "Tinjau ulang todo-list, pindahkan aktivitas yang dapat ditunda, dan hubungi pendamping bila tekanan berlanjut.",
            "practice": "Guided breathing dengan pendamping atau wali kelas" if role_is_student else "Sitting meditation fokus napas 10 menit dan rencana penyesuaian beban.",
        },
    }

    recommendation = dict(matrix[category])
    codes = list(recommendation["codes"])

    if "crisis_flag" in factors:
        codes.append("support_check")
        recommendation["action"] = "Ada sinyal krisis pada jurnal. Hubungi pendamping, guru BK, keluarga, atau layanan profesional sebelum menambah beban aktivitas."
        recommendation["practice"] = "Grounding napas singkat sambil ditemani orang tepercaya."
    elif "journal_pressure_terms" in factors:
        codes.append("stress_regulation_from_journal")
        recommendation["action"] = "Jurnal checkout memuat tanda tekanan. Turunkan kepadatan aktivitas paling menekan dan sisipkan jeda regulasi setelah aktivitas berat."
        recommendation["practice"] = "Napas 4 hitungan masuk dan 6 hitungan keluar selama 3 menit."
    elif "checkout_negative_mood" in factors:
        codes.append("recovery_plan_from_journal")
        recommendation["action"] = "Mood checkout sering berada di area negatif. Jadwalkan aktivitas pemulihan nyata sebelum menambah tugas baru."
        recommendation["practice"] = "Body Scan 5-10 menit dan jeda tanpa layar sebelum aktivitas berikutnya."
    elif "teacher_self_report_high" in factors:
        codes.append("teacher_recovery_plan")
        recommendation["action"] = "Refleksi kondisi guru menunjukkan tekanan tinggi. Kurangi aktivitas rendah prioritas dan buat jeda pemulihan yang benar-benar terjadwal."
        recommendation["practice"] = "Body scan 15-20 menit atau mindful movement ringan setelah jam mengajar."

    practice_code = practice_code_for(category, factors, role)
    practice = PRACTICE_CATALOG[practice_code]
    recommendation["codes"] = unique(codes)
    recommendation["dominant_factors"] = factors
    recommendation["practice_code"] = practice_code
    recommendation["practice_title"] = practice["title"]
    recommendation["practice"] = practice["practice"]
    recommendation["theory_reference"] = "Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)"
    return recommendation
