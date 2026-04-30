"""MK10-PRO proof command."""

from __future__ import annotations

import json

import click

from cli.surface import assert_surface, surface_facts


@click.command()
def proof() -> None:
    """Verify the MK10-PRO package/source truth surface."""

    facts = surface_facts()
    click.echo(json.dumps(facts, indent=2, sort_keys=True))

    try:
        assert_surface(facts)
    except RuntimeError as exc:
        raise click.ClickException(str(exc)) from exc

    click.echo("MK10-PRO PROOF: PASS")
