const int QUAKE_TIME = 180;

npc script QuakeMaster
{
	void run(int wait, int sfx1, int wait2)
	{
		while(true){
			Waitframes(wait);
			Screen->Quake = QUAKE_TIME;
			Game->PlaySound(sfx1);
       			Link->SwordJinx = QUAKE_TIME;
        		Link->ItemJinx = QUAKE_TIME;
			Waitframes(wait2);
		}
	}
}