//Timed projetile shooter trap.

//D0 - Damage dealt on hit, in 1/4ths of heart
//D1 - Eweapon type. Refer to std_constants.zh for finding ID`s of various eweapon types.
//D2 - Sprite used. Leave as 0 for sprite default to eweapon type.
//D3 - Projectile speed, in 1/100`s of pixel per frame.
//D4 - Delay between firing projetiles, in frames.
//D5 - Firing direction. Use positive value for shooting in specific direction or negatives for automatic aiming.
//	Use AT_* constants from std_functions.zh for verious aim types. The number must be multiplied by -1 and then passed as argument.
//D6 - Fire eweapon at sript init. 0 - false, 1 - true.
//D7 - Sound to play on firing eweapon.

ffc script TimedShooter{
	void run(int damage, int type, int sprite, int speed, int time, int direction, int instant, int sound){
		int timer= time;
		if (instant>0){
			Game->PlaySound(sound);
			eweapon wpn = Screen->CreateEWeapon(type);
			wpn->Damage=damage;
			if (sprite>0) wpn->UseSprite(sprite);
			wpn->X=this->X;
			wpn->Y=this->Y;
			wpn->Step=speed;
			if (direction<0) AimEWeapon(wpn, -direction);
			else wpn->Dir=direction;
			EweaponSpriteFlip (wpn);
		}
		while (true){
			timer--;
			if (timer<=0){
				Game->PlaySound(sound);
				eweapon wpn = Screen->CreateEWeapon(type);
				wpn->Damage=damage;
				if (sprite>0) wpn->UseSprite(sprite);
				wpn->X=this->X;
				wpn->Y=this->Y;
				wpn->Step=speed;
				if (direction<0) AimEWeapon(wpn, -direction);
				else wpn->Dir=direction;
				EweaponSpriteFlip (wpn);
				timer=time;
			}
			Waitframe();
		}
	}
}

void EweaponSpriteFlip (eweapon l){
	int dir = l->Dir;
 	if ((dir==DIR_UP)||(dir==8)) l->Flip=0;
	else if ((dir==DIR_DOWN)||(dir==12)) l->Flip=2;
	else if ((dir==DIR_LEFT)||(dir==14)) l->Flip=5;
	else if ((dir==DIR_RIGHT)||(dir==10)) l->Flip=4;
	else if ((dir==DIR_RIGHTUP)||(dir==9))l->Flip=0;
	else if ((dir==DIR_LEFTUP)||(dir==15)) l->Flip=1;
	else if ((dir==DIR_LEFTDOWN)||(dir==13)) l->Flip=3;
	else if ((dir==DIR_RIGHTDOWN)||(dir==11)) l->Flip=2;
}