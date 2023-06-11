const int SFX_LINEDOKU_PLACE = 16;//Sound to play when placing square
const int SFX_LINEDOKU_ERASE = 32;//Sound to play when erasing drawing

//Linedoku puzzle
//You have a grid of squares, some of them contain colored blocks with numbers on them. Your goal is to unfold the blocks into cross shaped areas centered around the block. No two unfolds should overlap. Total area of shape, not including central block, is equal to number written on block. Crosses are not necessary to extend in all directions. The area of grid fits unfolds with no empty spaces left.

//1. Setup 12 consecutive non-solid blocks for each color: first number blocks starting from 9 and ending at 0, then unfolded space, then selection cursor.
//2. Place FFC with script, combo deplicting "0" block and D0 for target number. Do that for each block. Make sure that each FFC uses separate combo set.
//3. Surround puzzle area with flag #67 (No PushBlocks).
ffc script Linedoku{
	void run(int num){
		int origdata = this->Data;
		this->InitD[7]=num;
		int origpos = ComboAt(CenterX(this), CenterY(this));
		int cmb = -1;
		this->InitD[6] = -1;
		int dir=-1;
		Screen->ComboF[origpos]=CF_NOBLOCKS;
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (this->InitD[6]<0){
				if (cmb==origpos && Link->PressEx1){
					if (this->InitD[7]>0){
						for (int i=1;i<=32;i++){
							ffc f = Screen->LoadFFC(i);
							if (f->Script!=this->Script)continue;
							f->InitD[6]=-1;
						}
						this->InitD[6]=origpos;						
					}
					else{
						Game->PlaySound(SFX_LINEDOKU_ERASE);
						for (int i=0; i<176; i++){
							if (Screen->ComboD[i]==origdata+1){
								Screen->ComboD[i]=Screen->UnderCombo;
								Screen->ComboC[i]=Screen->UnderCSet;
								Screen->ComboF[i]=0;
							}
						}
						this->InitD[7]=num;
					}
				}
				if (Link->PressEx1 && Screen->ComboD[cmb]==origdata+1){
					Game->PlaySound(SFX_LINEDOKU_ERASE);
					for (int i=0; i<176; i++){
						if (Screen->ComboD[i]==origdata+1){
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
							Screen->ComboF[i]=0;
						}
					}
					this->InitD[7]=num;
				}
			}
			else{
				if (((!ComboFI(cmb,CF_NOBLOCKS)&&Screen->ComboS[cmb]==0)|| Screen->ComboD[cmb]==origdata+1) && this->InitD[7]>0){
					int adjdir =  AdjacentComboDir(this->InitD[6], cmb);
					if (adjdir>=0 &&(dir<0 || adjdir==dir)){
						if (Screen->ComboD[cmb]!=origdata+1){
							Game->PlaySound(SFX_LINEDOKU_PLACE);
							Screen->ComboD[cmb]=origdata+1;
							Screen->ComboC[cmb]=this->CSet;
							Screen->ComboF[cmb]=CF_NOBLOCKS;
							this->InitD[7]--;
							LinedokuTriggerUpdate(this);
						}
						dir=adjdir;	
						this->InitD[6]=cmb;
					}
				}
				if (Link->PressEx1){
					this->InitD[6]=-1;
					dir=-1;
				}
			}
			if (this->InitD[6]>=0)Screen->FastCombo(2, ComboX(this->InitD[6]), ComboY(this->InitD[6]), origdata+2, this->CSet, OP_OPAQUE);
			this->Data = origdata-this->InitD[7];
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

//Defines adjacency direction for given combos, or -1, if combos are not adjacent.
int AdjacentComboDir(int cmb1, int cmb2){
	for (int i=0;i<4;i++){
		if (AdjacentComboFix(cmb1, i)==cmb2) return i;
	}
	return -1;
}	

//Checks triggers and trigger secrets if all color cubes moved onto correct positions with correct facing
void LinedokuTriggerUpdate(ffc this){
	for (int i=1;i<=33;i++){
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] =true;
			return;
		}
		else {
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=this->Script) continue;
			if (f->InitD[7]>0)break;
		}
	}
}