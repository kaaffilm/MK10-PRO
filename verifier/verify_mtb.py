"""
Public MTB verifier.

No engine, no trust, no authority required.
Any third party can verify an MTB using only public rules.
"""

from pathlib import Path
from typing import Dict, Any
import sys

from mtb.verify import verify_mtb


def main():
    """CLI entry point for MTB verification."""
    if len(sys.argv) < 2:
        print("Usage: verify_mtb <mtb_path>")
        sys.exit(1)
    
    mtb_path = Path(sys.argv[1])
    
    if not mtb_path.exists():
        print(f"Error: MTB file not found: {mtb_path}")
        sys.exit(1)
    
    print(f"Verifying MTB: {mtb_path}")
    results = verify_mtb(mtb_path)
    
    if results["valid"]:
        print("✓ MTB is valid")
        if results["warnings"]:
            print("\nWarnings:")
            for warning in results["warnings"]:
                print(f"  - {warning}")
        sys.exit(0)
    else:
        print("✗ MTB is invalid")
        print("\nErrors:")
        for error in results["errors"]:
            print(f"  - {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()

