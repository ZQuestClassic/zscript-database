//Attach this to the pick-up slot of a "Kill All Enemies" item in the item editor.

import "std.zh" // <- Remove this whole line if this is already included in your script file(s).

item script KillEnemiesQuake
{
    void run (int sfx)
    {
        Screen-> Quake = 120; //60 frames per second so 60 = 1 second. But feel free to toy with it.
        Game-> PlaySound(sfx); //Set D0 to the number of the sound you want to play.
	Link->Jump = 1; //Optional if you want Link to hop a little. Anything more than 3 is really high though. Not exactly sure how this is measured, but 1 is a half tile (8 pixels)
    }
}