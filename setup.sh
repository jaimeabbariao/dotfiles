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

# No associative arrays: macOS ships bash 3.2. "tool:package" pairs instead.
PACKAGES="git:git nvim:neovim rg:ripgrep curl:curl node:node npm:npm fzf:fzf fd:fd"

# Override package names per manager
case "$PKG_MANAGER" in
apt)
  # Used by Neovim and terminal apps when Ubuntu has an X11 display.
  # Headless SSH sessions use Neovim's OSC 52 provider instead.
  PACKAGES="${PACKAGES/node:node/node:nodejs} xclip:xclip"
  PACKAGES="${PACKAGES/fd:fd/fd:fd-find}"
  ;;
dnf)
  PACKAGES="${PACKAGES/fd:fd/fd:fd-find}"
  ;;
esac

for pair in $PACKAGES; do
  tool="${pair%%:*}"
  pkg="${pair#*:}"
  if command -v "$tool" &>/dev/null; then
    green "  [ok] $tool"
  else
    echo "  Installing $tool ($pkg)..."
    install_pkg "$pkg" || red "  Failed to install $tool — install it manually."
  fi
done

# Debian/Ubuntu ship fd-find's binary as `fdfind` to avoid colliding with
# fdclone, so tools looking for `fd` (Telescope, fzf configs) never find it.
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  mkdir -p "$HOME/bin"
  ln -sf "$(command -v fdfind)" "$HOME/bin/fd"
  green "  [ok] linked fd -> fdfind in ~/bin"
fi

# -------------------------------------------------------
# 3. Install Rust toolchain
# -------------------------------------------------------
echo ""
echo "=== Installing Rust toolchain ==="
# Own our toolchain dirs: images that ship a system rustup point these at
# root-owned paths, where `cargo install` fails with a permissions error.
export CARGO_HOME="$HOME/.cargo" RUSTUP_HOME="$HOME/.rustup"
# A rustup may already be installed but absent from this shell's PATH, since
# ~/.cargo/bin is only added by an interactive rc file. Look there first.
[ -d "$CARGO_HOME/bin" ] && PATH="$CARGO_HOME/bin:$PATH"
# Key on rustup, not cargo: a distro-packaged cargo is often too old to build
# yazi-build, so ensure a rustup-managed latest-stable toolchain regardless.
if command -v rustup &>/dev/null; then
  # Idempotent, and installs stable if this RUSTUP_HOME has no toolchain yet.
  rustup default stable >/dev/null && green "  [ok] rustup already installed" ||
    red "  rustup found but no usable toolchain — cargo-based tools will be skipped."
else
  if command -v cargo &>/dev/null; then
    yellow "  cargo found but rustup missing — installing rustup for a latest-stable toolchain..."
  else
    yellow "  Rust/Cargo not found. Installing via rustup..."
  fi
  # -y: non-interactive; --no-modify-path since we manage PATH ourselves.
  # RUSTUP_INIT_SKIP_PATH_CHECK: without it rustup-init aborts with "cannot
  # install while Rust is installed" when a distro rustc/cargo is on PATH.
  # rustup's ~/.cargo/bin wins on PATH anyway, so that check is unwanted here.
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y --no-modify-path; then
    PATH="$CARGO_HOME/bin:$PATH"
    green "  [ok] Rust toolchain installed"
  else
    red "  Failed to install Rust toolchain — cargo-based tools will be skipped."
  fi
fi

# -------------------------------------------------------
# 3a. Install tree-sitter-cli via cargo
# -------------------------------------------------------
echo ""
echo "=== Installing tree-sitter-cli ==="
if command -v tree-sitter &>/dev/null; then
  green "  [ok] tree-sitter-cli already installed"
else
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
# 3b. Install yazi
# -------------------------------------------------------
echo ""
echo "=== Installing yazi ==="
if command -v yazi &>/dev/null; then
  green "  [ok] yazi already installed"
elif [ "$PKG_MANAGER" = "brew" ]; then
  echo "  Installing yazi via brew..."
  install_pkg yazi || red "  Failed to install yazi — install it manually."
else
  # On Linux, install from crates.io (distro packages are often missing/outdated)
  # yazi-build requires make and gcc to build yazi-fm/yazi-cli from source
  case "$PKG_MANAGER" in
  apt) sudo apt-get install -y make gcc ;;
  dnf) sudo dnf install -y make gcc ;;
  pacman) sudo pacman -S --noconfirm make gcc ;;
  esac
  echo "  Installing yazi via cargo (yazi-build)..."
  cargo install --force yazi-build || red "  Failed to install yazi via cargo."
  green "  [ok] yazi installed"
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

plugin=zsh-autosuggestions
dest="$ZSH_CUSTOM/plugins/$plugin"
if [ -d "$dest" ]; then
  green "  [ok] $plugin already installed"
else
  echo "  Cloning $plugin..."
  git clone --depth=1 "https://github.com/zsh-users/$plugin" "$dest" || red "  Failed to clone $plugin"
  green "  [ok] $plugin installed"
fi

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
# 7. Install Herdr
# -------------------------------------------------------
echo ""
echo "=== Installing Herdr ==="
if command -v herdr &>/dev/null; then
  green "  [ok] Herdr already installed"
else
  echo "  Installing Herdr..."
  if curl -fsSL https://herdr.dev/install.sh | sh; then
    green "  [ok] Herdr installed"
  else
    red "  Failed to install Herdr."
  fi
fi

# -------------------------------------------------------
# 8. Install ponytail skills
# -------------------------------------------------------
echo ""
echo "=== Installing ponytail skills ==="

# Cloned outside the repo and symlinked in, so `setup.sh` tracks upstream
# instead of vendoring a copy that silently drifts. Skills only: the plugin's
# always-on hooks are Claude-specific, these dirs work in Codex/Cursor too.
PONYTAIL_DIR="$HOME/.local/share/ponytail"
if [ -d "$PONYTAIL_DIR/.git" ]; then
  echo "  Updating ponytail..."
  git -C "$PONYTAIL_DIR" pull --ff-only -q || yellow "  Failed to update ponytail — using the existing checkout."
else
  echo "  Cloning ponytail..."
  mkdir -p "$(dirname "$PONYTAIL_DIR")"
  git clone --depth=1 -q https://github.com/DietrichGebert/ponytail "$PONYTAIL_DIR" || red "  Failed to clone ponytail."
fi

if [ -d "$PONYTAIL_DIR/skills" ]; then
  for skill in "$PONYTAIL_DIR"/skills/*/; do
    link "${skill%/}" "$DOTFILES_DIR/agent-skills/$(basename "${skill%/}")"
  done
else
  red "  No ponytail skills found at $PONYTAIL_DIR/skills — skipping."
fi

# -------------------------------------------------------
# 8b. Install caveman skill
# -------------------------------------------------------
echo ""
echo "=== Installing caveman skill ==="

# Same pattern as ponytail: track upstream, symlink in. Skill only — the proxy
# and CLI need a global npm install and an agent wrapper. Linked after ponytail
# on purpose: both ship a `caveman` skill, upstream's wins.
CAVEMAN_DIR="$HOME/.local/share/caveman"
if [ -d "$CAVEMAN_DIR/.git" ]; then
  echo "  Updating caveman..."
  git -C "$CAVEMAN_DIR" pull --ff-only -q || yellow "  Failed to update caveman — using the existing checkout."
else
  echo "  Cloning caveman..."
  mkdir -p "$(dirname "$CAVEMAN_DIR")"
  git clone --depth=1 -q https://github.com/JuliusBrussee/caveman "$CAVEMAN_DIR" || red "  Failed to clone caveman."
fi

if [ -d "$CAVEMAN_DIR/skills/caveman" ]; then
  link "$CAVEMAN_DIR/skills/caveman" "$DOTFILES_DIR/agent-skills/caveman"
else
  red "  No caveman skill found at $CAVEMAN_DIR/skills/caveman — skipping."
fi

# -------------------------------------------------------
# 8c. Install leaf
# -------------------------------------------------------

echo ""
echo "=== Installing leaf ==="
if command -v leaf &>/dev/null; then
  green "  [ok] leaf already installed"
else
  echo "  Installing leaf..."
  if curl -fsSL https://raw.githubusercontent.com/RivoLink/leaf/main/scripts/install.sh | sh; then
    green "  [ok] leaf installed"
  else
    red "  Failed to install leaf."
  fi
fi

# -------------------------------------------------------
# 9. Symlink dotfiles
# -------------------------------------------------------
echo ""
echo "=== Symlinking Dotfiles ==="

# Must come after Oh My Zsh: its installer writes its own template to ~/.zshrc.
echo "Setting up Zsh..."
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo "Setting up Neovim..."
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "Setting up Yazi..."
link "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"

echo "Setting up Ghostty..."
link "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"

echo "Setting up WezTerm..."
link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"

echo "Setting up herdr..."
link "$DOTFILES_DIR/herdr" "$HOME/.config/herdr"

# Claude and Codex are linked file-by-file, not as directories: both keep
# mutable state (history, sessions, projects, logs) alongside their config.
echo "Setting up Claude..."
link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/claude/banned-words.txt" "$HOME/.claude/banned-words.txt"
mkdir -p "$HOME/.claude/hooks"
link "$DOTFILES_DIR/claude/hooks/banned-words.py" "$HOME/.claude/hooks/banned-words.py"

echo "Setting up Codex..."
link "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"

echo "Setting up agent skills..."
for skills_dir in \
  "$HOME/.claude/skills" \
  "$HOME/.codex/skills" \
  "$HOME/.cursor/skills"; do
  link "$DOTFILES_DIR/agent-skills" "$skills_dir"
done

echo ""
green "Done! All set up."
echo ""
yellow "Remember to source your zshrc to apply changes:"
yellow "  source ~/.zshrc"
