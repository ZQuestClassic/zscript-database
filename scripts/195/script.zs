const int AXE_SPRITE = 94;

ffc script Iron_Knuckle{
     void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
          n->Extend = 3;
          Ghost_TileWidth = 2;
          Ghost_TileHeight = 2;
          int combo = n->Attributes[10];
          float counter = -1;
          eweapon axe;
          int throw_timer = 300;
          int turncombo;
          int Speed = n->Step;
          int mode = 1;
          Ghost_X = 123;
          Ghost_Y = 80;
          Ghost_Transform(this,n,combo,-1,2,2);
          while(n->HP > 0){
              if(n->Dir == DIR_UP) turncombo = combo;
              else if (n->Dir == DIR_DOWN) turncombo = combo+1;
              else if (n->Dir == DIR_LEFT) turncombo = combo+2;
              else if (n->Dir == DIR_RIGHT) turncombo = combo+3;
              if(n->HP <=60 && mode ==1)mode =2;
              if(n->HP <=50 && mode ==2)mode = 3;
              if(n->HP <=40 && mode ==3)mode = 4;
              if(mode ==1){
                    throw_timer--;
                    if(throw_timer <=0){
                         throw_timer = 300;
                         axe = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, AXE_SPRITE, 40, EWF_ROTATE);
                         SetEWeaponLifespan(axe,EWL_TIMER, 60);
                         SetEWeaponMovement(axe, EWM_THROW, -1, EWMF_DIE);
                         SetEWeaponDeathEffect(axe,EWD_4_FIREBALLS_RANDOM, AXE_SPRITE);
                    }
              }
              else if(mode ==2){
                    n->Step = 2 * Speed;
                    throw_timer--;
                    if(throw_timer <=0){
                         throw_timer = 240;
                         axe = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, AXE_SPRITE, 40, EWF_ROTATE);
                         SetEWeaponLifespan(axe,EWL_TIMER, 60);
                         SetEWeaponMovement(axe, EWM_THROW, -1, EWMF_DIE);
                         SetEWeaponDeathEffect(axe,EWD_4_FIREBALLS_RANDOM, AXE_SPRITE);
                    }
              }
              else if(mode ==3){
                    n->Step = 3 * Speed;
                    throw_timer--;
                    if(throw_timer <=0){
                         throw_timer = 180;
                         axe = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, AXE_SPRITE, 40, EWF_ROTATE);
                         SetEWeaponLifespan(axe,EWL_TIMER, 60);
                         SetEWeaponMovement(axe, EWM_THROW, -1, EWMF_DIE);
                         SetEWeaponDeathEffect(axe,EWD_4_FIREBALLS_RANDOM, AXE_SPRITE);
                    }
              }
              else if(mode ==4){
                    n->Step = 4 * Speed;
                    throw_timer--;
                    if(throw_timer <=0){
                         throw_timer = 120;
                         axe = FireAimedEWeapon(n->Weapon, n->X+16, n->Y, 0, 300, n->WeaponDamage, AXE_SPRITE, 40, EWF_ROTATE);
                         SetEWeaponLifespan(axe,EWL_TIMER, 60);
                         SetEWeaponMovement(axe, EWM_THROW, -1, EWMF_DIE);
                         SetEWeaponDeathEffect(axe,EWD_4_FIREBALLS_RANDOM, AXE_SPRITE);
                    }
              }
              counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
              Ghost_Data = turncombo;
              if(n->HP <=10){
                   Ghost_DeathAnimation(this,n, 2);
                   Waitframes(60);
                   n->HP = 0;
                   Quit();
              }
              Ghost_Waitframe(this, n, true, true);
          }
     }
}