//D0 = Room index number of core enemy.
//D1 = Left of the decimal: Enemy ID of orbiter. Right of the decimal: Number of orbiters. 40.0016 would cause 16 Keese to orbit, for example. More than 100 orbiters will break things.
//D2 = Rotation speed of orbiters.
//D3 = Distance between enemy and orbiters, in pixels.
//D4 = Expansion interval, in frames. 60 frames is equal to 1 second. The orbiters will fly out to 2.5 times their original radius three times. Use 0 for no expansion.
//D5 = Number to the left of the decimal is 2 if orbiters block weapons, 1 if they ignore them, 0 if they keep their old resistances.
//Number to the right of the decimal is 0001 if all orbiters die along with core enemy, 0000 if they're set free instead.
//D6 = The X offset of the orbiters' center of rotation. 0 is recommended for 16x16 (one tile) enemies, and 8 for 32x32 (2x2 tile) big enemies.
//D7 = The Y offset of the orbiters' center of rotation. 0 is recommended for 16x16 (one tile) enemies, and 8 for 32x32 (2x2 tile) big enemies.

ffc script ReversePatra
{
	void run(int bigenemy_index_num, float orbiter_ID_and_orbiter_num, int rotation_speed, float orbit_radius, int expand_interval, int block_and_death, int x_offset, int y_offset)
	{
		npc bat[100];
		int DefenseStore[18];
		int timerExpand = 0;
		int repeats = 0;
		int orbiter_ID = Floor(orbiter_ID_and_orbiter_num);
		int orbiter_num = (orbiter_ID_and_orbiter_num - Floor(orbiter_ID_and_orbiter_num)) * 10000;
		int block = Floor(block_and_death);
		int orbiter_death = (block_and_death - Floor(block_and_death)) * 10000;
		float angle = 0;
		float orbit_radius_current = orbit_radius;
		bool expand = false;
		
		Waitframes(4);
		
		npc bigbat = Screen->LoadNPC(bigenemy_index_num);
		
		if (!bigbat->isValid())
		{
			Quit();
		}
		
		//Sanity check to avoid lagging the game and destroying allegro.log.
		if (orbiter_num > 100)
		{
			orbiter_num = 100;
		}
		
		for (int i = 0; i < orbiter_num ; i++)
		{
			bat[i] = Screen->CreateNPC(orbiter_ID);
		}
		
		//Stores orbiter natural defense to DefenseStore[], then sets them all to block or ignore weapons, depending on FFC argument D5.
		//Leaves them as is if D5 is 0.
		if (block != 0)
		{
			for (int i = 0; i < orbiter_num; i++)
			{
				for (int j = 0; j <= 17; j++)
				{
					DefenseStore[j] = bat[i]->Defense[j];
					if (block == 2)
					{
						bat[i]->Defense[j] = NPCDT_BLOCK;
					}
					else
					{
						bat[i]->Defense[j] = NPCDT_IGNORE;
					}
				}
			}
		}
		
		while (bigbat->HP >= 0)
		{
			for (int i = 0; i <= (orbiter_num - 1); i++)
			{
				bat[i]->X = bigbat->X + x_offset + (orbit_radius_current * Cos(angle + (i * (360 / orbiter_num))));
				bat[i]->Y = bigbat->Y + y_offset + (orbit_radius_current * Sin(angle + (i * (360 / orbiter_num))));
			}
			
			angle += rotation_speed;
			
			// Expands the orbiters three times, at 2.5 times their original radius at intervals of D7, expand_interval. Setting D7 to 0 skips this process entirely.
			if (expand_interval != 0)
			{
				if (!expand && repeats == 0 && orbit_radius_current <= orbit_radius)
				{
					timerExpand++;
				}
				if (timerExpand >= expand_interval)
				{
					timerExpand = 0;
					expand = true;
					repeats = 3; // This line determines how many times the orbiters expand in a row.
				}
				if (expand && orbit_radius_current < (orbit_radius * 2.5))
				{
					orbit_radius_current += (orbit_radius * 0.025);
				}
				if (expand && orbit_radius_current >= (orbit_radius * 2.5))
				{
					expand = false;
					repeats--;
				}
				if (!expand && orbit_radius_current > orbit_radius)
				{
					orbit_radius_current -= (orbit_radius * 0.025);
				}
				if (!expand && orbit_radius_current <= orbit_radius && repeats > 0)
				{
					expand = true;
				}
			}
			
			Waitframe();
		}
		
		//Sets orbiter defenses back to what they were.
		if (block != 0)
		{
			for (int i = 0; i < orbiter_num; i++)
			{
				for (int j = 0; j <= 17; j++)
				{
					bat[i]->Defense[j] = DefenseStore[j];
				}
			}
		}
		
		//Kills orbiters after core enemy death if FFC argument D6 (orbiter_death) is equal to 1.
		if (orbiter_death == 1)
		{
			for (int i = 0; i <= (orbiter_num - 1); i++)
			{
				bat[i]->HP = 0;
			}
		}
		
		//Kills orbiters if they're out of bounds when core enemy dies.
		for (int i = 0; i <= (orbiter_num - 1); i++)
		{
			if (bat[i]->X > 236 || bat[i]->X < 16 || bat[i]->Y > 156 || bat[i]->Y < 16)
			{
				bat[i]->HP = 0;
			}
		}
	}
}