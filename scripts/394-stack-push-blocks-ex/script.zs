const int SFX_PUSHBLOCK_MOVE = 50; //Sound to play when moving a block.
const int SFX_PUSHBLOCK_LAND_ON_TRIGGER = 16; //Sound to play when block gets stuck when landing on trigger.
const int SFX_PUSHBLOCK_STUCK_AFTER_ONE_PUSH = 16; //Sound to play when block flagged with #52,53,54,55,56,57 or 58 gets stuck after one push.
const int SFX_ICEBLOCK_PUSH = 21; //Sound to play when ice block gets pushed.
const int SFX_ICEBLOCK_STOP = 16; //Sound to play when ice block stops by hitting obstacle.
const int SFX_BLOCKHOLE = 0; //Sound to play when block falls into block hole (flag #91).
const int SFX_ICEBLOCK_PAINT = 0; //Sound to play when painting iceblock paints floor tile
const int SFX_PUSHBLOCK_DESTROY = 32;//Sound to play when pushblock is destroyed

const int SPR_PUSHBLOCK_DESTROY = 95; //Sprite to display, when pushblock is destroyed

const int CF_FFICEBLOCK = 98; //Combo Place Flag used by AutomaticFreeformPushblockPuzzle script to generate ice blocks.
const int CIF_STACKPUSH_ONLY = 99; //Combo Inherent Flag used by AutomaticFreeformPushblockPuzzle script to generate StackPush only blocks.

const int IC_MULTIPUSHBLOCK = 18; //Class of items used to allow Link to push stacked blocks
const int I_MULTIPUSHBLOCK = 56; //If set to >0 Link would not be able to push more than 1 block at time without this item.

const int PUSHBLOCK_SENSIVITY = 8; //Pushblock time sensivity, in frames. 

//FFC misc flags. Set to avoid conflicts with other FFC scripts.
//const int FFC_MISC_PUSHBLOCK_IMPULSE = 0; //FFC Misс variable to track block moving direction
//const int FFC_MISC_PUSHBLOCK_POWER = 1;//FFC Misс variable to track Link`s pushing power granted by IC_MULTIPUSHBLOCK item class. 
//Maximum stack weight cannot exceed this value.
//const int FFC_MISC_PUSHBLOCK_UNDERCSET = 2;//FFC Misс variable to track Cset of combo under pushblock FFC.

//Special block flags, OR them toether to define special pushblock properties. DON`T EDIT THESE CONSTANTS
const int PUSHBLOCK_SPECIAL_ENEMY_WAIT = 1; //Cannot be pushed until all enemies on screen are killed. 
const int PUSHBLOCK_SPECIAL_CAN_PUSH_OFF_TRIGGERS = 2; //Can be pushed off triggers.
const int PUSHBLOCK_SPECIAL_ONLY_ONE_PUSH= 4; //Gets stuck after 1 push.
const int PUSHBLOCK_SPECIAL_TRIGGER= 8; //Triggers screen secrets when moved.
const int PUSHBLOCK_SPECIAL_ICEBLOCK = 16; //Turns this block into Ice Pushblock that after push continues to move until hitting obstacle.
const int PUSHBLOCK_SPECIAL_REMOVE_ON_SECRET = 32; //Removed when triggering secrets.
const int PUSHBLOCK_SPECIAL_MULTIPUSH_ONLY = 64; //Cannot be pushed directly, only in stack with other blocks.
const int PUSHBLOCK_SPECIAL_ICEBLOCK_PAINTS_FLOOR = 128; //Iceblock paints floor, for floor painting puzzles
const int PUSHBLOCK_SPECIAL_CHANGE_NEXT = 256; //Changes combo to next in the list after every push
const int PUSHBLOCK_SPECIAL_DESTRUCTIVE_UNDERCOMBO = 512; //Always leave behind screen`s undercombo on every push

//Update V2.1
//Pushblock FFC is now invisible, when idle.

//Update V2.2
// Fixed stackpushing of iceblocks
// Ice blocks can now get stuck if landed on triggers. Set D0 to 1 in FFC with
//  AutomaticFreeformPushblockPuzzle script to avoid that.
// Added new FFC script - Remote controlled Pushblocks. Stand on FFC, face the chosen direction and press EX1 to push all pushblocks

//Update V2.3
//If painting iceblock FFC and floor that needs to be painted match CSets, floor combo, instead, will change to next one in the list.
//Added iceblock painting sound.
//New script - PlaceableIceblock
//New puzzle option - blocks change to next combo in the list after every push

//Update V2.4
//No Longer uses Misc variables.
//Fixed bug that caused bracelet items to be unused, if ID exceeds 143.
//UpdateFreeformBlockPower item pickup script is become redundant, as GetPraceletPower function was rewritten to increase perfomance. 

//Update V2.5
//New script Match-2 puzzle 
//New flag for pushblocks - always leave undercombos behind, like ZC engine pushables.

// Automatic Freeform Push Block generator script.
//1. Place FFC anywhere on the screen
//2. Construct block puzzle as if you did it in ZC 2.53- versions, but use only placed flags.
//  -Flag Ice PushBlocks with CF_FFICEBLOCK flags
//  - The only inherent flag that works is CIF_STACKPUSH_ONLY that restricts blocks to StackPush only
//3. D0 - Allow blocks to be pushed off triggers, like in classic Sokoban.
//   D1 - Remove all blocks and clean up FFC`s when puzzle is solved.
//   D2 - Special Puzzle mode
//        1.Ice Push blocks paint floor into his own Cset. 
//          If all combos flagged with CF_BLOCKTRIGGER are painted, secrets pop open.
//        2.Colored blocks and block triggers. Each block trigger must be covered by block with matching cset to solve.
//          If D0 is set to 0, blocks can get stuck on mismatching triggers, failing the puzzle.
//        3.Pushblocks change to next combo in the list after every push.
//   D3 - 1 - Always leave udercombos behind
ffc script AutomaticFreeformPushblockPuzzle{
	void run(int pushofftriggers, int secretremove, int icepaint, int undercombos){
		int str[] = "FreeformPushBlock";
		int scr = Game->GetFFCScript(str);
		int generic[22] = {1, 2, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, CF_FFICEBLOCK};
		int dirup[3] = {48, 55, 62};
		int dirdown[3] = {49, 56, 63};
		int dirleft[3] = {50, 57, 64};
		int dirright[3] = {51, 58, 65};
		int dirhoriz[3] = {47, 53, 60};
		int dirvert[3] = {1, 52, 59};
		int dir4way[3] = {2, 54, 61};
		int pushonce[7] = {52, 53, 54, 55, 56, 57, 58};
		int pushtrigger[7] = {1, 2, 47, 48, 49, 50, 51};
		int ctwait[3] = {8, 10, 27};
		int ctweight1[2] = {9, 10};
		int ctweight2[2] = {26, 27};
		int pushflags[177];
		for (int i=1; i<176; i++){
			if (MatchComboI(generic, i)) pushflags[i] = Screen->ComboI[i];
			if (MatchComboF(generic, i)) pushflags[i] = Screen->ComboF[i];
			if (pushflags[i]==0)continue;
			int args[3]= {0, 0, 0};
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirup[q]) args[0] = 1;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirdown[q]) args[0] = 2;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirleft[q]) args[0] = 4;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirright[q]) args[0] = 8;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirhoriz[q]) args[0] = 12;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dirvert[q]) args[0] = 3;
			}
			for (int q=0; q<3; q++){
				if (pushflags[i]==dir4way[q]) args[0] = 15;
			}
			for (int q=0; q<7; q++){
				if (pushflags[i]==pushonce[q]) args[2] |= 4;
			}
			for (int q=0; q<7; q++){
				if (pushflags[i]==pushtrigger[q]) args[2] |= 12;
			}
			for (int q=0; q<3; q++){
				if (Screen->ComboT[i]==ctwait[q]) args[2] |= 1;
			}
			for (int q=0; q<2; q++){
				if (Screen->ComboT[i]==ctweight1[q]) args[1] = 1;
			}
			for (int q=0; q<2; q++){
				if (Screen->ComboT[i]==ctweight2[q]) args[1] = 2;
			}
			if (Screen->ComboI[i]==CIF_STACKPUSH_ONLY) args[2] |= 64;
			if (pushflags[i]==CF_FFICEBLOCK){
				args [0] = 15;
				args [1] = 0;
				args [2] = 18;
				if (pushofftriggers==0) args[2]-=2;
				if (icepaint==1) args [2] |= PUSHBLOCK_SPECIAL_ICEBLOCK_PAINTS_FLOOR;
			}
			if (pushofftriggers>0) args[2]|=2;
			if (secretremove>0) args[2]|=32;
			if (icepaint==3)args[2]|=256;
			if (undercombos>0)args[2]|=512;
			ffc block = RunFFCScriptOrQuit(scr, args);
			block->X= ComboX(i);
			block->Y= ComboY(i);
			Screen->ComboF[i] = 0;
		}
		int tr[] = "FreeformPushBlockTriggers";
		scr = Game->GetFFCScript(tr);
		int trarg[8] = {0, 0, 0, 0, 0, 0, 0, 0};
		if (secretremove>0) trarg[0] =1;
		if (icepaint==2) trarg[1] =1;
		ffc trig = RunFFCScriptOrQuit(scr,trarg);		
	}
}

//Freeform Push Block script. Unlike normal push blocks. Link can push stack of these blocks, instead of 1 at time, if he has the powerful bracelet. 
// Place FFC at position of block.
// D0 - Allowed push directions for this block.
// D1 - Weight of block.
// D2 - Special flags, ORed together. Refer to PUSHBLOCK_SPECIAL_* constants at the top of this script file.
ffc script FreeformPushBlock {
	void run ( int dircs, int weight, int special ){
		int pos = ComboAt (CenterX (this), CenterY (this));
		this->Data = Screen->ComboD[pos];
		this->CSet = Screen->ComboC[pos];
		this->X= ComboX(pos);
		this->Y = ComboY(pos);
		this->Flags[FFCF_LENSVIS] = true;
		int undercombo = Screen->UnderCombo;
		this->InitD[6] = Screen->UnderCSet;
		int framecounter=0;
		int movecounter = 0;
		bool stackpush = true;
		if (special&PUSHBLOCK_SPECIAL_MULTIPUSH_ONLY) stackpush = false;
		int itm = GetCurrentItem(IC_MULTIPUSHBLOCK);
		this->InitD[5]=0;
		if (itm>=0){
			itemdata it= Game->LoadItemData(itm);
			this->InitD[5] = it->Power;
		}
		this->InitD[7]= -1;
		if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK_PAINTS_FLOOR)>0) this->InitD[6] = this->CSet;
		while (true){
			// Check if Link is pushing against the block
			if((Link->X == this->X - 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputRight && Link->Dir == DIR_RIGHT) || // Right
			(Link->X == this->X + 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputLeft && Link->Dir == DIR_LEFT) || // Left
			(Link->Y == this->Y - 16 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputDown && Link->Dir == DIR_DOWN) || // Down
			(Link->Y == this->Y + 8 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputUp && Link->Dir == DIR_UP)) { // Up
				framecounter++;
			}
			else {
				// Reset the frame counter
				framecounter = 0;
			}
			if (framecounter>=8){
				if (CanBePushed(this, Link->Dir, weight, stackpush)){
					if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK)==0)Game->PlaySound(SFX_PUSHBLOCK_MOVE);
					else Game->PlaySound(SFX_ICEBLOCK_PUSH);
				}
				framecounter=0;
			}
			if (this->InitD[7]>=0 && this->InitD[7]<=3){
				if (movecounter==0){
					movecounter = 16;
					this->Flags[FFCF_LENSVIS] = false;
					if ((special&PUSHBLOCK_SPECIAL_DESTRUCTIVE_UNDERCOMBO)>0){
						Screen->ComboD[pos] = Screen->UnderCombo;
						Screen->ComboC[pos] = Screen->UnderCSet;
					}
					else{
						Screen->ComboD[pos] = undercombo;
						Screen->ComboC[pos] = this->InitD[6];
					}
				}
				else {
					if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK)>0 && movecounter >8){
						if (!IceblockCanContinueSlide(this)) movecounter=0;
					}
					if (movecounter>0){
						NoAction();
						movecounter--;
						if (this->InitD[7]==DIR_UP) this->Y--;
						if (this->InitD[7]==DIR_DOWN) this->Y++;
						if (this->InitD[7]==DIR_LEFT) this->X--;
						if (this->InitD[7]==DIR_RIGHT) this->X++;
						if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK)>0){
							movecounter--;
							if (this->InitD[7]==DIR_UP) this->Y--;
							if (this->InitD[7]==DIR_DOWN) this->Y++;
							if (this->InitD[7]==DIR_LEFT) this->X--;
							if (this->InitD[7]==DIR_RIGHT) this->X++;
						}
					}
					if (movecounter<=0){
						if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK_PAINTS_FLOOR)>0){
							pos = ComboAt (CenterX (this), CenterY (this));
							this->X = ComboX(pos);
						this->Y = ComboY(pos);
						if (ComboFI(pos, CF_BLOCKTRIGGER)){
							if (Screen->ComboC[pos]==this->CSet){
								Game->PlaySound(SFX_ICEBLOCK_PAINT);
							Screen->ComboF[pos]=0;
							Screen->ComboD[pos]++;
							}
							else if (Screen->ComboC[pos]!=this->CSet){
								Game->PlaySound(SFX_ICEBLOCK_PAINT);
								Screen->ComboC[pos] = this->CSet;
								Screen->ComboF[pos]=0;
							}
						}
						for (int i=0; i<=176; i++){
							if (i==176){
								if (Screen->State[ST_SECRET]) break;
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET] = true;
								break;
							}
							if ((ComboFI(i,CF_BLOCKTRIGGER))) break;
							//if ((Screen->ComboC[i]) != (this->CSet)) break;
						}
						}
						if (IceblockCanContinueSlide(this)) movecounter=16;
						else{
							
							pos = ComboAt (CenterX (this), CenterY (this));
							this->X = ComboX(pos);
							this->Y = ComboY(pos);							
							undercombo = Screen->ComboD[pos];
							this->InitD[6] = Screen->ComboC[pos];
							int flag = Screen->ComboI[pos];
							if (ComboFI(pos, CF_BLOCKHOLE)){
								Game->PlaySound(SFX_BLOCKHOLE);
								Screen->ComboD[pos]++;
								ClearFFC(FFCNum(this));
								Quit();
							}
							if ((special&PUSHBLOCK_SPECIAL_CHANGE_NEXT)>0)this->Data++;
							Screen->ComboD[pos] = this->Data;
							Screen->ComboC[pos] =this-> CSet;
							this->InitD[7]=-1;
							this->Flags[FFCF_LENSVIS] = true;
							//this->InitD[7]=0;
							if ((special&PUSHBLOCK_SPECIAL_ICEBLOCK)>0) Game->PlaySound(SFX_ICEBLOCK_STOP);
							if ((special&PUSHBLOCK_SPECIAL_TRIGGER)>0){
								Game->PlaySound(27);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]= true;
								this->InitD[0]=0;
							}
							else{
								if ((special&PUSHBLOCK_SPECIAL_ONLY_ONE_PUSH)>0){
									Game->PlaySound(SFX_PUSHBLOCK_STUCK_AFTER_ONE_PUSH);
									this->InitD[0]=0;
								}
								if ((Screen->ComboF[pos]==CF_BLOCKTRIGGER)||(flag==CF_BLOCKTRIGGER)){
									if((special&PUSHBLOCK_SPECIAL_CAN_PUSH_OFF_TRIGGERS)==0){
										Game->PlaySound(SFX_PUSHBLOCK_LAND_ON_TRIGGER);
										this->InitD[0]=0;
									}
								}
							}
						}
					}
				}
			}
			if (this->InitD[7]==4){//Set FFC`s InitD to 4 to destroy pushblock.
				Game->PlaySound(SFX_PUSHBLOCK_DESTROY);
				Screen->ComboD[pos] = undercombo;
				Screen->ComboC[pos] = this->InitD[6];
				if (SFX_PUSHBLOCK_DESTROY>0){
					lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(pos), ComboY(pos));
					s->UseSprite(SFX_PUSHBLOCK_DESTROY);
					s->CollDetection=false; 
				}
				ClearFFC(FFCNum(this));
				Quit();
			}
			if (((special&32)>0)&&(Screen->State[ST_SECRET])){
				Screen->ComboD[pos] = undercombo;
				Screen->ComboC[pos] = this->InitD[6];
				ClearFFC(FFCNum(this));
				Quit();
			}
			//Screen->Rectangle(3, this->X, this->Y, this->X+15, this->Y+15, 3, 1, 0, 0, 0, false, OP_OPAQUE);
			//Screen->DrawInteger(3, this->X, this->Y,0, 1,0, -1, -1, FFCNum(this), 0, OP_OPAQUE);
			//debugValue(1, special);
			//debugValue(2, this->InitD[0]);
			Waitframe();
		}
	}
}

int OccupiedByPushblock(int cmb){
	int str[] = "FreeformPushBlock";
	int scr = Game->GetFFCScript(str);
	for (int i=1; i<=32; i++){
		ffc f = Screen->LoadFFC(i);
		if (f->Script!=scr)continue;
		int pos = ComboAt (CenterX (f), CenterY (f));
		if (pos == cmb) return i;
	}
	return 0;
}

bool IceblockCanContinueSlide(ffc f){	
	if (((f->InitD[2])&PUSHBLOCK_SPECIAL_ICEBLOCK)==0) return false;
	if (f->InitD[7]<0) return false;
	//if (f->InitD[7]>0) return false;
	int pos = ComboAt (CenterX (f), CenterY (f));
	int adj = AdjacentComboFix(pos, f->InitD[7]);
	if (ComboFI(adj, CF_BLOCKHOLE)) return true; //Iceblocks will slide over block holes unless obstructed.
	if (ComboFI(adj, CF_NOBLOCKS)) return false;
	if (Screen->ComboS[adj]>0) return false;
	int ff =  OccupiedByPushblock(adj);
	if (ff==0) return true;
	ffc n = Screen->LoadFFC(ff);
	if (!IceblockCanContinueSlide(n)) return false;
	return true;
}

// Returns TRUE, if all onscreen beatable enemies were have been defeated.
bool NoEnemiesLeft (){
	for (int i = 1; i<= Screen->NumNPCs(); i++){
		npc n = Screen->LoadNPC(i);
		if (!(n->isValid())) return true;
		if ((n->MiscFlags&NPCMF_NOT_BEATABLE)==0) return false;
	}
	return true;
}

bool IsOnColoredTergger(ffc f){
	int pos = ComboAt (CenterX (f), CenterY (f));
	int cset = Screen->ComboC[pos];
	if (f->CSet == cset) return true;
	return false;
}

bool CanBePushed(ffc f, int dir, int weight, bool stackpushonly){
	if (!stackpushonly) return false;
	if (((f->InitD[2])&PUSHBLOCK_SPECIAL_ENEMY_WAIT)>0){
		if (!NoEnemiesLeft ()) return false;
	}
	int str[] = "FreeformPushBlock";
	int scr = Game->GetFFCScript(str);
	if ((f->Script)!=scr) return false;
	//Game->PlaySound(SFX_HAMMER);
	if (dir==DIR_UP){
		if (((f->InitD[0])&1)==0) return false;
	}
	if (dir==DIR_DOWN){
		if (((f->InitD[0])&2)==0) return false;
	}
	if (dir==DIR_LEFT){
		if (((f->InitD[0])&4)==0) return false;
	}
	if (dir==DIR_RIGHT){
		if (((f->InitD[0])&8)==0) return false;
	}	
	int power = GetBraceletPower();
	if (power<weight) return false;	
	int cmb=ComboAt (CenterX (f), CenterY (f));
	int adj = AdjacentComboFix(cmb, dir);
	if (adj<0) return false;	
	if (ComboFI(adj, CF_NOBLOCKS)) return false;	
	if (Screen->ComboS[adj]>0){
		if (ComboFI(adj, 91)){
			f->InitD[7]= dir;
			return true;
		}
		//if (((f->InitD[2])&PUSHBLOCK_SPECIAL_ICEBLOCK)>0) return false;
		if ((I_MULTIPUSHBLOCK>0)&&(!Link->Item[I_MULTIPUSHBLOCK])) return false;
		for (int i=1; i<=32; i++){
			ffc next = Screen->LoadFFC(i);
			if ((next->Script) != scr) continue;
			if (next->X != ComboX(adj)) continue;
			if (next->Y != ComboY(adj)) continue;
			if (((next->InitD[2])&PUSHBLOCK_SPECIAL_ICEBLOCK)!= ((f->InitD[2])&PUSHBLOCK_SPECIAL_ICEBLOCK)) return false;
			if (CanBePushed(next, dir, (weight+next->InitD[1]), true)){
				f->InitD[7]= dir;
				return true;
			}
		}
		return false;
	}
	f->InitD[7]= dir;
	return true;
}

// Returns Link`s pushing power
int GetBraceletPower(){
	int result = -1;
	int highestlevel = -1;
	
	for(int i=0; i<=MAX_HIGHEST_LEVEL_ITEM_CHECK; ++i)	{
		itemdata id = Game->LoadItemData(i);
		if(id->Family == IC_BRACELET && Link->Item[i]){
			if(id->Level >= highestlevel){
				highestlevel = id->Level;
				result=i;
			}
		}
	}
	if (result<0)return 0;
	itemdata it = Game->LoadItemData(result);
	return it->Power;
}

//Item script needed to update Link`s pushing power, id you have Freeform Pushblocks and IC_MULTIPUSHBLOCK items on the same screen.
//it`s needed to avoid calling very slow GetHighestLevelItemOwned function every frame just for a single change.
// item script UpdateFreeformBlockPower{
// void run(){
// int str[] = "FreeformPushBlock";
// int scr = Game->GetFFCScript(str);
// for (int i=1; i<=32; i++){
// ffc next = Screen->LoadFFC(i);
// if ((next->Script) != scr) continue;
// next->InitD[5] = this->Power;
// }
// }
// }

//FFC script used to track block triggers.
// Place 1 FFC anywhere on the screen.
// D0 - remove FFC pushblocks when puzzle is solved.
ffc script FreeformPushBlockTriggers{
	void run(int secretremover, int color){
		if (Screen->State[ST_SECRET])Quit();
		int scr_iceblock[] = "FreeformPushBlock";
		int ffcscript_iceblock= Game->GetFFCScript(scr_iceblock);
		ffc blocks[31];
		int triggerx[31];
		int triggery[31];
		int num_push_blocks = 0;
		int num_triggers = 0;
		int good_counter = 0;
		
		for(int i = 0; i < 176 && num_triggers < 31; i++) {
			if(Screen->ComboF[i] == CF_BLOCKTRIGGER || Screen->ComboI[i] == CF_BLOCKTRIGGER) {
				triggerx[num_triggers] = (i % 16) * 16;
				triggery[num_triggers] = Floor(i / 16) * 16;
				num_triggers++;
			}
		}
		if(num_triggers == 0) Quit();
		
		for(int i = 1; i <= 32; i++) {
			ffc temp = Screen->LoadFFC(i);
			if(temp->Script == ffcscript_iceblock) {
				blocks[num_push_blocks] = temp;
				num_push_blocks++;
			}
		}
		if(num_push_blocks == 0) Quit();
		
		while(true) {
			for(int i = 0; i < num_push_blocks; i++) {
				//Check if blocks are on switches and not moving
				for(int j = 0; j < num_triggers; j++) {
					if(blocks[i]->X == triggerx[j] && blocks[i]->Y == triggery[j] && blocks[i]->Vx == 0 && blocks[i]->InitD[7] < 0) {
						if (color==0){
							good_counter++;
							break;
						}
						else{
							int col = blocks[i]->InitD[6];
							int cs = blocks[i]->CSet;
							if (cs==col) good_counter++;
							break;
						}
					}
				}
			}
			if(good_counter == num_triggers) {
				Game->PlaySound(SFX_SECRET);
				if (secretremover>0){
					for (int i=1; i<=32; i++){
						ffc f = Screen->LoadFFC(i);
						if (f->Script==ffcscript_iceblock) ClearFFC(i);
					}
				}
				Screen->TriggerSecrets();
				if((Screen->Flags[SF_SECRETS] & 2) == 0) Screen->State[ST_SECRET] = true;
				Quit();
			}
			
			//debugValue(2, good_counter);
			good_counter = 0;
			Waitframe();
		}
	}
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}

//Remote controlled iceblocks. Stand on control panel, face the chosen direction and press EX1 to send all iceblocks 
//(or other pushblocks) moving.

//Rquires StackPushblocks EX 2.2
//Place FFC at control panel`s position 

ffc script RemoteControlledIceblocks{
	void run(){
		int str[] = "FreeformPushBlock";
		int scr = Game->GetFFCScript(str);
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Link->PressEx1){
					Game->PlaySound(SFX_ICEBLOCK_PUSH);
					for (int i=1; i<=32; i++){
						ffc f = Screen->LoadFFC(i);
						if (f->Script!=scr) continue;
						if (f->InitD[7]>=0) continue;
						bool push = CanBePushed(f, Link->Dir, 0, true);
					}
				}
			}
			Waitframe();
		}
	}
}

//Requires Stack pushblock 2.3+
//Placeable iceblock for painting puzzle.
//Place anywhere in the screen. 
//D0 - ID of combo
//D1 - CSet of combo
//D2 - sound to play on placement
ffc script PlaceableIceblock{
	void run (int icecmb, int icecset, int sound){
		while(true){
			if (Link->PressEx1){
				int pos = ComboAt(CenterLinkX(),CenterLinkY());
				if (Screen->ComboF[pos]==CF_BLOCKTRIGGER){
					Game->PlaySound(sound);
					Screen->ComboD[pos] = icecmb;
					Screen->ComboC[pos] = icecset;
					Screen->ComboF[pos]=CF_FFICEBLOCK;
					int str[] = "AutomaticFreeformPushblockPuzzle";
					int scr = Game->GetFFCScript(str);
					int args[3]={1,0,1};
					ffc f = RunFFCScriptOrQuit(scr, args);
					//Trace(FFCNum(f));
					Quit();
				}
			}
			Waitframe();
		}
	}
}

const int CSET_MATCH_VANISH_UNMATCHABLE=11;//Cset used for unmatсhable blocks that are not needed to be destroyed to trigger secret.
//If two or more pushblocks with the same combo ID and CSet collide, they disappear. Remove all pushblocks to solve the puzzle.
//Place anywhere in the screen. No arguments needed.
ffc script MatchVanishPuzzle{
	void run(){
		Waitframe();
		int scr_iceblock[] = "FreeformPushBlock";
		int scr= Game->GetFFCScript(scr_iceblock);
		bool secret = false;
		bool moving = false;
		while(true){
			moving=false;
			secret=true;
			for (int i=1;i<=32;i++){
				ffc f=Screen->LoadFFC(i);
				if (f->Script!=scr) continue;
				if (f->CSet!= CSET_MATCH_VANISH_UNMATCHABLE)secret=false;
				if (f->InitD[7]>=0){
					moving=true;
					break;
				}
				int cmb = ComboAt(f->X+1, f->Y+1);
				for (int d=0;d<4;d++){
					int adjcmb = AdjacentComboFix(cmb, d);
					if (Screen->ComboD[adjcmb]==Screen->ComboD[cmb] && Screen->ComboC[adjcmb]==Screen->ComboC[cmb]&& f->CSet!= CSET_MATCH_VANISH_UNMATCHABLE) f->InitD[7]=4;
				}
				
			}
			if (moving){
				for (int i=1;i<=32;i++){
					ffc f=Screen->LoadFFC(i);
					if (f->Script!=scr) continue;
					if (f->InitD[7]==4)f->InitD[7]=-1;
				}
			}
			if (secret){
				Game->PlaySound(SFX_SECRET);
				Screen->TriggerSecrets();
				Screen->State[ST_SECRET] = true;
				Quit();
			}
			Waitframe();
		}
	}
}