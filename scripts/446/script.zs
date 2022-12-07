const int CF_SLIDERPUZZLE_BUMPER = 67;//Combo flag used for boundaries.
const int CF_SLIDERPUZZLE_TRIGGER = 66;//Combo flag used for triggers.

const int SFX_SLIDERPUZZLE_START = 21;//Sound to play, when slider starts moving
const int SFX_SLIDERPUZZLE_STOP = 16;//Sound to play, when slider stops moving

//Bouncing sliders puzzle. Stand on control panel, face the given direction, and press EX1, to send all sliders moving. 
//Each slider moves certain amount of combos. If hits obstacle, it reverses direction. Land all sliders on triggers simultaneously to solve.

//SlideBounceController
//
//Effect Width and height are used
//No arguments needed
//
//BouncingSlider
//
//Place and grid-snap at initial position.
//For obstacles, use NoPushblock flags or solid combos.
//For triggers, use BlockTrigger flags.
//D0 - Allowed directions for slider. Add together - 1-Up, 2-Down, 4-Left, 8-Right
//D1 - movement distance per command, in combos.

ffc script SlideBounceController{
	void run (){
		int str[] = "BouncingSlider";
		int scr = Game->GetFFCScript(str);
		bool canmove=true;
		while(true){
			canmove=true;
			for (int i=1;i<=32;i++){
				ffc f = Screen->LoadFFC(i);
				if (f->Script!=scr)continue;
				if (f->InitD[7]>=0){
					canmove=false;
					break;
				}
			}
			if (canmove && Link->PressEx1){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					Game->PlaySound(SFX_SLIDERPUZZLE_START);
					for (int i=1;i<=32;i++){
						ffc f = Screen->LoadFFC(i);
						if (f->Script!=scr)continue;
						f->InitD[7] = Link->Dir;
					}
				}
			}
			Waitframe();
		}
	}
}

ffc script BouncingSlider{
	void run(int dirs, int amount){
		int animcounter=0;
		int counter=0;
		this->InitD[7]=-1;
		while(true){
			if (animcounter==0){
				if (this->InitD[7]>=0){
					if ((dirs&(1<<(this->InitD[7])))>0){
						this->InitD[6]=0;
						animcounter=16;
						counter=amount;
						int cmb = ComboAt(this->X+1, this->Y+1);
						int adjcmb = AdjacentComboFix(cmb, this->InitD[7]);
						if ((Screen->ComboS[adjcmb]>0)||(ComboFI(adjcmb, CF_SLIDERPUZZLE_BUMPER))){
							this->InitD[7] = OppositeDir(this->InitD[7]);
							adjcmb = AdjacentComboFix(cmb, this->InitD[7]);
							if ((Screen->ComboS[adjcmb]>0)||(ComboFI(adjcmb, CF_SLIDERPUZZLE_BUMPER))){
								counter=0;
								animcounter=0;
								this->InitD[7]=-1;
								if (ComboFI(cmb,CF_SLIDERPUZZLE_TRIGGER))this->InitD[6]=1;
							}
						}
					}
					else{
						Game->PlaySound(SFX_SLIDERPUZZLE_STOP);
						this->InitD[7]=-1;
					}
				}
			}
			else{
				if (this->InitD[7]==DIR_UP) this->Y--;
				if (this->InitD[7]==DIR_DOWN) this->Y++;
				if (this->InitD[7]==DIR_LEFT) this->X--;
				if (this->InitD[7]==DIR_RIGHT) this->X++;
				animcounter--;
				if (animcounter==0){
					counter--;
					if (counter>0){
						animcounter=16;						
						int cmb = ComboAt(this->X+1, this->Y+1);
						int adjcmb = AdjacentComboFix(cmb, this->InitD[7]);
						if ((Screen->ComboS[adjcmb]>0)||(ComboFI(adjcmb, CF_SLIDERPUZZLE_BUMPER))) this->InitD[7] = OppositeDir(this->InitD[7]);
					}
					else{
						Game->PlaySound(SFX_SLIDERPUZZLE_STOP);
						int cmb = ComboAt(this->X+1, this->Y+1);
						this->InitD[7]=-1;
						if (ComboFI(cmb,CF_SLIDERPUZZLE_TRIGGER))this->InitD[6]=1;
						for(int i=1;i<=33;i++){
							if (i==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc f = Screen->LoadFFC(i);
							if (f->Script!=this->Script)continue;
							if (SliderCollision(f)) break;
							if (f->InitD[6]==0)break;
						}
					}
				}
			}
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

bool SliderCollision(ffc f){
	for(int i=1;i<=32;i++){
		ffc n = Screen->LoadFFC(i);
		if (f==n)continue;
		if (n->Script!=f->Script)continue;
		if (RectCollision(f->X, f->Y, f->X + 15, f->Y +15, n->X, n->Y, n->X +15, n->Y +15))return true;
	}
	return false;
}