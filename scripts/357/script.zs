//Start Screen (Press Start)

//Basically, what this script does, is trigger screen secrets when you
//press Start or A.
//That allows you to use this script as a Title Screen, by using a combo
//with the AutoSideWarp(A-D) type as the secret that shows up on screen.

//You need these to make the script work.
//Most projects need these anyway, so just make sure that
	//you have them set to import in the Script Buffer.
	//If you don't, either add a line to import them, or remove
	//the comment block "//" from the next two lines.
	
//import "std.zh"
//import "ffcscript.zh"

/////////
//Setup//
////////

//Import Script as normal
//Setup your title screen - MAKE SURE YOU BLOCK LINK'S MOVEMENTS with solid
	//combos. (Just in case he can move for some odd reason, which should NOT happen)
	//Also make sure that Link is set to Invisible,
	//and your secret sound is "none" in the Screen Settings (F9).
	//You can set the sound using D0 of the FFC.
	
//Place ffc in title screen room (use a valid combo), and set this script to it
	//Set D0 to the sound you want to use when you press Start
	//Set D1 to the amount of time you want to make it wait before warping
	//to the target screen.
	
//Setup a combo with the AutoSideWarp type, that blends with your title screen

//Make the autowarp tile the secret combo (16-31)

//Place Secret Tile 0 flag in the room

//Setup your warps using the screen/dMap you want to go to, and the warp you
	//used for the AutoSideWarp combo.
	//(If you used AutoSideWarp(D), then you need to setup Side Warp (D)
	//with your destination.
	
//////////
//Script//
/////////

ffc script StartScreen {
	void run(int sndPlay, int triggerTime) {
		
		while (true) {
			Link->InputB = false;
			Link->InputMap = false;
			Link->InputUp = false;
			Link->InputDown = false;
			Link->InputLeft = false;
			Link->InputRight = false;
			Link->InputEx1 = false;
			Link->InputEx2 = false;
			Link->InputEx3 = false;
			if (Link->PressStart == true || Link->PressA == true) {
				Game->PlaySound(sndPlay);
				for(int i = 0; i < triggerTime; i++) {
					
					WaitNoAction();
				}
				Screen->TriggerSecrets();
			}
			
			Waitframe();
		}
	}
}