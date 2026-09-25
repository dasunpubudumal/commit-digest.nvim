# commit-digest.nvim

A Neovim plugin that generates conventional commit messages from staged git diffs using the Claude API.

## How it works

Run `:CommitDigest` from any buffer inside a git repository. The plugin:

1. Runs `git diff --staged` for the current repo.
2. Sends the diff to the Claude API with a prompt that enforces [Conventional Commits](https://www.conventionalcommits.org/) format.
3. Displays the generated message in a floating window.

## Requirements

- Neovim ≥ 0.10 (uses `vim.system()`)
- `curl` on `$PATH`
- An [Anthropic API key](https://console.anthropic.com)

## Installation

### lazy.nvim

```lua
{
  "dasunpubudumal/commit-digest.nvim",
  opts = {
    -- api_key = "sk-ant-...",  -- or set ANTHROPIC_API_KEY in your environment
    model = "claude-sonnet-4-6",
    max_tokens = 1024,
  },
}
```

### Manual (no plugin manager)

Clone into your Neovim runtime path:

```sh
git clone https://github.com/dasunpubudumal/commit-digest.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/commit-digest.nvim
```

Then call setup in your config:

```lua
require("commit-digest").setup({})
```

## Configuration

```lua
require("commit-digest").setup({
  api_key    = nil,              -- reads ANTHROPIC_API_KEY from env if nil
  model      = "claude-sonnet-4-6",
  max_tokens = 1024,
})
```

| Option | Default | Description |
|---|---|---|
| `api_key` | `nil` | Anthropic API key. Falls back to `$ANTHROPIC_API_KEY`. |
| `model` | `"claude-sonnet-4-6"` | Claude model to use. |
| `max_tokens` | `1024` | Maximum tokens in the response. |

## Usage

Stage your changes, then run:

```
:CommitDigest
```

Inside the floating window:

| Key | Action |
|---|---|
| `y` | Yank the full message to the system clipboard (`+` and `"` registers) |
| `q` / `<Esc>` | Close the window |

You can also bind it to a key:

```lua
vim.keymap.set("n", "<leader>gc", "<cmd>CommitDigest<cr>", { desc = "Generate commit message" })
```

## Example

```
feat(claude): add Claude API client with async vim.system calls

- Replaces blocking io.popen with vim.system for non-blocking HTTP
- Parses JSON response via vim.json.decode
- Surfaces API errors through vim.notify
```
# commit-digest.nvim
