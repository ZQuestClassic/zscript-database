//Change titledmap to your title screen's dmap and titledscreen to your title screen's screen
const int titledmap=0;
const int titledscreen=0;

//Variables used to set your continue point
int continuescreen;
int continuedmap=titledmap;
int continuex;
int continuey;
int previousdmap;
bool dontsetcontinue;
bool setcontinue;


global script Slot_2
{
   void run()
  {
   while(true){
  //Following 2 lines disables the default continue function and sets it to the title screen
  Game->LastEntranceDMap=titledmap;
  Game->LastEntranceScreen=titledscreen;

	 //Here the magic begins. It checks if you've went to a new Dmap after entering a door, if you did it sets your continue point. You can also use setcontinue to trigger this event.
	   if ((previousdmap!=Game->GetCurDMap() && Game->GetCurDMap()!=titledmap) || setcontinue==1)
	  {
		previousdmap=Game->GetCurDMap();
		continuescreen=Game->GetCurDMapScreen();
		continuedmap=Game->GetCurDMap();
		continuex=Link->X;
		continuey=Link->Y;
		setcontinue=false;
	  }
		Waitframe();
	}
  }
}

global script Slot_3
{
   void run()
  {
  //Disables the default continue function and sets it to the title screen. This one is to make sure if you quit your game during an opening wipe, it doesn't use the default continue spot.
  Game->LastEntranceDMap=titledmap;
  Game->LastEntranceScreen=titledscreen;
  }
}

  //Place one of these on your title screen screen.
ffc script titlescreen_warp
{
  void run()
  {
	Waitframes(5);
	while(true)
	{
	  if (Link->InputStart == true)
	  {
		//If you start a new game, your continue isn't set, so you use the bottom side warp to warp to the game's first screen.
		if (continuedmap==titledmap)
		{
		  Link->Y=200;
		}
	else
		//If you have a set continue point, you'll be warped to the continue point set to the variables of the script.
		{
		  Waitframes(30);
		  Link->X=continuex;
		  Link->Y=continuey;
		  Link->PitWarp(continuedmap,continuescreen);
		}
	  }
	//This disables Link from using items or buttons on the title screen
	Link->InputA = false;
	Link->InputB = false;
	Link->InputLeft = false;
	Link->InputRight = false;
	Link->InputUp = false;
	Link->InputDown = false;
	Waitframe();
	}
  }
}

//Use this script if you want to disable the doorway continue point function. Place it on the place Link will warp to to disable it.
ffc script nocontinue
{
  void run()
  {
	while(true)
	{
	  if (LinkCollision(this))
	  {
		previousdmap=Game->GetCurDMap();
		dontsetcontinue=true;
	  }
	  Waitframe();
	}
  }
}

//Demonstration of how to use setcontinue to set your continue in a script.
item script setcontinue
{
  void run()
  {
  //Use this next line to set your continue point
  setcontinue=true;
  Game->PlaySound(25);
  }
}