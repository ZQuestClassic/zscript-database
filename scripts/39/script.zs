import "std.zh"
import "ffcscript.zh"
import "ghost.zh"
import "string.zh"
//Screen dimensions
const int screenWidth = 256;
const int screenHeight = 176;
//Acid pool constants
const int ACID_MAX_ON_SCREEN = 8; //Max number of acid puddles allowed on screen
//Mist colors (color = CSet# * 16 + color within CSet from 0 to 15)
const int COLOR_MIST_YELLOW = 6;
const int COLOR_MIST_RED = 5;
const int COLOR_MIST_GREEN = 82;
const int COLOR_MIST_BLUE = 3;

//AcidHandla enemy (place this one on screen)
//Type: Other
//Attrib 1: ID of head enemy
//Attrib 2: Max time between head sockets dropping acid (Recommend 120)
//Attrib 3: Acid combo (Set the CSet2 attribute so that it looks right with CSet 0)
//Attrib 4: Acid duration (120)
//Attrib 5: Maximum time between mist changes (240)
//Attrib 6: Minimum time between mist changes (180)
//Attrib 7: Time until heads respawn (240)
//Attrib 11: -1
//Attrib 12: Slot # of this script
//Weapon damage: Frames between acid damaging Link (10)
//Random rate: Frames before changing direction / 10 (e.g. 4 = 40 frames)
//HP, Damage, Step, Frame Rate: Set as normal
//Head enemy
//Type: Walking enemy
//Weapon Shot Type: Rapid Fire
//Set up all attributes as normal, including weapon of choice
ffc script acidHandla{
void run(int enemyID){
	 npc ghost = Ghost_InitAutoGhost(this, enemyID, GHF_NORMAL); //Load main enemy
	 npc heads[4]; //Acidhandla's heads - fireballs while alive, acid when dead
	 int headXY[8] = { 0,-15, 0,15, -15,0, 15,0 }; //Head X/Y offset in order UDLR
	 int acidTime[4]; //Time before each head socket drops acid
	 int storeDefense[18]; //Store defenses while invulnerable
	 int mistCounter; //Time before changing mist on/off
	 int mistType; //Currently active mist type
		 //0 = None
		 //1 = Yellow (switch button inputs)
		 //2 = Red (player and boss slow down)
		 //3 = Green (player and boss speed up)
		 //4 = Blue (instantly restore one head)
	 int curStep = ghost->Step; //Red/Green mists modify step speed
	 int headlessStep; //Step speed addition: (4-#heads)*15
	 int moveCountdown = ghost->Rate*10; //Time before changing direction


	 //==== Setup ====

	 //Load attributes
	 int headID = ghost->Attributes[0];
	 int acidDropRate = ghost->Attributes[1];
	 int acidSprite = ghost->Attributes[2];
	 int acidDuration = ghost->Attributes[3];
	 int hurtFreq = ghost->WeaponDamage;
	 int mistTimeMax = ghost->Attributes[4];
	 int mistTimeMin = ghost->Attributes[5];
	 int respawnRate = ghost->Attributes[6];
	 int respawnTime = respawnRate; //Time before heads respawn (all at once, starting when they're all gone)

	 //Find phase-change HP values
	 int phase2HP = ghost->HP / 2;
	 //int phase3HP = ghost->HP / 3;

	 //Create heads
	 for ( int i = 0; i < 4; i++ ){
		 heads[i] = Screen->CreateNPC(headID);
	 }

	 //Store defenses and make body invulnerable
	 for ( int i = 0; i < 18; i++ ){
		 storeDefense[i] = ghost->Defense[i];
		 ghost->Defense[i] = NPCDT_QUARTERDAMAGE;
	 }
	
	 //==== Begin loop ====
	 while ( ghost->HP > 0 ){
		 //Manage heads
		 int headCount;
		 for ( int i = 0; i < 4; i++ ){
			 if ( !heads[i]->isValid() ){ //If dead
				 if ( acidTime[i] <= 0 ){ //Acid time is up
					 int ffcScriptName[] = "acidPool";
					 int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
					 if ( CountFFCsRunning(ffcScriptNum) < ACID_MAX_ON_SCREEN ){ //Fewer than max acid
						 int x = ghost->X + headXY[i*2];
						 int y = ghost->Y + headXY[i*2+1];
						 int args[5] = { x, y, acidSprite, hurtFreq, acidDuration };
						 RunFFCScript(ffcScriptNum, args); //Drop some!
					 }
					 acidTime[i] = Rand(acidDropRate) + 1; //Reset time to random length
				 }
				 else //Otherwise decrement acid counter
						 acidTime[i]--;
				 }
			 else{ //Alive: keep in place
				 headCount++;
				 //Heads should handle their own fireballs
				 heads[i]->Dir = i; //Keep it facing in right direction
				 heads[i]->X = ghost->X + headXY[i*2];
				 heads[i]->Y = ghost->Y + headXY[i*2 + 1];
			 }
		 }
		 //If all heads destroyed, restore defenses
		 if ( headCount <= 0 ){
			 if ( respawnTime <= 0 ){ //If respawn time up
				 respawnTime = respawnRate;
				 for ( int i = 0; i < 4; i++ ){ //Regenerate heads
					 heads[i] = Screen->CreateNPC(headID);
					 heads[i]->X = ghost->X + headXY[i*2];
					 heads[i]->Y = ghost->Y + ghost->Y + headXY[i*2+1];
				 }
			 }
			 else
				 respawnTime--; //If set, count down to respawn; regeneration handled above
			 for ( int i = 0; i < 18; i++ )
				 ghost->Defense[i] = storeDefense[i];
		 }
		 //Otherwise make invulnerable (if heads respawn, takes effect next frame
		 else{
			 for ( int i = 0; i < 18; i++ )
				 ghost->Defense[i] = NPCDT_QUARTERDAMAGE;
			 respawnTime = respawnRate;
		 }
		
		 //Mist change
		 if ( mistCounter <= 0 && ghost->HP <= phase2HP ){ //If counter hits 0 and boss is on phase 2
			 mistCounter = Rand(mistTimeMax-mistTimeMin) + mistTimeMin; //Set random time
			 if ( mistType > 0 ) //If mist is active, disable it
				 mistType = 0;
			 else{ //If mist is inactive, enable it
				 mistType = Rand(4) + 1;
				 if ( mistType == 4 ){ //If blue
					 for ( int i = 0; i < 4; i++ ){ //Check each head
						 if ( !heads[i]->isValid() ){ //If dead
							 heads[i] = Screen->CreateNPC(headID); //Regenerate it
							 heads[i]->X = ghost->X + headXY[i*2];
							 heads[i]->Y = ghost->Y + ghost->Y + headXY[i*2+1];
							 break; //Then stop. Only one head is regenerated.
						 }
					 }
				 }
			 }
		 }
		 else if ( mistCounter > 0 )
			 mistCounter--;
		
		 //Mist effects
		 if ( mistType == 0 ) //None: Reset speed
			 curStep = ghost->Step;
		 else if ( mistType == 1 ){ //Yellow: Switch inputs
			 Screen->Rectangle(6, 0, 0, screenWidth, screenHeight, COLOR_MIST_YELLOW, 1, 0, 0, 0, true, 64);
			 switchInputs();
			 curStep = ghost->Step;
		 }
		 else if ( mistType == 2 ){ //Red: Slow down
			 Screen->Rectangle(6, 0, 0, screenWidth, screenHeight, COLOR_MIST_RED, 1, 0, 0, 0, true, 64);
			 curStep = ghost->Step/2;
			 if ( Rand(2) )
				 NoMovement();
		 }
		 else if ( mistType == 3 ){ //Green: Speed up
			 Screen->Rectangle(6, 0, 0, screenWidth, screenHeight, COLOR_MIST_GREEN, 1, 0, 0, 0, true, 64);
			 curStep = ghost->Step*2;
			 fastWalk(1);
		 }
		 else if ( mistType == 4 ){ //Blue: Nothing; head was regenerated at beginning
			 Screen->Rectangle(6, 0, 0, screenWidth, screenHeight, COLOR_MIST_BLUE, 1, 0, 0, 0, true, 64);
			 curStep = ghost->Step;
		 }
		
		 //Finally, move the 'Handla
		 moveCountdown--;
		 if ( moveCountdown <= 0 ){
			 moveCountdown = ghost->Rate*10;
			 ghost->Dir = Rand(4);
		 }
		
		 headlessStep = (4 - headCount) * 15;
		 Ghost_Move(ghost->Dir, (curStep+headlessStep)/100, 0);
		 Ghost_Waitframe(this, ghost, false, false);
	 }
	
	 for ( int i = 0; i < 4; i++ ){ //Kill off heads
		 if ( heads[i]->isValid() )
			 heads[i]->HP = 0;
	 }
	 Ghost_Explode(this, ghost); //Play asploding animation
}
}
void switchInputs(){
bool temp = Link->InputDown;
Link->InputDown = Link->InputUp;
Link->InputUp = temp;

temp = Link->InputRight;
Link->InputRight = Link->InputLeft;
Link->InputLeft = temp;

temp = Link->InputB;
Link->InputB = Link->InputA;
Link->InputA = temp;

temp = Link->InputR;
Link->InputR = Link->InputL;
Link->InputL = temp;
}
//Don't set speed too high!
void fastWalk ( int speed ){
//Up
if( Link->InputUp
&& !Screen->isSolid(Link->X,Link->Y+6) //NW
&& !Screen->isSolid(Link->X+7,Link->Y+6) //N
&& !Screen->isSolid(Link->X+15,Link->Y+6) //NE
)
	 Link->Y -= speed;
//Down
else if( Link->InputDown
&& !Screen->isSolid(Link->X,Link->Y+17) //SW
&& !Screen->isSolid(Link->X+7,Link->Y+17) //S
&& !Screen->isSolid(Link->X+15,Link->Y+17) //SE
)
	 Link->Y += speed;
//Left
else if( Link->InputLeft
&& !Screen->isSolid(Link->X-2,Link->Y+8) //NW
&& !Screen->isSolid(Link->X-2,Link->Y+15) //SW
)
	 Link->X -= speed;
//Right
else if( Link->InputRight
&& !Screen->isSolid(Link->X+17,Link->Y+8) //NE
&& !Screen->isSolid(Link->X+17,Link->Y+15) //SE
)
	 Link->X += speed;
}

//Hurts Link as long as he touches it - no knockback, no invuln
//D0: X position
//D1: Y position
//D2: Combo to use
//D3: Frames between hurting Link
//D4: Frames before this dissappears
ffc script acidPool{
void run ( int x, int y, int combo, int freq, int duration ){
	 int hurtTimer;
	 this->Data = combo;
	 this->CSet = 0;
	 this->X = x;
	 this->Y = y;
	 while ( duration > 0 ){
		 if ( LinkCollision(this) && Link->Z <= 0 ){
			 hurtTimer = (hurtTimer + 1) % freq;
			 if ( hurtTimer == 0 ){
				 Link->HP--;
			 }
		 }
		 else
			 hurtTimer = 0;
		 duration--;
		 Waitframe();
	 }
	 this->Data = 0;
}
}

//Prevents moving in any direction
void NoMovement(){
Link->InputUp = false; Link->PressUp = false;
Link->InputDown = false; Link->PressDown = false;
Link->InputLeft = false; Link->PressLeft = false;
Link->InputRight = false; Link->PressRight = false;
}