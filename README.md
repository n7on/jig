# Grim

A lightweight bash framework for clean CLI tools with parameters, validation, output formatting, and auto-completion.

## Setup

**Requirements:** [uv](https://docs.astral.sh/uv/getting-started/installation/)

```bash
# Clone and run setup (creates ~/.grim/, installs Python deps)
bash setup.bash

# Add to ~/.bashrc
source /path/to/grim/src/init.bash
```

`setup.bash` will create `~/.grim/config.env` from the example if it doesn't exist yet. Edit it to configure your environment.
## Hello World Example

```bash
# Custom completer: suggest system users for --name
_greet_user_completer() {
    compgen -u -- "$1"
}

greet() {
    _grim_command_param_init name greeting="Hello"
    _grim_command_param_parse "$@"
    _grim_command_param_validate name --required || return 1
    _grim_command_output_set "GREETING,NAME" '{printf "%s\t%s\n", $1, $2}'
    _grim_command_run printf "%s %s\n" "$greeting" "$name"
}

# Register parameters and completions
_grim_command_complete_params greet name greeting
_grim_command_complete_func greet name _greet_user_completer
_grim_command_complete_values greet greeting Hello Hi Hey

# --output_format (table, json, csv, raw) is included automatically
```

**Usage:**
```bash
source src/init.bash
greet --name World                      # table output (default)
greet --name Alice --greeting Hi        # table output with custom greeting
greet --name <TAB>                      # auto-completes system users
greet --greeting <TAB>                  # auto-completes: Hello, Hi, Hey
greet --output_format <TAB>             # auto-completes: table, json, csv, raw
greet --output_format json --name World # [{"GREETING":"Hello","NAME":"World"}]
greet --output_format csv --name World  # GREETING,NAME\nHello,World
greet --output_format raw --name World  # raw command output
```

## Core Functions

**Parameters & Validation:**
- `_grim_command_param_init param1 param2=default` — Declare parameters (adds `output_format=table` automatically)
- `_grim_command_param_parse "$@"` — Parse `--flag value` arguments into variables
- `_grim_command_param_validate param --required --regex "pattern" --path [file|dir]` — Validate a parameter
- `_grim_command_param_default param "value"` — Set default if parameter is empty
- `_grim_command_requires jq az` — Check that external commands exist

**Execution:**
- `_grim_command_run "${cmd[@]}"` — Run command, pipe stdout to output renderer, capture stderr as warnings
- `_grim_command_exec "${cmd[@]}"` — Run command, capture stderr as warnings (no output rendering)

**Output:**
- `_grim_command_output_set "HEADERS" 'extractor' [awk|jq]` — Configure output headers and extractor (default: awk)
- `_grim_command_output_render` — Format and render piped input based on `--output_format`

**Completion:**
- `_grim_command_complete_params func param1 param2 ...` — Register parameters for tab completion
- `_grim_command_complete_values func param value1 value2 ...` — Static completion values
- `_grim_command_complete_func func param completer_func` — Dynamic completion via function (output one value per line)
- `_grim_command_complete_filter "item1 item2" "$prefix"` — Filter completion items by prefix

**Messages:**
- `_grim_message_warn "message"` — Yellow `[WARN]` to stderr
- `_grim_message_error "message"` — Red `[ERROR]` to stderr

## Configuration

Edit `~/.grim/config.env` (created by `setup.bash`):
```bash
AZURE_DEVOPS_ORGANIZATION="my-org"
AZURE_DEVOPS_FEED_NAME="my-feed"
AZURE_SUBSCRIPTIONS="sub1 sub2"
```

See `config.env.example` for all available options.

## Project Structure

```
setup.bash              — one-time setup
config.env.example      — configuration template
pyproject.toml          — Python dependencies (managed by uv)
src/
├── init.bash           — source this in .bashrc
├── grim/               — framework utilities
│   ├── command.bash
│   ├── message.bash
│   └── output.bash
└── <namespace>/        — command modules
    ├── module.bash
    ├── kql/            — KQL query files
    └── python/         — Python scripts
~/.grim/
├── config.env          — your configuration
├── kql/                — user-defined KQL queries (override repo queries)
└── *.bash              — user-defined command extensions
```

Add new modules in `src/<namespace>/` — they load automatically. Functions are named `<namespace>_<module>_<action>`, e.g. `nmap_scan_full`, `azure_graph_query`.
