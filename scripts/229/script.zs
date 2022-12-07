item script KeyForAnotherLevelMessage{
    void run(int level, int m){
        Screen->Message(m);
        Game->LKeys[level]++;
    }
}