package funkin.scenes;

import bliss.engine.system.Game;
import funkin.ui.Alphabet;
import bliss.engine.utilities.AtlasFrames;
import bliss.engine.Sprite;

class TitleScreen extends MusicBeatScene {
    override function create() {
        super.create();
        Conductor.bpm = 102;
        Game.sound.playMusic(Paths.music("freakyMenu"));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        Conductor.time = Game.sound.music.time;
    }
}