# Creating a layout for your language

[Русский](custom-layouts.ru.md) · [Project installation](../README.md)

Start with Plasma Keyboard Extended already installed. Letter and geometry changes only require QML edits. Recompile C++ when changing event handling or the shortcut keycode table.

## 1. Find the directory and locale

The commands below use **Bash**. If you use Fish, first run `bash`. Run as your regular user, without sudo, from the repository directory.

```bash
layouts="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/keyboard/layouts"
ls "$layouts"
```

Locale directories include `es_ES`, `de_DE`, `fr_FR` and `uk_UA`. Use a real locale supported by Qt, not an arbitrary name such as `my_keyboard`. `fallback` is shared: editing it affects every locale that refers to it.

`main.qml` defines the main layer and `symbols.qml` the symbols layer. `.fallback` files select a shared layer. Copying the main layer does not translate the other layers.

## 2. Create a backed-up starting point

This example creates a starting point for **Spanish (`es_ES`)**, keeping function keys and modifiers. It is not a complete Spanish layout.

```bash
target_locale=es_ES
backup="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/keyboard/custom-backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$layouts/$target_locale"
cp -a "$layouts/$target_locale" "$backup/"
cp "$layouts/fallback/main.qml" "$layouts/$target_locale/main.qml"
if [ -f "$layouts/$target_locale/main.fallback" ]; then
  mv "$layouts/$target_locale/main.fallback" "$backup/main.fallback"
fi
kate "$layouts/$target_locale/main.qml"
```

Use another text editor if preferred. Save as **UTF-8** and leave `/usr/share` files unchanged. For an existing complex-language layout, inspect its original `main.qml` first: replacing it with the English starting point can remove required input processing.

## 3. Edit letters and their order

```qml
PcKey { text: "a"; key: 65; weight: 100 }
```

`text` supplies the label and typed text; `key` is a **Qt key code**, not a Linux code; `weight` is relative width. Button order within `KeyboardRow` determines position.

For example, Spanish Ñ occupies the US semicolon position. Replace the semicolon button with:

```qml
PcKey { text: "ñ"; key: Qt.Key_Semicolon; weight: 100 }
```

An ordinary tap types `ñ`; a shortcut uses the supported physical `KEY_SEMICOLON` position. Select the corresponding Spanish system keyboard layout for the expected shortcut behavior. Switching the on-screen language does not switch the system layout automatically.

When rearranging letters, consider the label, physical position and system layout together. Changing only labels does not guarantee matching shortcuts.

Keep `PcKey`, `ModifierKey`, `latchedModifiers` and `onClicked`: they implement one-shot Ctrl/Alt/Meta. Keep `ChangeLanguageKey` for language switching.

## 4. Keep staggered rows aligned

Normal letters use `weight: 100`. Each current letter row totals **1500**:

| Row | Initial offset | Remaining buttons |
| --- | --- | --- |
| Top | Tab: 150 | letters/symbols and Backspace |
| Middle | FillerKey: 175 | letters/symbols and Enter |
| Bottom | Shift: 225 | letters/symbols, spacing and Up |

```qml
FillerKey { weight: 175 }
```

This creates an empty gap. If you add a 100-weight letter, remove 100 from spacing or special-key widths in that row. Equal total weights keep letters equally wide. Offsets 150 → 175 → 225 give the Q → A → Z stagger. For a different keyboard shape, choose different offsets but keep equal overall row widths.

## 5. Enable and verify the language

```bash
bash scripts/activate.sh
```

Enable the locale in the on-screen keyboard's language settings, then select it with the language key. If it is missing, check the locale directory name and `main.qml`, then restart the keyboard. Hardware keyboard layouts and the on-screen language list are separate settings.

Check letters, Shift, Space, Backspace, Enter, symbols, Ctrl+C/V and Ctrl+arrows in an editor. Check switching back to English/Russian. For QML errors:

```bash
journalctl --user --since "5 minutes ago" --no-pager | grep plasma-keyboard
```

## 6. When a new letter's shortcut fails

The patch maps specified Qt codes: Latin letters, Russian letters, digits and listed special keys. A new Unicode code such as `0x00D1` is **not automatically added** to the physical key table. Typing can work while shortcuts fail.

Either use an appropriate supported physical-position Qt code, as with Ñ above, or extend `desktopScanCode()` in the C++ patch. Linux codes come from `linux/input-event-codes.h`; do not use them directly as QML `key` values.

For C++ changes, modify v6.7.5 sources, regenerate `patches/desktop-shortcuts.patch` against clean upstream sources, and build in a new `PLASMA_DESKTOP_BUILD_DIR` as described in the update guide. Editing an already patched `build/` tree does not update the distributed patch.

Chinese/Japanese input, composition, dead keys and special casing need more than replacing letters. `PcKey` sends direct text and uses ordinary `toUpperCase()`; it does not add language engines, dictionaries or composition rules. Preserve the stock input method and adapt those languages separately.

## 7. Preserve your work across installations

The installer recopies stock layouts and generates English/Russian. It backs up custom edits but **does not import them automatically**. Save your locale separately, for example outside the repository:

```bash
saved_layouts="$HOME/Documents/plasma-keyboard-custom-layouts"
mkdir -p "$saved_layouts"
cp -a "$layouts/$target_locale" "$saved_layouts/"
```

After updating and running `install.sh`, restore it before `activate.sh`:

```bash
cp -a "$saved_layouts/$target_locale/." "$layouts/$target_locale/"
if [ -f "$layouts/$target_locale/main.fallback" ]; then
  mv "$layouts/$target_locale/main.fallback" "$backup/restored-main.fallback"
fi
bash scripts/activate.sh
```

These commands assume the earlier variables are still set; define them again in a new terminal. For permanent changes to the distributed English/Russian layouts, edit `scripts/generate_layouts.py`: installation replaces generated files. Adding another locale to the generator's list also requires adapting its punctuation and row-width conditions, which currently assume English and Russian.

## Further information

The [Qt Virtual Keyboard overview](https://doc.qt.io/qt-6/qtvirtualkeyboard-overview.html) describes language layer files and input methods. This project's `PcKey` and C++ patch additionally determine its behavior.
