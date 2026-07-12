# UGREEN NAS for Linux

An unofficial open-source installer and launcher for running the official UGREEN NAS Windows desktop client on Linux through Wine.

The project provides:

- a graphical Flutter installer;
- automatic extraction of the official Windows installer;
- an isolated Wine environment;
- a Linux launcher;
- desktop menu integration for KDE and other Linux environments.

The user must provide the official UGREEN NAS Windows installer.

> [!IMPORTANT]
> This project is not affiliated with, endorsed by, or maintained by UGREEN.
> No proprietary UGREEN application files are included or redistributed.

## Current status

The project is an early proof of concept, but the main UGREEN NAS client is already functional on Fedora KDE.

### Working

- Graphical Flutter installer
- Selection of the official Windows `.exe`
- Automatic NSIS extraction
- Automatic extraction of the embedded 64-bit client
- Isolated Wine prefix creation
- UGREEN account login
- NAS discovery and connection
- File browsing
- File downloads
- Linux application menu integration
- Launching from KDE without a terminal
- Runtime logs for troubleshooting

### Known limitations

- The built-in video player currently plays audio, but its video output may remain black under Wine.
- Upload and synchronization features require more testing.
- Fedora KDE is currently the primary tested environment.
- Debian, Ubuntu, Arch Linux, and other distributions have not yet been fully validated.

## How it works

The official Windows installer contains an Electron-based desktop client.

This project:

1. validates the installer selected by the user;
2. extracts the NSIS package using 7-Zip;
3. locates and extracts the embedded `app-64.7z` archive;
4. creates an isolated 64-bit Wine prefix;
5. installs a Linux launcher;
6. adds UGREEN NAS to the desktop application menu.

The Electron application requires this environment variable under Wine:

```bash
ELECTRON_NO_ATTACH_CONSOLE=1
```

The launcher also provides valid standard input, output, and error descriptors. This prevents an Electron `EBADF` startup error when UGREEN NAS is launched from a graphical application menu.

## Requirements

The current prototype requires:

- Bash
- Wine
- Wineboot
- 7-Zip
- SHA-256 utilities
- Flutter, only when building the graphical interface from source

### Fedora

```bash
sudo dnf install \
  wine \
  p7zip \
  p7zip-plugins \
  kdialog
```

## Command-line installation

Clone the repository:

```bash
git clone https://github.com/TheZupZup/ugreen-nas-linux.git
cd ugreen-nas-linux
```

Run the installer with the official UGREEN NAS Windows installer:

```bash
./install.sh /path/to/UGREEN_NAS.exe
```

When KDE's `kdialog` is installed, you can also open a graphical file selector:

```bash
./install.sh
```

After installation, launch the client with:

```bash
ugreen-nas
```

UGREEN NAS should also appear in the Linux application menu.

## Graphical installer

The graphical interface is built with Flutter.

Run it from the repository:

```bash
cd gui
flutter pub get
flutter run -d linux
```

Then:

1. click **Browse**;
2. select the official UGREEN NAS Windows installer;
3. click **Install**;
4. wait for the installation to complete;
5. launch UGREEN NAS from the Linux application menu.

## Installation locations

Application files and Wine prefix:

```text
~/.local/share/ugreen-nas-linux/
```

Linux commands:

```text
~/.local/bin/ugreen-nas
~/.local/bin/ugreen-nas-uninstall
```

Desktop entry:

```text
~/.local/share/applications/io.github.thezupzup.UGREENNAS.desktop
```

Runtime log:

```text
~/.local/state/ugreen-nas-linux/ugreen-nas.log
```

## Uninstallation

Remove the application and its Wine prefix:

```bash
ugreen-nas-uninstall
```

Remove the application while preserving the Wine prefix:

```bash
ugreen-nas-uninstall --keep-prefix
```

## Project structure

```text
.
├── README.md
├── LICENSE
├── install.sh
├── bin/
│   ├── ugreen-nas
│   └── ugreen-nas-uninstall
└── gui/
    └── lib/
        └── features/
            └── installer/
                ├── application/
                ├── domain/
                ├── infrastructure/
                └── presentation/
```

The Bash scripts handle:

- installer extraction;
- Wine configuration;
- Linux installation;
- desktop integration;
- launching and uninstallation.

The Flutter application handles:

- file selection;
- installation progress;
- user-facing status messages;
- installation errors.

## Contributing

Contributions and compatibility reports are welcome.

Useful areas include:

- testing on additional Linux distributions;
- improving Wine compatibility;
- investigating the black video output;
- testing uploads and synchronization;
- creating `.deb`, `.rpm`, AppImage, and Flatpak packages;
- improving accessibility and translations;
- adding automated tests.

Please do not commit or redistribute proprietary UGREEN files, including:

- `.exe` files;
- `.dll` files;
- extracted application archives;
- `app.asar`;
- UGREEN logos or other trademarked assets.

## Tested configuration

The proof of concept has been tested with:

- Fedora KDE
- Wine Staging
- Intel and AMD graphics
- UGREEN NAS desktop client 1.17.0.2047

Successful login, NAS browsing, and file downloads have been confirmed on two independent Fedora installations.

## License

The open-source installer, launcher, and graphical interface are licensed under the Mozilla Public License 2.0.

UGREEN NAS, its application files, trademarks, and related assets remain the property of their respective owner.
