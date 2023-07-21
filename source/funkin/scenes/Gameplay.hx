package funkin.scenes;

import bliss.engine.utilities.AtlasFrames;
import bliss.engine.Sprite;
import bliss.engine.Scene;

class Gameplay extends Scene {
    var bfFNF:Sprite;
    var bfFNF2:Sprite;

    override function create() {
        add(bfFNF = new Sprite(50, 50));
        bfFNF.frames = AtlasFrames.fromSparrow("assets/images/characters/bf/normal.png", "assets/images/characters/bf/normal.xml");
        bfFNF.animation.addByPrefix("idle", "BF idle dance", 24, true);
        bfFNF.animation.play("idle");
        bfFNF.centerOrigin();
        bfFNF.screenCenter();
        
        add(bfFNF2 = new Sprite(50, 50));
        bfFNF2.frames = AtlasFrames.fromSparrow("assets/images/characters/bf/normal.png", "assets/images/characters/bf/normal.xml");
        bfFNF2.animation.addByPrefix("idle", "BF idle dance", 24, true);
        bfFNF2.animation.play("idle");
        bfFNF2.centerOrigin();
        bfFNF2.screenCenter();
        bfFNF2.scale.set(2, 0.5);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        bfFNF.angle += elapsed * 25;
    }
}