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

## Packs

Jig ships with only the core framework. Commands are added via packs.

Browse what's available in the registry:

```bash
jig pack available
```

Install by registry name, or by git URL for packs not in the registry:

```bash
jig pack install jig-note                              # by name
jig pack install https://github.com/you/your-pack      # by URL
```

List installed packs, then update or remove:

```bash
jig pack list
jig pack update
jig pack remove jig-note
```

### Publishing a pack

To get your pack listed in the registry, open a PR against
[`src/pack/packs.json`](src/pack/packs.json) adding an entry with `name`, `url`,
`description`, and the list of `modules` (top-level folders under `src/`) your
pack provides.

## Discovering commands

Commands are discovered at runtime — there is no static command reference, since the available commands depend on which packs you have installed.

```bash
jig command list                # list all commands from core + installed packs
jig command show <command>      # show parameters and help for a command
jig command docs                # render full markdown reference (ad-hoc)
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
