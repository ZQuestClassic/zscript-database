const int SECRET_SOUND = 56; // Change to the number for the sound effect to play when secrets are triggered. Leave at 0 if you don't want one.
 
const int CRYSTAL_COMBO = 896; // This should be the combo# of your first crystal color.
 
const int NUM_CRYSTAL_COMBOS = 6; // Set this to the maximum number of colors you can cycle.
 
// Change the above integers to reflect what they would be pointing to in YOUR quest. (Right now they are set to my specifications from the Demo Quest.)
// Combos should be in order, with the first combo as the first color (Color 0).
// Setup all of the combos with Strike->Next flags except for the last one on your list, which when hit should change to the screen's Under Combo.
// Set the screen's Under Combo to be the first combo (Combo 0) on your list, so that the colors loop back once they've run their course.
// Place the FFCs using this script onto your crystals, setting D0 to which color is the correct answer (the first color is 0), and set them to be "Translucent" and to "Run at Screen Init".
// Make sure to have a Secret Combo set for the screen so that the puzzle actually accomplishes something.
// I advise having the tiles used by each crystal be 8-Bit, so that they do not change along with the CSet, and remain uniform throughout your quest.
// The maximum number of crystals that can be used on-screen at any given time is 32.
 

ffc script CrystalSwitchFFC {
void run(){
 
        ffc f;
        int numCrystals = 0;
        int numCrystalsCorrect = -1;
 
        while(true){
              for(int i=1; i<=32; i++){
                     f=Screen->LoadFFC(i);
                     if( ( f->Data >= CRYSTAL_COMBO )&&( f->Data <= (CRYSTAL_COMBO+NUM_CRYSTAL_COMBOS-1) ) ){
                           numCrystals++;
                           if( f->Data == (f->InitD[0]+CRYSTAL_COMBO) )
                                 numCrystalsCorrect++;
                     }
              }
 
             if(numCrystals==numCrystalsCorrect+1){
                   Game->PlaySound(SECRET_SOUND);
                   Screen->TriggerSecrets();           
                   Screen->State[ST_SECRET]=true; // Change to false if you don't want the secret permanent.
                   Quit();
             } 
 
            numCrystals = 0;
            numCrystalsCorrect = -1;
 
           Waitframe();     
           }
     }
}