#!/bin/bash

# Mac Setup Automation Script
# Run with: bash <(curl -fsSL https://www.tananaev.com/setup.sh)
# Some steps require sudo; you'll be prompted as needed.

set -e

# Verify Xcode is installed before proceeding (required for git and dev tools)
if ! xcode-select -p &>/dev/null; then
  echo "ERROR: Xcode is not installed."
  echo "Please install Xcode from the App Store, launch it once to accept the"
  echo "license agreement, then re-run this script."
  exit 1
fi

if [ ! -d "/Applications/Google Chrome.app" ]; then
  echo "ERROR: Google Chrome is not installed."
  echo "Please install Chrome before running this script."
  exit 1
fi

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "ERROR: ~/.ssh/id_rsa not found."
  echo "Please add your SSH private key before running this script."
  exit 1
fi

echo "==> Starting Mac setup..."

# ─────────────────────────────────────────────
# HOMEBREW
# ─────────────────────────────────────────────
echo "==> Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> Setting up Homebrew autoupdate..."
brew tap homebrew/autoupdate 2>/dev/null || true
brew autoupdate start --upgrade 2>/dev/null || true

echo "==> Installing Homebrew packages..."
brew install --cask \
  sublime-text \
  vlc \
  libreoffice \
  gimp \
  visual-studio-code \
  intellij-idea-ce \
  android-studio \
  inkscape \
  spotify \
  codex

brew install \
  openjdk@17 \
  python \
  wget \
  maven \
  gpg \
  node \
  jq \
  dockutil

# ─────────────────────────────────────────────
# GIT
# ─────────────────────────────────────────────
echo "==> Configuring Git..."
git config --global user.name "Anton Tananaev"
git config --global user.email "anton.tananaev@gmail.com"
git config --global core.editor "nano"
git config --global core.autocrlf input
git config --global push.default simple

# ─────────────────────────────────────────────
# ENVIRONMENT
# ─────────────────────────────────────────────
echo "==> Setting up known hosts..."
ssh-keyscan github.com >> ~/.ssh/known_hosts
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

echo "==> Cloning repositories..."
cd ~/Documents

wget http://cdn.sencha.com/ext/gpl/ext-6.2.0-gpl.zip
unzip -qq ext-*-gpl.zip
rm ext-*-gpl.zip

clone() {
  if [ $# -eq 2 ]; then
    git clone "$1" "$2"
    (cd "$2" && git config user.email "anton@traccar.org")
  else
    git clone "$1" "$2" "$3"
    (cd "$3" && git config user.email "anton@traccar.org")
  fi
}

declare -a apps=(
  "traccar-client"
  "traccar-client-android"
  "traccar-client-ios"
  "traccar-manager"
  "traccar-manager-android"
  "traccar-manager-ios"
)

git clone git@github.com:tananaev/environment.git environment
git clone git@github.com:tananaev/tananaev-com.git tananaev-com
git clone git@github.com:tananaev/traccar-www.git traccar-www
clone --recurse-submodules git@github.com:traccar/traccar.git traccar
(cd traccar/traccar-web && git config user.email "anton@traccar.org")
for app in "${apps[@]}"; do
  clone git@github.com:traccar/$app.git $app
done

mkdir work && cd work
ln -s ../ext-6.2.0 ext-6.2.0
clone --recurse-submodules git@gitlab.com:traccar/traccar.git traccar
(cd traccar && git remote add upstream https://github.com/traccar/traccar.git)
(cd traccar/traccar-web && git config user.email "anton@traccar.org")
(cd traccar/traccar-web && git remote add upstream https://github.com/traccar/traccar-web.git)
for app in "${apps[@]}"; do
  clone git@gitlab.com:traccar/$app.git $app
  (cd $app && git remote add upstream https://github.com/traccar/$app.git)
done

cd ~/Documents

# ─────────────────────────────────────────────
# MACOS DEFAULTS
# ─────────────────────────────────────────────
echo "==> Applying macOS defaults..."

defaults write -g ApplePersistence -bool no
defaults write -g com.apple.swipescrolldirection -bool false

defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock wvous-br-corner -int 13
defaults write com.apple.dock wvous-br-modifier -int 0

defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"

defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
  '<dict>
    <key>InputSourceKind</key><string>Keyboard Layout</string>
    <key>KeyboardLayout ID</key><integer>19458</integer>
    <key>KeyboardLayout Name</key><string>Russian - PC</string>
  </dict>' \
  2>/dev/null || true

defaults write com.apple.CoreBrightness.plist CBBlueReductionStatus \
  -dict \
    AutoBlueReductionEnabled -int 1 \
    Mode -int 1 \
    CBColorAdaptationEnabled -int 1 \
  2>/dev/null || true

echo "setopt NO_BEEP" >> ~/.zshrc

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

# ─────────────────────────────────────────────
# DOCK ORDER
# ─────────────────────────────────────────────
echo "==> Setting Dock app order..."
declare -a DOCK_APPS=(
  "/System/Applications/Apps.app"
  "/System/Applications/Utilities/Terminal.app"
  "/Applications/Google Chrome.app"
  "/Applications/Android Studio.app"
  "/Applications/IntelliJ IDEA CE.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Xcode.app"
  "/Applications/Sublime Text.app"
  "/Applications/Spotify.app"
  "/System/Applications/App Store.app"
  "/System/Applications/System Settings.app"
)

dockutil --remove all --no-restart
for app in "${DOCK_APPS[@]}"; do
  if [ -d "$app" ]; then
    dockutil --add "$app" --no-restart
  else
    echo "  [skip] Not found: $app"
  fi
done
dockutil --add "/Applications" --view grid --display folder --no-restart
killall Dock

# ─────────────────────────────────────────────
# SPOTLIGHT
# ─────────────────────────────────────────────
echo "==> Disabling Spotlight indexing..."
sudo mdutil -a -i off

# ─────────────────────────────────────────────
# CHROME
# ─────────────────────────────────────────────
echo "==> Configuring Chrome via managed preferences..."

CHROME_POLICY_DIR="/Library/Managed Preferences"
sudo mkdir -p "$CHROME_POLICY_DIR"

sudo tee "$CHROME_POLICY_DIR/com.google.Chrome.plist" > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Disable built-in password manager -->
  <key>PasswordManagerEnabled</key>
  <false/>
  <!-- Disable notifications -->
  <key>DefaultNotificationsSetting</key>
  <integer>2</integer>
  <!-- Add Russian spellcheck -->
  <key>SpellcheckLanguage</key>
  <array>
    <string>ru</string>
  </array>
  <!-- Accept-Language header: English + Russian -->
  <key>ApplicationLocaleValue</key>
  <string>en-US</string>
  <!-- Force-install extensions: Bitwarden, uBlock Origin Lite, Empty New Tab, TopCashback -->
  <key>ExtensionInstallForcelist</key>
  <array>
    <string>nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx</string>
    <string>ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx</string>
    <string>dpjamkmjmigaoobjbekmfgabipmfilij;https://clients2.google.com/service/update2/crx</string>
    <string>lkmpdpkkkeeoiodlnmlichcmfmdjbjic;https://clients2.google.com/service/update2/crx</string>
  </array>
</dict>
</plist>
EOF

echo ""
echo "──────────────────────────────────────────"
echo "MANUAL STEPS REQUIRED:"
echo "──────────────────────────────────────────"
echo ""
echo "1. KEYBOARD (System Settings > Keyboard > Modifier Keys):"
echo "   - Swap Option ↔ Command for your external keyboard"
echo ""
echo "2. BITWARDEN: open extension > Settings > disable notifications"
echo ""
echo "==> Automated setup complete!"
