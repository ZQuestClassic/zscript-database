const int FFGLEEOK_FIRE_RATE = 4;//Fire Gleeok`s fire rate
const int NPC_MISC_GLEEOK_HEAD_OFFSET_X = 13;
const int NPC_MISC_GLEEOK_HEAD_OFFSET_Y = 14;

//Extended variant of Z1 Gleeok. Can have more customizability, like killable loose heads, different eweapons for intact and loose heads, unhardcoded position. Moving Gleeok also works.
//Uses 3 enemies. 
//Each head is separate NPC. Slice all heads off body to kill Gleeok, as usual.

ffc script FFGleeokBody{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int numheads = Ghost_GetAttribute(ghost, 0, 2);//Number of heads. Max 16
		int HeadNPC = Ghost_GetAttribute(ghost, 1, enemyID+1);//ID of head enemy.
		int necksegmentcount = Ghost_GetAttribute(ghost, 2, 4); //Number of neck segments per head
		int NeckSegmentCmb = Ghost_GetAttribute(ghost, 3, 1);//Combo used to render neck segment
		int looseheadnpc = Ghost_GetAttribute(ghost, 4, enemyID+2);//ID of loose head NPC to remove, when Gleeok is killed, -1 to disable
		int headinitXOffset = Ghost_GetAttribute(ghost, 5, 8);//Spawning X offset for heads.
		int headinitYOffset = Ghost_GetAttribute(ghost, 6, 40);//Spawning Y offset for heads.
		int neckoffsetX = Ghost_GetAttribute(ghost, 7, 0);//X position of connection between necks and body.
		int neckoffsetY = Ghost_GetAttribute(ghost, 8, 0);//Y position of connection between necks and body.
		int ewsize = Ghost_GetAttribute(ghost, 9, 2);//Body size (square)
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, ewsize, ewsize);
		if (ewsize>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		if (ghost->Damage==0) ghost->CollDetection=false;
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int curheads = 0;
		int State = 0;
		int neckposX=0;
		int neckposY=0;
		npc curhead;
		npc heads[16];
		for (int i=0;i<numheads;i++){
			heads[i] = CreateNPCAt(HeadNPC, Ghost_X+headinitXOffset,Ghost_Y+headinitYOffset);
		}
		int haltcounter=-1;
		
		Ghost_SpawnAnimationPuff(this, ghost);
		
		while(true){
			if (State==0){
				if (SPD>0)haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				curheads=0;
				for (int i=0; i<numheads; i++){
					if (!(heads[i]->isValid())) continue;
					curhead = heads[i];
					for (int i=0; i< necksegmentcount; i++){
						neckposX = Lerp(Ghost_X+neckoffsetX, GetEnemyProperty(curhead, ENPROP_X), (1/(necksegmentcount))*i);
						neckposY = Lerp(Ghost_Y+neckoffsetY, GetEnemyProperty(curhead, ENPROP_Y), (1/(necksegmentcount)*i));
						Screen->FastCombo(3, neckposX, neckposY, NeckSegmentCmb, Ghost_CSet, OP_OPAQUE);
					}
					curhead->Misc[NPC_MISC_GLEEOK_HEAD_OFFSET_X] = Ghost_X + headinitXOffset;
					curhead->Misc[NPC_MISC_GLEEOK_HEAD_OFFSET_Y] = Ghost_Y + headinitYOffset;
					curheads++;
				}
			}
			if (!Ghost_Waitframe(this, ghost, false, false)||curheads==0){
				ghost->CollDetection=false;
				for (int i=1; i<=Screen->NumNPCs();i++){
					if (looseheadnpc<0)continue;
					curhead = Screen->LoadNPC(i);
					if (curhead->ID!=looseheadnpc) continue;
					SetEnemyProperty(curhead, ENPROP_HP, 0);
				}
				for (int i=0; i<16; i++){
					if (!heads[i]->isValid()) continue;
					curhead = heads[i];
					SetEnemyProperty(curhead, ENPROP_HP, 0);
				}
				if (ewsize>1)Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				ghost->HP=0;
				Quit();
			}
		}
	}	
}

ffc script FFGleeokHead{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int rangex = Ghost_GetAttribute(ghost, 0, 24);//Maximum range at X coordinate
		int rangey = Ghost_GetAttribute(ghost, 1, 16);//Maximum range at Y coordinate
		int speedx = Ghost_GetAttribute(ghost, 2, 1);//Angular speed for X coordinate, in 1/100th of degree per frame.
		int speedy = Ghost_GetAttribute(ghost, 3, 2);//Angular speed for Y coordinate, in 1/100th of degree per frame.
		int initanglex = Ghost_GetAttribute(ghost, 4, 0);//Starting angle for X coordinate
		int initangley = Ghost_GetAttribute(ghost, 5, 0);//Starting angle for Y coordinate
		int looseheadnpc = Ghost_GetAttribute(ghost, 6, enemyID+1);//NPC to spawn on death, -1 - no loose head spawning
		int firenum = Ghost_GetAttribute(ghost, 7, 1);//Number of eweapons to fire per burst
		int shotspeed = Ghost_GetAttribute(ghost, 8, 60);//delay between shots, in frames. Enemy won`t fire , if Weapon Damage is 0.
		int ewsprite = Ghost_GetAttribute(ghost, 9, -1);//Eweapon sprite 
		
		
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		if (speedx >=1000) speedx= -320+Rand(640);
		if (speedy >=1000) speedy= -320+Rand(640);
		if (initanglex>360) initanglex =Rand(359);
		if (initangley>360) initangley =Rand(359);
		
		int State = 0;
		int origx = Ghost_X;
		int origy = Ghost_Y;
		int anglex = initanglex;
		int angley = initangley;
		int shotcounter=shotspeed;
		int shoottimer =0;		
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SpawnAnimationPuff(this, ghost);
		while(true){
			if (State==0){
				origx = ghost->Misc[NPC_MISC_GLEEOK_HEAD_OFFSET_X];
				origy = ghost->Misc[NPC_MISC_GLEEOK_HEAD_OFFSET_Y];
				anglex+=speedx/100;
				angley+=speedy/100;
				if (anglex>=360) anglex-=360;
				if (angley>=360) angley-=360;
				if (anglex<0)anglex+=360;
				if (angley<0)angley+=360;
				Ghost_X = origx + rangex*Cos(anglex);
				Ghost_Y = origy + rangey*Sin(angley);
				shotcounter--;
				if (shotcounter==0 && WPND>0){
					shoottimer = FFGLEEOK_FIRE_RATE*firenum;
					shotcounter=shotspeed;
				}
				if (shoottimer>0){
					if ((shoottimer%FFGLEEOK_FIRE_RATE)==0){
						eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
					}
					shoottimer--;
				}
			}
			// Screen->FastTile(3, Ghost_X, Ghost_Y, ghost->Tile, Ghost_CSet, OP_OPAQUE);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				for (int i=1;i<=Screen->NumNPCs();i++){
					if (looseheadnpc<0)continue;
					npc n=Screen->LoadNPC(i);
					if (n->ID!=enemyID) continue;
					if (n->HP==0)continue;
					npc e = CreateNPCAt(looseheadnpc, Ghost_X,Ghost_Y);
					break;
				}
				Quit();
			}
		}
	}	
}		

ffc script FFGleeokLooseHead{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int firenum = Ghost_GetAttribute(ghost, 0, 1);//Number of eweapons to fire per burst
		int shotspeed = Ghost_GetAttribute(ghost, 1, 60);//delay between shots, in frames. Enemy won`t fire , if Weapon Damage is 0.
		int ewsprite = Ghost_GetAttribute(ghost, 2, -1);//Eweapon sprite
		
		
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		
		int State = 0;
		int shotcounter=shotspeed;
		int shoottimer =0;
		int haltcounter = -1;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk8(haltcounter, SPD, RR, HF, HNG);
				shotcounter--;
				if (shotcounter==0 && WPND>0){
					shoottimer = FFGLEEOK_FIRE_RATE*firenum;
					shotcounter=shotspeed;
				}
				if (shoottimer>0){
					if ((shoottimer%FFGLEEOK_FIRE_RATE)==0){
						eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
					}
					shoottimer--;
				}
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Quit();
			}
		}
	}	
}