//D0: If D0 >0, set to the map to use as reference for under combos
//D1: If D0 >0, set to the screen to use as reference for under combos (convert screen numbers from Hex to Decimal)
ffc script TruePushblockUnderCombo{
	void run(int refMap, int refScreen){
		int i;
		int pos;
		int cd; int cc; int cf; int ci;
		int pushBlockX;
		int pushBlockY;
		bool wasPushBlock; //Keeps track of whether a push block has started moving
		
		int underCMB[176];
		int underCS[176];
		int underFlag[176];
		
		//Mark which flags are push blocks
		bool pushFlags[105];
		pushFlags[CF_PUSHUPDOWN] = true;
		pushFlags[CF_PUSH4WAY] = true;
		pushFlags[CF_PUSHLR] = true;
		pushFlags[CF_PUSHUP] = true;
		pushFlags[CF_PUSHDOWN] = true;
		pushFlags[CF_PUSHLEFT] = true;
		pushFlags[CF_PUSHRIGHT] = true;
		pushFlags[CF_PUSHUPDOWNNS] = true;
		pushFlags[CF_PUSHLEFTRIGHTNS] = true;
		pushFlags[CF_PUSH4WAYNS] = true;
		pushFlags[CF_PUSHUPNS] = true;
		pushFlags[CF_PUSHDOWNNS] = true;
		pushFlags[CF_PUSHLEFTNS] = true;
		pushFlags[CF_PUSHRIGHTNS] = true;
		pushFlags[CF_PUSHUPDOWNINS] = true;
		pushFlags[CF_PUSHLEFTRIGHTINS] = true;
		pushFlags[CF_PUSH4WAYINS] = true;
		pushFlags[CF_PUSHUPINS] = true;
		pushFlags[CF_PUSHDOWNINS] = true;
		pushFlags[CF_PUSHLEFTINS] = true;
		pushFlags[CF_PUSHRIGHTINS] = true;
		
		//Set initial values for all combos on the screen
		for(i=0; i<176; i++){
			cd = Screen->ComboD[i];
			cc = Screen->ComboC[i];
			cf = Screen->ComboF[i];
			ci = Screen->ComboI[i];
			//Set combos underneath a push block
			if(pushFlags[cf] || pushFlags[ci]){
				//If a reference screen is set, draw from that
				if(refMap>0){
					underCMB[i] = Game->GetComboData(refMap, refScreen, i);
					underCS[i] = Game->GetComboCSet(refMap, refScreen, i);
					underFlag[i] = Game->GetComboFlag(refMap, refScreen, i);
				}
				//Otherwise use under combo
				else{
					underCMB[i] = Screen->UnderCombo;
					underCS[i] = Screen->UnderCSet;
					underFlag[i] = 0;
				}
			}
			else{
				underCMB[i] = cd;
				underCS[i] = cc;
				underFlag[i] = cf;
			}
		}
		
		while(true){
			//If there's a push block on the screen, manage undercombos
			if(Screen->MovingBlockX>-1){
				//If the block just started moving, set the undercombo
				if(!wasPushBlock){
					pos = ComboAt(Screen->MovingBlockX+8, Screen->MovingBlockY+8);
					Screen->ComboD[pos] = underCMB[pos];
					Screen->ComboC[pos] = underCS[pos];
					Screen->ComboF[pos] = underFlag[pos];
				}
				pushBlockX = Screen->MovingBlockX;
				pushBlockY = Screen->MovingBlockY;
				wasPushBlock = true;
			}
			else{
				wasPushBlock = false;
				
				for(i=0; i<176; i++){
					cd = Screen->ComboD[i];
					cc = Screen->ComboC[i];
					cf = Screen->ComboF[i];
					ci = Screen->ComboI[i];
					//Only update combos in the array if they aren't covered by a push block
					if(!(pushFlags[cf] || pushFlags[ci])){
						underCMB[i] = cd;
						underCS[i] = cc;
						underFlag[i] = cf;
					}
				}
			}
			Waitframe();
		}
	}
}