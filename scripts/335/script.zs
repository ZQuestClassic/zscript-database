const int ESTUSFLASK_INITIAL_CAPACITY = 5; //How many estus you can carry to start with
const int ESTUSFLASK_MAX_CAPACITY = 20; //The max estus flasks you can ever carry
const int ESTUSFLASK_UPGRADE_TIERS = 5; //How many times the flask can be upgraded (scales healing from ESTUSFLASK_HEALING to ESTUSFLASK_HEALING_MAX)

const int ESTUSFLASK_HEALING = 48; //How much HP the flask heals minimum (16 = one heart)
const int ESTUSFLASK_HEALING_MAX = 80; //How much HP the flask heals maximum
const int ESTUSFLASK_DRINK_TIME = 60; //How many frames it takes to drink a flask and start the healing
const int ESTUSFLASK_HEAL_TIME = 40; //How many frames it takes for the flask to heal

const int ESTUSFLASK_REFILL_ON_F6 = 1; //If 1, the player gets all their flasks back on death/F6
const int ESTUSFLASK_HEALING_IS_PERCENT = 0; //If 1, healing from the estus flask is a percentage of max HP
const int ESTUSFLASK_GETTING_HIT_INTERRUPTS_HEALING = 1; //If 1, getting hit will interrupt the healing even after you finish drinking
const int ESTUSFLASK_CAN_DOUBLE_DRINK = 1; //If 1, using consecutive flasks will make the animation faster
const int ESTUSFLASK_CAN_WASTE = 0; //If 1, getting hit while drinking a flask will waste the flask
const int ESTUSFLASK_BONFIRE_HEALS = 1; //If 1, using a bonfire will fully heal you
const int ESTUSFLASK_BONFIRE_RESETENEMIES = 1; //If 1, using the bonfire will try to reset GuyCount[]
const int ESTUSFLASK_BONFIRE_SETS_CONTINUE = 1; //If 1, using the bonfire will set the continue point
const int ESTUSFLASK_BONFIRE_OVERRIDES_CONTINUE = 0; //If 1, only bonfires will be able to set the continue point

//Tile and CSet for the animation of Link drinking from the estus flask
const int TIL_ESTUSFLASK_DRINK = 540;
const int CS_ESTUSFLASK_DRINK = 6; 
//How many animation frames the drinking animation lasts for
const int FRAMES_ESTUSFLASK_DRINK = 8; 

//Tile for the estus flask item
const int TIL_ESTUSFLASK_ITEM = 520;
//Number of tiles following TIL_ESTUSFLASK_ITEM marking how much is left, going from empty to full
const int STATES_ESTUSFLASK_ITEM = 6;

//Layer, combo, and cset for A button prompts
const int LAYER_APROMPT = 4; 
const int CMB_APROMPT = 900; 
const int CS_APROMPT = 8;

void DrawAPrompt(){
	if(CMB_APROMPT>0)
		Screen->FastCombo(LAYER_APROMPT, Link->X, Link->Y-16, CMB_APROMPT, CS_APROMPT, 128);
}

//Sprite in weapons/misc for particles drawn while healing
const int SPR_ESTUSFLASK_PARTICLES = 88;

//Sound when Link drinks an estus flask
const int SFX_ESTUSFLASK_DRINK = 32; 
//Healing sound after drinking a flask
const int SFX_ESTUSFLASK_HEAL = 56; 
//Sound when refilling estus flasks
const int SFX_ESTUSFLASK_REFILL = 25;

//Counter for the current number of estus flasks (Script 3 by default)
const int CR_ESTUSFLASK_COUNT = 9;
//Counter for the current upgrade level of the estus flask (Script 4 by default)
const int CR_ESTUSFLASK_UPGRADE = 10;

const int _EF_HEALHP = 0;
const int _EF_HEALHP2 = 1;
const int _EF_HEALHPPERFRAME = 2;
const int _EF_DRINKTIMER = 3;
const int _EF_FIRSTLOAD = 4;
const int _EF_MAXREFILL = 5;
const int _EF_UPGRADETIER = 6;
const int _EF_LASTMAP = 7;
const int _EF_CONTINUEDMAP = 8;
const int _EF_CONTINUESCREEN = 9;
const int _EF_MAXDRINKTIME = 10;
const int _EF_DOUBLEDRINKTIMER = 11;
const int _EF_RESETMAP = 20; //First of map enemy spawn reset indices (20-275)
int EstusFlask[512];

void EstusFlask_Init(){
	//On the first load, set the capacity maximum for the flasks
	if(!EstusFlask[_EF_FIRSTLOAD]){
		Game->MCounter[CR_ESTUSFLASK_COUNT] = ESTUSFLASK_MAX_CAPACITY;
		EstusFlask[_EF_MAXREFILL] = ESTUSFLASK_INITIAL_CAPACITY;
		
		EstusFlask[_EF_CONTINUEDMAP] = Game->GetCurMap();
		EstusFlask[_EF_CONTINUESCREEN] = Game->GetCurDMapScreen();
		
		EstusFlask[_EF_FIRSTLOAD] = 1;
	}
	
	if(ESTUSFLASK_REFILL_ON_F6){
		Game->Counter[CR_ESTUSFLASK_COUNT] = EstusFlask[_EF_MAXREFILL];
	}
	
	EstusFlask_RefreshTiles();
}

void EstusFlask_Update(){
	int i; int j;
	//Drinking animation
	if(EstusFlask[_EF_DRINKTIMER]>0){
		i = EstusFlask[_EF_MAXDRINKTIME]-EstusFlask[_EF_DRINKTIMER];
		EstusFlask[_EF_DRINKTIMER]--;
		//If the timer runs out, make Link visible and proceed to the healing
		if(EstusFlask[_EF_DRINKTIMER]==0){
			Link->Invisible = false;
			
			Game->PlaySound(SFX_ESTUSFLASK_HEAL);
			EstusFlask[_EF_DOUBLEDRINKTIMER] = 32;
			//If flasks can be wasted, the counter has been decremented, otherwise do it here
			if(!ESTUSFLASK_CAN_WASTE){
				Game->Counter[CR_ESTUSFLASK_COUNT]--;
			}
		}
		//Otherwise make Link invisible and draw his tiles
		else{
			Link->Invisible = true;
			
			//If Link gets hit, make him visible and interrupt the animation
			if(Link->Action==LA_GOTHURTLAND){
				Link->Invisible = false;
				EstusFlask[_EF_DRINKTIMER] = 0;
				EstusFlask[_EF_HEALHP] = 0;
				EstusFlask[_EF_HEALHPPERFRAME] = 0;
				EstusFlask[_EF_DOUBLEDRINKTIMER] = 0;
			}
			//If he hasn't been hit, draw him
			else{
				int layer = 2;
				if(ScreenFlag(1, 4)) //Layer -2
					layer = 1;
					
				j = Clamp(Floor(i/(EstusFlask[_EF_MAXDRINKTIME]/FRAMES_ESTUSFLASK_DRINK)), 0, EstusFlask[_EF_MAXDRINKTIME]-1);
				Screen->FastTile(layer, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset, TIL_ESTUSFLASK_DRINK+j, CS_ESTUSFLASK_DRINK, 128);
				NoAction();
			}
		}
	}
	else if(EstusFlask[_EF_HEALHP]>0){
		//If Link gets hit or caps out, end the healing
		if(Link->HP>=Link->MaxHP||(ESTUSFLASK_GETTING_HIT_INTERRUPTS_HEALING&&Link->Action==LA_GOTHURTLAND)){
			EstusFlask[_EF_DRINKTIMER] = 0;
			EstusFlask[_EF_HEALHP] = 0;
			EstusFlask[_EF_HEALHPPERFRAME] = 0;
			if(ESTUSFLASK_GETTING_HIT_INTERRUPTS_HEALING&&Link->Action==LA_GOTHURTLAND)
				EstusFlask[_EF_DOUBLEDRINKTIMER] = 0;
		}
		else{
			//Subtract HP each frame being healed from the total frames
			//Get the difference minus decmials to determine how much to heal Link
			j = Floor(EstusFlask[_EF_HEALHP]);
			EstusFlask[_EF_HEALHP] = Max(EstusFlask[_EF_HEALHP]-EstusFlask[_EF_HEALHPPERFRAME], 0);
			int healAmount = j-Floor(EstusFlask[_EF_HEALHP]);
			
			Link->HP += healAmount;
			
			//Draw particles around Link if applicable
			if(SPR_ESTUSFLASK_PARTICLES){
				lweapon particle = CreateLWeaponAt(LW_SCRIPT10, Link->X+Rand(-8, 8), Link->Y+Rand(-8, 8));
				particle->UseSprite(SPR_ESTUSFLASK_PARTICLES);
				particle->DeadState = particle->ASpeed*particle->NumFrames;
				particle->CollDetection = false;
				particle->HitYOffset = -1000;
			}
		}
	}
	
	//Backup heal (Used when double drinking)
	if(EstusFlask[_EF_HEALHP2]>0){
		//If Link gets hit or caps out, end the healing
		if(Link->HP>=Link->MaxHP||(ESTUSFLASK_GETTING_HIT_INTERRUPTS_HEALING&&Link->Action==LA_GOTHURTLAND)){
			EstusFlask[_EF_HEALHP2] = 0;
		}
		else{
			//Subtract HP each frame being healed from the total frames
			//Get the difference minus decmials to determine how much to heal Link
			j = Floor(EstusFlask[_EF_HEALHP2]);
			EstusFlask[_EF_HEALHP2] = Max(EstusFlask[_EF_HEALHP2]-EstusFlask[_EF_HEALHPPERFRAME], 0);
			int healAmount = j-Floor(EstusFlask[_EF_HEALHP2]);
			
			Link->HP += healAmount;
			
			//Draw particles around Link if applicable
			if(SPR_ESTUSFLASK_PARTICLES){
				lweapon particle = CreateLWeaponAt(LW_SCRIPT10, Link->X+Rand(-8, 8), Link->Y+Rand(-8, 8));
				particle->UseSprite(SPR_ESTUSFLASK_PARTICLES);
				particle->DeadState = particle->ASpeed*particle->NumFrames;
				particle->CollDetection = false;
				particle->HitYOffset = -1000;
			}
		}
	}
	
	if(EstusFlask[_EF_DOUBLEDRINKTIMER]>0&&EstusFlask[_EF_DRINKTIMER]<=0)
		EstusFlask[_EF_DOUBLEDRINKTIMER]--;
	
	//Reset all guycounts if a bonfire has been used
	j = Game->GetCurMap();
	if(EstusFlask[_EF_LASTMAP]!=j){
		if(EstusFlask[_EF_RESETMAP+j]){
			for(i=0; i<=0x7F; i++){
				Game->GuyCount[i] = 10;
			}
			EstusFlask[_EF_RESETMAP+j] = 0;
		}
	}
	EstusFlask[_EF_LASTMAP] = j;
	
	//If bonfires overwrite continue points, set them every frame
	if(ESTUSFLASK_BONFIRE_OVERRIDES_CONTINUE){
		Game->LastEntranceDMap = EstusFlask[_EF_CONTINUEDMAP];
		Game->LastEntranceScreen = EstusFlask[_EF_CONTINUESCREEN];
		Game->ContinueDMap = EstusFlask[_EF_CONTINUEDMAP];
		Game->ContinueScreen = EstusFlask[_EF_CONTINUESCREEN];
	}
	
	//Update the estus flask tile to suit how many you have
	EstusFlask_RefreshTiles();
}

void EstusFlask_RefreshTiles(){
	if(TIL_ESTUSFLASK_ITEM>0&&STATES_ESTUSFLASK_ITEM>=2){
		int st = 0;
		if(Game->Counter[CR_ESTUSFLASK_COUNT]>0){
			st = Clamp(Round((Game->Counter[CR_ESTUSFLASK_COUNT]/EstusFlask[_EF_MAXREFILL])*(STATES_ESTUSFLASK_ITEM-1)), 1, STATES_ESTUSFLASK_ITEM-1);
		}
		
		CopyTile(TIL_ESTUSFLASK_ITEM+1+st, TIL_ESTUSFLASK_ITEM);
	}
}

//Put this script as the action script on the estus flask item
item script EstusFlask_Use{
	void run(){
		if(Game->Counter[CR_ESTUSFLASK_COUNT]>0){
			//Calculate how much to heal
			int baseHeal = ESTUSFLASK_HEALING;
			if(ESTUSFLASK_UPGRADE_TIERS>0){
				if(Game->Counter[CR_ESTUSFLASK_UPGRADE]>0){
					int addedHealth = Floor((ESTUSFLASK_HEALING_MAX-ESTUSFLASK_HEALING)*(Game->Counter[CR_ESTUSFLASK_UPGRADE]/ESTUSFLASK_UPGRADE_TIERS));
					baseHeal += addedHealth;
				}
			}
			
			//Get percentage of Link's max HP if applicable
			int healAmount = baseHeal;
			if(ESTUSFLASK_HEALING_IS_PERCENT){
				healAmount = Clamp(Round(Link->HP*(baseHeal*0.01)), 0, Link->MaxHP);
			}
			
			if(EstusFlask[_EF_DRINKTIMER]<=0&&EstusFlask[_EF_HEALHP]<=0&&EstusFlask[_EF_DOUBLEDRINKTIMER]<=0){
				Game->PlaySound(SFX_ESTUSFLASK_DRINK);
				//Set how much to heal and start drinking animation
				EstusFlask[_EF_HEALHP] = healAmount;
				EstusFlask[_EF_HEALHPPERFRAME] = healAmount/ESTUSFLASK_HEAL_TIME;
				EstusFlask[_EF_MAXDRINKTIME] = ESTUSFLASK_DRINK_TIME;
				EstusFlask[_EF_DRINKTIMER] = EstusFlask[_EF_MAXDRINKTIME];
				
				//If flasks can be wasted, decrement the counter here, otherwise do it in the global
				if(ESTUSFLASK_CAN_WASTE){
					Game->Counter[CR_ESTUSFLASK_COUNT]--;
				}
			}
			//If already drunk an estus flask, make drinking a second one immediately after go faster
			else if(ESTUSFLASK_CAN_DOUBLE_DRINK&&EstusFlask[_EF_DRINKTIMER]<=0){
				Game->PlaySound(SFX_ESTUSFLASK_DRINK);
				//Set how much to heal and start drinking animation
				EstusFlask[_EF_HEALHP2] += EstusFlask[_EF_HEALHP];
				EstusFlask[_EF_HEALHP] = healAmount;
				EstusFlask[_EF_HEALHPPERFRAME] = healAmount/ESTUSFLASK_HEAL_TIME;
				EstusFlask[_EF_MAXDRINKTIME] = Floor(ESTUSFLASK_DRINK_TIME/2);
				EstusFlask[_EF_DRINKTIMER] = EstusFlask[_EF_MAXDRINKTIME];
				
				//If flasks can be wasted, decrement the counter here, otherwise do it in the global
				if(ESTUSFLASK_CAN_WASTE){
					Game->Counter[CR_ESTUSFLASK_COUNT]--;
				}
			}
		}
	}
}

//Put this script as the pickup script on items that raise your estus flask capacity
//D0: String to play on pickup
//D1: How much to increase capacity by
item script EstusFlask_CapacityUpgrade{
	void run(int str, int amount){
		if(amount==0)
			amount = 1;
		if(str>0)
			Screen->Message(str);
		EstusFlask[_EF_MAXREFILL] = Min(EstusFlask[_EF_MAXREFILL]+amount, ESTUSFLASK_MAX_CAPACITY);
		Game->Counter[CR_ESTUSFLASK_COUNT] = Min(Game->Counter[CR_ESTUSFLASK_COUNT]+amount, ESTUSFLASK_MAX_CAPACITY);
	}
}

global script EstusFlask_Example{
	void run(){
		EstusFlask_Init();
		while(true){
			EstusFlask_Update();
			Waitdraw();
			Waitframe();
		}
	}
}



ffc script EstusFlask_Bonfire{
	void run(){
		int i;
		while(true){
			bool canUse;
			if(Link->X>=this->X-8&&Link->X<=this->X+8&&Link->Y>=this->Y-16&&Link->Y<=this->Y&&Link->Dir==DIR_DOWN)
				canUse = true;
			if(Link->X>=this->X-8&&Link->X<=this->X+8&&Link->Y>=this->Y&&Link->Y<=this->Y+8&&Link->Dir==DIR_UP)
				canUse = true;
			if(Link->X>=this->X-16&&Link->X<=this->X&&Link->Y>=this->Y-12&&Link->Y<=this->Y+4&&Link->Dir==DIR_RIGHT)
				canUse = true;
			if(Link->X>=this->X&&Link->X<=this->X+16&&Link->Y>=this->Y-12&&Link->Y<=this->Y+4&&Link->Dir==DIR_LEFT)
				canUse = true;
			if(canUse){
				DrawAPrompt();
				if(Link->PressA){
					Link->PressA = false;
					Link->InputA = false;
					NoAction();
					Game->PlaySound(SFX_ESTUSFLASK_REFILL);
					
					if(ESTUSFLASK_BONFIRE_HEALS){
						int healAmount = Link->MaxHP-Link->HP;
						EstusFlask[_EF_HEALHP] = healAmount;
						EstusFlask[_EF_HEALHPPERFRAME] = healAmount/30;
						EstusFlask[_EF_DRINKTIMER] = 0;
					}
					
					if(ESTUSFLASK_BONFIRE_RESETENEMIES){
						EstusFlask[_EF_LASTMAP] = -1;
						for(i=0; i<=255; i++){
							EstusFlask[_EF_RESETMAP+i] = 1;
						}
					}
					
					if(ESTUSFLASK_BONFIRE_SETS_CONTINUE||ESTUSFLASK_BONFIRE_OVERRIDES_CONTINUE){
						EstusFlask[_EF_CONTINUEDMAP] = Game->GetCurDMap();
						EstusFlask[_EF_CONTINUESCREEN]= Game->GetCurDMapScreen();
						
						Game->LastEntranceDMap = Game->GetCurDMap();
						Game->LastEntranceScreen = Game->GetCurDMapScreen();
						Game->ContinueDMap = Game->GetCurDMap();
						Game->ContinueScreen = Game->GetCurDMapScreen();
					}
					
					if(Game->Counter[CR_ESTUSFLASK_COUNT]<EstusFlask[_EF_MAXREFILL]){
						for(i=0; Game->Counter[CR_ESTUSFLASK_COUNT]<EstusFlask[_EF_MAXREFILL]; i++){
							Game->Counter[CR_ESTUSFLASK_COUNT] = Min(Game->Counter[CR_ESTUSFLASK_COUNT]+1, EstusFlask[_EF_MAXREFILL]);
							WaitNoAction(4);
						}
						WaitNoAction(20);
					}
					else{
						WaitNoAction(20);
					}
					while(EstusFlask[_EF_HEALHP]>0){
						WaitNoAction();
					}
				}
			}
			Waitframe();
		}
	}
}