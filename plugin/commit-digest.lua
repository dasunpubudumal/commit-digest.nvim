if vim.g.loaded_commit_digest then
  return
end
vim.g.loaded_commit_digest = true

vim.api.nvim_create_user_command("CommitDigest", function()
  require("commit-digest").generate()
end, { desc = "Generate a conventional commit message from staged changes" })
