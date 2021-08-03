package;

import flixel.FlxG;
import flixel.FlxState;

import openfl.utils.Assets;

using StringTools;

class SoundCacheState extends FlxState
{
	var check:Bool = false;
	var total:Int = 0;
	var loaded:Int = 0;

	override function create()
	{
		var text:Alphabet = new Alphabet(0, 0, "Caching Sound", true);
		text.screenCenter();
		add(text);
		
		super.create();
		
		cache();
	}
	
	public function cache():Void
	{
		#if sys
		var list:Array<String> = Assets.list();
		var usedList:Array<String> = [];
		for (item in list)
		{
			if (item.endsWith('.' + Paths.SOUND_EXT) && item.contains(':'))
			{
				usedList.push(item);
			}
		}
		total = usedList.length;
		check = true;
		for (id in usedList)
		{
			sys.thread.Thread.create(() -> {
				FlxG.sound.cache(id);
				loaded++;
			});
		}
		#else
		start();
		#end
	}
	
	public function start():Void
	{
		FlxG.switchState(new TitleState());
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		#if sys
		if (check && loaded >= total)
		{
			check = false;
			start();
		}
		#end
	}
}