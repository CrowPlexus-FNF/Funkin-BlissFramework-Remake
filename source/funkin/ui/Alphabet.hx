package funkin.ui;

import bliss.engine.utilities.AtlasFrames;
import bliss.engine.Sprite;
import bliss.engine.SpriteGroup;

import bliss.engine.system.Game;
import bliss.engine.system.Vector2D;

import bliss.engine.utilities.MathUtil;

class Alphabet extends SpriteGroup<AlphaCharacter> {
    public var bold:Bool = false;
    public var textSize(default, set):Float = 1;
    public var text(default, set):String;

    public var isMenuItem:Bool = false;
    public var targetY:Int = 0;

    public var changeX:Bool = true;
    public var changeY:Bool = true;

    public var rows:Int = 0;

    public var distancePerItem:Vector2D = new Vector2D(20, 120);

    public var alpha(default, set):Float = 1.0;

    public function new(x:Float = 0, y:Float = 0, text:String, ?bold:Bool = true, ?size:Float = 1) {
        super(x, y);
        this.bold = bold;
        @:bypassAccessor
        this.textSize = size;
        this.text = text;
    }

    override function update(elapsed:Float) {
	if (isMenuItem) {
		final lerpVal:Float = MathUtil.bound(elapsed * 9.6, 0, 1);
		if (changeX) position.x = MathUtil.lerp(position.x, targetY * distancePerItem.x, lerpVal);
		if (changeY) position.y = MathUtil.lerp(position.y, targetY * 1.3 * distancePerItem.y, lerpVal);
	}
	super.update(elapsed);
    }

    public inline function snapToPosition() {
	if (!isMenuItem) return;
	if (changeX) position.x = targetY * distancePerItem.x;
	if (changeY) position.y = targetY * 1.3 * distancePerItem.y;
    }

    //##-- VARIABLES/FUNCTIONS YOU SHOULDN'T TOUCH --##//
    @:noCompletion
    private inline function set_text(newText:String):String {
        destroyLetters();
        createLetters(newText);
        return text = newText;
    }

    @:noCompletion
    private inline function set_alpha(newAlpha:Float):Float {
        for (i in members) i.alpha = newAlpha;
        return alpha = newAlpha;
    }

    @:noCompletion
    private inline function set_textSize(v:Float) {
        textSize = v;
        destroyLetters();
        createLetters(text);
        return v;
    }

    @:noCompletion
    override function set_tint(value:Int) {
        for (letter in members)
            letter.tint = value;
        return super.set_tint(value);
    }

    @:noCompletion
    private inline function destroyLetters() {
        for(letter in members)
            letter.destroy();
        clear();
    }

    @:noCompletion
    private inline function createLetters(newText:String) {
        rows = 0;

        var xPos:Float = 0;
        var consecutiveSpaces:Int = 0;
        var rowData:Array<Float> = [];

        for (character in newText.split('')) {
	    if (character == '\n') {
		xPos = 0;
		rows++;
		continue;
	    }

	   var spaceChar:Bool = (character == " ");
    	    if (spaceChar) {
		xPos += 28;
		if(!bold && xPos >= Game.width * 0.65) {
			xPos = 0;
			rows++;
		}
		continue;
	    }

            var letter:AlphaCharacter = new AlphaCharacter(xPos, rows * AlphaCharacter.Y_PER_ROW * textSize, character, bold);
            letter.tint = tint;
            letter.row = rows;
            letter.scale.set(textSize, textSize);
            add(letter);

            xPos += letter.width;
            rowData[rows] = xPos;
        }

        for (letter in members)
            letter.rowWidth = rowData[letter.row];

        if (length > 0)
            rows++;
    }

    override function destroy() {
        distancePerItem = null;
        super.destroy();
    }
}

@:allow(funkin.ui.Alphabet)
class AlphaCharacter extends Sprite {
    public static final Y_PER_ROW:Float = 85;

    public static final letters:Array<String> = "abcdefghijklmnopqrstuvwxyz".split("");
    public static final numbers:Array<String> = "0123456789".split("");
    public static final symbols:Array<String> = "#$%&()|~<>←↓↑→-!'.+?*^\\/\",=×♥".split("");

    /**
     * Converts a regular letter into the name of it
     * in the alphabet spritesheet.
     * 
     * @param letter  The letter to convert.
     */
    public static inline function convert(letter:String) {
        return switch(letter) {
            case "\\": "bslash";
            case "/": "fslash";
            case ",": "comma";
            case ".": "period";
            case "-": "dash";
            case "=": "equals";
            case "!": "exclamation";
            case "?": "question";
            case "<": "less";
            case ">": "greater";
            case "+": "plus";
            case "←": "arrow left";
            case "↓": "arrow down";
            case "↑": "up arrow"; // i hate this :(
            case "→": "arrow right";
            case "×": "multX";
            case "♥": "heart";
            case "\"": "left double quotes";
            case "'": "single quotes";
            case "|": "pipe";
            case "*": "star";
            default: letter;
        }
    }

    public var letter:String;
    public var bold:Bool;

    public var row:Int;
    public var rowWidth:Float;

    public function new(x:Float = 0, y:Float = 0, letter:String, bold:Bool) {
        super(x, y);
        this.letter = letter;
        this.bold = bold;

        // frames = Paths.getSparrowAtlas('fonts/${bold ? "bold" : "normal"}');
        final pissShit:String = 'assets/images/fonts/${bold ? "bold" : "normal"}';
        frames = AtlasFrames.fromSparrow('$pissShit.png', '$pissShit.xml');

        if(bold) {
            createBold();
            return;
        }
        
        if(numbers.contains(letter.toLowerCase()))
            createNumber();
        else if(symbols.contains(letter.toLowerCase()))
            createSymbol();
        else
            createLetter();
    }

    public inline function createBold() {
        var letter:String = (letters.contains(this.letter.toLowerCase())) ? convert(this.letter).toUpperCase() : convert(this.letter);

        animation.addByPrefix("idle", '${letter}0', 24);
        updateOffset();
    }

    public inline function createLetter() {
        var letter:String = convert(this.letter).toUpperCase();
        var letterCase:String = (letter.toLowerCase() != letter) ? "upper" : "lower";

        animation.addByPrefix("idle", '${letter} ${letterCase}0', 24);
        updateOffset();
    }

    public inline function createSymbol() {
        var letter:String = convert(this.letter);

        animation.addByPrefix("idle", '${letter}0', 24);
        updateOffset();
    }

    public inline function createNumber() {
        var letter:String = convert(this.letter);

        animation.addByPrefix("idle", '${letter}0', 24);
        updateOffset();
    }

	public inline function updateOffset() {
		var offset:Vector2D = new Vector2D(0, bold ? 0 : (110 - size.y));

        if(!bold) {
            // initial offseting
            switch(letter) {
                case "g", "j":
                    offset.y += size.y * 0.1;
                case "p", "q", "y":
                    offset.y += size.y * 0.2;
                case ".", ',', '_':
                    offset.y += size.y;
                case "-":
                    offset.y -= size.y;
                case "'", "\"":
                    offset.y -= size.y * 1.05;
            }

            // offset fixing (moving smaller symbols upwards)
            switch(letter) {
                case "#", "←", "↓", "↑", "→", "-", ".", ",", "_", "*", "^", "+", "=", "×", "♥":
                    offset.y -= 12;
            }
        }

		animation.setAnimOffset("idle", offset.x, offset.y);
		animation.play("idle", true);
	}
}
