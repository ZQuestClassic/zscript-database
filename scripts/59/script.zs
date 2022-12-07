const int WATER_CURRENT_FREQ = 5; //# of frames between moving Link (CANNOT BE LOWER THAN 0)
const int WATER_CURRENT_FLAG = 98; //First of 4 flags to use in the order Up, Down, Left, Right


//FFC version
//D0 = current frequency (defaults to WATER_CURRENT_FREQ)
ffc script flowingWater{
    void run ( int frequency ){
        if( frequency < 1 )
            frequency = WATER_CURRENT_FREQ;
        while ( true ){
            doCurrents();
            Waitframes(frequency);
            swimLandCheck();
        }
    }
}



//Global version
global script FlowingWater{
    int waterCounter = 0;
    void run ( ){
        while ( true ){
            if ( waterCounter >= WATER_CURRENT_FREQ )
            {
                doCurrents();
                waterCounter = 0;
            }
            waterCounter++;
            swimLandCheck();
            Waitframe(); //There must be only one of these at the bottom of your while(true) loop
        }
    }
}

void doCurrents (){
    if ( Link->Action==LA_SWIMMING || Link->Action==LA_DIVING ){//If Link is swimming...

        //Move Link based on the current's direction...
        //but make sure it isn't solid
        
        //Up
        if( ComboFI(Link->X,Link->Y+8, WATER_CURRENT_FLAG) //If swimming in the appropriate flag
        //And the following combos ahead of Link are not solid
        && !Screen->isSolid(Link->X,Link->Y+6) //NW
        && !Screen->isSolid(Link->X+7,Link->Y+6) //N
        && !Screen->isSolid(Link->X+15,Link->Y+6) //NE

        //Check if the combo below Link is water to prevent getting pushed out
        && waterCheck( ComboAt(Link->X,Link->Y+6))
        && waterCheck( ComboAt(Link->X+7,Link->Y+6))
        && waterCheck( ComboAt(Link->X+15,Link->Y+6))
        )
            Link->Y -= 2;
        //Down
        if( ComboFI(Link->X,Link->Y+8, WATER_CURRENT_FLAG+1 )
        && !Screen->isSolid(Link->X,Link->Y+17) //SW
        && !Screen->isSolid(Link->X+7,Link->Y+17) //S
        && !Screen->isSolid(Link->X+15,Link->Y+17) //SE

        && waterCheck( ComboAt(Link->X,Link->Y+17))
        && waterCheck( ComboAt(Link->X+7,Link->Y+17))
        && waterCheck( ComboAt(Link->X+15,Link->Y+17))
        )
            Link->Y += 2;
        //Left
        if( ComboFI(Link->X,Link->Y+8, WATER_CURRENT_FLAG+2 )
        && !Screen->isSolid(Link->X-2,Link->Y+8) //NW
        && !Screen->isSolid(Link->X-2,Link->Y+15) //SW
        )
            Link->X -= 2;
        //Right
        if( ComboFI(Link->X,Link->Y+8, WATER_CURRENT_FLAG+3 )
        && !Screen->isSolid(Link->X+17,Link->Y+8) //NE
        && !Screen->isSolid(Link->X+17,Link->Y+15) //SE
        
        && waterCheck( ComboAt(Link->X+17,Link->Y+8) )
        && waterCheck( ComboAt(Link->X+17,Link->Y+15) )
        )
            Link->X += 2;
    }    
}

//Prevents Link from swimming on land
void swimLandCheck(){
        if( !waterCheck( ComboAt(Link->X,Link->Y+8) ) //If Link is not in the water...
        && ( Link->Action==LA_SWIMMING || Link->Action==LA_DIVING ) ) //and swimming...
            Link->Action = LA_NONE; //Make him stop swimming
}

//Checks if the designated combo is any water type
bool waterCheck(int cmb){
    if( Screen->ComboT[cmb] == CT_WATER
    || Screen->ComboT[cmb] == CT_SWIMWARP
    || Screen->ComboT[cmb] == CT_SWIMWARPB
    || Screen->ComboT[cmb] == CT_SWIMWARPC
    || Screen->ComboT[cmb] == CT_SWIMWARPD
    || Screen->ComboT[cmb] == CT_DIVEWARP
    || Screen->ComboT[cmb] == CT_DIVEWARPB
    || Screen->ComboT[cmb] == CT_DIVEWARPC
    || Screen->ComboT[cmb] == CT_DIVEWARPD
    )
        return true; //The combo is water
    return false;
}