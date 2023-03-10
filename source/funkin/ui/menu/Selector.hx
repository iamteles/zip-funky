package funkin.ui.menu;

import dependency.FNFSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import funkin.Alphabet;

class Selector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:Alphabet;
	public var chosenOptionString:String = '';
	public var options:Array<String>;

	// will make this better in the future, adding everything related to selectors right here from the git go;
	public var optionBooleans:Array<Bool> = [false, false, false, false, false];

	public function new(x:Float = 0, y:Float = 0, word:String, options:Array<String>, optionBooleans:Array<Bool>)
	{
		// call back the function
		super(x, y);

		this.options = options;
		#if DEBUG_TRACES trace(options); #end

		// oops magic numbers
		var shiftX = 48;
		var shiftY = 35;

		// generate multiple pieces
		this.optionBooleans = optionBooleans;

		#if html5
		// lol heres how we fuck with everyone
		var lock = new FlxSprite(shiftX + ((word.length) * 50) + (shiftX / 4) + ((optionBooleans[0]) ? 20 : 0), shiftY);
		lock.frames = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
		lock.animation.addByPrefix('lock', 'lock', 24, false);
		lock.animation.play('lock');
		add(lock);
		#else
		leftSelector = createSelector(shiftX, shiftY, word, 'left');
		rightSelector = createSelector(shiftX + ((word.length) * 50) + (shiftX / 4) + ((optionBooleans[0]) ? 20 : 0), shiftY, word, 'right');

		add(leftSelector);
		add(rightSelector);
		#end

		chosenOptionString = Init.trueSettings.get(word);
		if (optionBooleans.contains(true))
		{
			chosenOptionString = Std.string(Init.trueSettings.get(word));
			optionChosen = new Alphabet(FlxG.width / 2 + 200, shiftY + 20, chosenOptionString, false, false);
		}
		else
			optionChosen = new Alphabet(FlxG.width / 2, shiftY + 20, chosenOptionString, true, false);

		add(optionChosen);
	}

	public function createSelector(objectX:Float = 0, objectY:Float = 0, word:String, dir:String):FNFSprite
	{
		var returnSelector = new FNFSprite(objectX, objectY);
		returnSelector.frames = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');

		returnSelector.animation.addByPrefix('idle', 'arrow $dir', 24, false);
		returnSelector.animation.addByPrefix('press', 'arrow push $dir', 24, false);
		returnSelector.addOffset('press', 0, -10);
		returnSelector.playAnim('idle');

		return returnSelector;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (object in 0...objectArray.length)
			objectArray[object].setPosition(x + positionLog[object][0], y + positionLog[object][1]);
	}

	public function selectorPlay(whichSelector:String, animPlayed:String = 'idle')
	{
		switch (whichSelector)
		{
			case 'left':
				leftSelector.playAnim(animPlayed);
			case 'right':
				rightSelector.playAnim(animPlayed);
		}
	}

	var objectArray:Array<FlxSprite> = [];
	var positionLog:Array<Array<Float>> = [];

	override public function add(object:FlxSprite):FlxSprite
	{
		objectArray.push(object);
		positionLog.push([object.x, object.y]);
		return super.add(object);
	}
}
