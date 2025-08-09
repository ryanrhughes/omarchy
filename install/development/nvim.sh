#!/bin/bash

if ! command -v nvim &>/dev/null; then
  yay -S --noconfirm --needed nvim luarocks tree-sitter-cli

  # Install LazyVim
  rm -rf ~/.config/nvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  cp -R ~/.local/share/omarchy/config/nvim/* ~/.config/nvim/
  rm -rf ~/.config/nvim/.git
  echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
fi

# Symlink all theme neovim.lua files to nvim plugins directory
if [ -d ~/.config/omarchy/themes ]; then
  for theme_dir in ~/.config/omarchy/themes/*/; do
    if [ -f "${theme_dir}neovim.lua" ]; then
      theme_name=$(basename "$theme_dir")
      ln -sf "${theme_dir}neovim.lua" ~/.config/nvim/lua/plugins/theme-${theme_name}.lua
    fi
  done
fi
