ffc script showBossHealth{
	void run(){
		npc boss;
		int theboss = 0;
		int highest = 0;
		int numNPCs = 0;
		int red = 108;	   //value can be modified depending on tileset palette
		int white = 17;	 //value can be modified depending on tileset palette
		int xoffset = 3;	 //initial x offset for top left rectangle
		int yoffset = 20;   //initial y offset for top left rectangle

		while(Link->Action == LA_SCROLLING){
			Waitframe();
		}
		Waitframe();		//necessary to let ZC load everything on the screen before checking for a boss
		Waitframe();

		numNPCs = Screen->NumNPCs();

//check all NPCs on the screen and define the boss as the one with the most HP
		if(numNPCs > 0){
			for(int i = 1; i<=numNPCs; i++){
				boss = Screen->LoadNPC(i);
				if(boss->isValid() && boss->HP > highest){
					highest = boss->HP;
					theboss = i;
				}
			}
		}

		boss = Screen->LoadNPC(theboss);
		
//display boss health meter whilst the boss is alive
		while(boss->isValid()){
			float bossHealth = (boss->HP/highest) * 8;
			int shaded = Ceiling(bossHealth);
			int colour;

			for(int i=0; i<8; i++){
				if(8-i > shaded) colour = white;
				else colour = red;

				Screen->Rectangle(0, xoffset, yoffset+8*i, xoffset+8, yoffset+8*i+5, colour, 1, 0, 0, 0, true, 128);
			
			}			
			Waitframe();
		}
	}
}