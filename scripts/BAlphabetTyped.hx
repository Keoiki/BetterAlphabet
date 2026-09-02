package balphabet;

class BAlphabetTyped extends BAlphabet
{
    override function set_text(input:String):String
    {
        this.visible = false;
        super.set_text(input);
        resetText();
        this.visible = true;
        return input;
    }

    public var isTyping:Bool = false;
    public var finishedText:Bool = false;
    public var speed:Float = 0.05;
    public var curLetter:Int = -1;
    public var timeToUpdate:Float = 0;
    public var letterStep:Int = 1;
    public var delayTime:Float = 0;

    /**
     * A function that is dispatched when a letter is typed.
     * The `Int` passed is the character code of the shown letter.
     */
    public var letterCallback:Int->Void;

    /**
     * A function that is dispatched when typing is finished.
     */
    public var finishCallback:Void->Void;

    /**
     * A function that is dispatched when an event is reached.
     * The `String` passed is the name of the event.
     */
    public var eventCallback:String->Void;

    /**
     * With this variable set to `true`, events that have not yet been reached will be dispatched when `finishText()` is called.
     */
    public var dispatchEventsOnEarlyFinish:Bool = true;

    override public function new(x:Float, y:Float, text:String = "", ?config:TextConfig)
    {
        super(x, y, text, config);
        resetText();
    }

    public function startTyping():Void
    {
        finishedText = false;
        isTyping = true;
    }

    public function resetText():Void
    {
        curLetter = -1;
        timeToUpdate = 0;
        isTyping = false;
        finishedText = false;
        for (letter in letters)
        {
            letter.localVisible = false;
        }
    }

    public function finishText():Void
    {
        if (finishedText || !isTyping)
            return;

        if (dispatchEventsOnEarlyFinish)
        {
            for (i in curLetter...letters.length)
            {
                if (textData.exists(i))
                {
                    var eventName = textData.get(i).event;
                    if (eventName != null)
                    {
                        if (eventCallback != null) eventCallback(eventName);
                    }
                }
            }
        }

        displayUpTo(letters.length - 1);

        if (finishCallback != null) finishCallback();

        isTyping = false;
        finishedText = true;
        timeToUpdate = 0;
    }
    
    public function displayUpTo(dest:Int):Void
    {
        if (dest >= letters.length)
        {
            dest = letters.length - 1;
            curLetter = letters.length - 1;
        }

        for (i in 0...(dest + 1))
        {
            if (letters[i] != null)
            {
                letters[i].localVisible = true;
            }
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!isTyping) return;

        if (!finishedText)
        {
            timeToUpdate += elapsed;
            while (timeToUpdate >= speed + delayTime)
            {
                delayTime = 0;

                curLetter += letterStep;

                displayUpTo(curLetter);

                if (letterCallback != null) letterCallback(letters[curLetter].character);

                if (textData.exists(curLetter))
                {
                    delayTime = textData.get(curLetter).delay;
                    if (delayTime == null || delayTime < 0)
                    {
                        delayTime = 0;
                    }
                    // if (delayTime > 0) trace("Delay found for " + (curLetter) + ": " + delayTime);

                    var eventName = textData.get(curLetter).event;
                    if (eventName != null)
                    {
                        // trace("Event found for " + (curLetter) + ": " + eventName);
                        if (eventCallback != null) eventCallback(eventName);
                    }
                }

                if (curLetter >= letters.length - 1)
                {
                    if (finishCallback != null) finishCallback();
                    finishedText = true;
                    timeToUpdate = 0;
                    isTyping = false;
                    break;
                }

                timeToUpdate = 0;
            }
        }
    }

    public function start():Void
    {
        startTyping();
    }

    public function reset():Void
    {
        resetText();
    }

    public function finish():Void
    {
        finishText();
    }
}