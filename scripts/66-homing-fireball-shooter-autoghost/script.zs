// import "std.zh"
// import "string.zh"
// import "ghost.zh"

const int HFS_DEFAULT_STEP = 100;
const int HFS_DEFAULT_HOMING_TIME = 180;
const int HFS_DEFAULT_SPRITE = 17;
const int HFS_MIN_FIRE_TIME = 120;
const int HFS_MAX_FIRE_TIME = 480;
const int HFS_MIN_DISTANCE = 32;
const int HFS_DEFAULT_GRANULARITY = 0;
const int HFS_IC_SHIELD = 12; // Shield item class; you'll probably need to
							  // change this if using a GB-style shield

// npc->Misc[] indices
const int HFS_ATTR_STEP = 0;
const int HFS_ATTR_TURN_SPEED = 1;
const int HFS_ATTR_HOMING_TIME = 2;
const int HFS_ATTR_SHIELD_LEVEL = 3;
const int HFS_ATTR_SPRITE = 4;
const int HFS_ATTR_ROTATE = 5;
const int HFS_ATTR_SOUND = 6;
const int HFS_ATTR_MIN_DISTANCE = 7;
const int HFS_ATTR_GRANULARITY = 8;

ffc script HomingFireballShooter
{
	void run(int enemyID)
	{
		npc ghost;
		eweapon fireball;
		int damage;
		int step;
		float turnSpeed;
		int homingTime;
		int sprite;
		int sound;
		int distance;
		int granularity;
		int flags=0;
		int angle;

		
		// Initialize
		ghost=Ghost_InitAutoGhost(this, enemyID);
		ghost->CollDetection = false; // So Link won't get knocked back from touching it
		
		// Get enemy settings
		damage=ghost->WeaponDamage;
		
		step=Ghost_GetAttribute(ghost, HFS_ATTR_STEP, HFS_DEFAULT_STEP);
		turnSpeed=Ghost_GetAttribute(ghost, HFS_ATTR_TURN_SPEED, 0)/1000;
		homingTime=Ghost_GetAttribute(ghost, HFS_ATTR_HOMING_TIME, HFS_DEFAULT_HOMING_TIME);
		sprite=Ghost_GetAttribute(ghost, HFS_ATTR_SPRITE, HFS_DEFAULT_SPRITE, 0, 255);
		sound=Ghost_GetAttribute(ghost, HFS_ATTR_SOUND, 0, 0, 255);
		distance=Ghost_GetAttribute(ghost, HFS_ATTR_MIN_DISTANCE, 0, 0, 1024);
		granularity=Ghost_GetAttribute(ghost, HFS_ATTR_GRANULARITY, HFS_DEFAULT_GRANULARITY);
		
		if(ghost->Attributes[HFS_ATTR_SHIELD_LEVEL]<0)
			flags|=EWF_UNBLOCKABLE;
		else if(CurrentShieldLevel()<ghost->Attributes[HFS_ATTR_SHIELD_LEVEL])
			flags|=EWF_UNBLOCKABLE;
		
		if(ghost->Attributes[HFS_ATTR_ROTATE]>0)
			flags|=EWF_ROTATE;
		
		while(true)
		{
			Ghost_Waitframes(this, ghost, true, true, Rand(HFS_MIN_FIRE_TIME, HFS_MAX_FIRE_TIME));
			
			if(granularity<=0) // 0 granularity allows it to fire at any angle toward Link
				angle=RadtoDeg(ArcTan(Link->X-Ghost_X, Link->Y-Ghost_Y));
			else // 4 is 4-directional, 8 is 8-directional, 16 is 16-directional, etc. Yes, odd values work fine too.
				angle=Round(RadtoDeg(ArcTan(Link->X-Ghost_X, Link->Y-Ghost_Y))*granularity/360)*(360/granularity);


			if(Distance(Ghost_X, Ghost_Y, Link->X, Link->Y)>=distance)
			{
				fireball=FireEWeapon(EW_FIREBALL, Ghost_X, Ghost_Y, DegtoRad(angle), step, damage, sprite, sound, flags);
				if(turnSpeed!=0)
					SetEWeaponmovement(fireball, EWM_HOMING, turnSpeed);
				SetEWeaponLifespan(fireball, EWL_TIMER, homingTime);
			}
		}
		
	}
	
	// Get the level of Link's current shield
	int CurrentShieldLevel()
	{
		itemdata id;
		int maxLevel=0;
		
		for(int i=0; i<256; i++)
		{
			if(!Link->Item[i])
				continue;
			
			id=Game->LoadItemData(i);
			if(id->Family!=HFS_IC_SHIELD)
				continue;
			
			if(id->Level>maxLevel)
				maxLevel=id->Level;
		}
		
		return maxLevel;
	}
}