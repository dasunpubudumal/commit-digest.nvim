local M = {}

M.defaults = {
  api_key = nil,
  model = "claude-sonnet-4-6",
  max_tokens = 1024,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
