//import "std.zh"

//Global Constants
const int MISC_SOLIDFFC          = 14; //A misc value between 0 and 15 to denote a ffc as solid.
const int MISC_SFFC_X            = 0;  //This can be used by other ffcs as long as they're not solid.
const int SFFC_SIDEVIEWTHRESHOLD = 12; //Sideview X Overlap: used for hitdetection.
const int CRUSH_DAMAGE           = 8;  //Damage in 16ths of a heart dealt to link when he is crushed.
const int SF_SIDEWARP            = 2;  //The flag to denote that Left/Right sidewarps are used on a screen.
const int BIG_LINK               = 0;
const int CT_LADDER              = 0;  //If not using CT_RIGHTSTATUE

//Don't touch me, don't even think about setting these variables. HEY!
float SFFC_LinkX;
float SFFC_LinkY;

// this utility routine by Saffith checks for walkability of combos
bool isSolid(int x, int y){
    if(x<0 || x>255 || y<0 || y>175) return false;
    int mask=1111b;
    if(x%16< 8) mask&=0011b;
    else mask&=1100b;
    if(y%16< 8) mask&=0101b;
    else mask&=1010b;
    return (!(Screen->ComboS[ComboAt(x, y)]&mask)==0);
}
// this utility is used by the ffcs to check if the platform can move link.
bool CanMoveLink(int x){
    if(x > 0) x+=Link->X+16;
    else if(x < 0) x+=Link->X-1;
    if(x<0) return (Game->GetCurScreen()%16==0 && ScreenFlag(SF_MISC, SF_SIDEWARP));
    if(x>240) return (Game->GetCurScreen()%16==15 && ScreenFlag(SF_MISC,SF_SIDEWARP));
    int mask;
    if(x < Link->X) mask = 1100b;
    else mask = 11b;
    if(Cond(BIG_LINK || IsSideview(),false,true)){
        if(Link->Y % 16 < 8) mask &= ~101b;
    }
    return (Screen->ComboS[ComboAt(x, Link->Y)]&mask)==0 && !OnLadder();
}

// You can customize these functions to suit your needs.
// this utility is used to check if link is doing something that would interfer with him using an item.
bool LinkBusy()
{
    return (Link->Action==LA_ATTACKING||Link->Action == LA_CHARGING||Link->Action==LA_FROZEN);
}

// this utility is used to check if link using the feather.
bool UseFeather()
{
    return !LinkBusy() && ((GetEquipmentA()==I_ROCSFEATHER && Link->PressA) || (GetEquipmentB()==I_ROCSFEATHER && Link->PressB));
}

// this utility is used to check if link is on a sideview ladder.
bool OnLadder()
{
    int ct = Screen->ComboT[ComboAt(CenterLinkX(),CenterLinkY())];
    return (ct == Cond(CT_LADDER==0,CT_RIGHTSTATUE,CT_LADDER));
}

global script slot2_solidffc

{
    void run()
    {
        int olddmap = Game->GetCurDMap();
        int oldscreen = Game->GetCurScreen();
        int startx = Link->X;
        int starty = Link->Y;
        int linkxpos = startx;
        int linkypos = starty;
        bool dragged;
        while(true)
        {
            if((Link->Action!=LA_SCROLLING) && (olddmap != Game->GetCurDMap() || oldscreen != Game->GetCurScreen()))
            {
                olddmap = Game->GetCurDMap();
                oldscreen = Game->GetCurScreen();
                startx = Link->X;
                starty = Link->Y;
            }
            if(IsSideview())
            {
                //A fix for something I should of done different D:
                float linkposition = SFFC_SideviewShenanigans(linkxpos, linkypos);
                linkxpos = linkposition&0xFF;
                linkypos = (linkposition>>8)&0xFF;
                if((linkposition%1)*10000) dragged=true;
                else dragged=false;
            }
            Waitdraw();
            SolidFFCs(startx, starty, linkxpos, linkypos, dragged);
            linkxpos = Link->X;
            linkypos = Link->Y;
            Waitframe();
        }
    }
}

//Editing anything beneath this point may cause sickness, coma, brain anuerysm, or death.
//Do so at your own risk and don't hold me responsible. Have a good day! ^_^

void SolidFFCs(int startx, int starty, int linkxpos, int linkypos, bool dragged)
{
    int reservedx = Link->X;
    int reservedy = Link->Y;
    bool linkmoved[4]; //Up Down Left Right
    int edge[2];
    bool crushed;
    for(int i = 1; i <= 32 && !crushed; i++)
    {
        ffc f = Screen->LoadFFC(i);
        if(!f->Misc[MISC_SOLIDFFC]) continue;
        if(!SFFC_LinkCollision(f, edge)) continue;
        if(!SFFC_SetDirection(f, linkmoved, edge, linkxpos, linkypos))
        {
            crushed = SFFC_CrushLink(f, linkmoved, edge, startx, starty, dragged);
            continue;
        }
        crushed = SFFC_CrushLink(f, linkmoved, edge, startx, starty, dragged);
        if(!crushed)
        {
            if(edge[0]==DIR_UP || edge[0]==DIR_DOWN)
            {
                if(!IsSideview())
                {
                    SFFC_LinkY += edge[1];
                    if(Abs(SFFC_LinkY) >= 1) Link->Y += Floor(SFFC_LinkY);
                    SFFC_LinkY -= Floor(SFFC_LinkY);
                }
                else if(edge[0]==DIR_UP)
				{
					if(!(OnLadder() && UseFeather()))
				        Link->Jump=0; //Negate dat dang gravity
				}
				if(Link->InputLeft || Link->InputRight) Link->X = reservedx;
            }
            else if(edge[0]==DIR_LEFT ||edge[0]==DIR_RIGHT)
            {
                SFFC_LinkX += edge[1];
                if(Abs(SFFC_LinkX) >= 1) Link->X += Floor(SFFC_LinkX);
                SFFC_LinkX -= Floor(SFFC_LinkX);
                if(Link->InputUp || Link->InputDown || IsSideview()) Link->Y=reservedy;
            }
            reservedx=Link->X;
            reservedy=Link->Y;
        }
    }
}

//As usual Sideview gravity breaks everything even solid ffcs. XD
int SFFC_SideviewShenanigans(int linkxpos, int linkypos)
{
    bool linkmoved[4]; //Up Down Left Right
    int edge[2];
    float dragged;
    for(int i = 1; i <= 32; i++)
    {
        ffc f = Screen->LoadFFC(i);
        if(!f->Misc[MISC_SOLIDFFC]) continue;
        if(!SFFC_LinkCollision(f, edge) || !SFFC_SetDirection(f, linkmoved, edge, linkxpos, linkypos))
        {
            f->Misc[MISC_SFFC_X] = f->X;
            continue;
        }
        if(edge[0]==DIR_UP)
        {
             if(!OnLadder())
             {
                 if(UseFeather())
                 {
                     itemdata feather = Game->LoadItemData(I_ROCSFEATHER);
                     Link->Jump = feather->InitD[0];
                     Game->PlaySound(feather->UseSound);
                     f->Misc[MISC_SFFC_X] = f->X;
                     break; //Cause it should only happen once per frame.
                 }
                 else
                 {
                     if(Link->Jump<=0) Link->Jump=0;
                     Link->Y = f->Y-16;
                 }
                 linkypos = Link->Y;
             }
             if(CanMoveLink(f->X-f->Misc[MISC_SFFC_X]))
             {
                 SFFC_LinkX += f->X-f->Misc[MISC_SFFC_X];
                 if(Abs(SFFC_LinkX) >= 1)
                 {
                     Link->X += Floor(SFFC_LinkX);
                     SFFC_LinkX -= Floor(SFFC_LinkX);
                 }
                 linkxpos = Link->X;
                 dragged=0.9999;
             }
             else
             {
                 linkxpos = Link->X;
                 Link->Jump=0;
                 dragged=0;
             }
        }
        else if(edge[0]==DIR_DOWN && Link->Jump>0)
        {
            Link->Jump=0;
        }
        f->Misc[MISC_SFFC_X] = f->X;
    }
    return (linkxpos|(linkypos<<8))+dragged;
}

//Link Collision
bool SFFC_LinkCollision(ffc f, int edge)
{
    int linktop = Link->Y+Cond(BIG_LINK || IsSideview(), 0, 8)>>0;
    int linkbottom = Link->Y+15>>0;
    int linkleft = Link->X>>0;
    int linkright = Link->X+15>>0;
    int top = HitboxTop(f)>>0;
    int bottom = HitboxBottom(f)>>0;
    int left = HitboxLeft(f)>>0;
    int right = HitboxRight(f)>>0;
    int mod=0;
    if(IsSideview()) mod = SFFC_SIDEVIEWTHRESHOLD;
    // horizontal
    if(linktop < bottom && linkbottom > top)
    {
        if(IsSideview()) mod = 16-mod; //Less math.
        if(CenterLinkX() < CenterX(f)) // Left Side
        {
            edge[0]=DIR_LEFT;
            return (linkright >= left+mod);
        }
        else //Right Side
        {
            edge[0]=DIR_RIGHT;
            return (linkleft <= right-mod);
        }
    }
    // vertical
    else if(linkleft < right && linkright > left)
    {
        if(CenterLinkY() < CenterY(f)) // Top Side
        {
            edge[0]=DIR_UP;
            if(IsSideview()) return linkbottom+1 >= top && (linkleft > left-mod && linkleft < left+mod+(f->TileWidth-1)*16);
            else return (linkbottom >= top);
        }
        else //Bottom Side
        {
            edge[0]=DIR_DOWN;
            return (linktop <= bottom);
        }
    }
    else return false;
}

bool SFFC_SetDirection(ffc f, bool linkmoved, int edge, int linkxpos, int linkypos)
{
    //Move link to his old position.
    int x = Link->X;
    int y = Link->Y;
    Link->X = linkxpos;
    Link->Y = linkypos;
    //Then check for collisions again.
    bool ret = SFFC_LinkCollision(f, edge);
    //If we get here we know he didn't walk on the ffc and we got stuff to do.
    if(edge[0]==DIR_UP) edge[1] = -Abs(HitboxTop(f)-(Link->Y+15));
    else if(edge[0]==DIR_DOWN) edge[1] = Abs(HitboxBottom(f)-(Link->Y+Cond(BIG_LINK || IsSideview(),0,8)));
    else if(edge[0]==DIR_LEFT) edge[1] = -Abs(HitboxLeft(f)-(Link->X+15));
    else if(edge[0]==DIR_RIGHT) edge[1] = Abs(HitboxRight(f)-Link->X);
    linkmoved[edge[0]] = true;
    if(!ret)
    {
        if(Link->X >= HitboxLeft(f)-15 && Link->X <= HitboxRight(f) &&
          (Link->InputLeft||Link->InputRight)) Link->X=x;
        else if(Link->Y >= HitboxTop(f)-15 && Link->Y+Cond(BIG_LINK || IsSideview(),0,8) <= HitboxBottom(f) &&
          (Link->InputUp||Link->InputDown) || IsSideview()) Link->Y=y;
    }
    return ret;
}

bool SFFC_CrushLink(ffc f, bool linkmoved, int edge, int linkx, int linky, bool dragged)
{
    // Solid Combos
    bool crush; //Canwalk sucks, do it yourself guys. :)
    if(!IsSideview()) dragged = false;
    if(edge[0]==DIR_UP)
    {
         crush = isSolid(Floor(CenterLinkX()), Floor(Link->Y+Cond(BIG_LINK || IsSideview(), 0,8)+edge[1])) && !dragged;
         if(IsSideview() && crush) crush = (Floor(Link->Y)+16+edge[1]>=HitboxTop(f)); //Squash Bug Fix.
    }
    else if(edge[0]==DIR_DOWN)
         crush = isSolid(Floor(CenterLinkX()), Floor(Link->Y+15+edge[1]));
    else if(edge[0]==DIR_LEFT)
         crush = isSolid(Floor(Link->X+edge[1]), Floor(Link->Y+Cond(BIG_LINK || IsSideview(), 0,8)));
    else if(edge[0]==DIR_RIGHT)
         crush = isSolid(Floor(Link->X+15+edge[1]), Floor(Link->Y+Cond(BIG_LINK || IsSideview(), 0,8)));
    // Solid FFCs
    if(!crush)
    {
        for(int i; i < 4; i++)
        {
            if(linkmoved[i] && i==OppositeDir(edge[0]))
            {
                crush=true;
                break;
            }
        }
    }
    // Crushing Behavior
    if(crush)
    {
        Link->X = Clamp(linkx,0,240);
        Link->Y = Clamp(linky,0,160);
        Link->HP -= CRUSH_DAMAGE;
        Link->Action = LA_GOTHURTLAND;
        Link->HitDir = -1;
        Game->PlaySound(SFX_OUCH);
    }
    return crush;
}

ffc script SolidFFC
{
    void run()
    {
        this->Misc[MISC_SOLIDFFC] = 1;
        this->Misc[MISC_SFFC_X] = this->X;
    }
}