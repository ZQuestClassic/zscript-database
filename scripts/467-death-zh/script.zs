const int SFX_LINK_DEATH_SCREAM = 69; //Link`s scream SFX.

//--
//death.zh A library for making alternate death animations for Link.
//
//Requires ghost.zh
//Import and compile the library. Assign FFC script slots for death sequence scripts and test scripts.
//In subscreen editor, edit HP gauge, so "1 HP" tile looks like "0 HP/empty".
//
//A note for scripting custom death animations. Instead of Waitframe, use WaitNoAction to prevent escapes offscreen. 
//Also make sure Link is not moved by anything, like sideview gravity, again to prevent escapes.
//Always end those scripts with Link->HP=0; to kill Link for real.

//Main function that deals damage to Link and executes alternate death animation, if it drives Link`s HP to <= 0.
//Damage - damage
//Deathtype - FFC script slot number
//args - pointer for array, containing arguments for script
//scream - play SFX_LINK_DEATH_SCREAM sound in additional to and sounds played by script.
void AltDamageLink(int damage, int deathtype, int args, bool scream ){
	if (Link->HP<=1) return;
	if (Link->HP<=damage && deathtype>0){
		if (scream)Game->PlaySound(SFX_LINK_DEATH_SCREAM);
		Link->HP=1;
		ffc death = RunFFCScriptOrQuit(deathtype, args);
		death->X=Link->X;
		death->Y=Link->Y;
		Game->PlayMIDI(0);
	}
	else{
		eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, -1, -1, EWF_UNBLOCKABLE);
		e->Dir = Link->Dir;
		e->DrawYOffset = -1000;
		SetEWeaponLifespan(e, EWL_TIMER, 1);
		SetEWeaponDeathEffect(e, EWD_VANISH, 0);
	}
}

//Link gets cut in half. Blades, chompers, lasers etc.
//D0 - 0-sliced horizontally, 1-sliced vertically
//D1 - sprite for left/top half
//D2 - sprite for bottom/right half
//D3 - part flight speed
//D4 - sound to play at the start of horror
//D5 - total duration of sequence, in frames.
//D6 - >0 - Link`s remnants are affected by sideview gravity.
ffc script LinkDeathCutInHalf{
	void run (int dir, int tile1, int tile2, int speed, int sound, int duration, int grav){
		Game->PlaySound(sound);
		lweapon l1 = CreateLWeaponAt(LW_SCRIPT10, Link->X, Link->Y);
		lweapon l2 = CreateLWeaponAt(LW_SCRIPT10, Link->X, Link->Y);
		Link->Invisible=true;
		l1->UseSprite(tile1);
		l2->UseSprite(tile2);
		l1->CollDetection=false;
		l2->CollDetection=false;
		l1->DeadState=duration;
		l2->DeadState=duration;
		int l1x = l1->X;
		int l1y = l1->Y;
		int l2x = l2->X;
		int l2y = l2->Y;
		if (IsSideview()&& grav>0){
			int dir1=Rand(45)+90;
			int dir2=Rand(45)+45;
			int lv1=Sin(dir1)*-speed;
			int lv2=Sin(dir2)*-speed;
			for (int i =0;i<duration;i++){
			//speed+=0.05;
				if (l1->isValid()){
					l1x-=speed;
					l1->X=l1x;
					lv1=Min(TERMINAL_VELOCITY, lv1+GRAVITY);
					l1y+=lv1;
					l1->Y=l1y;
				}
				if (l2->isValid()){
					l2x+=speed;
					l2->X=l2x;
					lv2=Min(TERMINAL_VELOCITY, lv2+GRAVITY);
					l2y+=lv2;
					l2->Y=l2y;
				}
				Link->Jump=0;
				WaitNoAction();
			}
		}
		else{
			for (int i =0;i<duration;i++){
				if (dir==0){
				l1x-=speed;
				l2x+=speed;
					l1->X=l1x;
					l2->X=l2x;
				}
				else{
					l1y-=speed;
				l2y+=speed;
					l1->Y=l1y;
					l2->Y=l2y;
				}
				Link->Jump=0;
				WaitNoAction();
			}
		}
		Link->HP=0;
	}
}

//Link gets blasted into stuff. Explosives, curses etc.
//D0 - Blast size: 0-normal, 1-super
//D1 - Sprite used for remnants
//D2 - Remnant splatter area, in tiles
//D3 - total duration of sequence, in frames.
ffc script LinkDeathExplosion{
	void run (int size, int splash, int splashsize, int duration){
		Game->PlaySound(3);
		Link->Invisible=true;
		lweapon l;
		if (size>0)l=CreateLWeaponAt(LW_SBOMBBLAST, Link->X, Link->Y);
		else l=CreateLWeaponAt(LW_BOMBBLAST, Link->X, Link->Y);
		l->CollDetection=false;
		lweapon s=CreateLWeaponAt(LW_SCRIPT10, Link->X-splashsize*8+8, Link->Y-splashsize*8+8);
		s->UseSprite(splash);
		s->DeadState=duration;
		s->Extend=3;
		s->CollDetection=false;
		s->TileWidth=splashsize;
		s->TileHeight = splashsize;
		for (int i =0;i<duration;i++){
		Link->Jump=0;
		WaitNoAction();
		}
		Link->HP=0;
	}
}

//Burnt to nothing by hell fire. Anything fire-based
//D0 - delay between spawning flames, in frames.
//D1 - total duration of sequence, in frames.
ffc script LinkDeathFire{
	void run(int rate, int duration){
		for (int i =duration;i>0;i--){
			if (i>duration/3 && i%3==0){
			Game->PlaySound(SFX_FIRE);
				lweapon s=CreateLWeaponAt(LW_FIRE, Link->X-8+Rand(16), Link->Y-8+Rand(16));
				s->CollDetection=false;
			}
			Link->Invisible=true;
			Link->Jump=0;
			WaitNoAction();
		}
		Link->HP=0;
	}
}

//Generic Link death animation. Frozen, Petrified, impaled etc. 
//D0 - Sprite used for remnants
//D1 - sound to play at the start of horror
//D2 - Remnant splatter area, in tiles
//D3 - >0 - Link`s remnants are affected by sideview gravity.
//D4 - total duration of sequence, in frames.
//D5 - initial upwards velocity
ffc script LinkDeathGeneric{
	void run(int sprite, int sound, int splashsize, int grav, int duration, int vel){
		Game->PlaySound(sound);
		Link->Invisible=true;
		lweapon s=CreateLWeaponAt(LW_SCRIPT10, Link->X-splashsize*8+8, Link->Y-splashsize*8+8);
		s->UseSprite(sprite);
		s->DeadState=duration;
		s->CollDetection=false;
		s->Extend=3;
		s->TileWidth=splashsize;
		s->TileHeight = splashsize;
		int ly=s->Y;
		vel*=-1;
		if (!IsSideview())vel=0;
		for (int i =0;i<duration;i++){
			if (grav>0 && IsSideview()){
				vel=Min(TERMINAL_VELOCITY, vel+GRAVITY);
				ly = s->Y+vel;
				s->Y=ly;
			}
			Link->Jump=0;
			WaitNoAction();
		}
		Link->HP=0;
	}
}

//Guillotine - cuts in half, if touched, when it has positive Vy
//D0 - death animation script slot
//D1 - Sprite for left remnant
//D2 - sprite for right remnant
//D3 - sound on slice
ffc script Guillotine{
	void run(int scr, int spr1, int spr2, int sfx){
		while(true){
			if (LinkCollision(this) && this->Vy>0){
				int args[]={1, spr1,spr2,2,sfx,128,1};
				AltDamageLink(10000, scr, args, false);
			}
			Waitframe();
		}		
	}
}

//crusher - Reduces one into nothing but bloody smear on actual stomp, or performs one funny death animation
//D0 - script alot for crushing death
//D1 - remnant sprite size
//D2 - remnant sprite slot
//D3 - crush sound
//D4 - script slot for alternate death
//D5 - sprite slot for alternate death
//D6 - sound for alternate death
ffc script Crusher{
	void run(int scr, int spr,int sprsize, int sfx,int altscr, int altspr, int altsfx){
		while(true){
			if (LinkCollision(this) && this->Vy>0 && Link->Y>(this->Y+this->EffectHeight-8)){
				int args[]={spr, sfx,sprsize,0,128,0};
				AltDamageLink(10000, scr, args, true);
			}
			else if (LinkCollision(this)){
				int args[]={altspr, altsfx,1,1,180,4};
				AltDamageLink(10000,altscr , args, false);
			}
			Waitframe();
		}		
	}
}

//Laser - cuts into pieces on touch
//D0 - death animation script slot
//D1 - remnant sprite slot
//D2 - sound on death
//D3 - remnant sprite size
ffc script RE_Laser{
	void run(int scr, int spr, int sfx, int sprsize){
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				int args[]={spr, sfx,sprsize,0,128,0};
				AltDamageLink(10000, scr, args, true);
			}
			Waitframe();
		}
	}
}

//Laser slices in half vertically on touch.
//D0 - script alot for crushing death
//D1 - Sprite for left remnant
//D2 - sprite for right remnant
//D3 - sound on slice
ffc script RE_Laser2{
	void run(int scr,int spr1,int spr2, int sfx){
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				int args[]={1, spr1,spr2,0.5,sfx,128,1};
				AltDamageLink(10000, scr, args, true);
			}
			Waitframe();
		}
	}
}

//Laser slices in half horizontally on touch.
//D0 - script alot for crushing death
//D1 - Sprite for left remnant
//D2 - sprite for right remnant
//D3 - sound on slice
ffc script RE_LaserHoriz{
	void run(int scr, int spr1, int spr2, int sfx){
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				int args[]={0, spr1,spr2,0.5,sfx,128,1};
				AltDamageLink(10000, scr, args, true);
			}
			Waitframe();
		}
	}
}

//Megaman x Castlevania spikes. Explode into ridiclous gibs on tough.
//D0 - death animation script slot
//D1 - remnant sprite slot
//D2 - remnant sprite size
ffc script KillerSpikes{
	void run(int scr, int spr, int sprsize){
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				int args[]={1, spr,sprsize,128};
				AltDamageLink(10000, scr, args, true);
			}
			Waitframe();
		}
	}
}

//Lava - incenerates on touch
//D0 - fiery death animation script slot
ffc script KillerLava{
	void run(int scr){
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				int args[]={4, 128};
				AltDamageLink(10000, scr, args, true);
			}
			Waitframe();
		}
	}
}