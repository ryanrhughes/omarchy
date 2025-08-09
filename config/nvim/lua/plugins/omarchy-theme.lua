
local function apply_colorscheme(colorscheme, background)
  -- Clear all highlight groups before applying new theme
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.o.background = (background == "light" or background == "dark") and background or "dark"
  local success = pcall(vim.cmd.colorscheme, colorscheme)
  if success then
    -- Force redraw to ensure all UI components update
    vim.cmd("doautocmd ColorScheme")
    
    -- Reapply transparency settings after colorscheme change
    local transparency_file = vim.fn.expand("~/.config/nvim/plugin/after/transparency.lua")
    if vim.fn.filereadable(transparency_file) == 1 then
      vim.cmd("source " .. transparency_file)
    end
    
    -- Force neo-tree and other UI elements to refresh
    vim.schedule(function()
      vim.cmd("redraw!")
    end)
  end
  return success
end

local function apply_colorscheme_deferred(colorscheme, background, delay)
  vim.defer_fn(function()
    apply_colorscheme(colorscheme, background)
  end, delay or 0)
end

local function apply_theme()
  -- Try to load the colorscheme settings
  local theme_spec = {}
  package.loaded["plugins.current-theme-colorscheme"] = nil
  local ok, result = pcall(require, "plugins.current-theme-colorscheme")
  if ok then
    theme_spec = result
  else
    -- Fallback: check if old theme.lua exists
    package.loaded["plugins.theme"] = nil
    ok, result = pcall(require, "plugins.theme")
    if ok then
      theme_spec = result
    end
  end
  
  -- Try to load the plugin definition
  local plugin_spec = {}
  package.loaded["plugins.current-theme-plugin"] = nil
  ok, result = pcall(require, "plugins.current-theme-plugin")
  if ok then
    plugin_spec = result
  end

  -- Extract theme info from colorscheme spec
  local colorscheme, background = nil, "dark"
  for _, spec in ipairs(theme_spec) do
    if spec[1] == "LazyVim/LazyVim" and spec.opts then
      colorscheme = spec.opts.colorscheme or colorscheme
      background = spec.opts.background or background
    end
  end
  
  -- Get the theme plugin from plugin spec
  local theme_plugin = nil
  for _, spec in ipairs(plugin_spec) do
    if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
      theme_plugin = spec
      break
    end
  end

  if not colorscheme then
    return
  end

  -- Try to apply the colorscheme (in case it's already loaded)
  if apply_colorscheme(colorscheme, background) then
    return
  end

  -- Colorscheme didn't apply, make sure we have a plugin then move on to check if we need to install or load the plugin
  if not theme_plugin then
    return
  end

  local plugin_name = theme_plugin.name or theme_plugin[1]:match("([^/]+)$")
  local plugin_dir = require("lazy.core.config").options.root .. "/" .. plugin_name

  if vim.fn.isdirectory(plugin_dir) == 0 then
    -- Plugin doesn't exist, check if another instance is installing
    local lock_file = vim.fn.stdpath("data") .. "/omarchy-theme-install.lock"
    local lock_exists = vim.fn.filereadable(lock_file) == 1
    
    if lock_exists then
      -- Another instance is installing, wait for it
      local lock_age = os.time() - (vim.fn.getftime(lock_file) or 0)
      if lock_age < 10 then
        -- Lock is fresh, wait for lock to be removed
        local wait_time = 0
        local check_interval = 200
        local max_wait = 10000
        
        local function wait_for_install()
          wait_time = wait_time + check_interval
          if vim.fn.filereadable(lock_file) == 0 then
            -- Lock removed, wait for Lazy to fully update
            vim.defer_fn(function()
              -- Force Lazy to reload its plugin state
              require("lazy.core.plugin").load()
              
              vim.defer_fn(function()
                -- Now check if installation succeeded
                if vim.fn.isdirectory(plugin_dir) == 1 then
                  -- Plugin directory exists, try to load from Lazy's config
                  local Config = require("lazy.core.config")
                  local plugin = Config.plugins[plugin_name]
                  if plugin and plugin._.installed then
                    -- Plugin is registered and installed in Lazy
                    require("lazy.core.loader").load(plugin, { cmd = "colorscheme" })
                    apply_colorscheme_deferred(colorscheme, background, 100)
                  else
                    -- Plugin dir exists but Lazy doesn't know about it yet
                    -- Just try to apply directly
                    apply_colorscheme_deferred(colorscheme, background, 500)
                  end
                end
                -- If plugin dir doesn't exist, installation failed - do nothing
              end, 500)
            end, 500)
            return  -- Exit the polling loop
          elseif wait_time >= max_wait then
            -- Timeout, abandon wait
            return
          else
            -- Still locked, keep waiting
            vim.defer_fn(wait_for_install, check_interval)
          end
        end
        
        vim.defer_fn(wait_for_install, check_interval)
        return
      end
      -- Lock is stale, remove it
      vim.fn.delete(lock_file)
    end
    
    -- Create lock file and install
    vim.fn.writefile({tostring(vim.fn.getpid())}, lock_file)
    vim.cmd("Lazy install")
    vim.defer_fn(function()
      vim.fn.delete(lock_file)
      apply_colorscheme(colorscheme, background)
    end, 1500)
  else
    -- Plugin exists but not loaded, retry after loading
    local Config = require("lazy.core.config")
    local plugin = Config.plugins[plugin_name]
    if plugin then
      require("lazy.core.loader").load(plugin, { cmd = "colorscheme" })
    end
    apply_colorscheme_deferred(colorscheme, background, 100)
  end
end

return {
  {
    "omarchy-theme",
    name = "omarchy-theme",
    dir = vim.fn.expand("~/.config/nvim/lua/plugins"),
    lazy = false,
    priority = 9999,
    config = function()
      -- Apply theme on startup
      apply_theme()

      -- Listen for SIGUSR1 to apply theme changes
      local uv = vim.loop or vim.uv
      local signal = uv.new_signal and uv.new_signal()
      if signal then
        uv.signal_start(signal, "sigusr1", function()
          vim.schedule(function()
            -- Reload Lazy's plugin specs to pick up the new theme
            require("lazy.core.plugin").load()
            vim.api.nvim_exec_autocmds("User", { pattern = "LazyReload", modeline = false })
            vim.defer_fn(apply_theme, 100)
          end)
        end)
      end
    end,
  },
}
