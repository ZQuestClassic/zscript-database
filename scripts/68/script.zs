///Common Constant, only need to define once per script file.
const int BIG_LINK = 0; //Set this to 1 if using the Large Link Hit Box feature.

//Constants used by Ice Combos
const int CT_ICECOMBO = 142; //The combo type "Script1 by default"
const int ICE_ACCELERATION = 1;
const int ICE_DECELERATION = 1;
const int ICE_MAXSTEP     = 150;

//Declare global variables used by Ice Combos.
bool isScrolling;
bool onice;
float Ice_X;
float Ice_Y;
int Ice_XStep;
int Ice_YStep;
//End declaration

//Active Script
global script slot2_icecombos
{
    void run()
    {
        //Setup variables for ice combos.
        Setup_IceCombos();

        //Variable that stores Game->GetCurScreen() the previous frame.
        int oldscreen = Game->GetCurScreen();

        //Main Loop
        while(true)
        {
            Waitdraw();
            Update_IceCombos(oldscreen);
            oldscreen = Game->GetCurScreen();
            Waitframe();
        }
    }
}


//Initializes global variables used for ice combos.
void Setup_IceCombos()
{
    isScrolling = false;
    onice = false;
    Ice_X = 0;
    Ice_Y = 0;
    Ice_XStep = 0;
    Ice_YStep = 0;
}

//Adds Ice Combo functionally to CT_ICECOMBO;
void Update_IceCombos(int oldscreen)
{
    //Update Variables
    if(Link->Action != LA_SCROLLING)
    {
        if(isScrolling || oldscreen != Game->GetCurScreen() || (!onice && OnIce()))
        {
            Ice_X = Link->X;
            Ice_Y = Link->Y;
            if(isScrolling)
                isScrolling = false;
            else
            {
                Ice_XStep = 0;
                Ice_YStep = 0;
            }
        }
        onice = OnIce();
    }
    else
    {
        isScrolling = true;
        return;
    }

    //Ice Physics
    if(onice)
    {
        //Y Adjustment
        if(Link_Walking() && (Link->InputUp || Link->InputDown))
        {
            if(Link->InputUp && !Link->InputDown)
                Ice_YStep -= ICE_ACCELERATION;
            else if(!Link->InputUp && Link->InputDown)
                Ice_YStep += ICE_ACCELERATION;
        }
        else if(Ice_YStep != 0)
            Ice_YStep = Cond(Abs(Ice_YStep) - ICE_DECELERATION > 0, Ice_YStep - Sign(Ice_YStep)*ICE_DECELERATION, 0);
        Ice_YStep = Clamp(Ice_YStep, -ICE_MAXSTEP, ICE_MAXSTEP);

        //X Adjustment
        if(Link_Walking() && (Link->InputLeft || Link->InputRight))
        {
            if(Link->InputLeft && !Link->InputRight)
                Ice_XStep -= ICE_ACCELERATION;
            else if(!Link->InputLeft && Link->InputRight)
                Ice_XStep += ICE_ACCELERATION;
        }
        else if(Ice_XStep != 0)
            Ice_XStep = Cond(Abs(Ice_XStep) - ICE_DECELERATION > 0, Ice_XStep -Sign(Ice_XStep)*ICE_DECELERATION, 0);
        Ice_XStep = Clamp(Ice_XStep, -ICE_MAXSTEP, ICE_MAXSTEP);

        //Reset the Ice Position to Link's Actual Position if he's hurt or hopping out of water.
        if(Link->Action == LA_GOTHURTLAND || Link->Action == LA_HOPPING)
        {
            Ice_X = Link->X;
            Ice_Y = Link->Y;
        }

        //Initialize variables for solidity checking.
        int newx = (Ice_X + Ice_XStep/100)<<0;
        int newy = (Ice_Y + Ice_YStep/100)<<0;

        //Vertical Edge
        if(newx < Ice_X<<0)
        {
            for(int y = Ice_Y+Cond(BIG_LINK, 0, 8); y < (Ice_Y<<0) + 16 && Ice_XStep != 0; y++)
            {
                if(Screen->isSolid(newx, y))
                    Ice_XStep = 0;
            }
        }
        else if(newx > Ice_X<<0)
        {
            for(int y = Ice_Y+8; y < (Ice_Y<<0) + 16 && Ice_XStep != 0; y++)
            {
                if(Screen->isSolid(newx+15, y))
                    Ice_XStep = 0;
            }
        }

        //Horizontal Edge
        if(newy < Ice_Y<<0)
        {
            for(int x = Ice_X; x < (Ice_X<<0) + 16 && Ice_YStep != 0; x++)
            {
                if(Screen->isSolid(x, newy+Cond(BIG_LINK, 0, 8)))
                {
                    Ice_YStep = 0;
                }
            }
        }
        else if(newy > Ice_Y<<0)
        {
            for(int x = Ice_X; x < (Ice_X<<0) + 16 && Ice_YStep != 0; x++)
            {
                if(Screen->isSolid(x, newy+15))
                {
                    Ice_YStep = 0;
                }
            }
        }

        Ice_X += Ice_XStep/100;
        Ice_Y += Ice_YStep/100;
        Link->X = Ice_X;
        Link->Y = Ice_Y;
    }
    else
    {
        Ice_XStep = 0;
        Ice_YStep = 0;
    }
}

//Function used to check if Link is over a ice combo.
bool OnIce()
{
    if(Link->Z != 0)
        return false;
    else
    {
        int comboLoc = ComboAt(Link->X + 8, Link->Y + 12);
        if(Screen->ComboT[comboLoc] == CT_ICECOMBO)
            return true;
        else if(Screen->LayerScreen(1) != -1 && GetLayerComboT(1, comboLoc) == CT_ICECOMBO)
            return true;
        else if(Screen->LayerScreen(2) != -1 && GetLayerComboT(2, comboLoc) == CT_ICECOMBO)
            return true;
        else
            return false;
    }
}

//Returns true, if keyboard input is moving Link.
bool Link_Walking()
{
    if(UsingItem(I_HAMMER)) return false;
    else return (Link->Action == LA_WALKING || Link->Action == LA_CHARGING || Link->Action == LA_SPINNING);
}