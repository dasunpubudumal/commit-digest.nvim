local M = {}

local config = require("commit-digest.config")
local git = require("commit-digest.git")
local claude = require("commit-digest.claude")
local prompt = require("commit-digest.prompt")
local ui = require("commit-digest.ui")

function M.setup(opts)
  config.setup(opts)
end

-- Reads the staged diff, sends it to Claude, and shows the result in a
-- floating window. All network I/O runs asynchronously so Neovim stays
-- responsive while waiting.
function M.generate()
  vim.notify("[commit-digest] Reading staged diff...", vim.log.levels.INFO)

  git.get_staged_diff(function(diff, git_err)
    if git_err then
      vim.schedule(function()
        vim.notify("[commit-digest] git error: " .. git_err, vim.log.levels.ERROR)
      end)
      return
    end

    if not diff or vim.trim(diff) == "" then
      vim.schedule(function()
        vim.notify("[commit-digest] No staged changes found. Run `git add` first.", vim.log.levels.WARN)
      end)
      return
    end

    vim.schedule(function()
      vim.notify("[commit-digest] Generating commit message...", vim.log.levels.INFO)
    end)

    local message = prompt.build(diff)

    claude.chat(message, function(response, api_err)
      vim.schedule(function()
        if api_err then
          vim.notify("[commit-digest] Claude error: " .. api_err, vim.log.levels.ERROR)
          return
        end
        local lines = vim.split(response, "\n", { plain = true })
        ui.show(lines)
      end)
    end)
  end)
end

return M
