const int STATUE_PUZZLE_INVISIBLE_COMBO = 2487; //Solid Combo used to mimic solidity.

const int STATUE_PUZZLE_MOVE = 50; //Sound to play, when puzzle statue moves.
const int STATUE_PUZZLE_TURN = 16; //Sound to play, when puzzle statue rotates.

const int CMB_STATUE_PUZZLE_SHADOW=910;//Combo used to render shadow beheath jumping statue. 0 for no jumping
const int CSET_STATUE_PUZZLE_SHADOW=7;//CSet used to render shadow beheath jumping statue. 0 for no jumping

//Statue puzzle from Zelda: Twilight Princess. Stand on remote controller, then press Ex2 to rotate all statues anti-clockwise, or press Ex1
//to move each statue one combo in direction they facing, unless obstructed. Beware of collisions! Land all statues on trigger spaces simultaneously to solve the puzzle.

//1. Surround puzzle area with NoPushblocks flags.
//2. Place flags 62 - 65 (Pushblock, one direction, many) to define starting position and orientation of statues.
//3. Flag trigger spaces with flag 66 (Block trigger).
//4. Set up 4 combos in sequence for statues Up-Down-Left-Right
//5. Place FFC with TP_StatuePuzzle script
//D0 - ID of 1st statue combo (statue facing upwards)
//D1 - Music to play until puzzle is solved. 0 - Use Screen Midi. Setting this argument to >0 also causes MIDI to stop when puzzle is solved.

ffc script TP_StatuePuzzle{
	void run(int cmb, int music){
		if (Screen->State[ST_SECRET]) Quit();
		if (music>0) Game->PlayMIDI(music);
		int str[] = "TP_PuzzleStatue";
		int scr = Game->GetFFCScript(str);
		for (int i=0; i<176; i++){
			if (Screen->ComboF[i]<62) continue;
			if (Screen->ComboF[i]>65) continue;
			int args[8] = {music,0,0,0,0,0,0, Screen->ComboF[i]-62};
			ffc f = RunFFCScriptOrQuit(scr, args);
			f->X = ComboX(i);
			f->Y = ComboY(i);
			f->CSet = this->CSet;
			f->Data=cmb;
			Screen->ComboF[i]=0;
		}
		int animcounter=0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (animcounter==0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if (Link->PressEx2){
						Game->PlaySound(STATUE_PUZZLE_TURN);
						for (int i = 1; i<=32; i++){
							ffc f = Screen->LoadFFC(i);
							if (f->InitD[6]>0) continue;
							f->InitD[7]=RotDir(f->InitD[7], -2);
						}
					}
					if(Link->PressEx1){
						for (int i = 1; i<=32; i++){
							ffc f = Screen->LoadFFC(i);
							f->InitD[6]=1;
						}
						animcounter=16;
					}
				}
			}
			else{
				animcounter--;
			}
			Waitframe();
		}
	}
}

ffc script TP_PuzzleStatue{
	void run(int music){
		int origcmb = this->Data;
		int curcmb = this->Data;
		int cmb = ComboAt(this->X, this->Y);
		int ucmb = Screen->ComboD[cmb];
		int ucset = Screen->ComboC[cmb];
		Screen->ComboD[cmb] = STATUE_PUZZLE_INVISIBLE_COMBO;
		int animcounter=0;
		int adjcmb = -1;
		int jumpz=0;
		while(true){
			if (animcounter==0){
				if (this->InitD[6]>0){
					bool solid = false;
					adjcmb = AdjacentComboFix(cmb, this->InitD[7]);
					if (Screen->ComboS[adjcmb]>0) solid = true;
					if (ComboFI(adjcmb, CF_NOBLOCKS))solid =true;			
					if (!solid){
						Game->PlaySound(STATUE_PUZZLE_MOVE);
						Screen->ComboC[cmb]=ucset;
						Screen->ComboD[cmb]=ucmb;
						this->InitD[5]=0;
						animcounter=16;
					}
					else this->InitD[6]=0;
				}				
			}
			else{
				if (this->InitD[7]==DIR_UP) this->Y--;
				if (this->InitD[7]==DIR_DOWN) this->Y++;
				if (this->InitD[7]==DIR_LEFT) this->X--;
				if (this->InitD[7]==DIR_RIGHT) this->X++;
				if (StatueCollision(this)){
					lweapon l = CreateLWeaponAt(LW_BOMBBLAST, this->X, this->Y);
					l->CollDetection=false;
					Waitframe();
					this->Data=0;
					Quit();
				}
				if (animcounter>12) jumpz+=2;
				else if (animcounter>8) jumpz+=1;
				else if (animcounter>4) jumpz-=1;
				else jumpz-=2;
				animcounter--;
				if (animcounter==0){
					cmb=adjcmb;
					this->InitD[6]=0;
					ucmb = Screen->ComboD[cmb];
					ucset = Screen->ComboC[cmb];
					Screen->ComboD[cmb] = STATUE_PUZZLE_INVISIBLE_COMBO;
					if (ComboFI(cmb, CF_BLOCKTRIGGER))this->InitD[5]=1;
					for(int i=1;i<=33;i++){
						if (i==33){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							if (music>0)Game->PlayMIDI(0);
							break;
						}
						ffc f = Screen->LoadFFC(i);
						if (f->Script!=this->Script)continue;
						if (f->InitD[5]==0)break;
					}
				}
			}
			curcmb = origcmb+this->InitD[7];
			if ((CMB_STATUE_PUZZLE_SHADOW>0) && (animcounter>0)){
				this->Data=FFCS_INVISIBLE_COMBO;
				Screen->FastCombo(Cond(animcounter>0, 4,1), this->X, this->Y-jumpz, curcmb, this->CSet, OP_OPAQUE);
				Screen->FastCombo(1, this->X, this->Y,CMB_STATUE_PUZZLE_SHADOW, CSET_STATUE_PUZZLE_SHADOW, OP_TRANS);
			}
			else this->Data=curcmb;
			Waitframe();
		}
	}
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir){
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

//Rotated the given direction num times clockwise in 8-way rose wind
//Use negative values for anti-clockwise direction.
int RotDir(int dir, int num){
	int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
	int idx=-1;
	for (int i=0; i<8; i++){
		if (dirs[i] == dir){
			idx=i;
			break;
		}
	}
	if (idx<0) return -1;
	idx+=num;
	while (idx<0) idx+=8;
	while (idx>=8) idx-=8;
	return dirs[idx];
}



bool StatueCollision(ffc f){
	for(int i=1;i<=32;i++){
		ffc n = Screen->LoadFFC(i);
		if (f==n)continue;
		if (n->Script!=f->Script)continue;
		if (RectCollision(f->X, f->Y, f->X + 15, f->Y +15, n->X, n->Y, n->X +15, n->Y +15)) return true;
	}
	return false;
}