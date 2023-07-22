package funkin.scenes;

import sys.io.File;
import bliss.engine.utilities.BlissTimer;
import bliss.backend.graphics.BlissColor;
import bliss.engine.Group;
import bliss.engine.Sprite;
import bliss.engine.system.Game;
import bliss.engine.utilities.typeLimit.OneOfTwo;
import funkin.ui.Alphabet;

enum abstract IntroLineType(String) from String to String {
	final SET = "set";
	final ADD = "add";
}

class IntroLine {
	public var text:Array<String>;
	public var type:IntroLineType;
	public var onRun:TitleScreen->Void;

	public function new(?type:IntroLineType = SET, ?text:OneOfTwo<String, Array<String>>, ?onRun:TitleScreen->Void) {
		if (text == null)
			this.text = [];
		else if (text is String)
			this.text = cast(text, String).length > 0 ? [text] : [];
		else
			this.text = text;

		this.type = type;
		this.onRun = onRun;
	}

	public function run(state:TitleScreen) {
        if(type == SET)
            state.deleteCoolText();
                
        for(line in text) {
			for(i => wackyLine in state.curWacky)
				line = line.replace('{introLine${i+1}}', wackyLine);
            
			state.addMoreText(line.trim());
		}

		if(onRun != null)
			onRun(state);
	}
}

class TitleScreen extends MusicBeatScene {
	// intro line with no text specified means
	// it either adds nothing (if type is set to ADD)
	// or removes all text on screen (if type is set to SET, which is default)
	public var introLines:Map<Int, IntroLine> = [
		1 => new IntroLine(SET, ["ninjamuffin99", "PhantomArcade", "KawaiSprite", "evilsk8r"]),
		3 => new IntroLine(ADD, "present"),
		4 => new IntroLine(),
		5 => new IntroLine(SET, ["In association", "with"]),
		7 => new IntroLine(ADD, "Newgrounds", (state) -> state.ngSpr.visible = true),
		8 => new IntroLine(SET, null, (state) -> state.ngSpr.visible = false),
		9 => new IntroLine(SET, "{introLine1}"),
		11 => new IntroLine(ADD, "{introLine2}"),
		12 => new IntroLine(),
		13 => new IntroLine(SET, "Friday"),
		14 => new IntroLine(ADD, "Night"),
		15 => new IntroLine(ADD, "Funkin"),
	];
	public var introLength:Int = 16;

	public var curWacky:Array<String> = ["???", "???"];
	public var skippedIntro:Bool = false;
	public var accepted:Bool = false;

	public var logo:Sprite;
	public var gf:Sprite;
	public var titleEnter:Sprite;
	public var ngSpr:Sprite;

	public var textGroup:Group<Alphabet>;

	override function create() {
		super.create();
		Conductor.bpm = 102;
		Game.sound.playMusic(Paths.music("freakyMenu"));

        curWacky = Game.random.getObject(parseIntroText());

		add(textGroup = new Group());

		add(logo = new Sprite(-150, -100));
		logo.frames = Paths.getSparrowAtlas("menus/title/logo");
		logo.animation.addByPrefix("idle", "bump", 24, false);
		logo.animation.play("idle");

		add(gf = new Sprite(Game.width * 0.4, Game.height * 0.07));
		gf.frames = Paths.getSparrowAtlas("menus/title/gf");
		gf.animation.addByIndices("danceLeft", "gf dancing", [for (i in 0...15) i], 24, false);
		gf.animation.addByIndices("danceRight", "gf dancing", [for (i in 15...30) i], 24, false);
		gf.animation.play("danceLeft");

		add(titleEnter = new Sprite(100, Game.height * 0.8));
		titleEnter.frames = Paths.getSparrowAtlas("menus/title/pressEnter");
		titleEnter.animation.addByPrefix("idle", "idle", 24);
		titleEnter.animation.addByPrefix("confirm", "confirm", 24);
		titleEnter.animation.play("idle");

		add(ngSpr = new Sprite(0, Game.height * 0.52).loadGraphic(Paths.image("menus/title/newgrounds")));
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.screenCenter(X);

		for (spr in [logo, gf, titleEnter, ngSpr])
			spr.visible = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		Conductor.time = Game.sound.music.time;

		if (Game.keys.justPressed(ENTER)) {
			if (!skippedIntro)
				skipIntro();
			else if (!accepted)
				accept();
		}
	}

	override function beatHit(curBeat:Int) {
		if (curBeat < introLength && !skippedIntro) {
			var line:IntroLine = introLines.get(curBeat);
			if (line != null)
				line.run(this);
		} else if(!skippedIntro)
            skipIntro();
        
		logo.animation.play("idle", true);
		gf.animation.play(curBeat % 2 == 0 ? "danceRight" : "danceLeft");
	}

	public function createCoolText(textArray:Array<String>) {
		for(text in textArray)
            addMoreText(text);
	}

	public function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, (textGroup.length * 60) + 200, text, true);
		coolText.screenCenter(X);
		textGroup.add(coolText);
	}

	public function deleteCoolText() {
        for(text in textGroup.members)
            text.destroy();
        
		textGroup.clear();
	}

    public function parseIntroText() {
        var parsed:Array<Array<String>> = [];
        for(line in File.getContent(Paths.txt("data/introText")).split("\n"))
            parsed.push(line.split("--"));
        return parsed;
    }

	public function skipIntro() {
		if (skippedIntro) return;

		skippedIntro = true;
        deleteCoolText();

		for (spr in [logo, gf, titleEnter])
			spr.visible = true;

		Game.camera.flash(BlissColor.COLOR_WHITE, 4);
	}

	public function accept() {
		accepted = true;

		titleEnter.animation.play("confirm");
		Game.sound.play(Paths.sound("menus/confirmMenu"));
		Game.camera.flash(BlissColor.COLOR_WHITE, 1);

		new BlissTimer().start(2, (_) -> {
			Game.switchScene(new MainMenu());
		});
	}
}
