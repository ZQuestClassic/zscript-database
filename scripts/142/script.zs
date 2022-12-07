// Remove this import line if another script you're using already imports std.zh.
import "std.zh"

ffc script FireReduce
{
	void run(int duration)
	{
		while (true)
		{
			for (int i = 1; i <= Screen->NumEWeapons(); i++)
			{
				eweapon ewpn = Screen->LoadEWeapon(i);
				if (ewpn->ID == EW_FIRETRAIL)
				{
					if (ewpn->Misc[0] == 0)
					{
						ewpn->Misc[0] = duration;
					}
					if (ewpn->Misc[0] != 0)
					{
						ewpn->Misc[0]--;
						if (ewpn->Misc[0] <= 0)
						{
							ewpn->DeadState = WDS_DEAD;
						}
					}
				}
			}
			
			Waitframe();
		}
	}
}