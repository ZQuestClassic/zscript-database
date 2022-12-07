//Place this FFC on top of the screen return square (for post-puzzle, non-resetting teleport)
//D0: Combo in the OFF state (Step->Next combo type; hasn't been stepped on)
//D1: Combo that has been triggered but still walkable (defaults to 1 after OFF combo)
//D2: Combo in the ON state (non-walkable; defaults to 1 after pressed combo)
//D3: Sound to play when Link steps on an OFF combo
//D4: Secret mode
//-1 = Use screen secrets
//-2 = no permanence (target combo)
//-3 = no permanence (temporary secret)
//0-7 = save to screen D variable (target combo)
//D5: Combo to change if D4 = -2 or 0-7; changes to the next in the list
ffc script hamiltonianPath{
	void run( int offCombo, int pressedCombo, int onCombo, int changeSound, int perm, int targetCombo ){
		int numTriggersLast = 175; //Number of triggers last frame
		int numTriggers = 0; //Number of triggers left
		int triggerCombo = -1;
		int underLink = -1;
		//If not given D1 or D2, set them to the combos following the combos that are specified
		if ( !pressedCombo )
		pressedCombo = offCombo + 1;
		if ( !onCombo )
		onCombo = pressedCombo + 1;
		//Set initial trigger number
		for ( int i = 0; i < 175; i++ )
		if ( Screen->ComboD[i] == offCombo )
		numTriggersLast++;

		while( (perm == -1 && !Screen->State[ST_SECRET]) //Loop until secrets are triggered
		|| (perm >= 0 ) //Or in screen D[] mode (ends after first frame)
		|| (perm < -1)//Or forever if no permanence
		){
			underLink = ComboAt ( Link->X+8, Link->Y+8 ); //Find the combo under Link
			Link->Jump = 0; //Don't let Link jump
			Link->Z = 0; //That's cheating!

			//If Link presses L, give up
			//Can replace "PressL" with any other button
			if ( Link->PressL ){
				Link->Warp(Game->GetCurDMap(), Game->GetCurDMapScreen());
			}


			//SoundCombo: if fewer triggers this frame than last, play sound
			numTriggers = 0; //Reset trigger count
			//Count all the triggers (OFF combos)
			for ( int i = 0; i < 175; i++ )
			if ( Screen->ComboD[i] == offCombo )
			numTriggers++;
			if ( numTriggers < numTriggersLast ){
				Game->PlaySound(changeSound);
				numTriggersLast = numTriggers; //Update trigger state
				//Now change the trigger combos
				for ( int i = 0; i < 175; i++ ){ //Check each combo
					if ( i != underLink && Screen->ComboD[i] == pressedCombo ) //If it's a pressed combo and Link isn't standing on it
					Screen->ComboD[i] = onCombo;
				}
			}


			//If permanence by D variable is set and puzzle was completed before
			if(perm > 0 && perm < 8 && Screen->D[perm])
			numTriggers = 0; //Make the secrets code run

			//SecretsIfNotFound: if no triggers remain, trigger secrets and quit
			if ( numTriggers <= 0 ){ //If no OFF combos remain
				if ( perm == -3 || perm == -1 ) //Temp or perm secrets mode
				Screen->TriggerSecrets(); //Trigger secrets
				if ( perm == -1 ) //Perm secrets mode
				Screen->State[ST_SECRET] = true; //Store to screen secrets
				else if ( (perm >= 0 && perm < 8) || perm == -2 ){ //D[] or temp mode
					for ( int i = 0; i < 175; i++ )
					if ( Screen->ComboD[i] == targetCombo )
					Screen->ComboD[i]++; //Change all target combos to the next
					if ( perm >= 0 ) //D[] mode
					Screen->D[perm] = 1; //Save to Screen D variable
				}
				Game->PlaySound(SFX_SECRET); //Play the secret SFX
				break; //In case permanent secrets are disabled, force the script to end
			}

			Waitframe(); //Let the engine continue to run
		}

		//If the player gets stuck but still solves the puzzle, let him teleport to starting position
		while(true){
			//If Link presses L, give up
			//Can replace "PressL" with any other button
			if ( Link->PressL ){
				//Warping resets the puzzle - instead, move Link to the FFC's position
				Link->X = this->X;
				Link->Y = this->Y;
			}
			Waitframe();
		}
	}
}