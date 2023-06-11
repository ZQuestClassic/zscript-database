const int SFX_DEFUSE_LIT = 35;//Sound to play, when bomb fuse is lit.
const int SFX_DEFUSE_NUKE = 37;//Sound to play on full-screen nuke-like flash.
const int SFX_DEFUSE_HIT = 16;//Sound to play on defusing bomb.

const int C_DEFUSE_NUKEFLASH = 1;//Color of full-screen flash used by nuke.

const int FONT_DEFUSE_HUD = 0;//Font used to render game info;

//Bomb defusal challenge.
//No, it`s not typical "solve the puzzle withinh time limit" one :-)
//You have bombs with fuses. After some randomized time, one bomb, chosen at random lights it`s fuse, and Link must step on it before everything blows up. After succeful defusing, cycle repeats. Defuse bomb/s deveral times to win.

//Set up 4 consecutive combos for bombs - unlit, lit, blown up (crater), then solved.
//Place bombs on screen, using 1st combo from step 1.
//Place FFC, where bomb defusal count info will be rendered. Assign 1st combo from step 1 to it.
//D0 - minimum delay between bomb fuse lighting, in frames.
//D1 - maximum delay between bomb fuse lighting, in frames.
//D2 - fuse time, in frames.
//D3 - damage caused by explosion, in 1/4ths of heart
//D4 - bomb explosion type, 0 - normal, 1- super , 2 - nuke (full screen flash). All bombs explode on challenge failure.
//D5 - number of bomb defusals to win.

ffc script BombDefuse{
	void run (int mindelay, int maxdelay, int fusetime, int dam, int type, int bombcount){
		if (Screen->State[ST_SECRET]){
			for (int i=0;i<176;i++){
				if (Screen->ComboD[i]==this->Data || Screen->ComboD[i]==this->Data+1){
					Screen->ComboD[i]=this->Data+3;
				}
			}
			Quit();
		}
		int bombs[176];
		int numbombs=0;
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]==this->Data){
				bombs[numbombs]=i;
				numbombs++;
			}
		}
		int cmb=-1;
		int count=0;
		int curbomb=-1;
		int timer=mindelay+Rand(maxdelay-mindelay);
		int fuse = -1;
		while(true){
			if (timer>0){
				timer--;
				if (timer==0){
					curbomb = Rand(numbombs);
					curbomb = bombs[curbomb];
					Game->PlaySound(SFX_DEFUSE_LIT);
					Screen->ComboD[curbomb]++;
					fuse = fusetime;
				}
			}
			if (fuse>=0){
				cmb = ComboAt (CenterLinkX(), CenterLinkY());
				if (cmb==curbomb){
					Game->PlaySound(SFX_DEFUSE_HIT);
					Screen->ComboD[curbomb]=this->Data;
					count++;
					if (count>=bombcount){
						Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
						for (int i=0;i<176;i++){
							if (Screen->ComboD[i]==this->Data || Screen->ComboD[i]==this->Data+1){
								Screen->ComboD[i]=this->Data+3;
							}
						}
						Quit();
					}
					else{
						fuse=-1;
						curbomb=-1;
						timer=mindelay+Rand(maxdelay-mindelay);
					}
				}
				else{
					fuse--;
					if (fuse<=0){
						if (type==2){
							eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, dam, 22, SFX_DEFUSE_NUKE, EWF_UNBLOCKABLE);
							e->Dir = Link->Dir;
							e->DrawYOffset = -1000;
							SetEWeaponLifespan(e, EWL_TIMER, 1);
							SetEWeaponDeathEffect(e, EWD_VANISH, 0);
							for (int i=0;i<176;i++){
								if (Screen->ComboD[i]==this->Data || Screen->ComboD[i]==this->Data+1){
									Screen->ComboD[i]=this->Data+2;
								}
							}
							for (int i=1; i<=60;i++){
								if(i % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172, C_DEFUSE_NUKEFLASH, 1, 0, 0, 0, true, 64);
								Waitframe();
							}
						}
						else{
							for (int i=0;i<176;i++){
								if (Screen->ComboD[i]==this->Data || Screen->ComboD[i]==this->Data+1){
									eweapon e = CreateEWeaponAt(Cond(type>0,EW_SBOMBBLAST,EW_BOMBBLAST), ComboX(i), ComboY(i));
									e->Damage=dam;
									Screen->ComboD[i]=this->Data+2;
								}
							}
						}
						Quit();
					}
				}
			}
			Screen->DrawInteger(1, this->X+17, this->Y+1, FONT_DEFUSE_HUD,0,-1, -1, -1, count, 0, OP_OPAQUE);
			int str[]="/";
			Screen->DrawString(1, this->X+33, this->Y+1, FONT_DEFUSE_HUD, 0,-1,  0, str,OP_OPAQUE);
			Screen->DrawInteger(1, this->X+41, this->Y+1, FONT_DEFUSE_HUD,0,-1, -1, -1, bombcount, 0, OP_OPAQUE);
			Screen->DrawInteger(1, this->X+16, this->Y, FONT_DEFUSE_HUD,1,-1, -1, -1, count, 0, OP_OPAQUE);
			Screen->DrawString(1, this->X+32, this->Y, FONT_DEFUSE_HUD, 1,-1,  0, str,OP_OPAQUE);
			Screen->DrawInteger(1, this->X+40, this->Y, FONT_DEFUSE_HUD,1,-1, -1, -1, bombcount, 0, OP_OPAQUE);
			Waitframe();
		}		
	}
}