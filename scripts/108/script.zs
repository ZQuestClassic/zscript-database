// FFC Script to Fire EWeapons at Link at certain speeds and intervals
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
	// d2 = Frequency (60 is about 1 second) (DEFAULT: 120)
	// d3 = Speed (100 = 60 pixels a second) (DEFAULT: 100)
	// d4 = Damage (DEFAULT: 1)
	// d5 = Sound effect (DEFAULT: SFX_FIREBALL)
	// d6 = Initial Delay before firing
	// d7 = Flags
		// 1 = Unblockable
		// 2 = Stops when the FFC's combo changes
		// 3 = Unblockable and stops when the FFC's combo changes
ffc script ffcShooter
{
	void run(int weaponID, int dir, int frequency, int speed, int damage, int soundeffect, int initDelay, int flags)
	{

		// Create defaults for weapon IDs
		if(weaponID == 0)
			weaponID = EW_FIREBALL;
		else if(weaponID == 1)
			weaponID = EW_FIREBALL2;
		else if(weaponID == 2)
			weaponID = EW_ROCK;
		else if(weaponID == 3)
			weaponID = EW_FIRE;
		else if(weaponID == 4)
			weaponID = EW_FIRE2;
		else if(weaponID == 5)
			weaponID = EW_WIND;
		else if(weaponID == 6)
			weaponID = EW_BOMB;
			
		// Create defaults for other values
		if(frequency == 0)
			frequency = 120;
		if(speed == 0)
			speed = 100;
		if(damage == 0)
			damage = 1;
		if(soundeffect == 0)
			soundeffect = SFX_FIREBALL;
			
		int counter = 0;
		int startingCombo = this->Data;
			
		// Delay for the initial amount of time
		Waitframes(initDelay);
		
		// Continue forever if it's not set to end when the combo change... or end if the combo changed
		while(flags <= 1 || this->Data == startingCombo)
		{
		
			if(counter == 0)
			{
			
				// Play the sound effect
				if(soundeffect > 0)
					Game->PlaySound(soundeffect);
				
				// Here we go ahead and create the weapon
				eweapon weapon = Screen->CreateEWeapon(weaponID);
				weapon->X = this->X + this->EffectWidth/2 - 8;
				weapon->Y = this->Y + this->EffectHeight/2 - 8;
				weapon->Damage = damage;
				weapon->Step = speed;
				
				// If no proper direction was set, have it fire at Link
				if(dir < 1 || dir > 9)
				{
					weapon->Angular = true;
					weapon->Angle = RadianAngle(this->X + this->EffectWidth/2 - 8, this->Y + this->EffectHeight/2 - 8, Link->X+8, Link->Y+8);
					weapon->Dir = RadianAngleDir8(weapon->Angle);
				}
				// Else a proper direction was set, so set it to that
				else
					weapon->Dir = dir-1;
				
				// Up the weapon's dir if it was set as unblockable
				if(flags == 1 || flags == 3)
					weapon->Dir += 8;
			}
			
			
			counter = (counter+1)%frequency;	
			Waitframe();
		} //! End of while(flags <= 1 || this->Data == startingCombo)
	} //! End of void run(int weaponID, int dir, int frequency, int speed, int damage, int soundeffect, int initDelay, int flags)
} //! End of ffc script ffcShooter