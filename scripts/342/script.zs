ffc script PlayEnhancedMusic{
	void run(int dmap, int boss){
		if ( boss == 1 ) {
			Waitframes(4);
			if ( !ScreenEnemiesAlive() )
				Quit();
		}
		
		int dmapmusic[256];
		Game->GetDMapMusicFilename(dmap, dmapmusic);
		Game->PlayEnhancedMusic(dmapmusic, Game->GetDMapMusicTrack(dmap));
		
		if ( boss != 1 )
			Quit();
		
		while(ScreenEnemiesAlive()){
			Waitframe();
		}
		int areamusic[256];
		Game->GetDMapMusicFilename(Game->GetCurDMap(), areamusic);
		Game->PlayEnhancedMusic(areamusic, Game->GetDMapMusicTrack(Game->GetCurDMap()));
	}
	bool ScreenEnemiesAlive(){
		for(int i=Screen->NumNPCs(); i>=1; i--){
			npc n = Screen->LoadNPC(i);
			if(n->Type!=NPCT_PROJECTILE&&n->Type!=NPCT_FAIRY&&n->Type!=NPCT_TRAP&&n->Type!=NPCT_GUY){
				if(!(n->MiscFlags&(1<<3)))
					return true;
			}
		}
		return false;
	}
}