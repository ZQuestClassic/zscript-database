namespace ExampleEnemy{

	ffc script ExampleEnemyMinimal_GHOST{
		// Constants for the enemy's animation offsets
		enum{
			ANIM_NEUTRAL = 0,
			ANIM_ATTACKING = 1
		};
		
		void run(int enemyid){
			// Declare and assign the npc pointer to an enemy on the screen.
			// This uses InitAutoGhost because this script is intended to be run off
			// the autoghost global script rather than manually placed via FFC. 
			npc ghost = Ghost_InitAutoGhost(this, enemyid);
			
			// Resizes the enemy's tile size and hitbox. 
			// The two -1 args are its combo and cset, which don't need to change.
			Ghost_Transform(this, ghost, -1, -1, 2, 2);
			
			// Shrink the enemy's hitbox. It's generally best for the enemy's hitbox to be a little 
			// smaller than its sprite to account for empty space in the corners.
			Ghost_SetHitOffsets(ghost, 3, 3, 3, 3);
			
			int attack; // The current attack used by the enemy
			int attackCooldown = 96; // The delay before the enemy can use another attack
			
			// Attribute 11 is the enemy's starting combo
			int combo = ghost->Attributes[10];
			
			while(true){
				// While the enemy isn't attacking, give it some other movement pattern.
				// The most basic is just moving straight towards Link every frame.
				Ghost_MoveTowardLink(0.3, 0);
			
				// Count down the attack cooldown to 0
				if(attackCooldown)
					--attackCooldown;
				// If it's 0, check against a rand 16 for some random variance
				else if(Rand(16)==0){
					// Now the attack phase begins. Choose an attack to use
					attack = Choose(0, 1);
					switch(attack){
						// ATTACK 0: Triple fireball
						case 0:
						{
							Ghost_Data = combo + ANIM_ATTACKING;
							Ghost_Waitframes(this, ghost, GHD_EXPLODE, true, 16);
							// Offset the weapon angle in a loop to fire a triple shot
							for(int i=-1; i<=1; ++i){
								// FireAimedEWeapon() uses an angle that starts from the enemy towards Link, so we're giving it DegtoRad(30*i) as an offset to that.
								// The two -1's at the end tell it to use the default sprite and SFX for this weapon type, so a basic fireball.
								eweapon e = FireAimedEWeapon(EW_FIREBALL, Ghost_X+8, Ghost_Y+8, DegtoRad(30*i), 250, ghost->WeaponDamage, -1, -1, EWF_UNBLOCKABLE);
							}
							Ghost_Waitframes(this, ghost, GHD_EXPLODE, true, 16);
						}
						// ATTACK 1: Dash at Link
						case 1:
						{
							Ghost_Data = combo + ANIM_ATTACKING;
							// Store the angle between the enemy and Link, then wait for a bit
							int ang = Angle(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y);
							Ghost_Waitframes(this, ghost, GHD_EXPLODE, true, 32);
							// For 32 frames, move at that angle
							for(int i=0; i<32; ++i){
								Ghost_MoveAtAngle(ang, 2.5, 0);
								Ghost_Waitframe(this, ghost, GHD_EXPLODE, true);
							}
							Ghost_Waitframes(this, ghost, GHD_EXPLODE, true, 16);
						}
					}
					// Reset the enemy's animation to neutral
					Ghost_Data = combo + ANIM_NEUTRAL;
					// Make it wait another 96 frames before it can attack again
					attackCooldown = 96;
				}
			
				// A GHD_EXPLODE makes the enemy 
				// play a death animation when it dies.
				Ghost_Waitframe(this, ghost, GHD_EXPLODE, true);
			}
		}
		// There's no Waitframes() equivalent for Ghost_Waitframe() with a death animation so we'll just make one
		void Ghost_Waitframes(ffc this, npc ghost, int deathAnimation, bool quitOnDeath, int frames){
			for(int i=0; i<frames; ++i){
				Ghost_Waitframe(this, ghost, deathAnimation, quitOnDeath);
			}
		}
	}
}