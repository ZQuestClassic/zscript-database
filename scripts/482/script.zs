const int EW_ENEMYSWORD = EW_SCRIPT1; //Weapon type used for scripted sword weapons

//D0: Sword Sprite. Uses four tiles: Up, Down, Left, Right
//D1: How far out the sword is held
//D2: How far to offset the sword to the side when facing up and down (flipped based on direction)
//D3: How far to offset the sword up or down when facing left and right (not flipped based on direction)
npc script EnemySword_Simple{
	eweapon UpdateEnemySword(npc this, eweapon hitbox, int swordSprite, int swordExtend, int sideOffset, int downOffset){
		int dir = DIR_UP;
		if(this->Dir>=0)
			dir = this->Dir&3;
		int swordX;
		int swordY;
		//Get offsets for the sword
		switch(dir){
			case DIR_UP:
				swordX += sideOffset;
				swordY -= swordExtend;
				break;
			case DIR_DOWN:
				swordX -= sideOffset;
				swordY += swordExtend;
				break;
			case DIR_LEFT:
				swordX -= swordExtend;
				swordY += downOffset;
				break;
			case DIR_RIGHT:
				swordX += swordExtend;
				swordY += downOffset;
				break;
		}
		
		//If the weapon isn't there recreate it
		if(!hitbox->isValid()){
			hitbox = Screen->CreateEWeapon(EW_ENEMYSWORD);
			hitbox->Damage = this->Damage;
			hitbox->UseSprite(swordSprite);
		}
		hitbox->Tile = hitbox->OriginalTile + dir;
		hitbox->Dir = Link->Dir;
		hitbox->X = this->X;
		hitbox->Y = this->Y;
		//We're setting the weapon's offsets instead of position as this lets it clip off the side of the screen and still draw properly
		hitbox->DrawXOffset = swordX;
		hitbox->DrawYOffset = swordY;
		hitbox->HitXOffset = swordX;
		hitbox->HitYOffset = swordY;
		hitbox->DeadState = WDS_ALIVE;
		return hitbox;
	}
	void run(int swordSprite, int swordExtend, int sideOffset, int downOffset){
		//Wait for the enemy to spawn
		spritedata poof = Game->LoadSpriteData(22);
		Waitframes(poof->Frames*poof->Speed);
		
		if(swordExtend==0)
			swordExtend = 12;
		eweapon hitbox;
		this->Immortal = true;
		while(true){
			hitbox = UpdateEnemySword(this, hitbox, swordSprite, swordExtend, sideOffset, downOffset);
			
			//Do cleanup of the sword when the enemy is dead
			if(this->HP<=0||this->Falling){
				this->Immortal = false;
				if(hitbox->isValid())
					hitbox->DeadState = 0;
				Quit();
			}
			Waitframe();
		}
	}
}

import "LinkMovement.zh"

const int SFX_SWORDCLASH = 57;
const int SPR_SWORDCLASH = 103;

const int SWORDCLASH_PUSH_SPEED = 2; //Measured in pixels per frame
const int SWORDCLASH_PUSH_TIME = 8; //Frames the enemy will be moved for on a sword clash
const int SWORDCLASH_STUN_TIME = 8; //Frames the enemy will be additionally stunned for after movement on a sword clash

//D0: Sword Sprite. Uses four tiles: Up, Down, Left, Right
//D1: How far out the sword is held
//D2: How far to offset the sword to the side when facing up and down (flipped based on direction)
//D3: How far to offset the sword up or down when facing left and right (not flipped based on direction)
//D4: How many pixels away the enemy will aggro on Link from
//D5: How many frames the enemy tries to chase for
//D6: How many frames the enemy takes before it can do another chase
npc script EnemySword_Complex{
	//{ Movement code ripped out of  ghost.zh because the engine one doesn't work
	int __ConstWalk4(npc n, int counter)
	{
		return __ConstWalk4(n, counter, n->Step, n->Random, n->Homing, n->Hunger);
	}
	int __ConstWalk4(npc n, int counter, int step, int rate, int homing, int hunger)
	{
		step /= 100;
		if(n->HitDir > -1) return counter;
		if(counter <= 0)
		{
			__FixCoords(n);
			__PickDir4(n, rate, homing, hunger);
			
			unless(step)
				counter=0;
			else
				counter=Floor(16/step);
		}
		
		int xStep, yStep;
		switch(n->Dir)
		{
			case DIR_LEFT: case DIR_LEFTUP: case DIR_LEFTDOWN:
				xStep = -step;
				break;
			case DIR_RIGHT: case DIR_RIGHTUP: case DIR_RIGHTDOWN:
				xStep = step;
				break;
		}
		switch(n->Dir)
		{
			case DIR_UP: case DIR_LEFTUP: case DIR_RIGHTUP:
				yStep = -step;
				break;
			case DIR_DOWN: case DIR_LEFTDOWN: case DIR_RIGHTDOWN:
				yStep = step;
				break;
		}
		n->MoveXY(xStep, yStep, 0);
		return counter-1;
	}
	void __FixCoords(npc n)
	{
		n->X = (n->X & 0xF0) + ((n->X&8)?16:0);
		n->Y = (n->Y & 0xF0) + ((n->Y&8)?16:0);
	}
	int __LinedUp(npc n, int range, bool eightWay)
	{
		if(Abs(Link->X-n->X)<=range)
		{
			if(Link->Y<n->Y)
				return DIR_UP;
			else
				return DIR_DOWN;
		}
		else if(Abs(Link->Y-n->Y)<=range)
		{
			if(Link->X<n->X)
				return DIR_LEFT;
			else
				return DIR_RIGHT;
		}
		
		if (eightWay)
		{
			if (Abs(Link->X-n->X)-Abs(Link->Y-n->Y)<=range)
			{
				if (Link->Y<n->Y)
				{
					if (Link->X<n->X)
						return DIR_LEFTUP;
					else
						return DIR_RIGHTUP;
				}
				else
				{
					if (Link->X<n->X)
						return DIR_LEFTDOWN;
					else
						return DIR_RIGHTDOWN;
				}
			}
		}

		// Not in range
		return -1;
	}
	void __PickDir4(npc n, int rate, int homing, int hunger)
	{
		int newDir=-1;
		// Go for bait?
		if(Rand(4)<hunger)
		{
			// See if any is on the screen
			lweapon bait=LoadLWeaponOf(LW_BAIT);
			
			if(bait->isValid())
			{
				// Found bait; try to move toward it
				if(Abs(n->Y-bait->Y)>14)
				{
					if(bait->Y<n->Y)
						newDir=DIR_UP;
					else
						newDir=DIR_DOWN;
					
					if(n->CanMove(newDir, 16, 0))
					{
						n->Dir=newDir;
						return;
					}
				}
				
				if(bait->X<n->X)
					newDir=DIR_LEFT;
				else
					newDir=DIR_RIGHT;
				
				if(n->CanMove(newDir, 16, 0))
				{
					n->Dir=newDir;
					return;
				}
			}
		} // End hunger check
		
		// Homing?
		if(Rand(256)<homing)
		{
			newDir=__LinedUp(n, 8, false);
			if(newDir>=0 && n->CanMove(newDir, 16, 0))
			{
				n->Dir=newDir;
				return;
			}
		}
		
		// Check solidity of surrounding combos
		bool combos[4];
		int numDirs;
		int counter;
		
		for(int i=0; i<4; i++)
		{
			if(n->CanMove(i, 16, 0))
			{
				combos[i]=true;
				numDirs++;
			}
		}
		
		// Trapped?
		if(numDirs==0)
		{
			n->Dir=-1;
			return;
		}
		
		if(Rand(16)>=rate)
		{
			// Doesn't want to turn; keep going the same direction if possible
			if(combos[n->Dir])
				return;
		}
		
		// Pick a direction at random from the ones available
		counter=Rand(numDirs);
		for(int dir=0; dir<4; dir++)
		{
			unless(combos[dir])
				continue;
			
			unless(counter)
			{
				n->Dir=dir;
				return;
			}
			else
				--counter;
		}
	}
	//}
	eweapon UpdateEnemySword(npc this, eweapon hitbox, int swordSprite, int swordExtend, int sideOffset, int downOffset, int swordDir){
		int dir = DIR_UP;
		if(swordDir>=0)
			dir = swordDir&3;
		int swordX;
		int swordY;
		//Get offsets for the sword
		switch(dir){
			case DIR_UP:
				swordX += sideOffset;
				swordY -= swordExtend;
				break;
			case DIR_DOWN:
				swordX -= sideOffset;
				swordY += swordExtend;
				break;
			case DIR_LEFT:
				swordX -= swordExtend;
				swordY += downOffset;
				break;
			case DIR_RIGHT:
				swordX += swordExtend;
				swordY += downOffset;
				break;
		}
		
		//If the weapon isn't there recreate it
		if(!hitbox->isValid()){
			hitbox = Screen->CreateEWeapon(EW_ENEMYSWORD);
			hitbox->Damage = this->Damage;
			hitbox->UseSprite(swordSprite);
		}
		hitbox->Tile = hitbox->OriginalTile + dir;
		hitbox->Dir = Link->Dir;
		hitbox->X = this->X;
		hitbox->Y = this->Y;
		//We're setting the weapon's offsets instead of position as this lets it clip off the side of the screen and still draw properly
		hitbox->DrawXOffset = swordX;
		hitbox->DrawYOffset = swordY;
		hitbox->HitXOffset = swordX;
		hitbox->HitYOffset = swordY;
		hitbox->DeadState = WDS_ALIVE;
		return hitbox;
	}
	void UpdateAnimation(npc this, int animData, bool walking, int dir){
		enum {CURFRAME, CURTIL, MAXFRAME};
		if(walking){
			this->ScriptTile = this->OriginalTile+animData[CURTIL]+4*dir;
		}
		else{
			this->ScriptTile = this->OriginalTile+20+animData[CURTIL]+4*dir;
		}
		if(this->HP<=0||this->Falling)
			this->ScriptTile = -1;
		++animData[CURFRAME];
		if(animData[CURFRAME]>=animData[MAXFRAME]){
			animData[CURFRAME] = 0;
			++animData[CURTIL];
			if(animData[CURTIL]>3)
				animData[CURTIL] = 0;
		}
	}
	bool SwordCollision(lweapon linkSword, eweapon eSword, int eSwordDir){
		int x1 = eSword->X+eSword->HitXOffset+2;
		int y1 = eSword->Y+eSword->HitYOffset+2; 
		int w1 = 12; 
		int h1 = 12;
		int x2 = linkSword->X+2; 
		int y2 = linkSword->Y+2; 
		int w2 = 12; 
		int h2 = 12;
		
		if(eSwordDir==DIR_UP||eSwordDir==DIR_DOWN){
			x1 += 3;
			w1 -= 6;
		}
		else if(eSwordDir==DIR_LEFT||eSwordDir==DIR_RIGHT){
			y1 += 3;
			h1 -= 6;
		}
		
		int swordDir = AngleDir8(Angle(Link->X, Link->Y, linkSword->X, linkSword->Y));
		if(swordDir==DIR_UP||swordDir==DIR_DOWN){
			x2 += 3;
			w2 -= 6;
		}
		else if(swordDir==DIR_LEFT||swordDir==DIR_RIGHT){
			y2 += 3;
			h2 -= 6;
		}
		
		return RectCollision(x1, y1, x1+w1-1, y1+h1-1, x2, y2, x2+w2-1, y2+h2-1);
	}
	void run(int swordSprite, int swordExtend, int sideOffset, int downOffset, int aggroRange, int chaseTime, int cooldownTime){
		//Wait for the enemy to spawn
		spritedata poof = Game->LoadSpriteData(22);
		Waitframes(poof->Frames*poof->Speed);
		
		//Get the enemy's frame rate off NPC data
		npcdata d_this = Game->LoadNPCData(this->ID);
		int animData[3];
		animData[2] = Floor(d_this->ExFramerate/4);
		
		if(swordExtend==0)
			swordExtend = 12;
		eweapon hitbox;
		this->Immortal = true;
		
		int drawnDir = this->Dir;
		
		int step = this->Step/100;
		//When chasing the enemy goes at 1.5x speed but will not go above 1.5 base (Link's default step speed)
		int chaseStep = Min((this->Step/100)*1.5, 1.5);
		
		int state;
		int chaseClock;
		int stunClock;
		int coolownClock;
		int knockbackClock;
		int knockbackAngle;
		
		enum {WANDERING, STUNNED, ATTACKING, REALIGNING};
		
		int realignPos;
		int realignX;
		int realignY;
		
		int counter = -1;
		while(true){
			this->SlideSpeed = 2;
			
			if(this->Dir>-1)
				drawnDir = this->Dir;
			
			//The enemy can't walk into pits except in the knockback state
			this->MoveFlags[NPCMV_CAN_PIT_WALK] = false;
			switch(state){
				//Wandering about using 4-way movement
				case WANDERING:
					this->Slide();
					counter = __ConstWalk4(this, counter);
					if(coolownClock)
						--coolownClock;
					else if(Distance(this->X, this->Y, Link->X, Link->Y)<aggroRange){
						state = ATTACKING;
						chaseClock = chaseTime;
					}
					break;
				//Was just in a sword clash
				case STUNNED:
					this->Slide();
					this->MoveFlags[NPCMV_CAN_PIT_WALK] = true;
					if(knockbackClock){
						this->MoveAtAngle(knockbackAngle, SWORDCLASH_PUSH_SPEED, SPW_NONE);
						--knockbackClock;
					}
					if(stunClock)
						--stunClock;
					else{
						if(chaseClock){
							this->MoveFlags[NPCMV_CAN_PIT_WALK] = false;
							state = ATTACKING;
						}
						else{
							this->MoveFlags[NPCMV_CAN_PIT_WALK] = false;
							state = REALIGNING;
							realignPos = ComboAt(this->X+8, this->Y+8);
							realignX = this->X;
							realignY = this->Y;
						}
					}
					break;
				//Chase Link for a period of time
				case ATTACKING:
					int ang = Angle(this->X, this->Y, Link->X, Link->Y);
					this->Dir = AngleDir4(ang);
					this->MoveAtAngle(ang, chaseStep, SPW_NONE);
					this->Slide();
					if(chaseClock)
						--chaseClock;
					else{
						state = REALIGNING;
						realignPos = ComboAt(this->X+8, this->Y+8);
						realignX = this->X;
						realignY = this->Y;
					}
					break;
				//Use regular enemy movement for a period after chasing
				case REALIGNING:
					this->NoSlide = true;
					this->Slide();
					if(Distance(this->X, this->Y, realignX, realignY)>step){
						int ang = Angle(this->X, this->Y, ComboX(realignPos), ComboY(realignPos));
						realignX += VectorX(step, ang);
						realignY += VectorY(step, ang);
					}
					else{
						realignX = ComboX(realignPos);
						realignY = ComboY(realignPos);
						state = WANDERING;
						this->NoSlide = false;
						counter = -1;
					}
					this->X = realignX;
					this->Y = realignY;
					break;
			}
			
			//Scan over all weapons to find Link's sword and detect a collision with it
			if(hitbox->isValid()){
				for(int i=Screen->NumLWeapons(); i>0; --i){
					lweapon l = Screen->LoadLWeapon(i);
					if(l->ID==LW_SWORD||l->Weapon==LW_SWORD){
						if(SwordCollision(l, hitbox, drawnDir)&&state!=STUNNED){
							state = STUNNED;
							stunClock = SWORDCLASH_PUSH_TIME+SWORDCLASH_STUN_TIME;
							Game->PlaySound(SFX_SWORDCLASH);
							lweapon clash = CreateLWeaponAt(LW_SPARKLE, (l->X+hitbox->X+hitbox->HitXOffset)/2, (l->Y+hitbox->Y+hitbox->HitYOffset)/2);
							clash->UseSprite(SPR_SWORDCLASH);
							clash->CollDetection = false;
							
							knockbackClock = SWORDCLASH_PUSH_TIME;
							knockbackAngle = Angle(Link->X, Link->Y, this->X, this->Y);
							
							//Create a weapon script that runs the effect that pushes Link. This way even if the enemy dies that frame, Link still gets the full push.
							eweapon LinkPush = CreateEWeaponAt(EW_ENEMYSWORD, Link->X, Link->Y);
							LinkPush->CollDetection = false;
							LinkPush->DrawYOffset = -1000;
							LinkPush->Script = Game->GetEWeaponScript("LinkPushEffect");
							LinkPush->InitD[0] = WrapDegrees(knockbackAngle+180);
							LinkPush->InitD[1] = SWORDCLASH_PUSH_SPEED;
							LinkPush->InitD[2] = SWORDCLASH_PUSH_TIME;
							break;
						}
					}
				}
			}
			
			hitbox = UpdateEnemySword(this, hitbox, swordSprite, swordExtend, sideOffset, downOffset, drawnDir);
			UpdateAnimation(this, animData, state!=STUNNED, drawnDir);
			
			//Do cleanup of the sword when the enemy is dead
			if(this->HP<=0||this->Falling){
				this->Immortal = false;
				if(hitbox->isValid())
					hitbox->DeadState = 0;
				Quit();
			}
			Waitframe();
		}
	}
}

eweapon script LinkPushEffect{
	void run(int angle, int speed, int time){
		for(int i=0; i<time; ++i){
			LinkMovement_Push(VectorX(speed, angle), VectorY(speed, angle));
			Waitframe();
		}
		this->DeadState = 0;
	}
}