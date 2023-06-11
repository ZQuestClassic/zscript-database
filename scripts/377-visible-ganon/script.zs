ffc script VisibleGanon{
	void run(){
		//Wait 4 frames to give the enemy time to spawn
		Waitframes(4);
		npc Ganon = LoadNPCOf(NPC_GANON);
		int lastHP;
		int lastX;
		int lastY;
		bool wasStunned;
		if(Ganon->isValid()){
			lastHP = Ganon->HP;
			lastX = Ganon->X;
			lastY = Ganon->Y;
			while(Ganon->isValid()){
				//When Ganon's HP rises, he is stunned
				if(!wasStunned){
					if(Ganon->HP>lastHP){
						wasStunned = true;
					}
				}
				//When he moves while stunned, the stun period has ended
				else{
					if(Ganon->X!=lastX||Ganon->Y!=lastY){
						wasStunned = false;
					}
				}
	
				lastHP = Ganon->HP;
				lastX = Ganon->X;
				lastY = Ganon->Y;
				
				//Redraw Ganon to the screen when he's invisible and not stunned (Red palette)
				if(Ganon->HP>0&&!wasStunned)
					Screen->DrawTile(2, Ganon->X+Ganon->DrawXOffset, Ganon->Y+Ganon->DrawYOffset, Ganon->Tile, 2, 2, 14, -1, -1, 0, 0, 0, 0, true, 128);
				
				Waitframe();
			}
		}
	}
}