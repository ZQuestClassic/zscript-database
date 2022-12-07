import "std.zh"

//////////////////////
/// ItemHandling.zh //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// This is a global function set for handlinbg item interaction.                                           ///
/// The original author of this function set is grayswandir, who provided it to me, for use in TGC,         ///
/// and I use it for so many components, that in sharing other scriots, I may as well make it a header,     ///
/// to provide the functionality needed for many FFC scripts that I make available to others operable       ///
/// without duplicating these functions in every instance. I may expand on it at some future point.         ///
///                                                                                                         ///
/// Note: The pick-up is instantaneous, and does not need to wait for Link to touch the item.               ///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////
/// Global Constants ///
////////////////////////
 
const int MISC_LWEAPON_ITEM = 0; // The id of the item used to create an lweapon.
 
////////////////////////
/// Global Variables ///
////////////////////////
 
int LastItemUsed = 0; // The item id of the last item Link has used.
 
////////////////////////
/// Global Functions ///
////////////////////////
 
void UpdateLWeapons() {     //// Updates every LWeapon on screen. Call in the active script.
    for (int i = 1; i <= Screen->NumLWeapons(); i++) {
        UpdateLWeapon(Screen->LoadLWeapon(i));
    }
}
 

void UpdateLWeapon(lweapon lw) {    //// Update a given LWeapon.
// If the weapon does not have it's source item marked, mark it as being created by the last item that Link has used.
    if (lw->Misc[MISC_LWEAPON_ITEM] == 0) {
        lw->Misc[MISC_LWEAPON_ITEM] = LastItemUsed;
    }
}
 
/////////////////////////////////////////////////////////////////////////
/// Updates the LastItemUsed variable to our best guess at what was   ///
/// most recently used. This should be called at the end of the loop, ///
/// right before Waitdraw or Waitframe, because the item marked in    ///
/// LastItemUsed isn't actually used until after the Waitdraw or      ///
/// Waitframe.                                                        ///
/////////////////////////////////////////////////////////////////////////


void UpdateLastItem() {

  // Since we don't know which button has priority if both are pressed
  // at once, cancel the B button press if A has also been pressed
  // this frame.
  
    if (Link->PressA && Link->PressB) {
        Link->PressB = false;
    }

    // If Link is currently in an action where he obviously can't use items, then ignore his button presses.
    if (Link->Action != LA_NONE &&      
        Link->Action != LA_WALKING) {
            return;
    }

    // Check which button is being pressed, if any. Also check for the appopriate Jinx.

    if (Link->PressA && Link->SwordJinx == 0) {
        LastItemUsed = GetEquipmentA();
    }
    else if (Link->PressB && Link->ItemJinx == 0) {
        LastItemUsed = GetEquipmentB();
        }
}
 


bool IsFromItem(lweapon lw, int itemNumber) {   //// Return true if the given lweapon is from the given item.
    return lw->Misc[MISC_LWEAPON_ITEM] == itemNumber;
}
 


bool IsFromItemClass(lweapon lw, int itemClass) {   //// Return true if the given lweapon is from the given item class.
    itemdata data = Game->LoadItemData(lw->Misc[MISC_LWEAPON_ITEM]);
    return data->Family == itemClass;
}

////////////////////
/// Item Pick-Up ///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// This script creates an FFC, that gives Link a key, and clears the FFC if the FFC is touched by the      ///
/// boomerang, or the hookshot. This is useful if you want the boomerang/hookshot to pick up keys as in Z3, ///
/// without also allowing them to pick up other special items (per quest rules for Z3 boomerang.            ///
///                                                                                                         ///
/// Note: The pick-up is instantaneous, and does not need to wait for Link to touch the item.               ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// D0 : Item Class (Positive Number), or Item Number (negative Number) of primary trigger.                ///
/// Standard value is 1 (IC_BRANG).                                                                        ///
/// D1 : Item Class (positive Number), or Item Number (negative Number) of secondary trigger.              ///
/// Standard value is 21 (IC_HOOKSHOT).                                                                    ///
/// D2: Set to 0 to give a normal key, or 1 to give a key specific to the level that the player is inside. ///
/// Set to a negative number to give a specific item, other than a key, or a level key.                    ///
/// D3: Set this to the Sound Effect to play on giving the player the item, from Quest->Audio->SFX Data.   ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

ffc script Z3_Key_Pickup {
    void run(int trigger, int trigger2, int level, int SFX) {
    
        bool waiting = true;
            while(waiting){
                if ( Screen->D[0] >= 1 ) {   // If the FFC has already run on the screen
                    this->Data = 0; //Remove sprite
                    return; //Quit
                }
          
                else if ( Screen->D[0] == 0 ) {
                    for (int i = 1; i <= Screen->NumLWeapons(); i++) {   // Loop through all LWeapons on screen.
                    lweapon lw = Screen->LoadLWeapon(i);
                    
                        if (lw->CollDetection && Collision(this, lw)) {     // If the LWeapon is touching us.

                            if (trigger > 0) {      // If <trigger> is positive, test the lweapon for being the correct item class.
                                if (IsFromItemClass(lw, trigger) || IsFromItemClass(lw, trigger2)) {
                                        waiting = false;
                                        if ( level == 0 ) {
                                        Game->Counter[CR_KEYS] += 1;
                                        Game->PlaySound(SFX);
                                        Screen->D[0] = 1;
                                        this->Data = 0; //Remove sprite
                                        return; //Quit
                                    }
                                    else if ( level > 0 ) {
                                        item levelKeyGiven = Screen->CreateItem(I_LEVELKEY);
                                        levelKeyGiven->X = Link->X;
                                        levelKeyGiven->Y = Link->Y;
                                        levelKeyGiven->Z = Link->Z;
                                        Game->PlaySound(SFX);
                                        Screen->D[0] = 1;
                                        this->Data = 0; //Remove sprite
                                        return; //Quit
                                    }
                                    else if ( level < 0 ) {
                                        item levelKeyGiven = Screen->CreateItem(-level);
                                        levelKeyGiven->X = Link->X;
                                        levelKeyGiven->Y = Link->Y;
                                        levelKeyGiven->Z = Link->Z;
                                        Game->PlaySound(SFX);
                                        Screen->D[0] = 1;
                                        this->Data = 0; //Remove sprite
                                        return; //Quit
                                    }
                                }
                            }
                          
    //                        else {      // If <trigger> is negative, test the lweapon for being the correct item number.
    //                            if (IsFromItem(lw, -trigger) || IsFromItem(lw trigger2)) {
    //                                waiting = false;
    //                            }
    //                        }
                        }
                    }
                      
                    Waitframe();
                    //Screen->D[0] = 1;
                    //this->Data = 0; //Remove sprite
                    //return; //Quit
                }
                
                        
                
                
                
                
                
                // Do stuff
                
            }
          

          // Clear the FFC if needed
    }
}

/////////////////////////////
/// Sample Active Script. ///
/////////////////////////////

global script Active {
    void run() {
        while (true) {
            UpdateLWeapons();
            UpdateLastItem();
            if (Link->PressB) {LastItemUsed = GetEquipmentB();}
            if (Link->PressA) {LastItemUsed = GetEquipmentA();}
            Waitdraw();
            Waitframe();
        }
    }
}