// This script is for a fire keese, which harms Link when he slashes at it
// IMPORTANT: This requires ghost.zh to be setup first
	// Type: Other (Floating)
	// Attributes to set for the fire keese
	// Random Rate: The number of 8 pixel segments the keese will go before changing directions (DEFAULT: 6)
	// Homing Factor: The percentage (0-100) of times the keese will go toward Link when changing directions
	// Misc Attribute 11: The value set to GH_INVISIBLE_COMBO or -1
	// Misc Attribute 12: The ffc script slot
	// Be sure to check "Damaged by Power 0 Weapons" under Misc. Flags if you want the level 1 boomerang to hurt it!
ffc script FireKeese
{
	void run(int enemyID)
	{
		npc ghost;

		// Initialize - come to life and set the combo
		ghost = Ghost_InitAutoGhost(this, enemyID);
		Ghost_SetFlag(GHF_SET_DIRECTION);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_FAKE_Z);
		
		float step = ghost->Step/100;
		float maxSegments = ghost->Rate;
		if(maxSegments <= 0)
			maxSegments = 5;
		
		int movingDir = Rand(8);
		int movingDistance = (Rand(5)+1)*8; // 8-48 pixels
		
		// Give the keese a chance to go after Link
		if(Rand(100) < ghost->Homing)
			movingDir = RadianAngleDir8(RadianAngle(this->X, this->Y, Link->X, Link->Y));
		
		// Continue while the keese is still alive
		while(Ghost_HP > 0)
		{
			// See how far the keese is going to move this round
			int dist = movingDistance;
			if(dist > step)
				dist = step;
			movingDistance -= dist;
			
			// If the keese has stopped going in its current direction or needs to move
			if(movingDistance == 0 || !Ghost_CanMove(movingDir, dist, 0))
			{
				int newDir = Rand(8);
				
				// Give a chance for the keese to attack Link
				if(ghost->Homing > 0 && Rand(100) < ghost->Homing)
					newDir = RadianAngleDir8(RadianAngle(this->X, this->Y, Link->X, Link->Y));
				
				// If the new direction doesn't work, increment and try again
				for(int i = 1; i < 8 && !Ghost_CanMove(newDir, 8, 0); i++)
					newDir = (newDir+1)%8;
					
				movingDir = newDir;
				movingDistance = (Rand(5)+1)*8-step; // 8-48 pixels
				dist = step;
			}
		
			Ghost_Z = 8;
			Ghost_Move(movingDir, dist, 0);
			Ghost_Waitframe(this, ghost, true, false);
		}
		
		eweapon linkDamager; 
		
		// The keese is dead, so damage Link if he hit it with the sword
		for(int i = 1; i <= Screen->NumLWeapons(); i++)
		{
			lweapon temp = Screen->LoadLWeapon(i);
			if((temp->ID == LW_SWORD || temp->ID == LW_HAMMER || temp->ID == LW_WAND) && Collision(temp, ghost))
			{
				// Create an eweapon to damage Link
				linkDamager = Screen->CreateEWeapon(EW_FIREBALL);
				linkDamager->Dir = RadianAngleDir4(Angle(temp->X, temp->Y, Link->X, Link->Y)) + 8;
				linkDamager->X = Link->X;
				linkDamager->Y = Link->Y;
				linkDamager->Tile = GH_BLANK_TILE;
				linkDamager->OriginalTile = GH_BLANK_TILE;
				linkDamager->NumFrames = 0;
				linkDamager->Damage = ghost->Damage;
			}
		}
		
		// Wait to remove the damager so that it doesn't staw on the screen forever
		for(int i = 0; linkDamager->isValid() && i < 20; i++)
		{
			linkDamager->X = Link->X;
			linkDamager->Y = Link->Y;
			Waitframe();
		}
		if(linkDamager->isValid())
			Remove(linkDamager);
	}
} //! End of ffc script FireKeese