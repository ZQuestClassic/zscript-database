//A script by "Hoff123" to show a message(string) on the screen
//Includes multiple ways to display a message
//Normal, delay, no return, switch string, toggle switch string, and if you have a certain item or not
 
//D0: The string you want to use. If all you want is to show a simple message, leave the other arguments as is
//    If you're using D6, this will be the string shown if you don't have a certain item
//D1: How long until the message is showed. 60 = 1 second. If you don't want any delay, leave this as is
//D2: If you want the message to be showed only the first time you enter the screen, set this to 1
//    If you're using D6, this will be the string shown if you do have a certain item
//D3: If you want to switch to another string when you enter the screen a second time
//    It will then show the second string every time you visit that screen, unless...
//D4: If you want to toggle between the first and second string every time you enter the screen, set this to 1
//D5: The Screen->D[] variable you want to use for either D2 or D3/D4
//    If you have no idea what that means, just leave it as is
//D6: If you want to show a string depending on if you have an item or not, set this to the ID of the item
//    This one doesn't require any Screen->D variable(s) and just checks if you actually have an item or not in your inventory
 
//Note that for obvious reasons you can't use both D2 and D3/D4 in the same screen
//But you can mix them with delay. E.g "delay + no return" and "delay + switch string" 
//But note that there will always be a delay when you enter the screen if you use it

//D6 uses string and string2 to show a message depending on if you have an item or not
//and can't be mixed with any of the other ways, except for delay which works with everything

//You are meant to use one instance(one FFC) of this script per screen
//If you try to use multiple instances(multiple FFC's) on the same screen
//it will most likely cause some troubles
 
ffc script Hoffs_Message_Script
{
    void run(int string, int delay, int no_return, int string2, int toggle, int screen_var, int item_id)
    {
	//This variable is used to check if you have entered the screen before
	int screen_check = 1;
		
	//If you have chosen to use a delay(more then 0)
	if (delay > 0)
	{
            //Wait for "delay" amount of frames. 60 frames = 1 second
	    Waitframes(delay);
	}
		
	//If you want to show a string depending on if you have a certain item or not
	if ((item_id > 0))
	{
	    //If you do not have a certain item
	    if (!Link->Item[item_id])
	    {
		//Show the first string on the screen
		Screen->Message(string);
	    }
		
	    //If you do have that item
	    else if(Link->Item[item_id])
	    {
		//Show the second string on the screen
		Screen->Message(string2);
	    }
	}
		
	else
	{
	    //This runs the first time you enter the screen
	    if (Screen->D[screen_var] != screen_check)
	    {
		//Show the first string on the screen
		Screen->Message(string);
			
		//If you have chosen to use a second string
		if (string2 > 0)
		{
		    //Set Screen->D[screen_var] to be equal to screen_check(1)
		    Screen->D[screen_var] = screen_check;
		}   
	    }
	    
	    //This runs if you have chosen to use a second string,
	    //and you have already visited the screen once before
	    else
	    {
		//Show the second string on the screen
		Screen->Message(string2);
			
		//If you want to toggle between string1 and string2 every time you enter the screen
		if (toggle > 0)
		{
		    //Now Zelda Classic will think that you have never visited the screen before :)
		    //(Seriously, this just changes the Screen->D[screen_var] variable to the default value)
		    Screen->D[screen_var] = 0;
		}
	    }
		
	    //This only runs if you have set D2(no_return) to 1 or more
	    if (no_return > 0)
	    {
		//Set Screen->D[screen_var] to be equal to screen_check(1)
		Screen->D[screen_var] = screen_check;
	    }
	}
    }
}