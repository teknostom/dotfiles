local autocmd = vim.api.nvim_create_autocmd

-- Jenkinsfile syntax highlighting
autocmd("BufEnter", {
  pattern = "Jenkinsfile*",
  callback = function()
    vim.cmd("set filetype=groovy")
  end,
  desc = "Set Jenkinsfile filetype to groovy"
})

-- Auto-format on save for web files
autocmd("BufWritePre", {
  pattern = "*.js,*.tsx,*.ts,*.json,*.css",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
  desc = "Auto-format web files on save"
})

-- LSP hover and diagnostics on cursor hold
autocmd({ "CursorHold" }, {
  pattern = "*",
  callback = function()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).zindex then
        return
      end
    end
    vim.diagnostic.open_float({
      scope = "cursor",
      focusable = false,
      close_events = {
        "CursorMoved",
        "CursorMovedI",
        "BufHidden",
        "InsertCharPre",
        "WinLeave",
      },
    })
    vim.lsp.buf.hover()
  end,
  desc = "Show diagnostics and hover on cursor hold"
})
