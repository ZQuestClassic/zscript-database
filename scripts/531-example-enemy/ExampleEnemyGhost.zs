namespace ExampleEnemy{

	ffc script ExampleEnemy_GHOST{
		// Constants for the enemy's animation offsets
		enum{
			ANIM_NEUTRAL = 0,
			ANIM_ATTACKING = 1
		};
		
		// Constants for attacks
		enum{
			ATTACK_TRIPLESHOT,
			ATTACK_STREAMSHOT,
			ATTACK_WALLBOUNCE,
			ATTACK_RESPAWN_ORBITS
		};
		
		// Constants for movement patterns
		enum{
			MOVE_ZIGZAG,
			MOVE_CORNER
		};
		
		// Constants for vars[] array indices
		enum{
			VARS_ATTACK_COOLDOWN, // Timer for an enforced delay between attacks
			VARS_MOVE_COOLDOWN, // Timer that counts down when the enemy is near Link
			VARS_NPC_ORBIT, // Array of orbiting npcs
			VARS_ORBIT_ID, // ID for the orbiting npcs
			VARS_ORBIT_ANGLE, // Base angle for the orbiting npcs
			VARS_ORBIT_DIST, // The distance for orbiting npcs
			VARS_ORBIT_SPEED, // The speed for orbiting npcs
			VARS_ORBIT_COUNT // The number of orbiting npcs alive
		};
		
		// Constants for the enemy's SFX
		enum{
			SFX_WHOOSH = 59, // When the enemy starts moving
			SFX_WALLBONK = 21, // When it bonks into a wall
			SFX_SHOOT = 32, // When it fires a weapon
			SFX_ORBITRESPAWN = 56, // When it respawns an orbiting enemy
			SFX_ORBITSPIN = 54 // When it spins the orbits faster
		};
		
		// Constants for the enemy's projectiles
		enum{
			SPR_BULLET = 88
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
			
			int lastAttack = -1; // Initialized to -1 so it can use any attack first
			int orbitRespawnCooldown = 2; // Number of attacks before orbits can be respawned
			bool attackCondition; // This gets set to true when the enemy should enter the attacking state
			
			// Here we set up the vars array. This is an array of data that gets passed into Waitframe() and other functions.
			// In this case it's going to be updating 4 child npcs that orbit the main body and the main body's timers.
			untyped vars[16];
			npc orbit[4];
			vars[VARS_ATTACK_COOLDOWN] = 0;
			vars[VARS_MOVE_COOLDOWN] = 32;
			vars[VARS_NPC_ORBIT] = orbit; // Array pointers can be passed to other arrays. In this case because it's untyped it can also hold npc array pointers
			vars[VARS_ORBIT_ID] = ghost->Attributes[0]; // Attributes[0] is the enemy's Attribute 1 in the editor
			vars[VARS_ORBIT_ANGLE] = 0;
			vars[VARS_ORBIT_DIST] = 24;
			vars[VARS_ORBIT_SPEED] = 2;
			
			// Attribute 11 is the enemy's starting combo
			int combo = ghost->Attributes[10];
			
			UpdateOrbits(vars, true, false);
			while(true){
				// The enemy's movement phase happens before its attack phase.
				// In this case I gave it two movement patterns that it chooses at random.
				int movePattern = Rand(2);
				switch(movePattern){
					// MOVEMENT PATTERN 0: Move in a zig-zag towards Link
					case MOVE_ZIGZAG:
						int moveAngle = Angle(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y);
						// Move slowly towards Link for 32 frames
						for(int i=0; i<32; ++i){
							moveAngle = Angle(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y);
							Ghost_MoveAtAngle(moveAngle, 0.3, 0);
							Waitframe(this, ghost, vars, 1);
						}
						Waitframe(this, ghost, vars, 16); // Pause before zig-zag
						
						// 6 zig-zag motions in the stored direction
						int zigDir = Choose(-1, 1);
						for(int i=0; i<6&&!attackCondition; ++i){
							// Stop if it hit a wall
							if(!Ghost_CanMove(AngleDir4(moveAngle), 1, 0))
								break;
							Game->PlaySound(SFX_WHOOSH);
							for(int j=0; j<12&&!attackCondition; ++j){
								attackCondition = CanAttack(vars);
								Ghost_MoveAtAngle(moveAngle+60*zigDir, 2, 0);
								Waitframe(this, ghost, vars, 1);
							}
							zigDir *= -1; // Flip zigzag direction with every motion
							Waitframe(this, ghost, vars, 4); //Short pause after each motion
						}
						Waitframe(this, ghost, vars, 32); //Pause after moving
						// Remove a bit of movement cooldown for making a motion during the movement phase
						vars[VARS_MOVE_COOLDOWN] = Max(vars[VARS_MOVE_COOLDOWN]-16, 0);
						break;
					// MOVEMENT PATTERN 1: Pick a corner and move there
					case MOVE_CORNER:
						// An array of four tile positions in the corner the enemy can glide to
						int cornerPos[] = {35, 43, 115, 123};
						int targetX = Ghost_X;
						int targetY = Ghost_Y;
						// Keep rerolling a target corner until it finds one that's not too close
						while(Distance(Ghost_X, Ghost_Y, targetX, targetY)<64){
							int target = cornerPos[Rand(4)];
							targetX = ComboX(target);
							targetY = ComboY(target);
						}
						// Move the enemy into position
						Game->PlaySound(SFX_WHOOSH);
						for(int i=0; i<64&&!attackCondition; ++i){
							attackCondition = CanAttack(vars);
							int step = Lerp(1, 4, i/63);
							// If the enemy is in position, break the movement loop
							if(Distance(Ghost_X, Ghost_Y, targetX, targetY)<step){
								Ghost_X = targetX;
								Ghost_Y = targetY;
								break;
							}
							Ghost_MoveAtAngle(Angle(Ghost_X, Ghost_Y, targetX, targetY), step, 0);
							Waitframe(this, ghost, vars, 1);
						}
						Waitframe(this, ghost, vars, 32); //Pause after moving
						// Remove a bit of movement cooldown for making a motion during the movement phase
						vars[VARS_MOVE_COOLDOWN] = Max(vars[VARS_MOVE_COOLDOWN]-4, 0);
						break;
				}
				
				// Next up is the attack phase. 
				// But we'll let the move phase repeat until an attacking condition has been reached
				if(attackCondition){
					// Choose an attack at random
					int attack = Choose(ATTACK_TRIPLESHOT, ATTACK_STREAMSHOT, ATTACK_WALLBOUNCE);
					// If the enemy selects the same attack twice, reroll until it's a new one
					while(attack==lastAttack)
						attack = Choose(ATTACK_TRIPLESHOT, ATTACK_STREAMSHOT, ATTACK_WALLBOUNCE);
					
					// If only two or more orbits remain, count down to respawning them
					if(vars[VARS_ORBIT_COUNT]<=2){
						if(vars[VARS_ORBIT_COUNT]==0){
							// Count down twice as fast with 0 orbits
							if(orbitRespawnCooldown)
								--orbitRespawnCooldown;
							
							// Can't use the stream shot with 0 orbits
							if(attack==ATTACK_STREAMSHOT)
								attack = ATTACK_TRIPLESHOT;
						}
						
						if(orbitRespawnCooldown)
							--orbitRespawnCooldown;
						else{
							attack = ATTACK_RESPAWN_ORBITS;
							orbitRespawnCooldown = 2;
						}
					}
					
					lastAttack = attack;
					attackCondition = false;
					
					switch(attack){
						// ATTACK 0: Shoot three projectiles
						case ATTACK_TRIPLESHOT: 
						{
							Ghost_Data = combo + ANIM_ATTACKING;
							Windup(this, ghost, vars);
							Waitframe(this, ghost, vars, 16);
							// Offset the weapon angle in a loop to fire a triple shot
							for(int i=-1; i<=1; ++i){
								FireEWeapon(Ghost_X+8, Ghost_Y+8, Angle(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y) + 30*i, 250, ghost->WeaponDamage);
							}
							Waitframe(this, ghost, vars, 16);
							break;
						}
						// ATTACK 1: Move away from Link and shoot a stream of projectiles from the orbits
						case ATTACK_STREAMSHOT: 
						{
							Ghost_Data = combo + ANIM_ATTACKING;
							Windup(this, ghost, vars);
							// Move away from Link for 32 frames
							for(int i=0; i<32; ++i){
								Ghost_MoveTowardLink(-1, 0);
								Waitframe(this, ghost, vars, 1);
							}
							// Fire up to 16 bullets depending on how many orbits remain
							for(int i=0; i<16; ++i){
								int j = Rand(4);
								// If it rolled an invalid orbit, try a few more times to find one
								if(!orbit[j]->isValid()){
									for(int k=0; k<4&&!orbit[j]->isValid(); ++k)
										j = Rand(4);
								}
								
								// If the orbit is valid, fire a weapon from its position
								if(orbit[j]->isValid()){
									FireEWeapon(orbit[j]->X, orbit[j]->Y, Angle(orbit[j]->X, orbit[j]->Y, Link->X, Link->Y), 250, ghost->WeaponDamage);
								}
								
								Waitframe(this, ghost, vars, 6);
							}
							Waitframe(this, ghost, vars, 16);
							break;
						}
						// ATTACK 2: Bounce off the walls of the room at a 45 degree angle
						case ATTACK_WALLBOUNCE: 
						{
							Ghost_Data = combo + ANIM_ATTACKING;
							Windup(this, ghost, vars);
							// Get X and Y velocities moving away from Link
							int vX = Sign(Link->X - (Ghost_X+8));
							int vY = Sign(Link->Y - (Ghost_Y+8));
							for(int i=0; i<16; ++i){
								Ghost_MoveXY(vX*0.5, vY*0.5, 0);
								Waitframe(this, ghost, vars, 1);
							}
							for(int i=0; i<180; ++i){
								// If about to hit a wall on the X axis, bonk and turn around
								if((vX<0&&!Ghost_CanMove(DIR_LEFT, 1, 0)) || (vX>0&&!Ghost_CanMove(DIR_RIGHT, 1, 0))){
									vX = -vX;
									Game->PlaySound(SFX_WALLBONK);
									Waitframe(this, ghost, vars, 4);
								}
								// If about to hit a wall on the Y axis, bonk and turn around
								if((vY<0&&!Ghost_CanMove(DIR_UP, 1, 0)) || (vY>0&&!Ghost_CanMove(DIR_DOWN, 1, 0))){
									vY = -vY;
									Game->PlaySound(SFX_WALLBONK);
									Waitframe(this, ghost, vars, 4);
								}
								Ghost_MoveXY(vX*2.5, vY*2.5, 0);
								Waitframe(this, ghost, vars, 1);
							}
							Waitframe(this, ghost, vars, 32);
							break;
						}
						// ATTACK 3: Respawn lost orbits, then approach Link and expand them outwards
						case ATTACK_RESPAWN_ORBITS:
						{
							repeat(3)Windup(this, ghost, vars);
							vars[VARS_ORBIT_SPEED] = 0;
							// Respawn any lost orbits
							for(int i=0; i<4; ++i){
								if(!orbit[i]->isValid()){
									Game->PlaySound(SFX_ORBITRESPAWN);
									orbit[i] = CreateNPCAt(vars[VARS_ORBIT_ID], Ghost_X+8, Ghost_Y+8);
								}
								Waitframe(this, ghost, vars, 8);
							}
							// Move towards Link
							int ang = Angle(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y);
							vars[VARS_ORBIT_SPEED] = 2;
							for(int i=0; i<32; ++i){
								Ghost_MoveAtAngle(ang, 2, 0);
								Waitframe(this, ghost, vars, 1);
							}
							Waitframe(this, ghost, vars, 32);
							Ghost_Data = combo + ANIM_ATTACKING;
							// Expand the orbits while spinning faster. 
							// We modify the distance and speed with linear interpolation
							Game->PlaySound(SFX_ORBITSPIN);
							vars[VARS_ORBIT_SPEED] = 4;
							for(int i=0; i<32; ++i){
								vars[VARS_ORBIT_DIST] = Lerp(24, 96, i/31);
								Waitframe(this, ghost, vars, 1);
							}
							for(int i=0; i<48; ++i){
								vars[VARS_ORBIT_DIST] = Lerp(96, 24, i/47);
								vars[VARS_ORBIT_SPEED] = Lerp(4, 2, i/47);
								Waitframe(this, ghost, vars, 1);
							}
							break;
						}
					}
					
					Ghost_Data = combo + ANIM_NEUTRAL;
					
					vars[VARS_ATTACK_COOLDOWN] = 64;
					vars[VARS_MOVE_COOLDOWN] = 32;
				}
			}
		}
		
		// Play a windup spin animation before attacking
		void Windup(ffc this, npc ghost, untyped vars){
			// Start moving at a random angle
			int ang = Rand(360);
			//Quickly turn to make a circle motion
			for(int i=0; i<18; ++i){
				Ghost_MoveAtAngle(ang, 1, 0);
				ang += 20;
				Waitframe(this, ghost, vars, 1);
			}
		}
		
		// A simple wrapper function for FireEWeapon
		eweapon FireEWeapon(int x, int y, int ang, int step, int damage){
			eweapon e = FireEWeapon(EW_SCRIPT10, x, y, DegtoRad(ang), step, damage, SPR_BULLET, SFX_SHOOT, EWF_UNBLOCKABLE);
			e->Rotation = ang;
			return e;
		}
		
		// Update the enemy's cooldown clocks and return true if it can attack
		bool CanAttack(untyped vars){
			// First wait a certain amount after attacking
			if(vars[VARS_ATTACK_COOLDOWN]>0)
				--vars[VARS_ATTACK_COOLDOWN];
			else{
				// If the enemy got hit, reduce its move cooldown
				if(Ghost_GotHit())
					vars[VARS_MOVE_COOLDOWN] = Max(vars[VARS_MOVE_COOLDOWN]-24, 0);
				
				if(vars[VARS_MOVE_COOLDOWN]){
					// Decrement move cooldown when near Link
					if(Distance(Ghost_X+8, Ghost_Y+8, Link->X, Link->Y)<80)
						--vars[VARS_MOVE_COOLDOWN];
				}
				else // When the move cooldown hits 0, the enemy can attack
					return true;
			}
			return false;
		}
		
		// Update the positions of the orbits. Can also draw and spawn them as needed.
		// spawn is true at the start of the script when this function creates new orbits.
		// draw is true in the waitframe, where drawing is handled. 
		// Other calls to this function are only updating the position of the orbits.
		void UpdateOrbits(untyped vars, bool spawn, bool draw){
			// Pull the enemy array out of vars so we can loop over it
			npc orbits = vars[VARS_NPC_ORBIT];
			// Reset the count of living orbits, so we can recount
			vars[VARS_ORBIT_COUNT] = 0;
			for(int i=0; i<4; ++i){
				// Get the angle, x and y position of the orbit
				int ang = WrapDegrees(vars[VARS_ORBIT_ANGLE]+90*i);
				int x = Ghost_X+8+VectorX(vars[VARS_ORBIT_DIST], ang);
				int y = Ghost_Y+8+VectorY(vars[VARS_ORBIT_DIST]*0.5, ang);
				if(orbits[i]->isValid()){
					//If an orbit is dying, make it visible and remove it from the array 
					if(orbits[i]->HP<=0){
						orbits[i]->DrawXOffset = 0;
						orbits[i] = NULL;
						continue;
					}
					orbits[i]->X = Clamp(x, -32, 256+16);
					orbits[i]->Y = Clamp(y, -32, 176+16);
					// This math gets an enemy's flash cset from their knockback timer
					int cset = orbits[i]->CSet;
					if(orbits[i]->InvFrames)
						cset = 9-(orbits[i]->InvFrames>>1);
					// Angles -180-0 should draw behind the main enemy, offset the draw offset 
					// so they show up as invisible and redraw them
					if(draw){
						if(ang<0){
							Screen->FastTile(2, orbits[i]->X, orbits[i]->Y, orbits[i]->Tile, cset, 128);
							orbits[i]->DrawXOffset = -1000;
						}
						else
							orbits[i]->DrawXOffset = 0;
					}
					++vars[VARS_ORBIT_COUNT];
				}
				else if(spawn){
					orbits[i] = CreateNPCAt(vars[VARS_ORBIT_ID], x, y);
					++vars[VARS_ORBIT_COUNT];
				}
			}
			// Increase the base angle to make the orbits spin
			vars[VARS_ORBIT_ANGLE] = WrapDegrees(vars[VARS_ORBIT_ANGLE] + vars[VARS_ORBIT_SPEED]);
		}
		
		// This handles the enemy's death animation and any cleanup that may need to do.
		void DeathAnimation(ffc this, npc ghost, untyped vars){
			// Pull the enemy array out of vars so we can loop over it
			npc orbits = vars[VARS_NPC_ORBIT];
			for(int i=0; i<4; ++i){
				// Kill all the valid orbits and make them visible
				if(orbits[i]->isValid()){
					orbits[i]->HP = 0;
					orbits[i]->DrawXOffset = 0;
				}
			}
			// Play the standard explosion death animation.
			// To make your own ghost.zh death animations, look at 
			// __Ghost_Explode() in ghost2_other.zh as an example. 
			Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
			// The script needs to quit here or else it'll explode indefinitely.
			Quit();
		}
		
		// This is a wrapper function for Ghost_Waitframe().
		// It will handle things the enemy does every frame while waiting on the engine.
		// untyped vars is an array of data used for storing various things you might want 
		// to keep updated at all times. int frames is the number of frames to wait for
		void Waitframe(ffc this, npc ghost, untyped vars, int frames){
			for(int i=0; i<frames; ++i){
				UpdateOrbits(vars, false, true);
				// When ghost waitframe returns false (and quitOnDeath is false)
				// The death animation can begin. 
				if(!Ghost_Waitframe(this, ghost, false, false)){
					DeathAnimation(this, ghost, vars);
				}
			}
		}
	}
	
}