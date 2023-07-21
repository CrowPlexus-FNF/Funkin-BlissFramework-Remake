package funkin.game;

import haxe.ds.ArraySort;

import bliss.backend.interfaces.IDestroyable;

import bliss.engine.utilities.Signal;
import bliss.engine.utilities.SortUtil;

import funkin.game.ChartFormat;

typedef InternalBeatMap = Map<BeatType, BeatStructure>;

enum abstract BeatMap(InternalBeatMap) from InternalBeatMap to InternalBeatMap {
	public inline function new() {
		this = new InternalBeatMap();
	}

	public inline function updateSet(container:Conductor, type:BeatType, value:BeatStructure) {
		var curValue:BeatStructure = this.get(type);
		if(container != null && curValue != null && value != null && curValue.rounded != value.rounded)
			container.emit(type, value.rounded);

		this.set(type, value);
	}

	public inline function clear() {
		this.clear();
	}
}

enum abstract BeatType(String) from String to String {
	var STEP = "step";
	var BEAT = "beat";
	var MEASURE = "measure";
}

typedef BeatStructure = {
	var decimal:Float;
	var rounded:Int;
}

typedef BPMChange = {
	var time:Float;
	var step:Float;
	var bpm:Float;
}

class Conductor implements IDestroyable {
	/**
	 * The current time of the music attached
	 * to this conductor.
	 */
	public static var time:Float = 0.0;

	/**
	 * The current BPM of the music attached to this conductor.
	 */
	public static var bpm(default, set):Float = 100.0;

	/**
	 * A multiplier to how fast this conductor processes
	 * steps, beats, and measure.
	 * 
	 * Only applies in gameplay.
	 */
	public static var rate:Float = 1;

	/**
	 * The amount of time in-between a step.
	 */
	public static var stepDelta(default, null):Float = 0.0;

	/**
	 * The amount of time in-between a beat.
	 */
	public static var beatDelta(default, null):Float = 0.0;

	/**
	 * The amount of beats that happen per measure.
	 */
	public static var beatsPerMeasure:Int = 4;

	/**
	 * The amount of steps that happen per beat.
	 */
	public static var stepsPerBeat:Int = 4;

	/**
	 * Affects your range for hitting notes.
	 * 
	 * Use `safeZoneOffset` for notes and this variable
	 * for setting it.
	 */
	public static var safeFrames(default, set):Int = 10;

	/**
	 * The actual range that notes can be hit within.
	 */
	public static var safeZoneOffset(default, null):Float = (safeFrames / 60) * 1000.0;

	/**
	 * The list of BPM changes this song will go through.
	 */
	public static var bpmChanges:Array<BPMChange> = [];

	/**
	 * Stores the value of things like the current beat,
	 * step, measure, all that stuff.
	 * 
	 * Example usage:
	 * ```haxe
	 * Conductor.beatValues.get(STEP);
	 * Conductor.beatValues.get(BEAT);
	 * Conductor.beatValues.get(MEASURE);
	 * ```
	 */
	public var beatValues:BeatMap = new BeatMap();

	/**
	 * Sets up this conductor with data from a given song's chart.
	 * 
	 * @param chart  The chart to setup the conductor with.
	 */
	public static inline function setupSong(chart:ChartFormat) {
		bpm = chart?.meta?.bpm ?? 100.0;

		beatsPerMeasure = chart?.meta?.timeScale?.bpm ?? 4;
		stepsPerBeat = chart?.meta?.timeScale?.spb ?? 4;

		setupBPMChanges(chart);
	}

	/**
	 * Sets up a list of BPM changes from a given song's chart.
	 * 
	 * @param chart  The chart to setup the conductor's bpm changes with.
	 */
	public static inline function setupBPMChanges(chart:ChartFormat) {
		bpmChanges = [];
		if(chart == null || chart.events == null) return;

		var curBPM:Float = chart?.meta?.bpm ?? 100.0;
		var time:Float = 0;
		var step:Float = 0;

		for(event in chart.events) {
			for(e in event.dataList) {
				if(e.type == BPM_CHANGE && e.parameters != null) {
					if(Std.parseFloat(e.parameters[0]) == curBPM) continue;

					var steps:Float = (event.time - time) / ((60.0 / curBPM) * 1000.0 / beatsPerMeasure);
					step += steps;
					time = event.time;
					curBPM = Std.parseFloat(e.parameters[0]);

					bpmChanges.push({
						step: step,
						time: time,
						bpm: curBPM
					});
				}
			}
		}

		ArraySort.sort(bpmChanges, (a, b) -> return SortUtil.byValues(SortUtil.ASCENDING, a.time, b.time));
	}

	/**
	 * Connects a listener function to execute on
	 * steps, beats, or measures/sections.
	 * 
	 * @param type      Whether or not this listener executes on steps, beats, or sections.
	 * @param listener  The listener to connect to the beat type.
	 */
	public inline function connect(type:BeatType, listener:Int->Void) {
		if(!_events.exists(type))
			_events.set(type, new TypedSignal<Int->Void>());

		_events.get(type).connect(listener);
	}

	/**
	 * Disonnects a listener function from executing on
	 * steps, beats, or measures/sections.
	 * 
	 * @param type      Whether or not this listener stops executing on steps, beats, or sections.
	 * @param listener  The listener to disconnect from the beat type.
	 */
	public inline function disconnect(type:BeatType, listener:Int->Void) {
		if(!_events.exists(type))
			_events.set(type, new TypedSignal<Int->Void>());

		_events.get(type).disconnect(listener);
	}

	/**
	 * Disonnects all listener functions from executing on
	 * steps, beats, or measures/sections.
	 * 
	 * @param type  Whether or not each listener disconnects on steps, beats, or sections.
	 */
	public inline function disconnectAll(type:BeatType) {
		if(!_events.exists(type))
			_events.set(type, new TypedSignal<Int->Void>());

		_events.get(type).disconnectAll();
	}

	/**
	 * Emits/runs all of the listener functions connected
	 * to steps, beats, or measures/sections.
	 * 
	 * @param type  Whether or not execute each listener on steps, beats, or sections.
	 */
	public inline function emit(type:BeatType, value:Int) {
		if(_events.exists(type))
			_events.get(type).emit(value);
	}

	//##-- VARIABLES/FUNCTIONS YOU PROBABLY SHOULDN'T TOUCH!! --##//
	@:noCompletion
	private var _events:Map<BeatType, TypedSignal<Int->Void>> = [];

	@:noCompletion
	private var _curBPMChange:Int = 0;

	public function new() {}

	public inline function update(elapsed:Float) {
		// Execute BPM changes as the song goes on.
		var bpmChanges:Array<BPMChange> = Conductor.bpmChanges;
		var lastBPMChange:BPMChange = {time: 0, step: 0, bpm: 0};

		if(bpmChanges[_curBPMChange] != null && time >= bpmChanges[_curBPMChange].time)
			bpm = (lastBPMChange = bpmChanges[_curBPMChange++]).bpm;

		// Calculate beat values
		var value:Float = (time - lastBPMChange.time) / stepDelta;

		beatValues.updateSet(this, STEP,    {decimal: value,      rounded: Math.floor(value)});
		beatValues.updateSet(this, BEAT,    {decimal: value /= 4, rounded: Math.floor(value)});
		beatValues.updateSet(this, MEASURE, {decimal: value /= 4, rounded: Math.floor(value)});
	}

	public function destroy() {
		beatValues.clear();
		beatValues = null;

		for(e in _events)
			e.disconnectAll();
		
		_events = null;
	}

	@:noCompletion
	private static inline function set_bpm(v:Float):Float {
		beatDelta = (60.0 / v) * 1000.0;
		stepDelta = beatDelta / 4.0;
		return bpm = v;
	}

	@:noCompletion
	private static inline function set_safeFrames(v:Int):Int {
		safeZoneOffset = (v / 60) * 1000.0;
		return safeFrames = v;
	}
}