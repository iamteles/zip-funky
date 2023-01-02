package funkin;

import base.*;
import dependency.FNFSprite;
import flixel.FlxSprite;
import funkin.Strumline.UIStaticArrow;
import states.PlayState;

using StringTools;

enum NoteType
{
	NORMAL; // Normal Notes
	ALT; // Alt Animation Notes
	NO_ANIM; // No Animation Notes
	GF; // GF Notes
	HEY; // Hey Notes
	MINE; // Mines - Hit causes miss, deals damage
}

enum SustainType
{
	NORMAL; // Normal Holds, Hold to get them right
	ROLL; // Roll Holds, press rapidly to get them right
}

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteAlt:Float = 0;
	public var noteType:NoteType = NORMAL;
	public var noteString:String = "";

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var sustainType:SustainType = NORMAL;

	// only useful for charting stuffs
	public var chartSustain:FlxSprite = null;
	public var rawNoteData:Int;

	// not set initially
	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var noteSpeed:Float = 0;
	public var noteDirection:Float = 0;

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];

	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public static var noteTypeMap:Map<String, NoteType> = [
		'' => NORMAL,
		'Alt Animation' => ALT,
		'No Animation' => NO_ANIM,
		'Girlfriend Note' => GF,
		'Hey!' => HEY,
		'Mine Note' => MINE,
	];

	public static var sustainTypeMap:Map<String, SustainType> = ['' => NORMAL, 'Roll' => ROLL,];

	// for the Chart Editor, and later on for Psych Engine Notetypes Conversion
	public static var noteTypeList:Array<String> = ['', 'Alt Animation', 'No Animation', 'Girlfriend Note', 'Hey!', 'Mine Note'];

	/**
	 * WIP AND NOT REALLY WORKING RIGHT NOW!!
	**/
	public static var sustainTypeList:Array<String> = ['', 'Roll'];

	public var healthGain:Float = 0.023;
	public var healthLoss:Float = 0.0475;
	public var badNote:Bool = false;

	static var noteColorID:Array<String> = ['purple', 'blue', 'green', 'red'];
	static var pixelNoteID:Array<Int> = [4, 5, 6, 7];

	// quants
	static var directionID:Array<String> = ['left', 'down', 'up', 'right'];

	public static function convertNotetypes(noteType:NoteType, epicNote:Note = null):NoteType
	{
		// psych notetype compatibility
		var string = '';
		switch (string)
		{
			case 'No Animation':
				noteType = NO_ANIM;
			case 'Hey!':
				noteType = HEY;
			case 'Hurt Note':
				noteType = MINE; // tex is gonna be a grey disc rather than a fire note, wacky.
			case 'GF Note':
				noteType = GF;
			case 'Alt Animation':
				noteType = ALT;
			default:
				noteType = NORMAL;
		}

		return noteType;
	}

	public function new(strumTime:Float, noteData:Int, noteAlt:Float, ?prevNote:Note, ?sustainNote:Bool = false, type:NoteType = NORMAL,
			susType:SustainType = NORMAL)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		if (susType != null)
			sustainType = susType;
		else
			sustainType = NORMAL;

		if (type != null)
			noteType = type;
		else
			noteType = NORMAL;

		switch (type)
		{
			case MINE:
				healthLoss = 0.065;
				badNote = true;
			default:
				badNote = false;
		}

		// oh okay I know why this exists now
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;
		this.noteAlt = noteAlt;

		// determine parent note
		if (isSustainNote && prevNote != null)
		{
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		}
		else if (!isSustainNote)
			parentNote = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (Timings.msThreshold) && strumTime < Conductor.songPosition + (Timings.msThreshold))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;
	}

	/**
		Note creation scripts

		these are for all your custom note needs

		at the very bottom of this file you can find the function
		for setting up custom note behavior when hit and such
	**/
	public static function returnDefaultNote(assetModifier, strumTime, noteData, noteAlt, ?isSustainNote:Bool = false, ?prevNote:Note, type:NoteType = NORMAL,
			susType:SustainType = NORMAL):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, prevNote, isSustainNote, type, susType);

		// frames originally go here
		switch (assetModifier)
		{
			case 'pixel':
				if (isSustainNote)
				{
					switch (type)
					{
						case MINE:
							newNote.kill();
						default: // pixel holds default
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('arrowEnds', assetModifier, Init.trueSettings.get("Note Skin"),
								'noteskins/notes')),
								true, 7, 6);
							newNote.animation.add(noteColorID[noteData] + 'holdend', [pixelNoteID[noteData]]);
							newNote.animation.add(noteColorID[noteData] + 'hold', [pixelNoteID[noteData] - 4]);
					}
				}
				else
				{
					switch (type)
					{
						case MINE: // pixel mines
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('mines', assetModifier, '', 'noteskins/mines')), true, 17, 17);
							newNote.animation.add(noteColorID[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7]);

						default: // pixel notes default
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('arrows-pixels', assetModifier, Init.trueSettings.get("Note Skin"),
								'noteskins/notes')),
								true, 17, 17);
							newNote.animation.add(noteColorID[noteData] + 'Scroll', [pixelNoteID[noteData]]);
					}
				}
				newNote.antialiasing = false;
				newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
				newNote.updateHitbox();

			default: // base game arrows for no reason whatsoever
				switch (type)
				{
					case MINE: // mines
						newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('mines', assetModifier, '', 'noteskins/mines')), true, 133, 128);
						newNote.animation.add(noteColorID[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

						if (isSustainNote)
							newNote.kill();

						newNote.setGraphicSize(Std.int(newNote.width * 0.8));
						newNote.updateHitbox();
						newNote.antialiasing = true;

					default: // anything else
						newNote.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset('NOTE_assets', assetModifier, Init.trueSettings.get("Note Skin"),
							'noteskins/notes'));

						newNote.animation.addByPrefix(noteColorID[noteData] + 'Scroll', noteColorID[noteData] + '0');
						newNote.animation.addByPrefix(noteColorID[noteData] + 'holdend', noteColorID[noteData] + ' hold end');
						newNote.animation.addByPrefix(noteColorID[noteData] + 'hold', noteColorID[noteData] + ' hold piece');

						if (noteData == 0)
							newNote.animation.addByPrefix('purpleholdend', 'pruple end hold'); // uh?

						newNote.setGraphicSize(Std.int(newNote.width * 0.7));
						newNote.updateHitbox();
						newNote.antialiasing = true;
				}
		}
		//
		if (!isSustainNote)
			newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + 'Scroll');
		// trace(prevNote);
		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;

			var sustainPrefix:String = (susType == ROLL ? 'roll' : 'hold');

			newNote.animation.play(UIStaticArrow.getColorFromNumber(noteData) + '${sustainPrefix}end');

			newNote.updateHitbox();
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(UIStaticArrow.getColorFromNumber(prevNote.noteData) + sustainPrefix);

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * prevNote.noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		return newNote;
	}

	public static function returnQuantNote(assetModifier, strumTime, noteData, noteAlt, ?isSustainNote:Bool = false, ?prevNote:Note = null,
			type:NoteType = NORMAL, susType:SustainType = NORMAL):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, prevNote, isSustainNote, type, susType);

		// actually determine the quant of the note
		if (newNote.noteQuant == -1)
		{
			/*
				I have to credit like 3 different people for these LOL they were a hassle
				but its gede pixl and scarlett, thank you SO MUCH for baring with me
			 */
			final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

			var curBPM:Float = Conductor.bpm;
			var newTime = strumTime;
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (strumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = strumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
			final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
			// assumed 4 beats per measure?
			final measureTime:Float = beatTime * 4;

			final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime #if !neko + Init.trueSettings['Offset'] #end + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					newNote.noteQuant = quant;
					break;
				}
			}
		}

		// note quants
		switch (assetModifier)
		{
			default:
				// inherit last quant if hold note
				if (isSustainNote && prevNote != null)
					newNote.noteQuant = prevNote.noteQuant;
				// base quant notes
				if (!isSustainNote)
				{
					switch (type)
					{
						case MINE: // pixel mines
							if (assetModifier == 'pixel')
							{
								newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('mines', assetModifier, '', 'noteskins/mines')), true, 17, 17);
								newNote.animation.add(directionID[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7]);
							}
							else
							{
								newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('mines', assetModifier, '', 'noteskins/mines')), true, 133, 128);
								newNote.animation.add(directionID[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
							}

						default:
							// in case you're unfamiliar with these, they're ternary operators, I just dont wanna check for pixel notes using a separate statement
							var newNoteSize:Int = (assetModifier == 'pixel') ? 17 : 157;
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('NOTE_quants', assetModifier, Init.trueSettings.get("Note Skin"),
								'noteskins/notes', 'quant')),
								true, newNoteSize, newNoteSize);

							newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
							// LOL downscroll thats so funny to me
							newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
							newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
							newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
					}
				}
				else
				{
					switch (type)
					{
						default:
							// quant holds
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('HOLD_quants', assetModifier, Init.trueSettings.get("Note Skin"),
								'noteskins/notes', 'quant')),
								true, (assetModifier == 'pixel') ? 17 : 109, (assetModifier == 'pixel') ? 6 : 52);
							newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
							newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
							newNote.animation.add('roll', [2 + (newNote.noteQuant * 4)]);
							newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);
					}
				}

				var sizeThing = 0.7;
				if (type == MINE)
					sizeThing = 0.8;

				if (assetModifier == 'pixel')
				{
					newNote.antialiasing = false;
					newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
					newNote.updateHitbox();
				}
				else
				{
					newNote.setGraphicSize(Std.int(newNote.width * sizeThing));
					newNote.updateHitbox();
					newNote.antialiasing = true;
				}
		}

		//
		if (!isSustainNote)
			newNote.animation.play(UIStaticArrow.getArrowFromNumber(noteData) + 'Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;

			var sustainPrefix:String = (susType == ROLL ? 'roll' : 'hold');

			newNote.animation.play('${sustainPrefix}end');
			newNote.updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(sustainPrefix);

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * prevNote.noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		return newNote;
	}

	/**
	* Custom Note Functions (for when you hit a note), this should execute in PlayState;
	**/
	public function goodNoteHit(newNote:Note)
	{
		switch (newNote.noteType)
		{
			case MINE:
				PlayState.contents.decreaseCombo(true);
				PlayState.health -= healthLoss;	
			default:
				// do NOTHING!
		}
	}
}
