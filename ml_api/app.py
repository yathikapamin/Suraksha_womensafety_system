"""
SafeNet AI - ML Risk Scoring API
Flask-based API for location risk assessment using simple ML heuristics.
In production, replace with a trained model using crime data, lighting data, etc.
"""

from flask import Flask, request, jsonify
from datetime import datetime
import math
import random

app = Flask(__name__)

# ═══════════════════════════════════════
# RISK FACTORS DATABASE (simulated)
# ═══════════════════════════════════════

# Known high-risk zones (lat, lng, radius_km, risk_weight)
HIGH_RISK_ZONES = [
    {"lat": 12.9716, "lng": 77.5946, "radius": 0.5, "risk": 0.7, "name": "Zone A"},
    {"lat": 12.9352, "lng": 77.6245, "radius": 0.3, "risk": 0.8, "name": "Zone B"},
    {"lat": 13.0827, "lng": 80.2707, "radius": 0.4, "risk": 0.6, "name": "Zone C"},
]


def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two points in km."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    return R * c


def calculate_time_risk():
    """Risk based on time of day."""
    hour = datetime.now().hour
    if 22 <= hour or hour <= 5:
        return 0.8  # Late night - highest risk
    elif 18 <= hour <= 22:
        return 0.5  # Evening
    elif 5 <= hour <= 7:
        return 0.4  # Early morning
    else:
        return 0.1  # Daytime - lowest risk


def calculate_zone_risk(lat, lng):
    """Risk based on proximity to known high-risk zones."""
    max_risk = 0.0
    for zone in HIGH_RISK_ZONES:
        dist = haversine_distance(lat, lng, zone["lat"], zone["lng"])
        if dist <= zone["radius"]:
            zone_risk = zone["risk"] * (1 - dist / zone["radius"])
            max_risk = max(max_risk, zone_risk)
    return max_risk


def calculate_day_risk():
    """Risk based on day of week."""
    day = datetime.now().weekday()  # 0=Monday
    weekend_risk = 0.3 if day >= 5 else 0.1
    return weekend_risk


# ═══════════════════════════════════════
# API ENDPOINTS
# ═══════════════════════════════════════

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "SafeNet AI ML API", "version": "1.0.0"})


@app.route("/api/location-risk", methods=["POST"])
def location_risk():
    """Calculate risk score for a given location."""
    data = request.get_json()
    lat = data.get("latitude", 0)
    lng = data.get("longitude", 0)

    time_risk = calculate_time_risk()
    zone_risk = calculate_zone_risk(lat, lng)
    day_risk = calculate_day_risk()

    # Weighted combination
    location_risk_score = (time_risk * 0.4) + (zone_risk * 0.4) + (day_risk * 0.2)

    # Add small random noise for realism
    noise = random.uniform(-0.05, 0.05)
    location_risk_score = max(0.0, min(1.0, location_risk_score + noise))

    return jsonify({
        "location_risk_score": round(location_risk_score, 3),
        "components": {
            "time_risk": round(time_risk, 3),
            "zone_risk": round(zone_risk, 3),
            "day_risk": round(day_risk, 3),
        },
        "time_of_day": datetime.now().strftime("%H:%M"),
        "day_of_week": datetime.now().strftime("%A"),
        "coordinates": {"lat": lat, "lng": lng},
    })


@app.route("/api/calculate-risk", methods=["POST"])
def calculate_risk():
    """Full risk calculation combining all sensor inputs."""
    data = request.get_json()
    motion_score = data.get("motion_score", 0)
    audio_score = data.get("audio_score", 0)
    lat = data.get("latitude", 0)
    lng = data.get("longitude", 0)

    # Location risk
    time_risk = calculate_time_risk()
    zone_risk = calculate_zone_risk(lat, lng)
    day_risk = calculate_day_risk()
    location_risk = (time_risk * 0.4) + (zone_risk * 0.4) + (day_risk * 0.2)

    # Final risk = weighted combination
    MOTION_WEIGHT = 0.3
    AUDIO_WEIGHT = 0.4
    LOCATION_WEIGHT = 0.3

    final_risk = (motion_score * MOTION_WEIGHT) + (audio_score * AUDIO_WEIGHT) + (location_risk * LOCATION_WEIGHT)
    final_risk = max(0.0, min(1.0, final_risk))

    # Determine level
    if final_risk >= 0.6:
        risk_level = "HIGH"
        alert = True
    elif final_risk >= 0.3:
        risk_level = "MEDIUM"
        alert = False
    else:
        risk_level = "LOW"
        alert = False

    return jsonify({
        "final_risk_score": round(final_risk, 3),
        "risk_level": risk_level,
        "alert_triggered": alert,
        "components": {
            "motion": {"score": motion_score, "weight": MOTION_WEIGHT, "contribution": round(motion_score * MOTION_WEIGHT, 3)},
            "audio": {"score": audio_score, "weight": AUDIO_WEIGHT, "contribution": round(audio_score * AUDIO_WEIGHT, 3)},
            "location": {"score": round(location_risk, 3), "weight": LOCATION_WEIGHT, "contribution": round(location_risk * LOCATION_WEIGHT, 3)},
        },
        "threshold": 0.6,
    })


if __name__ == "__main__":
    print("🛡️ SafeNet AI ML Risk API starting...")
    print("📍 Endpoints:")
    print("   GET  /api/health")
    print("   POST /api/location-risk")
    print("   POST /api/calculate-risk")
    app.run(host="0.0.0.0", port=5000, debug=True)
