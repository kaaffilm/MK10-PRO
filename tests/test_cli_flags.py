"""Test that CLI rejects unknown flags."""
import subprocess
import pytest


def test_reject_unknown_flag():
    """CLI must reject any unknown flag."""
    result = subprocess.run(
        ["python", "-m", "cli", "--unknown-flag"],
        capture_output=True,
        text=True
    )
    assert result.returncode != 0, "Unknown flag should cause non-zero exit"


def test_reject_unknown_short_flag():
    """CLI must reject any unknown short flag."""
    result = subprocess.run(
        ["python", "-m", "cli", "-x"],
        capture_output=True,
        text=True
    )
    assert result.returncode != 0, "Unknown short flag should cause non-zero exit"


def test_known_flags_accepted():
    """Known flags should be accepted (help at minimum)."""
    result = subprocess.run(
        ["python", "-m", "cli", "--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, "--help should succeed"
