//Handles changing combos from one to another.

//D0 What weapon triggers this ffc. See std_constants for list of lweapons.
//D1 What flag is triggered by this ffc. All combos with this flag will be changed whether flag is inherent or placed.
//D2 Whether change is permanent. Set to non-zero for permanence.
//   Can have up to 8 permanent changes per screen.
//D3 How many combos between original combo and desired combo. Can be positive or negative.
//   Done this way so you don't have to place the combo next in the list. 
//   It can be anywhere, even before the original combo.
//    Example: You mark a 2x2 group of shutter combos with flag 16.
// Next to those wall combos in the combo list is a 2 x 2 group of door combos.
// Each door combo is 2 greater than the original, so secret_offset would be 2.

ffc script Secret_Combo{
     void run(int lw, int flag, int perm, int secret_offset){
          bool isHit;
          //If this combo has already been triggered, run the script.
          if(Screen->D[perm])isHit= true;
	  //Wait for it to be triggered.
          while(!isHit){
	       //Scan lweapons and wait for right one to impact.
               for (int i = 1; i <= Screen->NumLWeapons(); i++){
                    lweapon w = Screen->LoadLWeapon(i);
                    if (w->ID == lw && Collision(this, w))isHit = true;
               }
               Waitframe();
          }
	  //Play secret sound.
          Game->PlaySound(SFX_SECRET);
          //Change all flagged combos by offset amount.
          for (int i = 0; i < 175; i++ ){
               if(ComboFI(i,flag)){
                          Screen->ComboD[i]+=secret_offset;
                          Screen->ComboF[i] = 0;
                          Screen->ComboI[i] = 0;
               }
          }
	  //If not permanent, reset script.
          if(!perm)isHit = false;
          //Otherwise, save its activation.
          else{
               Screen->D[perm] = 1;
          }
     }
} 

//D0- Combo ID to watch. Events happen if it changes.
//D1- Sound to be made, if any. Set to zero for no sound.
//D2- Number of triggers in the room.
//D3- Whether screen secrets are triggered.
//D4- Screen->D register to store secrets in.

ffc script Combo_Change{
    void run(int comboid, int sfx, int numTriggers, bool secret,int perm){
        bool isBlock[176];
        bool SoundMade[176];
        bool playSound=false;
        int numChanged;
	bool triggered = false;
        //Store current location of correct combos.
        //Make sure it knows sound hasn't been made.
        for(int i=0; i<176; i++){
            SoundMade[i] = false;
            if(Screen->ComboD[i]==comboid)isBlock[i]= true;
        }
        //Secrets have been triggered, so do that.
	if (Screen->D[perm])triggered = true;
        while(!triggered){
            //Scan all combos.
            //If combo at position is no longer the right combo and a sound hasn't been made, make one if desired.            
            for(int i=0; i<176; i++){
                if(isBlock[i] && !SoundMade[i] && Screen->ComboD[i]!=comboid){
                    SoundMade[i]=true;
                    if(sfx>0)playSound = true;
                    //If secrets should be triggered, track how many have been switched.
		    if(secret)numChanged++;
                }
            }
            //Make a sound if you want.
            if(playSound){
                Game->PlaySound(sfx);
                playSound=false;
            }
            //If all triggers have been hit and secrets should be activated.
	    if(numChanged == numTriggers && secret)
		triggered = true;
            Waitframe();
        }
        //Trigger screen secrets, save permanence.
	Game->PlaySound(SFX_SECRET);
	Screen->TriggerSecrets();
	Screen->State[ST_SECRET] = true;
	Screen->D[perm]= 1;
    }
}