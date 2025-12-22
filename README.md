# SFDItemTool

A light weight and simple tool that can read [Superfighters Deluxe's](https://store.steampowered.com/app/855860/Superfighters_Deluxe/) `.item` files.

> [!NOTE]
> Superfighters Deluxe's `.item` files are not efficiently stored, they many completely transparent texture data. This results in a heavy size reduction when those textures are skipped, with SFD's 213 default items the total size is decreased by **76%** (`5855428 bytes` or `~5.58MB` down to `1409159 bytes` or `~1.34MB`).
>
> This tool will automatically detect and skip completely transparent textures.

### Usage

1. Download the [latest release](https://github.com/Liokindy/SFDItemTool/releases).

2. Use a terminal and run `SFDItemTool.exe`, or use a pre-created `.bat` file (only in Windows).

### Options

```
	-input [path]
```

The path of the input folder. Defaults to `Input`.

```
	-output [path]
```

The path of the output folder. Defaults to `Output`.

```
	-to [item|folder|pass]
```

What action to do with files in the input folder, and then use the output folder as a destination.
- `item`, assumes files in the input folder are all `.item` files. Exports them to folders that include `.png` files and a `.ini` file containing properties of the item.
- `folder`, assumes files in the input folder are all folders with `.png` files and a valid `.ini` file. Exports them to `.item` files.
- `pass`, assumes files in the input folder are all `.item` files. Exports them back to `.item` files.
