import "std.zh"

const int SCREEN_W = 320;
const int SCREEN_H = 240;

const int Link_WaterMaxCounter = 180;
int Link_WaterCounter = 180;

void ResetLinkWaterCounter()
{
	Link_WaterCounter = Link_WaterMaxCounter;
}
global script ActiveScript
{
	void run()
	{
		int last_ground_x = Link->X;
		int last_ground_y = Link->Y;
		int last_ground_screen = Game->GetCurDMapScreen();
		int last_ground_dmap = Game->GetCurDMap();
		int last_action = Link->Action;
		while(true)
		{
			if(last_action == LA_DROWNING && Link->Action != LA_DROWNING)
			{
				Link->X = last_ground_x;
				Link->Y = last_ground_y;
				Link->PitWarp(last_ground_dmap,last_ground_screen);
			}
				
			if(Link->Action == LA_SWIMMING)
			{
				Link_WaterCounter--;
				Screen->Circle(6, 8, 8, 8, 7,1, 0, 0, 0, true, 128);
				Screen->Arc(6,8,8,8,0,Link_WaterCounter * 360 / Link_WaterMaxCounter,6,1,8,8,Link_WaterCounter*2,false,false,128);
				Screen->Arc(6,8,8,6,0,Link_WaterCounter * 360 / Link_WaterMaxCounter,6,1,8,8,-Link_WaterCounter/2,false,false,128);
				Screen->Arc(6,8,8,4,0,Link_WaterCounter * 360 / Link_WaterMaxCounter,6,1,8,8,-Link_WaterCounter,true,true,128);
				Screen->DrawInteger(6,8,6,FONT_Z3SMALL,1,-1,0,0,Link_WaterCounter / 60,0,128);
				if(Link_WaterCounter < 0)
				{
					ResetLinkWaterCounter();
					Link->Action = LA_DROWNING;
				}
			}
			if(last_action != LA_DROWNING && !IsWater(ComboAt(Link->X,Link->Y)) && Link->Action != LA_SWIMMING)
			{
				Link_WaterCounter = Link_WaterMaxCounter;
				last_ground_x = Link->X;
				last_ground_y = Link->Y;

				last_ground_screen = Game->GetCurDMapScreen();
				last_ground_dmap = Game->GetCurDMap();
			}
			last_action = Link->Action;
			Waitframe();
		}
	}
}