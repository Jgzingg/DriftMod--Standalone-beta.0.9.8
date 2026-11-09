# DriftMod Standalone v0.9.8 Beta

DriftMod is a Lua resource for FiveM that lets drivers change vehicle handling in-game. The menu lets you tune traction and steering or choose a preset. The core drift controls work without ESX or QBCore.

> [!NOTE]
> This public beta is a prototype preserved as a technical reference.

## Install on a FiveM server

1. Download or clone this repository.
2. Copy the inner [`DriftMod`](DriftMod/) folder into your server's `resources` directory. The resulting path should be `resources/DriftMod/fxmanifest.lua`.
3. Add the following line to `server.cfg` and start the server.

```cfg
ensure DriftMod
```

If the server is already running, use `refresh` and then `ensure DriftMod` in the server console.

## Default controls

Get in the driver's seat to use the controls.

| Key | Action |
| --- | --- |
| `M` | Open the drift menu. |
| `K` | Toggle drift mode with the menu closed. |
| Left `Shift` | Hold for temporary drift mode while the toggle is off. |

## Configuration

Edit [`DriftMod/config.lua`](DriftMod/config.lua) to change the control IDs, default traction and steering values, presets, or vehicle allowlist. See the [FiveM controls reference](https://docs.fivem.net/docs/game-references/controls/) for input IDs.

The client records the vehicle's original handling when you enter and uses those values when restoring the handling. See [`DriftMod/client.lua`](DriftMod/client.lua) for the implementation.
