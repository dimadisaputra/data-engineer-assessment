import pandas as pd
import re
import os
import difflib
from pathlib import Path
from datetime import datetime
import logging

# ======================
# SETUP DIRECTORIES & LOGGING
# ======================
Path("2-etl-assessment/logs").mkdir(parents=True, exist_ok=True)
Path("2-etl-assessment/data").mkdir(parents=True, exist_ok=True)

# Setup logging
log_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
log_file = f"2-etl-assessment/logs/etl_process_{log_timestamp}.log"
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(message)s",
    handlers=[
        logging.FileHandler(log_file, encoding="utf-8"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# ======================
# HELPER FUNCTIONS
# ======================
def clean_string(s: str) -> str:
    """Remove all spaces, punctuation and uppercase for robust comparison."""
    if not s: return ""
    return re.sub(r'[^A-Z0-9]', '', str(s).upper())

def normalize_master_city_name(city_str: str) -> str:
    """
    Normalize master city name by removing prefixes:
    - "Kabupaten Aceh Barat" → "ACEH BARAT"
    - "Kota Bandung" → "BANDUNG"
    - "Kota Adm. Jakarta Barat" → "JAKARTA BARAT"
    """
    if pd.isna(city_str):
        return ""
    
    city_str = str(city_str).strip()
    # Remove prefixes in specific order
    city_str = re.sub(r"^Kabupaten\s+", "", city_str, flags=re.IGNORECASE)
    city_str = re.sub(r"^Kota\s+Adm\.\s+", "", city_str, flags=re.IGNORECASE)
    city_str = re.sub(r"^Kota\s+", "", city_str, flags=re.IGNORECASE)
    # Normalize whitespace and uppercase
    return " ".join(city_str.split()).upper()

def parse_alamat4(alamat4_val) -> tuple:
    """
    Parse Alamat4 value into (city_name, city_type)
    Returns:
        - city_name: normalized name (e.g., "BATAM")
        - city_type: "kota", "kabupaten", or "invalid"
    """
    if pd.isna(alamat4_val) or str(alamat4_val).strip() == "":
        return None, None
    
    val = str(alamat4_val).strip().upper()
    
    # Pattern 1: "NAMA KOTA, KOTA" → Kota
    if re.search(r",\s*KOTA$", val):
        city_name = re.sub(r",\s*KOTA$", "", val).strip()
        city_type = "kota"
    # Pattern 2: "NAMA KABUPATEN" → Kabupaten
    else:
        city_name = val
        city_type = "kabupaten"
    
    # Clean extra spaces
    city_name = " ".join(city_name.split())
    return city_name, city_type

def create_master_lookup(master_df: pd.DataFrame) -> tuple:
    """
    Create two lookup dictionaries from master data:
    1. kabupaten_lookup: {normalized_name: row}
    2. kota_lookup: {normalized_name: row}
    """
    kab_lookup = {}
    kota_lookup = {}
    unmapped_master = []
    
    for idx, row in master_df.iterrows():
        city_full = row["City"]
        city_norm = normalize_master_city_name(city_full)
        
        if not city_norm:
            unmapped_master.append(city_full)
            continue
        
        # Determine type from original City name
        if str(city_full).lower().startswith("kabupaten"):
            kab_lookup[city_norm] = row
        elif str(city_full).lower().startswith("kota"):
            kota_lookup[city_norm] = row
        else:
            logger.warning(f"Unrecognized city type in master: {city_full}")
    
    logger.info(f"Master lookup created: {len(kab_lookup)} kabupaten, {len(kota_lookup)} kota")
    if unmapped_master:
        logger.warning(f"Unmapped master entries: {len(unmapped_master)}")
    
    return kab_lookup, kota_lookup

# ======================
# MAIN ETL PIPELINE
# ======================
def run_etl():
    logger.info("="*60)
    logger.info("STARTING ETL PROCESS FOR ASSET DATA")
    logger.info("="*60)
    
    # === STEP 1: LOAD DATA ===
    logger.info("Step 1: Loading datasets...")
    try:
        master_df = pd.read_excel("2-etl-assessment/data/City Indonesia.xlsx")
        asset_df = pd.read_excel("2-etl-assessment/data/Assessment Data Asset Dummy.xlsx")
        logger.info(f"✓ Master data loaded: {len(master_df)} rows")
        logger.info(f"✓ Asset data loaded: {len(asset_df)} rows")
    except Exception as e:
        logger.error(f"Failed to load data: {str(e)}")
        raise
    
    # === STEP 2: DATA VALIDATION ===
    logger.info("\nStep 2: Data validation...")
    
    # Required fields check
    required_cols = ["Funcloc", "Alamat4"]
    missing_cols = [col for col in required_cols if col not in asset_df.columns]
    if missing_cols:
        logger.error(f"Missing required columns: {missing_cols}")
        raise ValueError(f"Missing columns: {missing_cols}")
    
    # Check nulls in required fields
    null_funcloc = asset_df["Funcloc"].isnull().sum()
    null_alamat4 = asset_df["Alamat4"].isnull().sum()
    logger.info(f"  - Null Funcloc: {null_funcloc}")
    logger.info(f"  - Null Alamat4: {null_alamat4}")
    
    if null_funcloc > 0 or null_alamat4 > 0:
        asset_df = asset_df.dropna(subset=["Funcloc", "Alamat4"]).reset_index(drop=True)
        logger.warning(f"Dropped {null_funcloc + null_alamat4} rows with null required fields")
    
    logger.info(f"✓ Valid records after validation: {len(asset_df)}")
    
    # === STEP 3: CREATE MASTER LOOKUP ===
    logger.info("\nStep 3: Creating master data lookup...")
    kab_lookup, kota_lookup = create_master_lookup(master_df)
    
    # === STEP 4: NORMALIZE & MAP ALAMAT4 ===
    logger.info("\nStep 4: Normalizing Alamat4 and mapping to master data...")
    
    # Prepare result containers
    mapped_records = []
    unmapped_records = []
    
    for idx, row in asset_df.iterrows():
        alamat4_raw = row["Alamat4"]
        city_name, city_type = parse_alamat4(alamat4_raw)
        
        if city_name is None:
            unmapped_records.append({
                "row_index": idx,
                "Funcloc": row["Funcloc"],
                "Alamat4_Raw": alamat4_raw,
                "Error": "Empty or invalid Alamat4 value"
            })
            continue
            
        if city_type == "invalid":
            unmapped_records.append({
                "row_index": idx,
                "Funcloc": row["Funcloc"],
                "Alamat4_Raw": alamat4_raw,
                "City_Name_Normalized": city_name,
                "Error": f"Ambiguous record: '{city_name}' (requires specific region/city)"
            })
            continue
        
        # Lookup based on type
        target_lookup = kota_lookup if city_type == "kota" else kab_lookup
        
        # 1. Exact Match on Normalized Name
        master_data = target_lookup.get(city_name)
        
        # 2. Advanced Fallback: Clean-string & Partial Match
        if master_data is None:
            clean_input = clean_string(city_name)
            
            # Find all potential matches
            potential_matches = []
            # Priority 1: Exact match after cleaning (e.g., 'Labuhan Batu' == 'Labuhanbatu')
            for m_name, m_row in target_lookup.items():
                clean_m_name = clean_string(m_name)
                if clean_input == clean_m_name:
                    potential_matches.append(m_row)
            
            # Priority 2: Substring match after cleaning (if no exact clean match found)
            if not potential_matches:
                for m_name, m_row in target_lookup.items():
                    clean_m_name = clean_string(m_name)
                    if clean_input in clean_m_name or clean_m_name in clean_input:
                        potential_matches.append(m_row)
            
            if len(potential_matches) == 1:
                master_data = potential_matches[0]
                logger.info(f"Auto-mapped (Space-Insensitive) '{city_name}' → '{master_data['City']}'")
            elif len(potential_matches) > 1:
                unmapped_records.append({
                    "row_index": idx,
                    "Funcloc": row["Funcloc"],
                    "Alamat4_Raw": alamat4_raw,
                    "City_Name_Normalized": city_name,
                    "Error": f"Ambiguous: {len(potential_matches)} matches found (e.g. {potential_matches[0]['City']})"
                })
                continue
            
            # 3. Fuzzy Match Fallback (Handles typos like KERTANEGARA vs KARTANEGARA)
            if master_data is None:
                all_master_names = list(target_lookup.keys())
                # Get the single best match with a similarity score
                matches = difflib.get_close_matches(city_name, all_master_names, n=1, cutoff=0.8)
                
                if matches:
                    master_data = target_lookup[matches[0]]
                    logger.warning(f"Fuzzy-mapped '{city_name}' → '{master_data['City']}' (Similarity > 80%)")
        
        if master_data is not None:
            mapped_records.append({
                "Funcloc": row["Funcloc"],
                "Alamat4_Raw": alamat4_raw,
                "City_Name_Normalized": city_name,
                "City_Type": city_type,
                "City_Match": master_data["City"],
                "CityCode": master_data["CityCode"],
                "RegionalCode": master_data["RegionalCode"],
                "Province": master_data["Province"],
                "Region": master_data["Region"]
            })
        else:
            # Fallback: cek tipe sebaliknya (misal "BANDUNG" tanpa koma seharusnya Kota)
            fallback_data = None
            if city_type == "kabupaten" and city_name in kota_lookup:
                fallback_data = kota_lookup[city_name]
                fallback_type = "kota"
            elif city_type == "kota" and city_name in kab_lookup:
                fallback_data = kab_lookup[city_name]
                fallback_type = "kabupaten"
            
            if fallback_data is not None:
                logger.warning(
                    f"Cross-type match for Funcloc {row['Funcloc']}: "
                    f"'{alamat4_raw}' ({city_type}) → matched as {fallback_type} '{fallback_data['City']}'"
                )
                mapped_records.append({
                    "Funcloc": row["Funcloc"],
                    "Alamat4_Raw": alamat4_raw,
                    "City_Name_Normalized": city_name,
                    "City_Type": fallback_type,
                    "City_Match": fallback_data["City"],
                    "CityCode": fallback_data["CityCode"],
                    "RegionalCode": fallback_data["RegionalCode"],
                    "Province": fallback_data["Province"],
                    "Region": fallback_data["Region"]
                })
            else:
                unmapped_records.append({
                    "row_index": idx,
                    "Funcloc": row["Funcloc"],
                    "Alamat4_Raw": alamat4_raw,
                    "City_Name_Normalized": city_name,
                    "City_Type": city_type,
                    "Error": "No match found in master data"
                })
    
    logger.info(f"✓ Successfully mapped: {len(mapped_records)} records")
    logger.info(f"✓ Unmapped records: {len(unmapped_records)}")
    
    # === STEP 5: GENERATE INTERNAL SITE ID ===
    logger.info("\nStep 5: Generating Internal Site ID (AAA-BB-CCC)...")
    
    if mapped_records:
        mapped_df = pd.DataFrame(mapped_records)
        
        # Sort by CityCode then Funcloc for sequential numbering
        mapped_df = mapped_df.sort_values(by=["CityCode", "Funcloc"]).reset_index(drop=True)
        
        # Generate sequential number (CCC) per CityCode group starting from 001
        mapped_df["Seq_Num"] = mapped_df.groupby("CityCode").cumcount() + 1
        mapped_df["CCC"] = mapped_df["Seq_Num"].apply(lambda x: f"{x:03d}")
        
        # Format Internal Site ID: AAA-BB-CCC
        # AAA = CityCode, BB = RegionalCode (padded to 2 digits), CCC = Sequence
        mapped_df["Internal_Site_ID"] = (
            mapped_df["CityCode"].astype(str) + "-" + 
            mapped_df["RegionalCode"].apply(lambda x: f"{int(float(x)):02d}" if pd.notna(x) else "00") + "-" + 
            mapped_df["CCC"]
        )
        
        # Reorder columns to match requirement: Internal_Site_ID first, Funcloc last
        final_columns = [
            "Internal_Site_ID",
            "City_Match",
            "CityCode",
            "RegionalCode",
            "Province",
            "Region",
            "Alamat4_Raw",
            "Funcloc"
        ]
        # Include original asset columns if needed
        asset_cols = [col for col in asset_df.columns if col not in ["Funcloc", "Alamat4"]]
        output_df = mapped_df[final_columns].copy()
        
        logger.info(f"✓ Generated {len(output_df)} Internal Site IDs")
    else:
        logger.error("No records mapped - cannot generate Internal Site ID")
        output_df = pd.DataFrame()
    
    # === STEP 6: SAVE RESULTS & LOGS ===
    logger.info("\nStep 6: Saving results...")
    
    # Save successful mappings
    if not output_df.empty:
        output_path = f"2-etl-assessment/data/asset_enriched_{log_timestamp}.xlsx"
        output_df.to_excel(output_path, index=False)
        logger.info(f"✓ Enriched data saved to: {output_path}")
    
    # Save unmapped records for review
    if unmapped_records:
        unmapped_df = pd.DataFrame(unmapped_records)
        unmapped_path = f"2-etl-assessment/data/unmapped_alamat4_{log_timestamp}.xlsx"
        unmapped_df.to_excel(unmapped_path, index=False)
        logger.warning(f"✓ Unmapped records saved to: {unmapped_path}")
        
        # Log top 10 unmapped patterns
        top_unmapped = unmapped_df["City_Name_Normalized"].value_counts().head(10)
        logger.warning(f"Top 10 unmapped patterns:\n{top_unmapped.to_string()}")
    
    # Save summary report
    summary = f"""
ETL PROCESS SUMMARY
===================
Timestamp          : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Total Input Records: {len(asset_df)}
Mapped Records     : {len(mapped_records)}
Unmapped Records   : {len(unmapped_records)}
Success Rate       : {len(mapped_records)/len(asset_df)*100:.2f}%

Master Data Stats:
  - Kabupaten entries: {len(kab_lookup)}
  - Kota entries     : {len(kota_lookup)}

Output Files:
  - Enriched data    : {output_path if not output_df.empty else 'N/A'}
  - Unmapped records : {unmapped_path if unmapped_records else 'None'}
  - Full log         : {log_file}
"""
    summary_path = f"2-etl-assessment/logs/summary_{log_timestamp}.txt"
    with open(summary_path, "w", encoding="utf-8") as f:
        f.write(summary)
    
    logger.info(f"\n✓ Summary report saved to: {summary_path}")
    logger.info("\n" + "="*60)
    logger.info("ETL PROCESS COMPLETED SUCCESSFULLY")
    logger.info("="*60)
    
    return output_df, unmapped_records

# ======================
# EXECUTE PIPELINE
# ======================
if __name__ == "__main__":
    try:
        enriched_df, unmapped = run_etl()
        
        # Quick validation
        if not enriched_df.empty:
            print("\n✅ Sample of generated Internal Site IDs:")
            print(enriched_df[["Internal_Site_ID", "Funcloc", "City_Match"]].head(10).to_string(index=False))
        
        if unmapped:
            print(f"\n⚠️  {len(unmapped)} records require manual review (see unmapped file)")
    
    except Exception as e:
        logger.exception(f"ETL process failed with error: {str(e)}")
        raise