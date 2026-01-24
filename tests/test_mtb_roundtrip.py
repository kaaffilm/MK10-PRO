"""Test MTB round-trip verification."""
import json
import hashlib
from pathlib import Path


def compute_hash(data: dict) -> str:
    """Compute deterministic hash of MTB data."""
    canonical = json.dumps(data, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(canonical.encode()).hexdigest()


def test_mtb_roundtrip():
    """MTB should survive JSON serialization round-trip with same hash."""
    sample_mtb = {
        "schema_version": "1.0.0",
        "bundle_hash": "abc123",
        "created_at": "2026-01-24T00:00:00Z",
        "files": [],
        "policy_evidence": {
            "profile_id": "test",
            "rule_checks": [
                {"rule_id": "test_rule", "passed": True}
            ]
        }
    }
    
    # Serialize and deserialize
    serialized = json.dumps(sample_mtb, sort_keys=True)
    deserialized = json.loads(serialized)
    
    # Hash should be identical
    hash1 = compute_hash(sample_mtb)
    hash2 = compute_hash(deserialized)
    
    assert hash1 == hash2, "MTB hash must survive round-trip"


def test_mtb_key_order_independence():
    """MTB hash should not depend on original key order."""
    mtb1 = {"a": 1, "b": 2, "c": 3}
    mtb2 = {"c": 3, "a": 1, "b": 2}
    
    assert compute_hash(mtb1) == compute_hash(mtb2), "Key order must not affect hash"
