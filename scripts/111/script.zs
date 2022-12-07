ffc script SavegameFFC{
    void run(int sfx){
        Game->PlaySound(sfx);
        Game->Save();
    }
}

ffc script SavegameOnlyOnceFFC{
    void run(int sfx, int d){
        if ( Screen->D[d] == 0 ) {
            Screen->D[d] = 1;
            Game->PlaySound(sfx);
            Game->Save();
        }
    }
}

item script SavegameItem{
    void run(int sfx){
        Game->PlaySound(sfx);
        Game->Save();
    }
}