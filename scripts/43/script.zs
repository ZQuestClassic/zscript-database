//Include this line at the top of your script at least once.
//import "std.zh"

const int CR_BAIT = 8; //CR_SCRIPT2 by default

item script BaitBag
{
    void run(int sprite, int time, int max)
    {
        if(Game->Counter[CR_BAIT]==0) Quit();
        if(NumLWeaponsOf(LW_BAIT) >= Max(1,max)) Quit();
        Game->Counter[CR_BAIT]--;
        lweapon bait = Screen->CreateLWeapon(LW_BAIT);
        bait->UseSprite(Cond(sprite==0, 14, sprite));
        bait->X = Link->X+InFrontX(Link->Dir,0);
        bait->Y = Link->Y+InFrontY(Link->Dir,0);
        bait->DeadState = Cond(time==0,768, time);
    }
}