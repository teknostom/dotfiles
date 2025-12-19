local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Reduce key timeout for faster escape sequences
vim.opt.ttimeoutlen = 10

-- Telescope
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)

-- Clear search highlight
map('n', '<leader>7', '<cmd>noh<cr>', opts)

-- Window navigation
vim.keymap.set('n', '<leader>j', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ö', '<C-w>l', { noremap = true, silent = true })

-- Create new splits
vim.keymap.set('n', '<leader>n', ':vnew<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>m', ':new<CR>', { noremap = true, silent = true })

-- Terminal mode escape (double Esc to avoid conflicts)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
local function strip_ansi(str)
  return str:gsub('\27%[[%d;]*m', '')
end

local function run_cli(cmd, title)
  vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,

    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify(strip_ansi(line), vim.log.levels.INFO, { title = title })
        end
      end
    end,

    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify(strip_ansi(line), vim.log.levels.ERROR, { title = title })
        end
      end
    end,

    on_exit = function(_, code)
      if code == 0 then
        vim.notify(title .. " complete!", vim.log.levels.INFO, { title = title })
      else
        vim.notify(title .. " failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = title })
      end
    end,
  })
end

vim.keymap.set("n", "<leader>ad", function()
  run_cli({ "dynapp-cli", "download" }, "dynapp-cli Download")
end)

vim.keymap.set("n", "<leader>au", function()
  run_cli({ "dynapp-cli", "upload" }, "dynapp-cli Upload")
end)
