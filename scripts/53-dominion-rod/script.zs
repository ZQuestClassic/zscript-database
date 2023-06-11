//Constants used by Dominion Rod scripts.
const int I_DOMINIONROD = 123; //The ID of the item.
const int LW_DOMINIONSPHERE = 31; //The scripted weapon for the projectile. Legal values 31-40.
const int LW_DAMAGE = 32; //The scripted weapon to use to make the statues do damage. Legal values 31-40.
const int TILE_BLANK = 65519; //A blank tile, legal values 0 - 65519.

//This function should only appear in your script file only once.
bool UsedItem(int id){
	return ((GetEquipmentA() == id && Link->PressA) || (GetEquipmentB() == id && Link->PressB));
}

item script DominionRod{
	void run(int ffcScriptNum, int step, int sprite, int sound, int rotate){
		//Check if the script "DominionSphere" is not already running.
		if(CountFFCsRunning(ffcScriptNum) == 0){
			//Make an ffc run the script or quit if no ffcs are available.
			int args[8] = {step, sprite, sound, rotate};
			RunFFCScriptOrQuit(ffcScriptNum, args);
		}
		else{
			//Find the ffc running the script and end it's execution.
			ffc f = Screen->LoadFFC(FindFFCRunning(ffcScriptNum));
			f->Script = 0;
		}
	}
}

ffc script DominionSphere{
	void run( int step, int sprite, int sound, bool rotate){
		//Create the sphere 8 pixels away from where Link is facing.
		lweapon sphere = NextToLink(LW_DOMINIONSPHERE, 8);
		//Turn off collision for the newly created weapon.
		sphere->CollDetection = false;
		//Set it's sprite, step, and direction,
		sphere->UseSprite(sprite);
		sphere->Step = step;
		sphere->Dir = Link->Dir;
		//Rotate it appropiately based on direction if rotate is true.
		if(rotate){
			if(sphere->Dir == DIR_DOWN) sphere->Flip = 3;
			else if(sphere->Dir == DIR_LEFT) sphere->Flip = 7;
			else if(sphere->Dir == DIR_RIGHT) sphere->Flip = 4;
		}
		//Play the firing sound effect.
		Game->PlaySound(sound);
		//Loop until the sphere becomes invalid.
		while(sphere->isValid()){
			//Kill the lweapon when it reaches the edge of the screen.
			if(sphere->Dir == DIR_UP && sphere->Y - (step/100) < 1) sphere->DeadState = WDS_DEAD;
			else if(sphere->Dir == DIR_DOWN && sphere->Y + (step/100) >= 160) sphere->DeadState = WDS_DEAD;
			else if(sphere->Dir == DIR_LEFT && sphere->X - (step/100) < 1) sphere->DeadState = WDS_DEAD;
			else if(sphere->Dir == DIR_RIGHT && sphere->X + (step/100) >= 240) sphere->DeadState = WDS_DEAD;
			//Waitframe to prevent lagging.
			Waitframe();
		}
	}
}

ffc script DominionStatue{
	void run(float velocity, int damage, int sound1, int sound2){
		//Declare a boolean to track whether it's active or not.
		bool active;
		//Declare a lweapon to be used to damage enemies;
		lweapon edamage;
		//Initialize a variable to store the starting data for the ffc.
		int combo = this->Data;
		//Loop indefinately;
		while(true){
			//Load the dominion sphere to a pointer.
			lweapon sphere = LoadLWeaponOf(LW_DOMINIONSPHERE);
			if(edamage->isValid()) edamage->DeadState = WDS_DEAD;
			//Check if the statue is being controlled.
			if(active){
				//Check if Link did NOT just use the Dominion Rod.
				if(!UsedItem(I_DOMINIONROD)){
					//Check if the statue can move in the direction link is facing.
					if(CanMove(this, velocity, Link->Dir)){
						//Change the ffc's combo to the moving combo.
						this->Data = combo + Link->Dir + 8;
						//Move in the direction Link is facing.
						if(Link->Dir == 0) this->Y -= velocity;
						else if(Link->Dir == 1) this->Y += velocity;
						else if(Link->Dir == 2) this->X -= velocity;
						else if(Link->Dir == 3) this->X += velocity;
					}
					else{
						//Change the ffc's combo to the idle combo.
						this->Data = combo + Link->Dir + 4;
					}
				}
				else{
					//Change the ffc's combo to the deactivated combo;
					this->Data = combo + Link->Dir;
					//Remove the sphere lweapon.
					sphere->DeadState = WDS_DEAD;
					//Set the flag active to false.
					active = false;
					//Play the deactivation sound.
					Game->PlaySound(sound2);
				}
				//Create an lweapon at the ffc's position to damage enemies.
				if(damage > -1){
					edamage = Screen->CreateLWeapon(LW_DAMAGE);
					edamage->X = this->X;
					edamage->Y = this->Y;
					edamage->Tile = TILE_BLANK;
					edamage->Damage = damage;
				}
			}
			//Otherwise check if sphere is valid.
			else if(sphere->isValid()){
				//Check if the sphere collided with the ffc.
				if(Collision(sphere, this)){
					//Set the sphere's step to 0, change it's tile to blank, and null it's animation.
					sphere->Step = 0;
					sphere->OriginalTile = TILE_BLANK;
					sphere->Tile = TILE_BLANK;
					sphere->NumFrames = 1;
					//Set active to true.
					active = true;
					//Change the ffc's combo to the active combo.
					this->Data = combo + 4;
					//Play the activation sound.
					Game->PlaySound(sound1);
				}
			}
			//Waitframe to prevent lagging.
			Waitframe();
		}
	}
	//This function is used to determine if the statue can move in the given direction.
	bool CanMove(ffc this, float velocity, int dir){
		//Initialize a boolean as true.
		bool condition = true;
		//Go through the loop 16 times.
		for(int i; i < 16; i++){
			//Check for solidity.
			if(dir == 0 && Screen->isSolid(this->X + i, this->Y - velocity)) condition = false;
			else if(dir == 1 && Screen->isSolid(this->X + i, this->Y + 15 + velocity)) condition = false;
			else if(dir == 2 && Screen->isSolid(this->X - velocity, this->Y + i)) condition = false;
			else if(dir == 3 && Screen->isSolid(this->X + 15 + velocity, this->Y + i)) condition = false;
			//Only do the rest of the loop for the first and last iteration of the loop.
			if(i == 0 || i == 15){
				//Check for water.
				if(dir == 0 && IsWater(ComboAt(this->X + i, this->Y - velocity))) condition = false;
				else if(dir == 1 && IsWater(ComboAt(this->X + i, this->Y + 15 + velocity))) condition = false;
				else if(dir == 2 && IsWater(ComboAt(this->X - velocity, this->Y + i))) condition = false;
				else if(dir == 3 && IsWater(ComboAt(this->X + 15 + velocity, this->Y + i))) condition = false;
				//Check for pits.
				if(dir == 0 && IsPit(ComboAt(this->X + i, this->Y - velocity))) condition = false;
				else if(dir == 1 && IsPit(ComboAt(this->X + i, this->Y + 15 + velocity))) condition = false;
				else if(dir == 2 && IsPit(ComboAt(this->X - velocity, this->Y + i))) condition = false;
				else if(dir == 3 && IsPit(ComboAt(this->X + 15 + velocity, this->Y + i))) condition = false;
			}
		}
		//Return the boolean we declared at the beginning of the function.
		return condition;
	}
}

ffc script DominionSwitch{
	void run(int ffcScriptNum, int data, int cset, bool permanent){
		//Initialize a boolean as the state of permanent secrets.
		bool gothit = Screen->State[ST_SECRET];
		//Loop until gothit is true.
		while(!gothit){
			//Loop through each ffc.
			for(int i = 1; i <= 32; i++){
				//Load the ffc to a pointer.
				ffc f = Screen->LoadFFC(i);
				//Continue if the script number of the ffc we loaded and ffcScriptNum don't Match.
				if(f->Script != ffcScriptNum) continue;
				//Continue if there's no collision between the two ffcs.
				if(!SquareCollision(f->X, f->Y, 16, this->X + 4, this->Y + 4, 8)) continue;
				//Set gothit to true.
				gothit = true;
				//Break out of the loop.
				break;
			}
			//Waitframe to prevent lagging.
			Waitframe();
		}
		//Change the combo data and cset of the combo beneath this ffc to data and cset respectfully.
		int comboLoc = ComboAt(this->X, this->Y);
		Screen->ComboD[comboLoc] = data;
		Screen->ComboC[comboLoc] = cset;
		//Quit if there are more switches or if screen secrets is true.
		if(Screen->State[ST_SECRET] || CountFFCsRunning(this->Script) > 1) Quit();
		//Trigger Secrets, and make them permanent if they need to be.
		Screen->TriggerSecrets();
		if(permanent)Screen->State[ST_SECRET] = true;
		//Play the secret sound.
		Game->PlaySound(SFX_SECRET);
	}
}