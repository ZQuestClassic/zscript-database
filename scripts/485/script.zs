const int CF_SWITCHABLE_OFF = 98;//Combo flag to define switchable combo in off state
const int CF_SWITCHABLE_ON = 99;//Combo flag to define switchable combo in on state

const int SCREEN_D_SWITCH = 0; //ScreenD to check for switch state

const int SFX_SWITCH = 16;//Sound to play on activating sewitch

//Simple 2-state switch

//Place FFC st switch location
//D0 - combo to turn flagged combos in off state
//D1 - combo to turn flagged combos in on state
//D2 - Switch type
// 0 - step -> permanent (until leaving screen)
// 1 - step - on, release - off.
// 2 - Toggle state with EX1.
// 3 - Hold EX1 on switch FFC to keep switch on, otherwise off.
// 4 - step - permanent
// 5 - toggle with EX1 - record into register
//D3 - Switch only combos with came CSet, as FFC.
//D4 - Quake timer on turning on.
//D5 - trap settings - -1 - fire drop, >0 enemy ID spawn
//D6 - if D5>0 - number of enemies to spawn, else - damage caused by fire eweapons.  
//D7 - if (D5<0) - number of fire eweapons to spawn.

//As for switchable FFCs, you can read switch state by passing FFC pointer into SwitchState function that eith returns swiych state (true - on, false - off), or generate error and terminates the script.

ffc script Switch{
	void run (int cmboff, int cmbon, int type, int color, int quake, int trap, int trap2, int trap3){
		int cmb=-1;
		int origcmb = ComboAt (CenterX(this), CenterY(this));
		int origdata = this->Data;
		this->InitD[7]=0;
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (cmb==origcmb){
				if (type==0 || type==1 || type==4){
					if (this->InitD[7]==0){
						Game->PlaySound(SFX_SWITCH);
						if (quake>0)Screen->Quake= quake;
					}
					if (this->InitD[7]==0){
						if (trap>0){
							for (int i=1;i<=trap2*16;i++){
								if ((i%16)==0){
									Game->PlaySound(SFX_FALL);
									npc n= SpawnNPC(trap);
									n->Z=128;
								}
								cmb = ComboAt (CenterLinkX(), CenterLinkY());
								if (cmb==origcmb)this->InitD[7]=1;
								if (type==4)SetScreenDBit(SCREEN_D_SWITCH, this->CSet, this->InitD[7]>0);
								if ((type==1 || type==3) && Screen->ComboS[origcmb]==0 && cmb!=origcmb) this->InitD[7]=0;
								if (type==4||type==5)this->InitD[7]=Cond(GetScreenDBit(SCREEN_D_SWITCH, this->CSet), 1,0);
								if (this->InitD[7]==1){
									this->Data=origdata+1;
									for (int i=0;i<176;i++){
										if (ComboFI(i, CF_SWITCHABLE_OFF) && (color==0 ||Screen->ComboC[i]==this->CSet)){
											Screen->ComboD[i]=cmbon;
											Screen->ComboF[i]=CF_SWITCHABLE_ON;
										}
									}
								}
								else{
									this->Data=origdata;
									for (int i=0;i<176;i++){
										if (ComboFI(i, CF_SWITCHABLE_ON)&& (color==0 ||Screen->ComboC[i]==this->CSet)){
											Screen->ComboD[i]=cmboff;
											Screen->ComboF[i]=CF_SWITCHABLE_OFF;
										}
									}
								}
								Waitframe();
							}
						}
						if (trap<0){
							for (int i=1;i<=trap3*16;i++){
								if ((i%16)==0){
									Game->PlaySound(SFX_FIRE);
									int fcmb = FindSpawnPoint(true, false, false, false);
									eweapon fire = CreateEWeaponAt(EW_FIRE, ComboX(fcmb), ComboY(fcmb));
									fire->Damage = trap2;
									fire->Z=128;
								}
								cmb = ComboAt (CenterLinkX(), CenterLinkY());
								if (cmb==origcmb)this->InitD[7]=1;
								if (type==4)SetScreenDBit(SCREEN_D_SWITCH, this->CSet, this->InitD[7]>0);
								if ((type==1 || type==3) && Screen->ComboS[origcmb]==0 && cmb!=origcmb) this->InitD[7]=0;
								if (type==4||type==5)this->InitD[7]=Cond(GetScreenDBit(SCREEN_D_SWITCH, this->CSet), 1,0);
								if (this->InitD[7]==1){
									this->Data=origdata+1;
									for (int i=0;i<176;i++){
										if (ComboFI(i, CF_SWITCHABLE_OFF) && (color==0 ||Screen->ComboC[i]==this->CSet)){
											Screen->ComboD[i]=cmbon;
											Screen->ComboF[i]=CF_SWITCHABLE_ON;
										}
									}
								}
								else{
									this->Data=origdata;
									for (int i=0;i<176;i++){
										if (ComboFI(i, CF_SWITCHABLE_ON)&& (color==0 ||Screen->ComboC[i]==this->CSet)){
											Screen->ComboD[i]=cmboff;
											Screen->ComboF[i]=CF_SWITCHABLE_OFF;
										}
									}
								}
								Waitframe();
							}
						}
					}
					if (cmb==origcmb){
						this->InitD[7]=1;
						if (type==4)SetScreenDBit(SCREEN_D_SWITCH, this->CSet, this->InitD[7]>0);
					}
				}
				else if (type==2 || type==5){
					if (Link->PressEx1){
						Game->PlaySound(SFX_SWITCH);
						if (quake>0)Screen->Quake= quake;
						if (this->InitD[7]==1)this->InitD[7]=0;
						else this->InitD[7]=1;
						if (type==5)SetScreenDBit(SCREEN_D_SWITCH, this->CSet, this->InitD[7]>0);
					}
				}
				else if (type==3){
					if (Link->InputEx1){
						if (this->InitD[7]==0){
							Game->PlaySound(SFX_SWITCH);
							if (quake>0)Screen->Quake= quake;
						}
						this->InitD[7]=1;
					}
					else this->InitD[7]=0;
				}
			}
			else{
				if ((type==1 || type==3) && Screen->ComboS[origcmb]==0) this->InitD[7]=0;
			}
			if (Screen->ComboS[origcmb]>0 && this->InitD[7]==0){
				if (quake>0)Screen->Quake= quake;
				Game->PlaySound(SFX_SWITCH);
				this->InitD[7]=1;
				if (type==4||type==5)SetScreenDBit(SCREEN_D_SWITCH, this->CSet, this->InitD[7]>0);
			}
			if (type==4||type==5)this->InitD[7]=Cond(GetScreenDBit(SCREEN_D_SWITCH, this->CSet), 1,0);
			if (this->InitD[7]==1){
				this->Data=origdata+1;
				for (int i=0;i<176;i++){
					if (ComboFI(i, CF_SWITCHABLE_OFF) && (color==0 ||Screen->ComboC[i]==this->CSet)){
						Screen->ComboD[i]=cmbon;
						Screen->ComboF[i]=CF_SWITCHABLE_ON;
					}
				}
			}
			else{
				this->Data=origdata;
				for (int i=0;i<176;i++){
					if (ComboFI(i, CF_SWITCHABLE_ON)&& (color==0 ||Screen->ComboC[i]==this->CSet)){
						Screen->ComboD[i]=cmboff;
						Screen->ComboF[i]=CF_SWITCHABLE_OFF;
					}
				}
			}
			//debugValue(1, Screen->D[SCREEN_D_SWITCH]);
			Waitframe();
		}
	}
}

//Returns True, if the given FFC runs Switch script and his state is ON. If FFC is not a switch FFC, the script terminates with error message in log.
bool SwitchState(ffc f){
	int str[]="Switch";
	int scr = Game->GetFFCScript(str);
	if (f->Script!=scr){
		int err[]="Error: this FFC is not a Switch FFC.";
		TraceS(err);
		Quit();
	}
	return f->InitD[7]==1;
}