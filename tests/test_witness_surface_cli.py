import json
import subprocess
import sys


def run_cmd(*args):
    return subprocess.run(args, check=True, text=True, capture_output=True)


def test_proof_command():
    result = run_cmd(sys.executable, "-m", "cli", "proof")
    assert "MK10-PRO PROOF: PASS" in result.stdout
    data = json.loads(result.stdout.split("\nMK10-PRO PROOF: PASS")[0])
    assert data["version"] == data["engine_version"]
    assert data["license"] == "Apache-2.0"


def test_boundary_command():
    result = run_cmd(sys.executable, "-m", "cli", "boundary")
    assert "MK10-PRO BOUNDARY: PASS" in result.stdout
    data = json.loads(result.stdout.split("\nMK10-PRO BOUNDARY: PASS")[0])
    assert "playback" in data["does_not_verify"]
    assert data["distribution_boundary"]["v1_0_3"] == "witness release"


def test_witness_command(tmp_path):
    out = tmp_path / "witness"
    result = run_cmd(sys.executable, "-m", "cli", "witness", "--out", str(out))
    assert "MK10-PRO WITNESS: PASS" in result.stdout
    assert (out / "MK10-WITNESS.json").exists()
    assert (out / "BOUNDARY.json").exists()
    assert (out / "SHA256SUMS").exists()
