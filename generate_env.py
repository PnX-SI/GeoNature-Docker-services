#!/usr/bin/env python3

# Attention ce script est encore en WIP

import click
from pathlib import Path
import re
import secrets
import string
from passlib.hash import apr_md5_crypt

ENV_SAMPLE = Path(".env.sample")
ENV_OUTPUT = Path(".env")


def uncomment_line(content, pattern):
    return [line.lstrip('#').strip() if pattern in line else line for line in content]


def comment_line(content, pattern):
    return ['#' + line if pattern in line and not line.strip().startswith('#') else line for line in content]


def get_default_from_sample(var_name, lines):
    for line in lines:
        if line.strip().startswith(f"{var_name}="):
            # Remove var= and optional quotes
            val = re.sub(rf'^{var_name}=\s*', '', line).strip()
            return val.strip('"').strip("'")
    return ""


def generate_password(length=16):
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))


@click.command()
def generate_env():
    click.echo("⚠️  This CLI is experimental and may change.")

    if not ENV_SAMPLE.exists():
        click.echo("❌ .env.sample not found.")
        return

    content = ENV_SAMPLE.read_text().splitlines()
    modified = content.copy()

    mode = click.prompt("Installation mode", type=click.Choice(["prod", "dev"]), default="prod")

    if mode == "dev":
        use_prebuilt = click.confirm("Use pre-built database image?", default=False)

        dev_patterns = [
            "USERSHUB_IMAGE=\"ghcr.io/pnx-si/usershub-local:latest\"",
            "GEONATURE_BACKEND_IMAGE=",
            "GEONATURE_BACKEND_EXTRA_IMAGE=",
            "GEONATURE_FRONTEND_IMAGE=",
            "GEONATURE_FRONTEND_EXTRA_IMAGE=",
            "GEONATURE_PRE_BUILT_DB=",
            "COMPOSE_FILE=essential.yml:traefik.yml:dev.yml"
        ]
        for pattern in dev_patterns:
            modified = uncomment_line(modified, pattern)

        if use_prebuilt:
            modified = uncomment_line(modified, "COMPOSE_PROFILES=pre-built-db,usershub")
            modified = uncomment_line(modified, "POSTGRES_HOST=geonature-pre-built-db")
        else:
            modified = uncomment_line(modified, "COMPOSE_PROFILES=db,usershub")

            # Ask for external DB usage (added per your request)
            use_external_db = click.confirm("Use an external PostgreSQL database (outside docker-compose)?", default=False)
            if use_external_db:
                default_postgres_host = get_default_from_sample("POSTGRES_HOST", content) or "localhost"
                default_postgres_db = get_default_from_sample("POSTGRES_DB", content) or "geonature2db"
                default_postgres_port = get_default_from_sample("POSTGRES_PORT", content) or "5432"

                postgres_host = click.prompt("Postgres host", default=default_postgres_host)
                postgres_db = click.prompt("Postgres database name", default=default_postgres_db)
                postgres_port = click.prompt("Postgres port", default=default_postgres_port)

                # Update lines
                def update_line(lines, var, value):
                    pattern = re.compile(rf"^{var}=.*")
                    found = False
                    new_lines = []
                    for line in lines:
                        if pattern.match(line.strip()):
                            new_lines.append(f"{var}={value}")
                            found = True
                        else:
                            new_lines.append(line)
                    if not found:
                        new_lines.append(f"{var}={value}")
                    return new_lines

                modified = update_line(modified, "POSTGRES_HOST", postgres_host)
                modified = update_line(modified, "POSTGRES_DB", postgres_db)
                modified = update_line(modified, "POSTGRES_PORT", postgres_port)

    elif mode == "prod":
        defaults = {
            "POSTGRES_USER": get_default_from_sample("POSTGRES_USER", content),
            "POSTGRES_PASSWORD": get_default_from_sample("POSTGRES_PASSWORD", content),
            "TRAEFIK_PASSWORD": get_default_from_sample("TRAEFIK_PASSWORD", content),
            "POSTGRES_PORT_ON_HOST": get_default_from_sample("POSTGRES_PORT_ON_HOST", content),
            "POSTGRES_HOST": get_default_from_sample("POSTGRES_HOST", content) or "postgres",
            "POSTGRES_DB": get_default_from_sample("POSTGRES_DB", content) or "geonature2db",
            "POSTGRES_PORT": get_default_from_sample("POSTGRES_PORT", content) or "5432",
        }

        postgres_user = click.prompt("Postgres username", default=defaults["POSTGRES_USER"])

        if click.confirm("Generate a random postgres password?", default=False):
            postgres_password = generate_password()
            click.echo(f"🔑 Generated POSTGRES_PASSWORD: {postgres_password}")
        else:
            postgres_password = click.prompt("Postgres password", default=defaults["POSTGRES_PASSWORD"], hide_input=True)

        if click.confirm("Generate htpasswd hash for traefik (admin:<password>)?", default=False):
            admin_pwd = click.prompt("Password for user 'admin'", hide_input=True)
            traefik_password = apr_md5_crypt.hash(admin_pwd)
            click.echo(f"🔐 TRAEFIK_PASSWORD (htpasswd format): {traefik_password}")
        else:
            traefik_password = click.prompt("Traefik password (htpasswd hash)", default=defaults["TRAEFIK_PASSWORD"], hide_input=False)

        postgres_port_on_host = click.prompt("Postgres port on host", default=defaults["POSTGRES_PORT_ON_HOST"])

        # Ask for external DB usage
        use_external_db = click.confirm("Use an external PostgreSQL database (outside docker-compose)?", default=False)
        if use_external_db:
            postgres_host = click.prompt("Postgres host", default=defaults["POSTGRES_HOST"])
            postgres_db = click.prompt("Postgres database name", default=defaults["POSTGRES_DB"])
            postgres_port = click.prompt("Postgres port", default=defaults["POSTGRES_PORT"])
        else:
            # Defaults from sample or from your original
            postgres_host = defaults["POSTGRES_HOST"]
            postgres_db = defaults["POSTGRES_DB"]
            postgres_port = defaults["POSTGRES_PORT"]

        # Function to update or append line:
        def update_line(lines, var, value):
            pattern = re.compile(rf"^{var}=.*")
            found = False
            new_lines = []
            for line in lines:
                if pattern.match(line.strip()):
                    new_lines.append(f"{var}={value}")
                    found = True
                else:
                    new_lines.append(line)
            if not found:
                new_lines.append(f"{var}={value}")
            return new_lines

        modified = update_line(modified, "POSTGRES_USER", f"\"{postgres_user}\"")
        modified = update_line(modified, "POSTGRES_PASSWORD", f"\"{postgres_password}\"")
        modified = update_line(modified, "TRAEFIK_PASSWORD", traefik_password)
        modified = update_line(modified, "POSTGRES_PORT_ON_HOST", postgres_port_on_host)

        modified = update_line(modified, "POSTGRES_HOST", postgres_host)
        modified = update_line(modified, "POSTGRES_DB", postgres_db)
        modified = update_line(modified, "POSTGRES_PORT", postgres_port)

    ENV_OUTPUT.write_text('\n'.join(modified) + '\n')
    click.echo(f"✅ .env file generated for mode: {mode}")


if __name__ == "__main__":
    generate_env()