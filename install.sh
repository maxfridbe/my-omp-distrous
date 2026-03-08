#!/bin/bash

# Theme Installation and .bashrc Update Script
# Usage: ./install.sh

# Get script directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
THEME_SRC="${SCRIPT_DIR}/themes"
TARGET_DIR="${HOME}/.config/omp/themes"

# 1. Create target directory and copy themes
echo "Creating theme directory: ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}"

echo "Copying themes..."
if [ -d "${THEME_SRC}" ]; then
    cp -r "${THEME_SRC}/"* "${TARGET_DIR}/"
    echo "Successfully copied themes to ${TARGET_DIR}"
else
    echo "Error: Source themes directory not found at ${THEME_SRC}"
    exit 1
fi

# 2. Update .bashrc
BASHRC="${HOME}/.bashrc"
echo "Updating ${BASHRC}..."

# Define the Oh My Posh configuration block
OMP_BLOCK_START="# --- BEGIN OH-MY-POSH DISTRO-THEME ---"
OMP_BLOCK_END="# --- END OH-MY-POSH DISTRO-THEME ---"

OMP_CONFIG_CONTENT="
${OMP_BLOCK_START}
# Set Oh My Posh theme based on distribution
if command -v oh-my-posh > /dev/null; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        
        # Priority: .config/omp/themes -> fallback to linux
        THEME_DIR=\"\${HOME}/.config/omp/themes\"
        THEME_ID=\$ID
        
        case \"\$ID\" in
            arch) THEME_ID=\"arch-linux\" ;;
            almalinux) THEME_ID=\"alma-linux\" ;;
            alpine) THEME_ID=\"alpine-linux\" ;;
            aosc) THEME_ID=\"aosc-linux\" ;;
            linuxmint) THEME_ID=\"linux-mint\" ;;
            pop) THEME_ID=\"pop_os\" ;;
            rocky) THEME_ID=\"rocky-linux\" ;;
            rhel) THEME_ID=\"red-hat\" ;;
            *) THEME_ID=\"\$ID\" ;;
        esac

        THEME_FILE=\"\${THEME_DIR}/distrous-\${THEME_ID}.omp.json\"
        
        # Check if the specific theme exists, fallback to general linux theme if not
        if [ ! -f \"\$THEME_FILE\" ]; then
            THEME_FILE=\"\${THEME_DIR}/distrous-linux.omp.json\"
        fi

        # Final existence check before init
        if [ -f \"\$THEME_FILE\" ]; then
            eval \"\$(oh-my-posh init bash --config \"\$THEME_FILE\")\"
        else
            eval \"\$(oh-my-posh init bash)\"
        fi
    else
        eval \"\$(oh-my-posh init bash)\"
    fi
fi
${OMP_BLOCK_END}"

# Remove existing OMP block or single eval line if they exist
# First, remove old style if it exists
sed -i '/eval "$(oh-my-posh init bash)"/d' "${BASHRC}"
# Then, remove any existing OMP_BLOCK
sed -i "/${OMP_BLOCK_START}/,/${OMP_BLOCK_END}/d" "${BASHRC}"

# Append the new block
echo "${OMP_CONFIG_CONTENT}" >> "${BASHRC}"

echo "Installation complete. Please restart your shell or run: source ~/.bashrc"
