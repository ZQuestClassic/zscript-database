const int CHAIN_SPRITE = 98;//Id of chain sprite.

ffc script Fyrus{
     void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
          n->Extend = 3;
          Ghost_TileWidth = 3;
          Ghost_TileHeight = 3;
          int combo = n->Attributes[10];
          Ghost_Transform(this,n,combo,-1,3,3);
          float speed = n->Step;
          eweapon chain;
          eweapon chain2;
          float counter = -1;
          int timer = 240;
          int turncombo;
          float angle;
          int angle_speed = 1;
          while(n->HP> 0){
               counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);
               if(n->Dir == DIR_UP)turncombo = combo;
               else if(n->Dir == DIR_DOWN)turncombo = combo+1;
               else if(n->Dir == DIR_LEFT)turncombo = combo+2;
               else if(n->Dir == DIR_RIGHT)turncombo = combo+3;
               angle = (angle + angle_speed) % 360;
               //Create two chains that circle the main foe.
               chain = FireAimedEWeapon(n->Weapon, (n->X+24) + 48 * Cos(angle), (n->Y+24) + 48 * Sin(angle), angle, 1, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
               SetEWeaponLifespan(chain,EWL_TIMER, 30);
               SetEWeaponDeathEffect(chain,EWD_VANISH, 0);
               chain2 = FireAimedEWeapon(n->Weapon, (n->X+24)  + 48 * Cos(angle+180), (n->Y+24) + 48 * Sin(angle+180), angle, 1, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
               SetEWeaponLifespan(chain2,EWL_TIMER, 30);
               SetEWeaponDeathEffect(chain2,EWD_VANISH, 0);
               //Fire a projectile chain periodically.
               if(timer <=0){
                    for(int i = 0; i< 30; i++){
                         if(n->Dir == DIR_UP)chain = FireAimedEWeapon(n->Weapon, n->X, n->Y-i, 0, 100, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
                         else if(n->Dir == DIR_DOWN)chain = FireAimedEWeapon(n->Weapon, n->X, n->Y+i, 0, 100, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
                         else if(n->Dir == DIR_LEFT)chain = FireAimedEWeapon(n->Weapon, n->X-i, n->Y, 0, 100, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
                         else if(n->Dir == DIR_UP)chain = FireAimedEWeapon(n->Weapon, n->X+i, n->Y, 0, 100, n->WeaponDamage, CHAIN_SPRITE, 40, EWF_ROTATE);
                         SetEWeaponLifespan(chain,EWL_TIMER, 120);
                         SetEWeaponMovement(chain, EWM_HOMING_REAIM, 10, 6);
                         SetEWeaponDeathEffect(chain,EWD_EXPLODE, 8);
                         //Track HP. Increase movement speed, chain rotation and projectile frequency as it drops.
                         if(n->HP> 50){
                              timer = 240;
                              angle_speed = 1;
                         }
                         else if(n->HP > 30 && n->HP < 50){
                              timer = 120;
                              n->Step = 2 * speed;
                              angle_speed = 2;
                         }
                         else if(n->HP < 30){
                              timer = 60;
                              n->Step = 3 * speed;
                              angle_speed = 3;
                         }
                         if(n->HP <=0 ||!n->isValid())break;
                    }
               }
               timer--;
               Ghost_Transform(this,n,turncombo,-1,3,3);
               Ghost_Waitframe(this, n, true, true);
          }
     }
}