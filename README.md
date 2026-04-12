# rig

A bash CLI framework for building clean, consistent command-line tools — with typed parameters, validation, output formatting, caching, and tab completion built in.

## Setup

**Requirements:** bash, python3

```bash
git clone <repo> rig
cd rig
bash setup.bash
```

Add to `~/.bashrc`:
```bash
export PATH="/path/to/rig/bin:$PATH"
source <(rig completion bash)
```

## Usage

```bash
rig nmap scan quick localhost
rig azure context list --output json
rig note add "my note #tag"
```

## Output formats

All commands support `--output`:

| Format | Description |
| --- | --- |
| `table` | Aligned table (default) |
| `json` | JSON array |
| `tsv` | Tab-separated values |
| `md` | Markdown table |
| `raw` | Unprocessed output |

## Output pipeline

All commands support these flags to slice and filter results:

```bash
rig azure context list --filter name=prod       # exact match (wildcards supported)
rig azure context list --filter name~prod       # contains match
rig azure context list --sort -name             # sort descending
rig azure context list --select name,id         # pick columns
rig azure context list --limit 10               # first N rows
```

## Caching

```bash
rig azure graph query my_query --cache          # cache for 300s (default)
rig azure graph query my_query --cache 3600     # cache for 1 hour
rig cache clear                                 # clear all cached results
```

## Available commands

See [COMMANDS.md](COMMANDS.md) for the full command reference.

## Adding commands

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to create new modules and commands.
