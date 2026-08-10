package balphabet;

using StringTools;
import funkin.modding.module.Module;
import funkin.util.ReflectUtil;
import haxe.ds.IntMap;

typedef TextData = {
    color:Null<Int>, // <c=FF0000>text</c>
    scale:Null<Float>, // <s=1.5>text</c>
    effect:Null<Int>, // <W> (1, Wave) or <S> (2, Shake)
    italics:Null<Bool>, // <i>
    bold:Null<Bool>, // <b>
    alpha:Null<Float>, // <a=0.5>Half opacity text!</a>
    delay:Null<Float>, // <d=0.5/> (Seconds, only on typed text)
    monospace:Null<Bool>, // <m>
    event:Null<String>, // <e=eventName/> (Only on typed text)
    offset:Null<Array<Float>> // <o=x,y/>
}

typedef PlaneOffset = {
    pos:Int,
    plane:Int
}

class BAlphabetParser extends Module
{
    public var letterData:IntMap<Int, Null<TextData>> = new IntMap();
    public var letterPlanes:Array<PlaneOffset> = [];

    public var charIndex:Int = 0;
    public var inTag:Bool = false;
    public var inSelfClosingTag:Bool = false;

    var hasColor:Null<Int> = null;
    var hasScale:Null<Float> = null;
    var hasEffect:Int = 0;
    var hasItalic:Bool = false;
    var hasBold:Bool = false;
    var hasAlpha:Null<Float> = null;
    var hasDelay:Null<Float> = null;
    var hasMono:Bool = false;
    var hasEvent:Null<String> = null;
    var hasOffset:Null<Array<Float>> = null;

    public function new():Void
    {
        super('balphabet-parser', 3);
    }

    public function resetVariables():Void
    {
        charIndex = 0;
        inTag = false;
        inSelfClosingTag = false;
        letterData.clear();
        letterPlanes = [];

        hasColor = null;
        hasScale = null;
        hasEffect = 0;
        hasItalic = false;
        hasBold = false;
        hasAlpha = null;
        hasDelay = null;
        hasMono = false;
        hasEvent = null;
        hasOffset = null;
    }

    public function parseText(text:String):Array<Dynamic>
    {
        resetVariables();
        text = parseUnicode(text);
        for (i in 0...text.length)
        {
            parseTags(text, text.charAt(i), i);
            if (inSelfClosingTag)
            {
                // trace('Adding SELF-CLOSING TAG STUFFS', i, charIndex, text.charAt(i), hasColor, hasScale, hasEffect, hasItalic, hasBold, hasAlpha, hasDelay, hasMono, hasEvent, hasOffset);
                addLetterModifiers(-1);
                // These effects should be terminated immediately.
                hasDelay = null;
                hasEvent = null;
                hasOffset = null;
            }
            // trace(i, charIndex, text.charAt(i), hasColor, hasScale, hasEffect, hasItalic, hasBold, hasAlpha, hasDelay, hasMono, hasEvent, hasOffset);
            if (!inTag && !inSelfClosingTag)
            {
                var charCheck = text.charCodeAt(i);
                if (charCheck != 9 && charCheck != 10 && charCheck != 13 && charCheck != 32)
                {
                    addLetterModifiers();
                    charIndex++;
                }
            }
        }
        var regex:EReg = new EReg('<[!a-zA-Z\\/][^>]*>', 'g');
        // text = regex.replace(text, '');
        text = regex.map(text, (e) -> {
            var match = e.matchedPos();
            for (a in 0...letterPlanes.length)
            {
                if (match.pos < letterPlanes[a].pos)
                {
                    letterPlanes[a].pos -= match.len;
                }
            }
            return '';
        });
        return [text, letterData, letterPlanes];
    }

    function parseUnicode(text:String):String
    {
        var i:Int = 0;
        var totalLength:Int = 0;
        var regex:EReg = new EReg("&#(x?)([A-Fa-f0-9]+);", "g");
        text = regex.map(text, (e) -> {
            var num:Int = Std.int((e.matched(1) == "x" ? "0x" : "") + e.matched(2));
            if (num > 0xFFFF)
            {
                var pos:Int = (i == 0) ? e.matchedPos().pos : e.matchedPos().pos - (totalLength - i);
                var plane:Int = Math.floor(num / 65535);
                letterPlanes.push({
                    pos: pos,
                    plane: plane
                });
            }
            i++;
            totalLength += e.matchedPos().len;
            return BAlphabetData.fromCharCode(num);
        });
    }

    public function parseTags(fullText:String, char:String, i:Int):Void
    {
        var isTag:Bool = char == '<';
        if (isTag)
        {
            var enter:Bool = fullText.charAt(i + 1) != '/';
            var end:Int = fullText.indexOf('>', i + 1);
            var hasData:Bool = end > fullText.indexOf('=', i + 1) && fullText.indexOf('=', i + 1) != -1;
            var tag:String = fullText.substring(enter ? i + 1 : i + 2, hasData ? fullText.indexOf('=', i + 1) : fullText.indexOf('>', i + 1));

            if (tag.length > 1) tag = tag.toLowerCase();

            if (fullText.charAt(end - 1) == '/')
            {
                inSelfClosingTag = true;
                onEnterTag(fullText, tag, i);
                return;
            }

            inTag = true;
            if (enter)
            {
                onEnterTag(fullText, tag, i);
            }
            else
            {
                // Not needed anymore? 
                // NVM I'm actually stupid
                onCloseTag(tag, i);
            }
        }
        else
        {
            var closeTag:Bool = (i > 0 && fullText.charAt(i - 1) == '>');
            if (closeTag)
            {
                inTag = false;
                inSelfClosingTag = false;
            }
        }
    }

    public function onEnterTag(fullText:String, tag:String, position:Int):Void
    {
        var tagStart:Int = position + 2 + tag.length; // <#=
        var tagEnd:Int = fullText.indexOf('>', tagStart);

        if (inSelfClosingTag)
        {
            switch (tag)
            {
                case 'd', 'delay': hasDelay = Std.parseFloat(fullText.substring(tagStart, tagEnd - 1));
                case 'e', 'event': hasEvent = fullText.substring(tagStart, tagEnd - 1);
                case 'o', 'offset': 
                    var commaIndex:Int = fullText.indexOf(',', tagStart);
                    hasOffset = [Std.parseFloat(fullText.substring(tagStart, commaIndex)), Std.parseFloat(fullText.substring(commaIndex + 1, tagEnd - 1))];
                default: trace('Trying to enter an unknown self-closing tag $tag at $position');
            }
        }

        if (inTag)
        {
            switch (tag)
            {
                case 'c', 'color':      hasColor = Std.parseInt('0x${fullText.substring(tagStart, tagEnd)}');
                case 'W', 'wave':       hasEffect = 1;
                case 'S', 'shake':      hasEffect = 2;
                case 'i', 'italic':     hasItalic = true;
                case 'b', 'bold':       hasBold = true;
                case 'a', 'alpha':      hasAlpha = Std.parseFloat(fullText.substring(tagStart, tagEnd));
                case 's', 'scale':      hasScale = Std.parseFloat(fullText.substring(tagStart, tagEnd));
                case 'm', 'mono', 'monospace':  hasMono = true;
                default: trace('Trying to enter an unknown tag $tag at $position');
            }
        }
    }

    public function onCloseTag(tag:String, position:Int):Void
    {
        switch (tag)
        {
            case 'c', 'color':      hasColor = null;
            case 'W', 'wave':       hasEffect = 0;
            case 'S', 'shake':      hasEffect = 0;
            case 'i', 'italic':     hasItalic = false;
            case 'b', 'bold':       hasBold = false;
            case 'a', 'alpha':      hasAlpha = null;
            case 's', 'scale':      hasScale = null;
            case 'm', 'mono', 'monospace':  hasMono = false;
            default: trace('Trying to exit an unknown tag $tag at $position');
        }
    }

    function addLetterModifiers(offset:Int = 0):Void
    {
        // return;
        if (letterData.exists(charIndex + offset))
        {
            var prevData:Dynamic = letterData.get(charIndex + offset);
            letterData.set(charIndex + offset,
            {
                color: hasColor != null ? hasColor : prevData.color,
                scale: hasScale != null ? hasScale : prevData.scale,
                effect: hasEffect != 0 ? hasEffect : prevData.effect,
                italic: hasItalic ? hasItalic : prevData.italic,
                bold: hasBold ? hasBold : prevData.bold,
                alpha: hasAlpha != null ? hasAlpha : prevData.alpha,
                delay: hasDelay != null ? hasDelay : prevData.delay,
                monospace: hasMono ? hasMono : prevData.monospace,
                event: hasEvent != null ? hasEvent : prevData.event,
                offset: hasOffset != null ? hasOffset : prevData.offset
            });
        }
        else if (hasColor != null ||
            hasEffect != 0 ||
            hasItalic ||
            hasBold ||
            hasScale != null ||
            hasAlpha != null ||
            hasDelay != null ||
            hasMono ||
            hasEvent != null ||
            hasOffset != null)
        {
            letterData.set(charIndex + offset,
            {
                color: hasColor,
                scale: hasScale,
                effect: hasEffect,
                italic: hasItalic,
                bold: hasBold,
                alpha: hasAlpha,
                delay: hasDelay,
                monospace: hasMono,
                event: hasEvent,
                offset: hasOffset
            });
        }
    }
}
