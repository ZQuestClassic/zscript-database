import "std.zh"
import "string.zh"
import "ghost.zh"

ffc script FirePeahat
{
	void run(int enemyID)
	{
		npc ghost = Ghost_InitAutoGhost(this,enemyID);
		float peahatx;
		float peahaty;
		int oldx = Ghost_X;
		int oldy = Ghost_Y;

		while(Ghost_Waitframe2(this,ghost,true,true))
		{
			peahatx+=Ghost_X-oldx;
			oldx=Ghost_X;
			if(Abs(peahatx) >= 16)
			{
				DropFire(ghost->WeaponDamage);
				peahatx=0;
			}
			peahaty+=Ghost_Y-oldy;
			oldy=Ghost_Y;
			if(Abs(peahaty) >= 16)
			{
				DropFire(ghost->WeaponDamage);
				peahaty=0;
			}
		}
	}
	void DropFire(int damage)
	{
		eweapon trail = FireNonAngularEWeapon(EW_FIRETRAIL, Ghost_X, Ghost_Y, Ghost_Dir, 0, damage,-1, -1, EWF_UNBLOCKABLE);
		SetEWeaponMovement(trail, EWM_FALL, Ghost_Z);
	}
}