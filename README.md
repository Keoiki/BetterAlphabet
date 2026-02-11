# Better Alphabet
A data driven text system for vanilla Friday Night Funkin. (i.e. V-Slice)

**Current FNF Version:** `0.8.1-develop`

Better Alphabet (or BAlphabet) is a Friday Night Funkin dependency mod which allows other modders to easily add cool looking text to whereever they want. It also offers customization of the written text and new character sheets can be added by modders easily.

> [!CAUTION]
> DO NOT edit this mod locally as it is a dependency when working on mod specific stuff, this mod is to be left untouched after it's downloaded. If you have suggestions on what should be added or changed, open an issue instead.

## Implementing in your own mod

Once the mod is in your mods folder, the only thing needed is:
```haxe
import balphabet.BAlphabet;
```
in whatever file you want to use it in, that's that, now it's ready to be used.

```haxe
var testText:BAlphabet = new BAlphabet(FlxG.width / 2, 50, "Hello!");
testText.alignment = "center";
testText.setScale(0.75);
add(testText);
```

The example above will create a new text object at the given position and with:
- the text "Hello!",
- with the alignment set to "center" so the text isn't offset from the middle of the screen,
- and lastly scaled down a bit, since the characters can be quite large by default.

> [!IMPORTANT]
> Do not try to set the scale of the text with `text.scale.set(x, y)`, this will NOT WORK properly and will lead to letter misalignment. Similarly do not try to set the `angle` of the text, this will only rotate each letter around themselves and not the whole text object like you might imagine.

But what if you wanted a bit more, like the customization I talked about earlier? The strings passed in support various tags, written as `<tag>Text</tag>`. The supported tags are as follows:
- `<b>` for **Bold**, this causes letters to change their graphic to a bold one, granting them an outline. If no bold graphic is found the default one is used instead.
- `<i>` for *Italics*, causing the characters to *skew a little bit*, making them Italic, wow. This may cause characters to overlap slightly however.
- `<c>` for Color, this tag lets you color any area of text however you want. The usage is `<c=00FF00>Green Text</c>` for green colored text for example, replacing the `00FF00` with the hex color of your choosing. (Do NOT include the `#`)
- `<a>` for Alpha, which allows you to change the opacity of the letters within the tag. `<a=0.5>This text is half visible</a> This half however, isn't.`
- `<s>` for SCALE, allowing you to scale individual letters as you want. This stacks with the text object's own scale, meaning a scale of `0.5` on a text object already at `0.5` scale makes any letter inside said tag `0.25` the size of the default letter size.
- `<W>` for Wavy, this one causes the letters to move in a sine wave pattern, with each letter moving slightly behind the previous one.
- `<S>` for Shake, which causes the letters to tremble from their initial position briefly, before moving back, repeating ad infinitum.

Another thing that is supported is HTML Escape Codes, letting you type characters without having to mindlessly copy paste them as long as you remember their (hexa)decimal codes. Just put them inside the string you're passing and they'll be parsed before any tags are.
- Both `&#65;` and `&#x41;` work for getting the `A` character as an example.

### Typed Text

```haxe
import balphabet.BAlphabetTyped;
```

This class allows you to make text that appears over a period of time, instead of instantly. The constructor for the class is the exact same, from there, there are a couple of variables that might be of interest:
- `speed:Float`, controls how fast the typing speed is, with the default of `0.05`,
- `letterStep:Int`, controls how many letters are shown each time they're meant to be, with the default of `1`,
- `finishedText:Bool`, for reading if the typing is done yet,
- `letterCallback:Void`, for running a function each time letters are shown, useful for sounds,
- and `finishCallback:Void`, for running a function once the text is done typing.

The function `startTyping() / start()` is used to start the typing effect, as it doesn't begin automatically, and `finishText() / finish()` can be used for finishing the text before it reaches the end itself.

Typed text also supports one extra tag currently:
- `<d>` for Delay, delaying the typing effect for the given amount in seconds. `Hmm,<d=0.25/> I'll have a uhh,<d=0.5/> I'm not sure...`
  - This tag is a self-closing one, meaning it has no ending partner unlike all the other tags.

## Implementing custom character sheets

Implementing custom characters is easy. However first you must understand the format on how the characters are named. In the `.xml` you'll get when exporting the image, each name is as follows: `decimal-hex`, for example `65-0041` for `A`.
- The hex is not required, as the mod only checks for `decimal-` when adding the animation.

With that out of the way, let's continue with the actual implementation:
- Place your image and xml into `images/balphabet/FONTNAME/TYPE/` of your mod, with `TYPE` being either `regular` or `bold`.
  - Let `FONTNAME` be `default` for this example.
- Create a `.txt` file in `data/balphabet/FONTNAME/` of your mod. The name should be the same as the `.png` and `.xml` from the previous step.
- Within the text file, each line will act as an entry for a character, with the following fields in the format `field=value`, separated by spaces:
  - `char`, being the decimal number of the character, not the hex,
  - `offsetX`, the offset in the X axis for the character (OPTIONAL)
  - `offsetY`, the offset in the Y axis for the character (OPTIONAL, but highly suggested)
  - `colored`, is this character colored? If `true` or `1`, color tags will not affect them.

An example is shown below, being the lone character from the `Special` sheet.
```
char=65533 offsetY=-8
```

## Implementing custom fonts

Do you not want to use the letter assets that come with the mod? Oh... well good news! It's possible to create custom fonts in order to not have the need to replace the default characters, because that would suck for compatibility between other mods.
- Create a folder in `data/balphabet/FONTNAME` of your mod, with `FONTNAME` being the name you want to use.
- Inside that folder, create a `.json` file with the name of the folder. Within that file, all 6 of the following fields must be present, or else a few errors might show up at your doorstep:
```json 
{
    "size": 54, // The regular letter height
    "sizeBold": 60, // Ditto, for bold
    "padding": 2, // The horizontal spacing between each letter
    "paddingBold": -6, // Ditto, for bold
    "lineHeight": 85, // Vertical spacing between each new line
    "spaceWidth": 28 // The width of a space character
}
```
- The values seen above are from the `default` font.
- Then, adding the letters is the same as in the above section, so go follow that next.
- In the end, your folder `data/balphabet/FONTNAME` should have `FONTNAME.json` and all the related typeface `.txt` files.

In order to use the custom font, input the name as the fourth parameter to the text's constructor, or change it on the fly by assigning it to the `font` field:
```haxe
... new BAlphabet(x, y, text, "fontnamehere"); // Same for BAlphabetTyped.
// or
text.font = "fontnamehere";
```
Omitting the font name will default the font to `default`.

## Debug State

You can check if your fonts and/or characters were loaded properly *(granted no Polymod errors)* is by opening the Debug State by pressing `Shift + B` on the Main Menu.
- `WASD` to move the camera.
- `Q/E` to zoom out/in.
- `U/I` to switch between the available fonts.
- `J/K` to switch between the shown typefaces.
- `Z/C` to switch between the shown character in the offset area, above the main text area, hold `Shift` or `Alt` to the switch by `10`, hold both to switch by `100`.
- `Arrow Keys` to move the offset area character, hold `Shift` to move by `10`.