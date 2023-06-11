const int SFX_NESTEDBOX_MOVE = 16;//Sound to play on each move;

//Nested box puzzle from Machinarium. You have a grid containing some boxes, which have 2 different sizes and 1 open side. 
//You control a marker that can move, enter/exit boxes and push them while inside them.
//1 small and 1 large box have different colors. Insert small such box into large such box to solve puzzle.
//Stand on FFC, face the given direction and press EX1 to move the marker.

//Set up 16 box combos. Rows - small, large, small trigger, large trigger. Columns - open in up/down/left/right directions.
//Set up 2 more combos. 1 for marker, 1 for empty space.
//Buile the puzzle. Only 1 small trigger box, 1 large trigger box and 1 marker combo must exist in the screen.
//You can use solid combos and No push block flags as obstacles and puzzle boundaries.
//Place invisible FFC with script at control panel.
//D0 - ID of Combo used for marker.
//D1 - ID of top left combo in box setup.
//D2 - ID of empty space.
//All combos in the puzzle are removed at the start. Graphics at runtime are rendered entirely by script.

ffc script NestedBoxPuzzle{
	void run(int startpos, int origcmb, int ucmb){
		int curpos=-1;
		int box2[176];
		int box1[176];
		int sol1 = -1;
		int sol2 = -1;
		int dir=-1;
		int animcounter=0;
		int animbox2=-1;
		int animbox1=-1;
		int drawx=-1;
		int drawy=-1;
		for (int i=0; i<176;i++){
			if ((curpos<0) && (Screen->ComboD[i]==startpos)) curpos=i; 
			if (Screen->ComboD[i]<origcmb){
				box1[i]=-1;
				box2[i]=-1;
			}
			else if (Screen->ComboD[i]>(origcmb+15)){
				box1[i]=-1;
				box2[i]=-1;
			}
			else {
				int state = Screen->ComboD[i]-origcmb;
				if ((state%8)>3){
					box2[i]=state%4;
					box1[i]=-1;
					if (state>7) sol2=i;
				}
				else{
					box1[i]=state%4;
					box2[i]=-1;
					if (state>7) sol1=i;
				}
				if (box2[i]>=0 || box1[i]>=0 || curpos==i) Screen->ComboD[i]=ucmb;
			}
		}
		int curcmb= Screen->ComboD[curpos];
		int curcset= Screen->ComboC[curpos];
		Screen->ComboD[curpos]=ucmb;
		while(true){
			if (animcounter==0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if (Link->PressEx1){
						if (BoxCanBePushed(curpos, box1, box2, Link->Dir)){
							Game->PlaySound(SFX_NESTEDBOX_MOVE);
							drawx=ComboX(curpos);
							drawy=ComboY(curpos);
							animcounter=16;
							dir=Link->Dir;
							int adjcmb = AdjacentComboFix(curpos, dir);
							if (box1[curpos]>=0 && box1[curpos]!=dir){
								animbox1 = box1[curpos];
								if (sol1==curpos) animbox1+=8;
								if (box2[curpos]>=0 && box2[curpos]!=dir){
									//Game->PlaySound(16);
									animbox2 = box2[curpos]+4;
									if (sol2==curpos) animbox2+=8;
								}
							}
							if (box2[curpos]>=0 && box2[adjcmb]<0 && box2[curpos]!=dir){
								animbox2 = box2[curpos]+4;
								if (sol2==curpos) animbox2+=8;
								if (box1[curpos]>=0){
									//Game->PlaySound(16);
									animbox1 = box1[curpos];
									if (sol1==curpos) animbox1+=8;
								}
							}
							if (animbox1>=0)box1[curpos]=-1;
							if (animbox2>=0)box2[curpos]=-1;
						}
					}
				}
			}
			else{
				if (dir==DIR_UP)drawy--;
				if (dir==DIR_DOWN)drawy++;
				if (dir==DIR_LEFT)drawx--;
				if (dir==DIR_RIGHT)drawx++;
				animcounter--;
				if (animcounter==0){
					int adjcmb = AdjacentComboFix(curpos, dir);
					if (animbox1>=0){
						box1[adjcmb]=animbox1%4;
						if (sol1==curpos) sol1=adjcmb;
						animbox1=-1;
					}
					if (animbox2>=0){
						box2[adjcmb]=animbox2%4;
						if (sol2==curpos) sol2=adjcmb;
						animbox2=-1;
					}
					curpos=adjcmb;
					drawx=-1;
					drawy=-1;
					if (sol1==sol2 && !Screen->State[ST_SECRET]){
						Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
					}
				}
			}
			for (int i=0;i<176;i++){
				int offset=0;
				if (box1[i]>=0) {
					offset+= box1[i];
					if (sol1==i) offset+=8;
					Screen->FastCombo(2, ComboX(i), ComboY(i), origcmb+offset, 2, OP_OPAQUE);
				}
				offset=0;
				if (box2[i]>=0){
					offset+= box2[i]+4;
					if (sol2==i) offset+=8;
					Screen->FastCombo(2, ComboX(i), ComboY(i), origcmb+offset, 2, OP_OPAQUE);
				}
				
			}
			if (animcounter==0)Screen->FastCombo(2, ComboX(curpos), ComboY(curpos), curcmb, curcset, OP_OPAQUE);
			else{
				Screen->FastCombo(2, drawx, drawy, curcmb, curcset, OP_OPAQUE);
				if (animbox1>=0) Screen->FastCombo(2, drawx, drawy, origcmb+animbox1, curcset, OP_OPAQUE);
				if (animbox2>=0) Screen->FastCombo(2, drawx, drawy, origcmb+animbox2, curcset, OP_OPAQUE);
			}
			//debugValue(1,box1[curpos]);
			//debugValue(2,box2[curpos]);
			//debugValue(3,curpos);
			Waitframe();
		}
	}
}

bool BoxCanBePushed(int pos, int box1, int box2, int dir){
	int adjcmb = AdjacentComboFix(pos, dir);
	if (Screen->ComboS[adjcmb]>0) return false;
	if (ComboFI(adjcmb, CF_NOBLOCKS)) return false;
	if (box1[adjcmb]>=0){
		if (dir!=OppositeDir(box1[adjcmb])) return false;
		if (box1[pos]>=0 && box1[pos]!=dir) return false;
		if (box2[pos]>=0 && box2[pos]!=dir) return false;
	}
	if (box2[adjcmb]>=0){
		if (dir!=OppositeDir(box2[adjcmb])) return false;
		if (box2[pos]>=0 && box2[pos]!=dir) return false;
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