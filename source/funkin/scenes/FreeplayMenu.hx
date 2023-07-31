package funkin.scenes;

import bliss.engine.Scene;
import bliss.engine.Sprite;
import bliss.engine.Group;
import bliss.engine.system.Game;

import bliss.engine.tweens.Tween;
import bliss.backend.graphics.BlissColor;

import funkin.ui.Alphabet;

typedef SongStruct = {
    var displayName:String;
    var folderLocation:String;
    var ?iconCharacter:String;
    var ?bgColor:BlissColor;
    var ?week:Int;
}

class FreeplayMenu extends Scene {
    var curSelection:Int = 0;
    var songsGroup:Group<Alphabet>;

    var bg:Sprite;

    var songs:Array<SongStruct> = [
         {displayName: "Tutorial", folderLocation: "tutorial", bgColor: BlissColor.fromString("#9271FD")},
         {displayName: "Bopeebo", folderLocation: "bopeebo", bgColor: BlissColor.fromString("#9271FD")},
         {displayName: "Fresh", folderLocation: "fresh", bgColor: BlissColor.fromString("#9271FD")},
         {displayName: "Dad Dattle", folderLocation: "dadbattle", bgColor: BlissColor.fromString("#9271FD")},
         {displayName: "Spookeez", folderLocation: "spookeez", bgColor: BlissColor.fromString("#223344")},
         {displayName: "South", folderLocation: "south", bgColor: BlissColor.fromString("#223344")},
         {displayName: "Monster", folderLocation: "monster", bgColor: BlissColor.fromString("#223344")},
         {displayName: "Pico", folderLocation: "pico", bgColor: BlissColor.fromString("#941653")},
         {displayName: "Philly Nice", folderLocation: "philly", bgColor: BlissColor.fromString("#941653")},
         {displayName: "Blammed", folderLocation: "blammed", bgColor: BlissColor.fromString("#941653")},
         {displayName: "Satin Panties", folderLocation: "satin-panties", bgColor: BlissColor.fromString("#FC96D7")},
         {displayName: "High", folderLocation: "high", bgColor: BlissColor.fromString("#FC96D7")},
         {displayName: "M.I.L.F", folderLocation: "milf", bgColor: BlissColor.fromString("#FC96D7")},
         {displayName: "Cocoa", folderLocation: "cocoa", bgColor: BlissColor.fromString("#A0D1FF")},
         {displayName: "Eggnog", folderLocation: "eggnog", bgColor: BlissColor.fromString("#A0D1FF")},
         {displayName: "Winter Horroland", folderLocation: "winter-horrorland", bgColor: BlissColor.fromString("#A0D1FF")},
         {displayName: "Senpai", folderLocation: "senpai", bgColor: BlissColor.fromString("#FF78BF")},
         {displayName: "Roses", folderLocation: "roses", bgColor: BlissColor.fromString("#FF78BF")},
         {displayName: "Thorns", folderLocation: "thorns", bgColor: BlissColor.fromString("#FF78BF")},
         {displayName: "Ugh", folderLocation: "ugh", bgColor: BlissColor.fromString("#F6B684")},
         {displayName: "Guns", folderLocation: "guns", bgColor: BlissColor.fromString("#F6B684")},
         {displayName: "Stress", folderLocation: "stress", bgColor: BlissColor.fromString("#F6B684")},
    ];

    override function create() {
        super.create();

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBGDesat")));
        bg.scrollFactor.set();
        bg.scale.set(1.2, 1.2);
        bg.screenCenter();

        add(songsGroup = new Group<Alphabet>());

        for (i in 0...songs.length) {
            var newSong:Alphabet = new Alphabet(0, (60 * i), songs[i].displayName, true);
            newSong.isMenuItem = true;
            newSong.targetY = i;
            songsGroup.add(newSong);
        }

        updateSelection();
    }

    override function update(elapsed:Float) {
        if (Game.keys.justPressed(UP)) updateSelection(-1);
        if (Game.keys.justPressed(DOWN)) updateSelection(1);

        super.update(elapsed);
    }

    var bgTween:Tween;

    public function updateSelection(newSelection:Int = 0):Void {
        curSelection = bliss.engine.utilities.MathUtil.wrap(curSelection + newSelection, 0, songs.length - 1);

        var i:Int = 0;
        for (item in songsGroup.members) {
            item.targetY = i - curSelection;
            item.alpha = item.targetY == 0 ? 1.0 : 0.6;
            i++;
        }

        if (songs[curSelection] != null) {
            if (songs[curSelection].bgColor == null)
                songs[curSelection].bgColor = BlissColor.COLOR_GRAY;
            if (bgTween != null) bgTween.cancel();
            bgTween = Tween.color(bg, 0.85, bg.tint, songs[curSelection].bgColor);
        }
    }
}
