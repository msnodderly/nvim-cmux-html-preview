# cmux-preview

Live-preview static HTML in a [cmux](https://cmux.io) browser pane while you
edit in vim.

Save a file → the pane reloads. Switch to a different HTML buffer → the pane
follows you. No build step, no file watchers, no websockets, no browser
extension: a static file server, cmux's browser pane, and two vim autocmds.

## Requirements

- macOS with cmux (the tool talks to the pane over cmux's CLI; it refuses to
  run when `CMUX_SOCKET_PATH` is unset)
- `python3` (for `python3 -m http.server`)
- vim or neovim for the editor hooks; the `preview` command also works alone

## Install

Vendor the two files into your project (they have no dependencies on each
other's location — `preview.vim` finds `preview` next to itself):

```sh
curl -fsSLO https://raw.githubusercontent.com/msnodderly/cmux-preview/main/preview
curl -fsSLO https://raw.githubusercontent.com/msnodderly/cmux-preview/main/preview.vim
chmod +x preview
```

Or clone the repo and put `preview` on your `$PATH`.

## Usage

```sh
preview start                      # servers + browser pane
vim -S preview.vim index.html      # edit; pane follows saves and buffer switches
preview stop                       # close pane, stop servers
```

`start` remembers the pane (in `.git/preview-state`) and reuses it across
restarts instead of opening a new one.

## Configuration

Optional `.preview.conf` at your repo root (the nearest ancestor directory
with `.preview.conf` or `.git`):

```
serve public_html 8451
serve public_snodderly 8452
open /mds/
```

- `serve DIR PORT` — serve `DIR` at `http://localhost:PORT/`. Repeatable;
  `sync` maps each edited file to the right server by its directory.
- `open PATH` — the page the pane opens at on `start` (on the first `serve`
  entry's port). Defaults to `/`.

With no config at all, the repo root is served on port 8450.

## Neovim: load automatically per-project

With `vim.o.exrc = true` in your `init.lua`, drop this in a `.nvim.lua` at
your repo root (nvim asks you to trust it once):

```lua
local here = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
vim.cmd.source(here .. "/tools/preview.vim")
```

## How it works

- `preview start` launches one `python3 -m http.server` per `serve` line and
  opens a cmux browser pane at the configured start page, saving the pane's
  surface ref so later runs reuse it.
- `preview.vim` fires `preview sync <file>` on `BufWritePost` and `BufEnter`
  for HTML buffers, in the background.
- `preview sync` maps the file path to its canonical URL (right port by
  directory, `index.html` stripped), then reloads the pane if it's already on
  that page or navigates it there. If preview isn't running it exits silently,
  so vim never sees an error.

## License

MIT
