const int HELMASAUR_ATTR_STUN_TIME = 0;

ffc script Helmasaur
{
	void run(int enemyID)
	{
		//Initialize the ghost
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		Ghost_SetFlag(GHF_SET_DIRECTION);
		Ghost_SetFlag(GHF_KNOCKBACK);

		//Movement Variabbles
		int step = ghost->Step;
		int stunCounter;
		int oldKnockback;

		Ghost_SpawnAnimationPuff(this, ghost);

		//Loop until defeated.
		do
		{
			//Protected from front and rebounds on sword collision.
			lweapon sword = LoadLWeaponOf(LW_SWORD);
			if(sword->isValid())
			{
				if(Collision(sword, ghost) && Link->Dir == (Ghost_Dir^1))
				__Ghost_KnockbackCounter=Link->Dir<<12|__GH_KNOCKBACK_TIME;
			}

			//Finished Knockback?
			if(oldKnockback == 1 || (__Ghost_InternalFlags & __GHFI_KNOCKBACK_INTERRUPTED))
			stunCounter = Ghost_GetAttribute(ghost, HELMASAUR_ATTR_STUN_TIME, 80);
			oldKnockback = __Ghost_KnockbackCounter & 4095;

			//Stunned?
			if(stunCounter > 0)
			stunCounter--;

			//Can move so do so.
			else if(!(__Ghost_KnockbackCounter & 4095) && !ClockIsActive() && !ghost->Stun)
			Ghost_MoveTowardLink(step/100, 2);
			
		} while(Ghost_Waitframe(this, ghost, true, true));
	}
}