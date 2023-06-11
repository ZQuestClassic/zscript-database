const int CMB_SEEDSHOOTERLINKAIM = 7680; //First of 8 directional combos of Link aiming the seed shooter

const int CMB_SEEDSHOOTERSEEDSHOOTER = 7688; //First of 8 directional combos of the seed shooter
const int CS_SEEDSHOOTERSEEDSHOOTER = 8; //CSet of the seed shooter

const int CMB_SEED_EMBERFIRE = 7700; //Combo of the fire drawn over an enemy burning from ember seeds
const int CS_SEED_EMBERFIRE = 8; //Ember seed fire CSet

const int CMB_SEED_GALEWIND = 7701; //Combo of an enemy/Link being carried off by a whirlwind
const int CS_SEED_GALEWIND = 7; //Whirlwind CSet

const int SPR_SEED_EMBER = 88; //Sprite of an ember seed
const int SPR_SEED_SCENT = 89; //Sprite of a scent seed
const int SPR_SEED_PEGASUS = 90; //Sprite of a pegasus seed
const int SPR_SEED_GALE = 91; //Sprite of a gale seed
const int SPR_SEED_MYSTERY = 92; //Sprite of a mystery seed

const int SPR_SEED_EMBER_POOF = 93; //Fire effect when an ember seed breaks. Duration of the animation determines how long the fire hitbox lasts for
const int SPR_SEED_SCENT_POOF = 94; //Sprite of a scent seed impact
const int SPR_SEED_PEGASUS_POOF = 95; //Sprite of a pegasus seed impact
const int SPR_SEED_GALE_POOF = 96; //Sprite of a gale seed whirlwind
const int SPR_SEED_MYSTERY_POOF = 97; //Sprite of a mystery seed impact

const int SPR_PEGASUS_DUST = 98; //Sprite of dust particles kicked up by Link running with pegasus seeds
const int SPR_SCENT_BAIT = 99; //Sprite of a scent seed dropped on the ground as bait

const int CR_SEED_EMBER = 7; //Counter used for ember seeds
const int CR_SEED_SCENT = 8; //Counter used for scent seeds
const int CR_SEED_PEGASUS = 9; //Counter used for pegasus seeds
const int CR_SEED_GALE = 10; //Counter used for gale seeds
const int CR_SEED_MYSTERY = 11; //Counter used for mystery seeds

const int LW_SEED = 40; //Weapon type for seeds (LW_SCRIPT10 by default)
const int LW_SEED_MYSTERY = 31; //Weapon type for mystery seeds (LW_SCRIPT1 by default)
const int LW_SEED_SCENT = 8; //Weapon type for scent seeds (LW_ARROW by default)

const int DAMAGE_SEED_EMBER = 2; //Damage the fire left by an ember seed deals
const int DAMAGE_SEED_SCENT = 2; //Damage a scent seed deals
const int DAMAGE_SEED_MYSTERY_LOW = 1; //Low end damage a mystery seed deals
const int DAMAGE_SEED_MYSTERY_HIGH = 6; //High end damage a mystery seed deals

const int SFX_SEEDSHOOTER = 65; //SFX when a seed of any type is fire by the seed shooter
const int SFX_SEED_EMBER = 66; //SFX an ember seed makes on impact
const int SFX_SEED_SCENT = 67; //SFX a scent seed makes on impact
const int SFX_SEED_PEGASUS = 66; //SFX a pegasus seed makes on impact
const int SFX_SEED_GALE = 68; //SFX a gale seed makes on impact
const int SFX_SEED_MYSTERY = 69; //SFX a mystery seed makes on impact

const int SFX_SCENT_BAIT = 72; //SFX a scent seed makes when used as bait
const int SFX_GALE_CEILINGBUMP = 72; //SFX when Link hits the ceiling after using a gale seed

const int SFX_PEGASUS_RUN = 70; //Looping SFX when speed boosted by pegasus seed
const int PEGASUS_SFX_FREQ = 10; //How often the sound loops

const int SEED_MAX_BOUNCE = 3; //How many times seeds bounce before breaking
const int SEED_STEP = 400; //Step speed of seeds launched by the seed shooter
const int SEED_SCENT_BAITFRAMES = 600; //How long scent seed bait lasts in frames (60ths of a second)
const int SEED_PEGASUS_STUN = 120; //How long pegasus seeds stun for in frames when hitting an enemy
const int SEED_PEGASUS_SPEEDFRAMES = 720; //How long pegasus seeds last for in frames when consumed
const float SEED_PEGASUS_SPEEDBOOST_STEP = 1.0; //Extra speed added to Link's step when boosted by pegasus seeds
const int DMF_NOGALE = 11; //DMap flag preventing gale seeds (Script 1 by default)

const int SEEDTREE_COOLDOWN = 12; //How many screen transitions seed trees take to respawn their seeds

const int DMAP_SEED_GALE_WARP = 1; //DMap of the warp screen used for gale seeds
const int SCREEN_SEED_GALE_WARP = 0x00; //Screen used for the warp screen used for gale seeds

const int SFX_SEED_WARP_CURSOR = 5; //Sound when moving the cursor in the warp menu
const int SFX_SEED_WARP_SELECT = 71; //Sound for selecting a warp

const int C_BLACK = 0x08; //Background color of the warp menu
const int C_SEED_WARP = 0x01; //Color of an unselected warp
const int C_SEED_WARP_SELECTED = 0x06; //Color of a selected warp

const int SEED_WARP_TITLE_FONT = 4; //Font used for the tile in the warp menu. See FONT_ in std_constants.zh
const int SEED_WARP_TITLE_X = 120; //X position of the title
const int SEED_WARP_TITLE_Y = 8; //Y position of the title

const int SEED_WARP_SELECTION_FONT = 0; //Font used for warps in the warp menu. 
const int SEED_WARP_SELECTION_X = 120; //X position of the first warp
const int SEED_WARP_SELECTION_Y = 32; //Y position of the first warp
const int SEED_WARP_SELECTION_HEIGHT = 12; //Y difference between warps

//X and Y position of the A button item on the passive subscreen
const int SUB_A_BUTTON_POS_X = 148;
const int SUB_A_BUTTON_POS_Y = 24;
//X and Y position of the A button item on the passive subscreen
const int SUB_B_BUTTON_POS_X = 124;
const int SUB_B_BUTTON_POS_Y = 24;

const int SUB_COUNTER_DRAW = 1; //Set to 1 to draw subscreen counters
const int SUB_COUNTER_FONT = 0; //Font used for subscreen counters. See FONT_ in std_constants.zh
const int SUB_COUNTER_SHADOW = 3; //0 = No Outline, 1 = Shadow, 2 = Shadow (U), 3 = Shadow (O), 4 = Shadow (+), 5 = Shadow (x)
const int SUB_COUNTER_C = 0x01; //Color of subscreen counters
const int SUB_COUNTER_C_OUTLINE = 0x08; //Outline color of subscreen counters

const int I_SEEDSATCHEL_EMBER = 153; //Item ID for the ember seed satchel
const int I_SEEDSATCHEL_SCENT = 154; //Item ID for the scent seed satchel
const int I_SEEDSATCHEL_PEGASUS = 155; //Item ID for the pegasus seed satchel
const int I_SEEDSATCHEL_GALE = 156; //Item ID for the gale seed satchel
const int I_SEEDSATCHEL_MYSTERY = 157; //Item ID for the mystery seed satchel

const int I_SEEDSHOOTER_EMBER = 143; //Item ID for the ember seed shooter
const int I_SEEDSHOOTER_SCENT = 144; //Item ID for the scent seed shooter
const int I_SEEDSHOOTER_PEGASUS = 145; //Item ID for the pegasus seed shooter
const int I_SEEDSHOOTER_GALE = 146; //Item ID for the gale seed shooter
const int I_SEEDSHOOTER_MYSTERY = 147; //Item ID for the mystery seed shooter

int seedShooterGlobal[96];
const int SSG__MAX_SLOT = 16;
const int SSG__SIZE = 5;
const int SSG_ACTIVE = 0;
const int SSG_DMAP = 1;
const int SSG_SCREEN = 2;
const int SSG_NAMESTRING = 3;
const int SSG_COOLDOWN = 4;
const int SSG_PEGASUSFRAMES = 80;
const int SSG_LASTDMAP = 81;
const int SSG_LASTSCREEN = 82;
const int SSG_SPECIALEXIT = 83;

item script SeedShooter{
	void run(int dummy, int itemID, int type){
		if(Link->Z > 0)
			Quit();
		int scr[] = "SeedShooter_FFC";
		int scrid = Game->GetFFCScript(scr);
		if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING)
			Quit();
		if((!Link->PressA&&GetEquipmentA()==itemID)||(!Link->PressB&&GetEquipmentB()==itemID))
			Quit();
		if(CountFFCsRunning(scrid)==0){
			int args[8] = {itemID, type};
			RunFFCScript(scrid, args);
		}
	}
}

item script SeedSatchel{
	void run(int dummy, int type){
		if(Link->Z > 0)
			Quit();
		int counter = 0;
		if(type==0)
			counter = CR_SEED_EMBER;
		else if(type==1)
			counter = CR_SEED_SCENT;
		else if(type==2)
			counter = CR_SEED_PEGASUS;
		else if(type==3)
			counter = CR_SEED_GALE;
		else if(type==4)
			counter = CR_SEED_MYSTERY;
		int scr[] = "SeedShooter_Seed_FFC";
		int scrid = Game->GetFFCScript(scr);
		if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING)
			Quit();
		if(type==2&&seedShooterGlobal[SSG_PEGASUSFRAMES]>0)
			Quit();
		if(CountFFCsRunning(scrid)==0){
			if(Game->Counter[counter]>0){
				Game->Counter[counter]--;
			}
			else
				Quit();
			int args[8] = {type, 1, Link->X, Link->Y+4, Link->Dir};
			RunFFCScript(scrid, args);
			Link->Action = LA_ATTACKING;
		}
	}
}

item script Bundle{
	void run(int msg, int i1, int i2, int i3, int i4, int i5, int i6, int i7){
		if(i1>0)
			Link->Item[i1] = true;
		if(i2>0)
			Link->Item[i2] = true;
		if(i3>0)
			Link->Item[i3] = true;
		if(i4>0)
			Link->Item[i4] = true;
		if(i5>0)
			Link->Item[i5] = true;
		if(i6>0)
			Link->Item[i6] = true;
		if(i7>0)
			Link->Item[i7] = true;
		Screen->Message(msg);
	}
}

ffc script SeedShooter_FFC{
	void run(int itemID, int type){
		int inputs[4];
		int shooterDir = Link->Dir;
		int counter = 0;
		if(type==0)
			counter = CR_SEED_EMBER;
		else if(type==1)
			counter = CR_SEED_SCENT;
		else if(type==2)
			counter = CR_SEED_PEGASUS;
		else if(type==3)
			counter = CR_SEED_GALE;
		else if(type==4)
			counter = CR_SEED_MYSTERY;
		bool alreadyInvisible = Link->Invisible;
		Link->Invisible = true;
		int minCounter = 16;
		while(!Shooter_Interrupted()&&(minCounter>0||((GetEquipmentA()==itemID&&Link->InputA)||(GetEquipmentB()==itemID&&Link->InputB)))){
			int drawLayer = 2;
			if(ScreenFlag(1, 4))
				drawLayer = 1;
			if(minCounter>0)
				minCounter--;
			shooterDir = SeedShooter_UpdateInputsDirection(shooterDir, inputs);
			Screen->FastCombo(drawLayer, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset, CMB_SEEDSHOOTERLINKAIM+shooterDir, 6, 128);
			Screen->FastCombo(drawLayer, Link->X+Link->DrawXOffset+SeedShooter_DirX(shooterDir), Link->Y+Link->DrawYOffset+SeedShooter_DirY(shooterDir), CMB_SEEDSHOOTERSEEDSHOOTER+shooterDir, CS_SEEDSHOOTERSEEDSHOOTER, 128);
			WaitNoAction();
		}
		if(!Shooter_Interrupted()&&Game->Counter[counter]>0){
			Game->PlaySound(SFX_SEEDSHOOTER);
			Game->Counter[counter]--;
			int scr[] = "SeedShooter_Seed_FFC";
			int scrid = Game->GetFFCScript(scr);
			int args[8];
			args[0] = type;
			args[1] = 0;
			args[2] = Link->X+Link->DrawXOffset+SeedShooter_DirX(shooterDir);
			args[3] = Link->Y+Link->DrawYOffset+SeedShooter_DirY(shooterDir);
			args[4] = shooterDir;
			RunFFCScript(scrid, args);
		}
		if(!alreadyInvisible)
			Link->Invisible = false;
	}
	bool Shooter_Interrupted(){
		if(!Link->Invisible)
			return true;
		if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING)
			return true;
		return false;
	}
	int SeedShooter_UpdateInputsDirection(int shooterDir, int inputs){
		int upTimer = 0;
		int downTimer = 1;
		int leftTimer = 2;
		int rightTimer = 3;
		
		int cycleFrames = 16;
		bool up;
		bool down;
		bool left;
		bool right;
		if(!(Link->InputUp&&Link->InputDown)){
			if(Link->PressUp)
				up = true;
			if(Link->InputUp){
				inputs[upTimer]++;
				if(inputs[upTimer]>cycleFrames){
					inputs[upTimer] = 0;
					up = true;
				}
			}
			else
				inputs[upTimer] = 0;
			
			if(Link->PressDown)
				down = true;
			if(Link->InputDown){
				inputs[downTimer]++;
				if(inputs[downTimer]>cycleFrames){
					inputs[downTimer] = 0;
					down = true;
				}
			}
			else
				inputs[downTimer] = 0;
		}
		if(!(Link->InputLeft&&Link->InputRight)){
			if(Link->PressLeft)
				left = true;
			if(Link->InputLeft){
				inputs[leftTimer]++;
				if(inputs[leftTimer]>cycleFrames){
					inputs[leftTimer] = 0;
					left = true;
				}
			}
			else
				inputs[leftTimer] = 0;
			
			if(Link->PressRight)
				right = true;
			if(Link->InputRight){
				inputs[rightTimer]++;
				if(inputs[rightTimer]>cycleFrames){
					inputs[rightTimer] = 0;
					right = true;
				}
			}
			else
				inputs[rightTimer] = 0;
		}
		
		if(up&&down){
			up = false;
			down = false;
		}
		if(left&&right){
			left = false;
			right = false;
		}
		if(Link->InputLeft&&Link->InputUp&&shooterDir==DIR_LEFTUP)
			return shooterDir;
		if(Link->InputRight&&Link->InputUp&&shooterDir==DIR_RIGHTUP)
			return shooterDir;
		if(Link->InputLeft&&Link->InputDown&&shooterDir==DIR_LEFTDOWN)
			return shooterDir;
		if(Link->InputRight&&Link->InputDown&&shooterDir==DIR_RIGHTDOWN)
			return shooterDir;
		
		if(shooterDir==DIR_UP){
			if(down||left)
				shooterDir = DIR_LEFTUP;
			else if(right)
				shooterDir = DIR_RIGHTUP;
		}
		else if(shooterDir==DIR_DOWN){
			if(up||right)
				shooterDir = DIR_RIGHTDOWN;
			else if(left)
				shooterDir = DIR_LEFTDOWN;
		}
		else if(shooterDir==DIR_LEFT){
			if(right||down)
				shooterDir = DIR_LEFTDOWN;
			else if(up)
				shooterDir = DIR_LEFTUP;
		}
		else if(shooterDir==DIR_RIGHT){
			if(left||up)
				shooterDir = DIR_RIGHTUP;
			else if(down)
				shooterDir = DIR_RIGHTDOWN;
		}
		else if(shooterDir==DIR_LEFTUP){
			if(left||down)
				shooterDir = DIR_LEFT;
			else if(right||up)
				shooterDir = DIR_UP;
		}
		else if(shooterDir==DIR_RIGHTUP){
			if(right||down)
				shooterDir = DIR_RIGHT;
			else if(left||up)
				shooterDir = DIR_UP;
		}
		else if(shooterDir==DIR_LEFTDOWN){
			if(left||up)
				shooterDir = DIR_LEFT;
			else if(right||down)
				shooterDir = DIR_DOWN;
		}
		else if(shooterDir==DIR_RIGHTDOWN){
			if(right||up)
				shooterDir = DIR_RIGHT;
			else if(left||down)
				shooterDir = DIR_DOWN;
		}
		
		return shooterDir;
	}
	int SeedShooter_DirX(int dir){
		if(dir==DIR_UP)
			return -3;
		else if(dir==DIR_DOWN)
			return 3;
		else if(dir==DIR_LEFT)
			return -15;
		else if(dir==DIR_RIGHT)
			return 15;
		else if(dir==DIR_LEFTUP)
			return -11;
		else if(dir==DIR_RIGHTUP)
			return 14;
		else if(dir==DIR_LEFTDOWN)
			return -11;
		else if(dir==DIR_RIGHTDOWN)
			return 14;
		return 0;
	}
	int SeedShooter_DirY(int dir){
		if(dir==DIR_UP)
			return -15;
		else if(dir==DIR_DOWN)
			return 15;
		else if(dir==DIR_LEFT)
			return 4;
		else if(dir==DIR_RIGHT)
			return 4;
		else if(dir==DIR_LEFTUP)
			return -14;
		else if(dir==DIR_RIGHTUP)
			return -8;
		else if(dir==DIR_LEFTDOWN)
			return 11;
		else if(dir==DIR_RIGHTDOWN)
			return 11;
		return 0;
	}
}

ffc script SeedShooter_Seed_FFC{
	void run(int type, int shotType, int x, int y, int dir){
		lweapon seed;
		npc collide;
		int bounce[2] = {SEED_MAX_BOUNCE, -1};
		if(shotType==-1){
			while(Link->Z>0){
				Link->Z -= 4;
				Link->Jump = 0;
				Screen->FastCombo(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
				WaitNoAction();
			}
			Quit();
		}
		else if(shotType==0){
			if(type==0){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_EMBER);
				seed->CollDetection = false;
			}
			else if(type==1){
				seed = CreateLWeaponAt(LW_SEED_SCENT, x, y);
				seed->UseSprite(SPR_SEED_SCENT);
				seed->Damage = DAMAGE_SEED_SCENT;
				seed->CollDetection = true;
			}
			else if(type==2){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_PEGASUS);
				seed->CollDetection = false;
			}
			else if(type==3){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_GALE);
				seed->CollDetection = false;
			}
			else if(type==4){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_MYSTERY);
				seed->CollDetection = false;
			}
			seed->Step = SEED_STEP;
			seed->HitXOffset = 4;
			seed->HitYOffset = 4;
			seed->HitWidth = 8;
			seed->HitHeight = 8;
			seed->Dir = dir;
			while(seed->isValid()&&bounce[0]>0){
				x = seed->X;
				y = seed->Y;
				Seed_UpdateDir(seed, bounce, type);
				if(type==1){
					int pX = seed->X+Seed_PredictX(seed->Dir, seed->Step/100);
					int pY = seed->Y+Seed_PredictY(seed->Dir, seed->Step/100);
					if(pX<=4||pX>=236||pY<=4||pY>=156){
						seed->CollDetection = false;
					}
					else{
						seed->CollDetection = true;
					}
				}
				else{
					collide = Seed_GetEnemyCollision(seed);
					if(collide->isValid())
						break;
				}
				if(bounce[0]>0)
					Waitframe();
				if(x<-64||x>256+64||y<-64||y>176+64){
					seed->DeadState = 0;
					Quit();
				}
			}
			if(seed->isValid()){
				x = seed->X;
				y = seed->Y;
				seed->DeadState = 0;
			}
		}
		else if(shotType==1){
			if(type==0){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_EMBER);
				seed->CollDetection = false;
			}
			else if(type==1){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_SCENT);
				seed->CollDetection = false;
			}
			else if(type==2){
				if(seedShooterGlobal[SSG_PEGASUSFRAMES]<=0){
					seedShooterGlobal[SSG_PEGASUSFRAMES] = SEED_PEGASUS_SPEEDFRAMES;
				}
				Quit();
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_PEGASUS);
				seed->CollDetection = false;
			}
			else if(type==3){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_GALE);
				seed->CollDetection = false;
			}
			else if(type==4){
				seed = CreateLWeaponAt(LW_SEED, x, y);
				seed->UseSprite(SPR_SEED_MYSTERY);
				seed->CollDetection = false;
			}
			seed->Step = 100;
			seed->HitXOffset = 4;
			seed->HitYOffset = 4;
			seed->HitWidth = 8;
			seed->HitHeight = 8;
			seed->Dir = dir;
			int jump = 1.6;
			int Z = 0;
			seed->Jump = 1.2;
			while(seed->isValid()&&(seed->Z>0||jump>0)){
				Z += jump;
				jump = Max(jump-0.16, -3.2);
				seed->Z = Max(Z, 0);
				x = seed->X;
				y = seed->Y;
				Waitframe();
			}
			collide = Seed_GetEnemyCollision(seed);
			if(seed->isValid()){
				x = seed->X;
				y = seed->Y;
				seed->DeadState = 0;
			}
		}
		lweapon hitbox;
		if(collide->isValid()){
			if(type==0){
				if(!Seed_Ember_GetEnemyDefense(collide->ID)){
					collide->Stun = 999;
					Game->PlaySound(SFX_SEED_EMBER);
					for(int i=0; i<60&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_EMBERFIRE, CS_SEED_EMBERFIRE, 128);
						Waitframe();
					}
					if(collide->isValid())
						collide->HP = 0;
					Quit();
				}
			}
			else if(type==2){
				if(!Seed_Pegasus_GetEnemyDefense(collide->ID)){
					collide->Stun = SEED_PEGASUS_STUN;
				}
			}
			else if(type==3){
				if(!Seed_Gale_GetEnemyDefense(collide->ID)){
					collide->Stun = 999;
					Game->PlaySound(SFX_SEED_GALE);
					for(int i=0; i<40&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
						Waitframe();
					}
					for(int i=0; i<30&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->Z += 4;
						collide->Jump = 0;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
						Waitframe();
					}
					if(collide->isValid()){
						collide->DrawYOffset = -1000;
						collide->ItemSet = 0;
						collide->HP = -1000;
					}
					Quit();
				}
			}
			else if(type==4){
				int effect = Rand(4);
				if(effect==0&&Seed_Ember_GetEnemyDefense(collide->ID))
					effect = -1;
				else if(effect==1&&Seed_Pegasus_GetEnemyDefense(collide->ID))
					effect = -1;
				else if(effect==2&&Seed_Gale_GetEnemyDefense(collide->ID))
					effect = -1;	
				if(effect==-1){
					hitbox = CreateLWeaponAt(LW_SEED_MYSTERY, collide->X, collide->Y);
					hitbox->Damage = Rand(DAMAGE_SEED_MYSTERY_LOW, DAMAGE_SEED_MYSTERY_HIGH);
					hitbox->DrawYOffset = -1000;
					hitbox->Dir = -1;
				}
				else if(effect==0){
					collide->Stun = 999;
					Game->PlaySound(SFX_SEED_EMBER);
					for(int i=0; i<60&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_EMBERFIRE, CS_SEED_EMBERFIRE, 128);
						Waitframe();
					}
					if(collide->isValid())
						collide->HP = 0;
					Quit();
				}
				else if(effect==1){
					collide->Stun = SEED_PEGASUS_STUN;
				}
				else if(effect==2){
					collide->Stun = 999;
					Game->PlaySound(SFX_SEED_GALE);
					for(int i=0; i<40&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
						Waitframe();
					}
					for(int i=0; i<30&&collide->isValid(); i++){
						collide->Stun = 999;
						collide->Z += 4;
						collide->Jump = 0;
						collide->CollDetection = false;
						Screen->FastCombo(4, collide->X+collide->DrawXOffset, collide->Y+collide->DrawYOffset-collide->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
						Waitframe();
					}
					if(collide->isValid()){
						collide->DrawYOffset = -1000;
						collide->ItemSet = 0;
						collide->HP = -1000;
					}
					Quit();
				}
			}
		}
		if(x>0&&x<240&&y>0&&y<160){
			lweapon poof;
			if(type==0){
				poof = CreateLWeaponAt(LW_SEED, x, y);
				poof->UseSprite(SPR_SEED_EMBER_POOF);
				poof->DeadState = poof->NumFrames*poof->ASpeed;
				poof->CollDetection = false;
				Game->PlaySound(SFX_SEED_EMBER);
				while(poof->isValid()){
					if(!hitbox->isValid()){
						hitbox = CreateLWeaponAt(LW_FIRE, x, y);
						hitbox->Step = 0;
						hitbox->Dir = -1;
						hitbox->Damage = DAMAGE_SEED_EMBER;
						hitbox->DrawYOffset = -1000;
					}
					Waitframe();
				}
				if(hitbox->isValid())
					hitbox->DeadState = 0;
			}
			else if(type==1){
				if(shotType==0){
					Game->PlaySound(SFX_SEED_SCENT);
					poof = CreateLWeaponAt(LW_SEED, x, y);
					poof->UseSprite(SPR_SEED_SCENT_POOF);
					poof->DeadState = poof->NumFrames*poof->ASpeed;
					poof->CollDetection = false;
				}
				else{
					Game->PlaySound(SFX_SCENT_BAIT);
					for(int i=0; i<SEED_SCENT_BAITFRAMES; i++){
						if(!poof->isValid()){
							poof = CreateLWeaponAt(LW_BAIT, x, y);
							poof->UseSprite(SPR_SCENT_BAIT);
						}
						Waitframe();
					}
					if(poof->isValid())
						poof->DeadState = 0;
				}
			}
			else if(type==2){
				Game->PlaySound(SFX_SEED_PEGASUS);
				poof = CreateLWeaponAt(LW_SEED, x, y);
				poof->UseSprite(SPR_SEED_PEGASUS_POOF);
				poof->DeadState = poof->NumFrames*poof->ASpeed;
				poof->CollDetection = false;
				if(LinkCollision(poof)){
					seedShooterGlobal[SSG_PEGASUSFRAMES] = SEED_PEGASUS_SPEEDFRAMES;
				}
			}
			else if(type==3){
				Game->PlaySound(SFX_SEED_GALE);
				poof = CreateLWeaponAt(LW_SEED, x, y);
				poof->UseSprite(SPR_SEED_GALE_POOF);
				poof->DeadState = 60;
				poof->CollDetection = false;
				while(poof->isValid()){
					if(LinkCollision(poof)){
						Link->X = poof->X;
						Link->Y = poof->Y;
						poof->DeadState = 0;
						for(int i=0; i<40; i++){
							Screen->FastCombo(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
							WaitNoAction();
						}
						for(int i=0; i<30; i++){
							Link->Z += 4;
							Link->Jump = 0;
							Screen->FastCombo(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
							WaitNoAction();
						}
						if(Game->DMapFlags[Game->GetCurDMap()]&(1<<DMF_NOGALE)){
							Game->PlaySound(SFX_GALE_CEILINGBUMP);
							Screen->Quake = 10;
							for(int i=0; i<8; i++){
								Link->Jump = 0;
								Screen->FastCombo(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
								WaitNoAction();
							}
							for(int i=0; i<30; i++){
								Link->Z -= 4;
								Link->Jump = 0;
								Screen->FastCombo(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, CMB_SEED_GALEWIND, CS_SEED_GALEWIND, 128);
								WaitNoAction();
							}
						}
						else
							Link->Warp(DMAP_SEED_GALE_WARP, SCREEN_SEED_GALE_WARP);
					}
					Waitframe();
				}
			}
			else if(type==4){
				Game->PlaySound(SFX_SEED_MYSTERY);
				poof = CreateLWeaponAt(LW_SEED_MYSTERY, x, y);
				poof->UseSprite(SPR_SEED_MYSTERY_POOF);
				poof->DeadState = poof->NumFrames*poof->ASpeed;
				poof->CollDetection = false;
				Waitframe();
			}
		}
		if(hitbox->isValid())
			hitbox->DeadState = 0;
	}
	npc Seed_GetEnemyCollision(lweapon l){
		npc coll[64];
		int count;
		for(int i=Screen->NumNPCs(); i>=1; i--){
			npc n = Screen->LoadNPC(i);
			if(n->ID==NPCT_GUY||n->ID==NPCT_FAIRY||n->ID==NPCT_PROJECTILE||n->ID==NPCT_TRAP)
				continue;
			if(n->CollDetection){
				if(Collision(n, l)&&n->CollDetection){
					coll[count] = n;
					count++;
				}
			}
		}
		int minDist = 1000;
		npc target;
		if(count>0){
			for(int i=0; i<count; i++){
				if(Distance(coll[i]->X, coll[i]->Y, l->X, l->Y)<minDist){
					minDist = Distance(coll[i]->X, coll[i]->Y, l->X, l->Y);
					target = coll[i];
				}
			}
		}
		return target;
	}
	int Seed_PredictX(int dir, int step){
		if(dir==DIR_LEFT||dir==DIR_LEFTUP||dir==DIR_LEFTDOWN)
			return -step;
		else if(dir==DIR_RIGHT||dir==DIR_RIGHTUP||dir==DIR_RIGHTDOWN)
			return step;
	}
	int Seed_PredictY(int dir, int step){
		if(dir==DIR_UP||dir==DIR_LEFTUP||dir==DIR_RIGHTUP)
			return -step;
		else if(dir==DIR_DOWN||dir==DIR_LEFTDOWN||dir==DIR_RIGHTDOWN)
			return step;
	}
	void Seed_UpdateDir(lweapon seed, int bounce, int type){
		int mirrorPos[1];
		int bt = Seed_BounceType(seed->X, seed->Y, type, mirrorPos);
		if(bt==-2){
			bounce[0] = 0;
			return;
		}
		if(bounce[1]==-1&&bt>0){
			bool specialBounce;
			if(seed->Dir==DIR_UP){
				if(bt==1)
					seed->Dir = DIR_DOWN;
				else if(bt==2){ // /
					seed->Y = ComboY(mirrorPos[0]);
					seed->Dir = DIR_RIGHT;
				}
				else if(bt==3){ // \
					seed->Y = ComboY(mirrorPos[0]);
					seed->Dir = DIR_LEFT;
				}
			}
			else if(seed->Dir==DIR_DOWN){
				if(bt==1)
					seed->Dir = DIR_UP;
				else if(bt==2){ // /
					seed->Y = ComboY(mirrorPos[0]);
					seed->Dir = DIR_LEFT;
				}
				else if(bt==3){ // \
					seed->Y = ComboY(mirrorPos[0]);
					seed->Dir = DIR_RIGHT;
				}
			}
			else if(seed->Dir==DIR_LEFT){
				if(bt==1)
					seed->Dir = DIR_RIGHT;
				else if(bt==2){ // /
					seed->X = ComboX(mirrorPos[0]);
					seed->Dir = DIR_DOWN;
				}
				else if(bt==3){ // \
					seed->X = ComboX(mirrorPos[0]);
					seed->Dir = DIR_UP;
				}
			}
			else if(seed->Dir==DIR_RIGHT){
				if(bt==1)
					seed->Dir = DIR_LEFT;
				else if(bt==2){ // /
					seed->X = ComboX(mirrorPos[0]);
					seed->Dir = DIR_UP;
				}
				else if(bt==3){ // \
					seed->X = ComboX(mirrorPos[0]);
					seed->Dir = DIR_DOWN;
				}
			}
			else if(seed->Dir==DIR_LEFTUP){
				if(bt==1)
					specialBounce = true;
				else if(bt==2) // /
					seed->Dir = DIR_RIGHTDOWN;
				else if(bt==3) // \
					bounce[0] = 0;
			}
			else if(seed->Dir==DIR_RIGHTUP){
				if(bt==1)
					specialBounce = true;
				else if(bt==2) // /
					bounce[0] = 0;
				else if(bt==3) // \
					seed->Dir = DIR_LEFTDOWN;
			}
			else if(seed->Dir==DIR_LEFTDOWN){
				if(bt==1)
					specialBounce = true;
				else if(bt==2) // /
					bounce[0] = 0;
				else if(bt==3) // \
					seed->Dir = DIR_RIGHTUP;
			}
			else if(seed->Dir==DIR_RIGHTDOWN){
				if(bt==1)
					specialBounce = true;
				else if(bt==2) // /
					seed->Dir = DIR_LEFTUP;
				else if(bt==3) // \
					bounce[0] = 0;
			}
			
			if(mirrorPos[0]>-1&&bt>1){
				bounce[1] = mirrorPos[0];//bt;
			}
			
			if(specialBounce){
				int b = Seed_SpecialBounce(seed, type);
				if(b==-2)
					bounce[0] = 0;
				else if(b>-1){
					//bounce[1] = b;
					seed->Dir = b;
				} 
			}
			bounce[0]--;
		}
		if(mirrorPos[0]!=bounce[1])
			bounce[1] = -1;
	}
	bool Seed_IsSolid(int x, int y){
		int ct = Screen->ComboT[ComboAt(x, y)];
		if(ct==CT_LADDERHOOKSHOT||ct==CT_LADDERONLY||ct==CT_HOOKSHOTONLY||ct==CT_WATER)
			return false;
		if(ct==CT_DIVEWARP||ct==CT_DIVEWARPB||ct==CT_DIVEWARPC||ct==CT_DIVEWARPD)
			return false;
		if(ct==CT_SWIMWARP||ct==CT_SWIMWARPB||ct==CT_SWIMWARPC||ct==CT_SWIMWARPD)
			return false;
		return Screen->isSolid(x, y);
	}
	int Seed_SpecialBounce(lweapon seed, int type){
		int dirCount[4];
		bool trueDir[4];
		if(type==0){
			if(ComboFI(seed->X+8, seed->Y+4, CF_CANDLE1))
				return -2;
			if(ComboFI(seed->X+8, seed->Y+11, CF_CANDLE1))
				return -2;
			if(ComboFI(seed->X+4, seed->Y+8, CF_CANDLE1))
				return -2;
			if(ComboFI(seed->X+11, seed->Y+8, CF_CANDLE1))
				return -2;
		}
		
		if(Seed_IsSolid(seed->X+8, seed->Y+4)){
			dirCount[DIR_UP]++;
			dirCount[DIR_LEFT]++;
			dirCount[DIR_RIGHT]++;
			trueDir[DIR_UP] = true;
		}
		if(Seed_IsSolid(seed->X+8, seed->Y+11)){
			dirCount[DIR_DOWN]++;
			dirCount[DIR_LEFT]++;
			dirCount[DIR_RIGHT]++;
			trueDir[DIR_DOWN] = true;
		}
		if(Seed_IsSolid(seed->X+4, seed->Y+8)){
			dirCount[DIR_LEFT]++;
			dirCount[DIR_UP]++;
			dirCount[DIR_DOWN]++;
			trueDir[DIR_LEFT] = true;
		}
		if(Seed_IsSolid(seed->X+11, seed->Y+8)){
			dirCount[DIR_RIGHT]++;
			dirCount[DIR_UP]++;
			dirCount[DIR_DOWN]++;
			trueDir[DIR_RIGHT] = true;
		}
		
		if(seed->Dir==DIR_LEFTUP){
			if(dirCount[DIR_UP]>dirCount[DIR_LEFT])
				return DIR_LEFTDOWN;
			if(dirCount[DIR_LEFT]>dirCount[DIR_UP])
				return DIR_RIGHTUP;
		}
		else if(seed->Dir==DIR_RIGHTUP){
			if(dirCount[DIR_UP]>dirCount[DIR_RIGHT])
				return DIR_RIGHTDOWN;
			if(dirCount[DIR_RIGHT]>dirCount[DIR_UP])
				return DIR_LEFTUP;
		}
		else if(seed->Dir==DIR_LEFTDOWN){
			if(dirCount[DIR_DOWN]>dirCount[DIR_LEFT])
				return DIR_LEFTUP;
			if(dirCount[DIR_LEFT]>dirCount[DIR_DOWN])
				return DIR_RIGHTDOWN;
		}
		else if(seed->Dir==DIR_RIGHTDOWN){
			if(dirCount[DIR_DOWN]>dirCount[DIR_RIGHT])
				return DIR_RIGHTUP;
			if(dirCount[DIR_RIGHT]>dirCount[DIR_DOWN])
				return DIR_LEFTDOWN;
		}
		
		if(seed->Dir==DIR_LEFTUP){
			if(trueDir[DIR_UP])
				return DIR_LEFTDOWN;
			if(trueDir[DIR_LEFT])
				return DIR_RIGHTUP;
		}
		else if(seed->Dir==DIR_RIGHTUP){
			if(trueDir[DIR_UP])
				return DIR_RIGHTDOWN;
			if(trueDir[DIR_RIGHT])
				return DIR_LEFTUP;
		}
		else if(seed->Dir==DIR_LEFTDOWN){
			if(trueDir[DIR_DOWN])
				return DIR_LEFTUP;
			if(trueDir[DIR_LEFT])
				return DIR_RIGHTDOWN;
		}
		else if(seed->Dir==DIR_RIGHTDOWN){
			if(trueDir[DIR_DOWN])
				return DIR_RIGHTUP;
			if(trueDir[DIR_RIGHT])
				return DIR_LEFTDOWN;
		}
		
		return -1;
	}
	int Seed_BounceType(int X, int Y, int type, int mirrorPos){
		int c;
		int ct;
		if(type==0&&ComboFI(X+8, Y+8, CF_CANDLE1))
			return -2;
		if(type==4){
			int scr[] = "OwlStatue";
			int num = FindFFCRunning(Game->GetFFCScript(scr));
			if(num>0){
				ffc f = Screen->LoadFFC(num);
				if(RectCollision(X+4, Y+4, X+11, Y+11, f->X+16, f->Y, f->X+31, f->Y+15)){
					return -2;
				}
			}
		}
		c = ComboAt(X+8, Y+8);
		ct = Screen->ComboT[c];
		if(ct==CT_MIRRORSLASH){
			mirrorPos[0] = c;
			return 2;
		}
		else if(ct==CT_MIRRORBACKSLASH){
			mirrorPos[0] = c;
			return 3;
		}
		if(Seed_IsSolid(X+8, Y+8)){
			return 1;
		}
		for(int x=0; x<2; x++){
			for(int y=0; y<2; y++){
				c = ComboAt(X+4+x*7, Y+4+y*7);
				ct = Screen->ComboT[c];
				if(type==0&&ComboFI(X+4+x*7, Y+4+y*7, CF_CANDLE1))
					return -2;
				if(ct==CT_MIRRORSLASH){
					mirrorPos[0] = c;
					return 2;
				}
				else if(ct==CT_MIRRORBACKSLASH){
					mirrorPos[0] = c;
					return 3;
				}
				if(Seed_IsSolid(X+4+x*7, Y+4+y*7)){
					return 1;
				}
			}
		}
		return 0;
	}
}

void Seed_SetDef(bool def, int id){
	def[id] = true;
}

ffc script SeedTree{
	void run(int itemID, int id, int str){
		id = Clamp(id, 0, SSG__MAX_SLOT-1);
		seedShooterGlobal[id*SSG__SIZE+SSG_ACTIVE] = 1;
		seedShooterGlobal[id*SSG__SIZE+SSG_DMAP] = Game->GetCurDMap();
		seedShooterGlobal[id*SSG__SIZE+SSG_SCREEN] = Game->GetCurDMapScreen();
		seedShooterGlobal[id*SSG__SIZE+SSG_NAMESTRING] = str;
		if(seedShooterGlobal[id*SSG__SIZE+SSG_COOLDOWN]>0)
			Quit();
		
		item itm[3];
		itm[0] = CreateItemAt(itemID, this->X+8, this->Y+3);
		itm[1] = CreateItemAt(itemID, this->X, this->Y+11);
		itm[2] = CreateItemAt(itemID, this->X+16, this->Y+11);
		int itmX[3];
		int itmY[3];
		int startX[3];
		int startY[3];
		for(int i=0; i<3; i++){
			itm[i]->Pickup = IP_DUMMY;
			itmX[i] = itm[i]->X;
			itmY[i] = itm[i]->Y;
			startX[i] = itmX[i];
			startY[i] = itmY[i];
			itm[i]->HitXOffset = 6;
			itm[i]->HitYOffset = 6;
			itm[i]->HitWidth = 4;
			itm[i]->HitHeight = 4;
		}
		int angle[3];
		int bounces[3];
		int step[3];
		while(true){
			lweapon sword = LoadLWeaponOf(LW_SWORD);
			for(int i=0; i<3; i++){
				if(itm[i]->isValid()){
					if(Collision(sword, itm[i])&&bounces[i]==0){
						itm[i]->HitXOffset = 0;
						itm[i]->HitYOffset = 0;
						itm[i]->HitWidth = 16;
						itm[i]->HitHeight = 16;
						itm[i]->Jump = 1.6;
						angle[i] = Angle(itm[i]->X, itm[i]->Y, Link->X, Link->Y);
						step[i] = (Distance(startX[i], startY[i], Link->X, Link->Y)*1.5)/35;
						itm[i]->Pickup = 0;
						bounces[i] = 1;
						SeedTree_FlagTaken(id);
					}
					if(itm[i]->Jump>0||itm[i]->Z>0){
						itmX[i] += VectorX(step[i], angle[i]);
						itmY[i] += VectorY(step[i], angle[i]);
						itm[i]->X = itmX[i];
						itm[i]->Y = itmY[i];
					}
					else if(itm[i]->Z==0){
						if(bounces[i]==1){
							bounces[i] = 2;
							itm[i]->Jump = 0.8;
						}
						else if(bounces[i]==2){
							bounces[i] = 3;
							itm[i]->Jump = 0.4;
						}
						else if(bounces[i]==3){
							bounces[i] = 4;
						}
					}
					if(bounces[i]==0||itm[i]->Z>0){
						SeedTree_DrawToLayer(itm[i], 5, 128);
						itm[i]->DrawYOffset = -1000;
					}
					else{
						itm[i]->DrawYOffset = 0;
					}
				}
			}
			Waitframe();
		}
	}
	void SeedTree_DrawToLayer(item i, int layer, int opacity){
		Screen->DrawTile(layer,i->X,i->Y-i->Z,i->Tile,i->TileWidth,i->TileHeight,i->CSet,-1,-1,0,0,0,0,true,opacity);
	}
	void SeedTree_FlagTaken(int id){
		seedShooterGlobal[id*SSG__SIZE+SSG_COOLDOWN] = SEEDTREE_COOLDOWN;
	}
}

ffc script SeedTree_Warp{
	void run(){
		seedShooterGlobal[SSG_PEGASUSFRAMES] = 0;
		Link->Z = 0;
		int numStrings;
		int warps[16];
		int names[16];
		for(int i=0; i<16; i++){
			names[i] = -1;
		}
		for(int i=0; i<SSG__MAX_SLOT; i++){
			if(seedShooterGlobal[i*SSG__SIZE+SSG_ACTIVE]){
				warps[numStrings] = i;
				names[numStrings] = seedShooterGlobal[i*SSG__SIZE+SSG_NAMESTRING];
				numStrings++;
			}
		}
		int maxStrings = Max(Floor((168-SEED_WARP_SELECTION_Y)/SEED_WARP_SELECTION_HEIGHT)-1, 0);
		int selectionFrames = 8;
		int upCounter;
		int downCounter;
		int selection = 0;
		int title[] = "Select Warp Destination:";
		while(true){
			Screen->Rectangle(6, 0, 0, 255, 175, C_BLACK, 1, 0, 0, 0, true, 128);
			Screen->DrawString(6, SEED_WARP_TITLE_X, SEED_WARP_TITLE_Y, SEED_WARP_TITLE_FONT, C_SEED_WARP, -1, TF_CENTERED, title, 128);
			if(Link->InputUp){
				upCounter++;
				if(Link->PressUp||upCounter>selectionFrames){
					Game->PlaySound(SFX_SEED_WARP_CURSOR);
					upCounter = 0;
					selection--;
					if(selection<0)
						selection = Max(numStrings-1, 0);
				}
			}
			else
				upCounter = 0;
			if(Link->InputDown){
				downCounter++;
				if(Link->PressDown||downCounter>selectionFrames){
					Game->PlaySound(SFX_SEED_WARP_CURSOR);
					downCounter = 0;
					selection++;
					if(selection>numStrings-1)
						selection = 0;
				}
			}
			else
				downCounter = 0;
			int startPos = selection-Floor(maxStrings/2);
			startPos = Min(startPos, numStrings-maxStrings);
			startPos = Max(startPos, 0);
			for(int i=0; i<maxStrings; i++){
				int x = SEED_WARP_SELECTION_X;
				int y = SEED_WARP_SELECTION_Y+i*SEED_WARP_SELECTION_HEIGHT;
				if(names[startPos+i]>-1){
					int str[256];
					Game->GetMessage(names[startPos+i], str);
					SeedTree_Warp_CapString(str);
					if(startPos+i==selection){
						Screen->DrawString(6, x, y, SEED_WARP_SELECTION_FONT, C_SEED_WARP_SELECTED, -1, TF_CENTERED, str, 128);
					}
					else{
						Screen->DrawString(6, x, y, SEED_WARP_SELECTION_FONT, C_SEED_WARP, -1, TF_CENTERED, str, 128);
					}
				}
			}
			if(Link->PressA||Link->PressStart)
				break;
			Link->PressStart = false; Link->InputStart = false;
			Link->PressMap = false; Link->InputMap = false;
			WaitNoAction();
		}
		Game->PlaySound(SFX_SEED_WARP_SELECT);
		for(int k=0; k<30; k++){
			Screen->Rectangle(6, 0, 0, 255, 175, C_BLACK, 1, 0, 0, 0, true, 128);
			Screen->DrawString(6, SEED_WARP_TITLE_X, SEED_WARP_TITLE_Y, SEED_WARP_TITLE_FONT, C_SEED_WARP, -1, TF_CENTERED, title, 128);
			int startPos = selection-Floor(maxStrings/2);
			startPos = Min(startPos, numStrings-maxStrings);
			startPos = Max(startPos, 0);
			for(int i=0; i<maxStrings; i++){
				int x = SEED_WARP_SELECTION_X;
				int y = SEED_WARP_SELECTION_Y+i*SEED_WARP_SELECTION_HEIGHT;
				if(names[startPos+i]>-1){
					int str[256];
					Game->GetMessage(names[startPos+i], str);
					SeedTree_Warp_CapString(str);
					if(startPos+i==selection){
						Screen->DrawString(6, x, y, SEED_WARP_SELECTION_FONT, Cond(k%4<2, C_SEED_WARP_SELECTED, C_SEED_WARP), -1, TF_CENTERED, str, 128);
					}
					else{
						Screen->DrawString(6, x, y, SEED_WARP_SELECTION_FONT, C_SEED_WARP, -1, TF_CENTERED, str, 128);
					}
				}
			}
			Link->PressStart = false; Link->InputStart = false;
			Link->PressMap = false; Link->InputMap = false;
			WaitNoAction();
		}
		int dest = warps[selection];
		Link->Z = 120;
		seedShooterGlobal[SSG_SPECIALEXIT] = 1;
		Link->Warp(seedShooterGlobal[dest*SSG__SIZE+SSG_DMAP], seedShooterGlobal[dest*SSG__SIZE+SSG_SCREEN]);
	}
	void SeedTree_Warp_CapString(int str){
		for(int i=SizeOfArray(str)-1; i>=0; i--){
			if(str[i]>32){
				str[i+1] = 0;
				return;
			}
		}
	}
}

ffc script OwlStatue{
	void run(int str){
		int data = this->Data;
		while(true){
			lweapon mysteryPoof;
			for(int i=Screen->NumLWeapons(); i>=1; i--){
				lweapon l = Screen->LoadLWeapon(i);
				if(l->ID==LW_SEED_MYSTERY&&!l->CollDetection){
					if(RectCollision(this->X+16, this->Y, this->X+31, this->Y+15, l->X+4, l->Y+4, l->X+11, l->Y+11)){
						mysteryPoof = l;
						break;
					}
				}
			}
			if(mysteryPoof->isValid()){
				while(mysteryPoof->isValid()){
					Waitframe();
				}
				this->Data = data+1;
				WaitNoAction(24);
				Screen->Message(str);
				WaitNoAction(24);
				this->Data = data;
			}
			Waitframe();
		}
	}
}

bool Seed_Ember_GetEnemyDefense(int id){
	bool def[512];
	
	Seed_SetDef(def, 106); //Bat
	Seed_SetDef(def, 160); //Bombchu
	Seed_SetDef(def, 68); //Digdogger Kid
	Seed_SetDef(def, 69);
	Seed_SetDef(def, 70);
	Seed_SetDef(def, 71);
	Seed_SetDef(def, 42); //Gel
	Seed_SetDef(def, 88);
	Seed_SetDef(def, 54); //Gibdo
	Seed_SetDef(def, 38); //Keese
	Seed_SetDef(def, 39);
	Seed_SetDef(def, 40);
	Seed_SetDef(def, 90);
	Seed_SetDef(def, 26); //Leever
	Seed_SetDef(def, 27);
	Seed_SetDef(def, 22); //Octorok
	Seed_SetDef(def, 20);
	Seed_SetDef(def, 23);
	Seed_SetDef(def, 21);
	Seed_SetDef(def, 32); //Peahat
	Seed_SetDef(def, 44); //Rope
	Seed_SetDef(def, 41); //Stalfos
	Seed_SetDef(def, 79);
	Seed_SetDef(def, 24); //Tektite
	Seed_SetDef(def, 25);
	Seed_SetDef(def, 52); //Vire
	Seed_SetDef(def, 91);
	Seed_SetDef(def, 48); //Wallmaster
	Seed_SetDef(def, 43); //Zol
	Seed_SetDef(def, 89);
	
	return !def[id];
}

bool Seed_Pegasus_GetEnemyDefense(int id){
	bool def[512];
	
	Seed_SetDef(def, 37); //Armos
	Seed_SetDef(def, 106); //Bat
	Seed_SetDef(def, 160); //Bombchu
	Seed_SetDef(def, 49); //Darknut
	Seed_SetDef(def, 50);
	Seed_SetDef(def, 92);
	Seed_SetDef(def, 68); //Digdogger Kid
	Seed_SetDef(def, 69);
	Seed_SetDef(def, 70);
	Seed_SetDef(def, 71);
	Seed_SetDef(def, 42); //Gel
	Seed_SetDef(def, 88);
	Seed_SetDef(def, 161); //Gel Fire
	Seed_SetDef(def, 163);
	Seed_SetDef(def, 35); //Ghini
	Seed_SetDef(def, 36);
	Seed_SetDef(def, 54); //Gibdo
	Seed_SetDef(def, 45); //Goriya
	Seed_SetDef(def, 46);
	Seed_SetDef(def, 136);
	Seed_SetDef(def, 38); //Keese
	Seed_SetDef(def, 39);
	Seed_SetDef(def, 40);
	Seed_SetDef(def, 90);
	Seed_SetDef(def, 26); //Leever
	Seed_SetDef(def, 27);
	Seed_SetDef(def, 137);
	Seed_SetDef(def, 53); //Like Like
	Seed_SetDef(def, 30); //Lynel
	Seed_SetDef(def, 31);
	Seed_SetDef(def, 28); //Moblin
	Seed_SetDef(def, 29);
	Seed_SetDef(def, 22); //Octorok
	Seed_SetDef(def, 20);
	Seed_SetDef(def, 23);
	Seed_SetDef(def, 21);
	Seed_SetDef(def, 139);
	Seed_SetDef(def, 138);
	Seed_SetDef(def, 141);
	Seed_SetDef(def, 140);
	Seed_SetDef(def, 86);
	Seed_SetDef(def, 32); //Peahat
	Seed_SetDef(def, 55); //Pols Voice
	Seed_SetDef(def, 170);
	Seed_SetDef(def, 44); //Rope
	Seed_SetDef(def, 80);
	Seed_SetDef(def, 41); //Stalfos
	Seed_SetDef(def, 79);
	Seed_SetDef(def, 120);
	Seed_SetDef(def, 24); //Tektite
	Seed_SetDef(def, 25);
	Seed_SetDef(def, 52); //Vire
	Seed_SetDef(def, 91);
	Seed_SetDef(def, 48); //Wallmaster
	Seed_SetDef(def, 43); //Zol
	Seed_SetDef(def, 89);
	Seed_SetDef(def, 162); //Zol Fire
	Seed_SetDef(def, 164);
	
	return !def[id];
}

bool Seed_Gale_GetEnemyDefense(int id){
	bool def[512];
	
	Seed_SetDef(def, 106); //Bat
	Seed_SetDef(def, 160); //Bombchu
	Seed_SetDef(def, 68); //Digdogger Kid
	Seed_SetDef(def, 69);
	Seed_SetDef(def, 70);
	Seed_SetDef(def, 71);
	Seed_SetDef(def, 42); //Gel
	Seed_SetDef(def, 88);
	Seed_SetDef(def, 161); //Gel Fire
	Seed_SetDef(def, 163);
	Seed_SetDef(def, 35); //Ghini
	Seed_SetDef(def, 36);
	Seed_SetDef(def, 45); //Goriya
	Seed_SetDef(def, 46);
	Seed_SetDef(def, 38); //Keese
	Seed_SetDef(def, 39);
	Seed_SetDef(def, 40);
	Seed_SetDef(def, 90);
	Seed_SetDef(def, 28); //Moblin
	Seed_SetDef(def, 29);
	Seed_SetDef(def, 22); //Octorok
	Seed_SetDef(def, 20);
	Seed_SetDef(def, 23);
	Seed_SetDef(def, 21);
	Seed_SetDef(def, 139);
	Seed_SetDef(def, 138);
	Seed_SetDef(def, 141);
	Seed_SetDef(def, 140);
	Seed_SetDef(def, 86);
	Seed_SetDef(def, 32); //Peahat
	Seed_SetDef(def, 44); //Rope
	Seed_SetDef(def, 80);
	Seed_SetDef(def, 41); //Stalfos
	Seed_SetDef(def, 79);
	Seed_SetDef(def, 120);
	Seed_SetDef(def, 24); //Tektite
	Seed_SetDef(def, 25);
	Seed_SetDef(def, 52); //Vire
	Seed_SetDef(def, 91);
	Seed_SetDef(def, 48); //Wallmaster
	Seed_SetDef(def, 43); //Zol
	Seed_SetDef(def, 89);
	Seed_SetDef(def, 162); //Zol Fire
	Seed_SetDef(def, 164);
	
	return !def[id];
}

void SeedShooter_Init(){
	seedShooterGlobal[SSG_PEGASUSFRAMES] = 0;
	seedShooterGlobal[SSG_LASTDMAP] = Game->GetCurDMap();
	seedShooterGlobal[SSG_LASTSCREEN] = Game->GetCurScreen();
	seedShooterGlobal[SSG_SPECIALEXIT] = 0;
}

void SeedShooter_DrawInt(int layer, int x, int y, int val){
	val = Clamp(val, 0, 99);
	int ones = val%10;
	int tens = Floor(val/10);
	int theNum[] = "  ";
	theNum[0] = '0' + tens;
	theNum[1] = '0' + ones;
	if(SUB_COUNTER_SHADOW==0){
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
	else if(SUB_COUNTER_SHADOW==1){
		Screen->DrawString(layer, x+1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
	else if(SUB_COUNTER_SHADOW==2){
		Screen->DrawString(layer, x+1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
	else if(SUB_COUNTER_SHADOW==3){
		Screen->DrawString(layer, x, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		
		Screen->DrawString(layer, x-1, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
	else if(SUB_COUNTER_SHADOW==4){
		Screen->DrawString(layer, x, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
	else if(SUB_COUNTER_SHADOW==5){
		Screen->DrawString(layer, x-1, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y-1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x-1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		Screen->DrawString(layer, x+1, y+1, SUB_COUNTER_FONT, SUB_COUNTER_C_OUTLINE, -1, TF_NORMAL, theNum, 128);
		
		Screen->DrawString(layer, x, y, SUB_COUNTER_FONT, SUB_COUNTER_C, -1, TF_NORMAL, theNum, 128);
	}
}

void SeedShooter_Update(){
	if(seedShooterGlobal[SSG_LASTDMAP]!=Game->GetCurDMap()||seedShooterGlobal[SSG_LASTSCREEN]!=Game->GetCurScreen()){
		for(int i=0; i<SSG__MAX_SLOT; i++){
			if(seedShooterGlobal[i*SSG__SIZE+SSG_COOLDOWN]>0){
				seedShooterGlobal[i*SSG__SIZE+SSG_COOLDOWN]--;
			}
		}
		if(seedShooterGlobal[SSG_SPECIALEXIT]){
			int scr[] = "SeedShooter_Seed_FFC";
			int scrid = Game->GetFFCScript(scr);
			int args[8] = {3, -1, Link->X, Link->Y, Link->Dir};
			RunFFCScript(scrid, args);
		}
		seedShooterGlobal[SSG_LASTDMAP] = Game->GetCurDMap();
		seedShooterGlobal[SSG_LASTSCREEN] = Game->GetCurScreen();
	}
	if(SUB_COUNTER_DRAW){
		int cr; int ab; int bb;
		int x; int y;
		ab = GetEquipmentA();
		cr = -1;
		if(ab==I_SEEDSHOOTER_EMBER)
			cr = CR_SEED_EMBER;
		else if(ab==I_SEEDSHOOTER_SCENT)
			cr = CR_SEED_SCENT;
		else if(ab==I_SEEDSHOOTER_PEGASUS)
			cr = CR_SEED_PEGASUS;
		else if(ab==I_SEEDSHOOTER_GALE)
			cr = CR_SEED_GALE;
		else if(ab==I_SEEDSHOOTER_MYSTERY)
			cr = CR_SEED_MYSTERY;
			
		if(ab==I_SEEDSATCHEL_EMBER)
			cr = CR_SEED_EMBER;
		else if(ab==I_SEEDSATCHEL_SCENT)
			cr = CR_SEED_SCENT;
		else if(ab==I_SEEDSATCHEL_PEGASUS)
			cr = CR_SEED_PEGASUS;
		else if(ab==I_SEEDSATCHEL_GALE)
			cr = CR_SEED_GALE;
		else if(ab==I_SEEDSATCHEL_MYSTERY)
			cr = CR_SEED_MYSTERY;
		
		if(cr>-1){
			x = SUB_A_BUTTON_POS_X;
			y = -56+SUB_A_BUTTON_POS_Y+16;
			SeedShooter_DrawInt(7, x, y, Game->Counter[cr]);
		}
			
		bb = GetEquipmentB();
		cr = -1;
		if(bb==I_SEEDSHOOTER_EMBER)
			cr = CR_SEED_EMBER;
		else if(bb==I_SEEDSHOOTER_SCENT)
			cr = CR_SEED_SCENT;
		else if(bb==I_SEEDSHOOTER_PEGASUS)
			cr = CR_SEED_PEGASUS;
		else if(bb==I_SEEDSHOOTER_GALE)
			cr = CR_SEED_GALE;
		else if(bb==I_SEEDSHOOTER_MYSTERY)
			cr = CR_SEED_MYSTERY;
			
		if(bb==I_SEEDSATCHEL_EMBER)
			cr = CR_SEED_EMBER;
		else if(bb==I_SEEDSATCHEL_SCENT)
			cr = CR_SEED_SCENT;
		else if(bb==I_SEEDSATCHEL_PEGASUS)
			cr = CR_SEED_PEGASUS;
		else if(bb==I_SEEDSATCHEL_GALE)
			cr = CR_SEED_GALE;
		else if(bb==I_SEEDSATCHEL_MYSTERY)
			cr = CR_SEED_MYSTERY;
			
		if(cr>-1){
			x = SUB_B_BUTTON_POS_X;
			y = -56+SUB_B_BUTTON_POS_Y+16;
			SeedShooter_DrawInt(7, x, y, Game->Counter[cr]);
		}
	}
	if(seedShooterGlobal[SSG_PEGASUSFRAMES]>0){
		if(seedShooterGlobal[SSG_PEGASUSFRAMES]%PEGASUS_SFX_FREQ==0)
			Game->PlaySound(SFX_PEGASUS_RUN);
		if(seedShooterGlobal[SSG_PEGASUSFRAMES]%8==0){
			lweapon trail = CreateLWeaponAt(LW_SEED, Link->X, Link->Y+8);
			trail->UseSprite(SPR_PEGASUS_DUST);
			trail->DeadState = trail->NumFrames*trail->ASpeed;
			trail->CollDetection = false;
		}
		LinkMovement_AddLinkSpeedBoost(SEED_PEGASUS_SPEEDBOOST_STEP);
		seedShooterGlobal[SSG_PEGASUSFRAMES]--;
	}
}

global script SeedShooter_Example{
	void run(){
		LinkMovement_Init();
		while(true){
			LinkMovement_Update1();
			SeedShooter_Update();
			Waitdraw();
			LinkMovement_Update2();
			Waitframe();
		}
	}
}