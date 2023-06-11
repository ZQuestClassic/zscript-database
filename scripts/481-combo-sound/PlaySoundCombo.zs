//A simple combodata script that plays a specified sound after a specified time.
//D0 - Sound to be played
//D1 - Delay before sound is played.
combodata script PlaySound
{
	void run(int sound, int delay)
	{
		if(delay > 0)
			Waitframes(delay);
		if(sound > 0)
			Audio->PlaySound(sound);
	}
}