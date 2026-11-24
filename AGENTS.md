# AGENTS.md

## What this is

A World of Warcraft **1.12 (vanilla)** UI replacement — the "ClassicAPI Edition" fork
(brues-code/pfUI), not upstream shagu/pfUI. Working copy origin is `Rothiss/pfUI`,
merging upstream from `brues-code/master`.

- Lua **5.0** VM (the 1.12 client). The **ClassicAPI** DLL backports Lua 5.1 syntax
  (`#`, `%`, long brackets, string methods) and ~950 modern APIs (`C_PlayerCache`,
  `C_Spell`, `C_Timer`, `C_ActionBar`, `EventRegistry`, …).
- **No build/test/lint tooling.** Everything runs in-game; there is no headless check.
  `## Version: @project-version@` in the .toc is substituted only by the release
  workflow (source checkouts report `dev`).

## Required DLLs (not bundled)

- **ClassicAPI** — required. `API_Check.lua` pins `PFUI_CLASSIC_API_MIN` (format
  `X*10000 + Y*100 + Z`; e.g. `11901` = v1.19.1). Verify the running build with
  `/pfdll` or `/classicapi`.
- **Nampower** — required (GCD indicator, spell queue, `GetSpellIdCooldown`).
- SuperWoW, UnitXP_SP3 — optional.

## TOC selection & load order

ClassicAPI's multi-flavor loader picks the real TOC; the three files are:
- `pfUI_ClassicAPI.toc` — non-Turtle clients (main entry).
- `pfUI_Turtle.toc` — Turtle WoW (swaps `init\stock.xml` for `init\turtle.xml`).
- `pfUI.toc` — loads only when the DLL is **missing** (runs `API_Check.lua` to show the popup).

Order: `API_Check.lua` → `pfUI.lua` → `env\locales_*` / `env\combatlog_*` →
`init\env.xml` → `init\stock.xml` → `init\api.xml` → `init\libs.xml` →
`init\skins.xml` → `init\modules.xml`.

## Environment & module pattern (read before editing)

Every Lua file except `pfUI.lua` starts with `setfenv(1, pfUI:GetEnvironment())`.

- `pfUI.env.__index = getfenv(0)` — unknown names fall through to globals.
- `pfUI.api.X = function…` uses an `__newindex` metatable that also sets `pfUI.env.X`,
  so module files call it as a bare global.
- In module files: `C` = config (`pfUI_config`), `T` = translation, `L` = locale.
- Register with `pfUI:RegisterModule(name, func)` / `pfUI:RegisterSkin(name, func)`.
  A legacy `(name, version_string, func)` order is normalized by `BackwardsCompatRegister`.
- Module/skin bodies load via `setfenv` + `securecallfunction` — one file's error
  doesn't stop later files.
- `pfUI.events` is an `EventRegistry` mixin (ClassicAPI); use it for event callbacks.

## Cooldowns (ClassicAPI-specific, easy to misdiagnose)

- Cooldowns draw on ClassicAPI's **`Cooldown` frame type** (C++ backport of 4.3.4's
  `CGCooldown`), not the vanilla `CooldownFrameTemplate` Model. The sweep is
  engine-ticked; numbers are gated by the `countdownForCooldowns` CVar.
- `C.cooldown.threshold` (default `"2"`) = GUI "Hide Numbers On Spell Cooldowns Up To
  (Seconds)"; it hides only **numbers**, never the sweep.
- `GetActionCooldown(slot)` resolves the slot through the macro `#showtooltip` cache;
  `C_Spell.GetSpellCooldown(spellID)` and the spellbook query the spell directly.

## Known compatibility footgun

Third-party macro addons (e.g. **SuperMacro**) conflict with ClassicAPI's macro-slot
resolution. Symptoms: action-bar cooldowns never show and buttons render "partially
empty" after `/reload`, while the spellbook is unaffected. This is a
SuperMacro-vs-ClassicAPI conflict, not a pfUI bug — don't patch pfUI; disable the
macro addon.

## In-game debugging

- `/pfdll` / `/classicapi` — DLL versions.
- `/etrace` — event trace (did an event fire?).
- `/dump <expr>` — inspect a value/table.
- `/luaerrors` — Lua error window (stack + locals).
