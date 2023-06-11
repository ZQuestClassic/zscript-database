//include this line below once per quest at the top of your zscript file.
//import "std.zh"

const int WAIT_TIME = 84; //default if not specified

ffc script CarryoverSecret
{
    void run(int map, int screen, int bitmap, int waittime)
    {
        while(Screen->State[ST_SECRET]) Quit();
        while(!Screen->State[ST_SECRET]) Waitframe();
        //SuspendGhostZHScripts(); //Uncomment this if you use ghost.zh
        if(waittime==0) waittime=WAIT_TIME;
        for(int i; i < waittime; i++)
        {
            Screen->SetRenderTarget(bitmap);
            Screen->DrawScreen(6, map, screen, 0,0,0);
            Screen->SetRenderTarget(RT_SCREEN);
            Screen->DrawBitmap(6, bitmap, 0, 0, 256, 176, 0, 56, 256, 176, 0, false);
            NoAction();
            Link->InputStart=false;
            Link->InputMap=false;
            Waitframe();
        }
        //ResumeGhostZHScripts(); //Uncomment this if you use ghost.zh
    }
}