package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'crystal')
	{
		super(x);

		this.character = character;

		var tex = Paths.getSparrowAtlas('campaign_menu_UI_characters');
		frames = tex;

		/* animation.addByPrefix('bf', "BF idle dance white", 24);
		animation.addByPrefix('bfConfirm', 'BF HEY!!', 24, false);
		animation.addByPrefix('gf', "GF Dancing Beat WHITE", 24);
		animation.addByPrefix('dad', "Dad idle dance BLACK LINE", 24);
		animation.addByPrefix('spooky', "spooky dance idle BLACK LINES", 24);
		animation.addByPrefix('pico', "Pico Idle Dance", 24);
		animation.addByPrefix('mom', "Mom Idle BLACK LINES", 24);
		animation.addByPrefix('parents-christmas', "Parent Christmas Idle", 24);
		animation.addByPrefix('senpai', "SENPAI idle Black Lines", 24); */
		
		// Parent Christmas Idle
		// NO IDLE LOL
		
		animation.addByPrefix('crystal', '01idle', 24);
		animation.addByPrefix('bao', '1idel', 24);
		animation.addByPrefix('kuna', 'GF Dancing Beat copy', 24);

		if (character != '')
			animation.play(character);
		updateHitbox();
	}
}
