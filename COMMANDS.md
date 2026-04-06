# Grim Commands

Grim is a bash CLI framework. Run commands using `grim`:

```bash
grim nmap_scan_quick localhost
grim azure_graph_query my_query --output_format json
grim note_add "my note #tag"
```

## ado

### `ado_feed_list`

List Azure DevOps feeds

| Parameter | Required | Description |
| --- | --- | --- |
| `--organization` |  | Azure DevOps organization |

### `ado_feed_package_download`

Download latest package from Azure DevOps feed

| Parameter | Required | Description |
| --- | --- | --- |
| `--feed` | yes | Feed name |
| `--organization` |  | Azure DevOps organization |
| `--package` | yes | Package name. Positional |
| `--path` |  | Download path. Default: `.` |

### `ado_feed_package_list`

List packages in an Azure DevOps feed

| Parameter | Required | Description |
| --- | --- | --- |
| `--feed` | yes | Feed name |
| `--organization` |  | Azure DevOps organization |

## azure

### `azure_context_add`

Create a new Azure context and log in

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Context name. Positional |

### `azure_context_list`

List available Azure contexts

### `azure_context_remove`

Remove a named Azure context

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Context name. Positional |

### `azure_context_switch`

Switch to a named Azure context (use 'default' to restore ~/.azure)

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Context name (or 'default'). Positional |

### `azure_graph_query`

Query Azure Resource Graph using a saved KQL file

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Query name (from queries/graph/). Positional |
| `--subscriptions` |  | Comma-separated list of subscription IDs to scope the query |

### `azure_law_query`

Query Azure Log Analytics workspace using a saved KQL file

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Query name (from queries/law/). Positional |
| `--timespan` |  | Query timespan as ISO 8601 duration. Default: `PT1H` |
| `--workspace` | yes | Log Analytics workspace name or ID |

## entra

### `entra_app_list`

List Entra app registrations with their permissions

### `entra_license`

List Entra license information

### `entra_license_plan_list`

List service plans across all subscribed Entra SKUs

### `entra_permission_list`

List Microsoft Graph OAuth permission scopes

### `entra_user_list`

List Entra users with license and MFA info

| Parameter | Required | Description |
| --- | --- | --- |
| `--odata_filter` |  | OData filter expression. Positional |

## export

### `export_excel`

Convert TSV input to a formatted Excel (.xlsx) file

| Parameter | Required | Description |
| --- | --- | --- |
| `--input` |  | Input TSV file (default: stdin) |
| `--output` |  | Output .xlsx file path. Default: `export.xlsx` |
| `--sheet` |  | Sheet name (appends if file exists). Default: `Sheet1` |

## git

### `git_pull`

Pull from remote if directory is a git repo

| Parameter | Required | Description |
| --- | --- | --- |
| `--path` |  | Path to git repository. Default: `.`. Positional |

### `git_push`

Stage, commit, and push changes

| Parameter | Required | Description |
| --- | --- | --- |
| `--message` | yes | Commit message |
| `--path` |  | Path to git repository. Default: `.`. Positional |

### `git_status`

Show status of files in a git repo

| Parameter | Required | Description |
| --- | --- | --- |
| `--path` |  | Path to git repository. Default: `.`. Positional |

### `git_sync`

Pull then commit and push changes

| Parameter | Required | Description |
| --- | --- | --- |
| `--message` | yes | Commit message |
| `--path` |  | Path to git repository. Default: `.`. Positional |

## grim

### `grim_command_docs`

Generate markdown documentation for all grim commands

### `grim_command_list`

List all registered grim commands

### `grim_command_show`

Show parameters for a grim command

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Command name. Positional |

### `grim_deps`

List all external dependencies across grim modules

## json

### `json_append`

Append a JSON object to an array in a file

| Parameter | Required | Description |
| --- | --- | --- |
| `--file` | yes | JSON file (created if missing) |
| `--item` | yes | JSON object to append |

### `json_build`

Build a JSON object from key=value arguments

### `json_find`

Find first matching item in a JSON array

| Parameter | Required | Description |
| --- | --- | --- |
| `--equals` | yes | Value to match (case-insensitive) |
| `--path` | yes | Dotted path to the array. Positional |
| `--return` |  | Field to return (omit for whole object) |
| `--where` | yes | Field to match on |

### `json_get`

Get a single value from JSON by path

| Parameter | Required | Description |
| --- | --- | --- |
| `--path` | yes | Dotted path to the value. Positional |

### `json_kv`

Flatten a JSON object to key/value rows

| Parameter | Required | Description |
| --- | --- | --- |
| `--path` |  | Dotted path to the object. Default: `.`. Positional |

### `json_remove`

Remove matching items from a JSON array in a file

| Parameter | Required | Description |
| --- | --- | --- |
| `--file` | yes | JSON file to update |
| `--match` | yes | Field to match on |
| `--value` | yes | Value to match for removal |

### `json_set`

Set a key/value in a JSON file

| Parameter | Required | Description |
| --- | --- | --- |
| `--file` | yes | JSON file to update |
| `--key` | yes | Key to set |
| `--value` | yes | Value to set |

### `json_tsv`

Extract fields from a JSON array as TSV

| Parameter | Required | Description |
| --- | --- | --- |
| `--fields` | yes | Comma-separated fields (col=path or just path) |
| `--path` | yes | Dotted path to the array. Positional |

## ms365

### `ms365_app_setup`

Create or update the _grim app registration with required MS365 permissions

### `ms365_app_show`

Show the _grim app registration and its permissions

### `ms365_login`

Authenticate with the _grim app using device code flow

### `ms365_purview_rlabel_add`

Create a new Purview retention label

| Parameter | Required | Description |
| --- | --- | --- |
| `--action` |  | Action after retention (none, delete, permanentlyDelete, startDispositionReview) |
| `--description_admins` |  | Description for admins |
| `--description_users` |  | Description for users |
| `--duration` |  | Retention period in days |
| `--name` | yes | Label display name. Positional |
| `--trigger` |  | Retention trigger (dateLabeled, dateCreated, dateModified, dateOfEvent) |

### `ms365_purview_rlabel_list`

List Purview retention labels

### `ms365_purview_rlabel_show`

Show details of a Purview retention label

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Label display name (exact match). Positional |

### `ms365_purview_slabel_add`

Create a new Purview sensitive information label

| Parameter | Required | Description |
| --- | --- | --- |
| `--color` |  | Label color as hex (e.g. #FF0000) |
| `--description` |  | Label description |
| `--name` | yes | Label display name. Positional |
| `--parent` |  | Parent label name (makes this a sublabel) |
| `--tooltip` |  | Tooltip shown to users |

### `ms365_purview_slabel_list`

List Purview sensitive information labels

### `ms365_purview_slabel_show`

Show details of a Purview sensitive information label

| Parameter | Required | Description |
| --- | --- | --- |
| `--name` | yes | Label name (exact match). Positional |

## nmap

### `nmap_scan_discover`

Network discovery (ping sweep)

| Parameter | Required | Description |
| --- | --- | --- |
| `--subnet` | yes | Subnet to scan. Positional |

### `nmap_scan_full`

Full port scan (all 65535 ports)

| Parameter | Required | Description |
| --- | --- | --- |
| `--target` | yes | Target host or IP. Positional |

### `nmap_scan_os`

OS detection (requires root)

| Parameter | Required | Description |
| --- | --- | --- |
| `--target` | yes | Target host or IP. Positional |

### `nmap_scan_quick`

Quick scan of common ports

| Parameter | Required | Description |
| --- | --- | --- |
| `--target` | yes | Target host or IP. Positional |

### `nmap_scan_services`

Service and version detection

| Parameter | Required | Description |
| --- | --- | --- |
| `--ports` |  | Port range to scan |
| `--target` | yes | Target host or IP. Positional |

### `nmap_scan_stealth`

Stealth SYN scan

| Parameter | Required | Description |
| --- | --- | --- |
| `--ports` |  | Port range to scan |
| `--target` | yes | Target host or IP. Positional |

### `nmap_scan_udp`

UDP scan

| Parameter | Required | Description |
| --- | --- | --- |
| `--ports` |  | Port range to scan. Default: `53,67,68,69,123,161,162,500,514,1900` |
| `--target` | yes | Target host or IP. Positional |

### `nmap_script_run`

Run NSE script(s) against target

| Parameter | Required | Description |
| --- | --- | --- |
| `--ports` |  | Port range to scan |
| `--script` | yes | NSE script name |
| `--target` | yes | Target host or IP |

## note

### `note_add`

Add a new note for today

| Parameter | Required | Description |
| --- | --- | --- |
| `--message` | yes | The note text, supports #tags. Positional |

### `note_delete`

Delete a note by id

| Parameter | Required | Description |
| --- | --- | --- |
| `--id` | yes | The note id to delete. Positional |

### `note_list`

List notes for a given date

| Parameter | Required | Description |
| --- | --- | --- |
| `--date` |  | Date to list notes for. Positional |

## openssl

### `openssl_client_connect`

Connect to a TLS server and display certificate info

| Parameter | Required | Description |
| --- | --- | --- |
| `--host` | yes | Target hostname. Positional |
| `--message` |  | Message to send after connect |
| `--port` |  | Target port. Default: `443` |

### `openssl_file_decrypt`

Decrypt a file

| Parameter | Required | Description |
| --- | --- | --- |
| `--cipher` |  | Cipher algorithm. Default: `aes-256-cbc` |
| `--input` | yes | Input file to decrypt |
| `--output` |  | Output file (default: input without .enc) |
| `--password` | yes | Decryption password |

### `openssl_file_encrypt`

Encrypt a file using AES-256-CBC

| Parameter | Required | Description |
| --- | --- | --- |
| `--cipher` |  | Cipher algorithm. Default: `aes-256-cbc` |
| `--input` | yes | Input file to encrypt |
| `--output` |  | Output file (default: input.enc) |
| `--password` | yes | Encryption password |

## tmux

### `tmux_pane`

Display piped input in a tmux split pane

| Parameter | Required | Description |
| --- | --- | --- |
| `--horizontal` |  | Split horizontally instead of vertically |
| `--size` |  | Pane size (rows/columns or percentage). Default: `40%` |

### `tmux_popup`

Display piped input in a floating tmux popup

| Parameter | Required | Description |
| --- | --- | --- |
| `--height` |  | Popup height (rows or percentage). Default: `60%` |
| `--title` |  | Popup title. Default: `grim` |
| `--width` |  | Popup width (columns or percentage). Default: `80%` |

## Framework Parameters

All commands support these parameters:

| Parameter | Description |
| --- | --- |
| `--output_format` | Output format: `table`, `json`, `tsv`, `raw`, `md`. Default: `table` |
| `--cache` | Cache TTL in seconds. Use bare `--cache` for 300s default |
| `--filter` | Filter rows: `COL=value` (exact/wildcard) or `COL~value` (contains) |
| `--sort` | Sort by column. Prefix with `-` for descending |
| `--select` | Comma-separated list of columns to include |
| `--limit` | Limit output to first N rows |
| `--debug` | Show verbose error output |
