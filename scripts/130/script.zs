import "std.zh"

const int CR_CONFUSION = 7; //The counter to use for confusion. CR_SCRIPT# values are 7-31.

global script Init
{
	void run()
	{
		Game->MCounter[CR_CONFUSION]=65535; //Max
	}
}


global script slot2_Confusion
{
	void run()
	{
		while(true)
		{
			//Waitdraw();
			UpdateConfusion();
			Waitframe();
		}
	}
}

void UpdateConfusion()
{
	if(Link->Drunk > 0)
	{
		Game->Counter[CR_CONFUSION]=Link->Drunk;
		Link->Drunk=0;
	}
	if(Game->Counter[CR_CONFUSION]>0)
	{
		Game->Counter[CR_CONFUSION]--;
		if(Link->InputUp != Link->InputDown)
		{
			Link->InputUp = !Link->InputUp;
			Link->InputDown = !Link->InputDown;
		}
		if(Link->InputLeft != Link->InputRight)
		{
			Link->InputLeft = !Link->InputLeft;
			Link->InputRight = !Link->InputRight;
		}
	}
}


item script RemoveConfusion
{
	void run()
	{
		Game->Counter[CR_CONFUSION]=NULL;
	}
}