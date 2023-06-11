const int CSET_FF_LIGHTSOUT_ON = 8; //CSet to render light FFC in ON state
const int CSET_FF_LIGHTSOUT_OFF = 7;//CSet to render light FFC in OFF state

const int CMB_FF_LIGHTSOUT_SOLID = 891;//Solid Combo to place under FFC 

const int SFX_FF_LIGHTSOUT_HIT = 16;//Sound to play on activating FFC

const int SCREEN_D_FF_LIGHTSOUT_COOLDOWN = 0;//Screen D to track cooldown between activationd.

const int FF_LIGHTSOUT_AUTOMATIC_ADJACENT_FFC_SETUP = 1;//>0 - Automatic adjacent FFC setup: each FFC is linked to nearest in all 4 cardinal directions, unless path to it is obsctructed by flag #67, or solid combo.

const int FF_LIGHTSOUT_COOLDOWN_TIME = 15; //Delay between registering sword hits, in frames.

// = FreeForm Lights Out =
// Works just like the oft-cloned puzzle game. Triggering one item triggers the adjacent as well.
//Set up 2 consecutive combos, Off then ON state.
//Place FFCS for each light with combo as OFF state of light. Must be one combo apart or more.
// D0: initial state (1 = on, 0 = off)
// D1-2: adjacent ffc ids (0 to ignore)
// D5: Target light state for puzzle solution.
ffc script FFCLightsOut {
	void run (int state, int adj1, int adj2, int adj3, int adj4, int solved_state) {
		ffc a1; 
		ffc a2; 
		ffc a3; 
		ffc a4;
		this->InitD[6]=ComboAt(CenterX(this), CenterY(this));
		Waitframe();
		if (FF_LIGHTSOUT_AUTOMATIC_ADJACENT_FFC_SETUP>0){
			Waitframe();
			int cmb=this->InitD[6];
			int adjcmb = this->InitD[6];
			while(adjcmb>0){
				adjcmb = AdjacentComboFix(adjcmb, DIR_UP);
				if (adjcmb<0){
					adj1=0;
					break;
				}
				if (ComboFI(adjcmb, CF_NOBLOCKS) || Screen->ComboS[adjcmb]>0){
					adj1=0;
					break;
				}
				for (int i=1;i<=32;i++){
					ffc f = Screen->LoadFFC(i);
					if (f==this)continue;
					if (f->Script!=this->Script) continue;
					if (f->InitD[6]!=adjcmb)continue;
					a1 = f;
					adj1 = i;
					//Trace(i);
					break;
				}
				if (adj1>0)break;
			}
			adjcmb = this->InitD[6];
			while(adjcmb>0){
				adjcmb = AdjacentComboFix(adjcmb, DIR_DOWN);
				if (adjcmb<0){
					adj2=0;
					break;
				}
				if (ComboFI(adjcmb, CF_NOBLOCKS) || Screen->ComboS[adjcmb]>0){
					adj2=0;
					break;
				}
				for (int i=1;i<=32;i++){
					ffc f = Screen->LoadFFC(i);
					if (f==this)continue;
					if (f->Script!=this->Script) continue;
					if (f->InitD[6]!=adjcmb)continue;
					a2 = f;
					adj2= i;
					//Trace(i);
					break;
				}
				if (adj2>0)break;
			}
			adjcmb = this->InitD[6];
			while(adjcmb>0){
				adjcmb = AdjacentComboFix(adjcmb, DIR_LEFT);
				if (adjcmb<0){
					adj3=0;
					break;
				}
				if (ComboFI(adjcmb, CF_NOBLOCKS) || Screen->ComboS[adjcmb]>0){
					adj3=0;
					break;
				}
				for (int i=1;i<=32;i++){
					ffc f = Screen->LoadFFC(i);
					if (f==this)continue;
					if (f->Script!=this->Script) continue;
					if (f->InitD[6]!=adjcmb)continue;
					a3 = f;
					adj3 = i;
					//Trace(i);
					break;
				}
				if (adj3>0)break;
			}
			adjcmb = this->InitD[6];
			while(adjcmb>0){
				adjcmb = AdjacentComboFix(adjcmb, DIR_RIGHT);
				if (adjcmb<0){
					adj4=0;
					break;
				}
				if (ComboFI(adjcmb, CF_NOBLOCKS) || Screen->ComboS[adjcmb]>0){
					adj4=0;
					break;
				}
				for (int i=1;i<=32;i++){
					ffc f = Screen->LoadFFC(i);
					if (f==this)continue;
					if (f->Script!=this->Script) continue;
					if (f->InitD[6]!=adjcmb)continue;
					a4 = f;
					adj4 = i;
					//Trace(i);
				}
				if (adj4>0)break;
			}
			//TraceNL();
		}		
		else{
			if(adj1 > 0) a1 = Screen->LoadFFC(adj1);
			if(adj2 > 0) a2 = Screen->LoadFFC(adj2);
			if(adj3 > 0) a3 = Screen->LoadFFC(adj3);
			if(adj4 > 0) a4 = Screen->LoadFFC(adj4);
		}		
		int origdata = this->Data;
		Waitframe();
		int c = this->InitD[6];
		if (CMB_FF_LIGHTSOUT_SOLID>0)Screen->ComboD[c]=CMB_FF_LIGHTSOUT_SOLID;
		this->InitD[6]=0;
		this->InitD[7]=state;
		bool cooldown=false;		
		if (Screen->State[ST_SECRET]) {
			this->InitD[7] = solved_state;
			if (this->InitD[7]==1){
				this->Data=origdata+1;
				this->CSet = CSET_FF_LIGHTSOUT_ON;
			}
			else{
				this->Data = origdata;
				this->CSet = CSET_FF_LIGHTSOUT_OFF;
			}
			Quit();
		}		
		while (true) {			
			if (Screen->D[SCREEN_D_FF_LIGHTSOUT_COOLDOWN] == 0) {
				for (int i=1; i<=Screen->NumLWeapons(); i++) {
					lweapon wpn = Screen->LoadLWeapon(i);
					if (wpn->ID == LW_SWORD) {
						if ( Distance(wpn->X, wpn->Y, this->X, this->Y) < 12 ) {
							Game->PlaySound(SFX_FF_LIGHTSOUT_HIT);
							this->InitD[6] = 1;
							if(adj1 > 0) a1->InitD[6] = 1;
							if(adj2 > 0) a2->InitD[6] = 1;
							if(adj3 > 0) a3->InitD[6] = 1;
							if(adj4 > 0) a4->InitD[6] = 1;
							Screen->D[SCREEN_D_FF_LIGHTSOUT_COOLDOWN] = FF_LIGHTSOUT_COOLDOWN_TIME;
							cooldown=true;
						}
					}
				}
			}
			else{
				if (cooldown) Screen->D[SCREEN_D_FF_LIGHTSOUT_COOLDOWN]--;
				if (Screen->D[SCREEN_D_FF_LIGHTSOUT_COOLDOWN]==0){
					FFLightsoutTriggerUpdate(this);
					cooldown=false;
				}
			}
			if (this->InitD[6] == 1) {
				this->InitD[6] = 0;
				if (this->InitD[7]==0)	this->InitD[7]=1;
				else this->InitD[7] = 0;				
			}
			
			if (this->InitD[7]==1){
				this->Data=origdata+1;
				this->CSet = CSET_FF_LIGHTSOUT_ON;
			}
			else{
				this->Data = origdata;
				this->CSet = CSET_FF_LIGHTSOUT_OFF;
			}
			Waitframe();
			
		}
	}
}

//Checks triggers and trigger secrets if all color cubes moved onto correct positions with correct facing
void FFLightsoutTriggerUpdate(ffc this){
	for (int i=1;i<=33;i++){
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] =true;
			Quit();
		}
		else {
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=this->Script) continue;
			if (f->InitD[7]!=f->InitD[5])break;
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