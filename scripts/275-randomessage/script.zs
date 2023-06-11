ffc script RandoMessage{
	void run(int m1, int m2, int m3, int m4, int m5, int m6, int m7, int delay){
		int str[7]={m1, m2, m3, m4, m5, m6, m7}; //Array to hold the string IDs.
		int choice; //A variable that holds the string selection. 
		int count;
		int msg[7];
		//Determine what indices hold a valid string and populate the second array with them.
		for ( int q = 0; q < 8; q++ ) {
			if ( str[q] > 0 ) {
				msg[count] = str[q];
				count++;
			}
		}
		if ( msg[0] == 0 ) { this->Data = 0; Quit(); } //Exit if there are no valid messages. 
		choice = Rand(0,count);
		//Choose the string to display. 
		
		delay = delay << 0; //Ensure that delay is an integer. 
		if ( delay == 0 ) 
		{ 
			delay = 5; //It takes 5 frames to spawn a guy, so that is the default.
		} 
		if ( delay < 0 ) //If delay is set to -1, we skip this. 
		{
			while(delay--)  { Waitframe(); } //Wait for the guy to spawn.
		}
		Screen->Message(msg[choice]); //Display the string.
		this->Data = 0; Quit(); //Clean ffc and exit. 
	}
}