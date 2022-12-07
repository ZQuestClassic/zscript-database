import "std.zh"  //only need this once

const int FFC_MISC_ETRIG = 0;       // ffc->Misc[] array index.
const int EW_MISC_EWEAPTRIG = 0;    // eweapon->Misc[] array index

// FFC checks for Enemy collisions.
// D0 = how long the enemy needs to be on the trigger for it to activate
// D1 = how many enemies need to be on the trigger for it to activate
// D2 = only this enemy type will trigger (Guy-type 0 won't work)
// D3 = only this enemy ID will trigger
// D4 = sensitive trigger? 0 = no, 1 = yes
// D5 = can Link also trigger this?  0 = no, 1 = yes, -1 = attraction, link can't trigger, but enemies are attracted to this combo
// D6 = when activated combo changes to next combo.  0 = no, 1 = yes, 2 = yes, and saved for when screen revisited
//      Note: can't use D6=2 with temp secrets (D7=2), script will attempt to set D6 to 1 if secrets are temporary
// D7 = is this the only trigger on screen?  0 = no, 1 = yes perm secrets, 2 = yes temp secrets.
//                                          <0 = trigger is unset without constant collision in this many frames
//      if D7 <= 0, you'll need the FFC_EnemyTriggerCheck or FFC_EnemyTriggerOrder on screen as well

// Note about attraction feature (D5=-1) for the step tiles:  
// The attraction places a lweapon Bait on the screen.  While scripts can create numerous baits on screen, Link can only place a bait if there // are no other baits on screen.  So if using the attraction feature, Link won't be able to use his bait weapon on that screen.  However, even // though Link won't place a bait any action script attached to the bait will still run.
// Also, the enemies will always be attracted to the first bait on screen, so if using two attraction tiles on one screen, they will go to the // lowest numbered FFC.

ffc script FFC_EnemyStepTrigger{
   void run(int duration, int numenem, int etype, int eid, int sens, int linktoo, int gotonext, int alone){
      if(Screen->State[ST_SECRET]) Quit();
      if(gotonext == 2 && (Screen->Flags[SF_SECRETS]&2 || alone==2)) gotonext = 1;
      if(alone<=0 && gotonext==2){
         int buffer1[] = "FFC_EnemyTriggerCheck";
         int buffer2[] = "FFC_EnemyTriggerOrder";
         int scriptNum1 = Game->GetFFCScript(buffer1);
         int scriptNum2 = Game->GetFFCScript(buffer1);
         ffc f;

         for(int i=1; i<=32; i++){
            f = Screen->LoadFFC(i);
            if(f->Script == scriptNum1 || f->Script == scriptNum2){
               if(f->InitD[0] == 0) gotonext = 1;
            }
         }
      }
      if(duration <= 0) duration = 1;
      if(numenem <= 0) numenem = 1;

      npc e;
      int curdura = 0;
      int olddura;
      int numCol;
      bool setNext = false;
      int unset;

      this->X = GridX(this->X);
      this->Y = GridY(this->Y);
      int loc = ComboAt(this->X,this->Y);

      if(linktoo == -1){
         lweapon lwbait = CreateLWeaponAt(LW_BAIT,this->X,this->Y);
         lwbait->DrawXOffset = -1000;
         lwbait->DeadState = -1;
      }

      while(this->Misc[FFC_MISC_ETRIG] != -1){
          if(this->Misc[FFC_MISC_ETRIG] == 2){
             curdura = 0;
             this->Misc[FFC_MISC_ETRIG] = 0;
             setNext = false;
             unset = 0;
             if(gotonext == 1) Screen->ComboD[loc]--;
             if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]-1);
          }         

          numCol = 0;
          olddura = curdura;

          for(int i=Screen->NumNPCs(); i>0; i--){
             if(linktoo == 1){
                if(LinkCollision(this,sens)){
                   curdura++;
                   break;
                }
             }

             e = Screen->LoadNPC(i);

             if(etype != 0){
               if(e->Type != etype) continue;
             }
             if(eid != 0){
               if(e->ID != eid) continue;
             }

             if(Collision(e,this,sens)){
                numCol++;
                if(numCol == numenem){
                   curdura++;
                   break;
                }
             }
          }
          if(olddura == curdura) curdura = 0;

          if(curdura >= duration){
             if(gotonext != 0 && !setNext){
                setNext = true;
                if(gotonext == 1) Screen->ComboD[loc]++;
                if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]+1);
             }

             this->Misc[FFC_MISC_ETRIG] = 1;
             if(alone<0) unset = Abs(alone);

             if(alone > 0){
                Game->PlaySound(SFX_SECRET);
                Screen->TriggerSecrets();           
                if(alone==1) Screen->State[ST_SECRET]=true;
                else Screen->State[ST_SECRET]=false;
                Quit();
             }
          }
          else if(alone < 0){
             if(unset<=0){
                this->Misc[FFC_MISC_ETRIG] = 0;
                if(setNext){
                   setNext = false;
                   if(gotonext == 1) Screen->ComboD[loc]--;
                   if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]-1);
                }
             }
             else unset--;
          }

          Waitframe();
      }
   }
}

// FFC checks for enemy weapon collisions
// D0 = eweapon type required to trigger.  0 for any.  eweapon types are found in std_constants.zh
// D1 = number of times the trigger needs to be hit before being triggered
// D2 = sensitive trigger? 0 = no, 1 = yes
// D3 = when activated combo changes to next combo.  0 = no, 1 = yes, 2 = yes, and saved for when screen revisited
//      Note: can't use D3=2 with temp secrets (D4=2), script will attempt to set D3 to 1 if secrets are temporary
// D4 = is this the only trigger on screen?  0 = no, 1 = yes perm secrets, 2 = yes temp secrets.
//                                           <0 = trigger is unset in this many frames
//      if D4 <= 0, you'll need the FFC_EnemyTriggerCheck or FFC_EnemyTriggerOrder on screen as well

ffc script FFC_EnemyWeapTrigger{
   void run(int ewtype, int numtimes, int sens, int gotonext, int alone){
      if(Screen->State[ST_SECRET]) Quit();
      if(gotonext == 2 && (Screen->Flags[SF_SECRETS]&2 || alone==2)) gotonext = 1;
      if(alone<=0 && gotonext==2){
         int buffer1[] = "FFC_EnemyTriggerCheck";
         int buffer2[] = "FFC_EnemyTriggerOrder";
         int scriptNum1 = Game->GetFFCScript(buffer1);
         int scriptNum2 = Game->GetFFCScript(buffer1);
         ffc f;

         for(int i=1; i<=32; i++){
            f = Screen->LoadFFC(i);
            if(f->Script == scriptNum1 || f->Script == scriptNum2){
               if(f->InitD[0] == 0) gotonext = 1;
            }
         }
      }
      if(numtimes <= 0) numtimes = 1;

      eweapon ew;
      int numCol = 0;
      bool setNext = false;
      int unset;

      this->X = GridX(this->X);
      this->Y = GridY(this->Y);
      int loc = ComboAt(this->X,this->Y);

      while(this->Misc[FFC_MISC_ETRIG] != -1){
         if(this->Misc[FFC_MISC_ETRIG] == 2){
            numCol = 0;
            setNext = false;
            unset = 0;
            this->Misc[FFC_MISC_ETRIG] = 0;
            if(gotonext == 1) Screen->ComboD[loc]--;
            if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]-1);
         }         

         for(int i=Screen->NumEWeapons(); i>0; i--){
            ew = Screen->LoadEWeapon(i);
            if(ew->Misc[EW_MISC_EWEAPTRIG] == 1) continue;
            if(ewtype != 0 && ew->ID != ewtype) continue;

            if(Collision(ew,this,sens)){
               numCol++;
               ew->Misc[EW_MISC_EWEAPTRIG] = 1;
            }
         }

         if(numCol >= numtimes){
             if(gotonext != 0 && !setNext){
                setNext = true;
                if(gotonext == 1) Screen->ComboD[loc]++;
                if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]+1);
             }

             this->Misc[FFC_MISC_ETRIG] = 1;
             if(alone<0) unset = Abs(alone);

             if(alone > 0){
                Game->PlaySound(SFX_SECRET);
                Screen->TriggerSecrets();           
                if(alone==1) Screen->State[ST_SECRET]=true;
                else Screen->State[ST_SECRET]=false;
                Quit();
             }
          }

          if(alone<0){
             if(unset<=0){
                if(this->Misc[FFC_MISC_ETRIG] == 1) numCol = 0;

                this->Misc[FFC_MISC_ETRIG] = 0;
                if(setNext){
                   setNext = false;
                   if(gotonext == 1) Screen->ComboD[loc]--;
                   if(gotonext == 2) Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]-1);
                }
             }
             else unset--;
          }

         Waitframe();
      }
   }
}

// Checks if all the Enemy Triggers (step or weapon) are currently activated, and sets Screen Secret if they are
// D0 - 0 = secrets temperary, 1 = secrets permanent 
ffc script FFC_EnemyTriggerCheck{
   void run(int temporperm){
      int numTrigs = 0;
      int numATrigs = 0;
      int ffcs[32];
      int buffer1[] = "FFC_EnemyStepTrigger";
      int buffer2[] = "FFC_EnemyWeapTrigger";
      int scriptNum1 = Game->GetFFCScript(buffer1);
      int scriptNum2 = Game->GetFFCScript(buffer2);
      ffc f;
      
      for(int i=1; i<=32; i++){
         f = Screen->LoadFFC(i);
         if(f->Script == scriptNum1 || f->Script == scriptNum2){
            ffcs[i-1] = 1;
            numTrigs++;
         }
      }

      while(true){
         numATrigs = 0;

         for(int i=1; i<=32; i++){
            if(ffcs[i-1] == 0) continue;
            f = Screen->LoadFFC(i);
            if(f->Misc[FFC_MISC_ETRIG] == 1) numATrigs++;
         }

         if(numATrigs == numTrigs){
            Game->PlaySound(SFX_SECRET);
            Screen->TriggerSecrets();           

            if(temporperm) Screen->State[ST_SECRET]=true;
            else Screen->State[ST_SECRET]=false;

            for(int i=1; i<=32; i++){
               if(ffcs[i-1] == 0) continue;
               f = Screen->LoadFFC(i);
               f->Misc[FFC_MISC_ETRIG] = -1;
            }
            
            Quit();
         }

         Waitframe();
      }
   }
}

// Checks if the Enemy Triggers (step or weapon) have been activated in the correct order.  Sets Screen Secret if they have been.
// If activated out of order, they'll all be deactivated.
// Order is defined as the order of the FFC#, so FFC1 -> FFC2 -> FFC3 -> etc
// D0 - 0 = secrets temperary, 1 = secrets permanent 
ffc script FFC_EnemyTriggerOrder{
   void run(int temporperm){
      int numTrigs = 0;
      int curTrig;
      int curATrig = 0;
      bool reset = false;
      bool newATrig = false;
      int ffcs[32];
      int buffer1[] = "FFC_EnemyStepTrigger";
      int buffer2[] = "FFC_EnemyWeapTrigger";
      int scriptNum1 = Game->GetFFCScript(buffer1);
      int scriptNum2 = Game->GetFFCScript(buffer2);
      ffc f;
      
      for(int i=1; i<=32; i++){
         f = Screen->LoadFFC(i);
         if(f->Script == scriptNum1 || f->Script == scriptNum2){
            ffcs[i-1] = 1;
            numTrigs++;
         }
      }

      while(true){
         curTrig = 0;
         newATrig = false;

         for(int i=1; i<=32; i++){
            if(ffcs[i-1] == 0) continue;
            f = Screen->LoadFFC(i);
            curTrig++;
            if(f->Misc[FFC_MISC_ETRIG] == 1){
               if(curTrig > curATrig+1){
                  reset = true;
               }
               else if(curTrig == curATrig+1){
                  newATrig = true;
               }
            }
         }         

         if(reset){
            reset = false;
            newATrig = false;
            curATrig=0;
            for(int i=1; i<=32; i++){
               if(ffcs[i-1] == 0) continue;
               f = Screen->LoadFFC(i);
               if(f->Misc[FFC_MISC_ETRIG] == 1) f->Misc[FFC_MISC_ETRIG] = 2;
            }
         }
         if(newATrig) curATrig++;

         if(numTrigs == curATrig){
            Game->PlaySound(SFX_SECRET);
            Screen->TriggerSecrets();           

            if(temporperm) Screen->State[ST_SECRET]=true;
            else Screen->State[ST_SECRET]=false;

            for(int i=1; i<=32; i++){
               if(ffcs[i-1] == 0) continue;
               f = Screen->LoadFFC(i);
               f->Misc[FFC_MISC_ETRIG] = -1;
            }
            
            Quit();
         }
        
         Waitframe();
      }
   }
}


// Overloaded Collision functions. 
bool Collision(npc e, ffc f, int sens){
   if(sens) return Collision(e,f);
   return SquareCollision(CenterX(e)-4, CenterY(e)-4, 8, CenterX(f)-4, CenterY(f)-4, 8);      
}

bool Collision(eweapon ew, ffc f, int sens){
   if(sens) return Collision(ew,f);
   return SquareCollision(CenterX(ew)-4, CenterY(ew)-4, 8, CenterX(f)-4, CenterY(f)-4, 8);      
}

// Overloaded so that you don't need to remember the order
bool Collision(ffc f, npc e, int sens){
   return Collision(e,f,sens);
}

bool Collision(ffc f, eweapon ew, int sens){
   return Collision(ew,f,sens);
}

// Overloaded Link collision function, with the sensitive or not check as above.
bool LinkCollision(ffc f, int sens){
   if(sens) return LinkCollision(f);
   return SquareCollision(Link->X+4, Link->Y+4, 8, CenterX(f)-4, CenterY(f)-4, 8);    
}