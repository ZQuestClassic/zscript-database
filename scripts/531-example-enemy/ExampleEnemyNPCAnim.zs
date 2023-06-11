namespace ExampleEnemy{

	// This is a class holding all the persistent variables 
	// associated with the enemy. It's created once at the start
	// and then passed down its functions so they can all access
	// the data within. You could have enemy classes handle behavior
	// as well, but I mostly use them for plain old data.
	class ExampleEnemyData{
		npc Orbit[4]; // An array of enemies that orbit the main body
		int AttackCooldown;
		int MoveCooldown;
		bool GotHit;
		int OrbitID;
		int OrbitCount;
		int OrbitAngle;
		int OrbitDist;
		int OrbitSpeed;
		
		ExampleEnemyData(npc n){
			AttackCooldown = 0;
			MoveCooldown = 32;
			OrbitID = n->Attributes[0]; // Attributes[0] is the enemy's Attribute 1 in the editor
			OrbitCount = 0;
			OrbitAngle = 0;
			OrbitDist = 24;
			OrbitSpeed = 2;
		}
	}

	npc script ExampleEnemy_NPCANIM{
		using namespace NPCAnim;
	
		// Constants for the enemy's animations
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
		
		void run(){
			// First create a new AnimHandler object, aptr. This will hold
			// all the data used for NPCAnim.zh's animation handling.
			// It will then be assigned to one of the enemy's Misc[] indices so
			// anything can access it off of the enemy.
			AnimHandler aptr = new AnimHandler(this);
			
			
			// Add animations to aptr with this function. Do this once at the start of the script.
			// In this case, the tile positions of both animations are relative to the enemy's original tile,
			// So ANIM_NEUTRAL uses 0 and ANIM_ATTACKING uses 8. You can use 
			// absolute tile numbers if you want with the ADF_NORELATIVE flag
			aptr->AddAnim(ANIM_NEUTRAL, 0, 4, 4, ADF_NORESET);
			aptr->AddAnim(ANIM_ATTACKING, 8, 4, 2, ADF_NORESET);
		
			// Resizes the enemy's tile size and hitbox.
			// The last four args are pixels shaved off each side of the hitbox.
			// It's generally best for the enemy's hitbox to be a little 
			// smaller than its sprite to account for empty space in the corners.
			aptr->SetHitbox(2, 2, {3, 3, 3, 3});
			
			// Same as above but for the hitbox's collision with terrain.
			aptr->SetMovementHitbox({3, 3, 3, 3}, true); 
			
			int lastAttack = -1; // Initialized to -1 so it can use any attack first
			int orbitRespawnCooldown = 2; // Number of attacks before orbits can be respawned
			bool attackCondition; // This gets set to true when the enemy should enter the attacking state
			
			// Here we create an instance of the enemy data class. This holds all the persistent data associated 
			// with the enemy. It's passed to Waitframe() and other functions so they can access and use this data.
			// In this case it's going to be updating 4 child npcs that orbit the main body and the main body's timers.
			ExampleEnemyData eed = new ExampleEnemyData(this);
			
			// Update the orbits once to put them in their starting locations
			UpdateOrbits(this, eed, true, false);
			while(true){
				// The enemy's movement phase happens before its attack phase.
				// In this case I gave it two movement patterns that it chooses at random.
				int movePattern = Rand(2);
				switch(movePattern){
					// MOVEMENT PATTERN 0: Move in a zig-zag towards Link
					case MOVE_ZIGZAG:
						int moveAngle = Angle(this->X+8, this->Y+8, Link->X, Link->Y);
						// Move slowly towards Link for 32 frames
						for(int i=0; i<32; ++i){
							moveAngle = Angle(this->X+8, this->Y+8, Link->X, Link->Y);
							MoveAtAngle(this, moveAngle, 0.3, AM_NONE);
							Waitframe(this, eed, 1);
						}
						Waitframe(this, eed, 16); // Pause before zig-zag
						
						// 6 zig-zag motions in the stored direction
						int zigDir = Choose(-1, 1);
						for(int i=0; i<6&&!attackCondition; ++i){
							// Stop if it hit a wall
							if(!CanMove(this, AngleDir4(moveAngle), AM_NONE))
								break;
							Game->PlaySound(SFX_WHOOSH);
							for(int j=0; j<12&&!attackCondition; ++j){
								attackCondition = CanAttack(this, eed);
								MoveAtAngle(this, moveAngle+60*zigDir, 2, AM_NONE);
								Waitframe(this, eed, 1);
							}
							zigDir *= -1; // Flip zigzag direction with every motion
							Waitframe(this, eed, 4); //Short pause after each motion
						}
						Waitframe(this, eed, 32); //Pause after moving
						// Remove a bit of movement cooldown for making a motion during the movement phase
						eed->MoveCooldown = Max(eed->MoveCooldown-16, 0);
						break;
					// MOVEMENT PATTERN 1: Pick a corner and move there
					case MOVE_CORNER:
						// An array of four tile positions in the corner the enemy can glide to
						int cornerPos[] = {35, 43, 115, 123};
						int targetX = this->X;
						int targetY = this->Y;
						// Keep rerolling a target corner until it finds one that's not too close
						while(Distance(this->X, this->Y, targetX, targetY)<64){
							int target = cornerPos[Rand(4)];
							targetX = ComboX(target);
							targetY = ComboY(target);
						}
						// Move the enemy into position
						Game->PlaySound(SFX_WHOOSH);
						for(int i=0; i<64&&!attackCondition; ++i){
							attackCondition = CanAttack(this, eed);
							int step = Lerp(1, 4, i/63);
							// If the enemy is in position, break the movement loop
							if(Distance(this->X, this->Y, targetX, targetY)<step){
								this->X = targetX;
								this->Y = targetY;
								break;
							}
							MoveAtAngle(this, Angle(this->X, this->Y, targetX, targetY), step, AM_NONE);
							Waitframe(this, eed, 1);
						}
						Waitframe(this, eed, 32); //Pause after moving
						// Remove a bit of movement cooldown for making a motion during the movement phase
						eed->MoveCooldown = Max(eed->MoveCooldown-4, 0);
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
					if(eed->OrbitCount<=2){
						if(eed->OrbitCount==0){
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
							aptr->PlayAnim(ANIM_ATTACKING);
							Windup(this, eed);
							Waitframe(this, eed, 16);
							// Offset the weapon angle in a loop to fire a triple shot
							for(int i=-1; i<=1; ++i){
								FireEWeapon(this->X+8, this->Y+8, Angle(this->X+8, this->Y+8, Link->X, Link->Y) + 30*i, 250, this->WeaponDamage);
							}
							Waitframe(this, eed, 16);
							break;
						}
						// ATTACK 1: Move away from Link and shoot a stream of projectiles from the orbits
						case ATTACK_STREAMSHOT: 
						{
							aptr->PlayAnim(ANIM_ATTACKING);
							Windup(this, eed);
							// Move away from Link for 32 frames
							for(int i=0; i<32; ++i){
								MoveTowardLink(this, -1, AM_NONE);
								Waitframe(this, eed, 1);
							}
							// Fire up to 16 bullets depending on how many orbits remain
							for(int i=0; i<16; ++i){
								int j = Rand(4);
								// If it rolled an invalid orbit, try a few more times to find one
								if(!eed->Orbit[j]->isValid()){
									for(int k=0; k<4&&!eed->Orbit[j]->isValid(); ++k)
										j = Rand(4);
								}
								
								// If the orbit is valid, fire a weapon from its position
								if(eed->Orbit[j]->isValid()){
									FireEWeapon(eed->Orbit[j]->X, eed->Orbit[j]->Y, Angle(eed->Orbit[j]->X, eed->Orbit[j]->Y, Link->X, Link->Y), 250, this->WeaponDamage);
								}
								
								Waitframe(this, eed, 6);
							}
							Waitframe(this, eed, 16);
							break;
						}
						// ATTACK 2: Bounce off the walls of the room at a 45 degree angle
						case ATTACK_WALLBOUNCE: 
						{
							aptr->PlayAnim(ANIM_ATTACKING);
							Windup(this, eed);
							// Get X and Y velocities moving away from Link
							int vX = Sign(Link->X - (this->X+8));
							int vY = Sign(Link->Y - (this->Y+8));
							for(int i=0; i<16; ++i){
								MoveXY(this, vX*0.5, vY*0.5, AM_NONE);
								Waitframe(this, eed, 1);
							}
							for(int i=0; i<180; ++i){
								// If about to hit a wall on the X axis, bonk and turn around
								if((vX<0&&!CanMove(this, DIR_LEFT, AM_NONE)) || (vX>0&&!CanMove(this, DIR_RIGHT, AM_NONE))){
									vX = -vX;
									Game->PlaySound(SFX_WALLBONK);
									Waitframe(this, eed, 4);
								}
								// If about to hit a wall on the Y axis, bonk and turn around
								if((vY<0&&!CanMove(this, DIR_UP, AM_NONE)) || (vY>0&&!CanMove(this, DIR_DOWN, AM_NONE))){
									vY = -vY;
									Game->PlaySound(SFX_WALLBONK);
									Waitframe(this, eed, 4);
								}
								MoveXY(this, vX*2.5, vY*2.5, AM_NONE);
								Waitframe(this, eed, 1);
							}
							Waitframe(this, eed, 32);
							break;
						}
						// ATTACK 3: Respawn lost orbits, then approach Link and expand them outwards
						case ATTACK_RESPAWN_ORBITS:
						{
							repeat(3)Windup(this, eed);
							eed->OrbitSpeed = 0;
							// Respawn any lost orbits
							for(int i=0; i<4; ++i){
								if(!eed->Orbit[i]->isValid()){
									Game->PlaySound(SFX_ORBITRESPAWN);
									eed->Orbit[i] = CreateNPCAt(eed->OrbitID, this->X+8, this->Y+8);
								}
								Waitframe(this, eed, 8);
							}
							// Move towards Link
							int ang = Angle(this->X+8, this->Y+8, Link->X, Link->Y);
							eed->OrbitSpeed = 2;
							for(int i=0; i<32; ++i){
								MoveAtAngle(this, ang, 2, AM_NONE);
								Waitframe(this, eed, 1);
							}
							Waitframe(this, eed, 32);
							aptr->PlayAnim(ANIM_ATTACKING);
							// Expand the orbits while spinning faster. 
							// We modify the distance and speed with linear interpolation
							Game->PlaySound(SFX_ORBITSPIN);
							eed->OrbitSpeed = 4;
							for(int i=0; i<32; ++i){
								eed->OrbitDist = Lerp(24, 96, i/31);
								Waitframe(this, eed, 1);
							}
							for(int i=0; i<48; ++i){
								eed->OrbitDist = Lerp(96, 24, i/47);
								eed->OrbitSpeed = Lerp(4, 2, i/47);
								Waitframe(this, eed, 1);
							}
							break;
						}
					}
					
					aptr->PlayAnim(ANIM_NEUTRAL);
					
					eed->AttackCooldown = 64;
					eed->MoveCooldown = 32;
				}
			}
		}
		
		// Play a windup spin animation before attacking
		void Windup(npc this, ExampleEnemyData eed){
			// Start moving at a random angle
			int ang = Rand(360);
			//Quickly turn to make a circle motion
			for(int i=0; i<18; ++i){
				MoveAtAngle(this, ang, 1, AM_NONE);
				ang += 20;
				Waitframe(this, eed, 1);
			}
		}
		
		// A simple function for firing eweapons
		eweapon FireEWeapon(int x, int y, int ang, int step, int damage){
			Game->PlaySound(SFX_SHOOT);
			eweapon e = CreateEWeaponAt(EW_SCRIPT10, x, y);
			e->Angular = true;
			e->Angle = DegtoRad(ang);
			e->Step = step;
			e->Damage = damage;
			e->UseSprite(SPR_BULLET);
			e->Rotation = ang;
			e->Unblockable = UNBLOCK_ALL;
			return e;
		}
		
		// Update the enemy's cooldown clocks and return true if it can attack
		bool CanAttack(npc this, ExampleEnemyData eed){
			// First wait a certain amount after attacking
			if(eed->AttackCooldown>0)
				--eed->AttackCooldown;
			else{
				// If the enemy got hit, reduce its move cooldown
				if(this->InvFrames&&!eed->GotHit){
					eed->MoveCooldown = Max(eed->MoveCooldown-24, 0);
					eed->GotHit = true; // Flag that it got hit
				}
				
				if(eed->MoveCooldown){
					// Decrement move cooldown when near Link
					if(Distance(this->X+8, this->Y+8, Link->X, Link->Y)<80)
						--eed->MoveCooldown;
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
		void UpdateOrbits(npc this, ExampleEnemyData eed, bool spawn, bool draw){
			// Reset the count of living orbits, so we can recount
			eed->OrbitCount = 0;
			for(int i=0; i<4; ++i){
				// Get the angle, x and y position of the orbit
				int ang = WrapDegrees(eed->OrbitAngle+90*i);
				int x = this->X+8+VectorX(eed->OrbitDist, ang);
				int y = this->Y+8+VectorY(eed->OrbitDist*0.5, ang);
				if(eed->Orbit[i]->isValid()){
					//If an orbit is dying, make it visible and remove it from the array 
					if(eed->Orbit[i]->HP<=0){
						eed->Orbit[i]->DrawXOffset = 0;
						eed->Orbit[i] = NULL;
						continue;
					}
					eed->Orbit[i]->X = Clamp(x, -32, 256+16);
					eed->Orbit[i]->Y = Clamp(y, -32, 176+16);
					// This math gets an enemy's flash cset from their knockback timer
					int cset = eed->Orbit[i]->CSet;
					if(eed->Orbit[i]->InvFrames)
						cset = 9-(eed->Orbit[i]->InvFrames>>1);
					// Angles -180-0 should draw behind the main enemy, offset the draw offset 
					// so they show up as invisible and redraw them
					if(draw){
						if(ang<0){
							Screen->FastTile(2, eed->Orbit[i]->X, eed->Orbit[i]->Y, eed->Orbit[i]->Tile, cset, 128);
							eed->Orbit[i]->DrawXOffset = -1000;
						}
						else
							eed->Orbit[i]->DrawXOffset = 0;
					}
					++eed->OrbitCount;
				}
				else if(spawn){
					eed->Orbit[i] = CreateNPCAt(eed->OrbitID, x, y);
					++eed->OrbitCount;
				}
			}
			// Increase the base angle to make the orbits spin
			eed->OrbitAngle = WrapDegrees(eed->OrbitAngle + eed->OrbitSpeed);
		}
		
		// This handles the enemy's death animation and any cleanup that may need to do.
		void DeathAnimation(npc this, ExampleEnemyData eed){
			// Get the enemy's AnimHandler pointer, to access functions that use it
			AnimHandler aptr = GetAnimHandler(this);
			for(int i=0; i<4; ++i){
				// Kill all the valid orbits and make them visible
				if(eed->Orbit[i]->isValid()){
					eed->Orbit[i]->HP = 0;
					eed->Orbit[i]->DrawXOffset = 0;
				}
			}
			// Play the standard explosion death animation.
			// To make your own NPCAnim.zh death animations, look at 
			// PlayDeathAnim() in NPCAnim.zh. Or don't. 
			// It doesn't matter how you handle it as much as it did with ghost. 
			aptr->PlayDeathAnim(false);
		}
		
		// This is a wrapper function for the version of Waitframe() in NPCAnim.zh.
		// It will handle things the enemy does every frame while waiting on the engine.
		// ExampleEnemyData eed is a class instance for storing various things you might want 
		// to keep updated at all times. int frames is the number of frames to wait for
		void Waitframe(npc this, ExampleEnemyData eed, int frames){
			for(int i=0; i<frames; ++i){
				// Reset the hit flag if it's not in iframes
				if(eed->GotHit&&!this->InvFrames)
					eed->GotHit = false;
				UpdateOrbits(this, eed, false, true);
				if(this->HP<=0){
					DeathAnimation(this, eed);
				}
				Waitframe(this);
			}
		}
	}
	
}