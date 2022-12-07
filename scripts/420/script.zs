const int SFX_DOOMLASER = 32; //Sound to play, when laser fires.
const int SFX_DOOMLASER_OPTICS = 6; //Sound to play when laser hits optics combo.
const int SFX_INSTANTDEATH = 14; //Sound to play, when Link gets fried by laser. Unfortunately it does not play due to warp sheinanigans.

const int SPR_LASER_OPTICS = 89;//Sprite used when optics combo tries to withstand disintegrating power of deadly laser.

//Requires ghost.zh

//Doom laser, invented by Quickman. It takes time to fire and travel and can be obscured by solid combos. 
//But one touch - and Link will be ISTANTLY DISINTEGRATED, no sell!!! Technically he will be warped to dungeon entrance with +1 to death count. if D4 is set to 0. 
//Place FFC where laser starts.
//D0 - Delay between script init and laser firing, in frames.
//D1 - Laser direction.
//D2 - Tile used to draw laser, 1 frame stretched.
//D3 - Laser travel speed, in pixels per frame. Default is 2.
//D4 - Damage. Cheap Chiniese materials!

ffc script DoomLaser{
	void run(int delay, int dir, int tile, int speed, int damage){
		if (speed==0)speed=2;
		int rtgx = this->X+15;
		int rtgy = this->Y+15;
		while (true){			
			if (delay>0)delay--;
			else {
				if (delay==0){
					Game->PlaySound(SFX_DOOMLASER);
					delay--;
				}
				if (dir==DIR_UP){
					this->Y-=speed;
					if (speed>0){
						if (LaserHitOptics(this, this->X, this->Y, this->InitD[3], dir, damage, tile)){
							int cmb = ComboAt(this->X, this->Y);
							eweapon e = Screen->CreateEWeapon(EW_SCRIPT10);
							e->X = ComboX(cmb);
							e->Y = ComboY(cmb);
							e->Damage = damage;
							if (damage==0) e->Damage = 65536;
							e->UseSprite(SPR_LASER_OPTICS);
							e->DeadState = -1;
							e->HitXOffset++;
							e->HitYOffset++;
							e->HitWidth-=2;
							e->HitHeight=-2;
							e->Behind=false;
							Game->PlaySound(SFX_DOOMLASER_OPTICS);
							speed=0;
						}
						else if (Screen->isSolid(this->X , this->Y)){
							this->Y+=speed;
							speed=0;
						} 
					}					
				}
				if (dir==DIR_DOWN){
					rtgy+=speed;
					if (speed>0){
						if (LaserHitOptics(this, this->X, rtgy, this->InitD[3], dir, damage, tile)){
							int cmb = ComboAt(this->X, rtgy);
							eweapon e = Screen->CreateEWeapon(EW_SCRIPT10);
							e->X = ComboX(cmb);
							e->Y = ComboY(cmb);
							e->Damage = damage;
							if (damage==0) e->Damage = 65536;
							e->UseSprite(SPR_LASER_OPTICS);
							e->DeadState = -1;
							e->HitXOffset++;
							e->HitYOffset++;
							e->HitWidth-=2;
							e->HitHeight=-2;
							Game->PlaySound(SFX_DOOMLASER_OPTICS);
							speed=0;
						}
						else if (Screen->isSolid(rtgx , rtgy)){
							rtgy-=speed;
							speed=0;
						}  
					}
					
				}
				if (dir==DIR_LEFT){
					this->X-=speed;
					if (speed>0){
						if (LaserHitOptics(this, this->X, this->Y, this->InitD[3], dir, damage, tile)){
							int cmb = ComboAt(this->X, this->Y);
							eweapon e = Screen->CreateEWeapon(EW_SCRIPT10);
							e->X = ComboX(cmb);
							e->Y = ComboY(cmb);
							e->Damage = damage;
							if (damage==0) e->Damage = 65536;
							e->UseSprite(SPR_LASER_OPTICS);
							e->DeadState = -1;
							e->HitXOffset++;
							e->HitYOffset++;
							e->HitWidth-=2;
							e->HitHeight=-2;
							Game->PlaySound(SFX_DOOMLASER_OPTICS);
							speed=0;
						}
						else if (Screen->isSolid(this->X , this->Y)){
							this->X+=speed;
							speed=0;
						} 
					}					
				}
				if (dir==DIR_RIGHT){
					rtgx+=speed;
					if (speed>0){
						if (LaserHitOptics(this, rtgx, this->Y, this->InitD[3], dir, damage, tile)){
							int cmb = ComboAt(rtgx, this->Y);
							eweapon e = Screen->CreateEWeapon(EW_SCRIPT10);
							e->X = ComboX(cmb);
							e->Y = ComboY(cmb);
							e->Damage = damage;
							if (damage==0) e->Damage = 65536;
							e->UseSprite(SPR_LASER_OPTICS);
							e->DeadState = -1;
							e->HitXOffset++;
							e->HitYOffset++;
							e->HitWidth-=2;
							e->HitHeight=-2;
							Game->PlaySound(SFX_DOOMLASER_OPTICS);
							speed=0;
						}
						else if (Screen->isSolid(rtgx , rtgy)){
							rtgx-=speed;
							speed=0;
						} 
					}					
				}
				Screen->DrawTile(2, this->X, this->Y, tile, 1, 1, this->CSet, Abs(rtgx-this->X), Abs(rtgy - this->Y), 0, 0, 0, 0, false, OP_OPAQUE);
				if (RectCollision(Link->X, Link->Y, Link->X+15, Link->Y+15, this->X, this->Y, rtgx, rtgy)){
					if (damage==0){
						Game->PlaySound(SFX_INSTANTDEATH);
						Screen->Rectangle(7, 0, 0, 256, 176, 0x93, -1, 0, 0, 0, true, OP_OPAQUE);
						Waitframe();
						int retdmap = Game->LastEntranceDMap;
						int retscreen = Game->LastEntranceScreen;
						Link->Warp(retdmap, retscreen);
						Game->NumDeaths++;
					}
					else{
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, -1, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
				}
			}
			Waitframe();
		}
	}
}

bool LaserHitOptics(ffc this, int x, int y,int speed, int dir, int damage, int tile){
	if (dir==DIR_UP){
		int cmb = ComboAt(x,y);
		if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM4WAY){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile);
			return true;
		}
		return false;
	}
	if (dir==DIR_DOWN){
		int cmb = ComboAt(x,y);
		if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM4WAY){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile-1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile);
			return true;
		}
		return false;
	}
	if (dir==DIR_LEFT){
		int cmb = ComboAt(x,y);
		if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM4WAY){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_LEFT, damage, tile);
			return true;
		}
		return false;
	}
	if (dir==DIR_RIGHT){
		int cmb = ComboAt(x,y);
		if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			return true;
		}
		if (Screen->ComboT[cmb]==CT_MAGICPRISM4WAY){
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_UP, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_DOWN, damage, tile+1);
			FireDoomLaser( this, ComboX(cmb), ComboY(cmb), speed, DIR_RIGHT, damage, tile);
			return true;
		}
		return false;
	}
}

void FireDoomLaser(ffc n, int x, int y, int speed, int dir, int damage, int tile){
	int str[] = "DoomLaser";
	int scr = Game->GetFFCScript(str);
	int args[] = {0, dir, tile, speed, damage};
	int fffc = RunFFCScript(scr, args);
	if (fffc>0){
		ffc f = Screen->LoadFFC(fffc);
		f->X=x;
		f->Y=y;
		f->CSet = n->CSet;
	}
}