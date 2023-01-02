import base.CoolUtil;
import base.debug.Overlay;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import funkin.Highscore;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import states.*;

using StringTools;

/** 
	Enumerator for settingtypes
**/
enum SettingTypes
{
	Checkmark;
	Selector;
}

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';

	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [
			false,
			Checkmark,
			'Whether to have the strumline vertically flipped in gameplay.',
			NOT_FORCED
		],
		'Controller Mode' => [
			false,
			Checkmark,
			'Whether to use a controller instead of the keyboard to play.',
			NOT_FORCED
		],
		'Auto Pause' => [
			true,
			Checkmark,
			'Whether to pause the game automatically if the window is unfocused.',
			NOT_FORCED
		],
		'Hardware Caching' => [
			false,
			Checkmark,
			"Whether the game should upload images to the GPU, takes effect after restart.",
			NOT_FORCED
		],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.', NOT_FORCED],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much memory is being used.',
			NOT_FORCED
		],
		'Debug Info' => [
			false,
			Checkmark,
			'Whether to display information like your game state.',
			NOT_FORCED
		],
		'Reduced Movements' => [
			false,
			Checkmark,
			'Whether to reduce movements, like icons bouncing or beat zooms in gameplay.',
			NOT_FORCED
		],
		'Stage Opacity' => [
			Checkmark,
			Selector,
			'Darkens non-ui elements, useful if you find the characters and backgrounds distracting.',
			NOT_FORCED
		],
		'Opacity Type' => [
			'UI',
			Selector,
			'Choose whether the filter will be behind the notes or the UI',
			NOT_FORCED,
			['UI', 'Notes']
		],
		'Counter' => [
			'None',
			Selector,
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			NOT_FORCED,
			['None', 'Left', 'Right']
		],
		'Display Accuracy' => [true, Checkmark, 'Whether to display your accuracy on screen.', NOT_FORCED],
		'Disable Antialiasing' => [
			false,
			Checkmark,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.',
			NOT_FORCED
		],
		'No Camera Note Movement' => [
			false,
			Checkmark,
			'When enabled, left and right notes no longer move the camera.',
			NOT_FORCED
		],
		'Disable Note Splashes' => [
			false,
			Checkmark,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.',
			NOT_FORCED
		],
		// custom ones lol
		'Offset' => [Checkmark, 3],
		'Filter' => [
			'none',
			Selector,
			'Choose a filter for colorblindness.',
			NOT_FORCED,
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		"Clip Style" => [
			'stepmania',
			Selector,
			"Chooses a style for hold note clippings; StepMania: Holds under Receptors; FNF: Holds over receptors",
			NOT_FORCED,
			['StepMania', 'FNF']
		],
		"UI Skin" => [
			'default',
			Selector,
			'Choose a UI Skin for judgements, combo, etc.',
			NOT_FORCED,
			''
		],
		"Note Skin" => ['default', Selector, 'Choose a note skin.', NOT_FORCED, ''],
		"Framerate Cap" => [120, Selector, 'Define your maximum FPS.', NOT_FORCED, ['']],
		"Opaque Arrows" => [
			false,
			Checkmark,
			"Makes the arrows at the top of the screen opaque again.",
			NOT_FORCED
		],
		"Opaque Holds" => [false, Checkmark, "Huh, why isnt the trail cut off?", NOT_FORCED],
		'Ghost Tapping' => [
			false,
			Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
			NOT_FORCED
		],
		'Centered Notefield' => [false, Checkmark, "Center the notes, disables the enemy's notes.", NOT_FORCED],
		'Skip Text' => [
			'freeplay only',
			Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.',
			NOT_FORCED,
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			false,
			Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.",
			NOT_FORCED
		],
		'Simply Judgements' => [
			false,
			Checkmark,
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.",
			NOT_FORCED
		],
		"Hitsound Type" => ['default', Selector, 'Choose the Note Hitsound you prefer.', NOT_FORCED, ''],
		'Hitsound Volume' => [Checkmark, Selector, 'The volume for your Note Hitsounds.', NOT_FORCED],
		'Colored Health Bar' => [
			false,
			Checkmark,
			"Whether the Health Bar should follow the Character Icon colors.",
			NOT_FORCED
		],
		'Disable Flashing Lights' => [
			false,
			Checkmark,
			"Whether flashing elements on the menus should be disabled.",
			NOT_FORCED
		],
		'Check for Updates' => [
			true,
			Checkmark,
			"Whether to check for updates when opening the game.",
			NOT_FORCED
		],
		'Score Bar Size' => [18, Selector, 'Set the text size for the Score Bar.', NOT_FORCED],
		'Disable Button Flickering' => [
			false,
			Checkmark,
			"Whether to disable button flickering when interacting with the items on the Options Menu.",
			NOT_FORCED
		],
		'Disable Shaders' => [
			false,
			Checkmark,
			"Whether to disable Fragment Shader effects during gameplay, can improve performance.",
			NOT_FORCED
		],
		'Menu Song' => [
			'foreverMenu',
			Selector,
			'Which song should we use for the Main Menu? takes effect upon switching states or restarting the game.',
			NOT_FORCED,
			['foreverMenu', 'freakyMenu']
		],
		'Use Set Scroll Speed' => [
			false,
			Checkmark,
			"Whether to override the song's scroll speed to use your own.",
			NOT_FORCED
		],
		'Scroll Speed' => [1, Selector, 'Set the scroll speed for the Notes.', NOT_FORCED],
	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var gameControls:Map<String, Dynamic> = [
		'LEFT' => [[FlxKey.LEFT, A], 0],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'UP' => [[FlxKey.UP, W], 2],
		'RIGHT' => [[FlxKey.RIGHT, D], 3],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 6],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 7],
		'PAUSE' => [[FlxKey.ENTER, P], 8],
		'RESET' => [[R, null], 9],
		'UI_UP' => [[FlxKey.UP, W], 12],
		'UI_DOWN' => [[FlxKey.DOWN, S], 13],
		'UI_LEFT' => [[FlxKey.LEFT, A], 14],
		'UI_RIGHT' => [[FlxKey.RIGHT, D], 15],
	];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];

	override public function create():Void
	{
		Highscore.load();
		loadSettings();
		loadControls();

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		// apply saved filters
		FlxG.game.setFilters(filters);

		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
		FlxGraphic.defaultPersist = true; // make sure we control all of the memory

		goToInitialDestination();
	}

	public static function loadSettings():Void
	{
		FlxG.save.bind('forever-settings', 'BeastlyGhost');

		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null && gameSettings.get(singularSetting)[3] != FORCED)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		// lemme fix that for you
		if (!Std.isOfType(trueSettings.get("Framerate Cap"), Int)
			|| trueSettings.get("Framerate Cap") < 30
			|| trueSettings.get("Framerate Cap") > 360)
			trueSettings.set("Framerate Cap", 30);

		if (!Std.isOfType(trueSettings.get("Stage Opacity"), Int)
			|| trueSettings.get("Stage Opacity") < 0
			|| trueSettings.get("Stage Opacity") > 100)
			trueSettings.set("Stage Opacity", 100);

		if (!Std.isOfType(trueSettings.get("Hitsound Volume"), Int)
			|| trueSettings.get("Hitsound Volume") < 0
			|| trueSettings.get("Hitsound Volume") > 100)
			trueSettings.set("Hitsound Volume", 0);

		// 'hardcoded' ui skins
		gameSettings.get("UI Skin")[4] = CoolUtil.returnAssetsLibrary('UI');
		if (!gameSettings.get("UI Skin")[4].contains(trueSettings.get("UI Skin")))
			trueSettings.set("UI Skin", 'default');

		gameSettings.get("Note Skin")[4] = CoolUtil.returnAssetsLibrary('noteskins/notes');
		if (!gameSettings.get("Note Skin")[4].contains(trueSettings.get("Note Skin")))
			trueSettings.set("Note Skin", 'default');

		gameSettings.get("Hitsound Type")[4] = CoolUtil.returnAssetsLibrary('hitsounds', 'assets/sounds');
		if (!gameSettings.get("Hitsound Type")[4].contains(trueSettings.get("Hitsound Type")))
			trueSettings.set("Hitsound Type", 'default');

		saveSettings();
		updateAll();

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}

	function goToInitialDestination()
	{
		// binding save to secrets so we can check your flashing lights state
		FlxG.save.bind('forever-secrets', 'BeastlyGhost');

		if (!FlxG.save.data.leftFlashing)
		{
			Main.switchState(this, new FlashingState());
		}
		else
		{
			// bind save back to settings
			FlxG.save.bind('forever-settings', 'BeastlyGhost');
			Main.switchState(this, new TitleState());
		}
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.bind('forever-settings', 'BeastlyGhost');
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		#if DEBUG_TRACES trace('Settings Saved!'); #end
		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.bind('forever-controls', 'BeastlyGhost');
		FlxG.save.data.controls = gameControls;
		FlxG.save.flush();

		#if DEBUG_TRACES trace('Controls Saved!'); #end
	}

	public static function loadControls():Void
	{
		FlxG.save.bind('forever-controls', 'BeastlyGhost');
		if (FlxG.save != null && FlxG.save.data.controls != null)
		{
			if ((FlxG.save.data.controls != null) && (Lambda.count(FlxG.save.data.controls) == Lambda.count(gameControls)))
				gameControls = FlxG.save.data.controls;
		}

		saveControls();
	}

	public static function updateAll()
	{
		FlxG.autoPause = trueSettings.get('Auto Pause');

		Overlay.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Debug Info'), trueSettings.get('Memory Counter'));

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		///*
		filters = [];
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filter');
		if (gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}

		FlxG.game.setFilters(filters);
		// */
	}
}
