import "std.zh"
import "FFCscript.zh"

const int MagicClock_ItemID = 123; //must be the item number of the magic clock
const int MagicClock_ActivateSFX = 60; //sound effect for activating the magic clock
const int MagicClock_WarpSFX = 61; //sound effect for the time warp
const int MagicClock_Combo = 892; //combo number to use for the animation sprite
const int MagicClock_CSet = 8; //the cset of that combo
const int MagicClock_Frames = 120; //number of frames it waits until it warps Link

item script MagicClockItem{
    void run(){
        Game->PlaySound(MagicClock_ActivateSFX);
        int ffcScriptName[]="MagicClockFFC";
        int ffcScriptNum=Game->GetFFCScript(ffcScriptName);
        int ffcID=FindFFCRunning(ffcScriptNum);
        if(ffcID==0)
            RunFFCScript(ffcScriptNum, 0);
        else{
            ffc f=Screen->LoadFFC(ffcID);
            f->Misc[0]=MagicClock_Frames;
        }
    }
}

ffc script MagicClockFFC{
    void run(){
        this->Flags[FFCF_ETHEREAL] = true;
        this->Misc[0]=MagicClock_Frames;
        int MagicClock_HP = Link->HP;
        int MagicClock_X = Link->X;
        int MagicClock_Y = Link->Y;
        int MagicClock_Dir = Link->Dir;
        int MagicClock_SwordJinx = Link->SwordJinx;
        int MagicClock_ItemJinx = Link->ItemJinx;
        int MagicClock_Drunk = Link->Drunk;
        while(true){
            if ( this->Misc[0] != 0 && GetEquipmentB() == MagicClock_ItemID ) {
                Link->InputB = false;
                Link->PressB = false;
            }
            if ( this->Misc[0] != 0 && GetEquipmentA() == MagicClock_ItemID ) {
                Link->InputA = false;
                Link->PressA = false;
            }
            if ( this->Misc[0] == 1 ) { //time warp
                Game->PlaySound(MagicClock_WarpSFX);
                Link->HP = MagicClock_HP;
                Link->X = MagicClock_X;
                Link->Y = MagicClock_Y;
                Link->Dir = MagicClock_Dir;
                Link->SwordJinx = MagicClock_SwordJinx;
                Link->ItemJinx = MagicClock_ItemJinx;
                Link->Drunk = MagicClock_Drunk;
            }
            if ( this->Misc[0] == 0 ) {
                MagicClock_HP = Link->HP;
                MagicClock_X = Link->X;
                MagicClock_Y = Link->Y;
                MagicClock_Dir = Link->Dir;
                MagicClock_SwordJinx = Link->SwordJinx;
                MagicClock_ItemJinx = Link->ItemJinx;
                MagicClock_Drunk = Link->Drunk;
            }
            else {
                if ( this->Misc[0] > 1 )
                    Screen->FastCombo(2, MagicClock_X, MagicClock_Y, MagicClock_Combo, MagicClock_CSet, OP_OPAQUE);
                this->Misc[0] --;
            }
            Waitframe();
        }
    }
}