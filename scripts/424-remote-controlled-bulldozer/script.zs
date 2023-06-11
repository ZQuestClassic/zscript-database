const int BULLDOZER_STATE_WAITING = 0;
const int BULLDOZER_STATE_MOVING = 1;

const int SFX_BULLDOZER_MOVE = 17;//Sound to play when bulldozer is moving. 
const int SFX_BULLDOZER_CRASH = 32;//Sound to play when bulldozer crashes.

const int SPR_BULLDOZER_CRASH = 89;//Sprite to display when bulldozer crashes.

const int CF_BULLDOZER_TRIGGER = 66;//Flag for secret trigger. Bulldoze all flagged combos to trigger secrets. 
const int CF_BULLDOZER_ALWAYS_CRASH = 67;//Flag used to crash bulldozer, when it attempts to run over it. 

const int BULLDOZER_SFX_TIMING = 10;// Counter used for timing ambient running SFX.
const int BULLDOZER_ALLOW_SOLID = 1;// If 0, bulldozer will crash on hitting any solid combo, in addition to  CF_BULLDOZER_ALWAYS_CRASH flags.
const int BULLDOZER_ALLOW_UTURN = 0;// If 0, bulldozer cannot U-turn.

//Magical bulldozer. Stand next to it and press Ex1 to activate it. You can control it by pressing direction buttons. 
//If it runs off course, it crashes. Bulldozed combos are replaced with screen`s undercombo. Bulldoze entire area to open secrets.

//1. Set up 4 consecutive combos for directions up->down->left->right.
//2. Import and compile the script. It requires ffcscript.zh, in addition to default libraries.
//3. Build the puzzle: place CF_BULLDOZER_TRIGGER over all combos that are needed to be bulldozed and CF_BULLDOZER_ALWAYS_CRASH for obstacles.
//   Also you can edit screen`s undercombo to have inherent CF_BULLDOZER_ALWAYS_CRASH flag for Hamiltonian style puzzles ala Link`s Awakening.
//4. Place FFC with 1st combo from step 1 and script assigned at it`s initial position. Grid snap it.
// D0 - Initial direction.
// D1 - Speed. 64 is best. Others may glitch.
// D2 - 0-Prevent secret triggering, just bulldozing stuff.
// D3 - Use FFC`s CSet, instead of screen`s undercset to replace bulldozed combos
// D4 - ID of combo to use as replacement of bulldozed combo, defaults to screen`s undercombo
// D5 - If set to > 0 -> allow Link to terminate bulldozer prematurely by pressing EX1.

ffc script RemoteControlBulldozer{
	void run(int dir, int speed, int trigger, int usecset, int ucmb, int manualcrash){
		this->X = GridX(this->X);
		this->Y = GridY(this->Y);
		int origdata = this->Data;
		this->Data = origdata + dir;
		int state = BULLDOZER_STATE_WAITING;
		bool crash = false;
		int counter = 0;
		if (ucmb==0) ucmb = Screen->UnderCombo;
		int uscet = Screen->UnderCSet;
		if (usecset>0) uscet = this->CSet;
		int cmb = ComboAt(CenterX(this), CenterY(this));
		int nextcmb =  AdjacentComboFix(cmb, dir);
		int newdir = dir;
		while (true){
			if (state==BULLDOZER_STATE_WAITING){
				if (LinkCollision (this) && Link->PressEx1){
					DirSpeedToVel(this, dir, speed);
					Link->PressEx1=false;
					state = BULLDOZER_STATE_MOVING;
					Screen->ComboD[cmb] = ucmb;
					Screen->ComboC[cmb] = uscet;
					if (Screen->ComboF[cmb]== CF_BULLDOZER_TRIGGER ) Screen->ComboF[cmb] = 0;
				}				
			}
			if (state==BULLDOZER_STATE_MOVING){
				if ((counter%BULLDOZER_SFX_TIMING) == 0) Game->PlaySound(SFX_BULLDOZER_MOVE);
				counter++;
				if (counter>=360) counter=0;
				
				if (Link->PressUp && (BULLDOZER_ALLOW_UTURN>0 || dir!= DIR_DOWN)) newdir = DIR_UP;
				if (Link->PressDown && (BULLDOZER_ALLOW_UTURN>0 || dir!= DIR_UP)) newdir = DIR_DOWN;
				if (Link->PressLeft && (BULLDOZER_ALLOW_UTURN>0 || dir!= DIR_RIGHT)) newdir = DIR_LEFT;
				if (Link->PressRight && (BULLDOZER_ALLOW_UTURN>0 || dir!= DIR_LEFT)) newdir = DIR_RIGHT;
				this->Data = origdata + newdir;
				if (Link->PressEx1 && manualcrash>0){
					Game->PlaySound(SFX_BULLDOZER_CRASH);
					Link->PressEx1=false;
					if (SPR_BULLDOZER_CRASH>0){
						lweapon l = CreateLWeaponAt(LW_SPARKLE, this->X, this->Y);
						l->UseSprite(SPR_BULLDOZER_CRASH);
						l->DeadState = Max(l->ASpeed*l->NumFrames-1, 1);
						l->CollDetection=false;
					}
					if (trigger>0){
						for (int i = 0; i<=176; i++){
							if (i==176){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET] = true;
							}
							else if (ComboFI(i, CF_BULLDOZER_TRIGGER))break;
						}
					}
					Link->CollDetection=true;
					this->Data = FFCS_INVISIBLE_COMBO;
					ClearFFC(FFCNum(this));
					Quit();
				}
				if (((this->X % 16)==0)&&(this->Y %16)==0){
					Screen->ComboD[cmb] = ucmb;
					Screen->ComboC[cmb] = uscet;
					if (Screen->ComboF[cmb]== CF_BULLDOZER_TRIGGER ) Screen->ComboF[cmb] = 0;
					nextcmb =  AdjacentComboFix(cmb, newdir);
					if (ComboFI(nextcmb, CF_BULLDOZER_ALWAYS_CRASH)) crash = true;
					if ((Screen->ComboS[nextcmb]>0)&&(BULLDOZER_ALLOW_SOLID==0)) crash = true;
					if (crash){
						Game->PlaySound(SFX_BULLDOZER_CRASH);
						if (SPR_BULLDOZER_CRASH>0){
							lweapon l = CreateLWeaponAt(LW_SPARKLE, this->X, this->Y);
							l->UseSprite(SPR_BULLDOZER_CRASH);
							l->DeadState = Max(l->ASpeed*l->NumFrames-1, 1);
							l->CollDetection=false;
						}
						if (trigger>0){
							for (int i = 0; i<=176; i++){
								if (i==176){
									Game->PlaySound(SFX_SECRET);
									Screen->TriggerSecrets();
									Screen->State[ST_SECRET] = true;
								}
								else if (ComboFI(i, CF_BULLDOZER_TRIGGER))break;
							}
						}
						Link->CollDetection=true;
						this->Data = FFCS_INVISIBLE_COMBO;
						ClearFFC(FFCNum(this));
						Quit();
					}
					else{
						cmb = nextcmb;
						dir=newdir;
						DirSpeedToVel(this, dir, speed);
					}					
				}
				
				NoAction();
				Link->CollDetection=false;
			}			
			Waitframe();
		}
	}
}

void DirSpeedToVel(ffc f, int dir, int speed){
	f->Vx=0;
	f->Vy=0;
	if (dir==DIR_UP) f->Vy= -speed/100;
	if (dir==DIR_DOWN) f->Vy= speed/100;
	if (dir==DIR_LEFT) f->Vx= - speed/100;
	if (dir==DIR_RIGHT) f->Vx= speed/100;
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