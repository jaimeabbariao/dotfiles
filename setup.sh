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
  [zsh - autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
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
if command -v starship &>/dev/null; then
  green "  [ok] starship already installed"
else
  echo "  Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y || red "  Failed to install starship."
  green "  [ok] starship installed"
fi

# -------------------------------------------------------
# 6. Install lazygit
# -------------------------------------------------------
echo ""
echo "=== Installing lazygit ==="
if command -v lazygit &>/dev/null; then
  green "  [ok] lazygit already installed"
else
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  if [ -z "$LAZYGIT_VERSION" ]; then
    red "  Failed to fetch latest lazygit version."
  else
    echo "  Installing lazygit v${LAZYGIT_VERSION}..."
    LAZYGIT_DIR="$HOME/lazygit"
    mkdir -p "$LAZYGIT_DIR"

    # Detect OS and arch
    case "$(uname -s)" in
    Darwin) LAZYGIT_OS="Darwin" ;;
    Linux) LAZYGIT_OS="Linux" ;;
    *)
      red "  Unsupported OS for lazygit install."
      LAZYGIT_OS=""
      ;;
    esac

    case "$(uname -m)" in
    x86_64) LAZYGIT_ARCH="x86_64" ;;
    arm64 | aarch64) LAZYGIT_ARCH="arm64" ;;
    *)
      red "  Unsupported architecture for lazygit install."
      LAZYGIT_ARCH=""
      ;;
    esac

    if [ -n "$LAZYGIT_OS" ] && [ -n "$LAZYGIT_ARCH" ]; then
      LAZYGIT_TAR="lazygit_${LAZYGIT_VERSION}_${LAZYGIT_OS}_${LAZYGIT_ARCH}.tar.gz"
      curl -Lo "$LAZYGIT_DIR/$LAZYGIT_TAR" "https://github.com/jesseduffield/lazygit/releases/latest/download/$LAZYGIT_TAR"
      tar xf "$LAZYGIT_DIR/$LAZYGIT_TAR" -C "$LAZYGIT_DIR" lazygit
      rm "$LAZYGIT_DIR/$LAZYGIT_TAR"

      # Add to PATH via ~/bin symlink
      mkdir -p "$HOME/bin"
      ln -sf "$LAZYGIT_DIR/lazygit" "$HOME/bin/lazygit"
      green "  [ok] lazygit installed to $LAZYGIT_DIR/lazygit"
      yellow "  Ensure ~/bin is in your PATH (e.g. export PATH=\"\$HOME/bin:\$PATH\" in .zshrc)"
    fi
  fi
fi

# -------------------------------------------------------
# 7. Install tmux & Oh My Tmux
# -------------------------------------------------------
echo ""
echo "=== Installing tmux ==="
if command -v tmux &>/dev/null; then
  green "  [ok] tmux already installed"
else
  echo "  Installing tmux..."
  install_pkg tmux || red "  Failed to install tmux — install it manually."
fi

echo ""
echo "=== Installing Oh My Tmux ==="
if [ -d "$HOME/.tmux" ]; then
  green "  [ok] Oh My Tmux already installed"
else
  echo "  Cloning Oh My Tmux..."
  git clone --depth=1 https://github.com/gpakosz/.tmux.git "$HOME/.tmux" || red "  Failed to clone Oh My Tmux"
  green "  [ok] Oh My Tmux installed"
fi

# -------------------------------------------------------
# 8. Symlink dotfiles
# -------------------------------------------------------
echo ""
echo "=== Symlinking Dotfiles ==="

echo "Setting up Neovim..."
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  echo "Setting up Zsh..."
  link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

echo "Setting up tmux..."
link "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

echo "Setting up Zellij..."
link "$DOTFILES_DIR/zellij" "$HOME/.config/zellij"

echo "Setting up claude skills.."
link "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

# -------------------------------------------------------
# 9. Set up ~/figma/figma
# -------------------------------------------------------
echo ""
echo "=== Setting up ~/figma/figma ==="
if [ -d "$HOME/figma/figma" ]; then
  echo "  Running pnpm install..."
  (cd "$HOME/figma/figma" && pnpm i) || red "  Failed to run pnpm i"
  echo "  Running bazel build_deps..."
  (cd "$HOME/figma/figma" && bazel run //web:build_deps) || red "  Failed to run bazel run //web:build_deps"
  green "  [ok] ~/figma/figma set up"
else
  yellow "  ~/figma/figma not found — skipping."
fi

echo ""
green "Done! All set up."
echo ""
yellow "Remember to source your zshrc to apply changes:"
yellow "  source ~/.zshrc"
