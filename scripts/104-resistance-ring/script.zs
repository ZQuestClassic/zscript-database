import "std.zh"

const int ResistanceRingL1_ID = 123; //item ID of the L1 resistance ring
const int ResistanceRingL2_ID = 124; //item ID of the L2 resistance ring
const int ResistanceRingL3_ID = 125; //item ID of the L3 resistance ring
const int ResistanceRingL1_Chance = 50; //chance in percent for the L1 ring to heal Link
const int ResistanceRingL2_Chance = 75; //chance in percent for the L2 ring to heal Link
const int ResistanceRingL3_Chance = 100; //chance in percent for the L3 ring to heal Link
const int ResistanceRingSFX = 0; //sfx for the rings to heal link
const int ResistanceRingLowestHealth = 8; //the lowest amount of health that a player can have. 4 would be a quarter heart, 8 would be half a heart

global script Active{
    void run(){
        int ResistanceRingLinkHP = Link->HP;
        while(true){
            int randomNumber = Rand(100);
            if ( Link->HP <= 0 && ResistanceRingLinkHP > ResistanceRingLowestHealth
            && ( (Link->Item[ResistanceRingL1_ID] && randomNumber <= ResistanceRingL1_Chance)
            || (Link->Item[ResistanceRingL2_ID] && randomNumber <= ResistanceRingL2_Chance)
            || (Link->Item[ResistanceRingL3_ID] && randomNumber <= ResistanceRingL3_Chance) ) ){
                Game->PlaySound(ResistanceRingSFX);
                Link->HP = ResistanceRingLowestHealth;
            }
            ResistanceRingLinkHP = Link->HP;
            Waitframe();
        }
    }
}