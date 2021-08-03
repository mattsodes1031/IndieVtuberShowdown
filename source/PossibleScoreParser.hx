package;

import Song.SwagSong;
import Section.SwagSection;
import openfl.utils.Assets;

class PossibleScoreParser
{
	public static function get(song:String, difficulty:Int):Int
	{
		var toRet:Int = 0;
		if (CachedPossibleScores.exists(song, difficulty))
			toRet = CachedPossibleScores.get(song, difficulty);
		return toRet;
	}

	public static function parse(song:String, difficulty:Int):Int
	{
		var toRet:Int = 0;
		var pathPrefix:String = "";
		switch (difficulty)
		{
			case 0:
				pathPrefix = "-easy";
			case 2:
				pathPrefix = "-hard";
		}
		if (Song.fetch(song + pathPrefix, song) != "NULL")
		{
			var curSong:SwagSong = Song.loadFromJson(song + pathPrefix, song);
			if (curSong.notes.length > 0)
			{
				var daBpm:Int = curSong.bpm;
				var crochet:Float = ((60 / daBpm) * 1000);
				var stepCrochet:Float = crochet / 4;
				for (songSection in curSong.notes)
				{
					var mustHitSection:Bool = songSection.mustHitSection;
					for (note in songSection.sectionNotes)
					{
						var noteVal:Int = note[1];
						var notes1:Array<Int> = [0, 1, 2, 3];
						var notes2:Array<Int> = [4, 5, 6, 7];
						if ((mustHitSection && notes1.contains(noteVal)) || (!mustHitSection && notes2.contains(noteVal)))
						{
							toRet += PlayState.maxAddScore;
							/*var susLength:Float = note[2];
							susLength /= stepCrochet;
							for (susNote in 0...Math.floor(susLength))
								toRet += PlayState.maxAddScore;*/
						}
					}
				}
			}
		}
		return toRet;
	}
}