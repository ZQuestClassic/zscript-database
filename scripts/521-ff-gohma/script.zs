//Extended variant of Z1 Gohma. Walks around, shooting eweapons. Only hitting his apen eye can deal any damage to boss.
//Set up 2 enemies, 1 for eye and 1 invincible for legs
//Gohma`s eye anmimation is handled by code and uses 4 frames, animation should be set to "none".
//Gohma`s leg animation is 4-frame for left leg and 4-frame right below it for right leg.
//Assign atttributes for eye part of boss.

ffc script FFGohma{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int dir = Ghost_GetAttribute(ghost, 0, 0);//Facing direction
		int eyedelay = Ghost_GetAttribute(ghost, 1, 300);//Delay between opening and closing eye
		int shotdelay = Ghost_GetAttribute(ghost, 2, 60);//Delay between shots, in frames. Enemy won`t fire , if Weapon Damage is 0. -1 - shoot eweapons on opening eye. 
		int flamerate = Ghost_GetAttribute(ghost, 3, 4);//delay between single eweapons in one volley, in frames.
		int numshots = Ghost_GetAttribute(ghost, 4, 1);//Number of eweapons to fire per burst
		int legnpc = Ghost_GetAttribute(ghost, 5, enemyID+1);//ID used by Gohma`s legs
		int ewsprite = Ghost_GetAttribute(ghost, 6, -1);//Eweapon sprite 
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int OrigTile = ghost->OriginalTile;
		int OrigCset = ghost->CSet;
		int State = 0;
		int haltcounter = -1;
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		int shotcounter=shotdelay;
		int shoottimer =0;
		int framecounter=eyedelay;
		int frame=0;
		bool cycle=true;
		
		int npcoffsetX[4]={-16, -16,0,0};
		int npcoffsetY[4]={0, 0,-16,-16};
		
		npc legs[2];
		
		legs[0]=CreateNPCAt(legnpc, Ghost_X+npcoffsetX[dir], Ghost_Y+npcoffsetY[dir]);
		legs[1]=CreateNPCAt(legnpc, Ghost_X-npcoffsetX[dir], Ghost_Y-npcoffsetY[dir]);
		legs[1]->OriginalTile+=20;
		
		while(true){
			if (State == 0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				SetEnemyProperty(legs[0], ENPROP_X,  Ghost_X+npcoffsetX[dir]);
				SetEnemyProperty(legs[0], ENPROP_Y,  Ghost_Y+npcoffsetY[dir]);
				SetEnemyProperty(legs[1], ENPROP_X,  Ghost_X-npcoffsetX[dir]);
				SetEnemyProperty(legs[1], ENPROP_Y,  Ghost_Y-npcoffsetY[dir]);
			}
			framecounter--;
			if (framecounter==0){
				if (cycle){
					frame++;
					if (frame==3){
						cycle=false;
						framecounter=eyedelay;
						Ghost_SetDefenses(ghost, defs);
						if (shotcounter<0)shoottimer = flamerate*numshots;
					}
					else framecounter=16;
				}
				else {
					frame--;
					if (frame==0){
						cycle=true;
						framecounter=eyedelay;
					}
					else{
						framecounter=16;
						Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					}					
				}
			}
			if (shotcounter>=0)shotcounter--;
			if (shotcounter==0 && WPND>0){
				shoottimer = flamerate*numshots;
				shotcounter=shotdelay;
			}
			if (shoottimer>0){
				if ((shoottimer%flamerate)==0){
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
				}
				shoottimer--;
			}
			ghost->OriginalTile = OrigTile + frame;
			if (!Ghost_Waitframe(this, ghost, false, false)){
				legs[0]->CollDetection=false;
				legs[1]->CollDetection=false;
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				SetEnemyProperty(legs[0], ENPROP_HP, 0);
				SetEnemyProperty(legs[1], ENPROP_HP, 0);				
				Quit();
			}
		}
	}
}