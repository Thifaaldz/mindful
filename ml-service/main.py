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
GEMINI_MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash-lite")
GEMINI_TIMEOUT_SECONDS = float(os.environ.get("GEMINI_TIMEOUT_SECONDS", "20"))
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
    "mindful_breathing": {
        "title": "Mindful Breathing",
        "practice": "Mindful Breathing 3-5 menit untuk kembali ke napas sebagai anchor perhatian.",
        "duration_minutes": 5,
        "steps": [
            "Duduk atau berdiri dengan nyaman dan lepaskan ketegangan yang tidak perlu.",
            "Perhatikan napas masuk dan napas keluar sebagaimana adanya.",
            "Sadari sensasi napas pada hidung, dada, atau perut.",
            "Jika perhatian berpindah, sadari lalu kembali perlahan pada napas.",
            "Akhiri dengan menyadari tubuh dan lingkungan.",
        ],
        "best_for": ["sulit fokus", "stres ringan", "pikiran ramai", "jeda setelah aktivitas"],
    },
    "focused_attention": {
        "title": "Focused Attention Meditation",
        "practice": "Focused Attention 5 menit dengan satu anchor perhatian.",
        "duration_minutes": 5,
        "steps": [
            "Pilih satu anchor, misalnya sensasi napas di ujung hidung.",
            "Pertahankan perhatian pada anchor tanpa mengejar pikiran lain.",
            "Saat perhatian berpindah, beri label sederhana seperti berpikir.",
            "Kembali ke anchor dengan lembut.",
            "Tutup dengan menyadari seluruh tubuh dan lingkungan.",
        ],
        "best_for": ["distraksi", "sulit konsentrasi", "sering mengecek ponsel", "fokus belajar"],
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
    "open_monitoring": {
        "title": "Open Monitoring",
        "practice": "Open monitoring 10 menit untuk mengamati pikiran, suara, emosi, dan sensasi tanpa bereaksi.",
        "duration_minutes": 10,
        "steps": [
            "Stabilkan diri melalui napas.",
            "Buka awareness ke tubuh.",
            "Sadari suara yang muncul.",
            "Sadari pikiran dan emosi tanpa mengejar atau menolak.",
            "Kembali ke napas untuk menutup sesi.",
        ],
        "best_for": ["overwhelmed", "pikiran ramai", "emosi bercampur", "non-reactivity"],
    },
    "mindfulness_of_sounds": {
        "title": "Mindfulness of Sounds",
        "practice": "Mindfulness of Sounds 5 menit sebagai grounding melalui suara.",
        "duration_minutes": 5,
        "steps": [
            "Siapkan posisi yang nyaman.",
            "Dengarkan suara dekat tanpa menilai.",
            "Dengarkan suara jauh tanpa mengejar sumbernya.",
            "Sadari suara muncul, berubah, dan menghilang.",
            "Kembali pada napas dan tutup sesi.",
        ],
        "best_for": ["grounding", "sulit fokus", "pikiran bergerak terus", "latihan ringan"],
    },
    "rain_self_compassion": {
        "title": "RAIN",
        "practice": "RAIN untuk mengenali dan merawat emosi berat.",
    },
    "loving_kindness": {
        "title": "Loving-Kindness Meditation",
        "practice": "Loving-kindness meditation 7 menit.",
    },
    "mountain_meditation": {
        "title": "Mountain Meditation",
        "practice": "Mountain meditation 10-15 menit untuk melatih kestabilan saat emosi berubah.",
        "duration_minutes": 15,
        "steps": [
            "Mulai dengan persiapan tubuh dan napas.",
            "Bayangkan bentuk gunung yang kokoh.",
            "Bayangkan cuaca berubah di sekitar gunung.",
            "Hubungkan perubahan cuaca dengan perubahan pikiran dan emosi.",
            "Rasakan kestabilan tubuh sebelum kembali pada napas.",
        ],
        "best_for": ["emosi naik turun", "tidak stabil", "perubahan", "tekanan tinggi", "acceptance"],
    },
    "informal_mindfulness": {
        "title": "Informal Mindfulness",
        "practice": "Mindfulness 2-5 menit dalam aktivitas harian seperti minum, makan, atau berjalan.",
        "duration_minutes": 3,
        "steps": [
            "Pilih aktivitas harian sederhana seperti minum, makan, atau berjalan.",
            "Sadari sensasi tubuh, aroma, warna, langkah, atau napas.",
            "Lakukan aktivitas lebih perlahan dari biasanya.",
            "Jika pikiran berpindah, kembali ke sensasi aktivitas.",
            "Akhiri dengan menyadari kondisi tubuh.",
        ],
        "best_for": ["waktu terbatas", "maintenance", "pencegahan", "rutinitas harian"],
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
  "suggestion": saran singkat 1-2 kalimat berbahasa Indonesia yang suportif, actionable, dan menjelaskan cara menurunkan tekanan saat ini,
  "crisis_flag": true HANYA jika ada indikasi kuat menyakiti diri sendiri/bunuh diri, selain itu false,
  "burnout_dimensions": subset dari ["kelelahan_emosional","depersonalisasi","rendah_pencapaian_diri"], boleh kosong [],
  "practice_code": salah satu kode dari allowed_practice_codes,
  "practice_title": nama teknik dari katalog yang sesuai practice_code,
  "recommended_movement": instruksi latihan singkat dari steps teknik terpilih,
  "why_this_tactic": alasan singkat kenapa teknik ini cocok untuk jurnal tersebut
}}

Pilih teknik hanya dari mindfulness_tactics. Jangan mengarang teknik baru.
Jika steps tersedia, recommended_movement wajib mengambil inti langkah dari steps tersebut.

Data teknik:
{tactics}

Teks jurnal:
\"\"\"{text}\"\"\"
"""
GEMINI_BURNOUT_RECOMMENDATION_PROMPT = """Kamu adalah asisten mindfulness untuk guru dan siswa di Indonesia.
Tugasmu: analisis periode aktivitas, lalu pilih SATU teknik mindfulness paling cocok dari katalog sistem.
Balas HANYA JSON valid, tanpa markdown, dengan struktur:

{{
  "headline": ringkasan pendek kondisi pengguna,
  "action": feedback dan arahan 1-2 kalimat yang suportif, actionable, menyebut NAMA TEKNIK terpilih, dan menjelaskan cara menurunkan risiko burnout,
  "analysis_review": ringkasan 1 kalimat dari pola aktivitas, mood, dan jurnal yang paling berpengaruh,
  "risk_reduction_steps": daftar 2-3 langkah pendek yang bisa dilakukan hari ini,
  "recommended_movement": instruksi singkat gerakan/latihan dari teknik terpilih, harus sesuai steps di katalog jika tersedia,
  "why_this_tactic": alasan singkat kenapa teknik ini cocok dengan kondisi pengguna,
  "practice_code": salah satu kode dari allowed_practice_codes,
  "codes": daftar kode rekomendasi ringkas, harus memuat practice_code
}}

Jangan mengarang teknik baru. Pilih hanya dari allowed_practice_codes.
Gunakan hanya teknik dan gerakan dari mindfulness_tactics. Jika steps tersedia, recommended_movement wajib mengambil inti langkah dari steps tersebut.
Pastikan headline, action, recommended_movement, practice_code, dan judul teknik dari katalog konsisten satu sama lain.
Contoh gaya action: "Berdasarkan analisis hari ini, lakukan Sitting Meditation untuk membantu menurunkan ketegangan setelah aktivitas padat."

Data:
{context}
"""


class ActivityFeature(BaseModel):
    title: str | None = None
    category_name: str | None = None
    activity_kind: str | None = None
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


class MindfulnessTacticFeature(BaseModel):
    id: int | None = None
    code: str | None = None
    category: str | None = None
    title: str
    description: str | None = None
    practice: str | None = None
    knowledge: str | None = None
    duration_minutes: int | None = None
    steps: list[str] | None = None
    cues: list[str] | None = None
    best_for: list[str] | None = None


class BurnoutScoreRequest(BaseModel):
    period_type: str
    role_context: Literal["student", "teacher", "other"] = "other"
    period_capacity_hours: float = Field(gt=0)
    self_report_levels: list[int] = Field(default_factory=list)
    activities: list[ActivityFeature]
    mindfulness_tactics: list[MindfulnessTacticFeature] = Field(default_factory=list)
    scoring_version: str = SCORING_VERSION


class BurnoutRecommendationRequest(BaseModel):
    category: Literal["hijau", "kuning", "merah"] | None = None
    dominant_factors: list[str] = Field(default_factory=list)
    role_context: Literal["student", "teacher", "other"] = "other"
    mindfulness_tactics: list[MindfulnessTacticFeature] = Field(default_factory=list)


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
    recommendation = recommendation_for(
        category,
        factors,
        payload.role_context,
        payload.mindfulness_tactics,
        payload.activities,
        final_score,
        wellbeing,
        workload_raw,
    )

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
    return recommendation_for(
        payload.category,
        payload.dominant_factors,
        payload.role_context,
        payload.mindfulness_tactics,
    )


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
    dimensions = detect_burnout_dimensions(text)
    practice = tactic_by_code(journal_practice_code_for(mood_detected, dimensions, crisis_flag), tactic_catalog([]))
    return {
        "mood_detected": mood_detected,
        "suggestion": SUGGESTIONS.get(mood_detected, SUGGESTIONS["netral"]),
        "crisis_flag": crisis_flag,
        "burnout_dimensions": dimensions,
        "practice_code": practice["code"],
        "practice_title": practice["title"],
        "recommended_movement": movement_from_tactic(practice),
        "why_this_tactic": why_tactic("kuning" if mood_detected in NEGATIVE_CHECKOUT_MOODS else "hijau", ["checkout_negative_mood"], practice),
        "source": "mock",
        "raw_response": None,
    }


def gemini_journal_analysis(text: str) -> dict[str, Any] | None:
    if not GEMINI_API_KEY:
        return None
    try:
        catalog = tactic_catalog([])
        data, raw_text = gemini_json_response(GEMINI_PROMPT.format(
            text=text,
            tactics=json.dumps({
                "allowed_practice_codes": [tactic["code"] for tactic in catalog],
                "mindfulness_tactics": [
                    {
                        "code": tactic["code"],
                        "title": tactic["title"],
                        "description": tactic["description"],
                        "duration_minutes": tactic.get("duration_minutes"),
                        "steps": tactic.get("steps", [])[:6],
                        "best_for": tactic.get("best_for", []),
                    }
                    for tactic in catalog
                ],
            }, ensure_ascii=False),
        ))
        mood = data.get("mood_detected")
        selected_code = data.get("practice_code")
        practice = tactic_by_code(selected_code, catalog) if selected_code in {tactic["code"] for tactic in catalog} else None
        return {
            "mood_detected": mood if mood in VALID_ANALYSIS_MOODS else "netral",
            "suggestion": data.get("suggestion") or SUGGESTIONS["netral"],
            "crisis_flag": bool(data.get("crisis_flag", False)),
            "burnout_dimensions": [
                dimension for dimension in data.get("burnout_dimensions", [])
                if dimension in VALID_DIMENSIONS
            ],
            "practice_code": practice["code"] if practice else None,
            "practice_title": practice["title"] if practice else None,
            "recommended_movement": (data.get("recommended_movement") or movement_from_tactic(practice)) if practice else None,
            "why_this_tactic": (data.get("why_this_tactic") or why_tactic("kuning", ["checkout_negative_mood"], practice)) if practice else None,
            "source": "gemini",
            "raw_response": raw_text,
        }
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, KeyError, IndexError):
        logger.exception("Panggilan Gemini gagal, fallback ke analisis jurnal lokal")
        return None


def gemini_json_response(prompt: str) -> tuple[dict[str, Any], str]:
    query = urllib.parse.urlencode({"key": GEMINI_API_KEY})
    url = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        f"{urllib.parse.quote(GEMINI_MODEL)}:generateContent?{query}"
    )
    body = json.dumps(
        {
            "contents": [
                {"parts": [{"text": prompt}]},
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

    return json.loads(raw_text), raw_text


def detect_burnout_dimensions(text: str) -> list[str]:
    lower = text.lower()
    return [
        dimension for dimension, keywords in BURNOUT_DIMENSION_KEYWORDS.items()
        if any(keyword in lower for keyword in keywords)
    ]


def journal_practice_code_for(mood: str, dimensions: list[str], crisis_flag: bool) -> str:
    if crisis_flag:
        return "grounding_321"
    if "kelelahan_emosional" in dimensions or mood == "lelah":
        return "body_scan_micro"
    if mood == "marah":
        return "stop_technique"
    if mood == "cemas":
        return "breathing_478"
    if mood == "sedih" or "rendah_pencapaian_diri" in dimensions:
        return "loving_kindness"
    if mood == "senang":
        return "informal_mindfulness"
    return "mindful_breathing"


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


def recommendation_for(
    category: str | None,
    factors: list[str],
    role: str,
    mindfulness_tactics: list[MindfulnessTacticFeature] | None = None,
    activities: list[ActivityFeature] | None = None,
    final_score: float | None = None,
    wellbeing_score_value: float | None = None,
    workload_score: float | None = None,
) -> dict[str, Any]:
    catalog = tactic_catalog(mindfulness_tactics)
    gemini_recommendation = gemini_burnout_recommendation(
        category,
        factors,
        role,
        catalog,
        activities or [],
        final_score,
        wellbeing_score_value,
        workload_score,
    )
    if gemini_recommendation:
        return gemini_recommendation

    return local_recommendation_for(category, factors, role, catalog)


def local_recommendation_for(category: str | None, factors: list[str], role: str, catalog: list[dict[str, Any]]) -> dict[str, Any]:
    if category is None:
        practice_code = available_practice_code("breathing_space_3min", catalog)
        practice = tactic_by_code(practice_code, catalog)
        return {
            "codes": unique([practice_code, "complete_activity_journal"]),
            "headline": "Data belum cukup",
            "action": action_with_practice_title(
                "Lengkapi check-in, check-out, dan jurnal pasca pada minimal satu aktivitas lalu jalankan analisis ulang.",
                practice,
            ),
            "analysis_review": analysis_review(category, factors),
            "risk_reduction_steps": risk_reduction_steps(category, factors, role),
            "recommended_movement": movement_from_tactic(practice),
            "why_this_tactic": why_tactic(category, factors, practice),
            "practice": practice["description"] or practice["practice"],
            "practice_code": practice_code,
            "practice_title": practice["title"],
            "tactic": practice,
            "dominant_factors": factors,
            "theory_reference": "Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)",
            "source": "fastapi-rule",
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

    practice_code = available_practice_code(practice_code_for(category, factors, role), catalog)
    practice = tactic_by_code(practice_code, catalog)
    recommendation["codes"] = unique([practice_code, *codes])
    recommendation["dominant_factors"] = factors
    recommendation["practice_code"] = practice_code
    recommendation["practice_title"] = practice["title"]
    recommendation["practice"] = practice["description"] or practice["practice"]
    recommendation["action"] = action_with_practice_title(recommendation.get("action"), practice)
    recommendation["tactic"] = practice
    recommendation["analysis_review"] = analysis_review(category, factors)
    recommendation["risk_reduction_steps"] = risk_reduction_steps(category, factors, role)
    recommendation["recommended_movement"] = movement_from_tactic(practice)
    recommendation["why_this_tactic"] = why_tactic(category, factors, practice)
    recommendation["theory_reference"] = "Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)"
    recommendation["source"] = "fastapi-rule"
    return recommendation


def tactic_catalog(mindfulness_tactics: list[MindfulnessTacticFeature] | None) -> list[dict[str, Any]]:
    catalog: list[dict[str, Any]] = []
    for item in mindfulness_tactics or []:
        data = item.model_dump() if hasattr(item, "model_dump") else item.dict()
        code = data.get("code") or data.get("category")
        if not code:
            continue
        catalog.append({
            "id": data.get("id"),
            "code": code,
            "category": code,
            "title": data.get("title") or code.replace("_", " ").title(),
            "description": data.get("description") or data.get("practice") or "",
            "practice": data.get("practice") or data.get("description") or "",
            "knowledge": data.get("knowledge"),
            "duration_minutes": data.get("duration_minutes") or 3,
            "steps": data.get("steps") or [],
            "cues": data.get("cues") or [],
            "best_for": data.get("best_for") or [],
        })
    if catalog:
        return catalog

    return [
        {
            "id": None,
            "code": code,
            "category": code,
            "title": practice["title"],
            "description": practice["practice"],
            "practice": practice["practice"],
            "knowledge": None,
            "duration_minutes": practice.get("duration_minutes", 3),
            "steps": practice.get("steps", []),
            "cues": [],
            "best_for": practice.get("best_for", []),
        }
        for code, practice in PRACTICE_CATALOG.items()
    ]


def tactic_by_code(code: str, catalog: list[dict[str, Any]]) -> dict[str, Any]:
    for tactic in catalog:
        if tactic["code"] == code:
            return tactic
    return catalog[0]


def available_practice_code(preferred_code: str, catalog: list[dict[str, Any]]) -> str:
    codes = {tactic["code"] for tactic in catalog}
    if preferred_code in codes:
        return preferred_code
    fallback_order = [
        "grounding_321",
        "body_scan_micro",
        "breathing_space_3min",
        "maintain_breath_awareness",
        "stop_technique",
    ]
    for code in fallback_order:
        if code in codes:
            return code
    return catalog[0]["code"]


def gemini_burnout_recommendation(
    category: str | None,
    factors: list[str],
    role: str,
    catalog: list[dict[str, Any]],
    activities: list[ActivityFeature],
    final_score: float | None,
    wellbeing_score_value: float | None,
    workload_score: float | None,
) -> dict[str, Any] | None:
    if not GEMINI_API_KEY or not catalog:
        return None

    try:
        context = {
            "category": category,
            "final_burnout_risk_score": None if final_score is None else round(final_score, 2),
            "wellbeing_score": None if wellbeing_score_value is None else round(wellbeing_score_value, 2),
            "workload_score": None if workload_score is None else round(workload_score, 2),
            "role_context": role,
            "dominant_factors": factors,
            "allowed_practice_codes": [tactic["code"] for tactic in catalog],
            "mindfulness_tactics": [
                {
                    "code": tactic["code"],
                    "title": tactic["title"],
                    "description": tactic["description"],
                    "knowledge": tactic.get("knowledge"),
                    "duration_minutes": tactic.get("duration_minutes"),
                    "steps": tactic.get("steps", [])[:8],
                    "best_for": tactic.get("best_for", []),
                }
                for tactic in catalog
            ],
            "activities": summarize_activities(activities),
        }
        data, raw_text = gemini_json_response(
            GEMINI_BURNOUT_RECOMMENDATION_PROMPT.format(
                context=json.dumps(context, ensure_ascii=False),
            )
        )
        allowed_codes = {tactic["code"] for tactic in catalog}
        selected_code = data.get("practice_code")
        if selected_code not in allowed_codes:
            return None

        tactic = tactic_by_code(selected_code, catalog)
        codes = [
            code for code in data.get("codes", [])
            if isinstance(code, str) and code in allowed_codes
        ]

        return {
            "codes": unique([selected_code, *codes]),
            "headline": data.get("headline") or "Rekomendasi mindfulness",
            "action": action_with_practice_title(data.get("action"), tactic),
            "analysis_review": data.get("analysis_review") or analysis_review(category, factors),
            "risk_reduction_steps": clean_string_list(data.get("risk_reduction_steps"), limit=3)
            or risk_reduction_steps(category, factors, role),
            "recommended_movement": data.get("recommended_movement") or movement_from_tactic(tactic),
            "why_this_tactic": data.get("why_this_tactic") or why_tactic(category, factors, tactic),
            "practice": tactic["description"] or tactic["practice"],
            "practice_code": selected_code,
            "practice_title": tactic["title"],
            "tactic": tactic,
            "dominant_factors": factors,
            "theory_reference": "Jon Kabat-Zinn - Mindfulness-Based Stress Reduction (MBSR)",
            "source": "gemini",
            "raw_response": raw_text,
        }
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, KeyError, IndexError):
        logger.exception("Panggilan Gemini untuk rekomendasi burnout gagal, fallback ke aturan lokal")
        return None


def summarize_activities(items: list[ActivityFeature]) -> list[dict[str, Any]]:
    return [
        {
            "title": item.title,
            "category_name": item.category_name,
            "activity_kind": item.activity_kind,
            "planned_hours": item.planned_hours,
            "actual_hours": item.actual_hours,
            "intensity_factor": item.intensity_factor,
            "checkin_mood": item.checkin_mood,
            "checkout_mood": item.checkout_mood,
            "checkout_mood_detected": item.checkout_mood_detected,
            "checkout_fact": truncate_text(item.checkout_fact),
            "checkout_feeling": truncate_text(item.checkout_feeling),
            "checkout_pattern": truncate_text(item.checkout_pattern),
            "checkout_plan": truncate_text(item.checkout_plan),
            "burnout_dimensions": burnout_dimensions(item),
            "crisis_flag": item.checkout_crisis_flag,
        }
        for item in items[:12]
    ]


def clean_string_list(value: Any, limit: int = 3) -> list[str]:
    if not isinstance(value, list):
        return []
    return [
        item.strip()
        for item in value[:limit]
        if isinstance(item, str) and item.strip()
    ]


def movement_from_tactic(tactic: dict[str, Any]) -> str:
    steps = clean_string_list(tactic.get("steps"), limit=3)
    if steps:
        return "Lakukan: " + " ".join(steps)
    return tactic.get("description") or tactic.get("practice") or "Ambil jeda napas singkat dengan sadar."


def action_with_practice_title(action: str | None, tactic: dict[str, Any]) -> str:
    title = str(tactic.get("title") or "latihan mindfulness").strip()
    text = (action or "").strip()
    if title and title.lower() in text.lower():
        return text
    if text:
        return f"Berdasarkan analisis ini, lakukan {title} untuk membantu Anda. {text}"
    return f"Berdasarkan analisis ini, lakukan {title} untuk membantu menurunkan tekanan dan menata kembali energi."


def analysis_review(category: str | None, factors: list[str]) -> str:
    if category is None:
        return "Data jurnal belum cukup, jadi sistem perlu minimal satu check-out lengkap untuk membaca pola tekanan."
    if "crisis_flag" in factors:
        return "Jurnal memuat sinyal krisis sehingga dukungan manusia perlu diprioritaskan sebelum menambah beban."
    if "journal_pressure_terms" in factors or "checkout_negative_mood" in factors:
        return "Mood atau isi jurnal menunjukkan tekanan yang mulai memengaruhi kondisi setelah aktivitas."
    if "workload_over_capacity" in factors or "dense_workload" in factors:
        return "Beban aktivitas pada periode ini cukup padat dibanding kapasitas pemulihan."
    return "Aktivitas dan jurnal masih relatif terkendali, dengan ruang untuk menjaga jeda pemulihan."


def risk_reduction_steps(category: str | None, factors: list[str], role: str) -> list[str]:
    if category is None:
        return [
            "Lengkapi check-in dan check-out pada aktivitas berikutnya.",
            "Tulis fakta dan perasaan secara singkat agar pola bisa terbaca.",
        ]
    if "crisis_flag" in factors:
        return [
            "Hubungi orang tepercaya atau pendamping sekolah.",
            "Kurangi aktivitas tambahan sampai kondisi lebih aman.",
            "Lakukan grounding singkat sambil ditemani.",
        ]
    if category == "merah":
        return [
            "Turunkan prioritas aktivitas yang bisa ditunda.",
            "Ambil jeda pemulihan sebelum aktivitas berikutnya.",
            "Minta dukungan guru BK, wali kelas, keluarga, atau rekan kerja.",
        ]
    if category == "kuning":
        return [
            "Cari aktivitas yang paling menguras energi.",
            "Sisipkan jeda napas atau body scan pendek.",
            "Kurangi multitasking pada aktivitas berikutnya.",
        ]
    if role == "student":
        return [
            "Pertahankan ritme belajar yang stabil.",
            "Gunakan jeda napas singkat sebelum berpindah aktivitas.",
        ]
    return [
        "Pertahankan jeda transisi antar aktivitas.",
        "Gunakan awareness napas sebelum masuk aktivitas berikutnya.",
    ]


def why_tactic(category: str | None, factors: list[str], tactic: dict[str, Any]) -> str:
    title = tactic.get("title") or "Teknik ini"
    if category is None:
        return f"{title} dipilih sebagai latihan awal yang ringan sambil menunggu data jurnal lebih lengkap."
    if "journal_pressure_terms" in factors or "checkout_negative_mood" in factors:
        return f"{title} cocok untuk membantu tubuh turun dari tekanan emosi setelah aktivitas."
    if "workload_over_capacity" in factors or "dense_workload" in factors:
        return f"{title} cocok sebagai jeda pemulihan singkat di tengah beban aktivitas yang padat."
    return f"{title} cocok untuk menjaga kestabilan perhatian dan energi."


def truncate_text(value: str | None, limit: int = 180) -> str | None:
    if not value:
        return None
    text = value.strip()
    if len(text) <= limit:
        return text
    return text[:limit].rstrip() + "..."
