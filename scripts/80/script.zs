// This will check for the specified combo.
// If found, it will play a message.
// If the combo disappears, the check for the combo will reset.
// This only works on layer 0.
// d0 = String
// d1 = Number of the combo to check for
ffc script comboString
{
	void run(int string, int combo)
	{
		bool hasAppeared = false;
		// Enter the main loop
		while(true)
		{
			// If the combo has not appeared, loop through this while loop...
			while(!hasAppeared)
			{
				// Check if there is an instance of the combo on the screen...
				if(FirstComboOf(combo, 0) != -1)
				{
					hasAppeared = true;
					Screen->Message(string); // Play the message.
				}
				Waitframe();
			}
			// If the combo has appeared, loop through this while loop...
			while(hasAppeared)
			{
				// Check if the combo is not still on the screen...
				if(FirstComboOf(combo, 0) == -1)
				{
					hasAppeared = false;
				}
				Waitframe();
			}
			Waitframe();
		}//!End while(true)
	}//!End void run()
}//!End ffc script comboString