package funkin;

import base.*;
import dependency.FNFSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.OverlayShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.system.scaleModes.*;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import funkin.background.*;
import openfl.display.BlendMode;
import openfl.display.BlendModeEffect;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import states.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	// week 2
	var halloweenBG:FNFSprite;

	// week 3
	var phillyCityLights:FlxTypedGroup<FNFSprite>;
	var phillyTrain:FNFSprite;
	var trainSound:FlxSound;

	// week 4
	public var limo:FNFSprite;
	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	var fastCar:FNFSprite;

	// week 5
	var upperBoppers:FNFSprite;
	var bottomBoppers:FNFSprite;
	var santa:FNFSprite;

	// week 6
	var bgGirls:BackgroundGirls;

	// week 7
	var smokeL:FNFSprite;
	var smokeR:FNFSprite;
	var tankWatchtower:FNFSprite;
	var tankGround:FNFSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var tankdude0:FNFSprite;
	var tankdude1:FNFSprite;
	var tankdude2:FNFSprite;
	var tankdude3:FNFSprite;
	var tankdude4:FNFSprite;
	var tankdude5:FNFSprite;

	//
	public var gfVersion:String = 'people';

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public var spawnGirlfriend:Bool = true;

	public static var screenRes:String = '1280x720';

	public static var stageScript:ScriptHandler;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		switch (ChartParser.songType)
		{
			case FNF:
			// placeholder
			case FNF_LEGACY:
				/// get hardcoded stage type if chart is fnf style
				// this is because I want to avoid editing the fnf chart type
				switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
				{
					case 'bopeebo' | 'fresh' | 'dadbattle':
						curStage = 'stage';
					case 'spookeez' | 'south' | 'monster':
						curStage = 'spooky';
					case 'pico' | 'blammed' | 'philly-nice':
						curStage = 'philly';
					case 'milf' | 'satin-panties' | 'high':
						curStage = 'highway';
					case 'cocoa' | 'eggnog':
						curStage = 'mall';
					case 'winter-horrorland':
						curStage = 'mallEvil';
					case 'senpai' | 'roses':
						curStage = 'school';
					case 'thorns':
						curStage = 'schoolEvil';
					case 'ugh' | 'guns' | 'stress':
						curStage = 'military';
					default:
						curStage = 'unknown';
				}
				PlayState.curStage = curStage;

			case UNDERSCORE | PSYCH | FOREVER:
				if (curStage == null || curStage.length < 1)
				{
					switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
					{
						case 'bopeebo' | 'fresh' | 'dadbattle':
							curStage = 'stage';
						case 'spookeez' | 'south' | 'monster':
							curStage = 'spooky';
						case 'pico' | 'blammed' | 'philly-nice':
							curStage = 'philly';
						case 'milf' | 'satin-panties' | 'high':
							curStage = 'highway';
						case 'cocoa' | 'eggnog':
							curStage = 'mall';
						case 'winter-horrorland':
							curStage = 'mallEvil';
						case 'senpai' | 'roses':
							curStage = 'school';
						case 'thorns':
							curStage = 'schoolEvil';
						case 'ugh' | 'guns' | 'stress':
							curStage = 'military';
						default:
							curStage = 'unknown';
					}
				}
				PlayState.curStage = PlayState.SONG.stage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			case 'stage':
				PlayState.defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				// add to the final array
				add(bg);

				var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				// add to the final array
				add(stageFront);

				var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				// add to the final array
				add(stageCurtains);
			case 'bliss':
				PlayState.defaultCamZoom = 0.7;
				var bg:FNFSprite = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/grass'));
				bg.setGraphicSize(Std.int(bg.width * 2));
				bg.antialiasing = true;
				bg.active = false;
				add(bg);
			default:
				curStage = 'unknown';
				PlayState.defaultCamZoom = 0.9;
		}

		callStageScript();
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		switch (curStage)
		{
			case 'bliss':
				gfVersion = 'people';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, gf:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray)
		{
			switch (char.curCharacter)
			{
				case 'gf':
					char.setPosition(gf.x, gf.y);
					gf.visible = false;
					/*
						if (isStoryMode)
						{
							camPos.x += 600;
							tweenCamIn();
					}*/
					/*
						case 'spirit':
							var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
							evilTrail.changeValuesEnabled(false, false, false, false);
							add(evilTrail);
					 */
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'bliss':
				dad.y += 360;
				gf.y -= 150;
		}

		if (stageScript.exists('repositionPlayers'))
			stageScript.get('repositionPlayers')(boyfriend, dad, gf);
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'highway':
				// trace('highway update');
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'school':
				bgGirls.dance();

			case 'philly':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					var lastLight:FlxSprite = phillyCityLights.members[0];

					phillyCityLights.forEach(function(light:FNFSprite)
					{
						// Take note of the previous light
						if (light.visible == true)
							lastLight = light;

						light.visible = false;
					});

					// To prevent duplicate lights, iterate until you get a matching light
					while (lastLight == phillyCityLights.members[curLight])
					{
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
					}

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;

					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case 'military':
				smokeL.animation.play('smokeLeft');
				smokeR.animation.play('smokeRight');
				tankWatchtower.animation.play('watchtower');
				tankdude0.animation.play('fg');
				tankdude1.animation.play('fg');
				tankdude2.animation.play('fg');
				tankdude3.animation.play('fg');
				tankdude4.animation.play('fg');
				tankdude5.animation.play('fg');
		}

		if (gfVersion == 'pico-speaker')
		{
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var man:TankmenBG = tankmanRun.recycle(TankmenBG);
					man.strumTime = TankmenBG.animationNotes[i][0];
					man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(man);
				}
			}
		}

		if (stageScript.exists('onUpdate'))
			stageScript.get('onUpdate')(curBeat);
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Character, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos(gf);
						trainFrameTiming = 0;
					}
				}
			case 'military':
				moveTank();
		}

		if (stageScript.exists('onUpdateConst'))
			stageScript.get('onUpdateConst')(elapsed);
	}

	// PHILLY STUFFS!
	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	// TANK STUFFS!!
	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		tankAngle += tankSpeed * FlxG.elapsed;
		tankGround.angle = (tankAngle - 90 + 15);
		tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
		tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function callStageScript()
	{
		stageScript = new ScriptHandler(Paths.getPreloadPath('stages/$curStage.hxs'));

		stageScript.set('createGraphic',
			function(id:String, x:Float, y:Float, size:Float = 1, scrollX:Float, scrollY:Float, alphaValue:Float = 1, scaleX:Float = 1, scaleY:Float = 1,
					image:String, fore:Bool = false, blendString:String = 'normal')
			{
				var madeGraphic:FNFSprite = new FNFSprite(x, y).loadGraphic(Paths.image(image));
				madeGraphic.setGraphicSize(Std.int(madeGraphic.width * size));
				madeGraphic.scrollFactor.set(scrollX, scrollY);
				madeGraphic.updateHitbox();
				madeGraphic.antialiasing = true;
				madeGraphic.blend = ForeverTools.getBlendFromString(blendString);
				madeGraphic.alpha = alphaValue;
				PlayState.GraphicMap.set(id, madeGraphic);

				if (fore)
					foreground.add(madeGraphic);
				else
					add(madeGraphic);
			});

		stageScript.set('createAnimatedGraphic',
			function(id:String, x:Float, y:Float, size:Float, scrollX:Float, scrollY:Float, alphaValue:Float = 1, scaleX:Float = 1, scaleY:Float = 1,
					image:String, anims:Array<Array<Dynamic>>, defaultAnim:String, fore:Bool = false, blendString:String = 'normal')
			{
				var madeGraphic:FNFSprite = new FNFSprite(x, y);
				madeGraphic.frames = Paths.getSparrowAtlas(image);

				for (anim in anims)
				{
					madeGraphic.animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
				}

				madeGraphic.setGraphicSize(Std.int(madeGraphic.width * size));
				madeGraphic.scrollFactor.set(scrollX, scrollY);
				madeGraphic.updateHitbox();
				madeGraphic.animation.play(defaultAnim);
				madeGraphic.antialiasing = true;
				madeGraphic.blend = ForeverTools.getBlendFromString(blendString);
				madeGraphic.alpha = alphaValue;
				madeGraphic.scale.set(scaleX, scaleY);
				PlayState.GraphicMap.set(id, madeGraphic);
				if (fore)
					foreground.add(madeGraphic);
				else
					add(madeGraphic);
			});

		stageScript.set('addOffsetByID', function(id:String, anim:String, x:Float, y:Float)
		{
			var getSprite:FNFSprite = PlayState.GraphicMap.get(id);
			getSprite.addOffset(anim, x, y);
		});

		stageScript.set('applyBlendByID', function(id:String, blendString:String)
		{
			var getSprite:FNFSprite = PlayState.GraphicMap.get(id);
			getSprite.blend = ForeverTools.getBlendFromString(blendString);
		});

		stageScript.set('configStage', function(daStage:String = 'stage', desiredZoom:Float = 1.05)
		{
			curStage = daStage;
			PlayState.defaultCamZoom = desiredZoom;
		});

		stageScript.set('addEmbeddedSound', function(sndString:String = '')
		{
			var sound:FlxSound;
			sound = new FlxSound().loadEmbedded(Paths.sound(sndString));
			FlxG.sound.list.add(sound);
		});

		stageScript.set('curStage', curStage);

		stageScript.set('conductorStepCrochet', Conductor.stepCrochet);

		stageScript.set('resetKey', function(button:Bool)
		{
			PlayState.resetKey = button;
		});

		stageScript.set('spawnGirlfriend', function(button:Bool)
		{
			spawnGirlfriend = button;
		});

		if (stageScript.exists('onCreate'))
			stageScript.get('onCreate')();
	}
}
