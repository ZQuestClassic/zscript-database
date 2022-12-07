import "std.zh"

// D0 is the number for the sound effect to play. Leave at 0 if you don't want one.
ffc script SecretsTriggeredByItem{
    void run(int sfx){
        while(true){
            if ( Screen->State[ST_ITEM] && !Screen->State[ST_SECRET] ) {
                Game->PlaySound(sfx);
                Screen->TriggerSecrets();
                Screen->State[ST_SECRET] = true;
            }
            Waitframe();
        }
    }
}