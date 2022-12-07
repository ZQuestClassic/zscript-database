import "std.zh"

const int BombsScreenShakeFrames = 10; //how many frames a bomb shakes the screen
const int BombsScreenShakeSFrames = 30; //how many frames a superbomb shakes the screen
const int BombsScreenShakeWeaponMisc = 0; //what weapon misc to use for explosion eweapons and lweapons (leave at 0 if no other script uses them)

global script Active {
    void run(){
        while(true){
            BombsScreenShake(); //put this line into your global loop (to combine this script with your global script)
            Waitframe();
        }
    }
}

void BombsScreenShake() {
    for (int i = 1; i <= Screen->NumLWeapons(); i++) { //lweapons
        lweapon lweap = Screen->LoadLWeapon(i);
        if ( lweap->ID == LW_BOMBBLAST && lweap->Misc[BombsScreenShakeWeaponMisc] == 0 ) { //if there is a normal explosion on screen and the misc value is 0
            Screen->Quake = BombsScreenShakeFrames; //shake the screen
            lweap->Misc[BombsScreenShakeWeaponMisc] = 1; //change the misc value to 1
        }
        else if ( lweap->ID == LW_SBOMBBLAST && lweap->Misc[BombsScreenShakeWeaponMisc] == 0 ) { //if there is a super explosion on screen and the misc value is 0
            Screen->Quake = BombsScreenShakeSFrames; //shake the screen
            lweap->Misc[BombsScreenShakeWeaponMisc] = 1; //change the misc value to 1
        }
    }
    for (int i = 1; i <= Screen->NumEWeapons(); i++) { //eweapons
        eweapon eweap = Screen->LoadEWeapon(i);
        if ( eweap->ID == EW_BOMBBLAST && eweap->Misc[BombsScreenShakeWeaponMisc] == 0 ) { //if there is a normal explosion on screen and the misc value is 0
            Screen->Quake = BombsScreenShakeFrames; //shake the screen
            eweap->Misc[BombsScreenShakeWeaponMisc] = 1; //change the misc value to 1
        }
        else if ( eweap->ID == EW_BOMBBLAST && eweap->Misc[BombsScreenShakeWeaponMisc] == 0 ) { //if there is a super explosion on screen and the misc value is 0
            Screen->Quake = BombsScreenShakeSFrames; //shake the screen
            eweap->Misc[BombsScreenShakeWeaponMisc] = 1; //change the misc value to 1
        }
    }
}