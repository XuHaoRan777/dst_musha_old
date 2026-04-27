# modinfo source

`modinfo.lua` is the file loaded by Don't Starve Together. Keep it as a generated single file for runtime compatibility.

Maintain configuration definitions here instead:

- `meta.lua` contains top-level mod metadata.
- `meta.lua` also contains shared helpers such as `T(zh, en)`, `ConfigOption`, and common option tables.
- `options/*.lua` contains grouped `configuration_options` entries.
- `tools/build_modinfo.ps1` joins these files back into root `modinfo.lua`.

Localization:

- The generated config page follows the DST client `locale`.
- Chinese clients (`zh`, `zhr`, `zht`) use the Chinese text passed to `T`.
- Other clients use the English text.
- Keep config `name`, `data`, and `default` values stable; only localize display text such as `label`, `hover`, and `description`.

Build:

```powershell
.\tools\build_modinfo.ps1
```

Check:

```powershell
.\tools\build_modinfo.ps1 -Check
```
