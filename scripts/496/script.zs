const int C_BOSS_OUTRO_FLASH = 1;//Color of full-screen flash.

//Boss outro effects. Spice up boss death animation.
//Place anyehere in the screen
//D0 - boss enemy slot (1 - 10)
//D1 - quake strangth and duration
//D2 - screen flash duration, in frames
//D3 - string to display on boss death
//D4 - sprite to display at the center of dead boss
//D5 - sprite width (in tiles, 0->1)
//D6 - sprite height (in tiles, 0->1)

ffc script BossOutroEffects{
	void run(int slot, int quake, int flash, int str, int sprite, int tilew, int tileh){
		if (tilew==0)tilew=1;
		if (tileh==0)tileh=1;
		int lvl = Game->GetCurLevel();
		if ((Screen->EFlags[1]&8)>0 && (Game->LItems[lvl]&8)>0)Quit();//Quit, if "Dungeon Boss" Dmap flag was set.
		Waitframes(4);
		npc boss = Screen->LoadNPC(slot);
		while(boss->HP >0) Waitframe();
		if (str>0)Screen->Message(str);
		if (quake>0)Screen->Quake=quake;
		if (sprite>0){
			lweapon s = CreateLWeaponAt(LW_SPARKLE, CenterX(boss)-8*tilew, CenterY(boss)-8*tileh);
			s->UseSprite(sprite);
			s->CollDetection=false;
			if (tilew>1 || tileh>1){
				s->Extend=3;
				s->TileWidth=tilew;
				s->TileHeight=tileh;
			}
		}
		if (flash>0){
			for (int i=1; i<=flash;i++){
				if(i % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172,  C_BOSS_OUTRO_FLASH, 1, 0, 0, 0, true, OP_TRANS);
				Waitframe();
			}
		}
	}
}