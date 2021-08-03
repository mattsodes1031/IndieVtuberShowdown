package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class ThankYouState extends FlxState
{
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		var txt:String = "Thank you for playing the demo\n
		Follow @blitz_crystal for more Indie VTuber Showdown updates!\n";
		var teamTxt:String = "Team:
		Crystal Blitz - Creator/Charter
		GWebDev - Coder (who coded this thing just now lol)
		disky - Coder
		elikapika - Artist
		staromelo - BG Artist
		Fpeyro - Composer
		bee_hanii - Cutscenes
		Tama - Icons
		Sai - Bao's Vocals
		Somniatica - Artemis' Vocals
		fueg0 - Mac Builder\n";

		var thankyou:FlxText = new FlxText(0, 0, 0, txt, 25);
		thankyou.setFormat(Paths.font('animeace2_reg.ttf'), 25);
		thankyou.screenCenter(X);
		add(thankyou);
		
		var team:FlxText = new FlxText(0, 0, 0, teamTxt, 14);
		team.setFormat(Paths.font('animeace2_reg.ttf'), 14);
		team.y = FlxG.height - team.height;
		add(team);
		
		var pressEsc:FlxText = new FlxText(0, 0, 0, "Press ESC Or Backspace To Go Back...", 32);
		pressEsc.x = FlxG.width - pressEsc.width;
		add(pressEsc);
		
		thankyou.y = pressEsc.height;
		
		var bao:Character = new Character(0, 0, "bao");
		var baoScale:Float = 0.7;
		bao.scale.set(baoScale, baoScale);
		bao.updateHitbox();
		bao.x = FlxG.width - bao.width;
		bao.y = FlxG.height - bao.height;
		add(bao);
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (controls.BACK)
		{
			FlxG.switchState(new StoryMenuState(true));
		}
	}
}