//Constants used by the HotRoom script.
const int I_FIRETUNIC   = 123; //If link has this item in his inventory he will be immune to the effects of hot rooms.
const int CR_SECONDS	= 31;  //A CR_ variable used by Game->Counter[] as a second counter.
const int HOTROOM_FLAG  = 0;   //This is the general use screen flag to use for hot rooms under the misc category. Values 0-4
const int HOTROOM_TIME  = 150; //This is the amount of seconds to allow Link to stay in a hot room for.
const int SOLID_WHITE   = 1;   //Solid white color from the palette.
const int SOLID_BLACK   = 16;  //Solid black color from the palette.

bool hotroominit = false;
int hotroomtimer = 0;

global script slot2_hotroom
{
	void run()
	{
		//Main Loop
		while(true)
		{
			Update_HotRoom();
			Waitframe();
		}
	}
}

void Update_HotRoom()
{
	if(Link->Item[I_FIRETUNIC])
	{
		hotroominit = false;
		return;
	}
	else if((Screen->Flags[SF_MISC] & 4<<HOTROOM_FLAG)!=0)
	{
		if(hotroominit)
		{
			Game->Counter[CR_SECONDS] = (Game->Counter[CR_SECONDS] + 1)%60;
			if(Game->Counter[CR_SECONDS] == 0) hotroomtimer--;
		}
		else hotroomtimer = HOTROOM_TIME;
		hotroominit = true;
		if(hotroomtimer == 0)
		{
			hotroominit = false;
			Link->HP = 0;
			Quit();
		}
	}
	else
	{
		hotroominit = false;
		hotroomtimer = 0;
		return;
	}
	if(hotroominit)
	{
		//Create an array of characters.
		int string[5];
		//Add the minutes to the array.
		itoa(string, 0, Div(hotroomtimer, 60));
		//Add the : after the minutes.
		string[strlen(string)] = ':';
		//Add the seconds after the colon.
		int seconds = hotroomtimer % 60;
		if(seconds < 10) string[strlen(string)] = '0';
		itoa(string, strlen(string), seconds);
		//Draw the timer to the screen.
		Screen->DrawString(7, 0, 0, FONT_DEF, SOLID_WHITE, SOLID_BLACK, TF_NORMAL, string, 128);
	}
}