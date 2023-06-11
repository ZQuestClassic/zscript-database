ffc script Nessie{
     void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
          Ghost_TileWidth = 4;
          Ghost_TileHeight = 2;
          int combo = n->Attributes[10];
          float counter = -1;
          int dive_timer = Choose(90,150,180);
          Ghost_SetFlag(GHF_DEEP_WATER_ONLY);
          Ghost_X = 112;
          Ghost_Y = 48;
          eweapon fireball[3];
          Ghost_Transform(this,n,combo,-1,4,2);
          int turncombo;
          int mode = 1;
          int stop = 60;
          int fire_timer = Choose(60, 90, 120, 150);
          while(n->HP> 0){
               counter = Ghost_ConstantWalk4(counter, n->Step, n->Rate, n->Homing, n->Hunger);
               if(mode ==1){
                    Ghost_SetAllDefenses(n, NPCDT_NONE);
                    if(n->Dir == DIR_RIGHT || n->Dir == DIR_UP){
                         Ghost_SetHitOffsets(n, 6, 8, 0, 5);
                         turncombo = combo+1;
                    }
                    else{
                         Ghost_SetHitOffsets(n, 6, 8, 5, 0);
                         turncombo = combo;
                    }
               }
               else{
                    Ghost_SetAllDefenses(n, NPCDT_IGNORE);
                    Ghost_SetHitOffsets(n, 0, 11, 0, 0);
                    if(n->Dir == DIR_RIGHT || n->Dir == DIR_UP)turncombo = combo+3;
                    else turncombo = combo+2;
               }
               if(fire_timer <0 && mode == 1){
                     if(n->Dir == DIR_RIGHT || n->Dir == DIR_UP){ 
                           fireball[0] = FireEWeapon(n->Weapon, n->X+64, n->Y, DegtoRad(315), 100, n->WeaponDamage, 40, 40, 0);
                           fireball[1] = FireEWeapon(n->Weapon, n->X+64, n->Y, DegtoRad(0), 100, n->WeaponDamage, 40, 40, 0);
                           fireball[2] = FireEWeapon(n->Weapon, n->X+64, n->Y, DegtoRad(45), 100, n->WeaponDamage, 40, 40, 0);
                           SetEWeaponLifespan(fireball[0],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[0], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[0],EWD_4_FIRES_RANDOM, 40);
                           SetEWeaponLifespan(fireball[1],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[1], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[1],EWD_4_FIRES_RANDOM, 40);
                           SetEWeaponLifespan(fireball[2],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[2], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[2],EWD_4_FIRES_RANDOM, 40);
                     }
                     else{
                           fireball[0] = FireEWeapon(n->Weapon, n->X, n->Y, DegtoRad(225), 100, n->WeaponDamage, 40, 40, 0);
                           fireball[1] = FireEWeapon(n->Weapon, n->X, n->Y, DegtoRad(180), 100, n->WeaponDamage, 40, 40, 0);
                           fireball[2] = FireEWeapon(n->Weapon, n->X, n->Y, DegtoRad(135), 100, n->WeaponDamage, 40, 40, 0);
                           SetEWeaponLifespan(fireball[0],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[0], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[0],EWD_4_FIRES_RANDOM, 40);
                           SetEWeaponLifespan(fireball[1],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[1], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[1],EWD_4_FIRES_RANDOM, 40);
                           SetEWeaponLifespan(fireball[2],EWL_TIMER, 120); 
                           SetEWeaponMovement(fireball[2], EWM_HOMING, DegtoRad(1), 120);
                           SetEWeaponDeathEffect(fireball[2],EWD_4_FIRES_RANDOM, 40);
                     }
                     fire_timer = Choose(60, 90, 120, 150);
               }
               if(dive_timer <=0 && mode ==1){
                    mode = 2;
                    dive_timer = Choose(90,150,180);
               }
               else if(dive_timer <=0 && mode ==2){
                    mode = 1;
                    dive_timer = Choose(90,150,180);
               }
               dive_timer--;
               fire_timer--;
               Ghost_Data = turncombo;
               Gen_Explode_Waitframe(this,n);
          }
     }
}

void Gen_Explode_Waitframe(ffc this, npc ghost){
     if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   Quit();
     }
}