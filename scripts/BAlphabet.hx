package balphabet;

import balphabet.BAlphabetCharacter;
import funkin.group.FunkinGroup;
import funkin.modding.module.ModuleHandler;
using StringTools;

typedef TextConfig =
{
    /**
     * The name of the font you want to use for the text.
     * Default: "default"
     */
    ?font:String,

    /**
     * The default color of the text.
     * Default: "FFFFFF"
     */
    ?baseColor:String,

    /**
     * The alignment of the text.
     * Options: "left", "center" or "centered", "right".
     * Default: "left"
     */
    ?alignment:String,

    /**
     * The line height of the text.
     * Default: Whatever the font's lineheight is that you're using.
     */
    ?lineHeight:Float

    // ?direction:TextDirection // Default: TextDirection.LeftToRight
}

/*
enum TextDirection
{
    LeftToRight;
    RightToLeft;
    UpToDown;
    DownToUp;
}
*/

class BAlphabet extends FunkinGroup
{
    // Base variable getter overrides
    override function get_width():Float
    {
        var widestRow:Float = 0;
        for (row in rowWidths)
        {
            if (row > widestRow)
            {
                widestRow = row;
            }
        }
        return widestRow * scale.x;
    }

    override function get_height():Float
    {
        return (letters[letters.length - 1]?.row + 1) * this.lineHeight * scale.y;
    }

    // Regular variables
    var textRaw:String;
    var text(default, set):String;
    var forceTextUpdate:Bool = false;

    function set_text(input:String):String
    {
        if (input == textRaw && !forceTextUpdate) return input;

        textRaw = input;
        clearLetters();
        text = textRaw.replace('\\n', '\n');
        var parserResult:Array = textParser.parseText(text);
        // trace(parserResult);
        text = parserResult[0];
        textData = parserResult[1];
        textDataPlanes = parserResult[2];
        createLetters(text);

        forceTextUpdate = false;
        return input;
    }

    var fontData:BAFont;
    var font(get, set):String;

    function set_font(input:String):String
    {
        if (!BAlphabetData.allFonts.exists(input))
        {
            fontData = BAlphabetData.allFonts.get('default');
            trace("Font " + input + " not found. Defaulting to default font.");
        }
        else
        {
            fontData = BAlphabetData.allFonts.get(input);
        }

        config.font = input;
        if (config.lineHeight == null) config.lineHeight = fontData.lineHeight;

        if (textRaw != null)
        {
            text = textRaw;
        }

        return input;
    }

    function get_font():String
    {
        return config.font;
    }

    var alignment(get, set):String;

    function set_alignment(input:String):String
    {
        input = input.trim();
        switch (input.toLowerCase())
        {
            case 'right': input = 'right';
            case 'center', 'centered': input = 'centered';
            default: input = 'left';
        }
        config.alignment = input;
        updateAlignment();

        return input;
    }

    function get_alignment():String
    {
        return config.alignment;
    }

    var baseColor(get, set):String;

    function set_baseColor(input:String):String
    {
        baseColor = input;
        config.baseColor = input;
        return input;
    }

    function get_baseColor():String
    {
        return config.baseColor;
    }

    var lineHeight(get, set):Float;

    function set_lineHeight(input:Float):Float
    {
        lineHeight = input;
        config.lineHeight = input;
        if (textRaw != null)
        {
            forceTextUpdate = true;
            text = textRaw;
        }
        return input;
    }

    function get_lineHeight():Float
    {
        return config.lineHeight;
    }

    function resetLineHeight():Void
    {
        lineHeight = fontData.lineHeight;
    }

    var letters:Array<BAlphabetCharacter> = [];
    var rowWidths:Array<Float> = [];
    var rows:Int = 0;

    var config:TextConfig;
    function validateConfig(config:Null<TextConfig>):TextConfig
    {
        if (config == null) config = {};
        config?.font ??= "default";
        this.font = config.font;
        config?.baseColor ??= "FFFFFF";
        config?.alignment ??= "left";
        config?.lineHeight ??= this.fontData.lineHeight;
        // config.direction ??= TextDirection.LeftToRight;
        return config;
    }

    var textParser;
    var textData;
    var textDataPlanes;

    public function new(x:Float, y:Float, text:String = "", ?config:TextConfig):Void
    {
        textParser = ModuleHandler.getModule('balphabet-parser');
        super(x, y);
        this.config = validateConfig(config);
        this.text = text;
    }

    @:deprecated("Use the built-in alignment property instead.")
    public function setAlignment(align:String):Void
    {
        alignment = align;
    }

    function updateAlignment():Void
    {
        for (letter in letters)
        {
            var newOffset:Float = 0;
            switch (alignment)
            {
                case 'right': newOffset = rowWidths[letter.row];
                case 'centered': newOffset = rowWidths[letter.row] / 2;
                default: newOffset = 0;
            }
            letter.localX += letter.alignOffset;
            letter.alignOffset = newOffset;
            letter.localX -= letter.alignOffset;
        }
    }

    @:deprecated("Use the built-in scale property instead.")
    public function setScale(scaleX:Float, ?scaleY:Float):Void
    {
        this.scale.set(scaleX, scaleY ?? scaleX);
    }

    public function setScrollFactor(factorX:Float = 0.0, factorY:Float = 0.0):Void
    {
        for (letter in children)
        {
            if (letter != null && letter.exists && letter.active)
            {
                letter.scrollFactor.set(factorX, factorY);
            }
        }
    }

    @:deprecated("Use the built-in text property instead.")
    public function setText(newText:String):Void
    {
        text = newText;
    }

    function clearLetters():Void
    {
        for (letter in children)
        {
            if (letter != null && letter.exists && letter.active)
            {
                letter.kill();
            }
        }
        letters = [];
        rowWidths = [];
        rows = 0;
    }

    function createLetters(newText:String):Void
    {
        rows = 0;
        rowWidths = [];
        var consecutiveSpaces:Int = 0;
        var posX:Float = 0;
        var index:Int = 0;
        var indexWithSpaces:Int = 0;
        for (character in newText.split(''))
        {
            indexWithSpaces++;
            if (character != '\n')
            {
                var isSpace:Bool = (character == " ");
                if (isSpace) consecutiveSpaces++;

                // Do not display certain characters.
                if (shouldIgnoreCharacter(character) || isSpace) continue;

                var charCode:Int = character.charCodeAt(0);

                var scaleMultiplier:Float = 1;
                var isBold:Bool = false;
                var isItalic:Bool = false;
                var isMonospaced:Bool = null;
                var newPlane:Int = 0;
                var posOffsets:Array<Float> = [0, 0];

                if (textData.exists(index))
                {
                    if (textData.get(index).scale != null)
                    {
                        scaleMultiplier = textData.get(index).scale;
                    }
                    isBold = textData.get(index).bold;
                    isMonospaced = textData.get(index).monospace;
                    isItalic = textData.get(index).italic;
                    if (textData.get(index).offset != null)
                    {
                        posOffsets = textData.get(index).offset;
                    }
                }

                for (plane in textDataPlanes)
                {
                    if (plane.pos == indexWithSpaces - 1)
                    {
                        newPlane = plane.plane;
                        break;
                    }
                }

                if (consecutiveSpaces > 0)
                {
                    posX += fontData.spaceWidth * consecutiveSpaces * scaleMultiplier;
                }

                // Use a revive system rather than creating a new letter EVERY TIME.
                // Seems to have improved performance quite a bit.
                var letter:BAlphabetCharacter = null;
                letter = getFirstAvailable();
                if (letter != null)
                {
                    letter.revive();
                    letter.resetEffects();
                }
                else
                {
                    letter = new BAlphabetCharacter(0, 0);
                    // Only add a letter when it's brand new!
                    this.add(letter);
                }
                letter.plane = newPlane;
                if (isMonospaced) letter.monospace = isMonospaced;
                letter.fontData = this.fontData;
                letter.setupAlphaCharacter(charCode, isBold, font, scaleMultiplier);
                letter.row = rows;
                letter.spacesBefore = consecutiveSpaces;
                letter.setupPosition(posX + posOffsets[0], rows * this.lineHeight + posOffsets[1]);
                letter.setColor(Std.parseInt('0x${baseColor}'));

                if (letter.monospace ?? fontData.monospace)
                {
                    var monoWidth:Float = letter.isBold ? fontData.widthBold : fontData.width;
                    if (monoWidth == 0 && letter.isBold) monoWidth = fontData.width;
                    posX += monoWidth * letter.localScale.x;
                }
                else
                {
                    var padding:Float = letter.isBold ? fontData.paddingBold : fontData.padding;
                    if (isItalic) padding *= 2;
                    posX += (letter.frameWidth + padding + letter.letterOffset[0]) * letter.localScale.x;
                }

                letters.push(letter);

                index++;
                consecutiveSpaces = 0;
            }
            else
            {
                letters[index - 1]?.spacesTrailing = consecutiveSpaces;
                consecutiveSpaces = 0;
                posX = 0;
                rows++;
            }
        }

        if (letters.length > 0)
        {
            // Deal with trailing spaces.
            if (consecutiveSpaces > 0)
            {
                posX += fontData.spaceWidth * consecutiveSpaces * letters[index - 1]?.localScale.x;
            }
            letters[index - 1]?.spacesTrailing = consecutiveSpaces;
        }

        setRowWidths();
        loadLetterModifiers();
        updateAlignment();
        updateChildren();
    }

    public function setRowWidths():Void
    {
        var posX:Float = 0;
        var prevRow:Int = -1;
        for (letter in children)
        {
            if (letter == null || !letter.exists || !letter.active) continue;

            if (letter.row != prevRow)
            {
                prevRow = letter.row;
                posX = 0;
            }

            if (letter.spacesBefore > 0)
            {
                posX += fontData.spaceWidth * letter.spacesBefore * letter.localScale.x;
            }

            if (letter.spacesTrailing > 0)
            {
                posX += fontData.spaceWidth * letter.spacesTrailing * letter.localScale.x;
            }
            
            if (letter.monospace ?? fontData.monospace)
            {   
                var monoWidth:Float = letter.isBold ? fontData.widthBold : fontData.width;
                if (monoWidth == 0 && letter.isBold) monoWidth = fontData.width;
                posX += monoWidth * letter.localScale.x;
            }
            else
            {
                var padding:Float = letter.isBold ? fontData.paddingBold : fontData.padding;
                posX += (letter.frameWidth + padding + letter.letterOffset[0]) * letter.localScale.x;
            }
            rowWidths[letter.row] = posX;
        }
    }

    public function loadLetterModifiers():Void
    {
        for (i in 0...letters.length)
        {
            if (textData.exists(i))
            {
                if (textData.get(i).color != null)
                {
                    letters[i].setColor(textData.get(i).color);
                }

                if (textData.get(i).alpha != null)
                {
                    letters[i].localAlpha = textData.get(i).alpha;
                }

                if (textData.get(i).italic)
                {
                    letters[i].setItalic();
                }

                if (textData.get(i).effect == 1)
                {
                    letters[i].doWave = true;
                    letters[i].waveOffset = i;
                }

                if (textData.get(i).effect == 2)
                {
                    letters[i].doShake = true;
                }
            }
        }
    }

    /**
     * Do not render the following:
     * 9 - Horizontal Tab
     * 10 - Line Feed
     * 13 - Carriage Return
     */
    public function shouldIgnoreCharacter(character:String):Bool
    {
        return character == BAlphabetData.fromCharCode(9)
            || character == BAlphabetData.fromCharCode(10)
            || character == BAlphabetData.fromCharCode(13);
    }
}