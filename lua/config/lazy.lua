local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require("go.format").goimport()
  end,
  group = format_sync_grp,
})

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "plugins" },
    {
      "rose-pine/neovim",
      name = "rose-pine",
      lazy = false,
      priority = 1000,
      config = function()
        require("rose-pine").setup()
        vim.cmd("colorscheme rose-pine")
      end,
    },
    { "ray-x/go.nvim" },
    { "ray-x/guihua.lua" },
    { "andweeb/presence.nvim" },
    {
      "s1n7ax/nvim-terminal",
      config = function()
        vim.o.hidden = true
        require("nvim-terminal").setup({
          window = {
            position = "botright",
            split = "sp",
            width = 25,
            height = 15,
          },

          -- keymap to disable all the default keymaps
          disable_default_keymaps = false,

          -- keymap to toggle open and close terminal window
          toggle_keymap = "<leader>;",

          -- increase the window height by when you hit the keymap
          window_height_change_amount = 2,

          -- increase the window width by when you hit the keymap
          window_width_change_amount = 2,

          -- keymap to increase the window width
          increase_width_keymap = "<leader><leader>+",

          -- keymap to decrease the window width
          decrease_width_keymap = "<leader><leader>-",

          -- keymap to increase the window height
          increase_height_keymap = "<leader>+",

          -- keymap to decrease the window height
          decrease_height_keymap = "<leader>-",

          terminals = {
            -- keymaps to open nth terminal
            { keymap = "<leader>1" },
            { keymap = "<leader>2" },
            { keymap = "<leader>3" },
            { keymap = "<leader>4" },
            { keymap = "<leader>5" },
          },
        })
      end,
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = {
    colorscheme = {
      "rose-pine",
    },
  },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
