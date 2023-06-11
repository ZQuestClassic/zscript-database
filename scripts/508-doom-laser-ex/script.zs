const int SFX_DOOMLASERDX = 32; //Sound to play, when laser fires.
const int SFX_DOOMLASERDX_OPTICS = 6; //Sound to play when laser hits optics combo.

const int SPR_DOOMLASERDX_FIZZLE = 22;//Sprite to display on Doom Laser fizzling out.

const int SCREEN_D_DOOMLASERDX_COLLISION = 0;//Screen D variable to track laser section collision.
const int SCREEN_D_DOOMLASERDX_RENDERING = 1;//Screen D variable to track laser section rendering.

//Requires ghost.zh

//Doom laser, invented by Quickman. It takes time to fire and travel and can be obscured by solid combos. 
//But one touch - and Link will be ISTANTLY DISINTEGRATED, no sell!!!

//This is complete overhaul of previous Doom Laser script.

//Set up 16 combos for laser GFX, as shown in demo.
//Set SCREEN_D_DOOMLASERDX_COLLISION and SCREEN_D_DOOMLASERDX_RENDERING constants to unused Screen D register.
//Compile the script. ghost.zh required. Assign 2 FFC script slots.
//Place and grid-snap FFC where laser starts. Assign DoomLaserDX FFC script and combo to 1st combo insequence from step 1.
//D0 - Laser direction
//D1 - Delay between script init and laser firing, in frames.
//D2 - Laser travel speed, in pixels per frame. Default is 2.
//D3 - Damage. Cheap Chiniese materials!
//D4 - Laser collision sensivity offset. 0-4
//D5 - Laser section duration prior to fizzling out, in frames. 0 - infinite.

//Mirrors work on Doom Lasers. 3-way MagicPrism combo splits Doom Laser sideways. 4-way Magic Prism combo splits laser 3-fold.

ffc script DoomLaserDX{
	void run(int dir, int delay,int speed, int damage, int leinency, int duration){
		if (damage==0)damage=6666;
		if (speed==0)speed=2;
		if (duration==0) duration=-1;
		int str[] = "DoomLaserColl";
		int scr = Game->GetFFCScript(str);		
		int lasers[176];
		int render[176];
		if (CountFFCsRunning(scr)==0){
			int args[] = {damage,leinency,this->Data};
			ffc coll = RunFFCScriptOrQuit(scr, args);
			coll->CSet = this->CSet;
			Waitframe();
			
		}
		Waitframe();
		lasers = Screen->D[SCREEN_D_DOOMLASERDX_COLLISION];
		render = Screen->D[SCREEN_D_DOOMLASERDX_RENDERING];
		int offset = 1<<OppositeDir(dir);
		int animcounter = -1;
		int cmb=ComboAt(CenterX(this),CenterY(this));
		int adjcmb =  AdjacentComboFix(cmb, dir);
		if (Screen->ComboT[adjcmb]==0 && Screen->ComboS[adjcmb]>0){
			this->Data=0;
			Quit();
		}
		while(true){
			if (delay>0){
				delay--;
				if (delay==0){
					Game->PlaySound(SFX_DOOMLASERDX);
					animcounter = 16/speed;
					offset = (1<<OppositeDir(dir));
					lasers[cmb]=duration;
					if (render[cmb]<0)render[cmb]=(1<<dir)+(1<<OppositeDir(dir));
				}
			}
			else if (animcounter<0){
			if (render[cmb]<0)render[cmb]=(1<<dir)+(1<<OppositeDir(dir));
				animcounter = 16/speed;
			}
			else{
				if (dir==DIR_UP)this->Y-=speed;
				if (dir==DIR_DOWN)this->Y+=speed;
				if (dir==DIR_LEFT)this->X-=speed;
				if (dir==DIR_RIGHT)this->X+=speed;
				animcounter--;
				if (animcounter==0){
					cmb=ComboAt(CenterX(this),CenterY(this));
					this->X=ComboX(cmb);
					this->Y=ComboY(cmb);
					lasers[cmb]=duration;
					render[cmb]=(1<<dir)+(1<<OppositeDir(dir));
					if (Screen->ComboT[cmb]==CT_MAGICPRISM4WAY){
						Game->PlaySound(SFX_DOOMLASERDX_OPTICS);
						for (int i=0;i<4;i++){
							if (i==OppositeDir(dir)) continue;
							FireDoomLaserDX(this, speed, i, damage, leinency, duration);
						}
						render[cmb]=15;
						this->Data=0;
						Quit();
					}
					if (Screen->ComboT[cmb]==CT_MAGICPRISM){
						Game->PlaySound(SFX_DOOMLASERDX_OPTICS);
						render[cmb]=0;
						for (int i=0;i<4;i++){
							if (i==dir) continue;
							if (i==OppositeDir(dir)) continue;
							FireDoomLaserDX(this, speed, i, damage, leinency, duration);
							render[cmb] += (1<<i);
							// Trace(render[cmb]);
						}
						render[cmb]+=(1<<OppositeDir(dir));
						this->Data=0;
						Quit();
					}
					if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
						Game->PlaySound(SFX_DOOMLASERDX_OPTICS);
						int newdir = RotDir(dir, Cond(dir<2, 2, -2));
						FireDoomLaserDX(this, speed, newdir, damage, leinency, duration);
						render[cmb] = (1<<OppositeDir(dir)) +(1<<newdir); 
						this->Data=0;
						Quit();
					}
					if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
						Game->PlaySound(SFX_DOOMLASERDX_OPTICS);
						int newdir = RotDir(dir, Cond(dir<2, -2, 2));
						FireDoomLaserDX(this, speed, newdir, damage, leinency, duration);
						render[cmb] = (1<<OppositeDir(dir)) +(1<<newdir);
						this->Data=0;
						Quit();
					}
					if (Screen->ComboT[cmb]==CT_BLOCKMAGIC){
						render[cmb] = (1<<OppositeDir(dir));
						this->Data=0;
						Quit();
					}
					adjcmb =  AdjacentComboFix(cmb, dir);
					if (Screen->ComboT[adjcmb]==0 && Screen->ComboS[adjcmb]>0){
						this->Data=0;
						Quit();
					}
					if (Screen->ComboT[adjcmb]==CT_MIRROR){
						this->Data=0;
						Quit();
					}
					animcounter = 16/speed;
				}
			}
			Screen->FastCombo(3, this->X, this->Y,this->Data+offset, this->CSet, OP_OPAQUE);
			Waitframe();
		}
	}
}

//Script for processing rendering and collision for Doom Lasers. Runs internally.
ffc script DoomLaserColl{
	void run(int damage, int leinency, int origdata){
		int lasers[176];
		int render[176];
		int offset = 0;
		int adjcmb = 0;
		int LinkYOffset = Cond(IsSideview(),0,8);
		for (int i=0;i<176;i++) lasers[i]=0;
		for (int i=0;i<176;i++) render[i]=-1;
		Screen->D[SCREEN_D_DOOMLASERDX_COLLISION]=lasers;
		Screen->D[SCREEN_D_DOOMLASERDX_RENDERING]=render;
		while(true){
			for (int i=0;i<176;i++){
				if (lasers[i]>0){
					lasers[i]--;
					if (lasers[i]==0){
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
						s->UseSprite(SPR_DOOMLASERDX_FIZZLE);
						s->CollDetection=false;
						render[i]=-1;
					}
				}
			}
			for (int i=0;i<176;i++){
				if (lasers[i]==0)continue;
				// Screen->Rectangle(3, ComboX(i)+leinency, ComboY(i)+leinency, ComboX(i)+16-leinency*2, ComboY(i)+16-leinency*2, 1, -1,0, 0, 0,false, OP_OPAQUE);
				if (RectCollision(Link->X, Link->Y+LinkYOffset, Link->X+15, Link->Y+Cond(IsSideview(),16,8), ComboX(i)+leinency, ComboY(i)+leinency, ComboX(i)+15-leinency*2, ComboY(i)+15-leinency*2)){
					eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, -1, -1, EWF_UNBLOCKABLE);
					e->Dir = Link->Dir;
					e->DrawYOffset = -1000;
					SetEWeaponLifespan(e, EWL_TIMER, 1);
					SetEWeaponDeathEffect(e, EWD_VANISH, 0);
				}
				// offset=0;
				// for (int d=0;d<4;d++){
					// adjcmb = AdjacentComboFix(i,d);
					// if (lasers[adjcmb]==0)continue;
					// offset+=(1<<d);
				// }
				//Screen->DrawInteger(5, ComboX(i), ComboY(i),0, 1,0 , -1, -1, render[i], 0, OP_OPAQUE);
				Screen->FastCombo(2, ComboX(i), ComboY(i),origdata+render[i], this->CSet, OP_OPAQUE);
			}			
			Waitframe();
		}
	}
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}

//Launches doom laser. Internal function.
void FireDoomLaserDX(ffc n, int speed, int dir, int damage, int leinency, int duration){
	int args[8] = {dir,0,speed, damage, leinency,duration,0,0};
	ffc f = RunFFCScriptOrQuit(n->Script, args);
	f->X=n->X;
	f->Y=n->Y;
	f->Data=n->Data;
	f->CSet = n->CSet;
}

//Rotated the given direction num times clockwise in 8-way rose wind
//Use negative values for anti-clockwise direction.
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