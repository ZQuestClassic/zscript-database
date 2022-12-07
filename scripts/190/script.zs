const int TAIL_ONE= 186;//Invulnerable Moldorm tail segement.
const int TAIL_TWO = 187;//Normal Moldorm Tail segment.

ffc script Big_Moldorm{
     void run(int enemyID){
         npc n = Ghost_InitAutoGhost(this,enemyID);
         int SegmentHP = 10;
         npc n2 = Screen->CreateNPC(TAIL_ONE);
         npc n3 = Screen->CreateNPC(TAIL_ONE);
         npc n4 = Screen->CreateNPC(TAIL_ONE);
         npc n5 = Screen->CreateNPC(TAIL_TWO);
         n2->HP = SegmentHP;
         n3->HP = SegmentHP;
         n4->HP = SegmentHP;
         n5->HP = SegmentHP;
         int Speed = n->Step;
         bool isAlive1 = true;
         bool isAlive2 = true;
         bool isAlive3 = true;
         bool isAlive4 = true;
         bool StartTimer = false;
         int timer = 0;
         Ghost_X = 123;
         Ghost_Y = 80;
         n->Extend = 3;
         Ghost_TileWidth = 2;
         Ghost_TileHeight = 2;
         int combo = n->Attributes[10];
         Ghost_Transform(this,n,combo,-1,2,2);
         n2->X = n->X-16;
         n2->Y = n->Y;
         n3->X = n2->X-8;
         n3->Y = n2->Y;
         n4->X = n3->X-8;
         n4->Y = n3->Y;
         n5->X = n4->X-8;
         n5->Y = n4->Y;
         float counter = -1;
         int turncombo;
         while(n->HP > 0){
              //Check each part to see if it is dead, and if so, get angry.
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
              //Movement code.
              counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
              if(n->Dir == DIR_UP) turncombo = combo;
              else if (n->Dir == DIR_DOWN) turncombo = combo+1;
              else if (n->Dir == DIR_LEFT) turncombo = combo+2;
              else if (n->Dir == DIR_RIGHT) turncombo = combo+3;
              Moldorm_Move(n,n2,n3,n4,n5,1);
              //A part is dead. I'm angry now.
              if(StartTimer){
                 timer = 600;
                 StartTimer = false;
              }
              while(timer > 0){
                  //Repeat movement code, because main while loop is not currently running.
                  counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
                  if(n->Dir == DIR_UP) turncombo = combo;
                  else if (n->Dir == DIR_DOWN) turncombo = combo+1;
                  else if (n->Dir == DIR_LEFT) turncombo = combo+2;
                  else if (n->Dir == DIR_RIGHT) turncombo = combo+3;
                  Moldorm_Move(n,n2,n3,n4,n5,timer);
                  n->Step = 2* Speed;
                  timer--;
                  //Not angry anymore.
                  if(timer <= 0){
                      n->Step = Speed;
                      //Check each part to see if it is dead and if so, replace.
                      if(isAlive3 && isAlive2 && isAlive1){
                          n4->HP = 0;
                          n4 =Screen->CreateNPC(TAIL_TWO);
                          n4->X = n3->X-8;
                          n4->Y = n3->Y;
                          n4->HP = SegmentHP;  
                      }
                      if(!isAlive3 && isAlive2 && isAlive1){
                          n3->HP = 0;
                          n3= Screen->CreateNPC(TAIL_TWO);
                          n3->X = n2->X-8;
                          n3->Y = n2->Y;
                          n3->HP = SegmentHP;
                      }
                      if(!isAlive3 && !isAlive2 && isAlive1){
                          n2->HP = 0;
                          n2 = Screen->CreateNPC(TAIL_TWO);
                          n2->X = n->X-16;
                          n2->Y = n->Y;
                          n2->HP = SegmentHP;
                      }
                      //All parts are dead. Replace the core.
                      if(!isAlive1 && !isAlive2 && !isAlive3 && !isAlive4)Ghost_SetAllDefenses(n, NPCDT_NONE);
                  }
                  Ghost_Data = turncombo;
                  Ghost_Waitframe(this, n, true, true);
             }
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

void Moldorm_Move(npc first, npc first2, npc first3, npc first4, npc first5, int angry){
    while(true){
         if(first->Dir == DIR_UP){
	      if(first2->X < first->X+8)first2->X++;
  	      else if(first2->X > first->X+8)first2->X--;
	      if(first2->Y > first->Y+32)first2->Y--;
    	      else if(first2->Y < first->Y+32)first2->Y++;
              if(first3->X < first2->X)first3->X++;
              else if(first3->X > first2->X)first3->X--;
	      if(first3->Y > first2->Y+8)first3->Y--;
   	      else if(first4->Y < first2->Y+8)first3->Y++;
       	      if(first4->X < first3->X)first4->X++;
      	      else if(first4->X > first3->X)first4->X--;
     	      if(first4->Y > first3->Y+8)first4->Y--;
              else if(first4->Y < first3->Y+8)first4->Y++;
              if(first5->X < first4->X)first5->X++;
              else if(first5->X > first4->X)first5->X--;
              if(first5->Y > first4->Y+8)first5->Y--;
   	      else if(first5->Y < first4->Y+8)first5->Y++;
        }
        if(first->Dir == DIR_DOWN){
              if(first2->X < first->X+8)first2->X++;
              else if(first2->X > first->X+8)first2->X--;
              if(first2->Y < first->Y-16)first2->Y++;
              else if(first2->Y > first->Y-16)first2->Y--;
              if(first3->X < first2->X)first3->X++;
              else if(first3->X > first2->X)first3->X--;
              if(first3->Y < first2->Y-8)first3->Y++;
              else if(first3->Y > first2->Y-8)first3->Y--;
              if(first4->X < first3->X)first4->X++;
              else if(first4->X > first3->X)first4->X--;
              if(first4->Y < first3->Y-8)first4->Y++;
              else if(first4->Y > first3->Y-8)first4->Y--;
              if(first5->X < first4->X)first5->X++;
              else if(first5->X > first4->X)first5->X--;
              if(first5->Y < first4->Y-8)first5->Y++;
              else if(first5->Y > first4->Y-8)first5->Y--;
        }
        if(first->Dir == DIR_LEFT){
              if(first2->X < first->X+32)first2->X++;
              else if(first2->X > first->X+32)first2->X--;
              if(first2->Y < first->Y+8)first2->Y++;
              else if(first2->Y > first->Y)first2->Y--;
              if(first3->X < first2->X+8)first3->X++;
              else if(first3->X > first2->X+8)first3->X--;
              if(first3->Y < first2->Y)first3->Y++;
              else if(first3->Y > first2->Y)first3->Y--;
              if(first4->X < first3->X+8)first4->X++;
              else if(first4->X > first3->X+8)first4->X--;
              if(first4->Y < first3->Y)first4->Y++;
              else if(first4->Y > first3->Y)first4->Y--;
              if(first5->X < first4->X+8)first5->X++;
              else if(first5->X > first4->X+8)first5->X--;
              if(first5->Y < first4->Y)first5->Y++;
              else if(first5->Y > first4->Y)first5->Y--;
        }
        if(first->Dir == DIR_RIGHT){
              if(first2->X < first->X-16)first2->X++;
              else if(first2->X > first->X-16)first2->X--;
              if(first2->Y < first->Y+8)first2->Y++;
              else if(first2->Y > first->Y+8)first2->Y--;
              if(first3->X < first2->X-8)first3->X++;
              else if(first3->X > first2->X-8)first3->X--;
              if(first3->Y < first2->Y)first3->Y++;
              else if(first3->Y > first2->Y)first3->Y--;
              if(first4->X < first3->X-8)first4->X++;
              else if(first4->X > first3->X-8)first4->X--;
              if(first4->Y < first3->Y)first4->Y++;
              else if(first4->Y > first3->Y)first4->Y--;
              if(first5->X < first4->X-8)first5->X++;
              else if(first5->X > first4->X-8)first5->X--;
              if(first5->Y < first4->Y)first5->Y++;
              else if(first5->Y > first4->Y)first5->Y--;
        }
        if(angry)break;
        Waitframe();
    }
}