//Add this line once at the top of your script file.
import "std.zh"
 
ffc script TallPushCombo
{
    void run()
    {
        while(true)
        {
            while(Screen->ComboD[ComboAt(this->X, this->Y+(this->TileHeight*16))] != Screen->UnderCombo)
                Waitframe();
 
            //We need to know what direction the block is going to move ahead of time as waitdraw cannot be used.
            float xstep;
            float ystep;
            if(Link->Dir==DIR_UP)
               ystep = -.5;
            else if(Link->Dir==DIR_DOWN)
               ystep = .5;
            else if(Link->Dir==DIR_LEFT)
               xstep = -.5;
            else if(Link->Dir==DIR_RIGHT)
               xstep = .5;
            for(int i; i < 32; i++) //Blocks are pushed for 32 frames.
            {
                this->X += xstep;
                this->Y += ystep;
                Waitframe();
            }
            this->X = GridX(this->X);
            this->Y = GridY(this->Y);
            Waitframe();
        }
    }
}