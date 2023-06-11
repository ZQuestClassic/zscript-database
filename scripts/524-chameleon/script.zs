//OoA Chameleon Moves like Gel. If it stays on same colored combo for some time, it becomes invisible and invincible. Otherwise it needs some time to change CSet to CSet of combo he o is on.

//Random rate, hunger, homing factor, halt rate and step speed are used.
//Attribute 0 - Time needed for adaptation, in frames. 
//Attribute 1 - Enemy X size.
//Attribute 1 - Enemy Y size.

ffc script Chameleon{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int delay = Ghost_GetAttribute(ghost, 0, 15);//Attribute 0 - Max delay between changing directions. 
		int sizex = Ghost_GetAttribute(ghost, 1, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 2, 1);//Tile Height
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = 0;
		int cmb=ComboAt(CenterX(ghost), CenterY(ghost));
		Ghost_CSet = Screen->ComboC[cmb];
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		int counter=delay;
		
		while(true){
			if (State==0){
				haltcounter = Ghost_HaltingWalk4(haltcounter, SPD, RR, HF, HNG, HR, (Rand(8)<<3)+2);
				cmb = ComboAt(CenterX(ghost), CenterY(ghost));
				if (Screen->ComboC[cmb]==Ghost_CSet){
					if (counter>0 && ghost->DrawXOffset==0){
						counter--;
						if (counter==0){
							ghost->DrawXOffset=1000;
							Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
							counter=delay;
						}
					}
				}
				else{
					if (ghost->DrawXOffset==1000){
						ghost->DrawXOffset=0;
						Ghost_SetDefenses(ghost, defs);
						counter=delay;
					}
					else{
						counter--;
						if (counter==0){
							Ghost_CSet = Screen->ComboC[cmb];
							counter=delay;
						}
					}
				}
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
			if (sizex*sizey >= 2)Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
			Quit();
			}
		}
	}
}