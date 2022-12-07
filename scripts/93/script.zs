import "std.zh"

// Screen Sound Freeze
// D0 = SFX to play
// D1 = Length to wait before playing SFX in frames (60 frames ~ 1 second)
// D2 = Length to wait when SFX starts playing until the string happens in frames (ZC doesn't have a way to wait for a SFX to finish playing automatically)
// D3 = String to play (if any)
// Note: This will only work with permanent secrets. If you want temporary secrets, you'd probably have to keep track of secret flags on the screen.
// Note2: This will not freeze FFCs since they kind of need to remain running for the script to work.
ffc script soundFreeze
{
	void run(int sfx, int pause_length, int sfx_length, int string)
	{
		bool firstRun = Screen->State[ST_SECRET]; // Check to see if secrets were set off already to avoid triggering script immediately on a screen entrance.
		while(!firstRun)
		{
			if(Screen->State[ST_SECRET]) // Secrets activated while on the screen.
			{
				int tempComboType = Screen->ComboT[0]; // Store combo type to restore it later.
				// Pause for pause length
				Screen->ComboT[0] = CT_SCREENFREEZE;
				Waitframes(pause_length);			
				// Play Sound
				Game->PlaySound(sfx);
				// Wait for "length" of sfx and then padding
				Waitframes(sfx_length);
				// Unpause
				Screen->ComboT[0] = tempComboType;
				// Play String
				if(string > 0)
					Screen->Message(string);
				// Set script as executed
				firstRun = true;
			}
			Waitframe();
		}//!End while(!firstRun)
	}//!End void run()
}//!End ffc script soundFreeze