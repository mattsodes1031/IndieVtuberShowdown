package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;

import haxe.Json;
import openfl.utils.Assets;
import haxe.Http;

import Discord.DiscordClient;

using StringTools;

class MediaMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	
	var medias:Array<String> = [];
	var mediaLinks:Array<String> = [];
	
	public var person:String;
	
	public function new(person:String)
	{
		super();
		this.person = person;
	}

	override function create()
	{
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.inst('whale-waltz'));
		}
		
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Inside The Credits Menu...", null);
	
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
		
		var personText:FlxText = new FlxText(0, 0, FlxG.width, person, 32);
		personText.setFormat('Nokia Cellphone FC Small', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		personText.screenCenter(X);
		add(personText);
		
		var smText:FlxText = new FlxText(0, 0, FlxG.width, "SOCIAL MEDIAS", 32);
		smText.setFormat('Nokia Cellphone FC Small', 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		smText.screenCenter(X);
		smText.y = personText.y + personText.height;
		add(smText);
		
		#if sys
		sys.thread.Thread.create(() -> {
		#end
		var http:Http = new Http("https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/characters.media");
		http.onData = function(data:String)
		{
			try
			{
				var parsed:Dynamic = Json.parse(data);
				#if sys
				sys.io.File.saveContent('assets/data/characters.media', data);
				#end
				fallback2(parsed);
			}
			catch (e:Dynamic)
			{
				fallback();
			}
		}
		http.onError = function(e:Dynamic)
		{
			fallback();
		}
		http.request();
		#if sys
		});
		#end

		super.create();
	}
	
	function fallback():Void
	{
		var parsed:Dynamic = Json.parse(Assets.getText('assets/data/characters.media'));
		fallback2(parsed);
	}
	
	function fallback2(parsed:Dynamic):Void
	{
		var parsed2:Dynamic = Reflect.getProperty(parsed, person);
		trace(Reflect.fields(parsed2));
		for (media in Reflect.fields(parsed2))
		{
			medias.push(media);
			mediaLinks.push(Reflect.getProperty(parsed2, media));
		}
		doCrap();
	}
	
	function doCrap():Void
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...medias.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, medias[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		changeSelection();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		
		if (Highscore.getInput() && FlxG.mouse.wheel != 0)
		{
			changeSelection(FlxG.mouse.wheel * -1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new CreditsMenu());
		}

		if (accepted)
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', [mediaLinks[curSelected], "&"]);
			#else
			FlxG.openURL(mediaLinks[curSelected]);
			#end
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = medias.length - 1;
		if (curSelected >= medias.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}