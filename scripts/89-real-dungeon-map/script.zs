//Standard Version
global script Slot_2{
	void run(){
		while(true){

		//Call Dungeonmap functions
		if(Game->GetCurDMap()==1){				 //Put the dmap-number of your dungeon here
			if(!Link->Item[185]){			 //Put the number of the fake-item here
			Link->InputMap = false;
			}
		}



Waitframe();
}				 //end while(true)
}				 //end voidrun
}				 //end script

//If one of your dungeons uses 2 dmaps (for instance for a boss-battles), use this script:
global script Slot_2{
	void run(){
		while(true){

		//Call Dungeonmap functions
		if((Game->GetCurDMap()==1)||(Game->GetCurDMap()==2)){				//Put the dmap-numbers of your dungeon here
			if(!Link->Item[185]){			 //Put the number of the fake-item here
			Link->InputMap = false;
			}
		}

Waitframe();
}				 //end while(true)
}				 //end voidrun
}				 //end script

//This script is only for ONE dungeon.
//If you have for instance 3 dungeons in your game, you have to copy and paste the bold-part of the script.
//Then it looks like this:
global script Slot_2{
	void run(){
		while(true){

		//Call Dungeonmap1 functions
		if(Game->GetCurDMap()==1){				 //Put the dmap-number of your dungeon1 here
			if(!Link->Item[185]){			 //Put the number of the fake-item1 here
			Link->InputMap = false;
			}
		}

//Call Dungeonmap2 functions
		if(Game->GetCurDMap()==2){				 //Put the dmap-number of your dungeon2 here
			if(!Link->Item[186]){			 //Put the number of the fake-item2 here
			Link->InputMap = false;
			}
		}

//Call Dungeonmap3 functions
		if(Game->GetCurDMap()==3){				 //Put the dmap-number of your dungeon2 here
			if(!Link->Item[187]){			 //Put the number of the fake-item2 here
			Link->InputMap = false;
			}
		}

Waitframe();
}				 //end while(true)
}				 //end voidrun
}				 //end script