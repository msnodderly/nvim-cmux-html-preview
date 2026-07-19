# nvim-cmux-html-preview

Live-preview static HTML in a [cmux](https://cmux.io) browser pane while you
edit in Vim or Neovim.

It provides an HTML equivalent to cmux's built-in Markdown preview: save a
file and the browser pane reloads; switch to another HTML buffer and the pane
follows it. There is no build step, browser extension, or file watcher—just a
local static-file server, a cmux browser pane, and editor autocommands.

> This is intentionally a small reference implementation. Use it directly or
> adapt it to your project's needs.

<img width="1443" height="903" alt="HTML live preview open beside Vim in cmux" src="https://github.com/user-attachments/assets/c4ed734f-a02e-42f9-97c9-0040dc7e60ab" />

## Requirements

- macOS with [cmux](https://cmux.io). The command communicates through cmux's
  CLI and refuses to start when `CMUX_SOCKET_PATH` is unset.
- `python3`, used for the local static-file server.
- Vim or Neovim for the editor hooks. The `preview` command can also be used
  on its own.

## Install

Download the two files into your project. `preview.vim` automatically finds a
`preview` executable in the same directory:

```sh
curl -fsSLO https://raw.githubusercontent.com/msnodderly/nvim-cmux-html-preview/main/preview
curl -fsSLO https://raw.githubusercontent.com/msnodderly/nvim-cmux-html-preview/main/preview.vim
chmod +x preview
```

Alternatively, clone the repository and put `preview` on your `PATH`:

```sh
git clone https://github.com/msnodderly/nvim-cmux-html-preview.git
```

## Usage

```sh
preview start                      # start servers and open a browser pane
vim -S preview.vim index.html      # edit; the pane follows saves and buffers
preview stop                       # close the pane and stop owned servers
```

`preview start` records the pane in `.git/preview-state` and reuses it on the
next start instead of opening a duplicate.

## Configuration

Add an optional `.preview.conf` at the project root (the nearest ancestor with
`.preview.conf` or `.git`):

```text
serve public_html 8451
serve public_snodderly 8452
open /mds/
```

- `serve DIR PORT` serves `DIR` at `http://localhost:PORT/`. It can be repeated;
  `sync` maps each edited file to the matching server directory.
- `open PATH` selects the page opened by `start`, using the first `serve`
  entry's port. It defaults to `/`.

Without a config, the project root is served on port 8450. Servers bind only to
`127.0.0.1` and are stopped by recorded process ID, so `preview stop` does not
terminate unrelated Python servers.

## Load automatically in Neovim

Enable project-local configuration with `vim.o.exrc = true` in `init.lua`, then
add this `.nvim.lua` at the project root (Neovim asks you to trust it once):

```lua
local here = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
vim.cmd.source(here .. "/tools/preview.vim")
```

Adjust `tools/preview.vim` if you installed the files elsewhere.

## How it works

- `preview start` launches one `python3 -m http.server` process per `serve`
  line and opens cmux at the configured start page.
- `preview.vim` runs `preview sync <file>` in the background on `BufWritePost`
  and `BufEnter` for HTML buffers.
- `preview sync` maps the file to its local URL, reloads the pane when it is
  already on that page, and otherwise navigates to it. It exits silently if no
  preview is running, so the editor does not report an error.

## License

MIT
