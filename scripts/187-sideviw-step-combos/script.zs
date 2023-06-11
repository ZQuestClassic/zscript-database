//import std.zh
const int SFX_STEPCOMBO = 0;

global script slot2_sideviewstepcombos
{
	void run()
	{
		while(true)
		{
			Waitdraw();
			if(IsSideview())
				SideviewStep();
			Waitframe();
		}
	}
}

void SideviewStep() //Triggers Solid Step Next Combos in sideview
{
	if(Link->Action==LA_SCROLLING)
		return;
	int tx=CenterLinkX();
	int ty=CenterLinkY();
	if(!OnSidePlatform(tx, ty, -8, -8, 16))
		return;	//needs to be on the ground;
	else
		ty+=16;
	int combo=ComboAt(tx,ty);
	if(Screen->ComboT[combo]==CT_STEP || Screen->ComboT[combo]==CT_STEPALL || Screen->ComboT[combo]==CT_STEPSAME)
	{
		if(SFX_STEPCOMBO)
			Game->PlaySound(SFX_STEPCOMBO);
		if(Screen->ComboT[combo]==CT_STEPALL)
		{
			for(int i=0; i < 176; i++)
			{
				if(Screen->ComboT[i]==CT_STEP||Screen->ComboT[i]==CT_STEPALL||Screen->ComboT[i]==CT_STEPCOPY)
					Screen->ComboD[i]++;
			}
			return;
		}
		else if(Screen->ComboT[combo]==CT_STEPSAME)
		{
			for(int i=0; i < 176; i++)
			{
				if(i==combo)
					continue;
				if(Screen->ComboD[i]==Screen->ComboD[combo])
					Screen->ComboD[i]++;
			}
			Screen->ComboD[combo]++;
		}
		else
			Screen->ComboD[combo]++;
	}
}