//Enemies spawn in waves. When all waves are spawned and all ebenies are killed, secrets pop open.
//ghost.zh required.

//Place invisible FFC anywhere in the screen.
//D0 - D7 - defines enemy waves. Each argument defines enemy wave in following scheme:
//#####.____ - delay between previous wave and this one, in frames. -1 - wait until all beatable enemies are gone.
//_____.###_ - ID of enemy to spawn.
//_____.___# - number of enemies to spawn, 1-9.

ffc script SequentialEnemySpawn{
	void run (int wave1, int wave2, int wave3, int wave4, int wave5, int wave6, int wave7, int wave8){
		if (Screen->State[ST_SECRET])Quit();
		Waitframes(5);
		int waves[8] = {wave1, wave2, wave3, wave4, wave5,wave6,wave7,wave8};
		int time[8];
		int enID[8];
		int ennum[8];
		for (int i=0; i<8; i++){
			time[i]=GetHighFloat(waves[i]);
			ennum[i]=Abs(GetPartialValue(waves[i], -4, 1));
			enID[i]=Abs(GetPartialValue(waves[i], -1, 3));
		}
		for (int i=0; i<8; i++){
			if (time[i]<0){
				Waitframes(5);
				while(EnemiesAlive())Waitframe();
			}
			else Waitframes(time[i]);
			if (time[i]!=0)Game->PlaySound(SFX_SUMMON);
			for (int n=1; n<=ennum[i];n++){
				npc en = SpawnNPC(enID[i]);
			}
		}
		while(EnemiesAlive())Waitframe();
		Game->PlaySound(SFX_SECRET);
		Screen->TriggerSecrets();
		Screen->State[ST_SECRET]=true;
	}
}