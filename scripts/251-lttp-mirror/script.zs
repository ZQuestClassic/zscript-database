import"std.zh"
import"ffcscript.zh"

const int SfxMirror =62;
const int SfxError =61;
const int ComboAutoWarpA =2560;
const int MirrorTime =220;
const int Mapoverworld =1;
const int Dmapoverworld =0;
const int Mapdarkworld =2;
const int Dmapdarkworld =1;

item script mirror{
    void run (){
        int ffcScriptName[] = "mirrorFFC";
        int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
        RunFFCScript(ffcScriptNum, NULL);
    }
}
ffc script mirrorFFC {
    void run(){
        int targetDMap; //DMap to warp to
        int targetMap; //Map (not DMap) to warp to
        if (Game->GetCurDMap() == Dmapdarkworld){
            targetDMap = Dmapoverworld;
            targetMap = Mapoverworld;
        }
        else if (Game->GetCurDMap() == Dmapoverworld){
            targetDMap = Dmapdarkworld;
            targetMap = Mapdarkworld;
        }
        else{ //Invalid Dmap
            Game->PlaySound(SfxError);
            return;
        }
        if ( Game->GetComboSolid(targetMap, Game->GetCurScreen(), ComboAt(Link->X+8,Link->Y+ 8)) ){
            Game->PlaySound(SfxError);
            return;
        }
        Game->PlaySound(SfxMirror);
        Screen->SetSideWarp(0, Game->GetCurDMapScreen(), targetDMap, WT_IWARPWAVE);
       
        Link->CollDetection = false;
        Screen->Wavy = MirrorTime;
        for(int i = 0; i < MirrorTime; i++){
            Link->InputStart = false;
            Link->PressStart = false;
            Link->InputMap = false;
            Link->PressMap = false;

            WaitNoAction();
        }
        Link->CollDetection = true;
       
        this->Data = ComboAutoWarpA;
    }
}