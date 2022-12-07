int DamageNumbers[65536];

const int NPCM_DAMAGENUMBERSLASTHP = 12; //npc->Misc[] index tracking the enemy's last HP

//Tile and CSet for the first of 8 tiles for enemy damage numbers
const int GFX_DAMAGENUMBERS_ENEMY = 4680;
const int CS_DAMAGENUMBERS_ENEMY = 7;

//Tile and CSet for the first of 8 tiles for enemy healing numbers
const int GFX_DAMAGENUMBERS_ENEMYHEAL = 4720;
const int CS_DAMAGENUMBERS_ENEMYHEAL = 5;

//Tile and CSet for the first of 8 tiles for Link damage numbers
const int GFX_DAMAGENUMBERS_LINK = 4700;
const int CS_DAMAGENUMBERS_LINK = 8;

//Tile and CSet for the first of 8 tiles for Link healing numbers
const int GFX_DAMAGENUMBERS_LINKHEAL = 4720;
const int CS_DAMAGENUMBERS_LINKHEAL = 5;

//Width and height of damage number tiles in pixels
const int DAMAGENUMBERS_WIDTH = 4;
const int DAMAGENUMBERS_HEIGHT = 7;

//Multiplier and number of decimal places shown for enemies
const int DAMAGENUMBERS_ENEMY_MULTIPLIER = 1;
const int DAMAGENUMBERS_ENEMY_DECIMAL_PLACES = -1;

//Multiplier and number of decimal places shown for Link
const int DAMAGENUMBERS_LINK_MULTIPLIER = 1;
const int DAMAGENUMBERS_LINK_DECIMAL_PLACES = -1;

const int DAMAGENUMBERS_MAX = 32; //The max number of damage numbers drawn to the screen at once
const int DAMAGENUMBERS_FRAMES = 40; //How many frames the damage numbers last for
const int DAMAGENUMBERS_SPAWNFRAMES = 24; //How many frames the damage numbers to appear (0 for instant)
const int DAMAGENUMBERS_XOFF = 0; //X offset for the spawning point of the numbers
const int DAMAGENUMBERS_YOFF = -8; //Y offset for the spawning point of the numbers
const int DAMAGENUMBERS_YSPEED = -0.1; //The speed the number moves on the Y-axis (negative = upwards)
const int DAMAGENUMBERS_BOUNCEHEIGHT = 6; //How high in pixels the numbers bounce on the Y axis
const int DAMAGENUMBERS_LINKDAMAGECOOLDOWN = 16; //How often in frames the script can detect Link taking damage
const int DAMAGENUMBERS_LINKHEALCOOLDOWN = 16; //How often in frames the script can detect Link healing HP
const int DAMAGENUMBERS_ALLOW_LARGE_NEGATIVE = 0; //If 1, enemies with <-1000 HP can still draw damage numbers. This is usually used by scripts to kill enemies without making a death sound

//Internal constants used by the script, don't change
const int _DNUM_STARTINDEX = 16;
const int _DNUM_INDICES = 5;

const int _DNUM_LASTLINKHP = 0;
const int _DNUM_LINKDAMAGECOOLDOWN = 1;
const int _DNUM_LINKHEALCOOLDOWN = 2;
const int _DNUM_LASTDMAP = 3;
const int _DNUM_LASTSCREEN = 4;

const int _DNUMI_X = 0;
const int _DNUMI_Y = 1;
const int _DNUMI_TYPE = 2;
const int _DNUMI_DAMAGE = 3;
const int _DNUMI_TIMER = 4;

const int _DNUM_TYPE_ENEMYDAMAGE = 0;
const int _DNUM_TYPE_ENEMYHEAL = 1;
const int _DNUM_TYPE_LINKDAMAGE = 2;
const int _DNUM_TYPE_LINKHEAL = 3;

//Init function, clears the DamageNumbers[] array on every load
void DamageNumbers_Init(){
	int size = SizeOfArray(DamageNumbers);
	for(int i=0; i<size; i++){
		DamageNumbers[i] = 0;
	}
	
	DamageNumbers[_DNUM_LASTLINKHP] = Link->HP;
	DamageNumbers[_DNUM_LASTDMAP] = Game->GetCurDMap();
	DamageNumbers[_DNUM_LASTSCREEN] = Game->GetCurScreen();
}

//Update function for enemies. This can be combined with your own if you have one
void DamageNumbers_UpdateEnemies(){
	for(int i=Screen->NumNPCs(); i>0; i--){
		npc n = Screen->LoadNPC(i);
		DamageNumbers_UpdateEnemyDamage(n);
	}
}

//Update function for individual enemies
void DamageNumbers_UpdateEnemyDamage(npc n){
	//Detect when the enemy's HP has changed
	if(n->HP!=n->Misc[NPCM_DAMAGENUMBERSLASTHP]){
		//Ignore enemies that don't have conventional HP
		if(DamageNumbers_IgnoreEnemyType(n))
			return;
		
		//NPCs with -1000 HP have usually been killed by scripts
		if(n->HP>-1000||DAMAGENUMBERS_ALLOW_LARGE_NEGATIVE){
			//If it's less make a damage number
			if(n->HP<n->Misc[NPCM_DAMAGENUMBERSLASTHP]){
				if(GFX_DAMAGENUMBERS_ENEMY!=0){
					DamageNumbers_AddNumberGFX(CenterX(n), CenterY(n)-DAMAGENUMBERS_HEIGHT/2, _DNUM_TYPE_ENEMYDAMAGE, Abs(n->HP-n->Misc[NPCM_DAMAGENUMBERSLASTHP]));
				}
			}
			//else if it wasn't 0 (just spawned in) make a healing number
			else if(n->Misc[NPCM_DAMAGENUMBERSLASTHP]){
				if(GFX_DAMAGENUMBERS_ENEMYHEAL!=0){
					DamageNumbers_AddNumberGFX(CenterX(n), CenterY(n)-DAMAGENUMBERS_HEIGHT/2, _DNUM_TYPE_ENEMYHEAL, Abs(n->HP-n->Misc[NPCM_DAMAGENUMBERSLASTHP]));
				}
			}
		}
			
		//Update the change in HP
		n->Misc[NPCM_DAMAGENUMBERSLASTHP] = n->HP;
	}
}

//Function for finding enemies that should never show damage numbers
bool DamageNumbers_IgnoreEnemyType(npc n){
	bool invalidTypes[256];
	
	invalidTypes[NPCT_GUY] = true;
	invalidTypes[NPCT_ROCK] = true;
	invalidTypes[NPCT_TRAP] = true;
	invalidTypes[NPCT_PROJECTILE] = true;
	invalidTypes[NPCT_NONE] = true;
	invalidTypes[NPCT_FAIRY] = true;
	
	return invalidTypes[n->Type];
}

//Update function for Link
void DamageNumbers_UpdateLink(){
	//Cooldown timer for Link taking damage (for things that damage him every frame)
	if(DamageNumbers[_DNUM_LINKDAMAGECOOLDOWN]>0)
		DamageNumbers[_DNUM_LINKDAMAGECOOLDOWN]--;
	//Cooldown timer for Link healing (for things that heal him every frame)
	if(DamageNumbers[_DNUM_LINKHEALCOOLDOWN]>0)
		DamageNumbers[_DNUM_LINKHEALCOOLDOWN]--;
	
	//Whenever Link's HP changes
	if(Link->HP!=DamageNumbers[_DNUM_LASTLINKHP]){
		//If he took damage and isn't on cooldown
		if(Link->HP<DamageNumbers[_DNUM_LASTLINKHP]){
			if(DamageNumbers[_DNUM_LINKDAMAGECOOLDOWN]<=0){
				if(GFX_DAMAGENUMBERS_LINK!=0)
					DamageNumbers_AddNumberGFX(CenterLinkX(), CenterLinkY()-DAMAGENUMBERS_HEIGHT/2, _DNUM_TYPE_LINKDAMAGE, Abs(Link->HP-DamageNumbers[_DNUM_LASTLINKHP]));
				
				DamageNumbers[_DNUM_LINKDAMAGECOOLDOWN] = DAMAGENUMBERS_LINKDAMAGECOOLDOWN;
			
				DamageNumbers[_DNUM_LASTLINKHP] = Link->HP;
			}
		}
		//otherwise if he healed and isn't on cooldown
		else{
			if(DamageNumbers[_DNUM_LINKHEALCOOLDOWN]<=0){
				if(GFX_DAMAGENUMBERS_LINKHEAL!=0)
					DamageNumbers_AddNumberGFX(CenterLinkX(), CenterLinkY()-DAMAGENUMBERS_HEIGHT/2, _DNUM_TYPE_LINKHEAL, Abs(Link->HP-DamageNumbers[_DNUM_LASTLINKHP]));
				
				DamageNumbers[_DNUM_LINKHEALCOOLDOWN] = DAMAGENUMBERS_LINKHEALCOOLDOWN;
			
				DamageNumbers[_DNUM_LASTLINKHP] = Link->HP;
			}
		}
	}
}

//Update function for scripted damage number draws
void DamageNumbers_UpdateNumberGFX(){
	int j;
	
	//If the screen has changed, reset all damage numbers
	if(Game->GetCurDMap()!=DamageNumbers[_DNUM_LASTDMAP]||Game->GetCurScreen()!=DamageNumbers[_DNUM_LASTSCREEN]){
		DamageNumbers_Init();
	}
	
	//Cycle through all number indices
	for(int i=0; i<DAMAGENUMBERS_MAX; i++){
		j = _DNUM_STARTINDEX+_DNUM_INDICES*i;
		//If >0, is valid
		if(DamageNumbers[j+_DNUMI_TIMER]>0){
			int type = DamageNumbers[j+_DNUMI_TYPE];
			
			int damage = DamageNumbers[j+_DNUMI_DAMAGE];
			
			//Draw all numbers based on type
			if(type==_DNUM_TYPE_ENEMYDAMAGE){
				if(DAMAGENUMBERS_ENEMY_MULTIPLIER>0)
					damage *= DAMAGENUMBERS_ENEMY_MULTIPLIER;
				DamageNumbers_Draw(DamageNumbers[j+_DNUMI_X]+DAMAGENUMBERS_XOFF, DamageNumbers[j+_DNUMI_Y]+DAMAGENUMBERS_YOFF, GFX_DAMAGENUMBERS_ENEMY, CS_DAMAGENUMBERS_ENEMY, damage, DamageNumbers[j+_DNUMI_TIMER], DAMAGENUMBERS_ENEMY_DECIMAL_PLACES);
			}
			else if(type==_DNUM_TYPE_ENEMYHEAL){
				if(DAMAGENUMBERS_ENEMY_MULTIPLIER>0)
					damage *= DAMAGENUMBERS_ENEMY_MULTIPLIER;
				DamageNumbers_Draw(DamageNumbers[j+_DNUMI_X]+DAMAGENUMBERS_XOFF, DamageNumbers[j+_DNUMI_Y]+DAMAGENUMBERS_YOFF, GFX_DAMAGENUMBERS_ENEMYHEAL, CS_DAMAGENUMBERS_ENEMYHEAL, damage, DamageNumbers[j+_DNUMI_TIMER], DAMAGENUMBERS_ENEMY_DECIMAL_PLACES);
			}
			else if(type==_DNUM_TYPE_LINKDAMAGE){
				if(DAMAGENUMBERS_LINK_MULTIPLIER>0)
					damage *= DAMAGENUMBERS_LINK_MULTIPLIER;
				DamageNumbers_Draw(DamageNumbers[j+_DNUMI_X]+DAMAGENUMBERS_XOFF, DamageNumbers[j+_DNUMI_Y]+DAMAGENUMBERS_YOFF, GFX_DAMAGENUMBERS_LINK, CS_DAMAGENUMBERS_LINK, damage, DamageNumbers[j+_DNUMI_TIMER], DAMAGENUMBERS_LINK_DECIMAL_PLACES);
			}
			else if(type==_DNUM_TYPE_LINKHEAL){
				if(DAMAGENUMBERS_LINK_MULTIPLIER>0)
					damage *= DAMAGENUMBERS_LINK_MULTIPLIER;
				DamageNumbers_Draw(DamageNumbers[j+_DNUMI_X]+DAMAGENUMBERS_XOFF, DamageNumbers[j+_DNUMI_Y]+DAMAGENUMBERS_YOFF, GFX_DAMAGENUMBERS_LINKHEAL, CS_DAMAGENUMBERS_LINKHEAL, damage, DamageNumbers[j+_DNUMI_TIMER], DAMAGENUMBERS_LINK_DECIMAL_PLACES);
			}
			
			DamageNumbers[j+_DNUMI_Y] += DAMAGENUMBERS_YSPEED;
			DamageNumbers[j+_DNUMI_TIMER]--;
		}
	}
}

//Function to add scripted damage number draws
void DamageNumbers_AddNumberGFX(int x, int y, int type, int damage){
	int j;
	//Cycle through all number indices
	for(int i=0; i<DAMAGENUMBERS_MAX; i++){
		j = _DNUM_STARTINDEX+_DNUM_INDICES*i;
		//If <= 0, is invalid
		if(DamageNumbers[j+_DNUMI_TIMER]<=0){
			DamageNumbers[j+_DNUMI_X] = x;
			DamageNumbers[j+_DNUMI_Y] = y;
			DamageNumbers[j+_DNUMI_TYPE] = type;
			DamageNumbers[j+_DNUMI_DAMAGE] = damage;
			DamageNumbers[j+_DNUMI_TIMER] = DAMAGENUMBERS_FRAMES;
			return;
		}
	}
}

//Function to draw scripted damage number draws for one frame
void DamageNumbers_Draw(int x, int y, int gfx, int cs, int num, int frame, int numDecimalPlaces){
	int i; int j; int k;
	
	//Frames normally count down, but this function calculates stuff as if they're counting up
	frame = DAMAGENUMBERS_FRAMES-frame;
	
	num = Clamp(num, 0, 99999.9999);
	int drawX = Floor(x-DAMAGENUMBERS_WIDTH/2);
	int drawY = Floor(y-DAMAGENUMBERS_HEIGHT/2);
	int digitsWh[5];
	
	//Get each digit of the number
	digitsWh[0] = Floor(num)%10;
	digitsWh[1] = Floor(num/10)%10;
	digitsWh[2] = Floor(num/100)%10;
	digitsWh[3] = Floor(num/1000)%10;
	digitsWh[4] = Floor(num/10000)%10;
	
	int digitsDc[5] = {-1, -1, -1, -1, -1};
	
	//If decimal places should be drawn
	if(numDecimalPlaces!=0){
		digitsDc[0] = 10; //Add the decimal point character
		
		//Get the digits of each decimal place
		i = (num-Floor(num))*10000;
		digitsDc[4] = Floor(i)%10;
		digitsDc[3] = Floor(i/10)%10;
		digitsDc[2] = Floor(i/100)%10;
		digitsDc[1] = Floor(i/1000)%10;
		
		//If there's a fixed number of decimal places, clear the unused ones
		if(numDecimalPlaces>0){
			for(i=4; i>numDecimalPlaces; i--)
				digitsDc[i] = -1;
		}
		//Else (-1) clear the unused ones
		else{
			for(i=1; digitsDc[i]==0&&i<=4; i++)
				digitsDc[i] = -1;
			//If all decimal places are empty, the number is whole. Remove the decimal point
			if(digitsDc[1]==-1)
				digitsDc[0] = -1;
		}
	}
	
	//Find how many whole number places should be visible
	int placesWh = 1;
	if(num>=10000)
		placesWh = 5;
	else if(num>=1000)
		placesWh = 4;
	else if(num>=100)
		placesWh = 3;
	else if(num>=10)
		placesWh = 2;
	
	int digits[10];
	int numDigits;
	
	//Put the whole and decimal digits into one array
	for(i=4; i>=0; i--){
		if(digitsDc[i]>0){
			digits[numDigits] = digitsDc[i];
			numDigits++;
		}
	}
	for(i=0; i<placesWh; i++){
		digits[numDigits] = digitsWh[i];
		numDigits++;
	}
	
	//Center the starting position of the number
	//(this gets added instead of subtracted because the numbers are drawn right to left)
	drawX += Floor(-DAMAGENUMBERS_WIDTH/2+(numDigits-1)*DAMAGENUMBERS_WIDTH/2);
	
	int tmpX; int tmpY;
	
	int spawnFreq;
	if(DAMAGENUMBERS_SPAWNFRAMES==0)
		spawnFreq = 0;
	else 
		spawnFreq = (360/DAMAGENUMBERS_SPAWNFRAMES);
	int spawnFreq2 = (180/numDigits);
	
	//Draw each digit in sequence
	for(i=0; i<numDigits; i++){
		k = frame*spawnFreq-i*spawnFreq2;
		j = Abs(Sin(Clamp(k, 0, 180)));
		tmpX = drawX-i*DAMAGENUMBERS_WIDTH;
		tmpY = drawY-DAMAGENUMBERS_BOUNCEHEIGHT*j;
		//Check if each digit should be drawn
		//When k>0, the Abs(Sin(k)) bounce animation has started. k is clamped so it only plays once.
		//Otherwise if spawnFreq is 0, all digits appear instantly
		if(k>=0||spawnFreq==0){
			if(gfx>0)
				Screen->FastTile(6, tmpX, tmpY, gfx+digits[i], cs, 128);
			else
				Screen->FastCombo(6, tmpX, tmpY, Abs(gfx)+digits[i], cs, 128);
		}
	}
}

global script DamageNumbers_ExampleGlobal{
	void run(){
		DamageNumbers_Init();
		while(true){
			DamageNumbers_UpdateEnemies();
			DamageNumbers_UpdateLink();
			DamageNumbers_UpdateNumberGFX();
			
			Waitdraw();
			Waitframe();
		}
	}
}