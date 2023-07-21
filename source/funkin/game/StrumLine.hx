package funkin.game;

import haxe.ds.Vector;

enum abstract StrumLineType(Int) from Int to Int {
	var OPPONENT = 0;
	var PLAYER = 1;
	var ADDITIONAL = 2;
}