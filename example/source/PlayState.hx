package;

import flixel.FlxState;
import flixel.FlxG;

class PlayState extends FlxState
{
	var swagInformations:Array<Dynamic> = [
        {
            text: 'Game',
            onClick: [exit_game, apply_fullScreen],
            namesList: ['FullScreen','Leave Game']
        },
        {
            text: 'Audio',
            onClick: [up_audio, down_audio, pause_music],
            namesList: ["+ Volume", "- Volume", "Pause/UnPause"]
        }
    ];

	var bar:UIBar;

	override public function create()
	{
		if(FlxG.sound.music==null) FlxG.sound.playMusic('assets/music/coolMusic.ogg',0.8,true);

		bar = new UIBar(swagInformations);
		add(bar);

		super.create();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	static function exit_game() #if desktop Sys.exit(1); #end
	static function apply_fullScreen() FlxG.fullscreen = !FlxG.fullscreen;
	static function up_audio() FlxG.sound.volume += 0.1;
	static function down_audio() FlxG.sound.volume -= 0.1;
	static function pause_music() FlxG.sound.music.playing ? FlxG.sound.music.pause() : FlxG.sound.music.resume();
}
