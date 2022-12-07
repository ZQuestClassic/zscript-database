import "std.zh"

const int LinkDrownSFX = 0; //Replace this number with the Sound Effect number for drowning

global script Slot2{
    void run(){
        bool LinkHasDrowned = false;
        while(true){
            if ( LinkHasDrowned == true && Link->Action != LA_DROWNING )
                LinkHasDrowned = false;
            if( Link->Action == LA_DROWNING && LinkHasDrowned == false){
                LinkHasDrowned = true;
                Game->PlaySound(LinkDrownSFX);
            }
            Waitframe();
        }
    }
}