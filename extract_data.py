import pandas as pd
import json

file_path = r"C:\Users\sujal\Desktop\women sefty ai\safenet_ai\bangalore_crime_dataset.xlsx"

try:
    df = pd.read_excel(file_path)
    output = {
        "columns": df.columns.tolist(),
        "sample": df.head(5).to_dict('records')
    }
    with open("dataset_inspect.json", "w") as f:
        json.dump(output, f, indent=4)
except Exception as e:
    with open("dataset_inspect.json", "w") as f:
        f.write(f"Error: {e}")
