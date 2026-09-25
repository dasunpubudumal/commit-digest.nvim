local M = {}

-- Opens a centered floating window displaying lines.
-- Keymaps inside the window:
--   q / <Esc>  close
--   y          yank full message to the system clipboard
function M.show(lines)
  -- Strip a trailing blank line that models sometimes add.
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "gitcommit"

  local ui_width = vim.o.columns
  local ui_height = vim.o.lines

  local width = math.min(80, ui_width - 4)
  local height = math.min(#lines, ui_height - 6)
  local row = math.floor((ui_height - height) / 2) - 1
  local col = math.floor((ui_width - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Commit Message ",
    title_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].cursorline = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local opts = { buffer = buf, nowait = true, noremap = true, silent = true }

  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  vim.keymap.set("n", "y", function()
    local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("[commit-digest] Commit message copied to clipboard", vim.log.levels.INFO)
  end, opts)
end

return M
