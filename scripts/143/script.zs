// std.zh only needs to be imported once. Remove this line if you have any other scripts that already import it.
import "std.zh"

global script Active
{
	void run()
	{
		while (true)
		{
			LREx1Ex2ItemSwitch();
			
			Waitframe();
		}
	}
}

void LREx1Ex2ItemSwitch()
{
	if (Link->PressL && Link->Action != LA_SCROLLING)
	{
		Link->SelectBWeapon(DIR_LEFT);
	}
	if (Link->PressR && Link->Action != LA_SCROLLING)
	{
		Link->SelectBWeapon(DIR_RIGHT);
	}
	if (Link->PressEx1 && Link->Action != LA_SCROLLING)
	{
		Link->SelectAWeapon(DIR_LEFT);
	}
	if (Link->PressEx2 && Link->Action != LA_SCROLLING)
	{
		Link->SelectAWeapon(DIR_RIGHT);
	}
}