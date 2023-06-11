//Uses to make a boss using the Gen_Explode_Waitframe wait for a certain number of frames before doing something.

void Gen_Explode_Waitframes(ffc this, npc ghost,int frames){
	for(;frames>0;frames--){
		Gen_Explode_Waitframe(this,ghost);
	}
}    
                   
//A general utility function to make a boss explode on death.

void Gen_Explode_Waitframe(ffc this, npc ghost){
     if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   Quit();
     }
}

const int BLIZZETA_BARRIER = 185;//Enemy ID of ice barriers that surround main boss.
const int BLIZZETA_EXTRA_COMBO = 32281;//Combo of top half of boss.
const int CHUNK_SPRITE = 83;//Sprite used by ice chunk attacks.

ffc script Blizzeta{
     void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
          npc n2 = Screen->CreateNPC(BLIZZETA_BARRIER);
          npc n3 = Screen->CreateNPC(BLIZZETA_BARRIER);
          npc n4 = Screen->CreateNPC(BLIZZETA_BARRIER);
          npc n5 = Screen->CreateNPC(BLIZZETA_BARRIER);
          bool isAlive1 = true;
          bool isAlive2 = true;
          bool isAlive3 = true;
          bool isAlive4 = true;
          n->Extend = 3;
          Ghost_TileWidth = 4;
          Ghost_TileHeight = 3;
          bool StartTimer = false;
          int timer = 0;
          int combo = n->Attributes[10];
          Ghost_Transform(this,n,combo,-1,4,3);
          Ghost_AddCombo(BLIZZETA_EXTRA_COMBO,-16,-31,6,2);
          n2->Extend = 3;
          n3->Extend = 3;
          n4->Extend = 3;
          n5->Extend = 3;
          n2->TileWidth = 2;
          n2->TileHeight = 2;
          n3->TileWidth = 2;
          n3->TileHeight = 2;
          n4->TileWidth = 2;
          n4->TileHeight = 2;
          n5->TileWidth = 2;
          n5->TileHeight = 2;
          n2->HitWidth = 32;
          n2->HitHeight = 32;
          n3->HitWidth = 32;
          n3->HitHeight = 32;
          n4->HitWidth = 32;
          n4->HitHeight = 32;
          n5->HitWidth = 32;
          n5->HitHeight = 32;
          n2->X = n->X - 32;
          n2->Y = n->Y +16;
          n3->X = n->X + 32;
          n3->Y = n->Y + 16;
          n4->X = n->X + 16;
          n4->Y = n->Y + 32;
          n5->X = n->X + 16;
          n5->Y = n->Y - 32;
          float ice_angle;
          float angle = 45;
          float speed = n->Step * 0.01;
          float step = speed;
          int angle_change; 
          bool BarrierUp = true;
          int direction = 1;
          eweapon chunk;
          while(n->HP > 0){
               //Track the HP of the barriers and if any die, start moving faster.
               if(n5->HP <= 0 && isAlive4){
                   isAlive4 = false;
                   StartTimer = true;
               }
               if (n4->HP <=0 && isAlive3){
                   isAlive3 = false;
                   StartTimer = true;
               }
               if (n3->HP<= 0 && isAlive2){
                   isAlive2 = false;
                   StartTimer = true;
               }
               if (n2->HP <= 0 && isAlive1){
                   isAlive1 = false;
                   StartTimer = true;
               }
               if(StartTimer){
                 timer = 600;
                 StartTimer = false;
               }
               //Rotate the barriers constantly.
               ice_angle = (ice_angle + 1) % 360;
               //Every 5 seconds, change from current angle to one of 3 others.
               if (angle_change == 0 && angle == 45)angle = Choose(135,225,315);
               else if(angle_change == 0 && angle == 135)angle = Choose(45, 225,315);
               else if(angle_change == 0 && angle == 225)angle = Choose(45,135,315);
               else if(angle_change == 0 && angle == 315)angle = Choose(45,135,225);
               angle_change = (angle_change + 1) % 240;
               Ghost_MoveAtAngle(angle, step, 3);
               //While any of the barriers are alive, keep the core invulnerable.
               if(BarrierUp){
                    n2->X = (n->X+16) + 48 * Cos(ice_angle);
                    n2->Y = (n->Y+24) + 48 * Sin(ice_angle);
                    n3->X = (n->X+16)  + 48 * Cos(ice_angle+90);
                    n3->Y = (n->Y+24) + 48 * Sin(ice_angle+90);
                    n4->X = (n->X+16) + 48 * Cos(ice_angle+180);
                    n4->Y = (n->Y+24) + 48 * Sin(ice_angle+180);
                    n5->X = (n->X+16)  + 48 * Cos(ice_angle+270);
                    n5->Y = (n->Y+24) + 48 * Sin(ice_angle+270);
                    if((n2->HP <= 0 && n3->HP <= 0 && n4->HP <= 0 && n5->HP<=0)
						||(!n2->isValid() && !n3->isValid() && !n4->isValid() 
						&& !n5->isValid()))BarrierUp = false;
               }
               //The barriers are dead. Make the core vulnerable.
               else if (!BarrierUp){
                    n->Defense[NPCD_MAGIC]=NPCDT_NONE;
                    step = speed;
               }
               //When a barrier dies, make it move faster and render the other parts invulnerable.
               while(timer > 0){
                    ice_angle = (ice_angle + 1) % 360;
                    step = 2* speed;
                    n2->Defense[NPCD_MAGIC]= NPCDT_IGNORE;
                    n3->Defense[NPCD_MAGIC]= NPCDT_IGNORE;
                    n4->Defense[NPCD_MAGIC]= NPCDT_IGNORE;
                    n5->Defense[NPCD_MAGIC]= NPCDT_IGNORE;
                    n2->X = (n->X+16)  + 48 * Cos(ice_angle);
                    n2->Y = (n->Y+24)  + 48 * Sin(ice_angle);
                    n3->X = (n->X+16)  + 48 * Cos(ice_angle+90);
                    n3->Y = (n->Y+24)  + 48 * Sin(ice_angle+90);
                    n4->X = (n->X+16)  + 48 * Cos(ice_angle+180);
                    n4->Y = (n->Y+24)  + 48 * Sin(ice_angle+180);
                    n5->X = (n->X+16)  + 48 * Cos(ice_angle+270);
                    n5->Y = (n->Y+24)  + 48 * Sin(ice_angle+270);
                    if (angle_change == 0 && angle == 45)angle = Choose(135,225,315);
                    else if(angle_change == 0 && angle == 135)angle = Choose(45, 225,315);
                    else if(angle_change == 0 && angle == 225)angle = Choose(45,135,315);
                    else if(angle_change == 0 && angle == 315)angle = Choose(45,135,225);
                    angle_change = (angle_change + 1) % 240;
                    chunk = FireAimedEWeapon(n->Weapon, (n->X+16)+ 1 * Cos(ice_angle), (n->Y+24)  + 1 * Sin(ice_angle), ice_angle, 100, n->WeaponDamage, CHUNK_SPRITE, 40, EWF_ROTATE);
                    SetEWeaponLifespan(chunk,EWL_TIMER, 90);
                    SetEWeaponDeathEffect(chunk,EWD_VANISH, 0);
                    Ghost_MoveAtAngle(angle, step, 3);
                    timer--;
                    if(timer <= 0){
                         n2->Defense[NPCD_MAGIC]=NPCDT_NONE;
                         n3->Defense[NPCD_MAGIC]=NPCDT_NONE;
                         n4->Defense[NPCD_MAGIC]=NPCDT_NONE;
                         n5->Defense[NPCD_MAGIC]=NPCDT_NONE;
                         step = speed;
                         break;
                    }
                    Gen_Explode_Waitframe(this, n);
               }
               //The boss is dead.
               Gen_Explode_Waitframe(this, n);
          }
     }
}