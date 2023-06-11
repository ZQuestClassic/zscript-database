const int SPR_ORBITER_EWEAPON = -1;//Sprite used by Boss eweapons.
//Orbiter/Patra
//Has up to 2 rings of enemies circling around. Invincible until all other orbiting enemies are killed. Then becomes more aggressive and faster. Can shoot eweapons. 

ffc script FreeformOrbiter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int WPNS = SPR_ORBITER_EWEAPON;
		
		int sizex = Ghost_GetAttribute(ghost, 0, 1);//Tile Width & Tile Height
		int orbitspeed = Ghost_GetAttribute(ghost, 1, 1);//Orbit rotation speed, reverse for inner orbit.
		int shotspeed = Ghost_GetAttribute(ghost, 2, 90);//Delay between shooting, in frames
		int numorbit1 = Ghost_GetAttribute(ghost, 3, 6);//Number of enemies in outer orbit.
		int numorbit2 = Ghost_GetAttribute(ghost, 4, 4);//Number of enemies in inner orbit.
		int orbitID1 = Ghost_GetAttribute(ghost, 5, 42);//ID of enemies in outer orbit.
		int orbitID2 = Ghost_GetAttribute(ghost, 6, 42);//ID of enemies in inner orbit.
		int radius = Ghost_GetAttribute(ghost, 7, 48);//Outer/minimum radius. Half for inner radius.
		int maxradius = Ghost_GetAttribute(ghost, 8, 64);//If orbit radius can expand/shrink, this defines max radius.
		int growspeed = Ghost_GetAttribute(ghost, 9, 10);//And this defines radius fluctuating speed. 0 for disabling grow/shrink.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizex);
		if (sizex>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int shotcounter=shotspeed;
		
		npc en1[12];
		npc en2[12];
		for (int i=0;i < numorbit1;i++){
			en1[i] = Screen->CreateNPC(orbitID1);
		}
		for (int i=0;i < numorbit2;i++){
			en2[i] = Screen->CreateNPC(orbitID2);
		}
		int angle1 = 0;
		int angle2 = 0;
		int numen = 0;
		int rad = radius;
		int newX=ghost->X;
		int newY=ghost->Y;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		while(true){
			angle1 +=orbitspeed;
			angle2 -=orbitspeed;
			numen=0;
			rad+=growspeed/10;
			if (rad>=maxradius)growspeed*=-1;
			if (rad<=radius)growspeed*=-1;
			haltcounter = Ghost_VariableWalk8(haltcounter, SPD, RR, HF, HNG, HR);
			for (int i=0;i < numorbit1;i++){
				if (en1[i]->isValid()){
					newX = Ghost_X + rad*Cos(angle1+360/numorbit1*i);
					newY = Ghost_Y + rad*Sin(angle1+360/numorbit1*i);
					SetEnemyProperty(en1[i], ENPROP_X, newX);
					SetEnemyProperty(en1[i], ENPROP_Y, newY);
					numen++;
				}
			}
			for (int i=0;i < numorbit2;i++){
				if (en2[i]->isValid()){
					newX = Ghost_X + rad*Cos(angle2+360/numorbit2*i)/2;
					newY = Ghost_Y + rad*Sin(angle2+360/numorbit2*i)/2;
					SetEnemyProperty(en2[i], ENPROP_X, newX);
					SetEnemyProperty(en2[i], ENPROP_Y, newY);
					numen++;
				}
			}
			shotcounter--;
			if (shotcounter==0 && WPND>0){
				eweapon e =  FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost), 0, 180, WPND, WPNS, -1, 0);
				shotcounter=shotspeed;
			}
			if (numen==0) Ghost_SetDefenses(ghost, defs);
			if (numen==0 && HF<256 && HF>127){
				HF=256;
				SPD*=2;
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}		
	}
}

//Shooter for orbiting enemy. Transforms into another enemy on death.
ffc script FreeformShooter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		
		int sizex = Ghost_GetAttribute(ghost, 0, 1);//Tile Width & Tile Height
		int shotspeed = Ghost_GetAttribute(ghost, 1, 60);//Delay between shooting, in frames
		int leftID = Ghost_GetAttribute(ghost, 2, 0);//ID of enemy to transform into on death.
		int WPNS = Ghost_GetAttribute(ghost, 3, -1);//Eweapon sprite
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizex);
		if (sizex>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int shotcounter=shotspeed;
		
		
		while(true){
			shotcounter--;
			if (shotcounter==0 && WPND>0){
				eweapon e =  FireAimedEWeapon(EW_FIREBALL, CenterX(ghost), CenterY(ghost), 0, 100, WPND, WPNS, -1, 0);
				shotcounter=shotspeed;
			}
			
			if (!Ghost_Waitframe(this, ghost, false, false)){
				if (leftID>0){
					npc en = Screen->CreateNPC(leftID);
					en->X = ghost->X;
					en->Y = ghost->Y;
				}
				Quit();
			}
		}		
	}
}

const int SPR_NEST_ORBITER_EWEAPON = -1;//Sprite used by Boss eweapons.
//Orbiter/Patra//Nested Patra
//Has up to 2 rings of enemies circling around. Invincible until all other enemies are killed. Then becomes more aggressive and faster. Can shoot eweapons.
//Each time center core is hit for damage, he spawns new rings of orbiters and becomes invincible again.

ffc script NestedOrbiter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int WPNS = SPR_NEST_ORBITER_EWEAPON;
		
		int sizex = Ghost_GetAttribute(ghost, 0, 1);//Tile Width & Tile Height
		int orbitspeed = Ghost_GetAttribute(ghost, 1, 1);//Orbit rotation speed, reverse for inner orbit.
		int shotspeed = Ghost_GetAttribute(ghost, 2, 90);//Delay between shooting, in frames
		int numorbit1 = Ghost_GetAttribute(ghost, 3, 6);//Number of enemies in outer orbit.
		int numorbit2 = Ghost_GetAttribute(ghost, 4, 4);//Number of enemies in inner orbit.
		int orbitID1 = Ghost_GetAttribute(ghost, 5, 42);//ID of enemies in outer orbit.
		int orbitID2 = Ghost_GetAttribute(ghost, 6, 42);//ID of enemies in inner orbit.
		int radius = Ghost_GetAttribute(ghost, 7, 48);//Outer/minimum radius. Half for inner radius.
		int maxradius = Ghost_GetAttribute(ghost, 8, 64);//If orbit radius can expand/shrink, this defines max radius.
		int growspeed = Ghost_GetAttribute(ghost, 9, 10);//And this defines radius fluctuating speed. 0 for disabling grow/shrink.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizex);
		if (sizex>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int shotcounter=shotspeed;
		
		npc en1[12];
		npc en2[12];
		for (int i=0;i < numorbit1;i++){
			en1[i] = Screen->CreateNPC(orbitID1);
		}
		for (int i=0;i < numorbit2;i++){
			en2[i] = Screen->CreateNPC(orbitID2);
		}
		int angle1 = 0;
		int angle2 = 0;
		int numen = 0;
		int rad = radius;
		int newX=ghost->X;
		int newY=ghost->Y;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		while(true){
			angle1 +=orbitspeed;
			angle2 -=orbitspeed;
			numen=0;
			rad+=growspeed/10;
			if (rad>=maxradius)growspeed*=-1;
			if (rad<=radius)growspeed*=-1;
			haltcounter = Ghost_VariableWalk8(haltcounter, SPD, RR, HF, HNG, HR);
			for (int i=0;i < numorbit1;i++){
				if (en1[i]->isValid()){
					newX = Ghost_X + rad*Cos(angle1+360/numorbit1*i);
					newY = Ghost_Y + rad*Sin(angle1+360/numorbit1*i);
					SetEnemyProperty(en1[i], ENPROP_X, newX);
					SetEnemyProperty(en1[i], ENPROP_Y, newY);
					numen++;
				}
			}
			for (int i=0;i < numorbit2;i++){
				if (en2[i]->isValid()){
					newX = Ghost_X + rad*Cos(angle2+360/numorbit2*i)/2;
					newY = Ghost_Y + rad*Sin(angle2+360/numorbit2*i)/2;
					SetEnemyProperty(en2[i], ENPROP_X, newX);
					SetEnemyProperty(en2[i], ENPROP_Y, newY);
					numen++;
				}
			}
			shotcounter--;
			if (shotcounter==0 && WPND>0){
				eweapon e =  FireAimedEWeapon(EW_SBOMB, CenterX(ghost), CenterY(ghost), 0, 180, WPND, WPNS, -1, 0);
				shotcounter=shotspeed;
			}
			if (numen==0) Ghost_SetDefenses(ghost, defs);
			if (numen==0 && HF<256 && HF>127){
				HF=256;
				SPD*=2;
			}
			if (Ghost_GotHit() && Ghost_HP>0){
				for (int i=0;i < numorbit1;i++){
					en1[i] = Screen->CreateNPC(orbitID1);
				}
				for (int i=0;i < numorbit2;i++){
					en2[i] = Screen->CreateNPC(orbitID2);
				}
				Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}		
	}
}

//Shooter for orbiting enemy. Transforms into another enemy on death.
ffc script NestOrbiterShooter{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		
		int sizex = Ghost_GetAttribute(ghost, 0, 1);//Tile Width & Tile Height
		int shotspeed = Ghost_GetAttribute(ghost, 1, 60);//Delay between shooting, in frames
		int leftID = Ghost_GetAttribute(ghost, 2, 0);//ID of enemy to transform into on death.
		int WPNS = Ghost_GetAttribute(ghost, 3, -1);//Eweapon sprite
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizex);
		if (sizex>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int shotcounter=shotspeed;
		
		
		while(true){
			shotcounter--;
			if (shotcounter==0 && WPND>0){
				eweapon e =  FireAimedEWeapon(EW_FIREBALL, CenterX(ghost), CenterY(ghost), 0, 100, WPND, WPNS, -1, 0);
				shotcounter=shotspeed;
			}
			
			if (!Ghost_Waitframe(this, ghost, false, false)){
				if (leftID>0){
					npc en = Screen->CreateNPC(leftID);
					en->X = ghost->X;
					en->Y = ghost->Y;
				}
				Quit();
			}
		}		
	}
}