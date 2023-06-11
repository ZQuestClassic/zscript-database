// Script to create a title screen activated with a button press.
//      D0 = sound to play upon pressing start
//      D1 = time between button press and warp
//      NOTE: This script works by triggering screen secrets
//      upon pressing the button. Make sure to place secrets under Link!

ffc script titleScreen
{
    void run(int SFX, int delay)
    {
        while (!Link->PressStart)
        {
            Waitframe();
        }
        Game->PlaySound(SFX);
        Waitframes(delay);
        Screen->State[ST_SECRET];
        Screen->TriggerSecrets();  
    }
}