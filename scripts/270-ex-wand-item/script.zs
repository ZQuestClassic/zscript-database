import "std.zh"  //only include this once

//Below are the constants that you need to set

const int CRAPPY_WAND = 123;  //set this to the item id of the wand item
const int SFX_MAGIC = 32;  //set this to the sound effect to make when you shoot your wand

const int SHOT_1 = 13;  //What link shoots when Ex1 is pressed (Magic at default)
const int SHOT_2 = 4;  //What link shoots when Ex2 is pressed (Bomb explosion at default)
const int SHOT_3 = 8;  //what link shoots when Ex3 is pressed (wind at default)
const int SHOT_4 = 11;  //what link shoots when Ex4 is pressed (bait at default)


//Below is the global script

global script Ex_Shooter_Active{
    void run(){
        while(true){
            
			//Add lines below this (up until 44) to your global script
			
			if(Link->Item[CRAPPY_WAND]){//if link is carrying the wand item
			
                if ( Link->PressEx1){//if Ex1 is pressed
                    CreateLWeaponAtDirection(SHOT_1, Link->X, Link->Y, Link->Dir);
                    Game->PlaySound(SFX_MAGIC);
					}
					
                if ( Link->PressEx2){//if Ex1 is pressed
                    CreateLWeaponAtDirection(SHOT_2, Link->X, Link->Y, Link->Dir);
                    Game->PlaySound(SFX_MAGIC);
					}
					
                if ( Link->PressEx3){//if Ex1 is pressed
                    CreateLWeaponAtDirection(SHOT_3, Link->X, Link->Y, Link->Dir);
                    Game->PlaySound(SFX_MAGIC);
					}
					
                if ( Link->PressEx4){//if Ex1 is pressed
                    CreateLWeaponAtDirection(SHOT_4, Link->X, Link->Y, Link->Dir);
                    Game->PlaySound(SFX_MAGIC);
					}
					
			//add lines above this (up until 20) to your global script
					
            }
            Waitframe();
        }
    }
}

//below is a function to create the LWeapon

//Create an LWeapon and set its X and Y position and direction in one command
lweapon CreateLWeaponAtDirection(int id, int x, int y, int LWDIR) {
  lweapon lw = Screen->CreateLWeapon(id);
  if(lw->isValid()) {
    lw->X = x;
    lw->Y = y;
	lw->Dir = LWDIR;
  }
  return lw;
}