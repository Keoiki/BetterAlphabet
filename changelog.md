Unicode sheets referenced in this file can be found here: https://www.unicode.org/charts/

## [1.0.0] - ??/02/2026

Initial Release

## Added

- 6 unicode character sheets; Latin, Latin-1 Supplement, Arrows, Katakana, Specials, and Symbols for Legacy Computing.
    - Latin: All.
    - Latin-1 Supplement: All.
    - Arrows: 2190-2199, 21A9 & 21AA, 21B0-21B3, 21B6 & 21B7, 21BA & 21BB and 21E6-21E9.
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