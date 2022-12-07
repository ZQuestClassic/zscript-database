ffc script Signpost{
    void run(int m,int input){
        int loc = ComboAt(this->X,this->Y);
        while(true){
            while(!AgainstComboBase(loc) || !SelectPressInput(input)) Waitframe();
            SetInput(input,false);
            Screen->Message(m);
            Waitframe();
        }
    }
    bool AgainstComboBase(int loc){
        return Link->Z == 0 && (Link->Dir == DIR_UP && Link->Y == ComboY(loc)+8 && Abs(Link->X-ComboX(loc)) < 8);
    }
}

//!!These functions should only be included in your script file once!!
bool SelectPressInput(int input){
    if(input == 0) return Link->PressA;
    else if(input == 1) return Link->PressB;
    else if(input == 2) return Link->PressL;
    else if(input == 3) return Link->PressR;
}
void SetInput(int input, bool state){
    if(input == 0) Link->InputA = state;
    else if(input == 1) Link->InputB = state;
    else if(input == 2) Link->InputL = state;
    else if(input == 3) Link->InputR = state;
}