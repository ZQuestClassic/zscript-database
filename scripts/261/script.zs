ffc script ButtonDisabler{
    void run(){
        while(true){
            Link->InputStart = false; Link->PressStart = false;
            Link->InputMap = false; Link->PressMap = false;
            NoAction();
            Waitframe();
        }
    }
}