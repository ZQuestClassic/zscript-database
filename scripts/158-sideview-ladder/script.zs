// SIDEVIEW LADDER --------------------------------------------------------------------------------------------

import "std.zh"       // only need this once
import "ffcscript.zh" // only need this once


// ----------------------------------------------------------------------
// Setup
//
// 1. Modify the constants to fit your needs. It looks for both, so they can potentially be used by other scripts.
//    If so, the other script will probably want to make sure it isn't both.  isSVLadder function is helpful for this.
// 2. Use one of the existing globals (see step#3) if no other global scripts. 
//    Or see the sample globals at the bottom of the script to see how to combine.
// 3. Decide if using the global version or FFC version. DON'T USE BOTH!!!!
//    Global - if you have lots of screens with the sideview ladder combos
//    FFC - only a few sideview ladder screens, or want more flexibility reusing the Script ComboTypes/Flags.
//    Both versions require adding things to the global script.  Each has its own sample global script at the bottom.

//  3a. If using the FFC version, just place the Sideview_Ladder FFC on that screen. Won't run on non-SV screens.
//      See the sample global, as there are numerous things to add to global for the FFC version.
//  3b. If using the global version, add or uncomment the GLB_Sideview_Ladder(); part of the global script.  
//      See the sample global for what needs to be included.

// 4. Watch out for compile conflicts with the isSolid function that many other scripts use.

// Optional Setup
//
// Roc's Feather
// 1. The script looks for only the default Roc Feather item#.  
//    So if you've changed that, or have multiple levels of Roc items, you'll need to mod that part of the script.
//
// Item use on ladder
// 1. A/B buttons are still enabled, allowing item use on the ladder
//    Expect weird behavior with certain items due to the script changing Link's direction.
//    i.e. can stab sword to the side while facing up
//    If you use the hookshot, you're likely going to need to modify the script to make it work right, or disable it.


// ----------------------------------------------------------------------
// Constants

// Sideview Ladder constant
const int CT_SVLADDER	            = 142;  	// CT_SCRIPT1, ComboType for Sideview Ladder
const int CF_SVLADDER               = 99;       // CF_SCRIPT2, ComboFlag for Sideview Ladder
                                                // This ComboFlags can be reused since this script requires both the ComboType and Flag.
                                                // If reusing, that script should check that it isn't the SV ComboType.

// ----------------------------------------------------------------------
// Global variable

//sideview ladder
bool onLadder = false;


// ----------------------------------------------------------------------
// Sideview Ladder functions (FFC and global versions)


// Place the FFC version on any screen with your sideview ladders.  won't run on non Sideview screens
// DON'T use this AND the global version

ffc script Sideview_Ladder{
   void run(){
      onLadder = false;
      if(!IsSideview()) Quit();

      itemdata feather = Game->LoadItemData(I_ROCSFEATHER);

      while(true){
         onLadder = false;

         if( isSVLadder(Link->X+8, Link->Y+6) || isSVLadder(Link->X+8, Link->Y+15) ){
            // Link is on SV ladder
            onLadder = true;

            if(Link->Jump < 0) Link->Jump=0;

            if(Link->InputUp){
               if( !isSolid(Link->X+1, Link->Y-1) && !isSolid(Link->X+8, Link->Y-1) && !isSolid(Link->X+14, Link->Y-1) )
                  Link->Y--;
            }

            else if(Link->InputDown){
               if( !isSolid(Link->X+1, Link->Y+16) && !isSolid(Link->X+8, Link->Y+16) && !isSolid(Link->X+14, Link->Y+16) )
                  Link->Y++;
            }

            if( (Link->InputRight || Link->InputLeft) && useFeather() && Link->Jump == 0){
               if( !isSolid(Link->X+1, Link->Y-1) && !isSolid(Link->X+8, Link->Y-1) && !isSolid(Link->X+14, Link->Y-1) ){

                  Game->PlaySound(feather->UseSound);
                  Link->Jump = 1.6 + (feather->Power*0.8);
               }
            }

            if(isSolid(Link->X+8, Link->Y+16) && isSolid(Link->X+8, Link->Y+16) && isSolid(Link->X+14, Link->Y+16) ){
               // Link is standing on solid ground at the base of SV Ladder
               onLadder = false;

               if(useFeather()){
                  Game->PlaySound(feather->UseSound);
                  Link->Jump = 1.6 + (feather->Power*0.8);
               }
            }
         }
         else if( isSVLadder(Link->X+8,Link->Y+16) ){
            // Link is standing on top of SV Ladder

            Link->Jump=0;

            if(Link->InputDown){
               Link->Y++;
               onLadder = true;

            }else if(useFeather()){
               Game->PlaySound(feather->UseSound);
               Link->Jump = 1.6 + (feather->Power*0.8);
            }
         }
         else if( isSVLadder(Link->X+8,Link->Y+17) || isSVLadder(Link->X+8,Link->Y+18) ){
            // Link is falling above SV Ladder, snap him to grid so we don't miss

            Link->Jump = 0;
            Link->Y += 16 - (Link->Y%16);
         }

         Waitframe();
      }// end whileloop
   }//end run
}//end ffc Sideview_Ladder


// Global function that doesn't get us stuck as always climbing when leaving an FFC sideview ladder screen while climbing
// sets onLadder to false if it isn't Sideview, or if the Sideview Ladder FFC script isn't present on new screen

void FFCBugFix_SVLadder(int oldscreen, int olddmap){
   if(!IsSideview()) onLadder = false;
   else{
      int buffer[] = "Sideview_Ladder";
      if(CountFFCsRunning(Game->GetFFCScript(buffer)) == 0) onLadder = false;
   }
}



// Global version of Sideview Ladder script.  
// If you have lots of screens using the sideview ladder this will save you the hassle of having to place the FFC on each one
// If using the global, DON'T use the FFC.

void GLB_Sideview_Ladder(){
   onLadder = false;
   if(!IsSideview()) return;

   itemdata feather = Game->LoadItemData(I_ROCSFEATHER);

   if( isSVLadder(Link->X+8, Link->Y+6) || isSVLadder(Link->X+8, Link->Y+15) ){
      // Link is on SV ladder
      onLadder = true;

      if(Link->Jump < 0) Link->Jump=0;

      if(Link->InputUp){
         if( !isSolid(Link->X+1, Link->Y-1) && !isSolid(Link->X+8, Link->Y-1) && !isSolid(Link->X+14, Link->Y-1) )
            Link->Y--;
         }

      else if(Link->InputDown){
         if( !isSolid(Link->X+1, Link->Y+16) && !isSolid(Link->X+8, Link->Y+16) && !isSolid(Link->X+14, Link->Y+16) )
            Link->Y++;
         }

         if( (Link->InputRight || Link->InputLeft) && useFeather() && Link->Jump == 0){
            if( !isSolid(Link->X+1, Link->Y-1) && !isSolid(Link->X+8, Link->Y-1) && !isSolid(Link->X+14, Link->Y-1) ){

               Game->PlaySound(feather->UseSound);
               Link->Jump = 1.6 + (feather->Power*0.8);
            }
         }

      if(isSolid(Link->X+8, Link->Y+16) && isSolid(Link->X+8, Link->Y+16) && isSolid(Link->X+14, Link->Y+16) ){
         // Link is standing on solid ground at the base of SV Ladder
         onLadder = false;

         if(useFeather()){
            Game->PlaySound(feather->UseSound);
            Link->Jump = 1.6 + (feather->Power*0.8);
         }
      }
   }
   else if( isSVLadder(Link->X+8,Link->Y+16) ){
      // Link is standing on top of SV Ladder

      Link->Jump=0;

      if(Link->InputDown){
         Link->Y++;
         onLadder = true;

      }else if(useFeather()){
         Game->PlaySound(feather->UseSound);
         Link->Jump = 1.6 + (feather->Power*0.8);
      }
   }
   else if( isSVLadder(Link->X+8,Link->Y+17) || isSVLadder(Link->X+8,Link->Y+18) ){
      // Link is falling above SV Ladder, snap him to grid so we don't miss

      Link->Jump = 0;
      Link->Y += 16 - (Link->Y%16);
   }
}//end GLB_Sideview_Ladder




// ----------------------------------------------------------------------
// Utility functions used by Sideview Ladder
// Useful for other scripts to call for script interactions


// Returns true if x,y is both the SV Ladder flag and type
bool isSVLadder(int x, int y){
   int loc = ComboAt(x,y);
   return( Screen->ComboT[loc] == CT_SVLADDER && ComboFI(loc, CF_SVLADDER) );
}

bool isSVLadder(int loc){
   return( Screen->ComboT[loc] == CT_SVLADDER && ComboFI(loc, CF_SVLADDER) );
}

// returns true if feather is equipped and being used
// could add more checks for more Roc Items in here, or some other type of jumping method, eg L-button.
bool useFeather(){
   if(GetEquipmentA()==I_ROCSFEATHER && Link->PressA) return true;
   if(GetEquipmentB()==I_ROCSFEATHER && Link->PressB) return true;

   return false;
}

// !!!!!!!!! This function is used by a lot of scripts.  Only need it once.
//returns true if the combo is solid at x/y
bool isSolid(int x, int y){
    if(x<0 || x>255 || y<0 || y>175) return false;
    int mask=1111b;
        if(x%16<8) mask&=0011b;
        else mask&=1100b;
            if(y%16<8) mask&=0101b;
            else mask&=1010b;
            return (!(Screen->ComboS[ComboAt(x, y)]&mask)==0);
}


// ----------------------------------------------------------------------
// Sample global scripts
//
// If not using any other global scripts, just compile this.
// Load the corresponding global for the method you are using.
//
// If combining with existing global script, see the sample for the method you are using, and read the comments.



global script Slot_2_FFCVersion{
   void run(){

      int olddmap = Game->GetCurDMap();           //*********** other scripts may use these same variables
      int oldscreen = Game->GetCurDMapScreen();   //*********** only need including once (before global loop)


      while(true){

         //*********** code like this if statement is common, only needs including once.
         //*********** near the top of global loop (before Waitdraw)
         if(Link->Action != LA_SCROLLING){        
            if( oldscreen != Game->GetCurDMapScreen() || olddmap != Game->GetCurDMap() ){

               //********** if there is similar code to this if statement, this FFCBugFix should be added
               FFCBugFix_SVLadder(oldscreen, olddmap);  //*********** (before waitdraw & before oldscreen,olddmap are set)

               olddmap = Game->GetCurDMap();
               oldscreen = Game->GetCurDMapScreen();
            }
         }         

         Waitdraw();
		
         if (onLadder) Link->Dir = DIR_UP;        //********* (After Waitdraw)

         Waitframe();

      }//end whileloop
   }//end run
}//end global slot2 FFC Version


global script Slot_2_GLB_Version{
   void run(){

      while(true){

         GLB_Sideview_Ladder();                //********* (before waitdraw)

         Waitdraw();
		
         if (onLadder) Link->Dir = DIR_UP;     //********* (After Waitdraw)

         Waitframe();

      }//end whileloop
   }//end run
}//end global slot2 Global Version