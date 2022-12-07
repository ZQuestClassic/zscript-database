import "std.zh"
import "ffcscript.zh"

const int DoorAutoWarpA = 2; //combo ID of a combo with an autowarp A combo type
const int DoorComboType = 142; //combotype for doors (script 1 by default)

int ScrollwarpingDoors[4];
const int doorWalk = 0;
const int doorWalkLinkDir = 1;
const int doorNextScreenLinkX = 2;
const int doorNextScreenLinkY = 3;

global script ActiveScript{
	void run(){
		while(true){
			int ScrollWarpingDoors[] = "ScrollwarpingDoors";
			if ( CountFFCsRunning(Game->GetFFCScript(ScrollWarpingDoors)) == 0 )
				RunFFCScript(Game->GetFFCScript(ScrollWarpingDoors), 0);
			Waitframe();
		}
	}
}

ffc script ScrollwarpingDoors{
	void run(){
		Link->Invisible = false;
		Link->CollDetection = true;
		int doorfound;
		if ( ScrollwarpingDoors[doorWalk] == 1 ) {
			Link->Dir = ScrollwarpingDoors[doorWalkLinkDir];
			doorfound = 0;
			while(doorfound != -1){
				if ( Screen->ComboT[ComboAt(Link->X+8, Link->Y - doorfound)] == DoorComboType ) {
					Link->Y = Link->Y - doorfound - 14;
					doorfound = -1;
				}
				else
					doorfound += 16;
				if ( doorfound >= 256 )
					doorfound = -1;
			}
		}
		if ( ScrollwarpingDoors[doorWalk] == 2 ) {
			Link->Dir = ScrollwarpingDoors[doorWalkLinkDir];
			doorfound = 0;
			while(doorfound != -1){
				if ( Screen->ComboT[ComboAt(Link->X + doorfound, Link->Y+12)] == DoorComboType ) {
					Link->X = Link->X + doorfound + 10;
					doorfound = -1;
				}
				else
					doorfound += 16;
				if ( doorfound >= 256 )
					doorfound = -1;
			}
		}
		if ( ScrollwarpingDoors[doorWalk] == 3 ) {
			Link->Dir = ScrollwarpingDoors[doorWalkLinkDir];
			doorfound = 0;
			while(doorfound != -1){
				if ( Screen->ComboT[ComboAt(Link->X+8, Link->Y + doorfound)] == DoorComboType ) {
					Link->Y = Link->Y + doorfound + 6;
					doorfound = -1;
				}
				else
					doorfound += 16;
				if ( doorfound >= 256 )
					doorfound = -1;
			}
		}
		if ( ScrollwarpingDoors[doorWalk] == 4 ) {
			Link->Dir = ScrollwarpingDoors[doorWalkLinkDir];
			doorfound = 0;
			while(doorfound != -1){
				if ( Screen->ComboT[ComboAt(Link->X - doorfound, Link->Y+8)] == DoorComboType ) {
					Link->X = Link->X - doorfound - 10;
					doorfound = -1;
				}
				else
					doorfound += 16;
				if ( doorfound >= 256 )
					doorfound = -1;
			}
		}
		ScrollwarpingDoors[doorWalk] = 0;
		int initialLinkX = Link->X;
		int initialLinkY = Link->Y;
		//Screen->EntryX = Link->X; Screen->EntryY = Link->Y;
		int linkdrowning = 0;
		while(true){
			if ( Link->Z == 0 && Link->Action != LA_SPINNING && comboDoorNorth(ComboAt(Link->X+8, Link->Y+12)) ) {
				Link->Invisible = true;
				ScrollwarpingDoors[doorWalkLinkDir] = Link->Dir;
				Link->Dir = DIR_UP;
				Screen->SetSideWarp(0, Game->GetCurDMapScreen() - 16, Game->GetCurDMap(), WT_SCROLLING);
				ScrollwarpingDoors[doorWalk] = 1;
				this->Data = DoorAutoWarpA;
				ScrollwarpingDoors[doorNextScreenLinkX] = Link->X;
				ScrollwarpingDoors[doorNextScreenLinkY] = Link->Y+176;
				NoAction();
			}
			if ( Link->Z == 0 && Link->Action != LA_SPINNING && comboDoorEast(ComboAt(Link->X+8, Link->Y+12)) ) {
				Link->Invisible = true;
				ScrollwarpingDoors[doorWalkLinkDir] = Link->Dir;
				Link->Dir = DIR_RIGHT;
				Screen->SetSideWarp(0, Game->GetCurDMapScreen() + 1, Game->GetCurDMap(), WT_SCROLLING);
				ScrollwarpingDoors[doorWalk] = 2;
				this->Data = DoorAutoWarpA;
				ScrollwarpingDoors[doorNextScreenLinkX] = Link->X-256;
				ScrollwarpingDoors[doorNextScreenLinkY] = Link->Y;
				NoAction();
			}
			if ( Link->Z == 0 && Link->Action != LA_SPINNING && comboDoorSouth(ComboAt(Link->X+8, Link->Y+12)) ) {
				Link->Invisible = true;
				ScrollwarpingDoors[doorWalkLinkDir] = Link->Dir;
				Link->Dir = DIR_DOWN;
				Screen->SetSideWarp(0, Game->GetCurDMapScreen() + 16, Game->GetCurDMap(), WT_SCROLLING);
				ScrollwarpingDoors[doorWalk] = 3;
				this->Data = DoorAutoWarpA;
				ScrollwarpingDoors[doorNextScreenLinkX] = Link->X;
				ScrollwarpingDoors[doorNextScreenLinkY] = Link->Y-176;
				NoAction();
			}
			if ( Link->Z == 0 && Link->Action != LA_SPINNING && comboDoorWest(ComboAt(Link->X+7, Link->Y+12)) ) {
				Link->Invisible = true;
				ScrollwarpingDoors[doorWalkLinkDir] = Link->Dir;
				Link->Dir = DIR_LEFT;
				Screen->SetSideWarp(0, Game->GetCurDMapScreen() - 1, Game->GetCurDMap(), WT_SCROLLING);
				ScrollwarpingDoors[doorWalk] = 4;
				this->Data = DoorAutoWarpA;
				ScrollwarpingDoors[doorNextScreenLinkX] = Link->X+256;
				ScrollwarpingDoors[doorNextScreenLinkY] = Link->Y;
				NoAction();
			}
			
			if ( Link->Action == LA_DROWNING || linkdrowning == 64 )
				linkdrowning ++;
			if ( linkdrowning == 64 ) {
				Link->Invisible = true;
				NoAction();
			}
			if ( linkdrowning == 65 ) {
				Link->Invisible = false;
				linkdrowning = 0;
				Link->X = initialLinkX;
				Link->Y = initialLinkY;
			}
			Waitframe();
		}
	}
	bool comboDoorNorth(int cp) {
		if ( Screen->ComboT[cp] == DoorComboType && Screen->ComboS[cp] == 0101b )
			return true;
		else
			return false;
	}
	bool comboDoorEast(int cp) {
		if ( Screen->ComboT[cp] == DoorComboType && Screen->ComboS[cp] == 1100b )
			return true;
		else
			return false;
	}
	bool comboDoorSouth(int cp) {
		if ( Screen->ComboT[cp] == DoorComboType && Screen->ComboS[cp] == 1010b )
			return true;
		else
			return false;
	}
	bool comboDoorWest(int cp) {
		if ( Screen->ComboT[cp] == DoorComboType && Screen->ComboS[cp] == 0011b )
			return true;
		else
			return false;
	}
}

//D0:
//0 = one way only
//1 = killing all enemies opens shutter (temporary)
//2 = permanent secrets opens shutter
//3 = shutter opens when no flag 16 is found (temporary)
ffc script ScrollwarpingDoorShutter{
	void run(int type){
		int thisData = this->Data;
		int thisCSet = this->CSet;
		this->Data = FFCS_INVISIBLE_COMBO;
		if ( type == 2 && Screen->State[ST_SECRET] )
			Quit();
		int cp = ComboAt(this->X+8, this->Y+8);
		int doorDir;
		if ( Screen->ComboS[cp] == 0101b )
			doorDir = DIR_DOWN;
		if ( Screen->ComboS[cp] == 1100b )
			doorDir = DIR_LEFT;
		if ( Screen->ComboS[cp] == 1010b )
			doorDir = DIR_UP;
		if ( Screen->ComboS[cp] == 0011b )
			doorDir = DIR_RIGHT;
		int underCombo = Screen->ComboD[cp];
		int underCSet = Screen->ComboC[cp];
		int LinkX = Link->X;
		if ( ScrollwarpingDoors[doorWalk] != 0 )
			LinkX = ScrollwarpingDoors[doorNextScreenLinkX];
		if(LinkX<=0)
			LinkX = 0;
		else if(LinkX>=240)
			LinkX = 240;
		int LinkY = Link->Y;
		if ( ScrollwarpingDoors[doorWalk] != 0 )
			LinkY = ScrollwarpingDoors[doorNextScreenLinkY];
		if(LinkY<=0)
			LinkY = 0;
		else if(LinkY>=160)
			LinkY = 160;
		int moveDir = Link->Dir;
		if(ScrollwarpingDoors[doorWalk] != 0 && GB_Shutter_InShutter(this, LinkX, LinkY, doorDir)){
			if(LinkY==0)
				moveDir = DIR_DOWN;
			else if(LinkY==160)
				moveDir = DIR_UP;
			else if(LinkX==0)
				moveDir = DIR_RIGHT;
			else if(LinkX==240)
				moveDir = DIR_LEFT;
			Waitframe();
			while(GB_Shutter_InShutter(this, Link->X, Link->Y, doorDir)){
				NoAction();
				if(moveDir==DIR_UP)
					Link->InputUp = true;
				else if(moveDir==DIR_DOWN)
					Link->InputDown = true;
				else if(moveDir==DIR_LEFT)
					Link->InputLeft = true;
				else if(moveDir==DIR_RIGHT)
					Link->InputRight = true;
				Waitframe();
			}
			//MooshPit_ResetEntry();
			Game->PlaySound(SFX_SHUTTER);
			this->Data = thisData+1;
			this->CSet = thisCSet;
			for(int i=0; i<4; i++){
				if(moveDir==DIR_UP)
					Link->Y = Min(Link->Y, this->Y-16);
				else if(moveDir==DIR_DOWN)
					Link->Y = Max(Link->Y, this->Y+8);
				else if(moveDir==DIR_LEFT)
					Link->X = Min(Link->X, this->X-16);
				else if(moveDir==DIR_RIGHT)
					Link->X = Max(Link->X, this->X+16);
				Waitframe();
			}
			this->Data = FFCS_INVISIBLE_COMBO;
			Screen->ComboD[cp] = thisData;
			Screen->ComboC[cp] = thisCSet;
			//if(type==1)
				Waitframes(8);
		}
		else {
			Screen->ComboD[cp] = thisData;
			Screen->ComboC[cp] = thisCSet;
			//if(type==1)
				Waitframes(8);
			//else
			//	Waitframe();
		}
		while(true){
			if(type==1){
				if(!GB_Shutter_CheckEnemies()){
					break;
				}
			}
			if(type==2){
				if(Screen->State[ST_SECRET]){
					break;
				}
			}
			if(type==3){
				if(GB_Shutter_CheckFlag16()){
					break;
				}
			}
			Waitframe();
		}
		Game->PlaySound(SFX_SHUTTER);
		Screen->ComboD[cp] = underCombo;
		Screen->ComboC[cp] = underCSet;
		this->Data = thisData+1;
		this->CSet = thisCSet;
		Waitframes(4);
		this->Data = FFCS_INVISIBLE_COMBO;
	}
	bool GB_Shutter_InShutter(ffc this, int LinkX, int LinkY, int doorDir){
		if ( ScrollwarpingDoors[doorWalk] == 1 && doorDir == DIR_UP && RectCollision(LinkX, LinkY, LinkX+15, LinkY+15, this->X, this->Y, this->X+15, this->Y+144) )
			return true;
		if ( ScrollwarpingDoors[doorWalk] == 2 && doorDir == DIR_RIGHT && RectCollision(LinkX, LinkY, LinkX+15, LinkY+15, this->X-224, this->Y, this->X+15, this->Y+15) )
			return true;
		if ( ScrollwarpingDoors[doorWalk] == 3 && doorDir == DIR_DOWN && RectCollision(LinkX, LinkY, LinkX+15, LinkY+15, this->X, this->Y-144, this->X+15, this->Y+15) )
			return true;
		if ( ScrollwarpingDoors[doorWalk] == 4 && doorDir == DIR_LEFT && RectCollision(LinkX, LinkY, LinkX+15, LinkY+15, this->X, this->Y, this->X+224, this->Y+15) )
			return true;
		if ( ScrollwarpingDoors[doorWalk] == 0 && RectCollision(LinkX, LinkY, LinkX+15, LinkY+15, this->X, this->Y, this->X+15, this->Y+15) )
			return true;
		return false;
	}
	bool GB_Shutter_CheckEnemies(){
		for(int i=Screen->NumNPCs(); i>=1; i--){
			npc n = Screen->LoadNPC(i);
			if(n->Type!=NPCT_PROJECTILE&&n->Type!=NPCT_FAIRY&&n->Type!=NPCT_TRAP&&n->Type!=NPCT_GUY){
				if(!(n->MiscFlags&(1<<3)))
					return true;
			}
		}
		return false;
	}
	bool GB_Shutter_CheckFlag16(){
		for(int i=0; i<=6; i++){
			if ( LastComboFlagOf(16, i) != -1 && (i == 0 || Screen->LayerMap(i) != -1) )
				return false;
		}
		return true;
	}
}