package funkin.game;

import haxe.ds.Vector;
import funkin.game.StrumLine.StrumLineType;

enum abstract ChartCharacterPosition(String) from String to String {
	var OPPONENT = "opponent";
	var SPECTATOR = "spectator";
	var PLAYER = "player";
}

enum abstract ChartEventType(String) from String to String {
	var CAMERA_PAN = "Camera Pan";
	var BPM_CHANGE = "BPM Change";
	var ADD_CAMERA_ZOOM = "Add Camera Zoom";
	var CAMERA_FLASH = "Camera Flash";
	var SCREEN_SHAKE = "Screen Shake";
	var SET_GF_SPEED = "Set GF Speed";
	var CAMERA_FOLLOW_POS = "Camera Follow Pos";
	var PLAY_ANIMATION = "Play Animation";
	var HEY = "Hey";
}

typedef ChartEvent = {
	/**
	 * The position of this event in milliseconds.
	 */
	var time:Float;

	/**
	 * A list of actual event data for this event.
	 */
	var dataList:Vector<ChartEventData>;
}

typedef ChartEventData = {
	/**
	 * The type of this event.
	 * 
	 * Here are some built-in types:
	 * 
	 * - Camera Pan
	 * - BPM Change
	 * - Add Camera Zoom
	 * - Camera Flash
	 * - Change Character
	 * - Screen Shake
	 * - Set GF Speed
	 * - Camera Follow Pos
	 * - Hey
	 */
	var type:ChartEventType;

	/**
	 * The parameters provided to the event when it is fired.
	 */
	var parameters:Vector<String>;
}

typedef ChartTimeScale = {
	/**
	 * Beats per measure
	 */
	var bpm:Int;

	/**
	 * Steps per beat
	 */
	var spb:Int;
}

typedef ChartMetadata = {
	/**
	 * The name of this song.
	 */
	var name:String;

	// Skinning/stylizing gameplay shit
	/**
	 * The style used for notes.
	 */
	var noteStyle:String;

	/**
	 * The style used for gameplay UI.
	 */
	var uiStyle:String;

	/**
	 * The stage/background used for gameplay.
	 */
	var stage:String;

	//##-- Beat related shit --##//
	/**
	 * The beats per minute of this song.
	 */
	var bpm:Float;

	/**
	 * How fast the notes scroll.
	 * 
	 * Lower is slower, Higher is faster.
	 */
	var speed:Float;

	/**
	 * The time scale of this song.
	 * 
	 * bpm = Beats per measure,
	 * spb = Steps per beat
	 */
	var timeScale:ChartTimeScale;

	//##--------- DON'T TOUCH! ---------##//
	//##-- OPTIONAL TO PREVENT SAVING --##//
	var ?_song:String;
}

typedef ChartNote = {
	/**
	 * The position of this note in milliseconds.
	 */
	var hitTime:Float;

	/**
	 * The direction of this note.
	 * 
	 * 0 = Left
	 * 1 = Down
	 * 2 = Up
	 * 3 = Right
	 */
	var direction:Int;

	/**
	 * The sustain length of this note in milliseconds.
	 */
	var length:Float;

	/**
	 * The type of this note.
	 * 
	 * You can make your own note types to do anything you want!
	 * There are 2 built-in types if you don't want to make any:
	 * 
	 * Hurt & Warning
	 */
	var type:String;

	var ?parent:ChartStrumLine;
}

typedef ChartStrumLine = {
	/**
	 * The characters that are attached to
	 * this strumline.
	 */
	var characters:Vector<String>;

	/**
	 * The notes that are attached to
	 * this strumline.
	 */
	var notes:Vector<ChartNote>;

	/**
	 * The type of this strumline.
	 * 
	 * 0 = Opponent, Hits notes on this strumline automatically unless Play As Opponent is enabled.
	 * 1 = Player, Requires keyboard input to hit notes on this strumline.
	 * 2 = Additional, Hits notes on this strumline automatically no matter what.
	 */
	var type:StrumLineType;

	/**
	 * Which side of the stage this strumline's
	 * characters go to.
	 * 
	 * - Opponent = Left Side
	 * - Spectator = Middle
	 * - Player = Right Side
	 */
	var position:ChartCharacterPosition;

	/**
	 * Whether or not this strumline is visible.
	 * 
	 * If not specified, this strumline will be visible.
	 */
	var ?visible:Bool;

	var ?posMult:Float;
}

typedef ChartFormat = {
	/**
	 * The metadata of this chart.
	 * 
	 * Contains info like BPM, scroll speed, etc.
	 */
	var meta:ChartMetadata;

	/**
	 * The strumlines of this chart.
	 * 
	 * Contains info like the notes and
	 * characters of this chart.
	 */
	var strumLines:Vector<ChartStrumLine>;

	/**
	 * The events that run at certain points
	 * during the song.
	 */
	var events:Vector<ChartEvent>;
}