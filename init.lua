-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = "<Space>"
require("config.lazy")
require("go").setup()
require("presence").setup({
  auto_update = true, -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
  neovim_image_text = "i'm a maniac", -- Text displayed when hovered over the Neovim image
  main_image = "file", -- Main image display (either "neovim" or "file")
  client_id = "793271441293967371", -- Use your own Discord application client id (not recommended)
  log_level = nil, -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
  debounce_timeout = 10, -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
  enable_line_number = false, -- Displays the current line number instead of the current project
  blacklist = {}, -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
  buttons = true, -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
  file_assets = {}, -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
  show_time = true, -- Show the timer

  -- Rich Presence text options
  editing_text = "Editing %s", -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
  file_explorer_text = "Browsing %s", -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
  git_commit_text = "Committing changes", -- Format string rendered when committing changes in git (either string or function(filename: string): string)
  plugin_manager_text = "Managing plugins", -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
  reading_text = "Reading %s", -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
  workspace_text = "Working on %s", -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
  line_number_text = "Line %s/%s", -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
})

local colors = {
  red = "#ca1243",
  grey = "#a0a1a7",
  black = "#383a42",
  white = "#f3f3f3",
  light_green = "#83a598",
  orange = "#fe8019",
  green = "#8ec07c",
}

local theme = {
  normal = {
    a = { fg = colors.white, bg = "#191724" },
    b = { fg = colors.white, bg = "#191724" },
    c = { fg = colors.black, bg = "#191724" },
    z = { fg = colors.white, bg = "#191724" },
  },
  insert = { a = { fg = colors.white, bg = "#81c2cd" } },
  visual = { a = { fg = colors.white, bg = "#e29c99" } },
}

local empty = require("lualine.component"):extend()
function empty:draw(default_highlight)
  self.status = ""
  self.applied_separator = ""
  self:apply_highlights(default_highlight)
  self:apply_section_separators()
  return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < "x"
    for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
      table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = "#191724" } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= "table" then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = "" } or { left = "" }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ""
  end
  local last_search = vim.fn.getreg("/")
  if not last_search or last_search == "" then
    return ""
  end
  local searchcount = vim.fn.searchcount({ maxcount = 9999 })
  return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
end

local function modified()
  if vim.bo.modified then
    return "+"
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return "-"
  end
  return ""
end

require("lualine").setup({
  options = {
    theme = theme,
    component_separators = "",
    section_separators = { left = "", right = "" },
  },
  sections = process_sections({
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
      "diff",
      {
        "diagnostics",
        source = { "nvim" },
        sections = { "error" },
        diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
      },
      {
        "diagnostics",
        source = { "nvim" },
        sections = { "warn" },
        diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
      },
      { "filename", file_status = false, path = 1 },
      { modified, color = { bg = colors.red } },
      {
        "%w",
        cond = function()
          return vim.wo.previewwindow
        end,
      },
      {
        "%r",
        cond = function()
          return vim.bo.readonly
        end,
      },
      {
        "%q",
        cond = function()
          return vim.bo.buftype == "quickfix"
        end,
      },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { search_result, "filetype" },
    lualine_z = { "%l:%c", "%p%%/%L" },
  }),
  inactive_sections = {
    lualine_c = { "%f %y %m" },
    lualine_x = {},
  },
})

require("lspconfig").gopls.setup({})
require("lspconfig").clangd.setup({
  cmd = {
    "clangd",
    "--background-index",
    "--pch-storage=memory",
    "--clang-tidy",
    "--suggest-missing-includes",
    "--all-scopes-completion",
    "--pretty",
    "--header-insertion=never",
    "-j=4",
    "--inlay-hints",
    "--header-insertion-decorators",
  },
  filetypes = { "c", "cpp", "h", "hpp" },
  init_options = { fallbackFlags = { "-std=c++2a" } },
})

require("lspconfig").rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
})
