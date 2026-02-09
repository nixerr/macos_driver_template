# macOS Driver Template

A minimal template for developing macOS Kernel Extensions (KEXTs). This project provides the boilerplate structure, build system, and configuration needed to get started with kernel-level driver development on macOS.

## Overview

This template produces a loadable kernel extension (`inspector.kext`) that demonstrates the standard KEXT lifecycle — module load and unload. It is intended as a starting point to be extended with actual driver functionality.

## Project Structure

```
.
├── Info.plist       # KEXT bundle metadata and dependencies
├── Makefile         # Build, code-sign, and install rules
├── kernel/
│   ├── main.c       # Driver entry/exit implementation
│   └── mod.h        # KEXT module declarations
└── build/           # Output directory (generated)
```

## Requirements

- macOS 14.5 (Sonoma) or later
- Xcode Command Line Tools (provides `clang`, `codesign`, `xcrun`)
- Apple Silicon (arm64e) Mac

## Building

```sh
make
```

This will:

1. Compile the kernel source files
2. Link against the Kernel and IOKit frameworks
3. Package the result into `build/inspector.kext`
4. Code-sign the KEXT bundle
5. Set ownership to `root:wheel` (requires `sudo`)

To clean build artifacts:

```sh
make clean
```

## Loading and Unloading

Load the extension:

```sh
sudo kextload build/inspector.kext
```

Unload the extension:

```sh
sudo kextunload build/inspector.kext
```

Check kernel log for output:

```sh
sudo dmesg | grep inspector
```

## Customization

To use this template for your own driver:

1. Rename the `inspector` references in `main.c`, `mod.h`, `Makefile`, and `Info.plist` to your driver name
2. Update the bundle identifier (`com.inspector`) in `Info.plist` and `Makefile`
3. Add your driver logic to the `_start` and `_stop` functions in `main.c`
