const int SFX_ENEMY_KILL_ORDER_ERROR = 32;//Sound to play, when player kills wrong enemy.

//Enemies in that screen must be killed in specific order to trigger secrets.
//
//Place invisible FFC anywhere in the screen.
//Set "Enemies always return" screen flag. No flag-spawned enemies, like Zoras, shooters, and, such. Only enemies in list are supported.
// D0 to D4 - Enemy order password. Read enemy positions in ZQuest editor, staering from top. 
//  D0 #####.____ - #1, ____.#### - #2
//  D1 #####.____ - #3, ____.#### - #4 etc.

ffc script EnemyOrderPassword{
	void run(int order1, int order2, int order3, int order4, int order5){
		Waitframes(4);
		int s[5]={order1, order2, order3, order4, order5};
		int sol[10];
		for (int i=0;i<5;i++){
			int j=2*i;
			sol[j]=GetHighFloat(s[i]);
			sol[j+1]=GetLowFloat(s[i]);
		}
		npc en[10];
		for (int i=0;i<10;i++){
			if (i<Screen->NumNPCs()) en[i]=Screen->LoadNPC(i+1);
		}
		int list[10];
		for (int i=0;i<10;i++){
			if (en[i]->isValid()) list[i]=en[i]->ID;
			else list[i]=-1;
		}
		int pos=0;
		while(true){
			for (int i=0;i<10;i++){
				if (list[i]<0)continue;
				if (en[i]->isValid()) continue;
				if (i+1!=sol[pos]){
					Game->PlaySound(SFX_ENEMY_KILL_ORDER_ERROR);
					Quit();
				}
				else{
					pos++;
					list[i]=-1;
					if (sol[pos]<=0){
						Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
						Quit();
					}
				}
			}
			Waitframe();
		}
	}	
}