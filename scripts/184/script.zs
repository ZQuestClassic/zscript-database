const int SFX_DROP_ITEM = 7; //Sound to play on dropping item.

//Triggers secrets when specific enemy dies.
//Place anywhere in the screen.
//DO: Enemy Slot
//D1: Set to anything > 0 for secret permanency.
ffc script EnemySecret{ 
	void run (int enemyslot, int perm){
		Waitframes(4); //Needed for ZC for initialize enemies
		npc trigger = Screen->LoadNPC(enemyslot); // Get a pointer for needed enemy
		while ( trigger->isValid()) Waitframe(); //Wait until enemy dies.
		Screen->TriggerSecrets(); // Trigger secrets
		Game->PlaySound(SFX_SECRET); //Play secret discovery jingle.
		if (perm>0) Screen->State[ST_SECRET]=true; //Set screen state to render secrets permanent.
	}
}

//Kills all enemies when specific screen state is set.
//Place anywhere in the screen.
//D0: Screen State to check. Refer to stdConstants.zh for determining which number to set.
ffc script SecretKillAllEnemies{ 
	void run(int state){
		Waitframes(4); // Needed to allow engine to initialize enemies
		while (!Screen->State[state]) Waitframe(); // Wait until desired screen state is set to true 
		for (int i=1; i<= Screen->NumNPCs(); i++){ // Kill all enemies on screen
			npc kill= Screen->LoadNPC(i);
			kill->HP=0;
		}
	}
}


// Triggers secrets when specific screen state is set
//Place anywhere in the screen.
//D0: Screen State to check. Refer to stdConstants.zh for determining which number to set.
//D1: Set to 1 to render secrets permanent.
//D2: Set Screen State to "false" on reentering for reusability (useful for 2.10-styled bosses).
//    Any number > 0 activates this function.
ffc script ScreenStateTrigger{ 
	void run (int state, int perm, int falsestart){
		if (falsestart>0) Screen->State[state]=false; // Set the screen state to false if needed (like reusable ambush trap)
		while (!Screen->State[state]) Waitframe(); // Wait until screen state is set to true.
		Game->PlaySound(SFX_SECRET); //Trigger screen secrets, complete with all accessories.
		Screen->TriggerSecrets();
		if (perm>0) Screen->State[ST_SECRET]=true;
	}
}

// Drops Screen`s Special Item when combo underneath FFC
//changes into another one. Works just like flag 10 but more versatile.
//Place the FFC where you want to drop item.
//No arguments needed.
ffc script SpecialItemDropper{
	void run(){ //Yes! No arguments needed!
		if (Screen->State[ST_SPECIALITEM]) Quit(); //Special item is already gone.
		int loc = ComboAt (this->X+8,this->Y+8);// Get combo location given it`s X and Y values.
		int origcombo = Screen->ComboD[loc]; //Set original combo.
		if (Screen->RoomType != RT_SPECIALITEM) Quit(); //Quit if room type is not "Special Item"
		int dropitem= Screen->RoomData; //See "Catch All" menu to set special item.
		if (dropitem == 0) Quit(); //No item set. Finita la comedia.
		while (Screen->ComboD[loc] == origcombo) Waitframe(); //Wait until combo changes into another one.
		Game->PlaySound(SFX_DROP_ITEM); //Play item drop jingle.
		item prize= Screen->CreateItem(dropitem); //Create Special Item.
		prize->X=this->X; //Place it at FFC`s position.
		prize->Y=this->Y;
		prize->Pickup=0x802; // Set pickup flags to "Hold up item on pickup" and "Set Special Item screen state".
	}
}

//Checks specific screen state and drops Screen`s Special Item, if set to TRUE.
//Place the FFC where you want to drop item. 
//D0: Screen state to check. Refer to stdConstants.zh for various screen states.
ffc script StateSpecialItem{
	void run (int state){
		int framespassed =0; // Time spent in that screen, in frames. 
		if (Screen->State[ST_SPECIALITEM]) Quit(); //Special item is already gone.
		if (Screen->RoomType != RT_SPECIALITEM) Quit(); //Quit if room type is not "Special Item"
		int dropitem= Screen->RoomData; //See "Catch All" menu to set special item.
		if (dropitem == 0) Quit(); ////No item set. Finita la comedia.
		while (!Screen->State[state]){ //Wait until screen state is set to TRUE, while 'Frames passed" ticks up.
			framespassed++;
			Waitframe();
		}
		if (framespassed) Game->PlaySound(SFX_DROP_ITEM); //If the screen state was already TRUE, no secret discovery jingle will play.
		item prize= Screen->CreateItem(dropitem); //Create Special Item.
		prize->X=this->X; //Place it at FFC`s position.
		prize->Y=this->Y;
		prize->Pickup=0x802; // Set pickup flags to "Hold up item on pickup" and "Set Special Item screen state".
	}
}