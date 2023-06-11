const int CMB_ENEMSTUN = 33930; //Combo for the enemy stun animations
const int CMB_CSET_ENEMSTUN = 8; //CSet of this combo
const int WPS_ENEMDEATH = 96; //Weapon/Misc sprite for enemy death animations

global script active{
    void run(){
        while(true){
            deathAnimations();
            Waitframe();
        }
    }
}

void deathAnimations(){
    for(int i = Screen->NumNPCs(); i > 0; i--){
        npc enem = Screen->LoadNPC(i);
        if ( enem->HP <= 0 && enem->HP > HP_SILENT ){
            lweapon Poof = CreateLWeaponAt(LW_SPARKLE, CenterX(enem)-8, CenterY(enem)- 8);
            Poof->UseSprite(WPS_ENEMDEATH);
            enem->HP = HP_SILENT;
        }
        else if ( enem->HP > 0 && enem->Stun > 0 ){
            Screen->DrawCombo(4, CenterX(enem)-8, enem->Y-16, CMB_ENEMSTUN, 1, 1, CMB_CSET_ENEMSTUN, -1, -1, 0, 0, 0, -1, FLIP_NO, true, OP_OPAQUE);
        }
    }
}