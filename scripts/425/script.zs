const int FALSE_PUSHBLOCK_SPECIAL_ENEMY_WAIT = 1;//Enamy wait flag

const int FALSE_PUSHBLOCK_WARNING_CSET = 8;//CSet used for false pushblock flashing before exploding.

const int SFX_FALSE_PUSHBLOCK_PRIMED = 0;//Sound to play when boobytrapped pushblock is primed.

//False Push Block
//A block that looks like regular pushblock. But on attempt to push it like other pushblocks it starts blinking and then explodes,
//potentially causing damage to Link.
//
//Place invisible FFC with script at trap`s location.
// D0 - allowed directions. Add together: 1 - up, 2 - down, 4 - left, 8 - right
// D1 - Weight, bracelet power needed to push/set off this trap.
// D2 - Damage from explosion, in 1/4ths of heart
// D3 - Set to 1 - no activation until all enemies onscreen are killed.
// D4 - Fuse time, in frames, defaults to 60.

ffc script FalsePushBlock{
	void run (int dirs, int weight, int damage, int flags, int warntime){
		this->X = GridX(this->X);
		this->Y = GridY(this->Y);
		if (warntime==0) warntime=60;
		int cmb = ComboAt(CenterX(this), CenterY(this));
		int origcset = Screen->ComboC[cmb];
		int framecounter=0;
		bool primed = false;
		while(true){
			if (!primed){
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
					if (FalseBlockCanBePushed(this, Link->Dir, weight)){
						Game->PlaySound(SFX_FALSE_PUSHBLOCK_PRIMED);
						framecounter=warntime;
						primed = true;
					}
				}
			}
			else {
				if ((framecounter%10) ==0){
					if (Screen->ComboC[cmb]==origcset) Screen->ComboC[cmb] = FALSE_PUSHBLOCK_WARNING_CSET;
					else Screen->ComboC[cmb] = origcset;
				}
				framecounter--;
				if (framecounter<=0){
					eweapon e;
					if (damage<0) e = CreateEWeaponAt(EW_SBOMBBLAST, this->X, this->Y);
					else e = CreateEWeaponAt(EW_BOMBBLAST, this->X, this->Y);
					e->Damage = Abs(damage);
					Screen->ComboD[cmb] = Screen->UnderCombo;
					Screen->ComboC[cmb] = Screen->UnderCSet;
					ClearFFC(FFCNum(this));
					Quit();
				}				
			}
			Waitframe();
		}
	}
}

bool FalseBlockCanBePushed(ffc f, int dir, int weight){
	if (((f->InitD[3])&FALSE_PUSHBLOCK_SPECIAL_ENEMY_WAIT)>0){
		if (!NoEnemiesLeft ()) return false;
	}
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
	int power = 0;
	int itm = GetCurrentItem(IC_BRACELET);
	if (itm>0){
		itemdata it = Game->LoadItemData(itm);
		power = it->Power;
	}
	if (power<weight) return false;	
	int cmb=ComboAt (CenterX (f), CenterY (f));
	int adj = AdjacentComboFix(cmb, dir);
	if (adj<0) return false;	
	if (ComboFI(adj, CF_NOBLOCKS))return false;	
	//if (Screen->ComboS[adj]>0) return false;
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