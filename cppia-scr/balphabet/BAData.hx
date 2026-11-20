package balphabet;

import flixel.FlxG;
import funkin.Assets;
import funkin.assets.Assets as NewAssets;
import funkin.assets.Paths;
import funkin.assets.Paths.AssetPath;
import funkin.modding.events.ScriptEvent;
import funkin.modding.events.ScriptEvent.UpdateScriptEvent;
import funkin.modding.module.Module;
//import funkin.ui.mainmenu.MainMenuState;
import funkin.util.SerializerUtil;
import haxe.Utf8;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
using StringTools;
using funkin.util.tools.ArrayTools;

typedef BAFont =
{
    ?height:Float,
    ?heightBold:Float,
    ?width:Float,
    ?widthBold:Float,
    ?monospace:Bool,
    ?padding:Float,
    ?paddingBold:Float,
    ?lineHeight:Float,
    ?spaceWidth:Float,
    ?antialiasing:Bool,
    ?shakeFramerate:Float,
    ?shakeSizeX:Float,
    ?shakeSizeY:Float,
    ?waveSize:Float,
    ?waveSpeed:Float,
    letters:IntMap<BALetter>
}

typedef BALetter =
{
    anim:String,
    typeface:String,
    ?colored:Bool,
    ?monospace:Bool,
    ?offsets:Array<Float>,
    ?offsetItalic:Float
}

class BAData extends Module
{
    public static var allFonts:StringMap<BAFont> = new StringMap();
    
    public static var uniqueTypefaces:Array<String> = [];
    public static var uniqueFonts:Array<String> = [];

    override public function new()
    {
        super('BAData', -2100000000);
    }

    override public function onCreate(event:ScriptEvent):Void
    {
        loadFontData();
        super.onCreate(event);
    }

    override public function onUpdate(event:UpdateScriptEvent):Void
    {   
        //if ((FlxG.state is MainMenuState) && FlxG.state.subState == null && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.B)
        //{
            // FlxG.switchState(new BAlphabetDebug());
        //}

        super.onUpdate(event);
    }

    /**
     * Returns the letter at the given map index.
     * @param index Non-hex number of the letter
     * @param font Name of the font
     * @return BALetter
     */
    public static function getLetter(index:Int, font:String = "default"):BALetter
    {
        if (allFonts.exists(font))
        {
            if (allFonts.get(font).letters.exists(index))
            {
                return allFonts.get(font).letters.get(index);
            }
        }
        trace("No letter found for number: " + index + " in font: " + font + ". Returning fallback letter.");
        return {anim: "65533", offsets: [0, 8], colored: false, typeface: "specials", monospace: false, offsetItalic: 0};
    }

    /**
     * Loads the data for all fonts the mod can find.
     */
    function loadFontData():Void
    {
        BAData.allFonts.clear();

        var fontList:Array<String> = Assets.list(TEXT).filter(function(file:String):Bool
        {
            return file.contains("data/balphabet/") && file.endsWith(".json");
        });

        for (font in fontList)
        {
            font = font.substring(font.indexOf("/") + 1);
            var data:String = Assets.getText(font);
            var json:BAFont = SerializerUtil.fromJSON(data);
            var name:String = font.substring(font.lastIndexOf("/") + 1, font.indexOf("."));

            // Validate data, apply the "default" font's values if not set.
            json.height ??= 54;
            json.heightBold ??= 60;
            json.width ??= 54;
            json.widthBold ??= 54;
            json.monospace ??= false;
            json.padding ??= 2;
            json.paddingBold ??= -6;
            json.lineHeight ??= 85;
            json.spaceWidth ??= 28;
            json.antialiasing ??= true;
            json.shakeFramerate ??= 16;
            json.shakeSizeX ??= 4;
            json.shakeSizeY ??= 4;
            json.waveSize ??= 16;
            json.waveSpeed ??= 4;

            json.letters = loadLetterData(name);
            BAData.allFonts.set(name, json);

            if (!BAData.uniqueFonts.contains(name))
            {
                BAData.uniqueFonts.push(name);
            }

            trace('Loaded font: $name');
        }

        BAData.uniqueTypefaces.push("all");

        var fontTextures:Array<String> = Assets.list(IMAGE).filter(function(file:String):Bool
        {
            return file.contains("ui/balphabet/") && file.endsWith(".png");
        });

        var toCache:Array<AssetPath> = [];

        for (font in fontTextures)
        {
            font = font.substring(font.indexOf("/") + 1, font.lastIndexOf(".png"));
            toCache.pushUnique(Paths.image(font));
        }

        NewAssets.cacheAllFlxGraphics(toCache, true);
    }

    /**
     * Loads the letter data for the given font.
     */
    function loadLetterData(fontName:String):IntMap<BALetter>
    {
        if (fontName == null)
        {
            return null;
        }

        var letters:IntMap<BALetter> = new IntMap();

        var alphabetList:Array<String> = Assets.list(TEXT).filter(function(file:String):Bool
        {
            return file.contains("data/balphabet/" + fontName) && file.endsWith(".txt");
        });

        for (file in alphabetList)
        {
            file = file.substring(file.indexOf("/") + 1);
            var data:String = Assets.getText(file);
            data = data.trim();

            var typeface:String = file.substring(file.lastIndexOf("/") + 1, file.indexOf("."));
            if (typeface == "general-punctuation") continue;
            if (!BAData.uniqueTypefaces.contains(typeface))
            {
                BAData.uniqueTypefaces.push(typeface);
            }
    
            var eachLine:Array<String> = data.split("\n");
            for (character in eachLine)
            {
                var index:Int = -1;
                var offsets:Array<Float> = [0, 0];
                var monospace:Null<Bool> = null;
                var colored:Bool = false;
                var italicOffset:Float = 0;
    
                var elements:Array<String> = character.split(" ");
                for (element in elements)
                {
                    var elementInfo:Array<String> = element.split("=");
                    elementInfo[0] = elementInfo[0].trim();
                    elementInfo[1] = elementInfo[1].trim();
                    switch (elementInfo[0])
                    {
                        case "char" | "index":
                            index = Std.parseInt(elementInfo[1]);
                        case "offsetX":
                            offsets[0] = Std.parseFloat(elementInfo[1]);
                        case "offsetY":
                            offsets[1] = Std.parseFloat(elementInfo[1]);
                        case "offsetI":
                            italicOffset = Std.parseFloat(elementInfo[1]);
                        case "monospace":
                            monospace = (elementInfo[1].toLowerCase() == "true" || elementInfo[1] == "1");
                        case "colored":
                            colored = (elementInfo[1].toLowerCase() == "true" || elementInfo[1] == "1");
                        default:
                            trace("Invalid data!", character);
                    }
                }
                letters.set(index, {anim: Std.string(index), offsets: offsets, monospace: monospace, colored: colored, typeface: typeface, offsetItalic: italicOffset});
            }
        }

        return letters;
    }

    public static function fromCharCode(code:Int):String
    {
        var u:Utf8 = new Utf8();
        u.addChar(code);
        return u.toString();
    }
}