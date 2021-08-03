package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
//import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

import flixel.FlxCamera;

import Discord.DiscordClient;
#if sys
import sys.thread.Thread;
#end

import haxe.Http;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	//var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var bao:Character;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	
	var defCam:FlxCamera;
	var scrollCam1:FlxCamera;
	var scrollCam2:FlxCamera;

	override public function create():Void
	{
		isReady = false;
	
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		
		defCam = new FlxCamera();
		defCam.bgColor.alpha = 0;
		scrollCam1 = new FlxCamera();
		scrollCam1.bgColor.alpha = 0;
		scrollCam2 = new FlxCamera();
		scrollCam2.bgColor.alpha = 0;
		
		FlxG.cameras.reset(scrollCam1);
		FlxG.cameras.add(scrollCam2);
		FlxG.cameras.add(defCam);
		
		FlxCamera.defaultCameras = [defCam];
		
		PlayerSettings.init();
		
		#if desktop
		DiscordClient.initialize();
		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		/*NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end*/

		FlxG.save.bind(DiscordStrings.saveBind[0], DiscordStrings.saveBind[1]);

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}
	
	var isReady:Bool = false;
	
	public var warningTxt:FlxText;
	
	public var warningBG:FlxSprite;

	public var showWarning:Bool = false;
	public static var skippedWarning:Bool = false;
	public var onceBullshit:Bool = false;
	
	public static var scrollPixelsPerSecond:Float = 50;
	var scrollBG:FlxSprite;
	// var scrBGFollow:FlxSprite;

	var logoBl:FlxSprite;
	// var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			#if html5
			openfl.utils.ByteArray.loadFromFile('assets/songs/whale-waltz/Inst.' + Paths.SOUND_EXT).onComplete(function(daByteArray:openfl.utils.ByteArray)
			{
			#end
				#if html5
				FlxG.sound.playMusic(openfl.media.Sound.fromAudioBuffer(lime.media.AudioBuffer.fromBytes(daByteArray)), 0);
				#else
				FlxG.sound.playMusic(Paths.inst('whale-waltz'), 0);
				#end

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			#if html5
			});
			#end
		}

		// Conductor.changeBPM(102);
		Conductor.changeBPM(180);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		bg.cameras = [scrollCam1, scrollCam2];
		add(bg);
		
		scrollBG = new FlxSprite();
		scrollBG.frames = Paths.getPackerAtlas('scrollbg');
		scrollBG.animation.addByPrefix('scroll', 'scrollbg_', 10);
		scrollBG.animation.play('scroll', true);
		scrollBG.antialiasing = true;
		scrollBG.screenCenter(X);
		scrollBG.cameras = [scrollCam1, scrollCam2];
		add(scrollBG);
		
		scrollCam2.focusOn(FlxPoint.get(FlxG.width / 2, -scrollBG.height + FlxG.height / 2));

		// logoBl = new FlxSprite(-150, -100);
		logoBl = new FlxSprite(-50, -50);
		// logoBl.frames = Paths.getSparrowAtlas('logobumpin_1');
		logoBl.frames = Paths.getPackerAtlas('bomp (2)');
		logoBl.antialiasing = true;
		// logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.addByIndices('bump', 'bomp (2)_', [7, 8, 0, 1, 2, 3, 4, 5, 6], "", 24, false);
		logoBl.animation.play('bump', true);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		/*gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);*/
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		//credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		//credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		//credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;
		
		bao = new Character(0, 0, "bao", true);
		var baoScale:Float = 0.6;
		bao.scale.set(baoScale, baoScale);
		bao.updateHitbox();
		bao.y = FlxG.height - bao.height;
		bao.x = FlxG.width - bao.width;
		bao.y -= 170;
		bao.x -= 120;
		bao.visible = false;
		add(bao);

		//FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
		
		warningBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		warningTxt = new FlxText(0, 360, FlxG.width,
		"WARNING:\nIf your game lags/crashes in a level\nGo to Options and turn Shaders Off\nPress ENTER To Proceed...",
		32);
		warningTxt.y = 200;
		warningTxt.setFormat(Paths.font("animeace2_reg.ttf"), 32, FlxColor.WHITE, CENTER);
		
		add(warningBG);
		add(warningTxt);
		
		isReady = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (isReady)
		{
			#if debug
			if (controls.RESET)
			{
				initialized = false;
				FlxG.switchState(new TitleState());
			}
			#end
			if (FlxG.sound.music != null)
				Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

			if (FlxG.keys.justPressed.F)
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}

			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					pressedEnter = true;
				}
			}
			#end

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
					pressedEnter = true;

				#if switch
				if (gamepad.justPressed.B)
					pressedEnter = true;
				#end
			}
			
			if (showWarning)
			{
				if (isReady)
				{
					warningBG.visible = true;
					warningTxt.visible = true;
					var adder:Float = 1 / FlxG.updateFramerate;
					
					if (warningBG.alpha < 1)
					{
						if (warningBG.alpha + adder > 1)
						{
							warningBG.alpha = 1;
						}
						else
						{
							warningBG.alpha += adder;
						}
					}
					
					warningTxt.alpha = warningBG.alpha;
				}
				if (pressedEnter)
				{
					skippedWarning = true;
					onceBullshit = false;
				}
			}
			else if (isReady)
			{
				warningBG.visible = false;
				warningTxt.visible = false;
				warningBG.alpha = 0;
				warningTxt.alpha = 0;
			}

			if (pressedEnter && !transitioning && skippedIntro && !showWarning)
			{
				/*#if !switch
				NGio.unlockMedal(60960);

				// If it's Friday according to da clock
				if (Date.now().getDay() == 5)
					NGio.unlockMedal(61034);
				#end*/

				titleText.animation.play('press');

				defCam.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();
				
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (!skippedWarning)
					{
						onceBullshit = false;
						showWarning = true;
					}
				}, 1);
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			
			if (skippedWarning && !onceBullshit && pressedEnter)
			{
				// showWarning = false;
				onceBullshit = true;
					// Check if version is outdated

					//var version:String = "v" + Application.current.meta.get('version');

					//if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
					/*if (false)
					{
						//trace('OLD VERSION!');
						//trace('old ver');
						//trace(version.trim());
						//trace('cur ver');
						//trace(NGio.GAME_VER_NUMS.trim());
						//FlxG.switchState(new OutdatedSubState());
						//FlxG.switchState(new MainMenuState());
					}
					else
					{*/
						#if sys
						sys.thread.Thread.create(() -> {
						#end
						var http:Http = new Http("https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/current.version");
						http.onData = function(data:String)
						{
							isReady = false;
							OutdatedSubState.daVer = data;
							UpdatedSubState.daVer = data;
							if (VersionParser.parse(CurrentVersion.get()) < VersionParser.parse(data) && !OutdatedSubState.leftState)
							{
								FlxG.switchState(new OutdatedSubState());
							}
							else if (VersionParser.parse(CurrentVersion.get()) >  VersionParser.parse(data) && !UpdatedSubState.leftState)
							{
								FlxG.switchState(new UpdatedSubState());
							}
							else
							{
								FlxG.switchState(new MainMenuState());
							}
						}
						
						http.onError = function(error)
						{
							trace('error: $error');
							isReady = false;
							FlxG.switchState(new MainMenuState());
						}
						
						http.request();
						#if sys
						});
						#end
						//FlxTween.tween(FlxG.camera, { zoom: 1 }, 0.5, {ease: FlxEase.quadIn });
					//}
			}

			if (pressedEnter && !skippedIntro)
			{
				skipIntro();
			}

			if (initialized)
			{
				scrollBG.visible = true;
				logoBl.visible = true;
				
				scrollBG.y -= scrollPixelsPerSecond / FlxG.updateFramerate;
				
				if (scrollBG.y < -scrollBG.height)
				{
					scrollBG.y = 0;
				}
			}
			else
			{
				scrollBG.visible = false;
				logoBl.visible = false;
			}
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (isReady)
		{
			logoBl.animation.play('bump', true);
			/*danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');*/

			FlxG.log.add(curBeat);

			switch (curBeat)
			{
				/*case 1:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				// credTextShit.visible = true;
				case 3:
					addMoreText('present');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['In association', 'with']);
				case 7:
					addMoreText('newgrounds');
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();*/
				case v if (v <= 0):
				case v if (v <= 1):
				case v if (v <= 2):
				case v if (v <= 3):
				case v if (v <= 4):
					createCoolText(['Welcome']);
					addMoreText('Indie');
				case v if (v <= 5):
					deleteCoolText();
					createCoolText(['Welcome']);
					addMoreText('Indie');
					addMoreText('Virtual');
				case v if (v <= 6):
					deleteCoolText();
					createCoolText(['Welcome']);
					addMoreText('Indie');
					addMoreText('Virtual');
					addMoreText('AI');
				case v if (v <= 7):
					deleteCoolText();
					createCoolText(['Welcome']);
					addMoreText('Indie');
					addMoreText('Virtual');
					addMoreText('AI');
					addMoreText('VTubers');
				case v if (v <= 8):
					deleteCoolText();
					createCoolText(['Crystal Blitz']);
				case v if (v <= 9):
					deleteCoolText();
					createCoolText(['Crystal Blitz']);
					addMoreText('elikapika');
				case v if (v <= 10):
					deleteCoolText();
					createCoolText(['Crystal Blitz']);
					addMoreText('elikapika');
					addMoreText('disky');
				case v if (v <= 11):
					deleteCoolText();
					createCoolText(['Crystal Blitz']);
					addMoreText('elikapika');
					addMoreText('disky');
					addMoreText('GWebDev');
				case v if (v <= 12):
					deleteCoolText();
					createCoolText(['FNF']);
				case v if (v <= 13):
					deleteCoolText();
					createCoolText(['FNF']);
					addMoreText('Indie');
				case v if (v <= 14):
					deleteCoolText();
					createCoolText(['FNF']);
					addMoreText('Indie');
					addMoreText('VTuber');
				case v if (v <= 15):
					deleteCoolText();
					createCoolText(['FNF']);
					addMoreText('Indie');
					addMoreText('VTuber');
					addMoreText('Showdown');
				case v if (v <= 16):
					deleteCoolText();
					createCoolText(['Song Is Whale Waltz']);
				case v if (v <= 17):
					deleteCoolText();
					createCoolText(['Song Is Whale Waltz']);
					addMoreText('LETS GO');
					bao.visible = true;
					bao.playAnim('LETSGO', true);
				case v if (v <= 18):
					deleteCoolText();
					createCoolText(['Song Is Whale Waltz']);
					addMoreText('LETS GO');
					bao.visible = true;
				case v if (v <= 19):
					deleteCoolText();
					createCoolText(['Song Is Whale Waltz']);
					addMoreText('LETS GO');
					bao.visible = true;
				case v if (v <= 20 || v > 20):
					bao.visible = false;
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			defCam.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
