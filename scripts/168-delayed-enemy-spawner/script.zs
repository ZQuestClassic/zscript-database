ffc script DelayedEnemySpawn{
	void run(int EnemyID, int SpawnDelay, int Limiter){
		int NumSpawns = 0;
		int OrigDelay = SpawnDelay;
			while(true){
				if (NumSpawns == Limiter && Limiter != 0) {
					Quit();
					}
				if (SpawnDelay <= 1) {
					SpawnDelay = OrigDelay;
					Game->PlaySound(SFX_SUMMON);
					NumSpawns++;
					createEnemy(EnemyID);
				}
				else {
					SpawnDelay--;
					}
			Waitframe();
			}
		}


// Only add the following code if you don't already have TheRandomHeader.zh imported.

void createEnemy(int enemyNum)
{
	while(true)
	{
		int x = Rand(12) * 16 + 32;
		int y = Rand(7) * 16 + 32;
		
		bool ifLocationOkay = true;
		
		if(Distance(x, y, Link->X, Link->Y) < 16)
			ifLocationOkay = false;
			
			if(Screen->isSolid(x, y))
				ifLocationOkay = false;
				
			if(Screen->isSolid(x+15, y))
				ifLocationOkay = false;
				
			if(Screen->isSolid(x, y+15))
				ifLocationOkay = false;
				
			if(Screen->isSolid(x+15, y+15))
				ifLocationOkay = false;
				
			if(Screen->isSolid(x+8, y+8))
				ifLocationOkay = false;
		
		int comboNum = ComboAt(x, y);
		int comboType = Screen->ComboT[comboNum];
		
		if(comboType == CT_WATER || comboType == CT_NOENEMY || comboType == CT_NOFLYZONE || comboType == CT_NOJUMPZONE)
			ifLocationOkay = false;
			
		if(Screen->ComboF[comboNum] == CF_NOENEMY)
			ifLocationOkay = false;
			
		if(ifLocationOkay)
		{
			CreateNPCAt(enemyNum, x, y);
			break;
		}
	}
}
}