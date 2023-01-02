package states.menus;

import base.ForeverTools;
import base.MusicBeat.MusicBeatState;
import dependency.Discord;
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
import lime.app.Application;
import states.substates.PauseSubstate;

using StringTools;

class CreditsGay extends MusicBeatState
{
	var bg:FlxSprite;

	override function create()
	{
		super.create();
		bg = new FlxSprite(-80);
		bg.loadGraphic(Paths.image('menus/base/credits'));
		bg.scrollFactor.set(0, 0.08);
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

	}

	override function update(elapsed:Float)
	{
		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
			Main.switchState(this, new MainMenuState());
		}
	}

}
