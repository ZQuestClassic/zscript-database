const int NPCM_WINDROBETRACKER = 0;

ffc script windWizzEmulation{
	void run(int isOW){
		int i;
		npc windrobes[256];
		int wrLastX[256];
		int wrLastY[256];
		int numWindrobes;
		
		while(true){
			//Find all windrobes on the screen. If they haven't been flagged, put them in the array
			for(i=Screen->NumNPCs(); i>0; --i){
				npc n = Screen->LoadNPC(i);
				if(n->ID==NPC_WIZZROBEWIND){
					if(!n->Misc[NPCM_WINDROBETRACKER]){
						windrobes[numWindrobes] = n;
						n->Misc[NPCM_WINDROBETRACKER] = 1;
						wrLastX[numWindrobes] = n->X;
						wrLastY[numWindrobes] = n->Y;
						++numWindrobes;
					}
				}
			}
			
			//Iterate through the array of windrobes to override their teleports
			for(i=0; i<numWindrobes; ++i){
				//Check if the enemy exists first
				if(windrobes[i]->isValid()){
					//If its X or Y has changed, we know it's teleported
					if(windrobes[i]->X!=wrLastX[i]||windrobes[i]->Y!=wrLastY[i]){
						FindWizzrobeTeleportSpot(windrobes[i], isOW);
					}
					wrLastX[i] = windrobes[i]->X;
					wrLastY[i] = windrobes[i]->Y;
				}
				//If it's invalid, replace it with the last one in the array
				else{
					windrobes[i] = windrobes[numWindrobes-1];
					wrLastX[i] = wrLastX[numWindrobes-1];
					wrLastY[i] = wrLastY[numWindrobes-1];
					--i;
					--numWindrobes;
				}
			}
			
			Waitframe();
		}
	}
	//Wizzrobe teleport logic, based on the 2.10 source
	void FindWizzrobeTeleportSpot(npc windrobe, bool isOW){
		int t;
		bool placed;
		int x; int y;
		//Roll placements until it finds one a certain distance from Link
		while(!placed&&t<160){
			if(!isOW){
				x = (Rand(12)+2)*16;
				y = (Rand(7)+2)*16;
			}
			else{
				x = (Rand(14)+1)*16;
				y = (Rand(9)+1)*16;
			}
			if(Abs(x-Link->X)>=32||Abs(y-Link->Y)>=32){
				placed = true;
			}
			++t;
		}
		windrobe->X = x;
		windrobe->Y = y;
		//Make the enemy face Link
		if(Abs(x-Link->X)<Abs(y-Link->Y)){
			if(y<Link->Y)
				windrobe->Dir = DIR_DOWN;
			else
				windrobe->Dir = DIR_UP;
		}
		else{
			if(x<Link->X)
				windrobe->Dir = DIR_RIGHT;
			else
				windrobe->Dir = DIR_LEFT;
		}
	}
}

ffc script windWizzEmulationAUTOGHOST{
	void run(int enemyID){
		int i; 
		
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		//Find if this FFC is the first instance on the screen.
		//If it isn't, quit out
		for(i=1; i<=32; ++i){
			ffc f = Screen->LoadFFC(i);
			if(f->Script==this->Script){
				if(f!=this)
					Quit();
				else
					break;
			}
		}
		
		bool isOW = true;
		if(Game->GetCurLevel()>0)
			isOW = false;
		
		npc windrobes[256];
		int wrLastX[256];
		int wrLastY[256];
		int numWindrobes;
		
		while(true){
			//Find all windrobes on the screen. If they haven't been flagged, put them in the array
			for(i=Screen->NumNPCs(); i>0; --i){
				npc n = Screen->LoadNPC(i);
				if(n->ID==NPC_WIZZROBEWIND){
					if(!n->Misc[NPCM_WINDROBETRACKER]){
						windrobes[numWindrobes] = n;
						n->Misc[NPCM_WINDROBETRACKER] = 1;
						wrLastX[numWindrobes] = n->X;
						wrLastY[numWindrobes] = n->Y;
						++numWindrobes;
					}
				}
			}
			
			//Iterate through the array of windrobes to override their teleports
			for(i=0; i<numWindrobes; ++i){
				//Check if the enemy exists first
				if(windrobes[i]->isValid()){
					//If its X or Y has changed, we know it's teleported
					if(windrobes[i]->X!=wrLastX[i]||windrobes[i]->Y!=wrLastY[i]){
						FindWizzrobeTeleportSpot(windrobes[i], isOW);
					}
					wrLastX[i] = windrobes[i]->X;
					wrLastY[i] = windrobes[i]->Y;
				}
				//If it's invalid, replace it with the last one in the array
				else{
					windrobes[i] = windrobes[numWindrobes-1];
					wrLastX[i] = wrLastX[numWindrobes-1];
					wrLastY[i] = wrLastY[numWindrobes-1];
					--i;
					--numWindrobes;
				}
			}
			
			if(ghost->isValid())
				Ghost_Waitframe2(this, ghost, false, false);
			else
				Waitframe();
		}
	}
	//Wizzrobe teleport logic, based on the 2.10 source
	void FindWizzrobeTeleportSpot(npc windrobe, bool isOW){
		int t;
		bool placed;
		int x; int y;
		//Roll placements until it finds one a certain distance from Link
		while(!placed&&t<160){
			if(!isOW){
				x = (Rand(12)+2)*16;
				y = (Rand(7)+2)*16;
			}
			else{
				x = (Rand(14)+1)*16;
				y = (Rand(9)+1)*16;
			}
			if(Abs(x-Link->X)>=32||Abs(y-Link->Y)>=32){
				placed = true;
			}
			++t;
		}
		windrobe->X = x;
		windrobe->Y = y;
		//Make the enemy face Link
		if(Abs(x-Link->X)<Abs(y-Link->Y)){
			if(y<Link->Y)
				windrobe->Dir = DIR_DOWN;
			else
				windrobe->Dir = DIR_UP;
		}
		else{
			if(x<Link->X)
				windrobe->Dir = DIR_RIGHT;
			else
				windrobe->Dir = DIR_LEFT;
		}
	}
}