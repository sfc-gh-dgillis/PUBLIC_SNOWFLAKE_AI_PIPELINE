#!/usr/bin/env python3
"""
Generates Snowflake notebooks and snowflake.yml files from templates by substituting Jinja variables.

Usage:
    # Generate all notebooks from template subdirectories
    python3 generate-notebook.py --all

    # Generate a single notebook (backward compatible)
    python3 generate-notebook.py --template <template.ipynb> --output <output.ipynb>

Directory structure (when using --all):
    notebook/
    ├── output/           # Generated notebooks go here
    │   └── <name>/
    │       ├── <name>.ipynb
    │       └── snowflake.yml
    └── template/         # Template subdirectories
        └── <name>/
            ├── *_template.ipynb
            └── *_snowflake_yml_template.yml

Environment variables used for substitution:
    - DEMO_WAREHOUSE_NAME
    - DEMO_DATABASE_NAME
    - DEMO_SCHEMA_NAME
    - INTERNAL_NAMED_STAGE
"""

import argparse
import json
import os
import sys
from pathlib import Path


def get_required_env(var_name: str) -> str:
    """Get a required environment variable or exit with error."""
    value = os.environ.get(var_name)
    if not value:
        print(f"Error: {var_name} environment variable not set")
        sys.exit(1)
    return value


def substitute_variables(text: str, variables: dict) -> str:
    """Substitute Jinja-style variables in text."""
    result = text
    for key, value in variables.items():
        result = result.replace(f"{{{{ {key} }}}}", value)
    return result


def generate_notebook(template_path: Path, output_path: Path, variables: dict) -> None:
    """Read template notebook, substitute variables, and write output."""
    with open(template_path, 'r') as f:
        notebook = json.load(f)

    for cell in notebook.get('cells', []):
        if 'source' in cell:
            if isinstance(cell['source'], list):
                cell['source'] = [substitute_variables(line, variables) for line in cell['source']]
            else:
                cell['source'] = substitute_variables(cell['source'], variables)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        json.dump(notebook, f, indent=1)

    print(f"  Generated notebook: {output_path}")


def generate_snowflake_yml(template_path: Path, output_path: Path, variables: dict) -> None:
    """Read snowflake.yml template, substitute variables, and write output."""
    with open(template_path, 'r') as f:
        content = f.read()

    yml_variables = variables.copy()
    if "internal_named_stage" in yml_variables:
        yml_variables["internal_named_stage"] = yml_variables["internal_named_stage"].lstrip("@")
    
    schema_name = yml_variables.get("demo_schema_name", "")
    if "." in schema_name:
        yml_variables["demo_schema_name"] = schema_name.split(".", 1)[1]

    content = substitute_variables(content, yml_variables)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        f.write(content)

    print(f"  Generated snowflake.yml: {output_path}")


def find_template_file(template_dir: Path, suffix: str) -> Path | None:
    """Find a file matching *<suffix> in the template directory."""
    matches = list(template_dir.glob(f"*{suffix}"))
    if len(matches) == 1:
        return matches[0]
    elif len(matches) > 1:
        print(f"Warning: Multiple files matching *{suffix} in {template_dir}, using first: {matches[0]}")
        return matches[0]
    return None


def process_template_directory(template_dir: Path, output_base: Path, variables: dict) -> bool:
    """Process a single template directory and generate outputs."""
    notebook_template = find_template_file(template_dir, "_template.ipynb")
    yml_template = find_template_file(template_dir, "_snowflake_yml_template.yml")

    if not notebook_template:
        print(f"  Skipping {template_dir.name}: No *_template.ipynb found")
        return False

    if not yml_template:
        print(f"  Error: {template_dir.name}: No *_snowflake_yml_template.yml found (required)")
        return False

    output_dir = output_base / template_dir.name
    notebook_name = notebook_template.name.replace("_template.ipynb", ".ipynb")
    notebook_output = output_dir / notebook_name

    yml_variables = variables.copy()
    yml_variables["notebook_file"] = notebook_name
    yml_variables["notebook_file_path"] = str(notebook_output)

    generate_notebook(notebook_template, notebook_output, variables)
    generate_snowflake_yml(yml_template, output_dir / "snowflake.yml", yml_variables)

    return True


def process_all_templates(base_dir: Path, variables: dict) -> int:
    """Discover and process all template subdirectories."""
    template_base = base_dir / "template"
    output_base = base_dir / "output"

    if not template_base.exists():
        print(f"Error: Template directory not found: {template_base}")
        return 1

    template_dirs = [d for d in template_base.iterdir() if d.is_dir()]

    if not template_dirs:
        print(f"Error: No template subdirectories found in {template_base}")
        return 1

    print(f"Found {len(template_dirs)} template(s) to process")
    print()

    success_count = 0
    for template_dir in sorted(template_dirs):
        print(f"Processing: {template_dir.name}")
        if process_template_directory(template_dir, output_base, variables):
            success_count += 1
        print()

    print(f"Successfully generated {success_count}/{len(template_dirs)} notebook(s)")
    return 0 if success_count == len(template_dirs) else 1


def process_single_template(template_path: Path, output_path: Path, variables: dict) -> int:
    """Process a single template file (backward compatible mode)."""
    if not template_path.exists():
        print(f"Error: Template not found: {template_path}")
        return 1

    print("Generating notebook project from templates...")
    print(f"  Notebook template: {template_path}")
    print(f"  Output: {output_path}")
    print()

    generate_notebook(template_path, output_path, variables)

    yml_template = find_template_file(template_path.parent, "_snowflake_yml_template.yml")
    if yml_template:
        yml_variables = variables.copy()
        yml_variables["notebook_file"] = output_path.name
        yml_variables["notebook_file_path"] = str(output_path)
        generate_snowflake_yml(yml_template, output_path.parent / "snowflake.yml", yml_variables)
    else:
        print(f"Error: snowflake.yml template not found in {template_path.parent}")
        return 1

    return 0


def main():
    parser = argparse.ArgumentParser(description="Generate Snowflake notebooks from templates")
    parser.add_argument("--all", "-a", action="store_true",
                        help="Process all template subdirectories in notebook/template/")
    parser.add_argument("--template", "-t", help="Path to template notebook (single mode)")
    parser.add_argument("--output", "-o", help="Output notebook path (single mode)")
    parser.add_argument("--base-dir", "-b", default="notebook",
                        help="Base directory containing template/ and output/ (default: notebook)")
    args = parser.parse_args()

    if not args.all and not (args.template and args.output):
        parser.error("Either --all or both --template and --output are required")

    variables = {
        "demo_warehouse_name": get_required_env("DEMO_WAREHOUSE_NAME"),
        "demo_database_name": get_required_env("DEMO_DATABASE_NAME"),
        "demo_schema_name": get_required_env("DEMO_SCHEMA_NAME"),
        "internal_named_stage": get_required_env("INTERNAL_NAMED_STAGE"),
    }
    # Add stage name without @ prefix for ALTER STAGE statements
    variables["internal_named_stage_name"] = variables["internal_named_stage"].lstrip("@")

    print(f"Environment:")
    print(f"  Warehouse: {variables['demo_warehouse_name']}")
    print(f"  Database: {variables['demo_database_name']}")
    print(f"  Schema: {variables['demo_schema_name']}")
    print(f"  Internal Stage: {variables['internal_named_stage']}")
    print()

    if args.all:
        return process_all_templates(Path(args.base_dir), variables)
    else:
        return process_single_template(Path(args.template), Path(args.output), variables)


if __name__ == "__main__":
    sys.exit(main())
