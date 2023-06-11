//import "std.zh"

const int SFX_GBSHIELD = 17; //Shield active SFX

int shieldItem; //Shield item to give (set by item script, reset each frame)
bool shieldButton; //False = B, True = A

global script gbshield_global{
	void run(){
		//Initializations
		bool shieldOn;

		while(true){
			if( !shieldOn && shieldItem ){ //Enable shield when using dummy
				shieldOn=true; //Set shield state to on
				Link->Item[shieldItem]=true; //Give the shield
				Game->PlaySound(SFX_GBSHIELD); //Play the sound
			}
			else if( ( (shieldButton && !Link->InputA)||(!shieldButton && !Link->InputB)) //When button is released
					&& shieldOn){ //And shield is still on
				Link->Item[shieldItem]=false; //Remove shield
				shieldItem = 0; //Reset shield item variable
				shieldOn = false; //Set shield state to off
			}

			Waitframe(); //Needed at bottom of while(true) loop
		} // end while
	} //end void run
}

//D0: "Real" shield item to give
item script gbshield{
	void run ( int shield ){
		shieldItem = shield;
		if ( Link->PressB ) shieldButton = false;
		else if ( Link->PressA ) shieldButton = true;
	}
}