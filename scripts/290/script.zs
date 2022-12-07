const int SHUTTER_INVISIBLE_COMBO = 1; //Set this to a combo that when placed on a 4x4 FFC will be invisible.

const int CMB_BOMBWALL_MARKER = 0; //Combo used for the hint marker when using the lens on a bomb wall
const int CS_BOMBWALL_MARKER = 7; //CSet of the hint marker

const int D_LTTPDOORS = 0; //Screen->D[] (0-7) index used for directional doors
const int D_LTTPDOORID = 1; //Screen->D[] (0-7) index used for ID'd doors

const int SHUTTER_USE_FFC_CSET = 0; //If 1, will set shutters to the FFC's CSet. Else keep the CSets below the FFC.

const int SHUTTER_OPEN_FRAMES = 6; //How long in frames (60ths of a second) an animated shutter takes to open
const int SHUTTER_LOCK_OPEN_FRAMES = 12; //How long in frames (60ths of a second) an animated locked door takes to open
const int SHUTTER_BOSS_LOCK_OPEN_FRAMES = 12; //How long in frames (60ths of a second) an animated boss lock door takes to open

const int SHUTTER_REPEAT_DELAY_FRAMES = 12; //Delay between a shutter closing and opening
const int SHUTTER_LOCK_ACTIVATION_FRAMES = 12; //Delay when pushing against a locked door before it opens

const int SFX_SHUTTER_OPEN = 9; //SFX of a shutter opening
const int SFX_SHUTTER_CLOSE = 9; //SFX of a shutter closing
const int SFX_LOCK_OPEN = 9; //SFX of a lock opening
const int SFX_BOSS_LOCK_OPEN = 9; //SFX of a boss lock opening
const int SFX_BOMB_WALL_OPEN = 9; //SFX of a bomb wall being blasted open

const int LENS_MP_COST = 1; //The MP cost of the lens item

//If you have different/more lens items in your quest, this function will need to be changed
bool UsingLens(){
	if(Link->MP<LENS_MP_COST)
		return false;
	if(GetEquipmentA()==I_LENS&&Link->InputA)
		return true;
	if(GetEquipmentB()==I_LENS&&Link->InputB)
		return true;
	return false;
}

bool BombWall_HoldingItemButton(int id){
		if(GetEquipmentA()==id&&Link->InputA)
			return true;
		if(GetEquipmentB()==id&&Link->InputB)
			return true;
		return false;
	}

//LttP Shutter
//D0: Direction to the wall the shutter is on - 0: Up, 1: Down, 2: Left, 3: Right
//D1: Trigger type for the shutter
//		0: One way
//		1: Kill enemies
//		2: Push block
//		3: Combo change
//		4: Perm secret
//D2: Combo position of the trigger combo for a combo change (3) shutter
//D6: If using an opening animation, this is the first of the combo groups, starting with a closed door.
//	  Opening combo groups should be arranged vertically and be made up of doors the same size as the FFC.
//D7: If using an opening animation, this is the number of frames in the animation.

ffc script LttP_Shutter{
	void run(int dir, int openTrigger, int triggerPos, int d3, int d4, int layer, int openingCmb, int openingFrames){
		int comboPos = ComboAt(this->X+8, this->Y+8);
		
		int closedCmb = this->Data;
		int openCmb = this->Data+4*this->TileHeight;
		this->Data = SHUTTER_INVISIBLE_COMBO;
		
		//Uncheck flags that make the FFC invisible during scrolling
		this->Flags[FFCF_LENSVIS] = false;
		this->Flags[FFCF_CHANGER] = false;
		
		int triggerCD = Screen->ComboD[triggerPos];
		int triggerCC = Screen->ComboC[triggerPos];
		int triggerCF = Screen->ComboF[triggerPos];
		
		//Set opening combo relative to the open and closed states if not set
		if(openingCmb==0&&openingFrames>0){
			openingCmb = closedCmb+2*(4*this->TileHeight);
		}
		
		int linkX = Link->X;
		int linkY = Link->Y;
		//If the script is running while the screen is scrolling, Link's position will be flipped.
		if(this->Flags[FFCF_PRELOAD]){
			if(dir==DIR_UP||dir==DIR_DOWN){
				if(linkY<=0)
					linkY = 160;
				else if(linkY>=160)
					linkY = 0;
			}
			else{
				if(linkX<=0)
					linkX = 240;
				else if(linkX>=240)
					linkX = 0;
			}
		}
		
		// >using variables as labels
		// shiggydiggy
		int SHUTTER_STATE = 0; //0 = Closed, 1 = Opening, 2 = Open, 3 = Closing
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int shutter[16] = {0, 0, openCmb, closedCmb, comboPos};
		
		if(openTrigger==4&&Screen->State[ST_SECRET]){ //Doors triggered by secret state don't need to run if it's already set
			Shutter_SetCombos(this, layer, comboPos, openCmb);
			Quit();
		}
			
		int shutterCooldown;
		
		//If Link entered from this shutter, push him out and close it
		if(Shutter_LinkCollide(this, dir, linkX, linkY, false)){
			shutterCooldown = SHUTTER_REPEAT_DELAY_FRAMES;
			shutter[SHUTTER_STATE] = 2; //Open
			Shutter_SetCombos(this, layer, comboPos, openCmb);
			Waitframe();
			while(Link->Action==LA_SCROLLING||Shutter_LinkCollide(this, dir, Link->X, Link->Y, true)){
				if(Link->Action!=LA_SCROLLING)
					Shutter_MoveLink(dir);
				Waitframe();
			}
			Shutter_EjectLink(this, dir);
			Shutter_Close(this, layer, shutter, openingFrames);
		}
		else{
			if(this->Flags[FFCF_PRELOAD]){
				Shutter_SetCombos(this, layer, comboPos, closedCmb);
				//Wait for screen to finish scrolling so Link doesn't get teleported during the animation
				Waitframe();
				while(Link->Action==LA_SCROLLING){
					Waitframe();
				}
			}
			else
				Shutter_Close(this, layer, shutter, openingFrames);
		}
		
		bool open = false;
		bool wasBlock = false;
		bool blockPuzzle = false;
		if(Shutter_CountBlockTriggers()>0)
			blockPuzzle = true;
			
		int enemyCooldown = 12;
		
		while(true){
			if(openTrigger==1){ //Enemies
				if(enemyCooldown>0)
					enemyCooldown--;
				else{
					if(Shutter_CountNPCs()==0)
						open = true;
				}
			}
			else if(openTrigger==2){ //Block
				if(blockPuzzle){ //Block puzzle secrets should override screens that just have blocks
					if(Shutter_CountBlockTriggers()==0)
						open = true;
				}
				else{
					if(Screen->MovingBlockX>-1||Screen->MovingBlockY>-1)
						wasBlock = true;
					else if(wasBlock)
						open = true;
				}
			}
			else if(openTrigger==3){ //Combo change
				if(triggerCD!=Screen->ComboD[triggerPos]||triggerCC!=Screen->ComboC[triggerPos]||triggerCF!=Screen->ComboF[triggerPos]){
					open = true;
				}
				else{
					if(!Shutter_LinkCollide(this, dir, Link->X, Link->Y, true))
						open = false;
				}
			}
			else if(openTrigger==4){ //Perm secret
				if(Screen->State[ST_SECRET])
					open = true;
			}
			
			if(shutter[SHUTTER_STATE]==0&&Shutter_LinkCollide(this, dir, Link->X, Link->Y, false))
				Shutter_EjectLink(this, dir);
			
			//Open and close the shutter if it should be closed/open but isn't
			if(open&&shutter[SHUTTER_STATE]==0){
				if(shutterCooldown>0)
					shutterCooldown--;
				else
					Shutter_Open(this, layer, shutter, openingFrames);
			}
			else if(!open&&shutter[SHUTTER_STATE]==2){
				Shutter_Close(this, layer, shutter, openingFrames);
				shutterCooldown = SHUTTER_REPEAT_DELAY_FRAMES;
			}
				
			Shutter_Update(this, layer, shutter, openingCmb, openingFrames);
			Waitframe();
		}
	}
	bool Shutter_Update(ffc this, int layer, int shutter, int openingCmb, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int curFrame;
		if(shutter[SHUTTER_STATE]==1){ //Opening
			if(shutter[SHUTTER_FRAMES]>0){
				shutter[SHUTTER_FRAMES]--;
				curFrame = Clamp(Floor((SHUTTER_OPEN_FRAMES-shutter[SHUTTER_FRAMES])/(SHUTTER_OPEN_FRAMES/openingFrames)), 0, openingFrames-1);
				Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], openingCmb+curFrame*(4*this->TileHeight));
			}
			else{
				Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
				shutter[SHUTTER_STATE] = 2; //Open
			}
		}
		else if(shutter[SHUTTER_STATE]==3){ //Closing
			if(shutter[SHUTTER_FRAMES]>0){
				shutter[SHUTTER_FRAMES]--;
				curFrame = Clamp(Floor(shutter[SHUTTER_FRAMES]/(SHUTTER_OPEN_FRAMES/openingFrames)), 0, openingFrames-1);
				Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], openingCmb+curFrame*(4*this->TileHeight));
			}
			else{
				Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_CLOSEDCMB]);
				shutter[SHUTTER_STATE] = 0; //Closed
			}
		}
	}
	void Shutter_Open(ffc this, int layer, int shutter, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		Game->PlaySound(SFX_SHUTTER_OPEN);
		if(openingFrames==0){
			Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
			shutter[SHUTTER_STATE] = 2; //Open
		}
		else{
			shutter[SHUTTER_STATE] = 1; //Opening
			shutter[SHUTTER_FRAMES] = SHUTTER_OPEN_FRAMES;
		}
	}
	void Shutter_Close(ffc this, int layer, int shutter, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		Game->PlaySound(SFX_SHUTTER_CLOSE);
		if(openingFrames==0){
			Shutter_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_CLOSEDCMB]);
			shutter[SHUTTER_STATE] = 0; //Closed
		}
		else{
			shutter[SHUTTER_STATE] = 3; //Closing
			shutter[SHUTTER_FRAMES] = SHUTTER_OPEN_FRAMES;
		}
	}
	bool Shutter_SetCombos(ffc this, int layer, int comboPos, int cmb){
		int w = this->TileWidth;
		int h = this->TileHeight;
		for(int x=0; x<w; x++){
			for(int y=0; y<h; y++){
				SetLayerComboD(layer, comboPos+x+y*16, cmb+x+y*4);
				if(SHUTTER_USE_FFC_CSET)
					__SetLayerComboC(layer, comboPos+x+y*16, this->CSet);
				//Screen->ComboD[comboPos+x+y*16] = cmb+x+y*4;
			}
		}
	}
	bool Shutter_LinkCollide(ffc this, int dir, int linkX, int linkY, bool fullTile){
		if(Link->Action==LA_SCROLLING||Link->X<0||Link->X>240||Link->Y<0||Link->Y>160)
			return false;
		int w = this->TileWidth;
		int h = this->TileHeight;
		int offset = 0;
		if(fullTile) 
			offset = 16;
		if(dir==DIR_UP){
			return (linkX>=this->X-16 && linkX<=this->X+w*16 && linkY <= Max(this->Y+h*16-16+offset-8, 0));
		}
		else if(dir==DIR_DOWN){
			return (linkX>=this->X-16 && linkX<=this->X+w*16 && linkY >= this->Y-offset);
		}
		else if(dir==DIR_LEFT){
			return (linkY>=this->Y-16 && linkY<=this->Y+h*16 && linkX <= this->X+w*16-16+offset);
		}
		else if(dir==DIR_RIGHT){
			return (linkY>=this->Y-16 && linkY<=this->Y+h*16 && linkX >= this->X-offset);
		}
	}
	bool Shutter_MoveLink(int dir){
		NoAction();
		if(dir==DIR_UP){
			Link->InputDown = true;
			if(!CanWalk(Link->X, Link->Y, DIR_DOWN, 1, false))
				Link->Y++;
		}
		else if(dir==DIR_DOWN){
			Link->InputUp = true;
			if(!CanWalk(Link->X, Link->Y, DIR_UP, 1, false))
				Link->Y--;
		}
		else if(dir==DIR_LEFT){
			Link->InputRight = true;
			if(!CanWalk(Link->X, Link->Y, DIR_RIGHT, 1, false))
				Link->X++;
		}
		else if(dir==DIR_RIGHT){
			Link->InputLeft = true;
			if(!CanWalk(Link->X, Link->Y, DIR_LEFT, 1, false))
				Link->X--;
		}
	}
	bool Shutter_EjectLink(ffc this, int dir){
		if(dir==DIR_UP)
			Link->Y = this->Y+this->TileHeight*16-8;
		else if(dir==DIR_DOWN)
			Link->Y = this->Y-16;
		else if(dir==DIR_LEFT)
			Link->X = this->X+this->TileWidth*16;
		else if(dir==DIR_RIGHT)
			Link->X = this->X-16;
	}
	int Shutter_CountNPCs(){
		int count;
		for(int i=Screen->NumNPCs(); i>=1; i--){
			npc n = Screen->LoadNPC(i);
			if(n->MiscFlags&(1<<3)) //Doesn't count as a beatable enemy flag
				continue;
			if(n->Type==NPCT_GUY||n->Type==NPCT_TRAP||n->Type==NPCT_PROJECTILE||n->Type==NPCT_NONE||n->Type==NPCT_FAIRY)
				continue;
			if(n->Type==NPCT_ZORA) //Borderline if this should be a skippable enemy. I believe most ZC behaviors skip it, so I've put it here
				continue;
			count++;
		}
		return count;
	}
	int Shutter_CountBlockTriggers(){
		int count;
		for(int i=0; i<176; i++){
			if(ComboFI(i, CF_BLOCKTRIGGER))
				count++;
		}
		return count;
	}
	//A shorthand way to set a combo on the current layer.
	//Layer 0 is the screen itself.
	void __SetLayerComboC(int layer, int pos, int cset) {
	  if (layer == 0)
		Screen->ComboC[pos] = cset;
	  else
		Game->SetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, cset);
	}
}

//LttP Locked Door
//D0: Direction to the wall the door is on - 0: Up, 1: Down, 2: Left, 3: Right
//D1: Special ID of the door (0 for none, 1-16). Be sure to match it with the door on the other side so both open properly.
//D6: If using an opening animation, this is the first of the combo groups, starting with a closed door.
//	  Opening combo groups should be arranged vertically and be made up of doors the same size as the FFC.
//D7: If using an opening animation, this is the number of frames in the animation.
ffc script LttP_LockedDoor{
	void run(int dir, int id, int d2, int d3, int d4, int layer, int openingCmb, int openingFrames){
		int comboPos = ComboAt(this->X+8, this->Y+8);
		
		int closedCmb = this->Data;
		int openCmb = this->Data+4*this->TileHeight;
		this->Data = SHUTTER_INVISIBLE_COMBO;
		
		//Uncheck flags that make the FFC invisible during scrolling
		this->Flags[FFCF_LENSVIS] = false;
		this->Flags[FFCF_CHANGER] = false;
		
		//Set opening combo relative to the open and closed states if not set
		if(openingCmb==0&&openingFrames>0){
			openingCmb = closedCmb+2*(4*this->TileHeight);
		}
		
		// >using variables as labels
		// shiggydiggy
		int SHUTTER_STATE = 0; //0 = Closed, 1 = Opening, 2 = Open, 3 = Closing
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int shutter[16] = {0, 0, openCmb, closedCmb, comboPos};
		
		//If screen D bit is set, open the door
		if(LockedDoor_CheckD(dir, id)){
			if(this->Flags[FFCF_PRELOAD]){
				LockedDoor_SetCombos(this, layer, comboPos, openCmb);
				Quit();
			}
			else{
				LockedDoor_Open(this, layer, shutter, openingFrames);
			}
		}
		else{
			LockedDoor_SetCombos(this, layer, comboPos, closedCmb);
		}
		
		int lockCount = SHUTTER_LOCK_ACTIVATION_FRAMES;
		while(true){
			if(shutter[SHUTTER_STATE]==0){ //Closed
				if(LockedDoor_DetectOpen(this, dir)){
					if(lockCount>0)
						lockCount--;
					else if(LockedDoor_HasKey()){
						LockedDoor_Open(this, layer, shutter, openingFrames);
						LockedDoor_SetD(dir, id);
						LockedDoor_TakeKey();
					}
				}
				else
					lockCount = SHUTTER_LOCK_ACTIVATION_FRAMES;
			}
			LockedDoor_Update(this, layer, shutter, openingCmb, openingFrames);
			Waitframe();
		}
	}
	bool LockedDoor_Update(ffc this, int layer, int shutter, int openingCmb, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int curFrame;
		if(shutter[SHUTTER_STATE]==1){ //Opening
			if(shutter[SHUTTER_FRAMES]>0){
				shutter[SHUTTER_FRAMES]--;
				curFrame = Clamp(Floor((SHUTTER_LOCK_OPEN_FRAMES-shutter[SHUTTER_FRAMES])/(SHUTTER_LOCK_OPEN_FRAMES/openingFrames)), 0, openingFrames-1);
				LockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], openingCmb+curFrame*(4*this->TileHeight));
			}
			else{
				LockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
				shutter[SHUTTER_STATE] = 2; //Open
			}
		}
	}
	void LockedDoor_Open(ffc this, int layer, int shutter, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		Game->PlaySound(SFX_LOCK_OPEN);
		if(openingFrames==0){
			LockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
			shutter[SHUTTER_STATE] = 2; //Open
		}
		else{
			shutter[SHUTTER_STATE] = 1; //Opening
			shutter[SHUTTER_FRAMES] = SHUTTER_OPEN_FRAMES;
		}
	}
	bool LockedDoor_SetCombos(ffc this, int layer, int comboPos, int cmb){
		int w = this->TileWidth;
		int h = this->TileHeight;
		for(int x=0; x<w; x++){
			for(int y=0; y<h; y++){
				SetLayerComboD(layer, comboPos+x+y*16, cmb+x+y*4);
				if(SHUTTER_USE_FFC_CSET)
					__SetLayerComboC(layer, comboPos+x+y*16, this->CSet);
				//Screen->ComboD[comboPos+x+y*16] = cmb+x+y*4;
			}
		}
	}
	bool LockedDoor_DetectOpen(ffc this, int dir){
		int hitboxX;
		int hitboxY;
		if(dir==DIR_UP){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y+this->TileHeight*16-16;
		}
		else if(dir==DIR_DOWN){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y;
		}
		else if(dir==DIR_LEFT){
			hitboxX = this->X+this->TileWidth*16-16;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		else if(dir==DIR_RIGHT){
			hitboxX = this->X;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		
		if(Link->X>=hitboxX-8&&Link->X<=hitboxX+8&&Link->Y>=hitboxY-16&&Link->Y<=hitboxY&&Link->InputDown&&Link->Dir==DIR_DOWN&&dir<2)
			return true;
		if(Link->X>=hitboxX-8&&Link->X<=hitboxX+8&&Link->Y>=hitboxY&&Link->Y<=hitboxY+8&&Link->InputUp&&Link->Dir==DIR_UP&&dir<2)
			return true;
		if(Link->X>=hitboxX-16&&Link->X<=hitboxX&&Link->Y>=hitboxY-8&&Link->Y<=hitboxY+8&&Link->InputRight&&Link->Dir==DIR_RIGHT&&dir>=2)
			return true;
		if(Link->X>=hitboxX&&Link->X<=hitboxX+16&&Link->Y>=hitboxY-8&&Link->Y<=hitboxY+8&&Link->InputLeft&&Link->Dir==DIR_LEFT&&dir>=2)
			return true;
		return false;
	}
	bool LockedDoor_CheckD(int dir, int id){
		if(id>0)
			return Screen->D[D_LTTPDOORID]&(1<<(Clamp(id-1, 0, 15)));
		else
			return Screen->D[D_LTTPDOORS]&(1<<Clamp(dir, 0, 3));
	}
	void LockedDoor_SetD(int dir, int id){
		int offset;
		if(dir==DIR_UP)
			offset = -16;
		else if(dir==DIR_DOWN)
			offset = 16;
		else if(dir==DIR_LEFT)
			offset = -1;
		else
			offset = 1;
		int nextD;
		if(id>0){
			Screen->D[D_LTTPDOORID] |= (1<<(Clamp(id-1, 0, 15)));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID, nextD|(1<<(Clamp(id-1, 0, 15))));
		}
		else{
			Screen->D[D_LTTPDOORS] |= (1<<Clamp(dir, 0, 3));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS, nextD|(1<<Clamp(OppositeDir(dir), 0, 3)));
		}
	}
	bool LockedDoor_HasKey(){
		if(Link->Item[I_MAGICKEY])
			return true;
		if(Game->Counter[CR_KEYS]>0)
			return true;
		if(Game->LKeys[Game->GetCurLevel()]>0)
			return true;
		return false;
	}
	void LockedDoor_TakeKey(){
		if(Link->Item[I_MAGICKEY])
			return;
		if(Game->LKeys[Game->GetCurLevel()]>0)
			Game->LKeys[Game->GetCurLevel()]--;
		else if(Game->Counter[CR_KEYS]>0)
			Game->Counter[CR_KEYS]--;
	}
	//A shorthand way to set a combo on the current layer.
	//Layer 0 is the screen itself.
	void __SetLayerComboC(int layer, int pos, int cset) {
	  if (layer == 0)
		Screen->ComboC[pos] = cset;
	  else
		Game->SetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, cset);
	}
}

//LttP Boss Locked Door
//D0: Direction to the wall the door is on - 0: Up, 1: Down, 2: Left, 3: Right
//D1: Special ID of the door (0 for none, 1-16). Be sure to match it with the door on the other side so both open properly.
//D6: If using an opening animation, this is the first of the combo groups, starting with a closed door.
//	  Opening combo groups should be arranged vertically and be made up of doors the same size as the FFC.
//D7: If using an opening animation, this is the number of frames in the animation.
ffc script LttP_BossLockedDoor{
	void run(int dir, int id, int d2, int d3, int d4, int layer, int openingCmb, int openingFrames){
		int comboPos = ComboAt(this->X+8, this->Y+8);
		
		int closedCmb = this->Data;
		int openCmb = this->Data+4*this->TileHeight;
		this->Data = SHUTTER_INVISIBLE_COMBO;
		
		//Uncheck flags that make the FFC invisible during scrolling
		this->Flags[FFCF_LENSVIS] = false;
		this->Flags[FFCF_CHANGER] = false;
		
		//Set opening combo relative to the open and closed states if not set
		if(openingCmb==0&&openingFrames>0){
			openingCmb = closedCmb+2*(4*this->TileHeight);
		}
		
		// >using variables as labels
		// shiggydiggy
		int SHUTTER_STATE = 0; //0 = Closed, 1 = Opening, 2 = Open, 3 = Closing
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int shutter[16] = {0, 0, openCmb, closedCmb, comboPos};
		
		//If screen D bit is set, open the door
		if(BossLockedDoor_CheckD(dir, id)){
			if(this->Flags[FFCF_PRELOAD]){
				BossLockedDoor_SetCombos(this, layer, comboPos, openCmb);
				Quit();
			}
			else{
				BossLockedDoor_Open(this, layer, shutter, openingFrames);
			}
		}
		else{
			BossLockedDoor_SetCombos(this, layer, comboPos, closedCmb);
		}
		
		int lockCount = SHUTTER_LOCK_ACTIVATION_FRAMES;
		while(true){
			if(shutter[SHUTTER_STATE]==0){ //Closed
				if(BossLockedDoor_DetectOpen(this, dir)){
					if(lockCount>0)
						lockCount--;
					else if(BossLockedDoor_HasKey()){
						BossLockedDoor_Open(this, layer, shutter, openingFrames);
						BossLockedDoor_SetD(dir, id);
					}
				}
				else
					lockCount = SHUTTER_LOCK_ACTIVATION_FRAMES;
			}
			BossLockedDoor_Update(this, layer, shutter, openingCmb, openingFrames);
			Waitframe();
		}
	}
	bool BossLockedDoor_Update(ffc this, int layer, int shutter, int openingCmb, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		int curFrame;
		if(shutter[SHUTTER_STATE]==1){ //Opening
			if(shutter[SHUTTER_FRAMES]>0){
				shutter[SHUTTER_FRAMES]--;
				curFrame = Clamp(Floor((SHUTTER_LOCK_OPEN_FRAMES-shutter[SHUTTER_FRAMES])/(SHUTTER_LOCK_OPEN_FRAMES/openingFrames)), 0, openingFrames-1);
				BossLockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], openingCmb+curFrame*(4*this->TileHeight));
			}
			else{
				BossLockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
				shutter[SHUTTER_STATE] = 2; //Open
			}
		}
	}
	void BossLockedDoor_Open(ffc this, int layer, int shutter, int openingFrames){
		int SHUTTER_STATE = 0;
		int SHUTTER_FRAMES = 1;
		int SHUTTER_OPENCMB = 2;
		int SHUTTER_CLOSEDCMB = 3;
		int SHUTTER_COMBOPOS = 4;
		Game->PlaySound(SFX_BOSS_LOCK_OPEN);
		if(openingFrames==0){
			BossLockedDoor_SetCombos(this, layer, shutter[SHUTTER_COMBOPOS], shutter[SHUTTER_OPENCMB]);
			shutter[SHUTTER_STATE] = 2; //Open
		}
		else{
			shutter[SHUTTER_STATE] = 1; //Opening
			shutter[SHUTTER_FRAMES] = SHUTTER_OPEN_FRAMES;
		}
	}
	bool BossLockedDoor_SetCombos(ffc this, int layer, int comboPos, int cmb){
		int w = this->TileWidth;
		int h = this->TileHeight;
		for(int x=0; x<w; x++){
			for(int y=0; y<h; y++){
				SetLayerComboD(layer, comboPos+x+y*16, cmb+x+y*4);
				if(SHUTTER_USE_FFC_CSET)
					__SetLayerComboC(layer, comboPos+x+y*16, this->CSet);
				//Screen->ComboD[comboPos+x+y*16] = cmb+x+y*4;
			}
		}
	}
	bool BossLockedDoor_DetectOpen(ffc this, int dir){
		int hitboxX;
		int hitboxY;
		if(dir==DIR_UP){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y+this->TileHeight*16-16;
		}
		else if(dir==DIR_DOWN){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y;
		}
		else if(dir==DIR_LEFT){
			hitboxX = this->X+this->TileWidth*16-16;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		else if(dir==DIR_RIGHT){
			hitboxX = this->X;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		
		if(Link->X>=hitboxX-8&&Link->X<=hitboxX+8&&Link->Y>=hitboxY-16&&Link->Y<=hitboxY&&Link->InputDown&&Link->Dir==DIR_DOWN&&dir<2)
			return true;
		if(Link->X>=hitboxX-8&&Link->X<=hitboxX+8&&Link->Y>=hitboxY&&Link->Y<=hitboxY+8&&Link->InputUp&&Link->Dir==DIR_UP&&dir<2)
			return true;
		if(Link->X>=hitboxX-16&&Link->X<=hitboxX&&Link->Y>=hitboxY-8&&Link->Y<=hitboxY+8&&Link->InputRight&&Link->Dir==DIR_RIGHT&&dir>=2)
			return true;
		if(Link->X>=hitboxX&&Link->X<=hitboxX+16&&Link->Y>=hitboxY-8&&Link->Y<=hitboxY+8&&Link->InputLeft&&Link->Dir==DIR_LEFT&&dir>=2)
			return true;
		return false;
	}
	bool BossLockedDoor_CheckD(int dir, int id){
		if(id>0)
			return Screen->D[D_LTTPDOORID]&(1<<(Clamp(id-1, 0, 15)));
		else
			return Screen->D[D_LTTPDOORS]&(1<<(4+Clamp(dir, 0, 3)));
	}
	void BossLockedDoor_SetD(int dir, int id){
		int offset;
		if(dir==DIR_UP)
			offset = -16;
		else if(dir==DIR_DOWN)
			offset = 16;
		else if(dir==DIR_LEFT)
			offset = -1;
		else
			offset = 1;
		int nextD;
		if(id>0){
			Screen->D[D_LTTPDOORID] |= (1<<(Clamp(id-1, 0, 15)));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID, nextD|(1<<(Clamp(id-1, 0, 15))));
		}
		else{
			Screen->D[D_LTTPDOORS] |= (1<<(4+Clamp(dir, 0, 3)));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS, nextD|(1<<(4+Clamp(OppositeDir(dir), 0, 3))));
		}
	}
	bool BossLockedDoor_HasKey(){
		if(Game->LItems[Game->GetCurLevel()]&LI_BOSSKEY)
			return true;
		return false;
	}
	//A shorthand way to set a combo on the current layer.
	//Layer 0 is the screen itself.
	void __SetLayerComboC(int layer, int pos, int cset) {
	  if (layer == 0)
		Screen->ComboC[pos] = cset;
	  else
		Game->SetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, cset);
	}
}

//LttP Bomb Wall
//D0: Direction to the wall the door is on - 0: Up, 1: Down, 2: Left, 3: Right
//D1: Special ID of the door (0 for none, 1-16). Be sure to match it with the door on the other side so both open properly.
ffc script LttP_BombWall{
	void run(int dir, int id, int d2, int d3, int d4, int layer, int d6, int d7){
		int comboPos = ComboAt(this->X+8, this->Y+8);
		
		int openCmb = this->Data;
		int rubbleCmb = this->Data+4*this->TileHeight;
		this->Data = SHUTTER_INVISIBLE_COMBO;
		
		//Uncheck flags that make the FFC invisible during scrolling
		this->Flags[FFCF_LENSVIS] = false;
		this->Flags[FFCF_CHANGER] = false;
		
		//If screen D bit is set, open the door
		if(BombWall_CheckD(dir, id)){
			BombWall_SetCombos(this, layer, comboPos, openCmb);
			BombWall_SetRubble(this, dir, rubbleCmb);
			Quit();
		}
		
		while(true){
			//Draw a hint graphic when using the lens
			if(UsingLens()){
				int x;
				int y;
				if(dir==DIR_UP){
					x = this->X+this->TileWidth*8-8;
					y = this->Y+this->TileHeight*16-16;
				}
				else if(dir==DIR_DOWN){
					x = this->X+this->TileWidth*8-8;
					y = this->Y;
				}
				else if(dir==DIR_LEFT){
					x = this->X+this->TileWidth*16-16;
					y = this->Y+this->TileHeight*8-8;
				}
				else if(dir==DIR_RIGHT){
					x = this->X;
					y = this->Y+this->TileHeight*8-8;
				}
				
				if(CMB_BOMBWALL_MARKER>0)
					Screen->FastCombo(6, x, y, CMB_BOMBWALL_MARKER, CS_BOMBWALL_MARKER, 128);
			}
			
			if(BombWall_DetectOpen(this, dir)){
				BombWall_SetCombos(this, layer, comboPos, openCmb);
				BombWall_SetRubble(this, dir, rubbleCmb);
				BombWall_SetD(dir, id);
				Game->PlaySound(SFX_BOMB_WALL_OPEN);
				Quit();
			}
			
			Waitframe();
		}
	}
	bool BombWall_SetCombos(ffc this, int layer, int comboPos, int cmb){
		int w = this->TileWidth;
		int h = this->TileHeight;
		for(int x=0; x<w; x++){
			for(int y=0; y<h; y++){
				SetLayerComboD(layer, comboPos+x+y*16, cmb+x+y*4);
				if(SHUTTER_USE_FFC_CSET)
					__SetLayerComboC(layer, comboPos+x+y*16, this->CSet);
				//Screen->ComboD[comboPos+x+y*16] = cmb+x+y*4;
			}
		}
	}
	void BombWall_SetRubble(ffc this, int dir, int cmb){
		int rubbleX;
		int rubbleY;
		
		if(dir==DIR_UP){
			rubbleX = this->X+this->TileWidth*8-8;
			rubbleY = this->Y+this->TileHeight*16;
		}
		else if(dir==DIR_DOWN){
			rubbleX = this->X+this->TileWidth*8-8;
			rubbleY = this->Y-16;
		}
		else if(dir==DIR_LEFT){
			rubbleX = this->X+this->TileWidth*16;
			rubbleY = this->Y+this->TileHeight*8-8;
		}
		else if(dir==DIR_RIGHT){
			rubbleX = this->X-16;
			rubbleY = this->Y+this->TileHeight*8-8;
		}
		
		this->Data = cmb;
		this->X = rubbleX;
		this->Y = rubbleY;
		this->TileWidth = 1;
		this->TileHeight = 1;
	}
	bool BombWall_DetectOpen(ffc this, int dir){
		int hitboxX;
		int hitboxY;
		if(dir==DIR_UP){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y+this->TileHeight*16-16;
		}
		else if(dir==DIR_DOWN){
			hitboxX = this->X+this->TileWidth*8-8;
			hitboxY = this->Y;
		}
		else if(dir==DIR_LEFT){
			hitboxX = this->X+this->TileWidth*16-16;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		else if(dir==DIR_RIGHT){
			hitboxX = this->X;
			hitboxY = this->Y+this->TileHeight*8-8;
		}
		
		for(int i=Screen->NumLWeapons(); i>=1; i--){
			lweapon l = Screen->LoadLWeapon(i);
			if(l->CollDetection&&l->DeadState==WDS_ALIVE){
				if(l->ID==LW_BOMBBLAST||l->ID==LW_SBOMBBLAST){
					if(RectCollision(l->X+l->HitXOffset, l->Y+l->HitYOffset, l->X+l->HitXOffset+l->HitWidth-1, l->Y+l->HitYOffset+l->HitHeight-1, hitboxX, hitboxY, hitboxX+15, hitboxY+15)){
						return true;
					}
				}
			}
		}
		return false;
	}
	bool BombWall_CheckD(int dir, int id){
		if(id>0)
			return Screen->D[D_LTTPDOORID]&(1<<(Clamp(id-1, 0, 15)));
		else
			return Screen->D[D_LTTPDOORS]&(1<<(8+Clamp(dir, 0, 3)));
	}
	void BombWall_SetD(int dir, int id){
		int offset;
		if(dir==DIR_UP)
			offset = -16;
		else if(dir==DIR_DOWN)
			offset = 16;
		else if(dir==DIR_LEFT)
			offset = -1;
		else
			offset = 1;
		int nextD;
		if(id>0){
			Screen->D[D_LTTPDOORID] |= (1<<(Clamp(id-1, 0, 15)));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORID, nextD|(1<<(Clamp(id-1, 0, 15))));
		}
		else{
			Screen->D[D_LTTPDOORS] |= (1<<(8+Clamp(dir, 0, 3)));
			nextD = Game->GetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS);
			Game->SetDMapScreenD(Game->GetCurDMap(), Game->GetCurDMapScreen()+offset, D_LTTPDOORS, nextD|(1<<(8+Clamp(OppositeDir(dir), 0, 3))));
		}
	}
	//A shorthand way to set a combo on the current layer.
	//Layer 0 is the screen itself.
	void __SetLayerComboC(int layer, int pos, int cset) {
	  if (layer == 0)
		Screen->ComboC[pos] = cset;
	  else
		Game->SetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, cset);
	}
}