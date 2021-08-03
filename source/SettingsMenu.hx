package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;

import Discord.DiscordClient;

using StringTools;

class SettingsMenu extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		// Updating Discord Rich Presence
		DiscordClient.changePresence("Inside Settings...", null);
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);
		
		grpSongs = new FlxTypedGroup<Alphabet>();

		fuckTheClearance();

		if (!FlxG.sound.music.playing)
		{
		FlxG.sound.playMusic(Paths.music('brosucks'), 0, true);
		FlxG.sound.music.fadeIn(2, 0, 0.8);
		}
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}
	
	public function fuckTheClearance():Void
	{
	remove(grpSongs);
	grpSongs = new FlxTypedGroup<Alphabet>();
	songs.splice(0, songs.length);
	add(grpSongs);
	
	var ourFuckingList:Array<String> = [];
	
	var downScrollShit:String = (Highscore.getDownscroll()) ? "On" : "Off";
	var inputShit:String = (Highscore.getInput()) ? "On" : "Off";
	var shaderShit:String = (Highscore.getShaders()) ? "On" : "Off";
	var betterInputShit:String = (Highscore.getBetterInput()) ? "On" : "Off";
	var censorShit:String = (Highscore.getCensor()) ? "On" : "Off";
	
	ourFuckingList.push('Downscroll $downScrollShit');
	ourFuckingList.push('New Input System $inputShit');
	ourFuckingList.push('Custom Keybindings');
	ourFuckingList.push('Visual Effects');
	ourFuckingList.push('Shaders $shaderShit');
	ourFuckingList.push('Ghost Tapping $betterInputShit');
	ourFuckingList.push('Censor $censorShit');
	
	for (shit in ourFuckingList)
	{
		songs.push(new SongMetadata(shit, 1, 'gf'));
	}
	
	var fuckingBool:Array<Bool> = [
	Highscore.getDownscroll(),
	Highscore.getInput(),
	false,
	false,
	Highscore.getShaders(),
	Highscore.getBetterInput(),
	Highscore.getCensor()
	];

	for (i in 0...songs.length)
	{
		var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
		songText.isMenuItem = true;
		songText.noAnim = true;
		songText.targetY = i;
		#if !web
		if (fuckingBool[i])
		{
			songText.color = 0xffff33;
		}
		#end
		grpSongs.add(songText);
	}
	changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F)
		{
		FlxG.fullscreen = !FlxG.fullscreen;
		}

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
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			switch(curSelected)
			{
				case 0:
					Highscore.toggleDownscroll();
				case 1:
					Highscore.toggleInput();
				case 2:
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new KeysMenu());
				case 3:
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new EffectsMenu());
				case 4:
					Highscore.toggleShaders();
				case 5:
					Highscore.toggleBetterInput();
				case 6:
					Highscore.toggleCensor();
			}
			fuckTheClearance();
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
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