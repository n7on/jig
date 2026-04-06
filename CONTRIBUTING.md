# Contributing

## Project structure

```
init.bash               — source this in .bashrc
setup.bash              — one-time setup (creates venv, installs Python deps)
bin/grim                — binary wrapper for non-interactive use
src/
├── _grim/              — framework internals (command, output, cache, message)
└── <namespace>/        — command modules (azure/, nmap/, note/, ...)
    ├── <module>.bash   — command definitions
    └── python/         — Python scripts called from bash commands
~/.grim/
├── <namespace>/        — per-module config files (JSON)
└── .cache/             — cached command output
```

## Using grim from non-interactive contexts

`bin/grim` is a wrapper that sources `init.bash` and runs a command by name. It's useful when calling grim from outside an interactive shell — scripts, Makefiles, CI pipelines, or other tools.

```bash
# From a shell script (no need to source init.bash)
/path/to/grim/bin/grim nmap_scan_quick localhost
/path/to/grim/bin/grim azure_context_list --output json

# From a Makefile
scan:
	/path/to/grim/bin/grim nmap_scan_quick $(HOST)

# From another tool (e.g. passing to --allowedTools in Claude Code)
--allowedTools "Bash(/path/to/grim/bin/grim *)"
```

## Creating a module

Create a directory under `src/` and add a `.bash` file. It will be loaded automatically by `init.bash`.

```
src/
└── weather/
    └── weather.bash
```

Functions are named `<namespace>_<action>`, e.g. `weather_forecast`, `weather_current`.

## Anatomy of a command

```bash
weather_forecast() {
    _grim_command_requires curl || return 1

    _grim_command_param location --required --positional --help "City name or coordinates"
    _grim_command_param days     --default 3 --help "Number of days"
    _grim_command_param_parse "$@" || return 1

    _grim_command_exec curl -s "https://wttr.in/$location?format=j1" \
        | json_tsv --path 'weather' --fields 'date=date,max=maxtempC,min=mintempC' \
        | _grim_command_output_render "date,max,min"
}

_grim_command_complete_params "weather_forecast" "Show weather forecast" "location" "days"
```

## Parameter declaration

Declare parameters inside the function body, before `_grim_command_param_parse`:

```bash
_grim_command_param <name> [options...]
```

| Option | Description |
| --- | --- |
| `--required` | Fail with an error if not provided |
| `--positional` | Accept as the first non-flag argument |
| `--default <value>` | Default value if not provided |
| `--help "<text>"` | Description shown in `--help` output |
| `--regex "<pattern>"` | Validate value against a regex |
| `--path file\|dir` | Validate that the value is an existing file or directory |

After declaring parameters, always call:

```bash
_grim_command_param_parse "$@" || return 1
```

This parses flags, assigns positional args, validates, and exports each parameter as a local variable.

## Output rendering

Commands produce TSV and pipe it through `_grim_command_output_render`:

```bash
# Pass column headers as a comma-separated string
some_command | awk '{print $1 "\t" $2}' | _grim_command_output_render "name,value"
```

The renderer handles `--output`, `--filter`, `--sort`, `--select`, and `--limit` automatically.

If your data already includes a header row (e.g. from a Python script), omit the argument:

```bash
_grim_command_exec_python mymodule extract.py "$arg" | _grim_command_output_render
```

## Running external commands

```bash
# Run a command, pipe stdout to output renderer, show stderr only on failure or --debug
_grim_command_exec curl -s "$url"

# Run a Python script from src/<namespace>/python/
_grim_command_exec_python azure extract.py "$arg"
```

Both functions respect `--cache` automatically.

## Checking dependencies

```bash
_grim_command_requires curl jq nmap || return 1
_grim_command_requires_az_extension resource-graph || return 1
```

## Caching

The `--cache` flag is handled transparently by `_grim_command_exec` and `_grim_command_exec_python`. No extra work needed in commands.

Users can pass `--cache` (uses 300s default) or `--cache <seconds>` for a custom TTL.

## Tab completion

Register each command at file scope (outside the function body):

```bash
# Basic: list the parameter names the command accepts
_grim_command_complete_params "weather_forecast" "Show weather forecast" "location" "days"

# Static value list for a parameter
_grim_command_complete_values "weather_forecast" "days" 1 3 7 14

# Dynamic completer function (prints one value per line)
_weather_location_complete() {
    printf '%s\n' "London" "New York" "Tokyo"
}
_grim_command_complete_func "weather_forecast" "location" _weather_location_complete
```

`_grim_command_complete_params` takes the function name, a description, and the parameter names the command uses. The framework params (`--output`, `--filter`, `--sort`, etc.) are included automatically.

## Python scripts

For complex data transforms, put Python scripts in `src/<namespace>/python/` and call them with `_grim_command_exec_python`:

```bash
_grim_command_exec_python weather forecast.py "$location" "$days" \
    | _grim_command_output_render
```

Scripts should write TSV (with a header row) to stdout. Use `print(..., file=sys.stderr)` for warnings — grim will show them only on failure or with `--debug`.

## Module config files

For modules that need configuration, store it as JSON in `~/.grim/<namespace>/<module>.json`. Use `_grim_command_config_init` to create it from an example on first use:

```bash
# At file scope in your module
_grim_command_config_init weather config
```

This copies `src/weather/config.json.example` to `~/.grim/weather/config.json` on first use.

Read and write config values with:

```bash
local api_key
api_key=$(_grim_command_config_get weather config api_key)

_grim_command_config_set weather config api_key "$new_key"
```

## Messages

```bash
_grim_message_warn "Something looks off"    # yellow [WARN] to stderr
_grim_message_error "Something went wrong"  # red [ERROR] to stderr
```

## Full example

```bash
# src/weather/weather.bash

weather_forecast() {
    _grim_command_requires curl || return 1

    _grim_command_param location --required --positional --help "City name"
    _grim_command_param days     --default 3             --help "Number of days to show"
    _grim_command_param_parse "$@" || return 1

    _grim_command_exec curl -s "https://wttr.in/${location}?format=j1" \
        | json_tsv --path 'weather' --fields 'date=date,max=maxtempC,min=mintempC' \
        | _grim_command_output_render "date,max,min"
}

_weather_complete_location() {
    printf '%s\n' "London" "Paris" "Tokyo" "New York"
}

_grim_command_complete_params "weather_forecast" "Show weather forecast" "location" "days"
_grim_command_complete_func   "weather_forecast" "location" _weather_complete_location
```

```bash
weather_forecast London                         # table (default)
weather_forecast London --output json    # JSON array
weather_forecast London --days 7 --filter max~2 # filtered
weather_forecast London --cache 3600            # cached for 1 hour
weather_forecast --help                         # show parameter help
```
