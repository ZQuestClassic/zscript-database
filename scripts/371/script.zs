item script ActiveRings
{
	void run(int item1, int sfx1, int wait, int sfx2, int restore)
	{
		if(item1 > 0){
			Link->Item[item1] = true;
			Game->PlaySound(sfx1);
			Waitframes(wait);
			Link->Item[item1] = false;
			Game->PlaySound(sfx2);
			Waitframes(restore);
		}
	}
}