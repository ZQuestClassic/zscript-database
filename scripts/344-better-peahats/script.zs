//Peahat enemy - By Orithan
//This is a fully-scripted Peahat, using Ghost.zh to finally produce a Peahat that's less annoying than the stock ZC version. Instead of being a traditional Z1 Peahat, this Peahat is more like the OoT incarnation - Remaining still until it lifts off. After lifting off, it flies high above and sending out larvae to attack Link. This script can be used to create a variety of enemies, some possibilities of which are shown in the demo quest.

//import "std.zh"
//import "string.zh"
//import "ghost.zh" 

//Attributes:
//HP, Damage, Weapon Damage, Step, Random Rate, Homing and Animation speed: Set as normal
// Animation speed refers to the animation speed of when peahat is flying at full speed. This value is doubled when peahat is landing or rising and set to 255 when it is on land.
//Halt Rate: Frequency of it firing weapons. Operates on a probability when it changes directon
//Misc Attribute 1: The Z height Peahat flies up to.
//Misc Attribute 2: Amount of time it remains at its Z height for before flying down.
//Misc Attribute 3: Amount of time it remains on the ground before flying up.
//Misc Attribute 4: By how much percent does the flight time vary from its normal value, both above and below the normal value.
//Misc Attribute 5: The enemy id it summons for its "larvae".
//Misc Attribute 6: How many it summons at a time.
//Misc Attribute 7: The frequency at which it summons. Pass a negative value into this to enable it to summon while grounded instead of in air.
//Misc Attribute 8: How close Link has to be in order for the Peahat to start taking off or Peahat is too scared to begin descending around.
//Misc Attribute 9: The SFX played when a Peahat spawns larvae. Set to -1 or below to set it to the default Summon Magic SFX.

ffc script Peahat{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID); //Load enemy
		Ghost_SetFlag(GHF_NORMAL | GHF_IGNORE_ALL_TERRAIN); //Peahat is a flying enemy, set relevant flags.
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_UnsetFlag(GHF_SET_DIRECTION); //Make sure that the Peahat can't change combo based on direction it moves.
		int state = 0; //The state Peahat is currently in. 0 = Grounded, 1 = Rising, 2 = Flying, 3 = Lowering.
		int timer = 0; //The timer used to keep track of when the Peahat is supposed to start flying.
		int counter = -1; //Initialize the movement counter variable

		//Grab attributes:
		int step = ghost->Step;
		int rate = ghost->Rate;
		int anim = ghost->ASpeed;
		int homing = ghost->Homing;
		int maxhp = Ghost_HP;
		int zflight = ghost->Attributes[0];
		int flighttime = ghost->Attributes[1];
		int groundtime = ghost->Attributes[2];
		int flightrandomizer = ghost->Attributes[3];
		int summonnpc = ghost->Attributes[4];
		int summonqty = ghost->Attributes[5];
		int summonfreq = ghost->Attributes[6];
		int flyradius = ghost->Attributes[7];
		int spawnsound = ghost->Attributes[8];
		if(spawnsound < 0){
			spawnsound = SFX_SUMMON;
		}
		
		//Peahat starts off on the ground
		ghost->ASpeed = 255;
		
		int summoncounter = -1; //Initialize the summon counter as undefined.
		int randomizedflighttime = flighttime; //Initialize the randomized flight time variable.
		
		if(summonfreq != 0 && summonqty > 0){ //Are the summoning attributes set? Note that the NPC summoned must be at least 20 due to technical issues that may arise from summoning earlier NPCs.
			summoncounter = 0; //Define the summon counter.
		}
		
		while(true){
			//Peahat is on the ground.
			if(state == 0){
				ghost->ASpeed = 255;
				if(timer >= groundtime || Ghost_GotHit() || Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(), CenterLinkY()) <= flyradius){ //Any of the following conditions are met: Peahat has stayed on the ground for Misc Attribute 3 frames, is hit by an attack or Link ventures to within Misc Attribute 8 pixels from it. Now it is time to lift off
					timer = 0; //Reset the timer
					state = 1; //Tell the Peahat to begin rising
				}
			}
			
			//Peahat is rising off the ground and into the air.
			else if(state == 1){
				ghost->ASpeed = anim*2; //Set the animation speed to half as fast as what it is set.
				Ghost_ConstantWalk8(counter, (step/zflight)*Max(Ghost_Z, 1), rate, homing, 0); //Move at a step speed relative to its destination height. Sanity check because apparently ZScript has issues with multiplying 0 in the block when determining the step speed
				Ghost_Jump = 0; //Set Jump to 0, to prevent falling
				if(timer%6 == 1){ //Slowly ascend
					Ghost_Z ++;
				}
				if(Ghost_Z >= zflight){ //It has risen to full flight height
					timer = 0; //Reset the timer
					state = 2; //Tell the peahat it is now flying
					randomizedflighttime = RandPercent(flighttime, flightrandomizer, flightrandomizer); //Randomize the flight time.
					if(summonfreq != 0 && summonqty > 0 && summonnpc >= 20){ //Refresh the summon counter
						summoncounter = 0; //Refresh the summon counter
					}
				}
			}
			
			//Peahat is flying.
			else if(state == 2){
				Ghost_ConstantWalk8(counter, step, rate, homing, 0); //Begin flying at normal speed
				Ghost_Jump = 0;
				ghost->ASpeed = anim; //Peahat animates at normal speed
				if(summoncounter == Abs(summonfreq) && summonfreq > 0){ //Positive summon frequency, summon only in the air.
					SpawnNPCs(Ghost_X, Ghost_Y, summonnpc, summonqty, spawnsound); //Summon NPC
					summoncounter = 0;
				}
				if(timer >= randomizedflighttime){ //Check to see if it is time to land
					if(Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(), CenterLinkY()) <= flyradius){ //Link is too close to Peahat, it remains in the air for half of Misc Attribute 2 more frames
						timer = randomizedflighttime-(flighttime/2); //Give it more flight frames
					}
					else{
						timer = 0; //Reset the timer
						state = 3; //Tell the Peahat to begin landing
					}
				}
			}
			
			//Peahat is landing
			else if(state == 3){
				if(Ghost_GotHit() || Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(), CenterLinkY()) <= flyradius){ //If any of the following happen, Peahat takes off again immediately.
					timer = 0; //Reset the timer
					state = 1; //Tell the Peahat to begin rising
				}
				ghost->ASpeed = anim*2;
				Ghost_ConstantWalk8(counter, (step/zflight)*Ghost_Z, 0, 0, 0); //Slow down
				Ghost_Jump = 0;
				if(timer%6 == 1){ //Slowly descend
					Ghost_Z --;
				}

				if(Ghost_Z <= 0){ //It has fully landed
					timer = 0; //Reset the timer
					state = 0; //Tell the Peahat that it has fully landed
				}
			}
			
			if(summoncounter == Abs(summonfreq) && summonfreq < 0){ //Negative summon frequency, summon at any time.
				SpawnNPCs(Ghost_X, Ghost_Y, summonnpc, summonqty, spawnsound);
				summoncounter = 0;
			}
			if(summoncounter >= 0){ //Summon counter only gets incremented if it got validated
				summoncounter ++;
			}
			timer ++; //Update the timer
			Ghost_Waitframe(this, ghost, true, true);
		}
	}
}

//These functions are reusable and are often included in my scripts.
//ONLY INCLUDE THE FOLLOWING FUNCTIONS ONCE IN YOUR SCRIPT FILES OR YOU WILL RUN INTO COMPILE ERRORS

//A simple function for randomizing values between a certain percentage of their original value. Val is simply the value to use, upper bound is how high above the original value in percent (eg. 30% above original) can be as a result, lower bound is the same except for that it determines how low below the original value the value can produce.
int RandPercent(int val, int upperbound, int lowerbound){
	float value = val;
	int highrange = (val/100)*(100+upperbound);
	int lowrange = (val/100)*(100-lowerbound);
	value = Rand(lowrange, highrange);
	
	return Ceiling(value);
}

//This function spawns a selected number of a certain type of NPC on a single location at a time, using a spawn sfx. Overloaded to make the sfx agument optional.
void SpawnNPCs(int x, int y, int id, int qty, int sfx){
	for(int a = 1; a <= qty; a ++){
		if(id >= 20){
			CreateNPCAt(id, x, y);
		}
	}
	if(sfx > 0){
		Game->PlaySound(sfx);
	}
}
void SpawnNPCs(int x, int y, int id, int qty){
	SpawnNPCs(x, y, id, qty, 0);
}