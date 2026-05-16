import pandas as pd
import json
import time
from geopy.geocoders import Nominatim

file_path = r"C:\Users\sujal\Desktop\women sefty ai\safenet_ai\bangalore_crime_dataset.xlsx"

try:
    df = pd.read_excel(file_path)
    geolocator = Nominatim(user_agent="safenet_ai_geocoder")
    
    results = []
    
    for index, row in df.iterrows():
        area = row.get("Area", "Unknown")
        total = row.get("Total", 0)
        
        # Risk thresholds
        if total > 300:
            risk = "High"
        elif total > 200:
            risk = "Medium"
        else:
            risk = "Low"
            
        location_query = f"{area}, Bangalore, India"
        try:
            location = geolocator.geocode(location_query)
            if location:
                results.append({
                    "area": area,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "total_crimes": int(total),
                    "risk_level": risk
                })
            else:
                print(f"Could not geocode {area}")
        except Exception as e:
            print(f"Error geocoding {area}: {e}")
        time.sleep(1) # respect API limits
        
    with open("bangalore_danger_zones.json", "w") as f:
        json.dump(results, f, indent=4)
        
    print("FINISHED GEOCODING!")
except Exception as e:
    print(f"Fatal script error: {e}")
