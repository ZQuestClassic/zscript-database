//Water drip

//D0 - The Y position on the screen the water will drop from. If set to 0 will default to -16.
//D1 - Amount of frames before the initial drip. If set to 0 will default to 20.
//D2 - Amount of frames before another drip. If set to 0 will defualt to 160.
//D3 - Max amount of random frames added to the D2 delay.
//D4 - Sprite ID to use for the ripple when landing. If set to 0 will default to 137 (for personal reasons deal with it :) )
//D5 - ID of SFX to play when drip lands.
//D6 - Velocity of water drop. If set to 0 will default to 2.

//Place an FFC on the screen with the graphic of your drip in the location it should drip to and assign this script and the variables.
//Set the flag "Run Script at Screen Init" to avoid the drip being visible on-screen before it falls. Also recommended to set the "Draw Over" flag.

const int DRIP_BLANK_COMBO = 25; //Set to a the ID of a blank combo

ffc script ceilingDrip {
	void run(int dropheight, int initdelay, int repeatdelay, int rand_delay_max, int ripple_sprite, int sound, int velocity) {
		//Determine and store initial data
		int dripcombo = this->Data;
		int targetX = this->X;
		int targetY = this->Y;
		
		//Set default values
		if (repeatdelay == 0) repeatdelay = 160;
		if (ripple_sprite == 0) ripple_sprite = 137;			//Change this 137 to the ID of your ripple sprite so you don't have to set D4 every time!
		if (dropheight == 0) dropheight = -16;
		if (velocity == 0) velocity = 2;
		
		this->Y = dropheight;
		if (initdelay) Waitframes(initdelay);
		else Waitframes(20);

		//Drippin time
		while (true) {
			
			if (this->Y <= targetY) {
				this->Data = dripcombo;
				this->Ay = Game->Gravity[GR_STRENGTH];;
				this->Vy = velocity;
			}
			
			else if (this->Y >= targetY) {
				this->Ay = 0;
				this->Vy = 0;
				this->Data = DRIP_BLANK_COMBO;
				if (sound) { Game->PlaySound(sound); }
			    lweapon dripp = CreateLWeaponAt(LW_SPARKLE, targetX, targetY);
				dripp->UseSprite(ripple_sprite);
				dripp->CollDetection = false;
				this->Y = dropheight;
				Waitframes(repeatdelay+Rand(rand_delay_max));
			}
			
			Waitframe();
		}
	}
}