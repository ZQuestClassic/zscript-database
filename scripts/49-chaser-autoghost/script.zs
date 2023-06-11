// import "std.zh"
// import "string.zh"
// import "ghost.zh"

const int CHASER_ACCELERATION = 0.05;
const int CHASER_DEFAULT_STEP = 100;

// npc->Misc[] indices
const int CHASER_ATTR_IGNORE_WATER = 0;
const int CHASER_ATTR_IGNORE_PITS = 1;
const int CHASER_ATTR_WIDTH = 2;
const int CHASER_ATTR_HEIGHT = 3;
const int CHASER_ATTR_START_SOUND = 4;
const int CHASER_ATTR_STOP_SOUND = 5;
const int CHASER_ATTR_MOVE_SOUND = 6;
const int CHASER_ATTR_MOVE_SOUND_LOOP_TIME = 7;

ffc script Chaser
{
	void run(int enemyID)
	{
		npc ghost;
		int inactiveCombo;
		int direction;
		float speed=0;
		float maxSpeed;
		int flags=0;
		int startSound;
		int stopSound;
		int moveSound;
		int moveSoundLoopTime;
		
		// Initialize
		ghost=Ghost_InitAutoGhost(this, enemyID);
		Ghost_TileWidth=Ghost_GetAttribute(ghost, CHASER_ATTR_WIDTH, 1, 1, 4);
		Ghost_TileHeight=Ghost_GetAttribute(ghost, CHASER_ATTR_HEIGHT, 1, 1, 4);
		Ghost_SpawnAnimationPuff(this, ghost);
		
		// Read settings
		if(ghost->Attributes[CHASER_ATTR_IGNORE_WATER]>0)
			flags|=GHF_IGNORE_WATER;
		if(ghost->Attributes[CHASER_ATTR_IGNORE_PITS]>0)
			flags|=GHF_IGNORE_PITS;
		Ghost_SetFlags(flags);
		
		maxSpeed=ghost->Step/100;
		if(maxSpeed==0)
			maxSpeed=CHASER_DEFAULT_STEP/100;
		
		inactiveCombo=Ghost_Data;
		startSound=ghost->Attributes[CHASER_ATTR_START_SOUND];
		stopSound=ghost->Attributes[CHASER_ATTR_STOP_SOUND];
		moveSound=ghost->Attributes[CHASER_ATTR_MOVE_SOUND];
		moveSoundLoopTime=ghost->Attributes[CHASER_ATTR_MOVE_SOUND_LOOP_TIME];
		
		while(true)
		{
			// Wait for Link to come into range
			while(true)
			{
				// Link is aligned vertically
				if(Link->X>Ghost_X-14 && Link->X<Ghost_X+16*Ghost_TileWidth-2)
				{
					// Move up or down?
					if(Link->Y<Ghost_Y && Ghost_CanMove(DIR_UP, 1, 0))
					{
						direction=DIR_UP;
						break;
					}
					else if(Link->Y>Ghost_Y && Ghost_CanMove(DIR_DOWN, 1, 0))
					{
						direction=DIR_DOWN;
						break;
					}
					else
						Ghost_Waitframe(this, ghost, true, true);
				}
				// Link is aligned horizontally
				else if(Link->Y>Ghost_Y-14 && Link->Y<Ghost_Y+16*Ghost_TileHeight-2)
				{					
					// Move left or right?
					if(Link->X<Ghost_X && Ghost_CanMove(DIR_LEFT, 1, 0))
					{
						direction=DIR_LEFT;
						break;
					}
					else if(Link->X>Ghost_X && Ghost_CanMove(DIR_RIGHT, 1, 0))
					{
						direction=DIR_RIGHT;
						break;
					}
					else
						Ghost_Waitframe(this, ghost, true, true);
				}
				else
					Ghost_Waitframe(this, ghost, true, true);
			}
			
			// Start moving
			Ghost_Data=inactiveCombo+1;
			Game->PlaySound(startSound);
			
			// Start i at 1 so the sound doesn't play right away
			for(int i=1; Ghost_X%8!=0 || Ghost_Y%8!=0 || Ghost_CanMove(direction, 1, 0); i++)
			{
				// Play the sound, if it's time
				if(moveSoundLoopTime>0)
				{
					if(i%moveSoundLoopTime==0)
						Game->PlaySound(moveSound);
				}
				
				// Switch combos at certain points
				if(i==10 || i==40)
					Ghost_Data++;
				
				// Speed up and move
				speed=Min(speed+CHASER_ACCELERATION, maxSpeed);
				Ghost_Move(direction, speed, 0);
				Ghost_Waitframe(this, ghost, true, true);
			}
			
			// Stop
			speed=0;
			Game->PlaySound(stopSound);
			Ghost_Data=inactiveCombo;
		}
	}
}