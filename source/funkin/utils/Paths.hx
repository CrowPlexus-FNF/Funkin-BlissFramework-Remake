package funkin.utils;

import bliss.engine.utilities.AtlasFrames;

class Paths {
    public static inline function asset(path:String):String {
        return 'assets/$path';
    }

    public static inline function image(path:String):String {
        return asset('images/$path.png');
    }

    public static function getSparrowAtlas(path:String):AtlasFrames {
        return AtlasFrames.fromSparrow(image(path), xml('images/$path'));
    }

    public static inline function music(path:String):String {
        return asset('music/$path.ogg');
    }

    public static inline function sound(path:String):String {
        return asset('sounds/$path.ogg');
    }

    public static inline function xml(path:String):String {
        return asset('$path.xml');
    }

    public static inline function txt(path:String):String {
        return asset('$path.txt');
    }

    public static inline function json(path:String):String {
        return asset('$path.json');
    }
}