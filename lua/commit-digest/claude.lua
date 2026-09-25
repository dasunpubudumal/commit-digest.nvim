local M = {}

local config = require("commit-digest.config")

-- Sends content to the Claude Messages API and calls callback(text, err).
function M.chat(content, callback)
  local api_key = config.options.api_key or vim.fn.getenv("ANTHROPIC_API_KEY")
  if not api_key or api_key == vim.NIL or api_key == "" then
    callback(nil, "ANTHROPIC_API_KEY is not set")
    return
  end

  local body = vim.json.encode({
    model = config.options.model,
    max_tokens = config.options.max_tokens,
    messages = {
      { role = "user", content = content },
    },
  })

  local args = {
    "curl", "--silent", "--show-error",
    "-X", "POST", "https://api.anthropic.com/v1/messages",
    "-H", "Content-Type: application/json",
    "-H", "anthropic-version: 2023-06-01",
    "-H", "x-api-key: " .. api_key,
    "-d", body,
  }

  vim.system(args, { text = true }, function(result)
    if result.code ~= 0 then
      callback(nil, "curl failed: " .. (result.stderr ~= "" and result.stderr or "exit " .. result.code))
      return
    end

    local ok, decoded = pcall(vim.json.decode, result.stdout)
    if not ok then
      callback(nil, "Failed to parse API response")
      return
    end

    if decoded.error then
      callback(nil, decoded.error.message or "Unknown API error")
      return
    end

    local text = decoded.content
      and decoded.content[1]
      and decoded.content[1].text

    if not text then
      callback(nil, "No text content in API response")
      return
    end

    callback(text, nil)
  end)
end

return M
