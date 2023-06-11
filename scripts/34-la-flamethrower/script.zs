ffc script LA_Flamethrower{ //The Flame Shooter from LA. Seen in the cave leading up to Turtle Rock, it fires flames in one direction at a rapid pace. D0 is for the direction it fires in (0 = Up, 1 = Down, 2 = Left, 3 = Right), D1 is how frequently it shoots flames and D2 is the amout of damage that the flames do to Link.
	void run(int direction, int frequency, int damage){ //Declares all of the D-variables.
		int counter; //Declares the counter variable.
		eweapon weapon;
		while(true){ //So that this will run on the screen indefinetley.
			if(counter % frequency == frequency - 1){ //Every frequency frames...
				weapon = CreateEWeaponAt(EW_FIRE, this->X, this->Y); //Fire the EWeapon.
				if(damage == 0){ //Set the amount damage it causes to Link in quarter hearts. Default to 16, which is four hearts (The same strengh as the flames it spewed out in LA).
					weapon->Damage = 16;
				}
				else if(damage == -1){ //Set damage to -1 so that it will spew out flames that only serve to tickle Link.
					weapon->Damage = 0;
				}
				else{ //If damage is set to anything else, leave it as is.
					weapon->Damage = damage;
				}
				Game->PlaySound(SFX_FIRE); //Play the Fire SFX.
				weapon->Dir = direction; //Set its direction.
			}
			counter ++; //Increments the counter variable.
			Waitframe(); //The Waitframe. Every while-loop MUST have one or the game will freeze!
		}
	}
}