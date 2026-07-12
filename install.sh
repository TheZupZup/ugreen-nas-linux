#!/usr/bin/env bash

set -Eeuo pipefail

readonly project_directory="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

readonly data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly installation_directory="$data_home/ugreen-nas-linux"
readonly application_directory="$installation_directory/app"
readonly wine_prefix="$installation_directory/prefix"

readonly user_bin_directory="$HOME/.local/bin"
readonly applications_directory="$data_home/applications"
readonly desktop_entry="$applications_directory/io.github.thezupzup.UGREENNAS.desktop"

temporary_directory=""

print_status() {
    printf '\n==> %s\n' "$1"
}

fail() {
    printf '\nErreur : %s\n' "$1" >&2
    exit 1
}

cleanup() {
    if [[ -n "$temporary_directory" && -d "$temporary_directory" ]]; then
        rm -rf "$temporary_directory"
    fi
}

trap cleanup EXIT

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        fail "La commande '$command_name' est requise."
    fi
}

select_installer() {
    if [[ $# -ge 1 ]]; then
        printf '%s\n' "$1"
        return
    fi

    if command -v kdialog >/dev/null 2>&1; then
        kdialog \
            --title "Sélectionner l’installateur UGREEN NAS" \
            --getopenfilename "$HOME" \
            '*.exe|Installateurs Windows (*.exe)'
        return
    fi

    fail "Indique le chemin de l’installateur Windows UGREEN NAS."
}

validate_installer() {
    local installer_path="$1"

    [[ -f "$installer_path" ]] ||
        fail "Le fichier sélectionné n’existe pas."

    [[ "${installer_path,,}" == *.exe ]] ||
        fail "Le fichier sélectionné doit être un fichier .exe."

    7z t "$installer_path" >/dev/null ||
        fail "7-Zip ne reconnaît pas cet installateur."
}

extract_application() {
    local installer_path="$1"
    local extracted_directory="$temporary_directory/extracted"
    local staged_application_directory="$temporary_directory/app"
    local application_archive

    mkdir -p "$extracted_directory" "$staged_application_directory"

    print_status "Extraction de l’installateur Windows"

    7z x \
        "$installer_path" \
        "-o$extracted_directory" \
        -y >/dev/null

    application_archive="$(
        find "$extracted_directory" \
            -type f \
            -name 'app-64.7z' \
            -print \
            -quit
    )"

    [[ -n "$application_archive" ]] ||
        fail "L’archive app-64.7z est introuvable dans l’installateur."

    print_status "Extraction du client UGREEN NAS"

    7z x \
        "$application_archive" \
        "-o$staged_application_directory" \
        -y >/dev/null

    [[ -f "$staged_application_directory/UGREEN NAS.exe" ]] ||
        fail "L’exécutable UGREEN NAS.exe est introuvable."

    mkdir -p "$installation_directory"

    rm -rf "$application_directory"
    mv "$staged_application_directory" "$application_directory"
}

initialize_wine_prefix() {
    if [[ -f "$wine_prefix/system.reg" ]]; then
        print_status "Préfixe Wine existant conservé"
        return
    fi

    print_status "Création de l’environnement Wine"

    mkdir -p "$wine_prefix"

    WINEPREFIX="$wine_prefix" \
    WINEARCH=win64 \
    WINEDEBUG=-all \
        wineboot --init
}

install_launchers() {
    print_status "Installation des commandes Linux"

    install -Dm755 \
        "$project_directory/bin/ugreen-nas" \
        "$user_bin_directory/ugreen-nas"

    install -Dm755 \
        "$project_directory/bin/ugreen-nas-uninstall" \
        "$user_bin_directory/ugreen-nas-uninstall"
}

create_desktop_entry() {
    print_status "Ajout de UGREEN NAS au menu des applications"

    mkdir -p "$applications_directory"

    cat > "$desktop_entry" <<DESKTOP
[Desktop Entry]
Type=Application
Version=1.0
Name=UGREEN NAS
Comment=Client UGREEN NAS exécuté avec Wine
Exec=$user_bin_directory/ugreen-nas
Icon=network-server
Terminal=false
Categories=Network;Utility;
StartupNotify=true
DESKTOP

    chmod 644 "$desktop_entry"

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$applications_directory" >/dev/null 2>&1 || true
    fi
}

write_installation_metadata() {
    local installer_path="$1"
    local metadata_file="$installation_directory/installation-info.txt"

    {
        printf 'installer_filename=%s\n' "$(basename "$installer_path")"
        printf 'installer_sha256=%s\n' "$(sha256sum "$installer_path" | awk '{print $1}')"
        printf 'installed_at=%s\n' "$(date --iso-8601=seconds)"
    } > "$metadata_file"
}

main() {
    require_command 7z
    require_command wine
    require_command wineboot
    require_command sha256sum

    local installer_path

    installer_path="$(select_installer "$@")"

    [[ -n "$installer_path" ]] ||
        fail "Aucun installateur n’a été sélectionné."

    installer_path="$(realpath "$installer_path")"

    validate_installer "$installer_path"

    temporary_directory="$(mktemp -d)"

    extract_application "$installer_path"
    initialize_wine_prefix
    install_launchers
    create_desktop_entry
    write_installation_metadata "$installer_path"

    printf '\nInstallation terminée avec succès.\n'
    printf 'Tu peux maintenant lancer UGREEN NAS depuis le menu KDE ou avec :\n\n'
    printf '  ugreen-nas\n\n'
}

main "$@"
