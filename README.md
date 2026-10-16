# herdr-tab-symbols-plugin

A [Herdr](https://herdr.dev) plugin that puts a symbol before the label of the first five tabs
in each workspace:

| Tab | Symbol |
| --- | --- |
| 1 | ★ |
| 2 | ♠ |
| 3 | ♣ |
| 4 | ♦ |
| 5 | ❤ |

My keyboard has five macro keys, M1 to M5. The macro keys have custom keycaps that show these
symbols, from M1 to M5: ★ ♠ ♣ ♦ ❤. That is the reason for these symbols and their order. When
the macro keys switch to tabs 1 to 5, the tab bar shows which key opens which tab:

```text
★ api   ♠ tests   ♣ 3   ♦ docs   ❤ 5   6
```

## How it works

Herdr plugins cannot draw on the tab bar. A tab has one label, so the plugin adds the symbol to
that label with `herdr tab rename`. The symbol is part of the label: `herdr tab list` and the
rename box show it.

The plugin runs `sync.sh` when Herdr starts and after each `tab.created`, `tab.closed`,
`tab.moved` and `tab.renamed` event. The script does these steps for each tab in each
workspace:

1. It removes a symbol and its space from the start of the label, if there is one.
2. It adds the correct symbol for the tab position, if the position is 1 to 5.
3. It renames the tab only if the label changes.

Step 3 stops a loop: a rename from the plugin causes one more `tab.renamed` event, but the
next run of the script finds nothing to change.

A tab with no name shows its position, for example `3`. After the plugin renames it to `♣ 3`,
the number is fixed text. If the label without its symbol is only digits, the script replaces
it with the current position. Thus an unnamed tab still shows its position after a move.

## Requirements

- Herdr 0.9.5 or later
- `bash`
- `jq`

## Install

Install from GitHub:

```bash
herdr plugin install jackcannon/herdr-tab-symbols-plugin
```

Or link a local clone:

```bash
herdr plugin link /path/to/herdr-tab-symbols-plugin
herdr plugin action invoke jackcannon.tab-symbols.sync
```

The startup hook does not run when you link a plugin. Run the `sync` action once, or open or
close a tab.

## Switch tabs with the macro keys

Add a second binding to `switch_tab` in `~/.config/herdr/config.toml`:

```toml
[keys]
switch_tab = ["prefix+1..9", "ctrl+alt+1..9"]
```

Then set the macro keys in the keyboard software:

| Key | Sends |
| --- | --- |
| ★ | `ctrl+alt+1` |
| ♠ | `ctrl+alt+2` |
| ♣ | `ctrl+alt+3` |
| ♦ | `ctrl+alt+4` |
| ❤ | `ctrl+alt+5` |

Run `herdr server reload-config` to apply the change. Herdr accepts only `1..9` as a key range,
so `ctrl+alt+0..9` does not work.

## Other Recommended Settings

These settings are not part of the plugin, but they work well with it. Add them to
`~/.config/herdr/config.toml`, then run `herdr server reload-config` to apply them.

### Window title

By default, Herdr sets the title of the terminal window to `{hostname}: {workspace}`. In a
terminal with tabs, such as Ghostty, the hostname makes the Herdr tab difficult to find. Set
the title to start with `herdr`:

```toml
[ui]
window_title = "herdr: {workspace}"
```

The title can also use these tokens: `{hostname}`, `{tab}`, `{pane}` and `{terminal_title}`.
An empty value makes Herdr leave the title alone.

### Move tabs

The symbols follow the tab position. These keys move the current tab one position to the left
or to the right, so you can put a tab on the macro key that you want. Herdr does not bind
them by default.

```toml
[keys]
move_tab_previous = "alt+shift+left"
move_tab_next = "alt+shift+right"
```

### Switch workspaces and agents by number

These keys go to a workspace or to an agent row by its number. Herdr does not bind them by
default.

```toml
[keys]
switch_workspace = "prefix+shift+1..9"
focus_agent = "prefix+alt+1..9"
```

### Agent notifications

Herdr sends a macOS notification when an agent finishes or needs input. Herdr does not send
notifications by default.

```toml
[ui.toast]
delivery = "system"
```

### Agent sidebar

The first setting puts the agents that need you at the top of the sidebar. The second setting
gives each agent state its own symbol, not only its own colour.

```toml
[ui]
agent_panel_sort = "priority"
status_indicators = "symbols"
```

### Clock in the tab bar

This setting shows the time at the right end of the tab bar.

```toml
[ui]
tab_bar_right = [
  { type = "datetime", format = "%H:%M" },
]
```

### Pane history

Herdr keeps the screen history of each pane after a server restart. This setting is
experimental.

```toml
[experimental]
pane_history = true
```

### Full config

This is my complete `~/.config/herdr/config.toml`. It has the macro key binding and all the
settings in this section. Copy it to a new computer in one step.

```toml
onboarding = false

[theme]
name = "vesper"
auto_switch = false

[ui]
window_title = "herdr: {workspace}"
agent_panel_sort = "priority"
status_indicators = "symbols"
tab_bar_right = [
  { type = "datetime", format = "%H:%M" },
]

[ui.toast]
delivery = "system"

[keys]
switch_tab = ["prefix+1..9", "ctrl+alt+1..9"]
move_tab_previous = "alt+shift+left"
move_tab_next = "alt+shift+right"
switch_workspace = "prefix+shift+1..9"
focus_agent = "prefix+alt+1..9"

[experimental]
pane_history = true
```

## Uninstall

```bash
herdr plugin uninstall jackcannon.tab-symbols
```

The symbols stay in the tab labels after you uninstall the plugin. Rename the tabs to remove
them. The Herdr API cannot clear a tab name, so a tab that had no name keeps its fixed number.
