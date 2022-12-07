ffc script Acheman{
     void run(int enemyID){
           npc n = Ghost_InitAutoGhost(this,enemyID);
           Ghost_TileWidth = 4;
           Ghost_TileHeight = 3;
           int combo = n->Attributes[10];
           Ghost_Transform(this,n,combo,-1,4,3);
           Ghost_X = 100;
           Ghost_Y = 50;
           float counter = -1;
           int speed = n->Step;
           int turncombo;
           int fire_timer = Choose(60,120,180,240);
           int shield_timer = Choose(90,150,210,240);
           int mode = 1;
           Ghost_SetFlag(GHF_FLYING_ENEMY);
           eweapon fireball[4];
           int stop = 60;
           while(n->HP> 0){
              if(mode ==1){
                    n->Step = speed;
                    counter = Ghost_ConstantWalk4(counter, n->Step, n->Rate, n->Homing, n->Hunger);
                    Ghost_SetAllDefenses(n, NPCDT_NONE);
                    n->Defense[NPCD_REFMAGIC] = NPCDT_IGNORE;
                    n->Defense[NPCD_REFFIREBALL] = NPCDT_IGNORE; 
                    if(n->Dir == DIR_LEFT || n->Dir == DIR_UP){
                         Ghost_SetHitOffsets(n, 0, 4, 10, 6);
                         turncombo = combo+2;
                    }
                    else{
                         Ghost_SetHitOffsets(n, 0, 4, 6, 10);
                         turncombo = combo+3;
                    }
               }
               else{
                    n->Step = 0;
                    Ghost_SetAllDefenses(n, NPCDT_IGNORE);
                    if(n->Dir == DIR_LEFT || n->Dir == DIR_UP){
                          Ghost_SetHitOffsets(n, 0, 6, 0, 12);
                          turncombo = combo+4;
                    }
                    else{
                          Ghost_SetHitOffsets(n, 0, 6, 12, 0);
                          turncombo = combo+5;
                    }
               }
               if(fire_timer <0 && mode == 1){
                     if(n->Dir == DIR_LEFT || n->Dir == DIR_UP){
                          turncombo = combo;
                          fireball[0] = FireAimedEWeapon(n->Weapon, n->X, n->Y, DegtoRad(247), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[1] = FireAimedEWeapon(n->Weapon, n->X, n->Y+16, DegtoRad(203), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[2] = FireAimedEWeapon(n->Weapon, n->X, n->Y+48, DegtoRad(157), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[3] = FireAimedEWeapon(n->Weapon, n->X, n->Y+48, DegtoRad(113), 100, n->WeaponDamage, 40, 40, 0);
                          SetEWeaponLifespan(fireball[0],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[0], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[0],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[1],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[1], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[1],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[2],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[2], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[2],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[3],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[3], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[3],EWD_VANISH, 0);
                     }
                     else{
                          turncombo = combo+1;
                          fireball[0] = FireAimedEWeapon(n->Weapon, n->X, n->Y, DegtoRad(293), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[1] = FireAimedEWeapon(n->Weapon, n->X, n->Y+16, DegtoRad(337), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[2] = FireAimedEWeapon(n->Weapon, n->X, n->Y+48, DegtoRad(23), 100, n->WeaponDamage, 40, 40, 0);
                          fireball[3] = FireAimedEWeapon(n->Weapon, n->X, n->Y+48, DegtoRad(67), 100, n->WeaponDamage, 40, 40, 0);
                          SetEWeaponLifespan(fireball[0],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[0], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[0],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[1],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[1], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[1],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[2],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[2], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[2],EWD_VANISH, 0);
                          SetEWeaponLifespan(fireball[3],EWL_TIMER, 200);
                          SetEWeaponMovement(fireball[3], EWM_HOMING, DegtoRad(22), 200);
                          SetEWeaponDeathEffect(fireball[3],EWD_VANISH, 0);
                     }
                     fire_timer = Choose(60,120,180,240);
                     while(stop >0){
                          n->Step = 0;
                          Ghost_SetHitOffsets(n, 0, 3, 4, 4);
                          Ghost_Data = turncombo;
                          stop--;
                          Gen_Explode_Waitframe(this,n);
                     }
                     stop = 60;
                     n->Step = speed;
               }
               if(shield_timer <=0 && mode ==1){
                    mode = 2;
                    shield_timer = Choose(90,150,210,240);
               }
               else if(shield_timer <=0 && mode ==2){
                    mode = 1;
                    shield_timer = Choose(90,150,210,240);
               }
               shield_timer--;
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