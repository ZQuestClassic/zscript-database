ffc script Big_Gohma{
     void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
          int modetimer = 600;
          Ghost_X = 123;
          Ghost_Y = 80;
          n->Extend = 3;
          Ghost_TileWidth = 2;
          Ghost_TileHeight = 2;
          int closed = n->Attributes[10];
          int open = closed+4;
          int combo = closed;
          int mode = 1;
          float counter = -1;
          eweapon fireball;
          Ghost_Transform(this,n,combo,-1,2,2);
          while(n->HP > 0){
               if(mode == 1)n->Defense[NPCD_ARROW] =NPCDT_IGNORE;
               else if (mode ==2)n->Defense[NPCD_ARROW] =NPCDT_NONE;
               if(n->Dir == DIR_UP && mode == 1)combo = closed;
               else if(n->Dir == DIR_DOWN && mode == 1)combo = closed+1;
               else if(n->Dir == DIR_LEFT && mode == 1)combo = closed+2;
               else if(n->Dir == DIR_RIGHT && mode == 1)combo = closed+3;
               else if(n->Dir ==DIR_UP && mode == 2)combo = open; 
               else if(n->Dir == DIR_DOWN && mode == 2)combo = open+1;
               else if(n->Dir ==DIR_LEFT && mode == 2)combo = open+2;
               else if(n->Dir == DIR_RIGHT && mode == 2)combo = open+3;
               if(modetimer >0 && mode ==1){
                    modetimer--;
                    if(modetimer<=0){
                         modetimer = 300;
                         if(n->Dir == DIR_UP || n->Dir == DIR_DOWN){
                              fireball = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, 40, 40, EWF_ROTATE);
                              SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                              SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                         }
                         else{
                              fireball = FireAimedEWeapon(n->Weapon, n->X, n->Y+16, 0, 300, n->WeaponDamage, 40, 40, EWF_ROTATE);
                              SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                              SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                         }
                         mode = 2;
                    }
               }
               else if(modetimer >0 && mode ==2){
                    modetimer--;
                    if(modetimer<=0){
                         modetimer = 300;
                         if(n->Dir == DIR_UP || n->Dir == DIR_DOWN){
                              fireball = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, 40, 40, EWF_ROTATE);
                              SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                              SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                         }
                         else{
                             fireball = FireAimedEWeapon(n->Weapon, n->X, n->Y+16, 0, 300, n->WeaponDamage, 40, 40, EWF_ROTATE);
                             SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                             SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                         }
                         mode = 1;
                    }
               }
               if(n->HP <=10){
                   Ghost_DeathAnimation(this,n, 2);
                   Waitframes(60);
                   n->HP = 0;
                   Quit();
               }
               counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
               Ghost_Data = combo;
               Ghost_Waitframe(this, n, true, true);
          }
     }
}