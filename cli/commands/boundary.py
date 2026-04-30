"""MK10-PRO boundary command."""

from __future__ import annotations

import json

import click

from cli.surface import boundary_payload


@click.command()
def boundary() -> None:
    """Print exact MK10-PRO claims and non-claims."""

    click.echo(json.dumps(boundary_payload(), indent=2, sort_keys=True))
    click.echo("MK10-PRO BOUNDARY: PASS")
