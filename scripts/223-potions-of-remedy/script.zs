//Potion of Remedy

const int CR_JINXP = 10; //script 4 slot

item script RemedyPotion
{
	void run()
	{
		if (Game->Counter[CR_JINXP]==0)
			{Quit();}
		else
		{
			Link->SwordJinx = 0;
			Game->Counter[CR_JINXP]--;
			Game->PlaySound(53);
			if (Game->Counter[CR_JINXP]==0){Link->Item[143]=false;}
		}
	}
}