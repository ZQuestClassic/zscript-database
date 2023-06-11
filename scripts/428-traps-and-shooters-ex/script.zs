// Rotating Cannon trap. Fires eweapons then rotates
	// d0 = The weapon ID to fire.  Can use EW_ constants or... (DEFAULT: fireball)
		// 0 = Fireball
		// 1 = Boss fireball
		// 2 = Rock
		// 3 = Fire (short distance)
		// 4 = Fire (long distance)
		// 5 = Wind
		// 6 = Bomb
	// d1 = Direction to fire in.  For DIR_ constants, add 1 to them (DEFAULT: at link)
		// 0 = At Link
		// 1 = Up
		// 2 = Down
		// 3 = Left
		// 4 = Right
		// 5 = Left Up
		// 6 = Right Up
		// 7 = Left Down
		// 8 = Right Down
	// d2 = #####.___ = Frequency (60 is about 1 second) (DEFAULT: 120)
	//	   _____.#### = Initial Delay before firing, in frames
	// d3 = Speed (100 = 60 pixels a second) (DEFAULT: 100)
	// d4 = Damage (DEFAULT: 1)
	// d5 = Sound effect (DEFAULT: SFX_FIREBALL)
	// d6 = rotaion rate after every shot, in multiples of 45 degrees.
	// d7 = Flags, add together
		// 1 = Unblockable
		// 2 = Stops when the FFC's combo changes
		// 4 = Rotating eweapon sprite
ffc script RotatingShooter{
	void run(int weaponID, int dir, int frequency, int speed, int damage, int sound, int rotspeed, int flags){
		
		// Create defaults for weapon IDs
		if(weaponID == 0)	weaponID = EW_FIREBALL;
		else if(weaponID == 1)	weaponID = EW_FIREBALL2;
		else if(weaponID == 2)	weaponID = EW_ROCK;
		else if(weaponID == 3)	weaponID = EW_FIRE;
		else if(weaponID == 4)	weaponID = EW_FIRE2;
		else if(weaponID == 5)	weaponID = EW_WIND;
		else if(weaponID == 6)	weaponID = EW_BOMB;
			
		// Create defaults for other values
		//if(frequency == 0)frequency = 120;
		if(speed == 0)	speed = 100;
		if(damage == 0)damage = 2;
		if(sound == 0)sound = SFX_FIREBALL;
			
		int counter = 0;
		int startingCombo = this->Data;
		bool aimed = false;
		if(dir <= 0 || dir > 9)aimed = true;
		else dir--;
		
		int initDelay = GetLowFloat(frequency);
		frequency = GetHighFloat(frequency);
		
		// Delay for the initial amount of time
		Waitframes(initDelay);
		
		// Continue forever if it's not set to end when the combo change... or end if the combo changed
		while(flags <= 1 || this->Data == startingCombo){		
			if(counter == 0){
				int eflags = EWF_ROTATE_360;
				if ((flags&4)==0) eflags=0;
				if ((flags&1)>0) eflags+=EWF_UNBLOCKABLE;
							
				eweapon e;
				if (aimed) e = FireAimedEWeapon(weaponID, CenterX(this)-4, CenterY(this)-4, 0,speed, damage, -1, sound, eflags);
				else e= FireNonAngularEWeapon(weaponID, CenterX(this)-4, CenterY(this)-4, dir, speed, damage, -1, sound, eflags);
				
				dir = RotDir(dir, rotspeed);
			}
			counter = (counter+1)%frequency;
			Waitframe();
		}
	} 
}

// Timed MachineGun trap. Fires volleys of eweapons at regular intervals	
	// d0 = Direction to fire in.  For DIR_ constants, add 1 to them (DEFAULT: at link)
		// 0 = At Link
		// 1 = Up
		// 2 = Down
		// 3 = Left
		// 4 = Right
		// 5 = Left Up
		// 6 = Right Up
		// 7 = Left Down
		// 8 = Right Down
	// d1 = Damage (DEFAULT: 1)
	// d2 = #####.___ = Frequency (60 is about 1 second) (DEFAULT: 120)
	//	   _____.#### = Initial Delay before firing, in frames
	// d3 = firing rate - delay (in frames) between shots in each volley	
	// d4 = The weapon ID to fire.  Can use EW_ constants or... (DEFAULT: fire, like flamethrower)
		// 0 = Fireball
		// 1 = Boss fireball
		// 2 = Rock
		// 3 = Fire (short distance)
		// 4 = Fire (long distance)
		// 5 = Wind
		// 6 = Bomb
	// d5 = Speed (100 = 60 pixels a second) (DEFAULT: 100)
	// d6 = Flags, add together
		// 1 = Unblockable
		// 2 = Stops when the FFC's combo changes
		// 4 = Rotating eweapon sprite
	// d7 = Sound effect (DEFAULT: SFX_FIRE)

ffc script TimedMachinegunTrap{
	void run (int dir, int damage, int frequency, int rate, int weaponID, int speed, int flags, int sound){
		if(frequency == 0)frequency = 90;
		if(rate==0) rate = 4;
		if(speed == 0)	speed = 180;
		if(damage == 0)damage = 2;
		if (weaponID==0) weaponID = EW_FIRE;
		
		
		int counter = 0;
		int rcounter = 0;
		int startingCombo = this->Data;
		bool aimed = false;
		if(dir < 1 || dir > 9)aimed = true;
		else dir--;
		
		int initDelay = GetLowFloat(frequency);
		frequency = GetHighFloat(frequency);
		
		// Delay for the initial amount of time
		Waitframes(initDelay);
		// Continue forever if it's not set to end when the combo change... or end if the combo changed
		while(((flags&2)>0) || this->Data == startingCombo){
					
			if(rcounter == 0 && counter<frequency){			
				Game->PlaySound(sound);
				
				int eflags = EWF_ROTATE_360;
				if ((flags&4)==0) eflags=0;
				if ((flags&1)>0) eflags+=EWF_UNBLOCKABLE;
						
				eweapon e;
				if (aimed) e = FireAimedEWeapon(weaponID, CenterX(this)-4, CenterY(this)-4, 0,speed, damage, -1, sound, eflags);
				else e= FireNonAngularEWeapon(weaponID, CenterX(this)-4, CenterY(this)-4, dir, speed, damage, -1, sound, eflags);
			}
			counter = (counter+1)%(frequency*2);
			rcounter = (rcounter+1)%rate;	
			Waitframe();
		}
	}
}


//Electric floor trap. Zaps Link when activated if Link was standing on.
// D0 - damage
// D1 - Initial Delay before activating, in frames
// D2 - Frequency (60 is about 1 second) (DEFAULT: 120)
// D3 - Sprtite used to shock Link, 1 frame.
// D4 - Sound effect on activating
// D5 - Sound effect on shock Link
ffc script ElectricFloorTrap{
	void run(int damage, int initDelay, int frequency, int shocksprite, int sfx, int shocksfx){
		if(frequency == 0)frequency = 120;
		if(damage == 0)damage = 1;
		
		int counter = 0;
		int origcmb = this->Data;
		bool on = false;
		bool shocked = false;
		Waitframes(initDelay);
		while(true){
			if(counter == 0 ){			
				if (on==false){
					Game->PlaySound(sfx);
					this->Data = origcmb+1;
					on = true;
				}
				else{
					this->Data = origcmb;
					on = false;
					shocked = false;
				}
			}
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (!shocked && on && Link->Z==0){
					eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, shocksprite, shocksfx, EWF_UNBLOCKABLE);
					e->Dir = Link->Dir;
					SetEWeaponLifespan(e, EWL_TIMER, e->NumFrames*e->ASpeed*8);
					SetEWeaponDeathEffect(e, EWD_VANISH, 0);					
					shocked=true;
				}
			}
			counter = (counter+1)%(frequency*2);
			Waitframe();
		}
	}
}

//Spawn 2 Rotating Cannons firing in opposite directions.
//Init Ds are the same as for Rotating Shooter
ffc script DoubleCannonSpawner{
	void run(int weaponID, int dir, int frequency, int speed, int damage, int sound, int rotspeed, int flags){
		int str[] = "RotatingShooter";
		int scr = Game->GetFFCScript(str);
		int args[8] = {weaponID, dir, frequency, speed, damage, sound, rotspeed, flags};
		ffc f = RunFFCScriptOrQuit(scr, args);
		f->X = this->X;
		f->Y = this->Y;
		dir--;
		dir = RotDir(dir, 4);
		dir++;
		args[1] = dir;
		f = RunFFCScriptOrQuit(scr, args);
		f->X = this->X;
		f->Y = this->Y;
	}
}


//Spawn 4 Rotating Cannons firing in cross shape, like in SMB3.
//Init Ds are the same as for Rotating Shooter
ffc script QuadCannonSpawner{
	void run(int weaponID, int dir, int frequency, int speed, int damage, int sound, int rotspeed, int flags){
		int str[] = "RotatingShooter";
		int scr = Game->GetFFCScript(str);
		int args[8] = {weaponID, dir, frequency, speed, damage, sound, rotspeed, flags};
		for (int i=1; i<=4; i++){
			dir--;
			dir = RotDir(dir, 2);
			dir++;
			args[1] = dir;
			ffc f = RunFFCScriptOrQuit(scr, args);
			f->X = this->X;
			f->Y = this->Y;
		}
	}
}

int RotDir(int dir, int num){
	int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
	int idx=-1;
	for (int i=0; i<8; i++){
		//Trace(dirs[i]);
		if (dirs[i] == dir){
			idx=i;
			break;
		}
	}
	if (idx<0) return -1;
	idx+=num;
	while (idx<0) idx+=8;
	while (idx>=8) idx-=8;
	return dirs[idx];
}