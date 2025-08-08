local function apply_colorscheme(colorscheme, background)
	vim.o.background = (background == "light" or background == "dark") and background or "dark"
	local success = pcall(vim.cmd.colorscheme, colorscheme)
	if success then
		-- Reapply transparency settings after colorscheme change
		local transparency_file = vim.fn.expand("~/.config/nvim/plugin/after/transparency.lua")
		if vim.fn.filereadable(transparency_file) == 1 then
			vim.cmd("source " .. transparency_file)
		end
	end
	return success
end

local function apply_colorscheme_deferred(colorscheme, background, delay)
	vim.defer_fn(function()
		apply_colorscheme(colorscheme, background)
	end, delay or 0)
end

local function apply_theme()
	-- Always reload to get latest theme
	package.loaded["plugins.theme"] = nil
	local theme_spec = require("plugins.theme")

	-- Extract theme info
	local colorscheme, background, theme_plugin = nil, "dark", nil
	for _, spec in ipairs(theme_spec) do
		if spec[1] == "LazyVim/LazyVim" and spec.opts then
			colorscheme = spec.opts.colorscheme or colorscheme
			background = spec.opts.background or background
		elseif spec[1] and spec[1] ~= "LazyVim/LazyVim" then
			theme_plugin = spec
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
		-- Plugin doesn't exist, install it
		vim.cmd("Lazy install")
		apply_colorscheme_deferred(colorscheme, background, 1500)
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
