import "std.zh" //only need this once

const int FFC_MISC_ONEWAY = 0; // set to an unused FFC->Misc[] value.
const int ONEWAY_UP = 408; // the up combo, in order after, down, left, right


// Place over a solid combo that you want to become a OneWay combo
// D0 = save any changes to OneWay direction so they remain after a screen change. 

ffc script FFC_OneWay{
   void run(int save){
      this->X = GridX(this->X);
      this->Y = GridY(this->Y);
      this->Misc[FFC_MISC_ONEWAY] = -1;

      int loc = ComboAt(this->X,this->Y);
      int oridir = Screen->ComboD[loc] - ONEWAY_UP;
      if(oridir<0 || oridir>3) Quit();
      
      int curdir;
      
      while(Link->Action != LA_SCROLLING){
         if(this->Misc[FFC_MISC_ONEWAY] != -1) curdir = this->Misc[FFC_MISC_ONEWAY];
         else curdir = oridir;

         if(Screen->ComboD[loc] != ONEWAY_UP + curdir){
            Screen->ComboD[loc] = ONEWAY_UP + curdir;
            if(save){
               Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, ONEWAY_UP + curdir);
            }
         }

         if(curdir == DIR_UP){
            if(Link->X >= this->X-1 && Link->X <= this->X+1 && Link->Y+8 == this->Y+16 && Link->InputUp){
               Link->X = this->X;
               for(int i=0; i<=24&&Link->Action!=LA_SCROLLING; i++){
                  Link->Dir = DIR_UP;
                  Link->Y--;
                  Link->Action = LA_WALKING;
                  WaitNoAction();
               }
            }
         }else if(curdir == DIR_DOWN){
            if(Link->X >= this->X-1 && Link->X <= this->X+1 && Link->Y+16 == this->Y && Link->InputDown){
               Link->X = this->X;
               for(int i=0; i<=24&&Link->Action!=LA_SCROLLING; i++){
                  Link->Dir = DIR_DOWN;
                  Link->Y++;
                  Link->Action = LA_WALKING;
                  WaitNoAction();
               }
            }
         }else if(curdir == DIR_LEFT){
            if(Link->X == this->X+16 && Link->Y >= this->Y-1 && Link->Y <= this->Y+1 && Link->InputLeft){
               Link->Y = this->Y;
               for(int i=0; i<=32&&Link->Action!=LA_SCROLLING; i++){
                  Link->Dir = DIR_LEFT;
                  Link->X--;
                  Link->Action = LA_WALKING;
                  WaitNoAction();
               }
            }
         }else if(curdir == DIR_RIGHT){
            if(Link->X+16 == this->X && Link->Y >= this->Y-1 && Link->Y <= this->Y+1 && Link->InputRight){
               Link->Y = this->Y;
               for(int i=0; i<=32&&Link->Action!=LA_SCROLLING; i++){
                  Link->Dir = DIR_RIGHT;
                  Link->X++;
                  Link->Action = LA_WALKING;
                  WaitNoAction();
               }
            }
         }

         Waitframe();
      }
   }
}


// Changes a OneWay combo to a new direction.
// D0 = the # of the ffc to change, leave 0 if want to change all
// D1 = the new direction, or...
// -1 for next direction 
// -2 for previous direction
// -3 for opposite direction
// -4 for random direction
// -5 no direction (use with D2 reset)
// D2 = reset - stepping once on this FFC sets new direction, stepping again resets to original. 0 = off, 1 = on.

ffc script FFC_OneWayChanger{
   void run(int num, int newdir, int reset){
      if(num < 0 || num > 32) Quit();

      int buffer[] = "FFC_OneWay";
      int scriptNum = Game->GetFFCScript(buffer);
      ffc f;

      if(num>0){
         f = Screen->LoadFFC(num);
         if(f->Script != scriptNum) Quit();
      }

      while(true){
         if(RectCollision(this->X, this->Y, this->X+(this->TileWidth*16), this->Y+(this->TileHeight*16), Link->X+2, Link->Y+8, Link->X+13, Link->Y+15)){
            if(num == 0){
               for(int i=1; i<=32; i++){
                  f = Screen->LoadFFC(i);
                  if(f->Script==scriptNum) Set_OnewayDIR(f,newdir,reset);
               }
            }
            else Set_OnewayDIR(f,newdir,reset);

            while(RectCollision(this->X, this->Y, this->X+(this->TileWidth*16), this->Y+(this->TileHeight*16), Link->X+2, Link->Y+8, Link->X+13, Link->Y+15))
               Waitframe();
         }

         Waitframe();
      }
   }
}

// Changes every OneWay combo that is currently pointing direction D0.
// D0 = the OneWay direction that will be changed
// D1 = the new direction that the OneWay combo will be changed to
//      same values as D1 for FFC_OneWayChanger

ffc script FFC_OneWaySameChanger{
   void run(int olddir, int newdir){
      int buffer[] = "FFC_OneWay";
      int scriptNum = Game->GetFFCScript(buffer);
      ffc f;

      while(true){
         if(RectCollision(this->X, this->Y, this->X+(this->TileWidth*16), this->Y+(this->TileHeight*16), Link->X+2, Link->Y+8, Link->X+13, Link->Y+15)){
            for(int i=1; i<=32; i++){
               f = Screen->LoadFFC(i);
               if(f->Script!=scriptNum) continue;
               if(olddir == Screen->ComboD[ ComboAt(f->X,f->Y) ] - ONEWAY_UP) Set_OnewayDIR(f,newdir,0);
               
            }

            while(RectCollision(this->X, this->Y, this->X+(this->TileWidth*16), this->Y+(this->TileHeight*16), Link->X+2, Link->Y+8, Link->X+13, Link->Y+15))
               Waitframe();
         }

         Waitframe();
      }
   }
}

void Set_OnewayDIR(ffc f, int newdir, int reset){
   if(reset && f->Misc[FFC_MISC_ONEWAY] != -1){
      f->Misc[FFC_MISC_ONEWAY] = -1;
      return;
   }
   int curdir = Screen->ComboD[ ComboAt(f->X,f->Y) ] - ONEWAY_UP;

   if(newdir >= 0 && newdir <=3) f->Misc[FFC_MISC_ONEWAY] = newdir;
   else if(newdir == -1){
      if(curdir == 3) f->Misc[FFC_MISC_ONEWAY] = 0; 
      else f->Misc[FFC_MISC_ONEWAY] = curdir+1;
   }
   else if(newdir == -2){
      if(curdir == 0) f->Misc[FFC_MISC_ONEWAY] = 3; 
      else f->Misc[FFC_MISC_ONEWAY] = curdir-1;
   }
   else if(newdir == -3) f->Misc[FFC_MISC_ONEWAY] = OppositeDir(curdir);
   else if(newdir == -4) f->Misc[FFC_MISC_ONEWAY] = Rand(4);
}