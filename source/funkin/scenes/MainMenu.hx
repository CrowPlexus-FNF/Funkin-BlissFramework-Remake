package funkin.scenes;

import bliss.engine.Group;
import bliss.engine.Scene;
import bliss.engine.Sprite;
import bliss.engine.Object2D;

import bliss.engine.system.Game;
import bliss.engine.tweens.Ease;
import bliss.engine.tweens.Tween;

import bliss.engine.utilities.MathUtil;
import bliss.engine.utilities.BlissTimer;
import bliss.engine.effects.FlickerEffect;

class MainMenu extends Scene {
    public var selected:Bool = false;
    public var curSelected:Int = 0;

    public var bg:Sprite;
    public var magenta:Sprite;
    public var camFollow:Object2D;

    public var grpButtons:Group<MainMenuButton>;

    override function create() {
        super.create();

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.scrollFactor.set(0, 0.17);
        bg.screenCenter();

        add(magenta = new Sprite().loadGraphic(Paths.image("menus/menuBGDesat")));
        magenta.scale.copyFrom(bg.scale);
        magenta.scrollFactor.copyFrom(bg.scrollFactor);
        magenta.screenCenter();
        magenta.visible = false;
        magenta.tint = 0xFFfd719b;

        add(grpButtons = new Group());
        addButtons();
        centerButtons();

        Game.camera.follow(camFollow = new Object2D(), 0.06);
        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.justPressed(UP))
            changeSelection(-1);

        if(Game.keys.justPressed(DOWN))
            changeSelection(1);

        if(Game.keys.justPressed(ENTER))
            select();
    }

    public function addButtons() {
        grpButtons.add(new MainMenuButton("story mode", () -> trace("no story yet fuck you")));
        grpButtons.add(new MainMenuButton("freeplay", () -> Game.switchScene(new FreeplayMenu())));
        grpButtons.add(new MainMenuButton("credits", () -> trace("no credits yet fuck you")));
        grpButtons.add(new MainMenuButton("options", () -> trace("no options yet fuck you")));
    }

    public function centerButtons() {
        final spacing:Float = 160;
		for(i => button in grpButtons.members) {
			button.position.x = Game.width * 0.5;
			button.position.y = ((Game.height * 0.5) + (i * spacing)) - ((grpButtons.length - 1) * spacing * 0.5);
		}
    }

    public function changeSelection(change:Int = 0) {
        final prevButton:MainMenuButton = grpButtons.members[curSelected];
        prevButton.playAnim("idle");

        curSelected = MathUtil.wrap(curSelected + change, 0, grpButtons.length - 1);
        
        final curButton:MainMenuButton = grpButtons.members[curSelected];
        curButton.playAnim("selected");

        camFollow.position.copyFrom(curButton.getMidpoint());
        Game.sound.play(Paths.sound("menus/scrollMenu"));
    }
    
    public function select() {
        if(selected) return;
        selected = true;

        final curButton:MainMenuButton = grpButtons.members[curSelected];

        FlickerEffect.flicker(magenta, 1.1, 0.12, false, true, (_) -> {
            for(i => spr in grpButtons.members) {
                if(curSelected == i) continue;
                Tween.tween(spr, {alpha: 0}, 0.4, {ease: Ease.quadOut});
            }
            new BlissTimer().start(0.4, (tmr:BlissTimer) -> curButton.select());
        });
        FlickerEffect.flicker(curButton, 1, 0.06, false, false);

        Game.sound.play(Paths.sound("menus/confirmMenu"));
    }
}

class MainMenuButton extends Sprite {
    /**
     * The function that gets ran whenever your
     * `ACCEPT` bind is pressed to select this button.
     */
    public var onSelect:Void->Void;

    public function new(name:String, ?onSelect:Void->Void) {
        super(0, 0);
        this.onSelect = onSelect;

        frames = Paths.getSparrowAtlas('menus/main/$name');
        animation.addByPrefix("idle", "idle", 24);
        animation.addByPrefix("selected", "selected", 24);
        playAnim("idle");
        scrollFactor.set();
    }

    public function playAnim(name:String, ?force:Bool = false) {
        animation.play(name, force);
        centerOrigin();
        offset.set(-origin.x, -origin.y);
    }

    /**
     * Selects this button and runs the
     * `onSelect` callback if available.
     */
    public function select() {
        if(onSelect != null)
            onSelect();
    }
}