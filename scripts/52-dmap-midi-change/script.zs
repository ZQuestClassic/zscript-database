// This script will change the DMap midi of a dmap.
// This is probably temporary and won't carry between game sessions.
// This doesn't work with the built-in Zelda 1 midis (sort of) due to laziness...
// d0 = The dmap midi to change. If less than 0 (-1 for example), it will pick the current dmap.
// d1 = The midi to change the dmap midi to. If less than 0 (-1 for example), it will pick the currently playing midi.
// d2 = Should the currently playing midi be changed? 0 = No. 1 = Yes.

ffc script dmapMIDIChange
{
	void run(int dmap, int midi, bool changePlaying)
	{
		Waitframe(); // Delay detection...
		while(true)
		{
			// Wait for screen to scroll in...
			while(Link->Action == LA_SCROLLING)
				Waitframe();
			
			// Set up the automatic stuff...
			if(this->InitD[1] < 0)
				midi = Game->GetMIDI();
			if(this->InitD[0] < 0)
				dmap = Game->GetCurDMap();
			
			if(Game->DMapMIDI[dmap] != midi)
				Game->DMapMIDI[dmap] = midi; // Set the midi for the dmap
				
			if(changePlaying && Game->GetMIDI() != midi)
				Game->PlayMIDI(midi); // Change currently playing midi
			
			Waitframe();
		}//!End while(true)
	}//!End void run()
}//!End dmapMIDIChange