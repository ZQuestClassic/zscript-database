//Used to make enemies teleport in one at a time.
ffc script MonsterSpawner
{
    void run(int enemyID, int max, int frequency, int flags, bool continuous)
    {
        if(enemyID==0 || max==0 || frequency==0)
            Quit();
        Waitframes(4);
        while(true)
        {
            if(NumNPCsOf(enemyID)<max)
            {
                npc n = Screen->CreateNPC(enemyID);
                int spawnpoint = FindSpawnPoint(flags&1b, flags&10b, flags&100b, flags&1000b);
                n->X = ComboX(spawnpoint);
                n->Y = ComboY(spawnpoint);
            }
            else if(!continuous)
            {
                break;
            }
            Waitframes(frequency);
        }
        npc n = LoadNPCOfType(NPC_TRIGGER);
        if(n->isValid()) n->HP = -1000;
    }
}