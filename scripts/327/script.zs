//import "std.zh"

//// Probably requires std.zh.


//// For use in sideview screens


//// SETUP ////

//// For best results:
//// Place an FFC with this script attached in your desired location.
//// Set "Tile W" to 2 and "Tile H" to 3, or to match whatever tiles you are using.*
//// *(Code was made using the Zelda 2 tiles)
//// (I also like to check the "Draw Over" flag.)
//// Place any additional FFCs ON THE SAME X-AXIS as before on each screen Link will move to via elevation.
//// Preferably, allow only 2-tile-wide spaces above and/or below elevator (if centered on tile grid).
//// Have fun! (This step is not required)

int sfx = 0;

//// Oh, and you need to set that 0 to the sfx number
//// that the elevator will make whilst moving.

////  ////





bool mup;
bool mdown;
//	UNNEEDED	bool link;	//// This says if the elevator should "link" with the position of Link.

ffc script Elevator
{
	void run()
	{
		while(true)
		{

		
		//// Matches elevator to Link's position
		
		if(Link->X >= this->X -7 && Link->X <= this->X + 16 + 7)
			{
				this->Y = Link->Y - 24;

	//// Behavior can be funky if you play with the elevator in game,
	//// but this will ensure that the elevator can get back to Link

	//// Also, when you enter a new screen using the elevator,
	//// the "next" elevator will zip right to you.
			}
			
			else
			{
				Waitframe();
			}


			//// Is anything solid?
			
			if(Screen->isSolid(this->X + 16, this->Y + 41))
			{
				mdown = false;
			}
			else
			{
				mdown = true;
			}
			
			if(Screen->isSolid(this->X + 16, this->Y + 7))
			{
				mup = false;
			}
			else if(this->Y < -30)
			{
				//// Hey, stop matching Link's and elevator's position!
				
				//link = false;
				Link->Y -= 2;
			}
			else
			{
				//link = true;
				
				
				mup = true;
			}
			
			
			
//// The actual movement part ////


			
		if(Link->X >= this->X - 7 && Link->X + 16 <= this->X + 39 && Link->Y <= this->Y + 32 && Link->Y >= this->Y + 24)
			{
			
			Link->Jump = 0;
			
			
			//// I had Ex1 make Link jump in my quest, so...
			//// If you do something similar, remove the comments
			//// to disable those buttons.
			
		//	Link->PressEx1 = false;
		//	Link->PressEx2 = false;
		//	Link->PressEx3 = false;
		//	Link->PressEx4 = false;
			
			
			
			//// Controls
			
			
			if(mup == true)
				{
				if(Link->InputUp)
				{
					Link->Y -= 2.0;
					this->Y -= 2.0;
					Game->PlaySound(sfx);
					
				}
					Waitframe();
				}
			
				
			if(mdown == true)
				{
				if(Link->InputDown)
				{
					Link->Y += 2.0;
					this->Y += 2.0;
					Game->PlaySound(sfx);
					
				}
					Waitframe();
				}
			
			else
				{
					Waitframe();
				}
			
			}
			
			
			else
			{
				Waitframe();
			}
		}
	}
}