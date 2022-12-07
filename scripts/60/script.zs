ffc script Locked{
	void run(int dir, int offset, int adjacent, bool boss, bool big){
		//Wait until the door is unlocked by Link if not already unlocked on screen init.
		while(!GetScreenDBit(0, dir) && !OpeningDoor(this, dir%4, boss)) Waitframe();
		//Initialize a variable as the location of combo the ffc is placed at.
		int comboLoc = ComboAt(this->X, this->Y);
		//Change the variable we just initialized according to the dir and big arguments.
		if(dir%4 == 0 || big) comboLoc -= 16;
		if(dir%4 == 2) comboLoc -= 1;
		//Loop through the horizontal combos.
		for(int i; i < 2; i++){
			//In each iteration of the loop, loop through the vertical combos.
			for(int j; (big && j < 3) || j < 2; j++){
				//Increment the combo data of the combo by the offset argument.
				int combo = comboLoc + i + (16 * j);
				Screen->ComboD[combo] += offset;
			}
		}
		//Check the screen D bit (dir) on register 0, and if it's already set skip the rest of the script.
		if(!GetScreenDBit(0, dir)){
			//It wasn't set which means Link just opened the door. So set it so it opens on screen init.
			SetScreenDBit(0, dir, true);
			//For back to back doors we need to set the screen bit on the adjacent screen.
			SetScreenDBit(adjacent, 0, AdjacentDir(dir), true);
			//If not a boss door subtract 1 key from Link's inventory.
			if(!boss){
				if(Game->LKeys[Game->GetCurLevel()] > 0) Game->LKeys[Game->GetCurLevel()]--;
				else Game->Counter[CR_KEYS]--;
			}
			//Lastly play a sound effect.
			Game->PlaySound(SFX_SHUTTER);
		}
	}
	//This function checks if link is trying to open the door, and meets the requirements to do so.
	bool OpeningDoor(ffc this, int dir, bool boss){
		//If a boss door and the player has no boss key return false;
		if(boss && !GetLevelItem(LI_BOSSKEY)) return false;
		//If not a boss door and the player has no keys return false;
		else if(!boss && Game->Counter[CR_KEYS] == 0 && Game->LKeys[Game->GetCurLevel()] == 0) return false;
		//Check if Link is near-centered with the door nonfacing central axis.
		else if(dir < 2 && Abs(Link->X - this->X) >= 4) return false;
		else if(dir >= 2 && Abs(Link->Y - this->Y) >= 4) return false;
		//Lastly return whether or not Link is next to the door and pushing against it.
		else if(dir == 0) return (Link->Y == this->Y + 8 && Link->InputUp);
		else if(dir == 1) return (Link->Y == this->Y - 16 && Link->InputDown);
		else if(dir == 2) return (Link->X == this->X + 16 && Link->InputLeft);
		else if(dir == 3) return (Link->X == this->X - 16 && Link->InputRight);
	}
	//This Function returns the direction of the adjacent screens locked door.
	int AdjacentDir(int dir){
		//We need a variable for both loops which is the number of doors
		int i;
		//dir%4 incrementing i by one each time we wrap.
		for(; dir >= 4; i++) dir -= 4;
		//Flip dir around so we have the opposite direction.
		dir = OppositeDir(dir);
		//Now add i4 to dir.
		dir += (i*4);
		//Lastly return dir.
		return dir;
	}
}

ffc script Shutter{
	void run(int dir, int offset, int type, bool oneway, bool big){
		//Check if Link is in the doorway.
		if(InDoorway(this, OppositeDir(dir))){
			//Link is in the doorway so open the shutter, copy & pasted from above.
			int comboLoc = ComboAt(this->X, this->Y);
			if(dir == 0 || big) comboLoc -= 16;
			if(dir == 2) comboLoc -= 1;
			for(int i; i < 2; i++){
				for(int j; (big && j < 3) || j < 2; j++){
					int combo = comboLoc + i + (16 * j);
					Screen->ComboD[combo] += offset;
				}
			}
			//Wait until the screen finishes scrolling.
			do{
				Waitframe(); //The scrolling doesn't start on screen init but one frame afterwards.
			} while(Link->Action == LA_SCROLLING);
			//Force Link into the room by nulling all controls accept the correct arrow key.
			while(InDoorway(this, dir)){
				NoAction();
				if(dir == 0) Link->InputDown = true;
				else if(dir == 1) Link->InputUp = true;
				else if(dir == 2) Link->InputRight = true;
				else if(dir == 3) Link->InputLeft = true;
				Waitframe();
			}
			//Close the shutter behind Link, copy & pasted from above.
			for(int i; i < 2; i++){
				for(int j; (big && j < 3) || j < 2; j++){
					int combo = comboLoc + i + (16 * j);
					Screen->ComboD[combo] -= offset;
				}
			}
			//Play the shutter sound effect.
			Game->PlaySound(SFX_SHUTTER);
		}
		//Otherwise wait a while. "Makes it so all shutters open simultaneously if the condition is fulfilled on screen init."
		else{
			do{
				Waitframe();
			} while(Link->Action == LA_SCROLLING);
			Waitframes(25);
		}
		//End the script here if it's a one way shutter.
		if(oneway) Quit();
		//Initialize blocks as the number of blocks on the screen.
		int blocks = NumBlocks();
		//Wait until the condition for opening the shutter is fulfilled.
		while(true){
			if(type == 0 && NoEnemies()) break;
			else if(type == 1 && NumBlocks() != blocks) break;
			else if(type == 2 && LastComboFlagOf(CF_BLOCKTRIGGER, 0) == -1) break;
			else if(type == 3 && Screen->State[ST_SECRET]) break;
			//If you need a custom condition for the shutter just add a else if at the end of the loop and assign it a number other than 0-3.
			Waitframe();
		}
		//If it's a block->shutter wait 20 frames.
		if(type == 1) Waitframes(20);
		//Else if it's a secret->shutter set the secret screen state to false.
		else if(type == 3) Screen->State[ST_SECRET] = false;
		//Open the shutter, copy and pasted from above.
		int comboLoc = ComboAt(this->X, this->Y);
		if(dir == 0 || big) comboLoc -= 16;
		if(dir == 2) comboLoc -= 1;
		for(int i; i < 2; i++){
			for(int j; (big && j < 3) || j < 2; j++){
				int combo = comboLoc + i + (16 * j);
				Screen->ComboD[combo] += offset;
			}
		}
		//Lastly play the shutter sound since it just opened.
		Game->PlaySound(SFX_SHUTTER);
	}
	//This function checks if link is in the doorway.
	bool InDoorway(ffc this, int dir){
		//Simply check link's position relative to the number and the location of the ffc.
		if(dir == 0) return(Link->X == this->X && Link->Y < 32);
		else if(dir == 1) return(Link->X == this->X && Link->Y > 128);
		else if(dir == 2) return(Link->Y == this->Y && Link->X < 32);
		else if(dir == 3) return(Link->Y == this->Y && Link->X > 208);
	}
	//This function check if all enemies have been defeated as if it was a normal shutter room.
	bool NoEnemies(){
		//Initialize a boolean as true.
		bool condition = true;
		//Loop through every npc.
		for(int i = Screen->NumNPCs(); i > 0; i--){
			//Load each npc to a pointer.
			npc n = Screen->LoadNPC(i);
			//Continue if the enemy is a item fairy.
			if(n->ID == NPC_ITEMFAIRY) continue;
			//Continue if the enemy has the "Doesn't count as beatable enemy" flag.
			else if(GetNPCMiscFlag(n, 8)) continue;
			//Since a beatable enemy exists, set condition to false and break out of the loop.
			condition = false;
			break;
		}
		return condition;
	}
	//This function returns the number of combos with push _ trigger flags.
	int NumBlocks(){
		//Declare the blocks variable.
		int blocks;
		//Loop through all 176 combos.
		for(int i; i < 176; i++){
			//If the inherited or placement flag is 1, 2, or 47 - 51 increment blocks.
			if(ComboFI(i, 1)) blocks++;
			else if(ComboFI(i, 2)) blocks++;
			else if(ComboFI(i, 47)) blocks++;
			else if(ComboFI(i, 48)) blocks++;
			else if(ComboFI(i, 49)) blocks++;
			else if(ComboFI(i, 50)) blocks++;
			else if(ComboFI(i, 51)) blocks++;
		}
		//Return the blocks variable.
		return blocks;
	}
}

ffc script Bombable{
	void run(int dir, int offset, int adjacent, int dustdata, int dustloc, bool big){
		//Check if the wall was already bombed by checking screen d bit (dir) on register 0.
		if(GetScreenDBit(0, dir)){
			//Open a hole in the wall, copy and pasted from above.
			int comboLoc = ComboAt(this->X, this->Y);
			if(dir == 0 || big) comboLoc -= 16;
			if(dir == 2) comboLoc -= 1;
			for(int i; i < 2; i++){
				for(int j; (big && j < 3) || j < 2; j++){
					int combo = comboLoc + i + (16 * j);
					Screen->ComboD[combo] += offset;
				}
			}
			//Change the ffc's data to dustdata and reposition it.
			this->Data = dustdata;
			this->X = ComboX(dustloc);
			this->Y = ComboY(dustloc);
			//Check if Link is in the doorway.
			if(InDoorway(this, OppositeDir(dir), big)){
				//The following is copy and pasted from the shutter script.
				do{
					Waitframe();
				} while(Link->Action == LA_SCROLLING);
				while(InDoorway(this, dir, big)){
					NoAction();
					if(dir%4 == 0) Link->InputDown = true;
					else if(dir%4 == 1) Link->InputUp = true;
					else if(dir%4 == 2) Link->InputRight = true;
					else if(dir%4 == 3) Link->InputLeft = true;
					Waitframe();
				}
			}
			//Since there's nothing else to do end the script.
			Quit();
		}
		//Declare the bombed variable.
		bool bombed;
		//Loop until bombed becomes true.
		while(!bombed){
			//Loop through each lweapon on screen.
			for(int i = Screen->NumLWeapons(); i > 0 && !bombed; i--){
				//Load the lweapon to a pointer.
				lweapon l = Screen->LoadLWeapon(i);
				//If the weapon is not a bomb blast or super bomb blast end this iteration of the loop.
				if(l->ID != LW_BOMBBLAST && l->ID != LW_SBOMBBLAST) continue;
				//If collision for the weapon is on and it collided with the ffc set bombed to true.
				if(Collision(this, l) && l->CollDetection) bombed = true;
			}
			Waitframe();
		}
		//copy and pasted from locked script.
		int comboLoc = ComboAt(this->X, this->Y);
		if(dir == 0 || big) comboLoc -= 16;
		if(dir == 2) comboLoc -= 1;
		for(int i; i < 2; i++){
			for(int j; (big && j < 3) || j < 2; j++){
				int combo = comboLoc + i + (16 * j);
				Screen->ComboD[combo] += offset;
			}
		}
		//copy and pasted from above.
		this->Data = dustdata;
		this->X = ComboX(dustloc);
		this->Y = ComboY(dustloc);
		//Set the screen D bit for (dir) on register 0.
		SetScreenDBit(0, dir, true);
		//Set the screen D bit for the adjacent screen.
		SetScreenDBit(adjacent, 0, AdjacentDir(dir), true);
	}
	//Function copy and pasted from shutter script.
	bool InDoorway(ffc this, int dir, bool big){
		int mod = 0;
		if(dir < 2 || !big) mod = 8;
		if(dir == 0) return(Link->X == this->X+mod && Link->Y < 32);
		else if(dir == 1) return(Link->X == this->X+mod && Link->Y > 128);
		else if(dir == 2) return(Link->Y == this->Y+mod && Link->X < 32);
		else if(dir == 3) return(Link->Y == this->Y+mod && Link->X > 208);
	}
	//Function copy and pasted from locked script.
	int AdjacentDir(int dir){
		int i;
		for(; dir >= 4; i++) dir -= 4;
		dir = OppositeDir(dir);
		dir += (i*4);
		return dir;
	}
}