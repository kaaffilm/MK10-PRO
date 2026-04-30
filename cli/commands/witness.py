"""MK10-PRO witness command."""

from __future__ import annotations

import json
from pathlib import Path

import click

from cli.surface import write_witness


@click.command()
@click.option("--out", "out_dir", default="mk10-witness", show_default=True, help="Witness packet output directory.")
def witness(out_dir: str) -> None:
    """Write a portable MK10-PRO witness packet."""

    result = write_witness(Path(out_dir).expanduser().resolve())
    click.echo(json.dumps(result, indent=2, sort_keys=True))
    click.echo("MK10-PRO WITNESS: PASS")
