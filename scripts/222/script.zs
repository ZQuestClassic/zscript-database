//Set this to the item's ID.
const int POTION_ID = 123;

//Set this to the number of the sound effect to be played when the medicine takes effect.
const int POTION_SFX = 22;

//Set to 1 if you want a message to be displayed when the medicine takes effect.
//Set to 0 if you don't want a message to be displayed.
const int DISPLAY_MESSAGE = 0;

//Set this to the number of the message that will be displayed when the medicine takes effect.
const int MESSAGE = 1;

global script Active {
     void run() {
          while (true) {
               if (Link->HP <= 0 && Link->Item[POTION_ID]) {
                    Link->HP = Link->MaxHP;
                    Link->Item[POTION_ID] = false;
                    Game->PlaySound(POTION_SFX);
                    
                    if (DISPLAY_MESSAGE > 0) {
                         Screen->Message(MESSAGE);
                    }
               }
               Waitframe();
          }
     }
}