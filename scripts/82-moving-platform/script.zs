///Constants and Variables used by platform script;
const int DIAGONAL_MOVEMENT = 1; //Enable the option and change this to 0 for nes movement.
int onplatform; //Global variable use this to check if Link is on a platform for other scripts.
 
global script slot2_platform
{
    void run()
    {
        while(true)
        {
            NesMovementFix();
            Waitdraw();
            MovingPlatforms();
            Waitframe();
        }
    }
}
 
void NesMovementFix()
{
    if(DIAGONAL_MOVEMENT==0 && (Link->InputUp || Link->InputDown))
    {
        Link->InputLeft = false;
        Link->InputRight = false;
    }
}
 
void MovingPlatforms()
{
    onplatform = 0;
    if(Link->Z == 0)
    {
        int buffer[] = "movingplatform";
        for(int i = 1; i <= 32; i++)
        {
            ffc f = Screen->LoadFFC(i);
            if(f->Script != Game->GetFFCScript(buffer)) continue;
            if(Abs(Link->X + 8 - CenterX(f)) >= f->TileWidth*8) continue;
            if(Abs(Link->Y + 12 - CenterY(f)) >= f->TileHeight*8) continue;
            onplatform = FFCNum(f);
            break;
        }
    }
}
 
ffc script MovingPlatform
{
    void run()
    {
        float oldx = this->X;
        float oldy = this->Y;
        float linkx;
        float linky;
        while(true)
        {
            if(onplatform == FFCNum(this))
            {
                 linkx += this->X - oldx;
                 linky += this->Y - oldy;
                 if(linkx << 0 != 0)
                 {
                     Link->X += linkx << 0;
                     linkx -= linkx << 0;
                 }
                 if(linky << 0 != 0)
                 {
                     Link->Y += linky << 0;
                     linky -= linky << 0;
                 }
            }
            else
            {
                 linkx = 0;
                 linky = 0;
            }
            oldx = this->X;
            oldy = this->Y;
            Waitframe();
        }
    }
}