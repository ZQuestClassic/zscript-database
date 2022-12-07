//import "std.zh"
//import "string.zh"
//import "stdExtra.zh"
//import "ffcscript.zh"

const int MEDICINE_ID = 29; //Item ID of your Medicine.

global script slot_2{
     void run(){
          while(true){
               Secret_Medicine(); //This should go before the Waitframe(); in your global script.
               Waitframe();
          }
     }
}

void Secret_Medicine(){
     if(Link->HP <=0 && Link->Item[MEDICINE_ID] == true){
          while(Link->HP < Link->MaxHP){
               freezeScreen();
               Link->Item[MEDICINE_ID] = false;
               Link->HP++;
               Game->PlaySound(SFX_REFILL);
               if(Link->HP == Link->MaxHP){
                    unfreezeScreen();
               }
               Waitframe();
          }
     }
}