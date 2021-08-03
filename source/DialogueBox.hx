package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;

import flixel.tweens.FlxTween;

import flixel.util.FlxAxes;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var controls(get, never):Controls;
	
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	var curSound:FlxSound;

	//var fadeScreen:FlxSprite;
	var blackScreen:FlxSprite;

	var whitelisted:Array<String> = ['killSound', 'soundoverwritestop', 'musicstop', 'music', 'musicloop', 'soundoverwrite', 'sound', 'bg', 'bghide', 'makeGraphic', 'fadeIn', 'fadeOut', 'overlayHide', 'bgOverlay', 'shakeOverlay', 'bgFadeIn', 'bgFadeOut', 'midTextFadeOut'];
	var isAuto:Bool = false;
	var autoSkip:Bool = false;
	var leTimer:FlxTimer;

	var box:FlxSprite;
	var daBg:FlxSprite;
	var daBgOverlay:FlxSprite;
	var hider:FlxSprite;
	var midText:FlxText;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];
	var extraPortraits:Array<Character> = [];
	
	var fadeColor:FlxColor = FlxColor.BLACK;
	
	public var paused:Bool = false;
	public var isFade:Bool = false;
	public var toFade:Float = 0;
	public var queueFade:Bool = false;
	public var fadeTimer:FlxTimer;
	/*public var curTime:Int = 0;
	public var startingTime:Int = 0;*/

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var bgFade:FlxSprite;

	var extraCharnames:Array<String> = [
	'crystal',
	'kuna',
	'bao',
	'domo'
	];

	var extraRights:Array<Bool> = [];

	var defaultSound:String = 'pixelText';
	
	var killSound:Bool = false;
	
	var holdIndicator:FlxText;
	var holdTimer:Float = 0;
	
	public var done:Bool = false;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, FlxG.height + 10);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
		}

		this.dialogueList = processDialog(dialogueList);

		if (!hasDialog)
			return;
			
		daBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		daBg.antialiasing = true;
		add(daBg);
		daBg.visible = false;
		
		daBgOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		daBgOverlay.antialiasing = true;
		daBgOverlay.visible = false;
		add(daBgOverlay);
		
		hider = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		hider.antialiasing = true;
		hider.alpha = 0;
		
		midText = new FlxText(0, 0, FlxG.width, "", 32);
		midText.setFormat(Paths.font('animeace2_reg.ttf'), 32, FlxColor.WHITE, CENTER);
		midText.screenCenter();

		box.animation.play('normalOpen');
		box.x = FlxG.width / 2 - box.width / 2;
		box.updateHitbox();

		box.y -= box.height;
		box.y += 20;
		box.x += 40;
		
		for (i in 0...extraCharnames.length)
		{
			var isRight:Bool = false;
			var rightInts:Array<Int> = [];

			if (extraCharnames[i].contains('crystal'))
			{
				isRight = true;
			}
			var daChar:String = extraCharnames[i];
			if (daChar == 'kuna')
				daChar = 'kuna-dafurry-forgotherspeakers';
			var newSprite:Character = new Character(box.x, box.y + 100, daChar, isRight);
			//newSprite.y -= newSprite.height;
			if (isRight)
			{
				newSprite.x += box.width;
				newSprite.x -= newSprite.width;
				newSprite.x -= 100;
			} else {
				newSprite.x += 100;
			}
			switch (extraCharnames[i])
			{
				case 'kuna':
					newSprite.y -= 350;
				case 'crystal':
					newSprite.y -= 400;
				case 'bao':
					newSprite.y -= 400;
				case 'domo':
					newSprite.y -= 300;
			}
			newSprite.updateHitbox();
			newSprite.scrollFactor.set();
			newSprite.visible = false;
			extraPortraits.push(newSprite);
			add(extraPortraits[i]);
			extraRights.push(isRight);
		}
		
		add(box);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 557, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 555, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;

			/*swagDialogue.size = 16;
			swagDialogue.font = '';
			swagDialogue.color = FlxColor.BLACK;*/
		swagDialogue.setFormat(Paths.font('animeace2_reg.ttf'), 20, 0xFF3F2021, LEFT);

		add(swagDialogue);
		
		add(hider);
		add(midText);
		
		holdIndicator = new FlxText(0, 0, 0, "Hold S To Skip...", 12);
		holdIndicator.setFormat('Nokia Cellphone FC Small', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		holdIndicator.x = FlxG.width - holdIndicator.width;
		add(holdIndicator);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
		/*fadeScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fadeScreen.antialiasing = true;
		add(fadeScreen);
		fadeScreen.alpha = 0;*/
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.antialiasing = true;
		add(blackScreen);
		
		if (fadeTimer != null)
		{
			fadeTimer.cancel();
			fadeTimer.destroy();
		}
		
		/*fadeTimer = new FlxTimer().start(1 / 100, function(tmr:FlxTimer)
		{
			curTime++;
		}, 0);*/
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.visible = false;
		dropText.alpha = 0;

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}
		
		//gwebdev = shit lol
		
		/*if (Math.isNaN(toFade))
		{
			toFade = 0;
		}*/

		/*if (queueFade)
		{
			queueFade = false;
			//startingTime = curTime;
		}*/
		
		//trace(curCharacter);
		
		//i suk
		//trace("start: " + startingTime);
		//trace("cur time: " + curTime);
		
		if ((!paused && !isFade) || !whitelisted.contains(curCharacter)) {
				box.alpha = 1;
				swagDialogue.alpha = 1;
		} else {
				box.alpha = 0;
				swagDialogue.alpha = 0;
		}

		isAuto = false;

		if (curCharacter.endsWith('-auto'))
			isAuto = true;

		//if ((FlxG.keys.justPressed.ANY) || (dialogueList.length > 0 && whitelisted.contains(curCharacter)) && dialogueStarted == true && !paused && !isFade)
		if ((controls.ACCEPT && !isAuto) || (isAuto && autoSkip) || (dialogueList.length > 0 && whitelisted.contains(curCharacter)) && dialogueStarted == true && !paused && !isFade)
		{
			var queuePause:Bool = false;
			queueFade = false;
			if (!paused && !isFade)
			{
			switch (curCharacter)
			{
				case 'musicloop':
					if (Paths.exists(Paths.music(dialogueList[0])))
					{
						FlxG.sound.playMusic(Paths.music(dialogueList[0]), 1, true);
					}
				case 'music':
					if (Paths.exists(Paths.music(dialogueList[0])))
					{
						FlxG.sound.playMusic(Paths.music(dialogueList[0]), 1, false);
					}
				case 'musicstop':
					if (FlxG.sound.music.playing)
					{
						FlxG.sound.music.stop();
					}
				case 'soundoverwrite':
					if (Paths.exists(Paths.sound(dialogueList[0])))
					{
						if (curSound != null && curSound.playing)
						{
							curSound.stop();
						}
						curSound = new FlxSound().loadEmbedded(Paths.sound(dialogueList[0]));
						//curSound.volume = FlxG.sound.volume;
						curSound.play();
					}
				case 'soundoverwritestop':
					if (curSound != null && curSound.playing)
					{
						curSound.stop();
					}
				case 'sound':
					/*var isParseable:Bool = false;

					try {
						haxe.crypto.Base64.decode(dialogueList[0]);
						isParseable = true;
					} catch(e:Dynamic) {
						isParseable = false;
					}*/
					
					if (Paths.exists(Paths.sound(dialogueList[0])))
					{
						FlxG.sound.play(Paths.sound(dialogueList[0]));
					}

					/*if (isParseable)
					{
						if (Paths.exists(Paths.sound(haxe.crypto.Base64.decode(dialogueList[0]))))
						{
							FlxG.sound.play(Paths.sound(haxe.crypto.Base64.decode(dialogueList[0])), 0.8);
						}
					}*/
				case 'bghide':
					daBg.visible = false;
				case 'bg':
					if (Paths.exists(Paths.image(dialogueList[0])))
					{
						daBg.loadGraphic(Paths.image(dialogueList[0]));
					}
					daBg.visible = true;
				case 'makeGraphic':
					var ourArr:Array<Int> = [];
					var tempShit:Array<String> = new EReg(",", "g").split(dialogueList[0]);
					for (shit in tempShit)
					{
						ourArr.push(Std.parseInt(shit));
					}
					if (ourArr.length == 4)
					{
						var canUse:Bool = true;
						for (fuck in 0...ourArr.length)
						{
							if (!(ourArr[fuck] <= 255 && ourArr[fuck] >= 0))
							{
								canUse = false;
							}
						}
						if (canUse)
						{
							var PACKED_COLOR = (ourArr[0] & 0xFF) << 24 | (ourArr[1] & 0xFF) << 16 | (ourArr[2] & 0xFF) << 8 | (ourArr[3] & 0xFF);
							daBg.makeGraphic(FlxG.width, FlxG.height, PACKED_COLOR);
							daBg.visible = true;
						}
					}
				case 'fadeColor':
					var ourArr:Array<Int> = [];
					var tempShit:Array<String> = new EReg(",", "g").split(dialogueList[0]);
					for (shit in tempShit)
					{
						ourArr.push(Std.parseInt(shit));
					}
					if (ourArr.length == 4)
					{
						var canUse:Bool = true;
						for (fuck in 0...ourArr.length)
						{
							if (!(ourArr[fuck] <= 255 && ourArr[fuck] >= 0))
							{
								canUse = false;
							}
						}
						if (canUse)
						{
							fadeColor = (ourArr[0] & 0xFF) << 24 | (ourArr[1] & 0xFF) << 16 | (ourArr[2] & 0xFF) << 8 | (ourArr[3] & 0xFF);
						}
					}
				case 'fadeIn':
						queueFade = true;
						
						camera.fade(fadeColor, Std.parseFloat(dialogueList[0]), false, function()
						{
							isFade = false;
							queueFade = false;
						}, true);
						box.alpha = 0;
						swagDialogue.alpha = 0;
					//}
					//trace("fade in");
				case 'fadeOut':
					/*var tempShit:Array<String> = new EReg(",", "g").split(dialogueList[0]);
					if (tempShit.length == 2)
					{*/
						/*toFade = Std.parseFloat(dialogueList[0]);
						isFadeIn = false;
						isFadeOut = true;*/
						/*var calc1:Float = Std.parseFloat(tempShit[0]);
						var calc2:Int = Std.parseInt(tempShit[1]);
						if (Math.isNaN(calc1))
						{
							calc1 = 0;
						}*/
						
						//fadeScreen.alpha = 1;
						/*new FlxTimer().start(calc1, function(tmr:FlxTimer)
						{
							fadeScreen.alpha = 1 - (1 * (tmr.elapsedLoops / tmr.loops));
							if (tmr.loopsLeft == 0)
							{
								isFade = false;
							}
						}, calc2);*/

						queueFade = true;
						
						camera.fade(fadeColor, Std.parseFloat(dialogueList[0]), true, function()
						{
							isFade = false;
							queueFade = false;
						}, true);
						box.alpha = 0;
						swagDialogue.alpha = 0;
						//trace("fadeout");
					//}
				case 'bgFadeIn':
					queueFade = true;
					FlxTween.tween(hider, { alpha: 0 }, Std.parseFloat(dialogueList[0]), { onComplete: function(twn:FlxTween)
					{
						isFade = false;
						queueFade = false;
					} });
				case 'bgFadeOut':
					queueFade = true;
					FlxTween.tween(hider, { alpha: 1 }, Std.parseFloat(dialogueList[0]), { onComplete: function(twn:FlxTween)
					{
						isFade = false;
						queueFade = false;
					} });
				case 'bgOverlay':
					if (Paths.exists(Paths.image(dialogueList[0])))
					{
						daBgOverlay.loadGraphic(Paths.image(dialogueList[0]));
					}
					daBgOverlay.visible = true;
				case 'overlayHide':
					daBgOverlay.visible = false;
				case 'midTextFadeOut':
					queueFade = true;
					FlxTween.tween(midText, { alpha: 0 }, Std.parseFloat(dialogueList[0]), { onComplete: function(twn:FlxTween)
					{
						isFade = false;
						queueFade = false;
					} });
				case 'shakeOverlay':
					var tempShit:Array<String> = new EReg(",", "g").split(dialogueList[0]);
					if (tempShit.length == 2)
					{
						var calc1:Float = Std.parseFloat(tempShit[0]);
						var calc2:Float = Std.parseFloat(tempShit[1]);
						if (Math.isNaN(calc1))
							calc1 = 0;
						if (Math.isNaN(calc2))
							calc2 = 0;
						//queueFade = true;
						FlxG.cameras.shake(calc1, calc2);//, function()
						//{
							//isFade = false;
							//queueFade = false;
						//});
					}
				case 'killSound':
					killSound = true;
			}

			if (whitelisted.contains(curCharacter))
			{
				box.alpha = 0;
				swagDialogue.alpha = 0;
			}
			
			remove(dialogue);

			bgFade.alpha = 0;

			}
			
			//trace(isFade);
			//trace("cur: " + curCharacter);
			//trace(dialogueList[0]);

			if ((dialogueList[1] == null && dialogueList[0] != null))
			//trace(dialogueList);
			//if (dialogueList.length == 0)
			{
				//trace("dis called");
				if (!isEnding && !paused && !isFade)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					//trace("yes");
					blackScreen.visible = false;
					box.alpha = 0;
					bgFade.alpha = 0;
					hidePortraits();
					swagDialogue.alpha = 0;
					dropText.alpha = 0;
					//swagDialogue.kill();
					//swagDialogue.destroy();
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						if (!done)
							finishThing();
					});
				}
			}
			else if (!paused && !isFade)
			{
				dropText.visible = true;
				box.visible = true;
				swagDialogue.visible = true;
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
			else if (paused || isFade)
			{
				dropText.visible = false;
				box.visible = false;
				swagDialogue.visible = false;
				hidePortraits();
			}

			if (queuePause)
			{
				queuePause = false;
				paused = true;
			}
			
			if (queueFade)
			{
				queueFade = false;
				isFade = true;
			}
		}
		
		if (FlxG.keys.pressed.S)
			holdTimer += 1 / FlxG.updateFramerate;
		else
			holdTimer = 0;	
			
		if (holdTimer >= 1)
		{
			blackScreen.visible = false;
			box.alpha = 0;
			bgFade.alpha = 0;
			hidePortraits();
			swagDialogue.alpha = 0;
			dropText.alpha = 0;
			//swagDialogue.kill();
			//swagDialogue.destroy();
			if (!done)
				finishThing();
		}

		super.update(elapsed);
	}
	
	function hidePortraits():Void
	{
		for (shit in extraPortraits)
		{
			shit.visible = false;
		}
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		if (!isFade && !paused)
		{
			box.visible = true;
			swagDialogue.visible = true;
		}
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		
		hidePortraits();
		
		switch (curCharacter)
		{
			case 'noone':
				hidePortraits();
				defaultSound = 'pixelText';
			case 'noone-auto':
				hidePortraits();
			case 'bao' | 'bao-auto' | 'noone-bao' | 'noone-bao-auto':
				defaultSound = 'baoText';
			case 'crystal' | 'crystal-auto' | 'noone-crystal' | 'noone-crystal-auto':
				defaultSound = 'crystalText';
			case 'kuna' | 'kuna-auto' | 'noone-kuna' | 'noone-kuna-auto':
				defaultSound = 'kunaText';
			case 'domo' | 'domo-auto':
				defaultSound = 'pixelText';
			case 'midText':
				box.visible = false;
				swagDialogue.visible = false;
				midText.text = dialogueList[0];
				midText.screenCenter();
				FlxTween.tween(midText, { alpha: 1 }, 1);
		}
		
		var replacedChar:String = new EReg("-auto", "g").replace(curCharacter, "");
		
		if (extraCharnames.contains(replacedChar))
		{
			extraPortraits[extraCharnames.indexOf(replacedChar)].visible = true;
			if (!extraRights[extraCharnames.indexOf(replacedChar)])
			{
				box.flipX = true;
			} else {
				box.flipX = false;
			}
		}

			if (swagDialogue.sounds != [FlxG.sound.load(Paths.sound(defaultSound), 0.6)])
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound(defaultSound), 0.6)];
			if (whitelisted.contains(replacedChar) || replacedChar == 'midText' || killSound)
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound(defaultSound), 0)];
			
		autoSkip = false;
		
		var del:Float = 0.04;
		if (curCharacter.endsWith('-auto'))
			del = 0.03;
			
		if (leTimer != null)
		{
			leTimer.cancel();
			leTimer.destroy();
		}

		swagDialogue.start(del, true, false, null, function()
		{
			leTimer = new FlxTimer();
			leTimer.start(0.3, function(tmr:FlxTimer)
			{
				if (isAuto)
					autoSkip = true;
			}, 1);
		});
		
		if (!whitelisted.contains(curCharacter))
		{
			blackScreen.visible = false;
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
	
	function processDialog(?dialogues:Array<String>):Array<String>
	{
		if (dialogues == null)
			return [];
		if (!Highscore.getCensor())
			return dialogues;
		var toRet:Array<String> = [];
		var censorWords:Array<String> = [
		'fuck', 'shit', 'cock', 'penis', 'dick', 'vagina', 'bitch'
		];
		for (dialog in dialogues)
		{
			var splitName:Array<String> = dialog.split(":");
			var char:String = splitName[1];
			var dialogData:String = dialog.substr(splitName[1].length + 2).trim();
			for (word in censorWords)
			{
				var lowerCased:String = dialogData.toLowerCase();
				var lowerCased2:String = word.toLowerCase();
				var indexes:Array<Int> = [];
				for (i in 0...lowerCased.length)
				{
					var lastIndex:Int = lowerCased.indexOf(lowerCased2, i);
					var lastIndex2:Int = i - 1 != -1 ? lowerCased.indexOf(lowerCased2, i - 1) : -1;
					if (lastIndex != -1 && lastIndex != lastIndex2)
					{
						indexes.push(lastIndex);
					}
				}
				for (ind in indexes)
				{
					dialogData = dialogData.substr(0, ind) + astGen(lowerCased2.length) + dialogData.substr(ind + lowerCased2.length);
				}
			}
			toRet.push(":" + char + ":" + dialogData);
		}
		return toRet;
	}
	
	function astGen(len:Int):String
	{
		var toRet:String = "";
		for (i in 0...len)
		{
			toRet += "*";
		}
		return toRet;
	}
}
