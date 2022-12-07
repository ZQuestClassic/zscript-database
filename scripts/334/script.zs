const int DEATHPENALTY_RUPEE_LOSS_PERCENT = 25; //Percent of Link's current rupees (0-100) lost on death
const int DEATHPENALTY_NUM_RUPEEBAGS = 4; //How many rupee bags to create
const int DEATHPENALTY_HP_REDUCTION_PERCENT = 0; //If >0 Link's max HP will be reduced by up to this percent (0-100) on death.
const int DEATHPENALTY_HP_REDUCTION_TIERS = 5; //How many tiers of max HP reductions there are

const int DEATHPENALTY_RUPEE_LOSS_IS_FIXED = 0; //If 1, the amount of rupees lost on death is a fixed value instead of a percentage
const int DEATHPENALTY_ACTIVE_ON_F6 = 0; //If 1, the death penalty will happen even if you F6
const int DEATHPENALTY_RESET_F6_HP = 0; //If 1, Link's HP won't be reset on death
const int DEATHPENALTY_MAGNETIZE_RUPEEBAGS = 1; //If 1, rupee bags will move towards Link when he gets close
const int DEATHPENALTY_RUPEEBAGS_USE_DCOUNTER = 1; //If 1, rupee bags will refill rupees gradually, else it's instant
const int DEATHPENALTY_FAST_RUPEE_FILL = 1; //If 1, Link's rupees will fill faster when gaining large amounts at once
const int DEATHPENALTY_HP_REDUCTION_ONLY_FULL_HEARTS = 0; //If 1, HP reduction will only work in full heart increments
const int DEATHPENALTY_RUPEEBAG_REVERSES_HP_REDUCTION = 1; //If 1, picking up a rupee bag from a death that reduced HP will undo the reduction
const int DEATHPENALTY_EXTRA_COUNTER_PENALTY_BASED_ON_MAX = 0; //If 1, counter penalties (see DeathPenalty_GiveTakeCounters() function) take based on the max value of the counter instead of the current
const int DEATHPENALTY_SPECIAL_DEATH_OVERRIDES_OLD_RUPEEBAGS = 1; //If 1, dying to a scripted object that doesn't allow rupee bags will still remove old rupee bags

//Sound when Link picks up a rupee bag
const int SFX_DEATHPENALTY_RUPEEBAG = 25;
//Sound when Link uses a cure curing consumable
const int SFX_DEATHPENALTY_UNCURSE_CONSUMABLE = 25;

//Combo and CSet for the rupee bag
const int CMB_DEATHPENALTY_RUPEEBAG = 900;
const int CS_DEATHPENALTY_RUPEEBAG = 5;

//Counter for the current level of HP reduction curse. 0 for none.
const int CR_DEATHPENALTY_HP_REDUCTION = 7; //Script 1 by default
//Counter for the number of held HP reduction curing items
const int CR_DEATHPENALTY_HP_REDUCTION_CURES = 8; //Script 2 by default

const int _DP_HASDIED = 0;
const int _DP_ANIM = 1;
const int _DP_FIRSTLOAD = 2;
const int _DP_RUPEEBAG_MAP = 3;
const int _DP_RUPEEBAG_SCREEN = 4;
const int _DP_HPREDUCTION_TIER = 5;
const int _DP_LASTX = 6;
const int _DP_LASTY = 7;
const int _DP_LASTHP = 8;
const int _DP_LASTMAP = 9;
const int _DP_LASTSCREEN = 10;
const int _DP_LOADEDSAVE = 11;
const int _DP_RUPEEBAG_HASCURSE = 12;
const int _DP_RUPEEBAG_HASITEMS = 13;
const int _DP_DONTSPAWNBAGS = 14;
const int _DP_RUPEEBAG_X = 20;
const int _DP_RUPEEBAG_Y = 21;
const int _DP_RUPEEBAG_AMOUNT = 22;

const int _DP_TAKENITEMS = 100; //First of taken item indices (100-355)

const int _DP_TAKENCOUNTERS = 400; //First of taken counter indices (400-431)
int DeathPenalty[432];

void DeathPenalty_Init(){
	int i; int j; int k;
	int x; int y;
	
	int numRupeeBags = Clamp(DEATHPENALTY_NUM_RUPEEBAGS, 1, 20);
	int rupeeLossPercent = Clamp(DEATHPENALTY_RUPEE_LOSS_PERCENT, 0, 100)*0.01;

	if(DeathPenalty[_DP_LOADEDSAVE]){
		DeathPenalty[_DP_LOADEDSAVE] = 0;
	}
	else if(!DeathPenalty[_DP_FIRSTLOAD]){
		DeathPenalty[_DP_FIRSTLOAD] = 1;
	}
	//If penalties should activate and it isn't the first load
	else if(DeathPenalty[_DP_HASDIED]||DEATHPENALTY_ACTIVE_ON_F6){
		//Add draining rupees to the main counter
		Game->Counter[CR_RUPEES] += Game->DCounter[CR_RUPEES];
	
		int rupeeVals[20];
		int lostRupees = Ceiling(Game->Counter[CR_RUPEES]*rupeeLossPercent);
		if(DEATHPENALTY_RUPEE_LOSS_IS_FIXED)
			lostRupees = DEATHPENALTY_RUPEE_LOSS_PERCENT;
		
		int lastRupees = Game->Counter[CR_RUPEES];
		Game->Counter[CR_RUPEES] = Max(Game->Counter[CR_RUPEES]-lostRupees, 0);
		lostRupees = Abs(lastRupees-Game->Counter[CR_RUPEES]);
		
		int rupeesPerBag = lostRupees/numRupeeBags;
		
		//Set rupee values to a fraction of the whole
		for(i=0; i<numRupeeBags; i++){
			rupeeVals[i] = Floor(rupeesPerBag);
		}
		//If it doesn't divide evenly, add 1 rupee to the first bag
		if(rupeesPerBag-Floor(rupeesPerBag)>0)
			rupeeVals[0] += lostRupees-Floor(rupeesPerBag)*numRupeeBags;
			
		//Move some rupees between bags at random
		for(i=0; i<numRupeeBags-1; i++){
			k = Floor(rupeesPerBag*(Rand(5, 20)*0.01));
			if(Rand(2)){
				rupeeVals[i] -= k;
				rupeeVals[i+1] += k;
			}
			else{
				rupeeVals[i] += k;
				rupeeVals[i+1] -= k;
			}
		}
		if(numRupeeBags>1){
			k = Floor(rupeesPerBag*(Rand(5, 20)*0.01));
			if(Rand(2)){
				rupeeVals[0] -= k;
				rupeeVals[numRupeeBags-1] += k;
			}
			else{
				rupeeVals[0] += k;
				rupeeVals[numRupeeBags-1] -= k;
			}
		}
	
		if(DEATHPENALTY_NUM_RUPEEBAGS>0){
			if(!DeathPenalty[_DP_DONTSPAWNBAGS]){
				//Create the rupee bags
				for(i=0; i<numRupeeBags; i++){
					if(numRupeeBags>1){
						j = Rand(360);
						k = Rand(8, 40);
						
						x = DeathPenalty[_DP_LASTX] + VectorX(k, j);
						y = DeathPenalty[_DP_LASTY] + VectorY(k, j);
					}
					else{
						x = DeathPenalty[_DP_LASTX];
						y = DeathPenalty[_DP_LASTY];
					}
					DeathPenalty[_DP_RUPEEBAG_X+i*3] = x;
					DeathPenalty[_DP_RUPEEBAG_Y+i*3] = y;
					if(DEATHPENALTY_RUPEE_LOSS_PERCENT)
						DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3] = rupeeVals[i];
					else
						DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3] = 1;
				}
			}
		}
		//Script related event where bags are prevented from spawning
		if(DeathPenalty[_DP_DONTSPAWNBAGS]){
			if(DEATHPENALTY_SPECIAL_DEATH_OVERRIDES_OLD_RUPEEBAGS){
				//Remove old rupee bags
				for(i=0; i<numRupeeBags; i++){
					DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3] = 0;
				}
			}
			DeathPenalty[_DP_DONTSPAWNBAGS] = 0;
		}
		
		DeathPenalty[_DP_RUPEEBAG_MAP] = DeathPenalty[_DP_LASTMAP];
		DeathPenalty[_DP_RUPEEBAG_SCREEN] = DeathPenalty[_DP_LASTSCREEN];
		
		//Handle the HP curse
		DeathPenalty[_DP_RUPEEBAG_HASCURSE] = 0;
		if(DEATHPENALTY_HP_REDUCTION_PERCENT>0){
			//Mark if rupee bag is able to undo the curse
			if(DEATHPENALTY_RUPEEBAG_REVERSES_HP_REDUCTION&&DeathPenalty[_DP_HPREDUCTION_TIER]<DEATHPENALTY_HP_REDUCTION_TIERS)
				DeathPenalty[_DP_RUPEEBAG_HASCURSE] = 1;
			
			//Increase HP reduction penalty
			DeathPenalty[_DP_HPREDUCTION_TIER] = Clamp(DeathPenalty[_DP_HPREDUCTION_TIER]+1, 0, DEATHPENALTY_HP_REDUCTION_TIERS);
		}
		
		//Take items on death
		DeathPenalty_GiveTakeItems(true);
		
		//Take counters on death
		DeathPenalty_GiveTakeCounters(true);
		
		//Keep HP on F6
		if(DEATHPENALTY_RESET_F6_HP){
			if(!DeathPenalty[_DP_HASDIED]&&DeathPenalty[_DP_LASTHP]>0)
				Link->HP = DeathPenalty[_DP_LASTHP];
		}
		
	}
	
	DeathPenalty[_DP_LASTX] = Link->X;
	DeathPenalty[_DP_LASTY] = Link->Y;
}

void DeathPenalty_Update(){
	if(Link->Action==LA_SCROLLING)
		return;
	
	int i; int j; int k;
	int x; int y;
	
	int numRupeeBags = Clamp(DEATHPENALTY_NUM_RUPEEBAGS, 1, 20);
	int rupeeLossPercent = Clamp(DEATHPENALTY_RUPEE_LOSS_PERCENT, 0, 100)*0.01;
	int hpReductionPercent = Clamp(DEATHPENALTY_HP_REDUCTION_PERCENT, 0, 99)*0.01;
	
	//If Link is on the same screen as the rupee bags
	if(Game->GetCurMap()==DeathPenalty[_DP_RUPEEBAG_MAP]&&Game->GetCurScreen()==DeathPenalty[_DP_RUPEEBAG_SCREEN]&&Link->HP>0){
		for(i=0; i<numRupeeBags; i++){
			//Only draw bags with rupees in them
			if(DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3]>0){
				x = DeathPenalty[_DP_RUPEEBAG_X+i*3];
				y = DeathPenalty[_DP_RUPEEBAG_Y+i*3];
				
				//Detect Link collisions
				if(RectCollision(Link->X+Link->HitXOffset+4, Link->Y+Link->HitYOffset+4, Link->X+Link->HitXOffset+11, Link->Y+Link->HitYOffset+11, x+4, y+4, x+11, y+11)){
					if(Link->Z==0&&!Link->Invisible){
						Game->PlaySound(SFX_DEATHPENALTY_RUPEEBAG);
						if(DEATHPENALTY_RUPEE_LOSS_PERCENT){
							if(DEATHPENALTY_RUPEEBAGS_USE_DCOUNTER){
								Game->DCounter[CR_RUPEES] += DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3];
							}
							else{
								Game->Counter[CR_RUPEES] += DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3];
							}
						}
						
						DeathPenalty[_DP_RUPEEBAG_AMOUNT+i*3] = 0;
						
						if(DeathPenalty[_DP_RUPEEBAG_HASCURSE]){
							DeathPenalty[_DP_HPREDUCTION_TIER] = Clamp(DeathPenalty[_DP_HPREDUCTION_TIER]-1, 0, DEATHPENALTY_HP_REDUCTION_TIERS);
							DeathPenalty[_DP_RUPEEBAG_HASCURSE] = 0;
						}
						
						if(DeathPenalty[_DP_RUPEEBAG_HASITEMS]){
							DeathPenalty_GiveTakeItems(false);
							DeathPenalty_GiveTakeCounters(false);
							DeathPenalty[_DP_RUPEEBAG_HASITEMS] = 0;
						}
					}
				}
				
				//Magnetize effect
				if(DEATHPENALTY_MAGNETIZE_RUPEEBAGS){
					if(Distance(Link->X, Link->Y, x, y)<48){
						j = Angle(x, y, Link->X, Link->Y);
						k = 24/Max(1, Distance(Link->X, Link->Y, x, y));
						
						DeathPenalty[_DP_RUPEEBAG_X+i*3] += VectorX(k, j);
						DeathPenalty[_DP_RUPEEBAG_Y+i*3] += VectorY(k, j);
					}
				}
				
				Screen->FastCombo(4, x, y, CMB_DEATHPENALTY_RUPEEBAG, CS_DEATHPENALTY_RUPEEBAG, 128);
			}
		}
	}

	//Max HP penalty
	if(DEATHPENALTY_HP_REDUCTION_PERCENT){
		i = Floor((DeathPenalty[_DP_HPREDUCTION_TIER]/DEATHPENALTY_HP_REDUCTION_TIERS)*hpReductionPercent*Link->HP);
		if(DEATHPENALTY_HP_REDUCTION_ONLY_FULL_HEARTS)
			i = Round(i/16)*16;
		Link->HP = Min(Link->HP, Link->MaxHP-i);
		
		if(CR_DEATHPENALTY_HP_REDUCTION>0){
			Game->Counter[CR_DEATHPENALTY_HP_REDUCTION] = DeathPenalty[_DP_HPREDUCTION_TIER];
		}
	}
	
	//Track HP to undo on F6
	DeathPenalty[_DP_LASTHP] = Link->HP;
	
	//Keep track of if Link died
	if(Link->HP<=0){
		DeathPenalty[_DP_HASDIED] = 1;
	}
	else if(DeathPenalty[_DP_HASDIED]){
		DeathPenalty[_DP_HASDIED] = 0;
	}
	
	//Fast draining rupees
	if(DEATHPENALTY_FAST_RUPEE_FILL){
		int dc = Abs(Game->DCounter[CR_RUPEES]);
		int sign = Sign(Game->DCounter[CR_RUPEES]);
		if(dc>=1000){
			Game->Counter[CR_RUPEES] += 100*sign;
			Game->DCounter[CR_RUPEES] -= 100*sign;
		}
		else if(dc>=500){
			Game->Counter[CR_RUPEES] += 50*sign;
			Game->DCounter[CR_RUPEES] -= 50*sign;
		}
		else if(dc>=200){
			Game->Counter[CR_RUPEES] += 20*sign;
			Game->DCounter[CR_RUPEES] -= 20*sign;
		}
		else if(dc>=100){
			Game->Counter[CR_RUPEES] += 10*sign;
			Game->DCounter[CR_RUPEES] -= 10*sign;
		}
		else if(dc>=50){
			Game->Counter[CR_RUPEES] += 5*sign;
			Game->DCounter[CR_RUPEES] -= 5*sign;
		}
		else if(dc>=20){
			Game->Counter[CR_RUPEES] += 2*sign;
			Game->DCounter[CR_RUPEES] -= 2*sign;
		}
	}
	
	DeathPenalty[_DP_LASTX] = Link->X;
	DeathPenalty[_DP_LASTY] = Link->Y;
	DeathPenalty[_DP_LASTMAP] = Game->GetCurMap();
	DeathPenalty[_DP_LASTSCREEN] = Game->GetCurScreen();
	
	//If the script is set to not spawn bags and Link isn't actually dead that frame, undo that
	if(DeathPenalty[_DP_DONTSPAWNBAGS]&&Link->HP>0)
		DeathPenalty[_DP_DONTSPAWNBAGS] = 0;
}

void DeathPenalty_GiveTakeItems(bool take){
	int i;
	int ItemsToTake[256];
	
	//Examples
	//ItemsToTake[17] = 2; //EXAMPLE: Blue ring - Taken forever
	//ItemsToTake[6] = 1; //EXAMPLE: Sword 2 - Can be regained
	
	if(take){
		for(i=0; i<256; i++){
			DeathPenalty[_DP_TAKENITEMS+i] = 0;
			if(ItemsToTake[i]){
				if(Link->Item[i]&&ItemsToTake[i]==1){
					DeathPenalty[_DP_TAKENITEMS+i] = 1;
					DeathPenalty[_DP_RUPEEBAG_HASITEMS] = 1;
				}
				Link->Item[i] = false;
			}
		}
	}
	else{
		for(i=0; i<256; i++){
			if(DeathPenalty[_DP_TAKENITEMS+i]){
				Link->Item[i] = true;
				DeathPenalty[_DP_TAKENITEMS+i] = 0;
			}
		}
	}
}

void DeathPenalty_GiveTakeCounters(bool take){
	int i;
	if(take){
		int counterBehavior[32];
		int counterPercent[32];
		int tc[2] = {counterBehavior, counterPercent};
		
		//Examples
		//DeathPenalty_TakeCounter_Percent(tc, CR_ARROWS, false, 50); //EXAMPLE: Takes 50% of arrows, can be regained
		//DeathPenalty_TakeCounter_Exact(tc, CR_BOMBS, true, 5); //EXAMPLE: Takes 5 bombs, can't be regained
		
		for(i=0; i<32; i++){
			if(counterBehavior[i]){
				int amountTaken = Abs(counterPercent[i]);
				//If counter percent is positive, take a percentage of the counter. Otherwise takea fixed value
				if(counterPercent[i]>0){
					if(DEATHPENALTY_EXTRA_COUNTER_PENALTY_BASED_ON_MAX)
						amountTaken = Ceiling(Game->MCounter[i]*(counterPercent[i]*0.01));
					else
						amountTaken = Ceiling(Game->Counter[i]*(counterPercent[i]*0.01));
				}
				int oldAmount = Game->Counter[i];
				Game->Counter[i] = Max(Game->Counter[i]-amountTaken, 0);
				//If the taken counter items can be regained
				if(counterBehavior[i]==1){
					//Store how much was taken from the counter
					DeathPenalty[_DP_TAKENCOUNTERS+i] = Abs(oldAmount-Game->Counter[i]);
					DeathPenalty[_DP_RUPEEBAG_HASITEMS] = 1;
				}
			}
		}
	}
	else{
		for(i=0; i<32; i++){
			if(DeathPenalty[_DP_TAKENCOUNTERS+i]){
				Game->Counter[i] += DeathPenalty[_DP_TAKENCOUNTERS+i];
				DeathPenalty[_DP_TAKENCOUNTERS+i] = 0;
			}
		}
	}
}

void DeathPenalty_TakeCounter_Percent(int tc, int whichCounter, bool permanent, int percent){
	int counterBehavior = tc[0];
	int counterPercent = tc[1];
	
	counterBehavior[whichCounter] = 1;
	if(permanent)
		counterBehavior[whichCounter] = 2;
	counterPercent[whichCounter] = Abs(percent);
}

void DeathPenalty_TakeCounter_Exact(int tc, int whichCounter, bool permanent, int amount){
	int counterBehavior = tc[0];
	int counterPercent = tc[1];
	
	counterBehavior[whichCounter] = 1;
	if(permanent)
		counterBehavior[whichCounter] = 2;
	counterPercent[whichCounter] = -Abs(amount);
}

//Disables rupee bags for one frame
void DeathPenalty_DisableRupeeBags(){
	if(Link->HP<=0)
		DeathPenalty[_DP_DONTSPAWNBAGS] = 1;
}

//This script is for items that when picked up remove the HP curse
item script DeathPenalty_UncursePickup{
	void run(int msg){
		if(msg>0)
			Screen->Message(msg);
		DeathPenalty[_DP_HPREDUCTION_TIER] = 0;
	}
}

//This script is for items that when used remove the HP curse
item script DeathPenalty_UncurseConsumable{
	void run(){
		if(Game->Counter[CR_DEATHPENALTY_HP_REDUCTION_CURES]>0&&DeathPenalty[_DP_HPREDUCTION_TIER]>0){
			Game->PlaySound(SFX_DEATHPENALTY_UNCURSE_CONSUMABLE);
			DeathPenalty[_DP_HPREDUCTION_TIER] = 0;
			Game->Counter[CR_DEATHPENALTY_HP_REDUCTION_CURES]--;
		}
	}
}

global script DeathPenalty_Example{
	void run(){
		DeathPenalty_Init();
		while(true){
			DeathPenalty_Update();
			Waitdraw();
			Waitframe();
		}
	}
}

global script DeathPenalty_onContinue{
	void run(){
		DeathPenalty[_DP_LOADEDSAVE] = 1;
	}
}