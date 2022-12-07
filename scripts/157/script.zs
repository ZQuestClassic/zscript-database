ffc script customGuy
{
	void run(int tileNum, int tileCSet)
	{
        	  Waitframes(4);
                  npc n = Screen->LoadNPC(3);
	          n->OriginalTile = tileNum;
		  n->CSet = tileCSet;
	}
}