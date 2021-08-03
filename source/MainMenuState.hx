package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
//import io.newgrounds.NG;
import lime.app.Application;

import flixel.FlxCamera;
import flixel.math.FlxPoint;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'credit menu', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	// var camFollow:FlxObject;
	
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var scrollBG:FlxSprite;
	var bg4:FlxSprite;
	
	var arrow1:FlxSprite;
	var arrow2:FlxSprite;
	
	var mainCam:FlxCamera;
	var scrollCam1:FlxCamera;
	var scrollCam2:FlxCamera;

	var force:Bool = false;
	
	public function new(Force:Bool = false)
	{
		super();
		force = Force;
	}

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		mainCam = new FlxCamera();
		mainCam.bgColor.alpha = 0;
		
		scrollCam1 = new FlxCamera();
		scrollCam1.bgColor.alpha = 0;
		
		scrollCam2 = new FlxCamera();
		scrollCam2.bgColor.alpha = 0;
		
		FlxG.cameras.reset(scrollCam1);
		FlxG.cameras.add(scrollCam2);
		FlxG.cameras.add(mainCam);
		
		FlxCamera.defaultCameras = [mainCam];

		if (!FlxG.sound.music.playing || force)
		{
			FlxG.sound.playMusic(Paths.inst('whale-waltz'));
		}

		persistentUpdate = persistentDraw = true;
		
		bg4 = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
		bg4.scrollFactor.x = 0;
		bg4.scrollFactor.y = 0.18;
		bg4.updateHitbox();
		bg4.screenCenter();
		bg4.alpha = 0;
		bg4.antialiasing = true;
		add(bg4);
		
		scrollBG = new FlxSprite();
		scrollBG.frames = Paths.getPackerAtlas('scrollbg');
		scrollBG.animation.addByPrefix('scroll', 'scrollbg_', 10);
		scrollBG.animation.play('scroll', true);
		scrollBG.antialiasing = true;
		scrollBG.screenCenter(X);
		scrollBG.cameras = [scrollCam1, scrollCam2];
		scrollBG.alpha = 0;
		add(scrollBG);
		
		scrollCam2.focusOn(FlxPoint.get(FlxG.width / 2, -scrollBG.height + FlxG.height / 2));
		
		bg2 = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue'));
		bg2.scrollFactor.x = 0;
		bg2.scrollFactor.y = 0.18;
		// bg2.setGraphicSize(Std.int(bg4.width * 1.1));
		bg2.updateHitbox();
		bg2.alpha = 0;
		bg2.screenCenter();
		bg2.antialiasing = true;
		add(bg2);
		
		bg1 = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg1.scrollFactor.x = 0;
		bg1.scrollFactor.y = 0.18;
		// bg1.setGraphicSize(Std.int(bg4.width * 1.1));
		bg1.updateHitbox();
		bg1.screenCenter();
		bg1.antialiasing = true;
		add(bg1);

		/*var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);*/
		
		magenta = new FlxSprite(bg4.x, bg4.y).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.updateHitbox();
		magenta.visible = false;
		magenta.screenCenter();
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// trace(bg4.width);
		// trace(magenta.width);
		// bg4.setGraphicSize(Std.int(bg4.width * 1.1));
		// bg4.screenCenter();

		// camFollow = new FlxObject(0, 0, 1, 1);
		// add(camFollow);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');
		var tex2 = Paths.getSparrowAtlas('story_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			if (optionShit[i] == 'story mode')
				menuItem.frames = tex2;
			else
				menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter();
			menuItem.y += FlxG.height * menuItem.ID;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}
		
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		
		arrow1 = new FlxSprite(0, 10);
		arrow1.frames = ui_tex;
		arrow1.animation.addByPrefix('idle', "arrow left");
		arrow1.animation.addByPrefix('press', "arrow push left");
		arrow1.animation.play('idle');
		arrow1.angle = 90;
		arrow1.updateHitbox();
		arrow1.screenCenter(X);
		add(arrow1);
		
		arrow2 = new FlxSprite(0, 0);
		arrow2.frames = ui_tex;
		arrow2.animation.addByPrefix('idle', "arrow right");
		arrow2.animation.addByPrefix('press', "arrow push right");
		arrow2.animation.play('idle');
		arrow2.angle = 90;
		arrow2.updateHitbox();
		arrow2.screenCenter(X);
		arrow2.y = FlxG.height - arrow2.height - 10;
		add(arrow2);

		// mainCam.follow(camFollow, null, 0.06);

		var daString:String = "GWebDev IDK Engine v1.0.0 (Hello to whoever is playing this)\nIVS v" + CurrentVersion.get() + "\nFNF v" + Application.current.meta.get('version') + " (Commit d3cd2e2)\n";
		var daMultiplier:Int = 3;
		
		var guide:FlxText = new FlxText(0, 0, 0, "Press Up Or Down To Navigate\nAND DON'T IGNORE TUTORIAL!\n", 12);
		guide.scrollFactor.set();
		guide.setFormat("Nokia Cellphone FC Small", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		guide.x = FlxG.width - guide.width;
		add(guide);
		
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18 * daMultiplier, 0, daString, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;
	
	

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
			
			if (controls.UP)
				arrow1.animation.play('press');
			else
				arrow1.animation.play('idle');
			if (controls.DOWN)
				arrow2.animation.play('press');
			else
				arrow2.animation.play('idle');

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					scrollBG.color = 0xFF0000FF;
					if (optionShit[curSelected] != 'credit menu')
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");
										
									case 'credit menu':
										FlxG.switchState(new CreditsMenu());
										trace("Credits Selected");

									case 'options':
										FlxG.switchState(new SettingsMenu());
								}
							});
						}
					});
				}
			}
		}
		
		if (scrollBG.alpha > 0)
		{
			scrollBG.y -= TitleState.scrollPixelsPerSecond / FlxG.updateFramerate;
				
			if (scrollBG.y < -scrollBG.height)
			{
				scrollBG.y = 0;
			}
		}
		else
			scrollBG.y = 0;

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		var beforeSelected:Int = 0;
		beforeSelected += curSelected;
	
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
			
			var toMove:Int = 0;
			
			var daOption:String = optionShit[curSelected];
			switch (daOption)
			{
				case 'story mode':
					if (spr.ID == beforeSelected)
						switch (optionShit[spr.ID])
						{
							case 'options':
								toMove = 1;
							case 'freeplay':
								toMove = 2;
						}
					if (spr.ID == curSelected)
						switch (optionShit[beforeSelected])
						{
							case 'options':
								toMove = 3;
							case 'freeplay':
								toMove = 4;
						}
				case 'freeplay':
					if (spr.ID == beforeSelected)
						switch (optionShit[spr.ID])
						{
							case 'story mode':
								toMove = 1;
							case 'credit menu':
								toMove = 2;
						}
					if (spr.ID == curSelected)
						switch (optionShit[beforeSelected])
						{
							case 'story mode':
								toMove = 3;
							case 'credit menu':
								toMove = 4;
						}
				case 'credit menu':
					if (spr.ID == beforeSelected)
						switch (optionShit[spr.ID])
						{
							case 'freeplay':
								toMove = 1;
							case 'options':
								toMove = 2;
						}
					if (spr.ID == curSelected)
						switch (optionShit[beforeSelected])
						{
							case 'freeplay':
								toMove = 3;
							case 'options':
								toMove = 4;
						}
				case 'options':
					if (spr.ID == beforeSelected)
						switch (optionShit[spr.ID])
						{
							case 'credit menu':
								toMove = 1;
							case 'story mode':
								toMove = 2;
						}
					if (spr.ID == curSelected)
						switch (optionShit[beforeSelected])
						{
							case 'credit menu':
								toMove = 3;
							case 'story mode':
								toMove = 4;
						}
			}
			
			if (toMove > 0)
			{
				var del:Float = 0.25;
				var daEase:Float->Float = FlxEase.quadOut;
				var added:Float = FlxG.height / 2 + spr.y / 2;
				
				switch (toMove)
				{
					case 1:
						spr.screenCenter();
						FlxTween.tween(spr, { y: spr.y - added }, del, { ease: daEase });
					case 2:
						spr.screenCenter();
						FlxTween.tween(spr, { y: spr.y + added }, del, { ease: daEase });
					case 3:
						spr.screenCenter();
						spr.y += added;
						FlxTween.tween(spr, { y: spr.y - added }, del, { ease: daEase });
					case 4:
						spr.screenCenter();
						spr.y -= added;
						FlxTween.tween(spr, { y: spr.y + added }, del, { ease: daEase });
					case 5:
						spr.y = FlxG.height * 2;
				}
				
				if ([3, 4].contains(toMove))
				{
					var toggles:Array<Float> = [0, 0, 0, 0];
					toggles[curSelected] = 1;
					FlxTween.tween(bg1, { alpha: toggles[0] }, del, { ease: daEase });
					FlxTween.tween(bg2, { alpha: toggles[1] }, del, { ease: daEase });
					FlxTween.tween(scrollBG, { alpha: toggles[2] }, del, { ease: daEase });
				 	FlxTween.tween(bg4, { alpha: toggles[3] }, del, { ease: daEase });
				}
			}

			spr.updateHitbox();
		});
	}
}
