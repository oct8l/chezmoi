#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# and treat unset variables as an error and exit immediately.
set -Eeuo pipefail

# Enable debugging if DOTFILES_DEBUG is set.
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Function to set UI-related defaults.
function defaults_ui() {
    # Display battery percentage
    # ref. https://github.com/todd-dsm/mac-ops/issues/39#issuecomment-962459353
    defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
}

# Function to set keyboard-related defaults.
function defaults_keyboard() {
    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    # Set a shorter delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 25

    # Change Caps Lock to Ctrl
    # ref. https://stackoverflow.com/a/46460200
    hidutil property --set \
        '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc": 0x700000039, "HIDKeyboardModifierMappingDst": 0x7000000e0 }] }'
}

# Function to set trackpad-related defaults.
function defaults_trackpad() {
    # Set trackpad scaling
    defaults write -g com.apple.trackpad.scaling 2

    # Enable tap to click for this user and for the login screen
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # Enable 3-finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
}

# Function to set Control Center-related defaults.
function defaults_controlcenter() {
    # Show Bluetooth in the Control Center
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
}

# Function to set Dock-related defaults.
function defaults_dock() {
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    # Set the icon size of Dock items to 30 pixels
    defaults write com.apple.dock tilesize -int 30

    # Remove all the icons in the Dock
    defaults write com.apple.dock persistent-apps -array ""
    defaults write com.apple.dock recent-apps -array ""
    defaults write com.apple.dock persistent-others -array ""

    # Function to create a Dock item entry
    function dock_item() {
        local app_file_path="$1"
        printf '
        <dict>
            <key>tile-data</key>
                <dict>
                    <key>file-data</key>
                        <dict>
                            <key>_CFURLString</key><string>%s</string>
                            <key>_CFURLStringType</key><integer>0</integer>
                        </dict>
                </dict>
        </dict>', "${app_file_path}"
    }

    # Function to get the path of the System Preferences or System Settings app
    function get_system_app_path() {
        local system_preferences_path="/System/Applications/System Preferences.app/"
        local system_settings_path="/System/Applications/System Settings.app/"

        if [ -e "${system_preferences_path}" ]; then
            echo "${system_preferences_path}"
        elif [ -e "${system_settings_path}" ]; then
            # For macOS Ventura
            echo "${system_settings_path}"
        else
            echo "Could not find system app ${system_preferences_path} and ${system_settings_path}" >&2
            exit 1
        fi
    }

    # Add specific applications to the Dock
    defaults write com.apple.dock persistent-apps -array \
        "$(dock_item /Applications/Google\ Chrome.app)" \
        "$(dock_item /Applications/Visual\ Studio\ Code.app)" \
        "$(dock_item /Applications/Slack.app)" \
        "$(dock_item /Applications/iTerm.app)" \
        "$(dock_item "$(get_system_app_path)")"
}

# Function to set input source-related defaults.
function defaults_input_sources() {
    # Enable `Automatically switch to a document's input source`
    defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput -bool true

    # Set `Select the previous input source` as Command + `
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 \
        "<dict>
            <key>enabled</key><true/>
            <key>value</key>
                <dict>
                    <key>parameters</key>
                        <array>
                            <integer>96</integer>
                            <integer>50</integer>
                            <integer>1048576</integer>
                        </array>
                    <key>type</key>
                        <string>standard</string>
                </dict>
        </dict>"

    # Temporarily delete IME input language settings
    defaults delete com.apple.HIToolbox AppleEnabledInputSources
    # Add US IME input source
    defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
        "<dict>
            <key>InputSourceKind</key><string>Keyboard Layout</string>
            <key>KeyboardLayout ID</key><integer>0</integer>
            <key>KeyboardLayout Name</key><string>U.S.</string>
        </dict>"
    # Add Google Japanese IME input source
    defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
        "<dict>
            <key>Bundle ID</key><string>com.google.inputmethod.Japanese</string>
            <key>Input Mode</key><string>com.apple.inputmethod.Japanese</string>
            <key>InputSourceKind</key><string>Input Mode</string>
        </dict>"
    defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
        "<dict>
            <key>Bundle ID</key><string>com.google.inputmethod.Japanese</string>
            <key>InputSourceKind</key><string>Keyboard Input Method</string>
        </dict>"
}

# Function to set Finder-related defaults.
function defaults_finder() {
    # Set Home directory as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Group items by name
    defaults write com.apple.finder FXPreferredGroupBy -string "Name"
    defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Enable the “Remove items from the Trash after 30 days” feature
    defaults write com.apple.finder FXRemoveOldTrashItems -bool true
}

# Function to set screenshot-related defaults.
function defaults_screencapture() {
    # Save screenshots to ${HOME}/Pictures/
    defaults write com.apple.screencapture location -string "${HOME}/Pictures/"
    defaults write com.apple.screencapture name -string "Screen Shot"

    # Disable the floating screenshot thumbnail
    defaults write com.apple.screencapture show-thumbnail -bool false
}

# Function to set assistant-related defaults.
function defaults_assistant() {
    # Disable Siri
    defaults write com.apple.assistant.support "Assistant Enabled" -bool false
    # Disable dictation
    defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false
}

# Function to set iTerm2-related defaults.
function defaults_iterm2() {
    # Additional defaults settings can be found in `.chezmoiscripts/macos/run_once_04-install-iterm2.sh.tmpl`

    # Don’t display the annoying prompt when quitting iTerm
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false

    # Set the custom folder to load preferences
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    # Disable tip of the day
    defaults write com.googlecode.iterm2 NoSyncTipsDisabled -bool true
}

# Function to kill affected applications to apply the changes.
function kill_affected_applications() {
    local apps=(
        "Activity Monitor"
        "Calendar"
        "cfprefsd"
        "Dock"
        "Finder"
        # "Google Chrome Canary"
        # "Google Chrome"
        "SizeUp"
        "Spectacle"
        "SystemUIServer"
        # "Terminal" # disable because the setup script is running in the Terminal
        "Transmission"
        "Twitter"
    )
    for app in "${apps[@]}"; do
        killall "${app}" || echo "Process \`${app}\` was not running."
    done
}

# Function to open the Spectacle application.
function open_spectacle() {
    local app_path="/Applications/Spectacle.app/"
    if [ -e "${app_path}" ]; then
        open -g "${app_path}"
    fi
}

# Function to reopen killed applications.
function open_killed_applications() {
    open_spectacle
}

# Main function to execute all default settings.
function main() {
    # defaults_ui
    # defaults_keyboard
    # defaults_trackpad
    # defaults_controlcenter
    # defaults_dock
    # defaults_input_sources
    # defaults_finder
    # defaults_screencapture
    # defaults_assistant
    # defaults_iterm2
    # kill_affected_applications
    # open_killed_applications
}

# If the script is being run directly, execute the main function.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
