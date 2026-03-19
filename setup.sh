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
# 1. Detect package manager
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
    *) red "  No supported package manager found. Install '$name' manually."; return 1 ;;
  esac
}

# Maps a tool name to the correct package name per package manager
pkg_name() {
  local tool="$1"
  case "$tool" in
    nvim)
      case "$PKG_MANAGER" in
        brew) echo "neovim" ;;
        apt|dnf) echo "neovim" ;;
        pacman) echo "neovim" ;;
        *) echo "neovim" ;;
      esac
      ;;
    gcc)
      case "$PKG_MANAGER" in
        brew) echo "gcc" ;;
        apt) echo "build-essential" ;;
        dnf) echo "gcc" ;;
        pacman) echo "base-devel" ;;
        *) echo "gcc" ;;
      esac
      ;;
    make)
      case "$PKG_MANAGER" in
        brew) echo "make" ;;
        apt) echo "build-essential" ;;
        dnf) echo "make" ;;
        pacman) echo "base-devel" ;;
        *) echo "make" ;;
      esac
      ;;
    node)
      case "$PKG_MANAGER" in
        brew) echo "node" ;;
        apt) echo "nodejs" ;;
        dnf) echo "nodejs" ;;
        pacman) echo "nodejs" ;;
        *) echo "nodejs" ;;
      esac
      ;;
    npm)
      case "$PKG_MANAGER" in
        apt) echo "npm" ;;
        *) echo "" ;; # npm comes with node on brew/dnf/pacman
      esac
      ;;
    rg)
      case "$PKG_MANAGER" in
        brew) echo "ripgrep" ;;
        apt) echo "ripgrep" ;;
        dnf) echo "ripgrep" ;;
        pacman) echo "ripgrep" ;;
        *) echo "ripgrep" ;;
      esac
      ;;
    fd)
      case "$PKG_MANAGER" in
        brew) echo "fd" ;;
        apt) echo "fd-find" ;;
        dnf) echo "fd-find" ;;
        pacman) echo "fd" ;;
        *) echo "fd" ;;
      esac
      ;;
    lazygit)
      case "$PKG_MANAGER" in
        brew) echo "lazygit" ;;
        *) echo "lazygit" ;;
      esac
      ;;
    *) echo "$tool" ;;
  esac
}

# -------------------------------------------------------
# 2. Install dependencies
# -------------------------------------------------------
echo "=== Installing Dependencies ==="
echo "Detected package manager: $PKG_MANAGER"
echo ""

REQUIRED_TOOLS=(git nvim gcc make node npm rg fd fzf stylua shfmt)
OPTIONAL_TOOLS=(lazygit)

missing=()
for tool in "${REQUIRED_TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    green "  [ok] $tool"
  else
    yellow "  [missing] $tool"
    missing+=("$tool")
  fi
done

# Also check for a C compiler via cc/clang if gcc is missing
if [[ " ${missing[*]} " == *" gcc "* ]]; then
  if command -v cc &>/dev/null || command -v clang &>/dev/null; then
    green "  [ok] C compiler found (cc/clang)"
    missing=("${missing[@]/gcc/}")
  fi
fi

echo ""
echo "Optional tools:"
for tool in "${OPTIONAL_TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    green "  [ok] $tool"
  else
    yellow "  [missing] $tool"
    missing+=("$tool")
  fi
done

echo ""

if [ ${#missing[@]} -gt 0 ]; then
  # Filter out empty entries
  filtered=()
  for m in "${missing[@]}"; do
    [ -n "$m" ] && filtered+=("$m")
  done

  if [ ${#filtered[@]} -gt 0 ]; then
    echo "The following tools will be installed: ${filtered[*]}"
    read -rp "Proceed? [Y/n] " answer
    answer="${answer:-Y}"

    if [[ "$answer" =~ ^[Yy]$ ]]; then
      if [ "$PKG_MANAGER" = "apt" ]; then
        echo "Updating package index..."
        sudo apt-get update -qq
      fi

      for tool in "${filtered[@]}"; do
        pkg="$(pkg_name "$tool")"
        if [ -z "$pkg" ]; then
          continue # e.g. npm on non-apt (comes with node)
        fi
        echo "Installing $tool ($pkg)..."
        install_pkg "$pkg" || red "  Failed to install $tool — install it manually."
      done

      echo ""
      green "Installation complete."
    else
      yellow "Skipping installation. Some tools may be missing."
    fi
  fi
else
  green "All dependencies are already installed."
fi

# -------------------------------------------------------
# 3. Install libclang-dev (needed for tree-sitter and other native builds)
# -------------------------------------------------------
echo ""
echo "=== Installing libclang-dev ==="
case "$PKG_MANAGER" in
  brew)
    if brew list llvm &>/dev/null; then
      green "  [ok] llvm (provides libclang) already installed"
    else
      echo "Installing llvm (provides libclang)..."
      brew install llvm || red "  Failed to install llvm."
    fi
    ;;
  apt)
    if dpkg -s libclang-dev &>/dev/null 2>&1; then
      green "  [ok] libclang-dev already installed"
    else
      echo "Installing libclang-dev..."
      sudo apt-get install -y libclang-dev || red "  Failed to install libclang-dev."
    fi
    ;;
  dnf)
    if rpm -q clang-devel &>/dev/null 2>&1; then
      green "  [ok] clang-devel already installed"
    else
      echo "Installing clang-devel..."
      sudo dnf install -y clang-devel || red "  Failed to install clang-devel."
    fi
    ;;
  pacman)
    if pacman -Qi clang &>/dev/null 2>&1; then
      green "  [ok] clang already installed"
    else
      echo "Installing clang..."
      sudo pacman -S --noconfirm clang || red "  Failed to install clang."
    fi
    ;;
  *)
    red "  No supported package manager found. Install libclang-dev manually."
    ;;
esac

# -------------------------------------------------------
# 4. Install tree-sitter-cli via cargo
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
  echo "Installing tree-sitter-cli via cargo..."
  cargo install tree-sitter-cli || red "  Failed to install tree-sitter-cli via cargo."
  if command -v tree-sitter &>/dev/null; then
    green "  [ok] tree-sitter-cli installed successfully"
  else
    red "  tree-sitter-cli not found after install — check your PATH includes ~/.cargo/bin"
  fi
fi

# -------------------------------------------------------
# 5. Symlink dotfiles
# -------------------------------------------------------
echo ""
echo "=== Symlinking Dotfiles ==="
echo "Source: $DOTFILES_DIR"
echo ""

# --- Neovim ---
echo "Setting up Neovim..."
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# --- Lazygit ---
if [ -d "$DOTFILES_DIR/lazygit" ]; then
  echo "Setting up Lazygit..."
  link "$DOTFILES_DIR/lazygit" "$HOME/.config/lazygit"
fi

# --- Zsh ---
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  echo "Setting up Zsh..."
  link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

echo ""
green "Done! All dotfiles have been symlinked."
