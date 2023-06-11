ffc script HatWizzrobe{
	void run(int enemyid){
		npc ghost = Ghost_InitAutoGhost(this, enemyid);
		Ghost_SetFlag(GHF_4WAY);
		Ghost_SetFlag(GHF_KNOCKBACK_4WAY);
		Ghost_SetFlag(GHF_STUN);
		Ghost_SetFlag(GHF_CLOCK);
		int Store[18];
		//Ghost_CSet = ghost->Attributes[9];
		int LASER_COMBO = Ghost_Data;
		Ghost_StoreDefenses(ghost, Store);
		Ghost_Waitframe(this, ghost, true, true);
		Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
		//bool Eppy;
		ghost->CollDetection = false;
		for (int i = 60; i > 0; i--)
		{
			Ghost_Waitframe(this, ghost, true, true);
		}
		while(true){
			Ghost_Dir = AngleDir4(Angle(Ghost_X, Ghost_Y, Link->X, Link->Y));
			Ghost_SetDefenses(ghost, Store);
			for (int i = 30; i > 0; i--)
			{
				if (i % 2 == 0 || i % 5 == 0) Ghost_Data = LASER_COMBO + 4;
				else Ghost_Data = LASER_COMBO;
				Ghost_Waitframe(this, ghost, true, true);
			}
			ghost->CollDetection = true;
			if (ghost->Attributes[1] > 0) Ghost_Dir = AngleDir4(Angle(Ghost_X, Ghost_Y, Link->X, Link->Y));
			for (int i = 30; i > 0; i--)
			{
				if (i > 15) Ghost_Data = LASER_COMBO + 8;
				else Ghost_Data = LASER_COMBO + 12;
				Ghost_Waitframe(this, ghost, true, true);
			}
			Ghost_Data = LASER_COMBO + 16;
			eweapon Flamewar;
			if (ghost->Weapon >= 129 && ghost->Weapon <= 145 && ghost->Weapon != 144 && ghost->Weapon != 143)
			{
				if (ghost->Attributes[2] == 0)
				{
					if (Ghost_Dir == DIR_UP) Flamewar = FireNonAngularEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y - 8, DIR_UP, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_DOWN) Flamewar = FireNonAngularEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y + 8, DIR_DOWN, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_LEFT) Flamewar = FireNonAngularEWeapon(ghost->Weapon, Ghost_X - 8, Ghost_Y + 0, DIR_LEFT, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_RIGHT) Flamewar = FireNonAngularEWeapon(ghost->Weapon, Ghost_X + 8, Ghost_Y + 0, DIR_RIGHT, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
				}
				else if (ghost->Attributes[2] > 0)
				{
					int tempangle = RadianAngle(Ghost_X, Ghost_Y, Link->X, Link->Y) + (2*PI);
					int maxangle = dirToRad(Ghost_Dir) + DegtoRad(ghost->Attributes[2]) + (2*PI);
					int minangle = dirToRad(Ghost_Dir) - DegtoRad(ghost->Attributes[2]) + (2*PI);
					if (Ghost_Dir == DIR_UP) Flamewar = FireEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y - 8, VBound(tempangle, maxangle, minangle) - (2*PI), ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_DOWN) Flamewar = FireEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y + 8, VBound(tempangle, maxangle, minangle) - (2*PI), ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_LEFT) Flamewar = FireEWeapon(ghost->Weapon, Ghost_X - 8, Ghost_Y + 0, VBound(tempangle, maxangle, minangle) - (2*PI), ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_RIGHT) Flamewar = FireEWeapon(ghost->Weapon, Ghost_X + 8, Ghost_Y + 0, VBound(tempangle, maxangle, minangle) - (2*PI), ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
				}
				else
				{
					if (Ghost_Dir == DIR_UP) Flamewar = FireAimedEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y - 8, 0, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_DOWN) Flamewar = FireAimedEWeapon(ghost->Weapon, Ghost_X + 0, Ghost_Y + 8, 0, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_LEFT) Flamewar = FireAimedEWeapon(ghost->Weapon, Ghost_X - 8, Ghost_Y + 0, 0, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
					if (Ghost_Dir == DIR_RIGHT) Flamewar = FireAimedEWeapon(ghost->Weapon, Ghost_X + 8, Ghost_Y + 0, 0, ghost->Attributes[0], ghost->WeaponDamage, -1, -1, 0);
				}
			}
			//Trace(421);
			if (ghost->Weapon == WPN_ENEMYBRANG)
			{
				//Trace(422);
				if (Flamewar->isValid())
				{
					//Trace(423);
					for (int i = 40; Flamewar->isValid() && i > 0; i--)
					{
						//Trace(424);
						Ghost_Waitframe(this, ghost, true, true);
					}
					if (Flamewar->isValid()) Flamewar->DeadState = WDS_BOUNCE;
					TraceB(Collision(ghost, Flamewar));
					while (Flamewar->isValid() && Collision(ghost, Flamewar) == false)
					{
						//Trace(425);
						Flamewar->X += VectorX(5, Angle(Flamewar->X, Flamewar->Y, Ghost_X, Ghost_Y));
						Flamewar->Y += VectorY(5, Angle(Flamewar->X, Flamewar->Y, Ghost_X, Ghost_Y));
						Ghost_Waitframe(this, ghost, true, true);
					}
					Remove(Flamewar);
					Game->PlaySound(SFX_BRANG);
				}
			}
			else for (int i = 30; i > 0; i--)
			{
				Ghost_Waitframe(this, ghost, true, true);
			}
			for (int i = 0; i < 30; i++)
			{
				if (i > 15) Ghost_Data = LASER_COMBO + 8;
				else Ghost_Data = LASER_COMBO + 12;
				Ghost_Waitframe(this, ghost, true, true);
			}
			ghost->CollDetection = false;
			for (int i = 30; i > 0; i--)
			{
				if (i % 2 == 0 || i % 5 == 0) Ghost_Data = LASER_COMBO + 4;
				else Ghost_Data = LASER_COMBO;
				Ghost_Waitframe(this, ghost, true, true);
			}
			Ghost_Data = LASER_COMBO;
			Ghost_StoreDefenses(ghost, Store);
			Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
			ghost->CollDetection = false;
			int randmax = ghost->Attributes[3];
			int randmin = ghost->Attributes[4];
			for (int i = Rand(randmin, randmax); i > 0; i--)
			{
				Ghost_Waitframe(this, ghost, true, true);
			}
			Ghost_Waitframe(this, ghost, true, true);
		}
	}
}