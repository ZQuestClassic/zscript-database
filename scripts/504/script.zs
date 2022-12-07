//FFManhandla
//Extended variant of Z1 Manhandla with more customizability. Moves and fires like a normal 4, or 8 headed boss.
//Uses 2 enemy slots, 1 for core, 1 or head. If core is killed first, all heads are gone instantly and vice versa.
ffc script FFManhandla{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int weaponID = ghost->Weapon;
		
		// Initialize
		ghost->Extend=3;
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_8WAY);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int firerate = Ghost_GetAttribute(ghost, 0, 60);//Delay batween firing EWeapons, in frames.
		int size = Ghost_GetAttribute(ghost, 1, 1);//Enemy size and number of heads, 1 - 1x1(4 heads), 2- 2x2(8 heads), 3 -3x3(12 heads), 4 - 4x4(16 heads)
		int speedinc = Ghost_GetAttribute(ghost, 2, 8);//Speed increase modifier with each head killed, stacked additively
		int headID = Ghost_GetAttribute(ghost, 3, enemyID+1);//Enemy ID for heads, uses next ID in list by default, must use "Other" enemy type
		int WPNS = Ghost_GetAttribute(ghost, 4, -1);//Sprite used by fired EWeapons.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, size, size);
		
		Ghost_SpawnAnimationPuff(this, ghost);
		int OrigTile = ghost->OriginalTile;
		int state = 0;
		int statecounter=firerate;
		if (size>4)size=4;
		int haltcounter=0;
		int speedmod = 0;
		
		//Spawn heads
		int numheads = size*4;
		npc heads[16];
		int offsetX[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		int offsetY[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		int dirs[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		int offsetX1[16] = {0, -16,16,0,0,0,0,0,0,0,0,0,0,0,0,0};
		int	offsetY1[16] = {-16, 0,0,16,0,0,0,0,0,0,0,0,0,0,0,0};
		int dirs1[16] = {0,2,3,1,0,0,0,0,0,0,0,0,0,0,0,0};
		int dirs2[16] = {0,0,2,3,2,3,1,1,0,0,0,0,0,0,0,0};
		int offsetX2[16] = {0, 16,-16,32,-16,32,0,16,0,0,0,0,0,0,0,0};
		int offsetY2[16] = {-16, -16,0,0,16,16,32,32,0,0,0,0,0,0,0,0};
		int dirs3[16] = {0,0,0,2,3,2,3,2,3,1,1,1,0,0,0,0};
		int offsetX3[16] = {0, 16,32,-16,48,-16,48,-16,48,0,16,32,0,0,0,0};
		int offsetY3[16] = {-16, -16,-16,0,0,16,16,32,32,48,48,48,0,0,0,0};
		int dirs4[16] = {0,0,0,0,2,3,2,3,2,3,2,3,1,1,1,1};
		int offsetX4[16] = {0, 16,32,48,-16,64,-16,64,-16,64,-16,64,0,16,32,48};
		int offsetY4[16] = {-16, -16,-16,-16,0,0,16,16,32,32,48,48,64,64,64,64};
		for (int i=0; i<numheads; i++){
			heads[i]=SpawnNPC(headID);
			if (size==4){
				offsetX[i]=offsetX4[i];
				offsetY[i]=offsetY4[i];
				dirs[i]=dirs4[i];
			}
			else if (size==3){
				offsetX[i]=offsetX3[i];
				offsetY[i]=offsetY3[i];
				dirs[i]=dirs3[i];
			}
			else if (size==2){
				offsetX[i]=offsetX2[i];
				offsetY[i]=offsetY2[i];
				dirs[i]=dirs2[i];
			}
			else{
				offsetX[i]=offsetX1[i];
				offsetY[i]=offsetY1[i];
				dirs[i]=dirs1[i];
			}
			SetEnemyProperty(heads[i], ENPROP_X, Ghost_X+offsetX[i]);
			SetEnemyProperty(heads[i], ENPROP_Y, Ghost_Y+offsetY[i]);
			SetEnemyProperty(heads[i], ENPROP_DIR, dirs[i]);
			SetEnemyProperty(heads[i], ENPROP_CSET, Ghost_CSet);
		}
		Ghost_Waitframe(this, ghost);
		Ghost_Waitframe(this, ghost);
		Ghost_Waitframe(this, ghost);
		Ghost_Waitframe(this, ghost);
		while(true)	{
			speedmod=0;
			for (int i=0; i<numheads; i++){
				if (heads[i]->isValid()){
					SetEnemyProperty(heads[i], ENPROP_X, Ghost_X+offsetX[i]);
					SetEnemyProperty(heads[i], ENPROP_Y, Ghost_Y+offsetY[i]);
					SetEnemyProperty(heads[i], ENPROP_DIR, dirs[i]);
				}
				else speedmod+=speedinc;
				if (speedmod==(numheads*speedinc)) Ghost_HP=0;
			}
			haltcounter = Ghost_VariableWalk8(haltcounter, SPD+speedmod, RR, HF, HNG, 15);
			statecounter--;
			if (statecounter==0){
				eweapon e;
				for (int i=0; i<numheads; i++){
					if (!heads[i]->isValid()) continue;
					if (WPND==0)continue;
					if (weaponID==EW_FIREBALL) e = FireAimedEWeapon(weaponID,heads[i]->X , heads[i]->Y, 0, 150, WPND, WPNS, -1, EWF_ROTATE);
					else e = FireNonAngularEWeapon (weaponID, heads[i]->X , heads[i]->Y, dirs[i], 200, WPND, WPNS, -1, EWF_ROTATE);
				}
				statecounter=firerate;
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				for (int i=0; i<numheads; i++){
					if (heads[i]->isValid())SetEnemyProperty(heads[i], ENPROP_HP, 0);
				}
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}		
		}
	}
}