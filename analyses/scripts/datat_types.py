
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]

PROTOCOLS_FILE = BASE_DIR / "seeds" / "protocols.csv"

print(f"Lese Datei: {PROTOCOLS_FILE}")

df = pd.read_csv(PROTOCOLS_FILE, sep=";",
    nrows=0)
print("protocols:")
print("  +column_types:")

for column in df.columns:
    print(f'    {column}: String')