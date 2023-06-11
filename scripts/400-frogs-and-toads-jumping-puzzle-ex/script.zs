const int SFX_FROGPUZZLE_MOVE = 16; //Sound to play when making move.
const int SFX_FROGPUZZLE_SOLVED = 27;//Sound to play when puzzle is solved. 

const int CMB_FROFPUZZLE_SHADOW = 910;//Shadow combo used for jumping animation.
const int CMB_FROFPUZZLE_TURNLOCK =2237;//Combo used to mark turn-locked pieces.

// 7 spaces in 1 horizontal line. 3 spaces occupied by frogs facing right, 3 by toads facing left and 1 empty space in between
//Toads and frogs can only move forward and jump 1 space forward, if occupied. Stand on piece that can be moved and press Ex1.
// The goal is to swap all toads with frogs and vice versa.
// 1. Set up 3 combos. First, empty space, then frog , then toad.
// 2.Place FFC at leftmost spot of the puzzle.
//  D0 - Empty space combo.

ffc script FrogJumpingPuzzle{
	void run(int cmbfrog){
		int startpos = ComboAt(CenterX(this), CenterY(this));
		int pos[7] = {1,1,1,0,2,2,2};
		int endpos[7] = {2,2,2,0,1,1,1};
		int cmb[7];
		if (Screen->State[ST_SECRET]){
			for (int i=0; i<7; i++){
				Screen->ComboD[startpos+i] = cmbfrog+endpos[i];
			}
			Quit();
		}
		for (int i=0; i<7; i++){
			cmb[i] = startpos+i;
			Screen->ComboD[startpos+i] = cmbfrog+pos[i];
		}
		
		while (true){
			if (RectCollision(ComboX(startpos), ComboY(startpos),ComboX(startpos+7)-1, ComboY(startpos)+15, CenterLinkX(), CenterLinkY(), (CenterLinkX()+1), (CenterLinkY())+1)){
				if (Link->PressEx1){
					int curpos = ComboAt(CenterLinkX(), CenterLinkY());
					int frogpos = curpos-startpos;
					if (pos[frogpos]==1){
						if (frogpos<6){
							if (pos[frogpos+1]==0){
								Game->PlaySound(SFX_FROGPUZZLE_MOVE);
								SwapCombos(curpos, curpos+1);
								pos[frogpos]=0;
								pos[frogpos+1]=1;
								
							}
						}
						if (frogpos<5){
							if ((pos[frogpos+1]>0)&&(pos[frogpos+2]==0)){
								Game->PlaySound(SFX_FROGPUZZLE_MOVE);
								SwapCombos(curpos, curpos+2);
								pos[frogpos]=0;
								pos[frogpos+2]=1;
							}
						}
					}
					if (pos[frogpos]==2){
						if (frogpos>0){
							if (pos[frogpos-1]==0){
								Game->PlaySound(SFX_FROGPUZZLE_MOVE);
								SwapCombos(curpos, curpos-1);
								pos[frogpos]=0;
								pos[frogpos-1]=2;
								
							}
						}
						if (frogpos>1){
							if ((pos[frogpos-1]>0)&&(pos[frogpos-2]==0)){
								Game->PlaySound(SFX_FROGPUZZLE_MOVE);
								SwapCombos(curpos, curpos-2);
								pos[frogpos]=0;
								pos[frogpos-2]=2;
							}
						}
					}
					for (int i=0;i<7;i++){
						if (pos[i]!=endpos[i]) break;
							else if (i==6){								
								Game->PlaySound(SFX_FROGPUZZLE_SOLVED);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								Quit();
							}
					}
				}
			}
			Waitframe();
		} 
	}
	
	void SwapCombos(int pos1, int pos2){
		int cmb1 = Screen->ComboD[pos1];
		int cmb2 = Screen->ComboD[pos2];
		int cset1 = Screen->ComboC[pos1];
		int cset2 = Screen->ComboC[pos2];
		Screen->ComboD[pos1] = cmb2;
		Screen->ComboD[pos2] = cmb1;
		Screen->ComboC[pos1] = cset2;
		Screen->ComboC[pos1] = cset1;
	}
}

// Extended variety of Frogs and Toads puzzle with new features. Pieces can move and jump in any allowed directions.
// Swap frogs and toads to solve.
// 1. Set up 3 combos. First, empty space, then frog , then toad.
// 2.Place FFC anywhere in the screen.
// D0 - Empty space combo.
// D1 - Combo for frog
// D2 - Combo for toad.
// D3 - Add together.
//   1 - Frogs and toads must alternate turns.
//   2 - Frogs and toads slide like on ice after moving/jumping.
//   4 - Allow jumping over same type. Frogs over frogs etc.
// D4 - Allowed directions for frogs. Add together - 1-Up, 2-Down, 4-Left, 8-Right
// D5 - Allowed directions for toads.
// D6 - CSet used for piece selection

ffc script FrogPuzzleEX{
	void run(int cmbspace,int cmbfrog, int cmbtoad, int flags, int frogdir, int toaddir, int selectcset){
		int curpos = -1;
		int newpos = -1;
		int oldfrog = -1;
		int animcounter=0;
		int arrcmb[176];
		int arrsol[176];
		int drawx = this->X;
		int drawy = this->Y;
		int jumpz = 0;
		int dir=-1;
		if (frogdir==0) frogdir=8;
		if (toaddir==0) toaddir=4;
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]==cmbspace){
				arrcmb[i]=0;
				arrsol[i]=0;
			}
			else if (Screen->ComboD[i]==cmbfrog){
				arrcmb[i]=1;
				arrsol[i]=2;
			}
			else if (Screen->ComboD[i]==cmbtoad){
				arrcmb[i]=2;
				arrsol[i]=1;
			}
			else{
				arrcmb[i]=-1;
				arrsol[i]=-1;
			}
		}
		while(true){
			if (animcounter==0){
				if (Link->PressEx1){
					int cmb = ComboAt (CenterLinkX(), CenterLinkY());
					if (arrcmb[cmb]>0 && (((flags&1)==0)||oldfrog!=arrcmb[cmb])){
						if (curpos==-1) curpos=cmb;
						else curpos=-1;
					}
					else if (curpos>=0){
						int ang = Angle(ComboX(curpos), ComboY(curpos), ComboX(cmb), ComboY(cmb));
						dir = AngleDir4(ang);
						if (FrogCanJump(curpos, arrcmb, dir, flags, frogdir, toaddir)){
							Game->PlaySound(SFX_FROGPUZZLE_MOVE);
							animcounter=16;
							oldfrog = arrcmb[curpos];
							arrcmb[curpos]=0;
							this->Data = Screen->ComboD[curpos];
							this->CSet = Screen->ComboC[curpos];
							Screen->ComboD[curpos]=cmbspace;
							newpos=cmb;
						}
					}
				}
			}
			if (animcounter>0){
				drawx = Lerp((ComboX(curpos)),ComboX(newpos), (1-animcounter/16));
				drawy = Lerp((ComboY(curpos)),ComboY(newpos), (1-animcounter/16));
				if (animcounter>12) jumpz+=2;
				else if (animcounter>8) jumpz+=1;
				else if (animcounter>4) jumpz-=1;
				else jumpz-=2;
				animcounter--;
				if (animcounter==0){
					if (((flags&2)>0)&&(IceFrogCanContinueJump(newpos, arrcmb, dir))){
						animcounter=16;
						curpos=newpos;
						newpos = AdjacentComboFix(newpos, dir);
					}
					else{
						arrcmb[newpos]=oldfrog;
						curpos=-1;
						Screen->ComboD[newpos]=this->Data;
						this->InitD[7]=0;
						for (int i=0;i<=176;i++){
							if (i==176){
								this->InitD[7]=1;
								break;
							}
							if (arrcmb[i]!=arrsol[i]) break;
						}
						for(int i=1;i<=33;i++){
							if (i==33){
								Game->PlaySound(SFX_FROGPUZZLE_SOLVED);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc f = Screen->LoadFFC(i);
							if (f->Script!=this->Script)continue;
							if (f->InitD[7]==0)break;
						}
					}
				}
			}
			if ((CMB_FROFPUZZLE_SHADOW>0) && (animcounter>0))Screen->FastCombo(1, drawx, drawy,CMB_FROFPUZZLE_SHADOW, 7, OP_TRANS);
			if (animcounter>0)Screen->FastCombo(Cond(animcounter>0, 4,1), drawx, drawy-jumpz, this->Data, this->CSet, OP_OPAQUE);
			if (curpos>0 && animcounter==0)Screen->FastCombo(1, ComboX(curpos), ComboY(curpos),Screen->ComboD[curpos], selectcset, OP_OPAQUE);
			if (((flags&1) >0)&& oldfrog>0 ){
				for (int i=0;i<176;i++){
					if(CMB_FROFPUZZLE_TURNLOCK==0)break;
					if (oldfrog==arrcmb[i])Screen->FastCombo(1, ComboX(i), ComboY(i),CMB_FROFPUZZLE_TURNLOCK, 11, OP_TRANS);
				}
			}
			//debugValue(1, curpos);
			Waitframe();
		}
	}
}

bool FrogCanJump(int cmb, int arrcmb, int dir, int flags, int frogdir, int toaddir){
	int dirs=0;
	if (arrcmb[cmb]==1)dirs = frogdir;
	if (arrcmb[cmb]==2)dirs = toaddir;
	if (dir==DIR_UP){
		if ((dirs&1)==0) return false;
	}
	if (dir==DIR_DOWN){
		if ((dirs&2)==0) return false;
	}
	if (dir==DIR_LEFT){
		if ((dirs&4)==0) return false;
	}
	if (dir==DIR_RIGHT){
		if ((dirs&8)==0) return false;
	}
	int linkcmb = ComboAt (CenterLinkX(), CenterLinkY());
	int adjcmb = AdjacentComboFix(cmb, dir);
	if (adjcmb<0) return false;
	if (arrcmb[adjcmb]==0)return linkcmb==adjcmb;
	if (arrcmb[adjcmb]>0){
		if (arrcmb[cmb]==arrcmb[adjcmb]){
			if ((flags&4)==0)return false;
		}
		adjcmb = AdjacentComboFix(adjcmb, dir);
		if (arrcmb[adjcmb]==0) return linkcmb==adjcmb;
	}
	//Game->PlaySound(3);
	return false;
}

bool IceFrogCanContinueJump(int cmb,int arrcmb , int dir){
	int adjcmb = AdjacentComboFix(cmb, dir);
	return arrcmb[adjcmb]==0;
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