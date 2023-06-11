const int CMB_TARGET_HIT_ANIM = 2152;// Combo ID of animation to play on targets hit by lasers.
const int CT_LASER_PEPAINTER = 142; // Type of the combo that changes laser passing through to it`s own Cset
const int CT_LASER_DESTRUCTIBLE = 143; // Type of the combo that can be destroyed by laser.
const int CF_LASER_TRIGGER = 77; //Laser trigger flag. All flagged combos must be hit with lasers. 
//And in case of Cset of flagged combo is being 5 or greater, cset of laser and combo must match, or trigger won`t work.
const int SFX_LASER_DESTROY = 13;//Sound to play when CT_LASER_DESTRUCTIBLE combo is destroyed by laser.
const int I_LASER_DEFLECTOR = 37;//Item used by Link to delfect lasers and protects him from damaging lasers. Mirror Shield by default.

const int SCREEN_D_LASER_TRIGGER_ARRRAYPTR = 7;//Screen D register to store array pointer for laser triggers.

int trigs[176];

//Laser that emits colored beam. Beam can bounce off mirrors, be repainted by color changers, and even cause damage to Link.
//Hit all truggers simultaneously with lasers to open secrets. Mirrors can be one-sided, check out combo solidity in the demo quest.
//1. Set up  CMB_TARGET_HIT_ANIM combo to render animation, when laser passes through trigger.
//2. Set SCREEN_D_LASER_TRIGGER_ARRRAYPTR to unused Screen D register.
//3. Import and compile the script. Assign 2 FFC slots. It requires ghost.zh
//4. Place and grid-snap FFC, where laser emitter was meant to be.
// D0 - Laser direction
// D1 - Laser Cset
// D2 - Damage dealt to Link, if it touches laser, in 1/4ths of heart
// D3 - Set to 1, and laser will be able to penetrate solid combos. Without it only ladder/hookshot crossable combos are transparent 
//      for laser. You can block laser anyway with Block Magic combo type.
//5. Flag all targets with CF_LASER_TRIGGER flag (Magic trigger reflected by default).
//6. Place invisible FFC with LaserTriggers script anywhere in the screen.
ffc script LaserPuzzle{
	void run (int dir, int color, int damage, int pen){
		Waitframe();
		int newtrigs[176];
		newtrigs = Screen->D[SCREEN_D_LASER_TRIGGER_ARRRAYPTR];
		while(true){
			DoLaser(this->X+7, this->Y+7, dir, color, damage, pen, newtrigs);
			Waitframe();
		}
	}
}

void DoLaser(int x, int y, int dir, int color, int damage, int pen, int newtrigs){
	if (dir==-1) return;
	bool hit = false;
	int newcolor = color;
	int newdir = dir;
	int origdir = dir;
	int destx = x;
	int desty = y;
	int origcmb = ComboAt(x, y);
	int linkcmb = ComboAt(CenterLinkX(),CenterLinkY());
	while (newdir>=0){
		dir=newdir;
		x=destx;
		y=desty;
		color=newcolor;
		if (dir==DIR_UP) desty -=16;
		else if (dir==DIR_DOWN) desty +=16;
		else if (dir==DIR_LEFT) destx -=16;
		else if (dir==DIR_RIGHT) destx +=16;
		if (destx<=0)return;
		if (destx>= 256) return;
		if (desty<=0) return;
		if (desty>=176) return;
		int cmb = ComboAt(destx, desty);
		if (newtrigs[cmb] ==0){
			if ((Screen->ComboC[cmb]<5)||(Screen->ComboC[cmb]==color)){
				if (newtrigs[cmb]==0){
					Screen->FastCombo(1, ComboX(cmb), ComboY(cmb), CMB_TARGET_HIT_ANIM , Screen->ComboC[cmb], OP_OPAQUE);
					newtrigs[cmb] =1;
				}
			}
		}
		if (Screen->ComboT[cmb] == CT_LASER_DESTRUCTIBLE){
			Game->PlaySound(SFX_LASER_DESTROY);
			Screen->ComboD[cmb] = Screen->UnderCombo;
			Screen->ComboC[cmb] = Screen->UnderCSet;
		}
		if (Screen->MovingBlockX>=0){
			if ((Screen->MovingBlockX <= destx)
			&&(Screen->MovingBlockX+15>=destx)
			&&(Screen->MovingBlockY <=desty )
			&&(Screen->MovingBlockY+15>=desty)){
				if (dir==DIR_UP) desty = Screen->MovingBlockY+16;
				else if (dir==DIR_DOWN) desty = Screen->MovingBlockY-1;
				else if (dir==DIR_LEFT) destx = Screen->MovingBlockX+16;
				else if (dir==DIR_RIGHT) destx = Screen->MovingBlockX-1;
				newdir=-1;
				hit=true;
			}
		}
		if (newdir<0) continue;
		if (Screen->ComboT[cmb]==CT_LASER_PEPAINTER){
			newcolor = Screen->ComboC[cmb];
		}
		//if (hit) continue;
		if (Screen->ComboT[cmb]==CT_BLOCKMAGIC){
			newdir = -1;
		}
		//if (hit) continue;
		if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
			if (Screen->ComboS[cmb]!=15){
				if ((newdir == DIR_UP)&&((Screen->ComboS[cmb]&10)==10)){
					desty = ComboY(cmb)+16;
					newdir=-1;
				}
				else if ((newdir == DIR_DOWN)&&((Screen->ComboS[cmb]&5)==5)){
					desty = ComboY(cmb)-1;
					newdir=-1;
				}
				else if ((newdir == DIR_LEFT)&&((Screen->ComboS[cmb]&12)==12)){
					destx = ComboX(cmb)+16;
					newdir=-1;
				}
				else if ((newdir == DIR_RIGHT)&&((Screen->ComboS[cmb]&3)==3)){
					destx = ComboX(cmb)-1;
					newdir=-1;
				}
			}
			if (newdir>=0){
				if (newdir<2) newdir = LaserRotDir(newdir, 2);
				else newdir =  LaserRotDir(newdir, -2);
			}
		}
		else if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
			if (Screen->ComboS[cmb]!=15){
				if ((dir == DIR_UP)&&((Screen->ComboS[cmb]&10)==10)){
					desty = ComboY(cmb)+16;
					newdir=-1;
				}
				else if ((dir == DIR_DOWN)&&((Screen->ComboS[cmb]&5)==5)){
					desty = ComboY(cmb)-1;
					newdir=-1;
				}
				else if ((dir == DIR_LEFT)&&((Screen->ComboS[cmb]&12)==12)){
					destx = ComboX(cmb)+16;
					newdir=-1;
				}
				else if ((dir == DIR_RIGHT)&&((Screen->ComboS[cmb]&3)==3)){
					destx = ComboX(cmb)-1;
					newdir=-1;
				}
			}
			if (newdir>=0){
				if (dir<2) newdir = LaserRotDir(newdir, -2);
				else newdir =  LaserRotDir(newdir, 2);
			}
		}
		else if (Screen->ComboT[cmb]==CT_MIRROR)newdir=OppositeDir(dir);
		if (Screen->ComboS[cmb]==15){
			bool p = false;
			if (pen>0) p=true;
			if (Screen->ComboT[cmb]==CT_LADDERHOOKSHOT) p = true;
			if (Screen->ComboT[cmb]==CT_HOOKSHOTONLY) p = true;
			if (Screen->ComboT[cmb]==CT_LADDERONLY) p = true;
			if (Screen->ComboT[cmb]==CT_LASER_PEPAINTER) p = true;
			if (Screen->ComboT[cmb]==CT_MIRRORSLASH) p=true;
			if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH) p=true;
			if (newdir<0)p=true;
			if (!p){
				if (dir == DIR_UP){
					desty = ComboY(cmb)+16;
					newdir=-1;
				}
				else if (dir == DIR_DOWN){
					desty = ComboY(cmb)-1;
					newdir=-1;
				}
				else if (dir == DIR_LEFT){
					destx = ComboX(cmb)+16;
					newdir=-1;
				}
				else if (dir == DIR_RIGHT){
					destx = ComboX(cmb)-1;
					newdir=-1;
				}
			}
		}
		if (cmb==linkcmb){
			hit= false;
			if (RectCollision(destx, desty, x, y, Link->X, Link->Y, Link->X+15, Link->Y+15)) hit= true;
			if (RectCollision(x, y, destx, desty, Link->X, Link->Y, Link->X+15, Link->Y+15)) hit= true;
			if (Link->Z>0) hit=false;
			if (hit&&newdir>=0){
				if (Link->Item[I_LASER_DEFLECTOR]) newdir=Link->Dir;
				else if (damage>0 && NumEWeaponsOf(EW_SCRIPT10)==0){
					eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, -1, -1, EWF_UNBLOCKABLE);
					e->Dir = Link->Dir;
					e->DrawYOffset = -1000;
					SetEWeaponLifespan(e, EWL_TIMER, 1);
					SetEWeaponDeathEffect(e, EWD_VANISH, 0);
				}
			}
		}
		if (cmb==origcmb && (newdir==origdir || newdir==OppositeDir(origdir))){
			newdir = -1;
		}
		if (dir<2)Screen->Rectangle(3, x, y, destx+1, desty, color*16+2, 1, 0, 0, 0, true, OP_OPAQUE);
		else Screen->Rectangle(3, x, y, destx, desty+1, color*16+2, 1, 0, 0, 0, true, OP_OPAQUE);
	}
}


ffc script LaserTriggers{
	void run(){
		int newtrigs[176];
		for (int i=0;i<176;i++) newtrigs[i]=0;
		Screen->D[SCREEN_D_LASER_TRIGGER_ARRRAYPTR]=newtrigs;
		while(true){
			for (int i=0;i<176;i++){
				if (Screen->State[ST_SECRET]) break;
				if (newtrigs[i]==0) break;
				else if (i==175){
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
				Screen->State[ST_SECRET]= true;
				}
			}
			for (int i=0;i<176;i++){
				if (ComboFI(i, CF_LASER_TRIGGER)){
					newtrigs[i] = 0;
				}
				else newtrigs[i] = -1;
			}
			Waitframe();
		}
	}
}

int LaserRotDir(int dir, int num){
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