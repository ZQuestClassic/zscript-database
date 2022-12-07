// This mimics a GB Locked Dungeon, which only opens when the player has a special item
// d0 = The combo of the lock block
// d1 = The item required to open the lock block
// d2 = The message that is displayed if you do not have the lock block
// d3 = The sound effect played when opening the lock block
// d4 = Set to 1 if you want the item to be removed from Link's inventory
ffc script LockedDungeonEntrance
{
	void run(int dgnlock, int key, int msg, int sfx, int removeItem)
	{
		// This this ffc to ethereal to make sure that the cave/stairs still work
		this->Flags[FFCF_ETHEREAL] = true;
		
		int loc = ComboAt(this->X+8, this->Y+8);
		int numKeys = -1;

		// If lockblocks haven't been activated yet
		if(!Screen->State[ST_LOCKBLOCK])
		{
			// This basically monitors to make sure the user pushes against the lock block a few moments before unlocking it
			int pressDelay = 0;

			while(true)
			{

				// If Link is pushing up against the lock block
				if(ComboAt(Link->X+8, Link->Y+7) == loc && Screen->ComboD[loc] == dgnlock && Link->InputUp)
				{
					pressDelay++;

					// If they have waited enough time
					if(pressDelay >= 5)
					{
						// If they have a key, unlock it
						if(Link->Item[key])
						{
							Screen->State[ST_LOCKBLOCK] = true;
							Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]+1);

							if(sfx == 0)
								Game->PlaySound(SFX_SHUTTER);
							else
								Game->PlaySound(sfx);

							if(removeItem)
								Link->Item[key] = false;

							break;
						}
						// Otherwise display an error message
						else if(msg > 0)
						{
							pressDelay = -5;
							Screen->Message(msg);
						}
					}
				}
				else
					pressDelay = 0;

				// Trigger this lock block if other lock blocks have been opened
				if(Screen->State[ST_LOCKBLOCK])
				{
					Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]+1);
					break;
				}

				Waitframe();
			} //! End of while(true)
		} //! End of if(!Screen->State[ST_LOCKBLOCK])
		// Else lock blocks were already activated, so change the combo if needed
		else if(Screen->ComboD[loc] == dgnlock)
			Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), loc, Screen->ComboD[loc]+1);
	} //! End of void run(int dgnlock, int key, int msg, int sfx)
} //! End of ffc script LockedDungeonEntrance