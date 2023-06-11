////////////////////////////
///Dungeon Outside/Inside///
////////////////////////////
  


ffc script DungeonOutside{
    void run(int misc){
        Link->Misc[misc] = Game->GetCurDMap();
    }
}

ffc script StringDungeon{
    void run(int m, int delay, int misc){
        if (Link->Misc[misc] != Game->GetCurDMap()){
            Waitframes(delay);
            Screen->Message(m);
        }
    }
}


 


  
////////////////////
///Second Version///    ///StringDungeon is Now StringOnce///
////////////////////     ///This One plays whenever you enter the dungeon///



ffc script DungeonOutside{
    void run(int misc){
        Link->Misc[misc] = Game->GetCurDMap();
    }
}

ffc script StringOnce{
    void run(int m, int delay, int misc){
        if (Link->Misc[misc] != Game->GetCurDMap()){
            Link->Misc[misc] = Game->GetCurDMap();
            Waitframes(delay);
            Screen->Message(m);
        }
    }
}