# jig

A bash CLI framework for building clean, consistent command-line tools — with typed parameters, tab completion, output formatting, filtering, and caching built in.

## Requirements

- bash
- python3 + venv

## Setup

```bash
git clone https://github.com/n7on/jig ~/source/jig
jig setup
```

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/source/jig/bin:$PATH"
source <(jig completion bash)   # or zsh
```

## Plugins

Jig ships with only the core framework. Commands are added via packs:

```bash
jig pack install https://github.com/n7on/jig-microsoft
jig pack install https://github.com/n7on/jig-note
jig pack install https://github.com/n7on/jig-export
jig pack install https://github.com/n7on/jig-general
```

List installed packs:

```bash
jig pack list
```

Update or remove:

```bash
jig pack update
jig pack remove jig-note
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
jig pack list --filter pack=built-in
jig pack list --filter namespace~az
jig pack list --sort namespace
jig pack list --select namespace
jig pack list --limit 5
```

## Caching

```bash
jig <command> --cache          # cache for 300s (default)
jig <command> --cache 3600     # cache for 1 hour
jig cache clear                # clear all cached results
```

## Syncing ~/.jig across machines

`~/.jig` holds your config, notes, and pack manifest. You can back it up and sync it across machines using a private git repo.

**One-time setup:**

```bash
git -C ~/.jig init
git -C ~/.jig remote add origin <your jig home repo>
git -C ~/.jig add .
git -C ~/.jig commit -m "init"
git -C ~/.jig push -u origin main
```

**Ongoing sync:**

```bash
jig sync
```

**New machine:**

```bash
git clone <your jig home repo>
jig setup   # recreates venv and reinstalls all packs
```

## Writing packs

See [CONTRIBUTING.md](CONTRIBUTING.md).
