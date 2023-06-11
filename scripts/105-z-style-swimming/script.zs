import "std.zh"

////////////////////////
/// Z3 Stle Swimming ///
///////////////////////////////////////////////////////
/// Version 14.1 - 22nd May, 2014                   ///
/// Script Credits: Avataro, MoscowModder, ZoriaRPG ///
///////////////////////////////////////////////////////
/// Updated code comments on 22nd May, 2014.        ///
///////////////////////////////////////////////////////



const int SwimPaddle = 0; //Set to swimming paddle sound.
bool isSwimming; //Establish boolean to determine of Link is swimming.

global script active {
    void run() {
        while(true) {
        paddle(); //This should be before Waitdraw.
        Waitdraw();
        Waitframe();
        }
    }
}


void paddle(){


    int combo=Screen->ComboT[ComboAt(Link->X+8, Link->Y+12)];
    if(combo==CT_WATER || combo==CT_SWIMWARP || combo==CT_DIVEWARP || (combo>=CT_SWIMWARPB && combo<=CT_DIVEWARPD)) 
    //Check to see if Link is on a swim-combo, and is swimming.
    {
    isSwimming = true;
    }
    else{
    isSwimming = false;
    }
    
    if( Link->Dir == DIR_UP //If Link is facing up...
                && Link->Action == LA_SWIMMING //and is swimming...
                && isSwimming == true //combo is a swim combo...
                && Link->InputB //and presses B...
                //You can change this to another button, such as L, R, or an Ext button... 
                //Do not set this to A if you have diving enabled.
                && !Screen->isSolid(Link->X,Link->Y+6) //NW Check Solidity
                && !Screen->isSolid(Link->X+7,Link->Y+6) //N Check Solidity
                && !Screen->isSolid(Link->X+15,Link->Y+6) //NE Check Solidity
            )
            {
            Link->Y -= 2; //The number of TILES (16 pixels each) that Link will move UP, when paddling.
            Game->PlaySound(SwimPaddle); //Play the paddling sound set as a constant.
            }
    else if( Link->Dir == DIR_DOWN  //If Link is facing down...
                && Link->Action == LA_SWIMMING //and is swimming...
                && isSwimming == true //combo is a swim combo...
                && Link->InputB //and presses B...
                //You can change this to another button, such as L, R, or an Ext button...
                //Do not set this to A if you have diving enabled.
                && !Screen->isSolid(Link->X,Link->Y+17) //SW Check Solidity
                && !Screen->isSolid(Link->X+7,Link->Y+17) //S Check Solidity
                && !Screen->isSolid(Link->X+15,Link->Y+17) //SE Check Solidity
            )
            {
            Link->Y += 2; //The number of TILES (16 pixels each) that Link will move DOWN, when paddling.
            Game->PlaySound(SwimPaddle); //Play the paddling sound set as a constant.
            }
    if( Link->Dir == DIR_RIGHT //If Link is facing right....
                && Link->Action == LA_SWIMMING  //and is swimming...
                && isSwimming == true //combo is a swim combo...
                && Link->InputB //and presses B... 
                //You can change this to another button, such as L, R, or an Ext button...
                //Do not set this to A if you have diving enabled.
                && !Screen->isSolid(Link->X+17,Link->Y+8) //NE Check Solidity
                && !Screen->isSolid(Link->X+17,Link->Y+15) //SE Check Solidity
            )
            {
            Link->X += 2; //The number of TILES (16 pixels each) that Link will move RIGHT, when paddling.
            Game->PlaySound(SwimPaddle); //Play the paddling sound set as a constant.
            }
    if( Link->Dir == DIR_LEFT //If Link is facing left...
                && Link->Action == LA_SWIMMING //and is swimming...
                && isSwimming == true //combo is a swim combo...
                && Link->InputB //and presses B...
                //You can change this to another button, such as L, R, or an Ext button...
                //Do not set this to A if you have diving enabled.
                && !Screen->isSolid(Link->X-2,Link->Y+8) //NW Check Solidity
                && !Screen->isSolid(Link->X-2,Link->Y+15) //SW Check Solidity
            )
            {
            Link->X -= 2; //The number of TILES (16 pixels each) that Link will move LEFT, when paddling.
            Game->PlaySound(SwimPaddle); //Play the paddling sound set as a constant.
            }
            
            

   

    if ( Link->Action == LA_SWIMMING && isSwimming == false )
    //If Link is NOT swimming...
    {
    Link->Action = LA_NONE;
    //Change Link tile back to normal. This prevents Link from swimming on solid combos.
    }
    
    
}