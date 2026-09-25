local M = {}

-- Runs `git diff --staged` in the repo containing the current buffer and
-- calls callback(diff_text, err_string). Both are mutually exclusive.
function M.get_staged_diff(callback)
  local cwd = vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h")
  if cwd == "" then
    cwd = vim.fn.getcwd()
  end

  vim.system(
    { "git", "diff", "--staged" },
    { text = true, cwd = cwd },
    function(result)
      if result.code ~= 0 then
        callback(nil, result.stderr ~= "" and result.stderr or "git exited with code " .. result.code)
        return
      end
      callback(result.stdout, nil)
    end
  )
end

return M
