import "std.zh"

//D0 = combo for triggers (they need combo type NONE, only place them on layer 0)
//D1 = combo for activated triggers
//D2 = sfx for stepping on trigger (leave at 0 if not needed)
//D3 = secret sfx (leave at 0 if not needed)

ffc script StepTriggersComboSecret{
    void run(int triggerOff, int triggerOn, int triggerSFX, int secretSFX){
        if ( Screen->State[ST_SECRET] == true )
            Quit();
        int numberOfTriggers = 0;
        for(int i = 0; i < 175; i++){
            if ( Screen->ComboD[i] == triggerOff )
                numberOfTriggers ++;
        }
        while(true){
            if ( Screen->ComboD[ComboAt(Link->X+8, Link->Y+12)] == triggerOff && Link->Z == 0 ) {
                Game->PlaySound(triggerSFX);
                Screen->ComboD[ComboAt(Link->X+8, Link->Y+12)] = triggerOn;
                numberOfTriggers --;
            }
            if ( numberOfTriggers == 0 ) {
                Game->PlaySound(secretSFX);
                Screen->TriggerSecrets();
                Screen->State[ST_SECRET] = true;
                Quit();
            }
            Waitframe();
        }
    }
}