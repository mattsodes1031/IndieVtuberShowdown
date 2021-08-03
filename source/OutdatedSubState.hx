package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

import haxe.Http;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var daVer:String = "I DONT KNOW";

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"So\n" +
			"Your Version Of IVS Is Outdated...\n" +
			"You Have Version " + CurrentVersion.get() + "\n" +
			"The Latest Version Out There Is " + daVer + "\n" +
			"What Are You Waiting For...\n\n" +
			"PRESS ENTER If You Want To Go To The Gamebanana Page!\n" +
			"Or Back To Go To The Menu",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			#if sys
			sys.thread.Thread.create(() -> {
			#end
			var http:Http = new Http("https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/current.gamebanana");
			
			http.onData = function(data:String)
			{
				FlxG.openURL(data);
			}
			
			http.onError = function(error)
			{
				trace('request error: $error');
			}
			
			http.request();
			#if sys
			});
			#end
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
