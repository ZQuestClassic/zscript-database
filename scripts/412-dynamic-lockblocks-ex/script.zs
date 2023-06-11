const int SCREEN_D_LOCK = 0; //Screen В to track lockblocks ststes

const int SFX_ERROR = 16; //Sound to play on failure to unlock lockblock.
const int SFX_UNLOCK = 9; //Sound to play on unlocking lockblock. 
const int SFX_LOCK = 9;// Sound to play on locking locblock and retrieving items.

//1. Set up items that add to counters in Item Editor.
//2. Set up 2 sequential combos. 1 for locked state, 1 for unlocked one. Set their type to None and solidity to full-solid.
//3. Set SCREEN_D_LOCK constant to avoid conflicts with other scripts.
//4. Import and compile the script. Nothing beyond default libraries is needed. Assign 2 FFC script slots.
//5. Place 1 invisible FFC for each dynamic lockblock onto combo in the screen from step 1, assign MultiitemDynamicLock script.
// - D0 to D5: item requirements and counter costs as following:
//   if D>=0 - #####.____ - Counter to check.
//             _____.#### - Counter cost. 
//   if D<0  - Abs(D) - ID of item required.
//  All of those conditions must be met simultaneously to unlock lockblock.
//  D6 - Screen D bit used to track lockblock state. Must be unique for each lockblock in the screen.
//  D7 - Abs->String to display when cannot afford unlocking.
//   If D7 id set to <0, items will get stuck in lockbock, rendering it stay unlocked permanently.
//6. Place 1 invisible FFC with LockBlockTrigger script.
// D0 - Number of dynamic lockblocks need to be unlocked to trigger.
// D1 - Screen State to track. Only use 8-LockBlock, 9-BossLockBlock, 10-TreasureChest, 11-LockedChest and 12-BossLockedChest screen states.
// D2 - Quake power to trigger when unlocked. if set to <0, also stops music.

ffc script MultiitemDynamicLock{
	void run(int item1, int item2, int item3, int item4, int item5, int item6, int dbit, int msg){
		int itemreq[6] = {item1,item2,item3,item4,item5,item6};
		bool unlocked = GetScreenDBit(SCREEN_D_LOCK, dbit);
		int cmb = ComboAt(CenterX(this), CenterY(this));
		int origdata = this->Data;
		if (unlocked){
			this->Data++;
			Screen->ComboD[cmb]++;
		}
		if (msg<0){
			if (unlocked) Quit();
		}
		while(true){
			if (PressedOn(this)){
				if (!unlocked){
					if (HasEnoughItems(itemreq)){
						Game->PlaySound(SFX_UNLOCK);
						SubtractItemCost(itemreq);
						SetScreenDBit(SCREEN_D_LOCK, dbit, true);
						unlocked=true;
						this->Data++;
						Screen->ComboD[cmb]++;
						if (msg<0) Quit();
					}
					else {
						Game->PlaySound(SFX_ERROR);
						Screen->Message(Abs(msg));
					}
				}
				else{
					Game->PlaySound(SFX_LOCK);
					RetreiveItemCost(itemreq);
					SetScreenDBit(SCREEN_D_LOCK, dbit, false);
					unlocked=false;
					this->Data--;
					Screen->ComboD[cmb]--;
				}
			}
		Waitframe();
		}
	}
}

ffc script LockBlockTrigger{
	void run (int numlocks, int state, int quake){
		int cmb_normal = 0;
		int cmb_copycat = 0;
		if (state == ST_LOCKBLOCK){
			cmb_normal = 59;
			cmb_copycat = 60;
		}
		else if (state == ST_BOSSLOCKBLOCK){
			cmb_normal = 61;
			cmb_copycat = 62;
		}
		else if (state == ST_CHEST){
			cmb_normal = 65;
			cmb_copycat = 66;
		}
		else if (state == ST_LOCKEDCHEST){
			cmb_normal = 67;
			cmb_copycat = 68;
		}
		else if (state == ST_BOSSCHEST){
			cmb_normal = 69;
			cmb_copycat = 70;
		}
		int ret = 0;
		while(true){
			ret=0;			
			for (int i=1; i<=17; i++){
				if(GetScreenDBit(SCREEN_D_LOCK, i)) ret++;
			}
			if (ret>=numlocks){
				if (!Screen->State[state]){
					Screen->State[state] = true;
					for (int i=0; i<176; i++){
						if (Screen->ComboT[i] == cmb_normal) Screen->ComboD[i]++;
						if (Screen->ComboT[i] == cmb_copycat) Screen->ComboD[i]++;
					}
					Screen->Quake= Abs(quake);
					if (quake<0) Game->PlayMIDI(0);
				}
			}
			else {
				if (Screen->State[state]){
					Screen->State[state] = false;
					for (int i=0; i<176; i++){
						Screen->ComboD[i]--;
						if ((Screen->ComboT[i] == cmb_normal)||(Screen->ComboT[i] == cmb_copycat )) {}
						else Screen->ComboD[i]++;
					}
				}
			}
			debugValue(1, ret);
			Waitframe();
		}
	}
}

//Returns true, if Link tries to open lockblock.
bool PressedOn(ffc f){
	int curx = Link->X;
	int cury = Link->Y;
	int npcx = f->X;
	int npcy = f->Y;
	int borderx = f->EffectWidth;
	int bordery = f->EffectHeight;
	if (RectCollision(curx, cury, (curx+16), (cury+16), (npcx-4), npcy, npcx, (npcy+bordery))){
		if ((Link->Dir == DIR_RIGHT)&&(Link->PressA)){
			return true;
		}
	}
	if (RectCollision(curx, cury, (curx+16), (cury+16), npcx, (npcy - 4), (npcx + borderx), npcy)){
		if ((Link->Dir == DIR_DOWN)&&(Link->PressA)){
			return true;
		}
	}
	if (RectCollision(curx, cury, (curx+16), (cury+16), npcx, (npcy + bordery), (npcx+borderx), (npcy+bordery+4))){
		if ((Link->Dir == DIR_UP)&&(Link->PressA)){
			return true;
		}
	}
	if (RectCollision(curx, cury, (curx+16), (cury+16), (npcx+borderx), npcy, (npcx+borderx+4), (npcy+bordery))){
		if ((Link->Dir == DIR_LEFT)&&(Link->PressA)){
			return true;
		}
	}
	return false;
}

bool HasEnoughItems(int arritem){
	for (int i=0; i<SizeOfArray(arritem);i++){
		if (arritem[i]>0){
			int counter = GetHighFloat(arritem[i]);
			int cost = GetLowFloat(arritem[i]);
			if (Game->Counter[counter]<cost) return false;
			else continue;
		}
		if (arritem[i]<0){
			int req = arritem[i]*-1;
			if (!Link->Item[req]) return false;
			else continue;
		}
	}
	return true;
}

void  SubtractItemCost(int arritem){
	for (int i=0; i<SizeOfArray(arritem);i++){
		if (arritem[i]>0){
			int counter = GetHighFloat(arritem[i]);
			int cost = GetLowFloat(arritem[i]);
			Game->Counter[counter] -=cost;
		}
		if (arritem[i]<0){
			int req = arritem[i]*-1;
			Link->Item[req] = false;
		}
	}
}

void RetreiveItemCost(int arritem){
	for (int i=0; i<SizeOfArray(arritem);i++){
		if (arritem[i]>0){
			int counter = GetHighFloat(arritem[i]);
			int cost = GetLowFloat(arritem[i]);
			Game->Counter[counter] +=cost;
		}
		if (arritem[i]<0){
			int req = arritem[i]*-1;
			Link->Item[req] = true;
		}
	}
}