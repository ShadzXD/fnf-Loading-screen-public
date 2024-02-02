// This menu is made by torch the dragon

/* 
IF DOWNLOADING FROM THE CharMenuFiles Folder:
DO NOT FORGET TO RENAME THIS FILE TO "CharMenu.hx"
They are only labeled this way for specific engines 
(if it is necessary to make it for an engine)
*/

package states;

import backend.Section;
import backend.Song;
import backend.WeekData;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import haxe.Json;
import objects.Character.Character;
import flixel.ui.FlxBar;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// Using for achievements
import backend.Achievements;

import Math;
import StringTools;
import states.FreeplayState;

class CharMenu extends MusicBeatState{
    // Selectable Character Variables
    var selectableCharacters:Array<String> = ['bf', 'pico-player']; // Currently Selectable characters
    var selectableCharactersNames:Array<String> = ['BF', 'pico']; // Characters names
    var selectableCharactersOffsets:Array<Array<Int>> = [[1000, 10], [-907, -611]]; // [x, y]
    
    // Unlockable characters
    var unlockableChars:Array<String> = ['tankman-player']; // Unlockable Characters
    var unlockableCharsNames:Array<String> = ['UGH']; // Names of unlockable Characters
    var unlockableCharactersOffsets:Array<Array<Int>> = [ [25, 0]]; // [x, y]
    
    // This is the characters that actually appear on the menu
    var unlockedCharacters:Array<String> = [];
    var unlockedCharactersNames:Array<String> = [];
    var unlockedCharactersOffsets:Array<Array<Int>> = [];
    var endstring:String;
    // This'll be used for achievements
    /* This is an example
    [
        ["week3_nomiss", "0"], - This'll unlock the first unlockable character if Week 3 was completed with no misses
        ["week7_nomiss", "1"] - This'll unlock the second unlockable character
    ]
    */
    var achievementUnlocks:Array<Array<String>> = [
        ["week7_nomiss", "1"]
    ];

    // Folder locations
    var fontFolder:String = 'assets/fonts/'; // Please don't change unless font folder changes, leads to the fonts folder
    var sharedFolder:String = 'shared'; // Please don't change, leads to the shared folder

    // Variables for what is shown on screen
    var curSelected:Int = 0; // Which character is selected
    var characterImage:Character;
    var menuBG:FlxSprite; // The background
    var bgOverlay:FlxSprite;
    var magenta:FlxSprite;
    var colorTween:FlxTween = null;
    private var imageArray:Array<Character> = []; // Array of all the selectable characters
    var selectedCharName:Alphabet; // Name of selected character

    // Additional Variables
    var alreadySelected:Bool = false; // If the character is already selected
    var ifCharsAreUnlocked:Array<Bool> = FlxG.save.data.daUnlockedChars;

    // Animated Arrows Variables
    var newArrows:FlxSprite;
    var rightarrow:FlxSprite;

    // Used to not double reset values
    private var alreadyReset:Bool = false;

    // Used for Char Placement
    var charXoffset:Int = 500;
    var tweenTime:Float = 0.35;
    var destinationTweens:Array<FlxTween> = [null];

    // Use for offseting
    #if debug
    var inCharMenuDebug:Bool = false;
    var charMenuDebugText:FlxText;
    #end

    override function create()
    {
        resetCharacterSelectionVars();
        checkFirstSlot();

        // Code to check is an achievement is completed
        for (i in 0...achievementUnlocks.length)
        {
            if (Achievements.isAchievementUnlocked(achievementUnlocks[i][0])) {
                FlxG.save.data.daUnlockedChars[Std.parseInt(achievementUnlocks[i][1])] = true;
            }
            else {
                FlxG.save.data.daUnlockedChars[Std.parseInt(achievementUnlocks[i][1])] = false;
            }
        }

        // Determines if the characters are unlocked
        if (ifCharsAreUnlocked == null) 
        {
            ifCharsAreUnlocked = [false];
            for (i in 0...unlockableChars.length) {
                if (FlxG.save.data.daUnlockedChars != null) {
                    if (FlxG.save.data.daUnlockedChars[i] != null) {
                        ifCharsAreUnlocked[i] = FlxG.save.data.daUnlockedChars[i];
                    }
                } else { // For some reason I had to create a failsafe?
                    FlxG.save.data.daUnlockedChars[i] = false;
                }
            }
        }
        // If the unlocked chars are empty, fill it with defaults
        if (unlockedCharacters == null) 
        {
            unlockedCharacters = selectableCharacters;
        } 
        // If names are empty, fill it with defaults
        if (unlockedCharactersNames == null) 
        {
            unlockedCharactersNames = selectableCharactersNames;
        }

        // If offsets are empty, fill with defaults
        if (unlockedCharactersOffsets == null)
        {
            unlockedCharactersOffsets = selectableCharactersOffsets;
        }

        unlockedCharsCheck();
 
        var endfunction: Map<String, String> = [
            "week4" => "-car",
            "week5" => "-christmas",
            "week6" => "-pixel"
        ];
        
        // Assuming WeekData.getWeekFileName() returns a String representing the week
        var weekFileName = WeekData.getWeekFileName();
         endstring = endfunction.exists(weekFileName) ? endfunction.get(weekFileName) : "";

        // Making sure the background is added first to be in the back and then adding the character names and character images afterwords
        menuBG = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = ClientPrefs.data.antialiasing;
        add(menuBG);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
        bgOverlay = new FlxSprite().loadGraphic(Paths.image('background/bgOverlay'));
        bgOverlay.setGraphicSize(Std.int(bgOverlay.width * 0.69));
        bgOverlay.updateHitbox();
        bgOverlay.screenCenter();
        bgOverlay.antialiasing = true;
        add(bgOverlay);

        // Adds the chars to the selection
        for (i in 0...unlockedCharacters.length)
        {
             characterImage = new Character(0, 0, unlockedCharacters[i]);
            if (StringTools.endsWith(unlockedCharacters[i], '-pixel'))
                characterImage.scale.set(5.5, 5.5);
            else  
            characterImage.scale.set(0.45, 0.45);

            characterImage.screenCenter();
            imageArray.push(characterImage);
            characterImage.flipX = false;

            add(characterImage);
        }
        for (i in 0...imageArray.length)
            {
                if (i != curSelected)
                    {
                colorTween = FlxTween.color(imageArray[i], 0.1, 0xffffffff, 0xff000000, {
                    onComplete: function(twn:FlxTween) {
                        colorTween = null;
                    }
                });
                FlxTween.tween(imageArray[i].scale, {x:0.4, y:0.4}, 0.1, { ease: FlxEase.quadInOut, type: FlxTween.PERSIST } );
            }
          
            }
        // Character select text at the top of the screen
        var selectionHeader:Alphabet = new Alphabet(0, 10, 'Character Select', true);
        add(selectionHeader);
        
        // New Animated Arrows
        newArrows = new FlxSprite();
        newArrows.frames = Paths.getSparrowAtlas('background/char_select_arrows');
        newArrows.animation.addByPrefix('idle', 'left static', 24, false);
        newArrows.animation.addByPrefix('left', 'left press', 24, false);
        newArrows.antialiasing = true;
        newArrows.scale.set(0.6,0.6);
        newArrows.offset.set(50, -240);
        newArrows.screenCenter(XY);
        newArrows.animation.play('idle');
        add(newArrows);

        rightarrow = new FlxSprite();
        rightarrow.frames = Paths.getSparrowAtlas('background/char_select_arrows');
        rightarrow.animation.addByPrefix('idle', 'right static', 12, false);
        rightarrow.animation.addByPrefix('right', 'right press', 12, false);
        rightarrow.antialiasing = true;
        rightarrow.scale.set(0.6,0.6);
        rightarrow.offset.set(-930 -100, -250);
        rightarrow.animation.play('idle');
        rightarrow.screenCenter(XY);
        add(rightarrow);
        // The currently selected character's name top right
        selectedCharName = new Alphabet(FlxG.width * 0.1, 620);
        selectedCharName.alignment = CENTERED;
        selectedCharName.screenCenter(X);
        selectedCharName.updateHitbox();
        add(selectedCharName);

        #if debug
        charMenuDebugText = new FlxText(FlxG.width * 0.7, FlxG.height * 0.8, 0, "", 32);
        charMenuDebugText.setFormat(fontFolder + 'vcr.ttf', 32, FlxColor.WHITE, RIGHT);
        add(charMenuDebugText);
        #end

        initializeChars();
        super.create();
    }

    override function update(elapsed:Float)
    {
        selectedCharName.text = unlockedCharactersNames[curSelected].toUpperCase();
        if (selectedCharName.text == '' || selectedCharName.text == null)
        {
            trace('No name');
            selectedCharName.text = '';
        }

        // Must be changed depending on how an engine uses its own controls
        var leftPress = controls.UI_LEFT_P; // Default for Psych
        var rightPress = controls.UI_RIGHT_P; // Default for Psych
        var accepted = controls.ACCEPT; // Should be Universal
        var goBack = controls.BACK; // Should be Universal

        #if debug
        var debugMode = FlxG.keys.justPressed.E;
        var moveDown = FlxG.keys.justPressed.K;
        var moveUp = FlxG.keys.justPressed.I;
        var moveLeft = FlxG.keys.justPressed.J;
        var moveRight = FlxG.keys.justPressed.L;
        var unlockTank = FlxG.keys.justPressed.T;
        #end
        
        if (!alreadySelected)
        {
            if (leftPress)
            {
                newArrows.offset.set(33, -250);
                newArrows.animation.play('left', true);
                changeSelection(-1);
            }
            //if (leftPress)
             //   {
              //      newArrows.offset.set(33, -250);
            //        newArrows.animation.play('left', true);
              //      changeSelection(-1);
             //   }
            if (rightPress)
            {
                
                rightarrow.offset.set(-900 - 100, -250);
                rightarrow.animation.play('right', true);
                changeSelection(1);
            }
            if (accepted)
            {
                alreadySelected = true;
        
                imageArray[curSelected].playAnim('hey', false, false);
                imageArray[curSelected].specialAnim = true;
             if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
                FlxG.sound.play(Paths.sound('confirmMenu'));

                var daSelected:String = unlockedCharacters[curSelected];
                if (unlockedCharacters[curSelected] != PlayState.SONG.player1)
                    PlayState.SONG.player1 = daSelected + endstring;


             
                    
                // This is to make the audio stop when leaving to PlayState
                FlxG.sound.music.volume = 0;

                // This is used in Psych for playing music by pressing space, but the line below stops it once the PlayState is entered
				FreeplayState.destroyFreeplayVocals();

                new FlxTimer().start((0.5), function(tmr:FlxTimer)
                {
                    // MusicBeatState.switchState(new PlayState()); // Usual way
                    FlxG.switchState(new PlayState()); // Gonna try this for Psych
                });
            }
            if (goBack)
            
            FlxG.switchState(new FreeplayState());
            
            #if debug
            if (debugMode)
            {
                inCharMenuDebug = !inCharMenuDebug;
            }
            if (inCharMenuDebug)
            {
                charMenuDebugText.alpha = 1;
                if(moveUp) {unlockedCharactersOffsets[curSelected][1]--; initializeChars();}
                if(moveDown) {unlockedCharactersOffsets[curSelected][1]++; initializeChars();}
                if(moveLeft) {unlockedCharactersOffsets[curSelected][0]--; initializeChars();}
                if(moveRight) {unlockedCharactersOffsets[curSelected][0]++; initializeChars();}
                charMenuDebugText.text = "Current Character's\nMenu Offsets:\nX: " +  unlockedCharactersOffsets[curSelected][0] + "\nY: " + unlockedCharactersOffsets[curSelected][1];
            } else {
                charMenuDebugText.alpha = 0;
            }
            #end

            for (i in 0...imageArray.length)
            {
               imageArray[i].dance();
            }

            // Code to replay arrow Idle anim when finished
            if (newArrows.animation.finished == true)
            {
                newArrows.offset.set(50, -240);
                
                newArrows.animation.play('idle');
            }
          //  if (newArrows.animation.finished == true)
             //   {
             //       newArrows.offset.set(50, -240);
                    
             //       newArrows.animation.play('idle');
             //   }
            if (rightarrow.animation.finished == true)
                {
                    rightarrow.offset.set(-930 -100, -250);
                    rightarrow.animation.play('idle');
                }
            super.update(elapsed);
        }
    }

    function initializeChars()
    {
        for (i in 0...imageArray.length)
        {
            // Sets the unselected characters to a more transparent form

            /* 
            These adjustments for Pixel characters may break for different ones, but eh, I am just making it for bf-pixel anyway
            
            Nevermind, Go to CheckFirstSlot() function to add specific offsets to make it fit better
            */
            if (StringTools.endsWith(imageArray[i].curCharacter, '-pixel'))
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * charXoffset) + 475 + unlockedCharactersOffsets[i][0];
                imageArray[i].y = (FlxG.height / 2) - 60 + unlockedCharactersOffsets[i][1];
            }
            else
            {
                imageArray[i].x = (FlxG.width / 2) + ((i - curSelected - 1) * charXoffset) + 250 + unlockedCharactersOffsets[i][0];
                imageArray[i].y = (FlxG.height / 2) - (imageArray[i].height / 2) + unlockedCharactersOffsets[i][1];
                // imageArray[i].screenCenter(Y);
            }
        }

        imageArray[curSelected].alpha = 1;

        unlockedCharsCheck();
    }

    // Changes the currently selected character
    function changeSelection(changeAmount:Int = 0):Void
    {
        curSelected += changeAmount;
        // This just ensures you don't go over the intended amount
        if (curSelected < 0)
            curSelected = unlockedCharacters.length - 1;
        if (curSelected >= unlockedCharacters.length)
            curSelected = 0;

        for (i in 0...imageArray.length)
        {
            if (i == curSelected)
                {
                FlxTween.tween(imageArray[i].scale, {x:0.45, y:0.45}, 0.1, { ease: FlxEase.quadInOut, type: FlxTween.PERSIST } );
                colorTween = FlxTween.color(imageArray[i], 0.1, 0xff000000, 0xffffffff, {
                    onComplete: function(twn:FlxTween) {
                        colorTween = null;
                    }
                });    
            }    
                    else
                {
                    FlxTween.tween(imageArray[i].scale, {x:0.4, y:0.4}, 0.1, { ease: FlxEase.quadInOut, type: FlxTween.PERSIST } );

            colorTween = FlxTween.color(imageArray[i], 0.1, 0xffffffff, 0xff000000, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
            });
        }
            var destinationX:Float = 0;

            /* 
            These adjustments for Pixel characters may break for different ones, but eh, I am just making it for bf-pixel anyway

            Nevermind, Go to CheckFirstSlot() function to add specific offsets to make it fit better
            */
            if (StringTools.endsWith(imageArray[i].curCharacter, '-pixel'))
            {
                destinationX = (FlxG.width / 2) + ((i - curSelected - 1) * charXoffset) + 475 + unlockedCharactersOffsets[i][0];
            }
            else
            {
                destinationX = (FlxG.width / 2) + ((i - curSelected - 1) * charXoffset) + 250 + unlockedCharactersOffsets[i][0];
            }
            // if (moveTween != null) moveTween.cancel();
            if (destinationTweens[i] != null) destinationTweens[i].cancel();
            destinationTweens[i] = FlxTween.tween(imageArray[i], {x : destinationX}, tweenTime, {ease: FlxEase.quadInOut});
        }
        
        unlockedCharsCheck();
    }

    
    
    function unlockedCharsCheck()
    {
        // Resets all values to ensure that nothing is broken
        if (!alreadyReset) {
            resetCharacterSelectionVars();
        }

        // Makes this universal value equal the save data
        ifCharsAreUnlocked = FlxG.save.data.daUnlockedChars;

        // If you have managed to unlock a character, set it as unlocked here
        for (i in 0...ifCharsAreUnlocked.length)
        {
            if (ifCharsAreUnlocked[i] == true)
            {
                if (!unlockedCharacters.contains(unlockableChars[i])) {
                    unlockedCharacters.push(unlockableChars[i]);
                }
                if (!unlockedCharactersNames.contains(unlockableCharsNames[i])) {
                    unlockedCharactersNames.push(unlockableCharsNames[i]);
                }
                if (!unlockedCharactersOffsets.contains(unlockableCharactersOffsets[i])) {
                    unlockedCharactersOffsets.push(unlockableCharactersOffsets[i]);
                }
            }
        }
    }

    /*
    This is used for the character that is supposed to be in the song, you may want to add your own case.
    It's to ensure that the character is properly offset in the character selection menu
    */
    function checkFirstSlot()
    {
        switch (unlockedCharacters[0])
        {
            case 'bf':
                unlockedCharactersOffsets[0] = [-724, -224];
                unlockedCharactersOffsets[0] = [-724, -224];
          case 'pico-player':
                unlockedCharactersOffsets[0] = [300, 3];
            default:
                unlockedCharactersOffsets[0] = [-600, 10];
                    unlockedCharactersOffsets[0] = [-418, -632];
               
        }
    }

    function resetCharacterSelectionVars() 
    {
        // Ensures the save data has at least 1 value
        if (FlxG.save.data.daUnlockedChars == null) {FlxG.save.data.daUnlockedChars = [false];}

        // Allows the code to determind if this has already been reset
        alreadyReset = true;

        // Just resets all things to defaults
        ifCharsAreUnlocked = [false];
        destinationTweens = [null];

        // Ensures the characters are reset and that the first one is the default character
        unlockedCharacters = selectableCharacters;
        unlockedCharacters[0] = "bf"; 

        // Grabs default character names
        unlockedCharactersNames = selectableCharactersNames;

        // Grabs default offsets
        unlockedCharactersOffsets = selectableCharactersOffsets;
    }
}
