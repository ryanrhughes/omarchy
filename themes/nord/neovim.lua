-- Theme configuration
local plugin_name = "EdenEast/nightfox.nvim"
local theme_name = "nordfox"
local background = "dark"

local function apply_theme()
  -- Set background
  vim.o.background = background
  
  -- Try to apply colorscheme
  local ok = pcall(vim.cmd.colorscheme, theme_name)
  
  if not ok then
    -- Theme not available, trigger Lazy to install it
    vim.cmd("Lazy install")
    
    -- Simple delayed retry after triggering install
    vim.defer_fn(function()
      vim.o.background = background
      pcall(vim.cmd.colorscheme, theme_name)
    end, 1000)
  end
end

-- Apply immediately on file reload
vim.schedule(apply_theme)

return {
  {
    plugin_name,
    priority = 1000,
    config = function()
      -- Try setup if available
      pcall(function()
        local nightfox = require("nightfox")
        if nightfox.setup then
          nightfox.setup({})
        end
      end)
      vim.o.background = background
      vim.cmd.colorscheme(theme_name)
    end,
  },
}