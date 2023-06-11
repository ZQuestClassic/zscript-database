const int SFX_ALT_DIGDOGGER_HIT = 15; //Sound to play , when FF Digdogger is hit by whistle lweapon

const int ALT_DIGDOGGER_INVINCIBILITY_FRAMES = 60;//Invincibility between hits, in frames.
const int ALT_DIGDOGGER_BERSERK_SPEED_GAIN = 20;//Speed increase each time FFDigdogger gets hit.

//Digdogger variant. Walks around, shooting eweapons. Play whistle, when eye is open to damage this monster. 
//Set up 2 enemies, 1 for eye and 1 invincible for body
//Blob`s eye anmimation is handled by code and uses 4 frames, animation should be set to "none".
//Blob`s leg animation is 4-frame for left leg and 4-frame right below it for right leg.
//Assign atttributes for eye part of boss.

ffc script AsteroidsDigdogger{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int killenID = Ghost_GetAttribute(ghost, 0, 66);//ID of enemy to spawn on death
		int eyedelay = Ghost_GetAttribute(ghost, 1, 300);//Delay between opening and closing eye
		int shotdelay = Ghost_GetAttribute(ghost, 2, 60);//Delay between shots, in frames. Enemy won`t fire , if Weapon Damage is 0. -1 - shoot eweapons on opening eye. 
		int flamerate = Ghost_GetAttribute(ghost, 3, 4);//Delay between single eweapons in one volley, in frames.
		int numshots = Ghost_GetAttribute(ghost, 4, 1);//Number of eweapons to fire per burst
		int blobID = Ghost_GetAttribute(ghost, 5, enemyID+1);//ID used by body
		int ewsprite = Ghost_GetAttribute(ghost, 6, -1);//Eweapon sprite 
		int sizex = Ghost_GetAttribute(ghost, 7, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 8, 1);//Tile Height
		int killnumen = Ghost_GetAttribute(ghost, 9, 4);//Number of enemies to spawn on death
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		Ghost_SetFlag(GHF_8WAY);
		
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
		int musiccooldown = 0;
		
		npc blob = CreateNPCAt(blobID, Ghost_X-sizex*8+8, Ghost_Y-sizey*8+8);
		blob->Extend=3;
		blob->TileWidth = sizex;
		blob->TileHeight = sizey;
		blob->HitWidth = 16*sizex - 4;
		blob->HitHeight = 16*sizey - 4;
		blob->HitXOffset=2;
		blob->HitYOffset=2;
		int origcset = blob->CSet;
		
		while(true){
			if (State == 0){
				haltcounter = Ghost_ConstantWalk8(haltcounter, SPD, RR, HF, HNG);
				SetEnemyProperty(blob, ENPROP_X,  Ghost_X-sizex*8+8);
				SetEnemyProperty(blob, ENPROP_Y,  Ghost_Y-sizey*8+8);
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
			for (int i=1; i<=Screen->NumLWeapons();i++){
				if (frame!=3)break;
				if (musiccooldown>0)break;
				lweapon m = Screen->LoadLWeapon(i);
				if (m->ID!=LW_WHISTLE)continue;
				Game->PlaySound(SFX_ALT_DIGDOGGER_HIT);
				Ghost_HP-=2;
				SPD+=ALT_DIGDOGGER_BERSERK_SPEED_GAIN;
				musiccooldown = ALT_DIGDOGGER_INVINCIBILITY_FRAMES;
				Ghost_StartFlashing(ALT_DIGDOGGER_INVINCIBILITY_FRAMES);
			}
			if (musiccooldown>0){
				if (IsOdd(musiccooldown)) SetEnemyProperty(blob, ENPROP_CSET, 7);
				else SetEnemyProperty(blob, ENPROP_CSET, origcset);
				musiccooldown--;
				if (musiccooldown==0) SetEnemyProperty(blob, ENPROP_CSET, origcset);
			}
			ghost->OriginalTile = OrigTile + frame;
			if (!Ghost_Waitframe(this, ghost, false, false)){
				for (int i=1;i<=killnumen;i++){
					npc e = CreateNPCAt(killenID, Ghost_X,Ghost_Y);
				}
				SetEnemyProperty(blob, ENPROP_HP, 0);
				Quit();
			}
		}
	}
}