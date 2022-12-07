import "std.zh"

// D0 - The SFX ID that you want to play.
ffc script OnEntrySound{
    
    void run(int sfx){
         
        // Play the sound effect.
        Game->PlaySound(sfx);    
        
        // Quit the script.
        Quit();
    }
    
}