package states;

import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.animation.FlxAnimation;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import funkin.Character;
import funkin.Stage;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

/**
	character offset editor
	this is just code from the base game
	with some tweaking here and there to make it work on forever engine
	and some other additional features

	notes to take:
	* offsets are currently broken, as characters never spawn at their in-game idle position
	* ghost characters don't properly work
 */
class CharacterDebug extends MusicBeatState
{
	var _file:FileReference;

	// characters
	var char:Character;
	var ghost:Character;

	var curCharacter:String = 'dad';

	var curAnim:Int = 0;

	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];

	var camFollow:FlxObject;

	var stageBuild:Stage;
	var curStage:String = 'stage';

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var UI_box:FlxUITabMenu;
	var fileExt:String = 'hxs';

	public function new(curCharacter:String = 'dad')
	{
		super();
		this.curCharacter = curCharacter;
	}

	override public function create()
	{
		super.create();

		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// set up camera
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		// add stage
		generateBackground();

		// add characters
		ghost = new Character(0, 0, curCharacter);
		ghost.debugMode = true;
		ghost.visible = false;
		add(ghost);

		generateCharacter(!curCharacter.startsWith('bf'));

		// add texts
		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);

		genCharOffsets();

		#if DISCORD_RPC
		Discord.changePresence('OFFSET EDITOR', 'Editing: ' + curCharacter);
		#end

		// add menu tabs
		var tabs = [{name: 'Preferences', label: 'Preferences'},];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);

		addPreferencesUI();

		ghostAnimDropDown.selectedLabel = '';
	}

	var coolGrid:FlxBackdrop;
	var coolGradient:FlxSprite;

	function generateBackground()
	{
		coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		coolGrid.screenCenter();
		coolGrid.alpha = (32 / 255);
		add(coolGrid);

		// gradient
		coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		coolGradient.screenCenter();
		add(coolGradient);
	}

	var ghostAnimDropDown:FlxUIDropDownMenu;
	var check_offset:FlxUICheckBox;

	function addPreferencesUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Preferences";

		check_offset = new FlxUICheckBox(10, 60, null, null, "Offset Mode", 100);
		check_offset.checked = false;

		ghostAnimDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray(animList, true), function(animation:String)
		{
			if (animList[0] != '' || animList[0] != null)
			{
				ghost.visible = true;
				ghost.alpha = 0.85;
				ghost.playAnim('idle', true);
			}
			else
			{
				ghost.visible = false;
			}
		});

		tab_group.add(new FlxText(ghostAnimDropDown.x, ghostAnimDropDown.y - 18, 0, 'Ghost Animation:'));
		tab_group.add(check_offset);
		tab_group.add(ghostAnimDropDown);
		UI_box.addGroup(tab_group);
	}

	override function update(elapsed:Float)
	{
		MusicBeatState.camBeat = camHUD;
		textAnim.text = char.animation.curAnim.name;
		ghost.flipX = char.flipX;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			Main.switchState(this, new PlayState());
		}

		// camera controls

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			var addToCam:Float = 500 * elapsed;
			if (FlxG.keys.pressed.SHIFT)
				addToCam *= 4;

			if (FlxG.keys.pressed.I)
				camFollow.y -= addToCam;
			else if (FlxG.keys.pressed.K)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.J)
				camFollow.x -= addToCam;
			else if (FlxG.keys.pressed.L)
				camFollow.x += addToCam;
		}

		// character controls

		if (FlxG.keys.justPressed.F)
		{
			char.flipX = !char.flipX;
		}

		if (FlxG.keys.justPressed.W)
			updateAnimation(-1);

		if (FlxG.keys.justPressed.S)
			updateAnimation(1);

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);
		}

		if (check_offset.checked)
		{
			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN
			];

			for (i in 0...controlArray.length)
			{
				if (controlArray[i])
				{
					var holdShift = FlxG.keys.pressed.SHIFT;
					var multiplier = 1;
					if (holdShift)
						multiplier = 10;

					var arrayVal = 0;
					if (i > 1)
						arrayVal = 1;

					var negaMult:Int = 1;
					if (i % 2 == 1)
						negaMult = -1;
					char.animOffsets.get(animList[curAnim])[arrayVal] += negaMult * multiplier;

					updateTexts();
					genCharOffsets(false);
					// ghost.setPosition(char.x, char.y);
					char.playAnim(animList[curAnim], false);
				}
			}
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveCharOffsets();

		super.update(elapsed);
	}

	function updateAnimation(hey:Int)
	{
		curAnim += hey;

		if (curAnim < 0)
			curAnim = animList.length - 1;
		if (curAnim >= animList.length)
			curAnim = 0;
	}

	function generateCharacter(isDad:Bool = true)
	{
		char = new Character(!isDad, curCharacter);
		char.screenCenter();
		char.debugMode = true;
		add(char);
	}

	function genCharOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			text.scrollFactor.set();
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList)
			{
				animList.push(anim);
			}

			daLoop++;

			char.setPosition(offsets[0], offsets[1]);
		}

		if (dumbTexts.length < 1)
		{
			animList = ['[NONE]'];

			var text:FlxText = new FlxText(10, 38, 0, '
				No animations found
				\nplease make sure your ${curCharacter}.$fileExt script
				has the offsets properly set up
				\n\nTry: addOffset(\'animationName\', offsetX, offsetY);
				', 15);
			text.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			text.scrollFactor.set();
			text.color = FlxColor.RED;
			text.cameras = [camHUD];
			dumbTexts.add(text);
		}
	}

	function saveCharOffsets():Void
	{
		var result = "";

		for (anim => offsets in char.animOffsets)
		{
			var text = 'addOffset("' + anim + '", ' + offsets.join(", ") + ');';
			result += text + "\n";
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(result.trim(), curCharacter + "Offsets." + fileExt);
		}
	}

	/**
	 * Called when the save file dialog is completed.
	 */
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved OFFSET DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the offset data.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Offset data");
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}
}
