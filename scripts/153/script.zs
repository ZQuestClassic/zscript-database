import "std.zh" // only need this once

const int SHADOW_TILE = 27400; // set these to whatever you have your shadow sprite set to.
const int SHADOW_CSET = 7;


// Place Enemy_Waves FFC on the screen where the waves should happen
// Set the arguments based on comments below
// The script is hardcoded to look for Enemy Placement Flags for where to place the wave enemies.
// Make sure you have enough flag placements (they don't acutually need to be different flags), for the number of enemies you are spawning
// Add in whatever you want to happen trigger secrets etc (or add more waves), where I've commented to do so.

// D0 = the spawn type of the waves.
//      0 = the enemies normal spawn type
//      1 = fall from ceiling, only if enemy has "Instant" spawn type set
//      2 = fall from ceiling, hack method of drawing other spawn types (Puff, Flicker) off screen for a few frames.
//
// D1 = the enemy to spawn for the 2nd wave
// D2 = the number of enemies to spawn for the 2nd wave
// D3 = same as D1, 3rd wave
// D4 = same as D2, 3rd wave


ffc script Enemy_Waves{
     void run(int spawn_type, int wave2_enemy, int wave2_amount, int wave3_enemy, int wave3_amount){
          int wavenum = 1;

          Waitframes(5);  // until the enemies actually show up

          while(true){
               if(Screen->NumNPCs() == 0){ // if you killed all the enemies in that wave
                    wavenum++; // go to next wave

                    if(wavenum == 2){
                         SpawnCode(wave2_enemy, wave2_amount, spawn_type);
                    }else if(wavenum == 3){
                         SpawnCode(wave3_enemy, wave3_amount, spawn_type);
                    }else if(wavenum == 4){

                         // add another wave or trigger secret or whatever
                    
                         Quit();
                    }// end wavenum if
               }// end numNPCs if          
               

               Waitframe();

          }//end whileloop
     }//end run

     void SpawnCode(int wave_enemy, int wave_amount, int spawn_type){
          for(int i = 0; i <= 175; i++){ // lets search for enemy placement flags
               if( ComboFIRange(i, 37, 46) ){ //37-46 are the enemy placement flag#s
                    npc enem = CreateNPCAt(wave_enemy, ComboX(i), ComboY(i) ); // create the enemy on the combo

                    if(spawn_type > 0){
                         FallFromCeiling(enem, spawn_type);  // fake the fall from ceiling
                    }

                    wave_amount--;  // count down number of enemies we need to place in this wave

                    if(wave_amount == 0){  // stop placing enemies
                         break; //from forloop
                    }
                }
          }//end forloop 
     }//end SpawnCode function
}//end Enemy_Waves ffc function

//Returns true if the combo at 'loc' has either an inherent or place flag in the range of 'flagmin' to 'flagmax'
bool ComboFIRange(int loc, int flagmin, int flagmax){
     for(int i = flagmin; i <= flagmax; i++){
          if (Screen->ComboF[loc] == i || Screen->ComboI[loc] == i){
               return true;
          }
     }

     return false;
}


// method = 1 = enemy should have Instant Spawn type set, or you'll see the Puff
// method = 2 = enemy is drawn offscreen during its Spawn animation.

void FallFromCeiling(npc enem, int method){
     int xpos = enem->X;
     int ypos = enem->Y;

     if(method==2){
          // hack method of drawing enemy offscreen while it spawns with puff animation
          // but we'll still draw our shadow in the correct spot

          for(int i = 20; i >= 0; i--){
              enem->X = -16;  
              enem->Y = -16;
 
              Screen->DrawTile(1, xpos, ypos, SHADOW_TILE, 1, 1, SHADOW_CSET, -1, -1, 0, 0, 0, 0, true, 128);
           
              Waitframe();          
          }
     }//end if method2

     //draw our falling enemy.  the shadow is drawn naturally by the game.
     for(int i = 20; i >= 0; i--){
          enem->X = xpos;
          enem->Y = ypos;
          enem->Z = i;

          Waitframe();          
     }
}//end FallFromCeiling function