import "std.zh"

// Sample global script just using the JumpDrownSpawn function.

global script Slot_2{
   void run(){
		
      // Several scripts use these same variables, only need them once.

      int olddmap = Game->GetCurDMap();
      int oldscreen = Game->GetCurDMapScreen();
      int startx = Link->X;
      int starty = Link->Y;
      int startdir = Link->Dir;

      // Variable used by JumpDrownSpawn.
      int jumping = 0;


      while(true){

         // JumpDrownSpawn 

         if(Link->Action != LA_SCROLLING){

            if(!IsJumping() && jumping == 0 && (oldscreen != Game->GetCurDMapScreen() || olddmap != Game->GetCurDMap())){
               olddmap = Game->GetCurDMap();
               oldscreen = Game->GetCurDMapScreen();
               startx = Link->X;
               starty = Link->Y;
               startdir = Link->Dir;
            }
         }
		   
         jumping = JumpDrownSpawn(jumping, startx, starty, olddmap, oldscreen, startdir);

         // END JumpDrownSpawn


         Waitdraw();
		

         Waitframe();

      }//end whileloop
   }//end run
}//end global slot2



// JumpDrownSpawn function

// Returns 0 if not jumping, 1 if currently jumping, 2 if drowning from a jump
int JumpDrownSpawn(int jumping, int x, int y, int dmap, int scr, int dir){
    if(Link->Action == LA_SCROLLING) return jumping;

    if( IsJumping() && jumping != 2){
       return 1;     // still jumping
    }

    // done jumping, are we drowning?
    if((jumping == 1 || jumping == 2) && Link->Action == LA_DROWNING){
       return 2;  // yes drowning, and still drowning
    }

    // done drowning, respawn
    if(jumping == 2){
       Link->X = x;
       Link->Y = y;
       Link->Dir = dir;

       if(Game->GetCurDMap()!=dmap || Game->GetCurDMapScreen()!=scr){
          Link->PitWarp(dmap, scr);
          WaitNoAction();
       }

       Link->Action = LA_GOTHURTLAND;
       Link->HitDir = -1;
    }

    return 0; // not jumping
}


// utility function returns true if Link is jumping, necessary because SideView gravity sucks
// might need tweaking depending on other SideView scripts you use.

bool IsJumping(){
  if(IsSideview()){
     if(Link->Action == LA_SWIMMING || Link->Action == LA_DIVING || Link->Action == LA_DROWNING) return false;
     if(Link->Jump != 0) return true;
     if(!OnSidePlatform(Link->X,Link->Y)) return true;
  }
  else{
     if(Link->Z > 0) return true;
  }

  return false;
}