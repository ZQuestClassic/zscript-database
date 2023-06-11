ffc script ReSpawner{
    void run(int ID, int Itemchanger, int altID, bool continuous){
        npc n;
        bool SpawnAlive;
        if (!n->isValid())SpawnAlive = false;
        while(true){
            if (!SpawnAlive){
                if(Itemchanger !=0 && altID != 0 && Link->Item[Itemchanger]) ID = altID;
                if(!continuous){
                    if(Link->HP < Link->MaxHP|| Link->MP < Link->MaxMP){
                        if(NumNPCsOf(ID)== 0)CreateNPCAt(ID, this->X, this->Y);
                    }
                }
                else{
                    if(NumNPCsOf(ID)== 0)CreateNPCAt(ID, this->X, this->Y);
                }
            }
            
            Waitframe();
        }
    }
}