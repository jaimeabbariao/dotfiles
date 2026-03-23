#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
green() { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red() { printf '\033[31m%s\033[0m\n' "$1"; }

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    yellow "  Backing up existing $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi
  ln -s "$src" "$dest"
  green "  Linked $dest -> $src"
}

# -------------------------------------------------------
# 1. Detect package manager & install helpers
# -------------------------------------------------------
detect_pkg_manager() {
  if command -v brew &>/dev/null; then
    echo "brew"
  elif command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

PKG_MANAGER="$(detect_pkg_manager)"

install_pkg() {
  local name="$1"
  case "$PKG_MANAGER" in
  brew) brew install "$name" ;;
  apt) sudo apt-get install -y "$name" ;;
  dnf) sudo dnf install -y "$name" ;;
  pacman) sudo pacman -S --noconfirm "$name" ;;
  *)
    red "  No supported package manager found. Install '$name' manually."
    return 1
    ;;
  esac
}

# -------------------------------------------------------
# 2. Install LazyVim dependencies
# -------------------------------------------------------
echo "=== Installing LazyVim Dependencies ==="
echo "Detected package manager: $PKG_MANAGER"
echo ""

# Package names differ per manager: tool -> package
declare -A PACKAGES
PACKAGES=(
  [git]=git
  [nvim]=neovim
  [rg]=ripgrep
  [curl]=curl
  [node]=node
  [npm]=npm
)

# Override package names per manager
case "$PKG_MANAGER" in
apt)
  PACKAGES[fd]=fd-find
  PACKAGES[node]=nodejs
  ;;
brew)
  PACKAGES[fd]=fd
  ;;
esac

for tool in "${!PACKAGES[@]}"; do
  pkg="${PACKAGES[$tool]}"
  if command -v "$tool" &>/dev/null; then
    green "  [ok] $tool"
  else
    echo "  Installing $tool ($pkg)..."
    install_pkg "$pkg" || red "  Failed to install $tool — install it manually."
  fi
done

# -------------------------------------------------------
# 2.5 Install lazygit manually
# -------------------------------------------------------

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# -------------------------------------------------------
# 3. Install tree-sitter-cli via cargo
# -------------------------------------------------------
echo ""
echo "=== Installing tree-sitter-cli ==="
if command -v tree-sitter &>/dev/null; then
  green "  [ok] tree-sitter-cli already installed"
else
  if ! command -v cargo &>/dev/null; then
    yellow "  Rust/Cargo not found. Installing via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi
  # libclang-dev is required to build tree-sitter-cli
  case "$PKG_MANAGER" in
  apt) sudo apt-get install -y libclang-dev ;;
  dnf) sudo dnf install -y clang-devel ;;
  pacman) sudo pacman -S --noconfirm clang ;;
  brew) ;; # macOS includes libclang via Xcode/CommandLineTools
  esac

  echo "  Installing tree-sitter-cli via cargo..."
  cargo install tree-sitter-cli || red "  Failed to install tree-sitter-cli via cargo."
  green "  [ok] tree-sitter-cli installed"
fi

# -------------------------------------------------------
# 4. Install Oh My Zsh
# -------------------------------------------------------
echo ""
echo "=== Installing Oh My Zsh ==="
if [ -d "$HOME/.oh-my-zsh" ]; then
  green "  [ok] Oh My Zsh already installed"
else
  echo "  Installing Oh My Zsh..."
  CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || red "  Failed to install Oh My Zsh."
  green "  [ok] Oh My Zsh installed"
fi

# -------------------------------------------------------
# 5. Install Oh My Zsh custom plugins
# -------------------------------------------------------
echo ""
echo "=== Installing Oh My Zsh Plugins ==="

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A OMZ_PLUGINS
OMZ_PLUGINS=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
)

for plugin in "${!OMZ_PLUGINS[@]}"; do
  dest="$ZSH_CUSTOM/plugins/$plugin"
  if [ -d "$dest" ]; then
    green "  [ok] $plugin already installed"
  else
    echo "  Cloning $plugin..."
    git clone --depth=1 "${OMZ_PLUGINS[$plugin]}" "$dest" || red "  Failed to clone $plugin"
    green "  [ok] $plugin installed"
  fi
done

# install starship
curl -sS https://starship.rs/install.sh | sh

# -------------------------------------------------------
# 6. Symlink dotfiles
# -------------------------------------------------------
echo ""
echo "=== Symlinking Dotfiles ==="

echo "Setting up Neovim..."
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  echo "Setting up Zsh..."
  link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

echo ""
green "Done! All set up."
