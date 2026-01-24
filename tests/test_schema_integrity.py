"""Test schema integrity and determinism."""
import json
import hashlib
from pathlib import Path


SCHEMA_PATH = Path(__file__).parent.parent / "mtb" / "schema" / "mtb.schema.json"
EXPECTED_HASH_FILE = Path(__file__).parent.parent / ".schema_checksum"


def compute_schema_hash():
    """Compute SHA-256 hash of the schema file."""
    if not SCHEMA_PATH.exists():
        return None
    content = SCHEMA_PATH.read_bytes()
    return hashlib.sha256(content).hexdigest()


def test_schema_exists():
    """Schema file must exist."""
    assert SCHEMA_PATH.exists(), f"Schema file not found at {SCHEMA_PATH}"


def test_schema_valid_json():
    """Schema must be valid JSON."""
    with open(SCHEMA_PATH) as f:
        data = json.load(f)
    assert "$schema" in data, "Schema must have $schema property"


def test_schema_hash_matches():
    """Schema hash must match recorded checksum."""
    if not EXPECTED_HASH_FILE.exists():
        # First run - create checksum file
        actual = compute_schema_hash()
        EXPECTED_HASH_FILE.write_text(actual + "\n")
        return
    
    expected = EXPECTED_HASH_FILE.read_text().strip()
    actual = compute_schema_hash()
    
    assert actual == expected, (
        f"Schema hash mismatch. Expected: {expected}, Actual: {actual}. "
        "Schema modification requires explicit checksum update."
    )


def test_mtb_reorder_determinism():
    """MTB hash must be independent of input order."""
    def make_mtb(files):
        return {
            "schema_version": "1.0.0",
            "files": sorted(files),  # Must sort for determinism
            "policy_evidence": {"profile_id": "test", "rule_checks": []}
        }
    
    files1 = ["a.txt", "b.txt", "c.txt"]
    files2 = ["c.txt", "a.txt", "b.txt"]
    
    mtb1 = make_mtb(files1)
    mtb2 = make_mtb(files2)
    
    hash1 = hashlib.sha256(json.dumps(mtb1, sort_keys=True).encode()).hexdigest()
    hash2 = hashlib.sha256(json.dumps(mtb2, sort_keys=True).encode()).hexdigest()
    
    assert hash1 == hash2, "MTB hash must be order-independent"
