Unicode sheets referenced in this file can be found here: https://www.unicode.org/charts/

## [3.0.0] - ??/??/2026

### Added

- Added ? unicode character sheets:
    - Cyrillic (All but combination glyphs)
    - Cyrillic Extended-B (All but combination glyphs)
    - Cyrillic Extended-C (All)
    - Cyrillic Extended-D (All but `1E08F`)
    - Miscellaneous Symbols (some idk how many)
    - Miscellaneous Symbols and Arrows (ditto)
    - Musical Symbols (ditto)
    - Dingbats (ditto)
- Added a new `<e=String/>` tag to dispatch "event" signals from typed text.
    - It's a self-closing tag that takes a string as an input. (No `"` or `'` required)
    - The event string is dispatched via the `eventCallback` function, what you do afterwards is up to you!
- Added new font data fields:
    - `shakeFramerate` - Controls how often shake offsets are applied. (Default: 16)
    - `shakeSizeX` and `shakeSizeY` - Controls how large the shake offset is in pixels. (Default: 4 and 4)
    - `waveSize` - Controls how large the wave effect is in pixels. (Default: 16)
    - `waveSpeed` - Controls how fast the wave effect is. (Default: 4)
- Added support for `.txt` files in place of `.xml` for letter spritesheets. (Packer atlas instead of Sparrow atlas)
- Added a `pixel-example` font to show pixel font and packer atlas capability.

### Changed

- **[BREAKING CHANGE]** Replaced the `font` in the constructor for `BAlphabet` and `BAlphabetTyped` to `config`.
    - `config` contains `font`, `baseColor`, and `alignment`.
    - New usage is as follows: `new BAlphabet(0, 0, "text", { font: "default", baseColor: "FFFFFF", alignment: "left" });`.
    - Adding new parameters will be easier this way.
- Alphabet Debug now supports Middle Mouse button for camera movement and Mouse Wheel for zooming.

## [2.0.0] - 26/03/2026

### Added

- 2(?) unicode character sheets: 
    - Hiragana: All. (Except `3099-309C`)
    - Miscellaneous Technical: `2326` & `2327`, `232B`, `23E9-23EF`, and `23F4-23FE`.
- Added a new `<m>` tag to force monospace on characters inside the tag.
- Added a new `setScrollFactor(factorX:Float, ?factorY:Float)` function to set the scroll factor for the object.
    - The regular `scrollFactor.set(x, y)` does not work due to FunkinGroup.
- Added an `antialiasing` field to fonts. The default value is `true`.

### Changed

- The text now uses the new `FunkinGroup` class as its base, allowing for better scaling and now; rotation!
- The `setScale()` function is deprecated, please use the built-in scale field instead.
    - The function still works for the time being for backwards compatibility.

## [1.0.0] - 23/02/2026

Initial Release

### Added

- 7 unicode character sheets; Latin, Latin-1 Supplement, Arrows, Mathematical Operators, Katakana, Specials, and Symbols for Legacy Computing.
    - Latin: All.
    - Latin-1 Supplement: All.
    - Arrows: `2190-2199`, `21A9 & 21AA`, `21B0-21B3`, `21B6 & 21B7`, `21BA & 21BB`, and `21E6-21E9`.
    - Mathematical Operators: `2205-2207`, `2211`, `2218-221E`, `2227-222A`, `2223-223A`, `2260-2269`, `2295-229D`, and `22EE-22F1`.
    - Katakana: All.
    - Specials: FFFD.
    - Symbols for Legacy Computing: 1FBF0-1FBF9.
- 8 tags that have their own special effect:
    - Bold `<b>`: Changes the letter graphics to one with a black outline. If no bold variant exists, the default one will be used instead.
        - `<b>Bold Text</b>`.
    - Italic `<i>`: Skews the letters to the right slightly. Note that letters may end up overlapping each other slightly.
        - `<i>Italic Text</i>`.
    - Color `<c>`: Colors the letters to the given hex color, without the `#`.
        - `<c=00FF00>Green Text</c>`.
    - Alpha `<a>`: Changes the alpha of letters to the given value.
        - `<a=0.75>This text is slightly transparent</a>`.
    - Scale `<s>`: Scales the letters relative to the parent text's scale. If the text's scale is 0.5, and the given value is 0.5, then the letter's effective scale becomes 0.25.
        - `<s=0.5>This text is half the scale</s> This part however, isn't.`
    - Wavy `<W>`: The letters will move in a sine pattern, with each letters movement offset from the previous.
        - `<W>Woo, waving!</W>`
    - Shaky `<S>`: The letters will move a random short distance, then return back to the initial position, repeating.
        - `<S>Ooh, scary!</S>`
    - Delay `<d>`: Delays a typed text for the given value in seconds.
        - `Hmm,<d=0.25/> I'll have a uhh,<d=0.5/> I'm not sure...`
- Support for HTML Escape codes; either `&#65;` (decimal) or `&#x41;` (hexadecimal) will work.
- Support for adding custom character sheets; read the `README` for more on that.
- Support for adding custom fonts; read the `README` for more on that.