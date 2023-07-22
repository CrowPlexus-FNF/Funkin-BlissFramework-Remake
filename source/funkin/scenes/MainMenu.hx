package funkin.scenes;

import bliss.engine.utilities.MathUtil;
import bliss.engine.Group;
import bliss.engine.Scene;
import bliss.engine.Sprite;
import bliss.engine.Object2D;
import bliss.engine.system.Game;

class MainMenu extends Scene {
    public var curSelected:Int = 0;

    public var bg:Sprite;
    public var camFollow:Object2D;

    public var menuItems:Array<String> = [
        "story mode",
        "freeplay",
        "credits",
        "options"
    ];
    public var menuButtons:Group<Sprite>;

    override function create() {
        super.create();

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.scrollFactor.set(0, 0.17);
        bg.screenCenter();

        add(menuButtons = new Group());

        for(i => item in menuItems) {
            final button:Sprite = new Sprite(Game.width * 0.5, 120 + (i * 160));
            button.frames = Paths.getSparrowAtlas('menus/main/$item');
            button.animation.addByPrefix("idle", "idle", 24);
            button.animation.addByPrefix("selected", "selected", 24);
            button.animation.play("idle");
            button.centerOrigin();
            button.offset.set(-button.origin.x, -button.origin.y);
            button.scrollFactor.set();
            menuButtons.add(button);
        }

        Game.camera.follow(camFollow = new Object2D(), 0.06);
        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.justPressed(UP))
            changeSelection(-1);

        if(Game.keys.justPressed(DOWN))
            changeSelection(1);
    }

    public function changeSelection(change:Int = 0) {
        final prevButton = menuButtons.members[curSelected];
        prevButton.animation.play("idle");
        prevButton.centerOrigin();
        prevButton.offset.set(-prevButton.origin.x, -prevButton.origin.y);

        curSelected = MathUtil.wrap(curSelected + change, 0, menuButtons.length - 1);

        final curButton = menuButtons.members[curSelected];
        curButton.animation.play("selected");
        curButton.centerOrigin();
        curButton.offset.set(-curButton.origin.x, -curButton.origin.y);

        camFollow.position.copyFrom(curButton.getMidpoint());
    }
}