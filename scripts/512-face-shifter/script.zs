//Cycling Shapeshifter

//Moves in 4 directions. Vulnerable only during specific frame of animation.
//E.Anim - None, 2-frame, 3-frame or 4-frame, one row every 4 states.

ffc script FaceShifter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int delay = Ghost_GetAttribute(ghost, 0, 60);//Delay between changing frames.
		int numstates = Ghost_GetAttribute(ghost, 1, 4);//Number of frames in animation
		int sizex = Ghost_GetAttribute(ghost, 2, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 1);//Tile Height
		int targetstate = Ghost_GetAttribute(ghost, 4, 0);//Target frame.
		int numframes = Ghost_GetAttribute(ghost, 5, 2);//number of frames per step.
		int dirshift = Ghost_GetAttribute(ghost, 6, 0);//>0 - switch face every time enemy turns, ignoring timing.
		int faceswitchanim = Ghost_GetAttribute(ghost, 7, 0);//>0 - use animation when switching faces, uses the same stup right below original animation
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int pos =0;
		int statecounter=delay;
		int olddir = Ghost_Dir;
		int faceanim=0;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		if (pos!=targetstate)Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		
		while(true){
			if (State==0){
				if (statecounter>45 || faceswitchanim==0)haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (faceanim>0 || dirshift==0)statecounter--;
				if (statecounter<=45){
					faceanim=1;
				}
				if (statecounter==0){
					pos++;
					if (pos>=numstates)pos=0;						
					if (pos!=targetstate)Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					else Ghost_SetDefenses(ghost, defs);
					statecounter=delay;
					faceanim=0;
					olddir=Ghost_Dir;
				}
			}
			if (dirshift>0 && Ghost_Dir!=olddir&& faceanim==0){
				statecounter=45;
				faceanim=1;
				olddir=Ghost_Dir;
			}
			FSAnimation(ghost, OrigTile, numstates, pos, numframes, faceanim);
			Ghost_Waitframe(this, ghost);
		}		
	}
}	

void FSAnimation(npc ghost, int origtile, int numstates, int State, int numframes, int faceanim){
	int offset = 0;
	int faceoffset = 1;	
	while (State>=4){
		offset+=20*ghost->TileHeight;
		State-=4;
	}
	while(numstates>4){
		faceoffset++;
		numstates-=4;
	}
	if (faceanim>0)	offset+=20*ghost->TileHeight*faceoffset;
	offset +=numframes * ghost->TileWidth*State;
	// if (ghost->CSet==6)debugValue(1,offset);
	ghost->OriginalTile = origtile + offset;
}

const int CMB_FACE_SHIFTER_BOSS_SWITCH_ANIM = 1044;//Combo to use for alternate face shifting animation
const int FACE_SHIFTER_BOSS_JUMP_SPEED = 3.2;//Boss jumping speed

//Cycling Shapeshifter - Boss variant

//Moves in 4 directions. Vulnerable only during specific frame of animation.
//When it changes faces, it jumps and fires eweapon on landing.
//E.Anim - None, 2-frame, 3-frame or 4-frame, one row every 4 states.

ffc script FaceShifter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int delay = Ghost_GetAttribute(ghost, 0, 60);//Delay between changing frames.
		int numstates = Ghost_GetAttribute(ghost, 1, 4);//Number of frames in animation
		int sizex = Ghost_GetAttribute(ghost, 2, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 1);//Tile Height
		int targetstate = Ghost_GetAttribute(ghost, 4, 0);//Target frame.
		int numframes = Ghost_GetAttribute(ghost, 5, 2);//number of frames per step.
		int dirshift = Ghost_GetAttribute(ghost, 6, 0);//>0 - switch face every time enemy turns, ignoring timing.
		int faceswitchanim = Ghost_GetAttribute(ghost, 7, 0);//>0 - use animation when switching faces, uses the same stup right below original animation
		int ewsprite = Ghost_GetAttribute(ghost, 8, -1);//Sprite used for eweapons.
		int ewspeed = Ghost_GetAttribute(ghost, 9, 300);//Eweapon speed
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int OrigTile = ghost->OriginalTile;
		int State = 1;
		int haltcounter = -1;
		int pos =0;
		int statecounter=delay;
		int olddir = Ghost_Dir;
		int faceanim=0;
		Ghost_Z=256;
		int origmidi = Game->GetMIDI();
				Game->PlayMIDI(0);
		Game->PlaySound(SFX_FALL);
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		if (pos!=targetstate)Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		
		while(true){
			if (State==1){
				if (Ghost_Z==0){
					Game->PlaySound(3);
					Screen->Quake=48;
					if (Game->GetMIDI()<=0)Game->PlayMIDI(origmidi);
					State=0;
				}
			}
			if (State==0){
				if (statecounter>48 || faceswitchanim==0)haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (faceanim>0 || dirshift==0)statecounter--;
				if (statecounter<=48){
					if (faceanim==0)Ghost_Jump=FACE_SHIFTER_BOSS_JUMP_SPEED;
					faceanim=1;
				}
				if (statecounter==0){
					if (WPND>0){
						eweapon e =  FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost),0, ewspeed, WPND, ewsprite, -1, 0);
					}
					pos++;
					if (pos>=numstates)pos=0;						
					if (pos!=targetstate)Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					else Ghost_SetDefenses(ghost, defs);
					statecounter=delay;
					faceanim=0;
					//Game->PlaySound(3);
					//Screen->Quake=48;
					olddir=Ghost_Dir;
				}
			}
			if (dirshift>0 && Ghost_Dir!=olddir&& faceanim==0){
				statecounter=48;
				faceanim=1;
				olddir=Ghost_Dir;
			}
			//debugValue(1,Ghost_Data);
			FSBAnimation(ghost, OrigTile, numstates, pos, numframes, faceanim);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}		
	}
}	

void FSBAnimation(npc ghost, int origtile, int numstates, int State, int numframes, int faceanim){
	if (CMB_FACE_SHIFTER_BOSS_SWITCH_ANIM>0 && faceanim>0){
		Screen->DrawCombo	(3, Ghost_X, Ghost_Y-Ghost_Z, 
		CMB_FACE_SHIFTER_BOSS_SWITCH_ANIM, Ghost_TileWidth, Ghost_TileHeight, 
		Ghost_CSet, -1, -1, 
		0, 0, 0, 
		0, 0, 
		true, OP_OPAQUE);
		ghost->DrawXOffset=1000;
		return;
	}
	ghost->DrawXOffset=0;
	int offset = 0;
	int faceoffset = 1;	
	while (State>=4){
		offset+=20*ghost->TileHeight;
		State-=4;
	}
	while(numstates>4){
		faceoffset++;
		numstates-=4;
	}
	if (faceanim>0)	offset+=20*ghost->TileHeight*faceoffset;
	offset +=numframes * ghost->TileWidth*State;
	ghost->OriginalTile = origtile + offset;
}