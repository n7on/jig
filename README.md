# rig

A bash CLI framework for building clean, consistent command-line tools — with typed parameters, tab completion, output formatting, filtering, and caching built in.

## Requirements

- bash
- python3 + venv

## Setup

```bash
git clone https://github.com/n7on/rig ~/Source/rig
rig setup
```

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/Source/rig/bin:$PATH"
source <(rig completion bash)   # or zsh
```

## Plugins

Rig ships with only the core framework. Commands are added via plugins:

```bash
rig plugin install https://github.com/n7on/rig-microsoft
rig plugin install https://github.com/n7on/rig-note
rig plugin install https://github.com/n7on/rig-export
rig plugin install https://github.com/n7on/rig-general
```

List installed plugins:

```bash
rig plugin list
```

Update or remove:

```bash
rig plugin update
rig plugin remove rig-note
```

## Output formats

All commands support `--output_format`:

| Format | Description |
| --- | --- |
| `table` | Aligned table (default) |
| `json` | JSON array |
| `tsv` | Tab-separated values |
| `md` | Markdown table |
| `raw` | Unprocessed output |

## Filtering and sorting

```bash
rig plugin list --filter plugin=built-in
rig plugin list --filter namespace~az
rig plugin list --sort namespace
rig plugin list --select namespace
rig plugin list --limit 5
```

## Caching

```bash
rig <command> --cache          # cache for 300s (default)
rig <command> --cache 3600     # cache for 1 hour
rig cache clear                # clear all cached results
```

## Writing plugins

See [CONTRIBUTING.md](CONTRIBUTING.md).
