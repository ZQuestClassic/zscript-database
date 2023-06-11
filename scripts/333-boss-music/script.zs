ffc script BossMusic{
	void run(int bossMusic){
		int defaultMusic = Game->GetMIDI();
		Waitframes(4);
		if (Screen->NumNPCs() < 1) Quit();
		Game->PlayMIDI(bossMusic);
		while (Screen->NumNPCs() > 0) {
			if (Screen->NumNPCs() == 1) {
				npc firstEnemy = Screen->LoadNPC(1);
				if (firstEnemy->ID == NPC_ITEMFAIRY) break;
			}
			Waitframe();
		}
		Game->PlayMIDI(defaultMusic);
	}
}