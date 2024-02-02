package states.stages;

import flixel.math.FlxPoint;

class Spooky extends BaseStage
{
	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;
	override function create()
	{
		halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloween_bg halloweem bg0000', 'halloween_bg halloweem bg lightning strike']);
	
		add(halloweenBG);

		//PRECACHE SOUNDS
		precacheSound('thunder_1');
		precacheSound('thunder_2');

	
	}


	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	    halloweenBG.animation.play('halloween_bg halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(dad.animOffsets.exists('scared')) {
			dad.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

	}


}