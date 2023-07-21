package;

import bliss.Project;
import bliss.backend.graphics.BlissColor;
import bliss.engine.system.Game;

class Main {
	static function main() {
		Project.windowBGColor = BlissColor.COLOR_BLACK;
		Project.windowTitle = "Friday Night Funkin'";
		Project.windowWidth = 1280;
		Project.windowHeight = 720;

		Game.create(240, new funkin.scenes.TitleScreen());
	}
}
