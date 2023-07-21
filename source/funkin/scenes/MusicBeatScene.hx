package funkin.scenes;

import bliss.engine.Scene;

import funkin.game.Conductor;

class MusicBeatScene extends Scene {
	public var beatContainer:Conductor;

	public function new() {
		super();
		beatContainer = new Conductor();
		beatContainer.connect(STEP,    stepHit);
		beatContainer.connect(BEAT,    beatHit);
		beatContainer.connect(MEASURE, measureHit);
	}

	override function update(elapsed:Float) {
		beatContainer.update(elapsed);
		super.update(elapsed);
	}

	override function destroy() {
		beatContainer.destroy();
		super.destroy();
	}

	public function stepHit(curStep:Int) {}
	public function beatHit(curBeat:Int) {}
	public function measureHit(curMeasure:Int) {}
}