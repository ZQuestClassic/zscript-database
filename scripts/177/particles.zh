//Particles.zh
//A header used to create particle effects based on Lweapons
//
//Unlike Grayswandir`s animation.zh it has more features regarding controlling particle movement.
//as well as creating bigger particles.

const int LW_PARTICLE = 31; //Animation Lweapon ID. Set it so it does not conflict with other scripts.

//Lweapon misc variables
const int LWEAPON_MISC_ANIMATION_VX = 1; //"Vertical velocity" misc variable.
const int LWEAPON_MISC_ANIMATION_VY = 2; //"Horizontal velocity" misc variable.
const int LWEAPON_MISC_ANIMATION_AX = 3; //"Horizontal Acceleration" misc variable.
const int LWEAPON_MISC_ANIMATION_AY = 4; //"Vertical Acceleration" misc variable.
const int LWEAPON_MISC_ANIMATION_TIMEOUT = 5; //"Particle Lifespan" misc variable.
const int LWEAPON_MISC_ANIMATION_AFFECTED_BY_GRAVITY = 6; //"Gravity boolean" misc variable. Used in sideview areas.
const int LWEAPON_MISC_ANIMATION_XPOS = 7; //"Paeticle X position" misc variable.
const int LWEAPON_MISC_ANIMATION_YPOS = 8; //"Paeticle Y position" misc variable.

global script Animations{
	void run(){
		while (true){
			Waitdraw();
			UpdateAnimations(); //Place this function between "Waitdraw" and "Waitframe" when combining with other global scripts.
			Waitframe();
		}
	}
}

// Creates a particle. Setting lifespan to -2 sets it to one full animation cycle.
lweapon CreateAnimation (int x, int y, int sprite, int ax, int ay, int vx, int vy, int lifespan, bool grav){
	lweapon anim = Screen->CreateLWeapon(LW_PARTICLE);
	anim->X = x;
	anim->Y = y;
	anim->UseSprite(sprite);
	anim->CollDetection = false; //No one should want for any NPC do destroy particle by stepping on it`s spawn point.
	anim->Misc[LWEAPON_MISC_ANIMATION_VX] = vx;
	anim->Misc[LWEAPON_MISC_ANIMATION_VY] = vy;
	anim->Misc[LWEAPON_MISC_ANIMATION_AX] = ax;
	anim->Misc[LWEAPON_MISC_ANIMATION_AY] = ay;
	if (lifespan == -2){
		anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT] = (anim->ASpeed)*(anim->NumFrames);
	}
	else anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT] = lifespan;
	if (grav) anim->Misc[LWEAPON_MISC_ANIMATION_AFFECTED_BY_GRAVITY] = 1;
	anim->Misc[LWEAPON_MISC_ANIMATION_XPOS] = anim->X;
	anim->Misc[LWEAPON_MISC_ANIMATION_YPOS] = anim->Y;
	return anim;
}

//Andvanced version of animation creating. Use it if you are running out of sprite slots in Weapons/Misc animation data.
lweapon CreateAnimationAdvanced( int x, int y, int numframes, int aspeed, int origtile, int cset, int flashcset, int ax, int ay, int vx, int vy, int lifespan, bool grav){
	lweapon anim = Screen->CreateLWeapon(LW_PARTICLE);
	anim->DeadState = -1;
	anim->X = x;
	anim->Y = y;
	anim->CollDetection = false;
	anim->NumFrames = numframes;
	anim->ASpeed = aspeed;
	anim->OriginalTile = origtile;
	anim->OriginalCSet = cset;
	if (flashcset >= 0){
		anim->Flash = true;
		anim->FlashCSet = flashcset;
	}
	anim->Misc[LWEAPON_MISC_ANIMATION_VX] = vx;
	anim->Misc[LWEAPON_MISC_ANIMATION_VY] = vy;
	anim->Misc[LWEAPON_MISC_ANIMATION_AX] = ax;
	anim->Misc[LWEAPON_MISC_ANIMATION_AY] = ay;
	if (lifespan == -2){
		anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT] = (anim->ASpeed)*(anim->NumFrames);
	}
	else anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT] = lifespan;
	if (grav) anim->Misc[LWEAPON_MISC_ANIMATION_AFFECTED_BY_GRAVITY] = 1;
	anim->Misc[LWEAPON_MISC_ANIMATION_XPOS] = anim->X;
	anim->Misc[LWEAPON_MISC_ANIMATION_YPOS] = anim->Y;
	return anim;
}

//Set angular motion of particle. Angle is measured in degrees.
void SetAngularMovement(lweapon anim, int angle, int speed){
	anim->Misc[LWEAPON_MISC_ANIMATION_VX] = speed*Cos(angle);
	anim->Misc[LWEAPON_MISC_ANIMATION_VY] = speed*Sin(angle);
}

//Expands particle size.
void BigAnim (lweapon anim, int tilewidth, int tileheight){
	anim->Extend = 3;
	anim->TileWidth = tilewidth;
	anim->TileHeight = tileheight;
}

//Main particle update function. Uses DrawOffset variables to actually display particle at it`s position so it does not disappear on touching screen edges
void UpdateAnimations(){
	lweapon anim;
	for (int i=1; i<= Screen->NumLWeapons(); i++){
		anim = Screen->LoadLWeapon(i);
		if (anim->ID == LW_PARTICLE){
			if (!(anim->CollDetection)){
				if (((anim->Misc[LWEAPON_MISC_ANIMATION_AFFECTED_BY_GRAVITY])>0)&&(IsSideview())){// Determine gravity movement.
					if ((anim->Misc[LWEAPON_MISC_ANIMATION_VY]) < TERMINAL_VELOCITY) anim->Misc[LWEAPON_MISC_ANIMATION_AY] = GRAVITY;
					else {
						anim->Misc[LWEAPON_MISC_ANIMATION_AY] = 0;
						anim->Misc[LWEAPON_MISC_ANIMATION_VY] = TERMINAL_VELOCITY;
					}
				}
				//Next update particle velocity depending on acceleration.
				anim->Misc[LWEAPON_MISC_ANIMATION_VX] = (anim->Misc[LWEAPON_MISC_ANIMATION_VX])+(anim->Misc[LWEAPON_MISC_ANIMATION_AX]);
				anim->Misc[LWEAPON_MISC_ANIMATION_VY] = (anim->Misc[LWEAPON_MISC_ANIMATION_VY])+(anim->Misc[LWEAPON_MISC_ANIMATION_AY]);
				//Then update pseudo-position of particle depending on velocity.
				anim->Misc[LWEAPON_MISC_ANIMATION_XPOS] = (anim->Misc[LWEAPON_MISC_ANIMATION_XPOS])+(anim->Misc[LWEAPON_MISC_ANIMATION_VX]);
				anim->Misc[LWEAPON_MISC_ANIMATION_YPOS] = (anim->Misc[LWEAPON_MISC_ANIMATION_YPOS])+(anim->Misc[LWEAPON_MISC_ANIMATION_VY]);
				//And finally calculate and apply DrawOffset values to Lweapons.
				anim->DrawXOffset = (anim->Misc[LWEAPON_MISC_ANIMATION_XPOS]) - (anim->X);
				anim->DrawYOffset = (anim->Misc[LWEAPON_MISC_ANIMATION_YPOS]) - (anim->Y);
				//Remove particle if it falls off bottom of the screen on sideview areas.
				if (((anim->Misc[LWEAPON_MISC_ANIMATION_AFFECTED_BY_GRAVITY])>0)&&((anim->Misc[LWEAPON_MISC_ANIMATION_YPOS])>176)){
					Remove(anim);
				}
				//Update life timer and remove animation if it hits 0.
				if ((anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT])>0) anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT]--;
				if ((anim->Misc[LWEAPON_MISC_ANIMATION_TIMEOUT])==0) Remove(anim);
			}
		}
	}
}

//Removes all particles from screen.
void ClearParticles(){
	for (int i=1; i< Screen->NumLWeapons(); i++){
		lweapon rem = Screen->LoadLWeapon(i);
		if (rem->ID != LW_PARTICLE) continue;
		if (!rem->CollDetection) continue; //An extra security measure to avoid deleting non-particle lweapons.
		Remove(rem);
	}
}