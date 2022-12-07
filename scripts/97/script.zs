//Include this lines without the backslashes once at the top of your script file.
//import "std.zh"

ffc script TrippyFloor
{
    void run(int bitmap, float step, int combo, int cset)
    {
        Screen->SetRenderTarget(bitmap);
        for(int i; i < 16; i++)
            for(int j; j < 16; j++)
                Screen->FastCombo(2, 16*i, 16*j, combo, cset, OP_OPAQUE);
        Screen->DrawBitmap(2, bitmap, 0, 0, 256, 256, 256, 0, 256, 256, 0, false);
        Screen->DrawBitmap(2, bitmap, 0, 0, 512, 256, 0, 256, 512, 256, 0, false);
        Screen->SetRenderTarget(RT_SCREEN);
        float angle = Randf(360);
        while(true)
        {
            Screen->DrawBitmap(2, bitmap, 0, 0, 512, 512, this->X-128, this->Y-168, 512, 512, angle, false);
            angle += step;
            if(angle<-360) angle+=360;
            else if(angle>=360) angle-=360;
            Waitframe();
        }
    }
}