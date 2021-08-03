package;

class CachedPossibleScores
{
	public static var cached:Bool = false;
	#if (haxe >= "4.0.0")
	public static var cachedData:Map<String, Int> = new Map();
	#else
	public static var cachedData:Map<String, Int> = new Map<String, Int>();
	#end
	
	public static function cache(songList:Array<String>):Void
	{
		for (song in songList)
		{
			for (diff in 0...3)
			{
				var diffPrefix:String = "";
				switch (diff)
				{
					case 0:
						diffPrefix = "-easy";
					case 2:
						diffPrefix = "-hard";
				}
				cachedData.set(song + diffPrefix, PossibleScoreParser.parse(song, diff));
			}
		}
		cached = true;
	}
	
	public static function exists(song:String, diff:Int):Bool
	{
		return cachedData.exists(song + getDiff(diff));
	}
	
	public static function getDiff(diff:Int):String
	{
		var diffPrefix:String = "";
		switch (diff)
		{
			case 0:
				diffPrefix = "-easy";
			case 2:
				diffPrefix = "-hard";
		}
		return diffPrefix;
	}
	
	public static function get(song:String, diff:Int):Int
	{
		return cachedData.get(song + getDiff(diff));
	}
}