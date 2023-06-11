namespace PegasusBoots
{	
	bool UserInterruptDash()
	{
		// Extra things that interrupt the dash go here
	}
	
	bool UserDisableDash()
	{
		// Things that should disable the dash go here
		return UserInterruptDash(); // Things that interrupt the dash should also probably disable it
	}
	
	float UserModifyDashSpeed(int oldspeed)
	{
		// Any special logic here for changing dash speed based on other scripts
		return oldspeed;
	}
	
	bool UserEndDash(int dir, int speed)
	{
		// Special dash handling goes here. Return true if it should replace the normal halting period
		return false;
	}
	
	bool IsDashing()
	{
		genericdata gd = Game->LoadGenericData(Game->GetGenericScript("PegasusBoots_Generic"));
		return gd->Data[DDI_CURRENTLYDASHING];
	}
	
	// Dash tiles
	const int TIL_LINK_DASHFRAMES = 33260;
	
	const int ASPEED_DASH1 = 2; // A.Speed for dash windup
	const int ASPEED_DASH2 = 3; // A.Speed for dash
	
	// SFX
	const int SFX_DASH = 0;
	const int SFX_DASH_BOUNCE = 0;
	
	const int FREQ_SFX_DASH_WINDUP = 6;
	const int FREQ_SFX_DASH = 8;
	
	// Sprites
	const int SPR_DASH_DUST = 0; // Sprite for dust particles trailing behind Link
	const int FREQ_DASH_DUST = 8;
	const int STEP_DASH_DUST = 50; // The particles move away from Link slightly with this step
	
	// Bouncing
	const int DASH_BOUNCE_JUMP = 1.2; // Height when bouncing off a wall
	
	// Speed settings
	const float DASH_BASE_SPEED = 0.0; // Speed at the start of the dash
	const float DASH_TOP_SPEED = 4.0; // Speed at the end of the dash
	const int DASH_BOUNCE_SPEED = 1.0; // Speed when bouncing off a wall
	const float DASH_STEERING_MULTIPLIER = 0.25; // Multiplier for strafing while dashing
	const float DASH_COLLISION_MULTIPLIER = 1.0; // Multiplier for dampening speed when dashing through crystals (1.0 is disabled)

	// Durations
	const int DASH_WINDUP_FRAMES = 16; // Frames before Link starts moving
	const int DASH_ACCEL_FRAMES = 32; // Frames to reach top speed
	const int DASH_HALT_FRAMES = 16; // Frames to reach a stop after letting go
	const int DASH_COLLISION_FRAMES = 4; // Frames Link's speed is changed after a collision
	const int DASH_COLLISION_FRAMES2 = 8; // Frames it takes for his speed to return to normal after

	// Fake sword settings
	const bool DASH_ENABLE_SWORD = true; // If true, can hold the sword during the dash
	const bool DASH_REQUIRE_SWORD_EQUIPPED = true; // If true, the sword has to be equipped to a button in order to use it with the dash
	
	const int FAKESWORD_DIST = 12; // Distance from Link the sword extends
	const int FAKESWORD_OFFSET_UPDOWN = 4; // Distance to the left/right of Link the sword is offset when facing up/down
	const int FAKESWORD_OFFSET_LEFTRIGHT = 2; // Distance down from Link the sword is offset when facing left/right

	const int LW_FAKESWORD = LW_SCRIPT10;
	
	// Misc dash settings
	const bool DASH_USES_LTM = false; // If true, Link's tile modifiers get added to the dash tiles
	const bool DASH_LOWERS_SHIELD = false; // If true, dashing puts Link in the "attacking" state
	const bool DASH_CAN_SIDE_SMASH = true; // If true, dashing into crystals from the side can still break them
	const bool DASH_ALLOW_FEATHER = true; // If true, the feather can still be used while dashing
	
	enum DashDataIndices
	{
		DDI_ITEMLAUNCHED,
		DDI_CURRENTLYDASHING,
		
		DDI_SIZE
	};
	
	enum DashStates
	{
		DST_WINDUP,
		DST_DASHING,
		DST_BOUNCE,
		DST_DASHTHROUGH
	};
	
	enum FrameCountIdx
	{
		FCI_ANIMTIMER,
		FCI_ANIMFRAME,
		FCI_SFXTIMER,
		FCI_SPRITETIMER
	};
	
	enum DashCollision
	{
		DC_COLLIDEDCRYSTAL,
		DC_FORCEBOUNCE
	};
		
		
	itemdata script PegasusBoots
	{
		void run()
		{
			if(IsSideview()&&Link->Dir<DIR_LEFT)
				Quit();
			if(UserDisableDash())
				Quit();
			// Because of timing issues, most of this item runs through a generic script
			genericdata gd = Game->LoadGenericData(Game->GetGenericScript("PegasusBoots_Generic"));
			gd->Data[DDI_ITEMLAUNCHED] = true;
			gd->InitD[0] = this->ID;
			gd->Running = true;
		}
	}
	
	generic script PegasusBoots_Generic
	{
		void run(int itemID)
		{
			this->DataSize = DDI_SIZE;
			
			// The script reloads on F6 so it knows to quit at those times
			// If it was started by anything but the item script, it'll quit
			this->ReloadState[GENSCR_ST_RELOAD] = true;
			this->ReloadState[GENSCR_ST_CONTINUE] = true;
			
			Link->ScriptTile = 0;
			// Quit if not launched by the item
			if(!this->Data[DDI_ITEMLAUNCHED])
			{
				this->Data[DDI_CURRENTLYDASHING] = false;
				Quit();
			}
			// And turn off the flag for next time
			this->Data[DDI_ITEMLAUNCHED] = false;
			
			int frameCount[4];
			int dashState = DST_WINDUP;
			int dashTimer = DASH_WINDUP_FRAMES;
			int dashDampenTimer;
			
			int dashDir = Link->Dir;
			float dashSpeed = DASH_BASE_SPEED;
			
			int swordID = GetSwordID();
			// We're loading a script slot here to know how to identify PegasusCrystal combos
			// All the actual logic is in this script
			int crystalSlot = Game->GetComboScript("PegasusCrystal");
			
			WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE);
			// ReleaseTimer is a janky workaround to an issue with Link inputs and scrolling
			// Because scrolling stops input polling, we need to give some 
			// leeway for letting go of the button. This way the frame when scroll begins 
			// won't count as the dash ending
			int releaseTimer;
			if(UsingItem(itemID))
				releaseTimer = 2;
			while((releaseTimer||Game->Scrolling[SCROLL_DIR]!=-1||dashState==DST_BOUNCE)&&!InterruptDash())
			{
				if(!UsingItem(itemID)&&Game->Scrolling[SCROLL_DIR]==-1)
					--releaseTimer;
				else
					releaseTimer = 2;
					
				// Update the dashing animation
				// This also plays sounds and creates dust sprites
				switch(dashState)
				{
					case DST_WINDUP:
						UpdateAnim(frameCount, ASPEED_DASH1, FREQ_SFX_DASH_WINDUP);
						break;
					case DST_DASHING:
						UpdateAnim(frameCount, ASPEED_DASH2, FREQ_SFX_DASH);
						break;
					case DST_BOUNCE:
						UpdateAnim(frameCount, ASPEED_DASH2, 0);
						break;
				}
				
				//Movement logic. Doesn't happen during scrolling.
				if(Game->Scrolling[SCROLL_DIR]==-1)
				{
					switch(dashState)
					{
						// Windup just has Link stand in place for a bit while animating
						case DST_WINDUP:
						{
							if(dashTimer)
								--dashTimer;
							else
							{
								this->Data[DDI_CURRENTLYDASHING] = true;
								dashState = DST_DASHING;
								dashTimer = DASH_ACCEL_FRAMES;
							}
							break;
						}
						// The part where he actually moves forward
						case DST_DASHING:
						{
							dashSpeed = Lerp(DASH_TOP_SPEED, DASH_BASE_SPEED, dashTimer/DASH_ACCEL_FRAMES);
							// Dampen speed after hitting a crystal
							if(dashDampenTimer)
							{
								if(dashDampenTimer<DASH_COLLISION_FRAMES2)
									dashSpeed *= Lerp(1.0, DASH_COLLISION_MULTIPLIER, dashDampenTimer/DASH_COLLISION_FRAMES2);
								else
									dashSpeed *= DASH_COLLISION_MULTIPLIER;
								--dashDampenTimer;
							}
							dashSpeed = UserModifyDashSpeed(dashSpeed);
							Link->MoveXY(DirX(dashDir)*dashSpeed, DirY(dashDir)*dashSpeed);
							if(DASH_STEERING_MULTIPLIER)
							{
								if(dashDir<DIR_LEFT)
								{
									Link->MoveXY(((Link->InputLeft?-1:0)+(Link->InputRight?1:0)) * dashSpeed * DASH_STEERING_MULTIPLIER, 0);
								}
								else
								{
									Link->MoveXY(0, ((Link->InputUp?-1:0)+(Link->InputDown?1:0)) * dashSpeed * DASH_STEERING_MULTIPLIER);
								}
							}
							if(dashTimer)
								--dashTimer;
								
							untyped collData[2];
							if(!CanDash(Round(Link->X), Round(Link->Y), dashDir, crystalSlot, collData)||collData[DC_FORCEBOUNCE])
							{
								int collideX = Link->X;
								int collideY = Link->Y;
								if(!collData[DC_FORCEBOUNCE])
								{
									// Try moving Link to see if he can slip around a corner. Only bonk if he can't
									for(int i=0; i<4; ++i)
									{
										Link->MoveXY(DirX(dashDir), DirY(dashDir));
									}
								}
								if(collData[DC_FORCEBOUNCE]||!CanDash(Round(Link->X), Round(Link->Y), dashDir, crystalSlot, collData))
								{
									this->Data[DDI_CURRENTLYDASHING] = false;
									dashState = DST_BOUNCE;
									Link->Jump = DASH_BOUNCE_JUMP;
									Game->PlaySound(SFX_DASH_BOUNCE);
								}
								Link->X = collideX;
								Link->Y = collideY;
							}
							if(collData[DC_COLLIDEDCRYSTAL])
								dashDampenTimer = DASH_COLLISION_FRAMES + DASH_COLLISION_FRAMES2;
							
							break;
						}
						// And the part where he bonks into a wall
						case DST_BOUNCE:
						{
							if(Link->Jump>0||Link->Z>0)
							{
								Link->MoveXY(-DirX(dashDir)*DASH_BOUNCE_SPEED, -DirY(dashDir)*DASH_BOUNCE_SPEED);
								NoAction();
							}
							else
							{
								// When the bounce ends, restore Link's tile and end the script
								Link->ScriptTile = 0;
								Quit();
							}
							break;
						}
					}
					
					if(DASH_LOWERS_SHIELD)
					{
						// To make Link lower his shield, we use a janky method of 
						// switching in and out of the attacking state
						if(!Link->Falling&&!Link->Drowning&&(Link->Action!=LA_FALLING&&Link->Action!=LA_DROWNING))
						{
							Link->Action = LA_NONE;
							Link->Action = LA_ATTACKING;
							// Because the attacking state disables feather, we need a workaround to use it
							TryImitateFeather();
						}
					}
					else
					{
						NoActionPegasus();
					}
				}
					
				WaitTo(SCR_TIMING_POST_GLOBAL_WAITDRAW);
				
				// Setting direction stops drowning for some reason
				if(Link->Action!=LA_FALLING&&Link->Action!=LA_DROWNING)
					Link->Dir = dashDir;
					
				// Draw swords post waitdraw so their positions during scrolling are more accurate
				switch(dashState)
				{
					case DST_WINDUP:
						DrawSword(swordID, true);
						break;
					case DST_DASHING:
						DrawSword(swordID, false);
						break;
					case DST_BOUNCE:
						DrawSword(swordID, true);
						break;
				}
				
				WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE);
			}
			this->Data[DDI_CURRENTLYDASHING] = false;
			// This is a short skid animation at the end of the dash
			if(!UserEndDash(dashDir, dashSpeed))
			{
				for(int i=0; i<DASH_HALT_FRAMES&&!UserInterruptDash()&&Link->Action!=LA_DROWNING&&!Link->Falling; ++i)
				{
					UpdateAnim(frameCount, ASPEED_DASH2, FREQ_SFX_DASH);
					Link->MoveXY(DirX(dashDir)*Lerp(dashSpeed, 0, i/DASH_HALT_FRAMES), DirY(dashDir)*Lerp(dashSpeed, 0, i/DASH_HALT_FRAMES));
					WaitTo(SCR_TIMING_POST_GLOBAL_WAITDRAW);
					WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE);
				}
			}
			// Always revert ScriptTile when the script ends
			Link->ScriptTile = 0;
		}
		void UpdateAnim(int frameCount, int aspeed, int dashfreq)
		{
			// Animation frame count. Will always go for 4 frames of animation, one of which is recycled
			++frameCount[FCI_ANIMTIMER];
			if(frameCount[FCI_ANIMTIMER]>aspeed)
			{
				frameCount[FCI_ANIMTIMER] = FCI_ANIMTIMER;
				++frameCount[FCI_ANIMFRAME];
				frameCount[FCI_ANIMFRAME] %= 4;
			}
			
			// Here we handle the recycled animation frame
			int til = TIL_LINK_DASHFRAMES+3*Link->Dir;
			switch(frameCount[FCI_ANIMFRAME])
			{
				case 1:
					til += 1;
					break;
				case 3:
					til += 2;
					break;
			}
			// Add Link tile modifiers if needed
			if(DASH_USES_LTM)
			{
				til += Link->TileMod;
			}
			
			Link->ScriptTile = til;
			
			// Frame counter for SFX
			if(dashfreq)
			{
				if(frameCount[FCI_SFXTIMER]==0)
				{
					Game->PlaySound(SFX_DASH);
				}
				++frameCount[FCI_SFXTIMER];
				frameCount[FCI_SFXTIMER] %= dashfreq;
			}
			
			// And for sprites
			if(frameCount[FCI_SPRITETIMER]==0&&Game->Scrolling[SCROLL_DIR]==-1)
			{
				bool onGround;
				// Don't create dust if not on the ground
				if(IsSideview())
					onGround = Link->Standing&&Link->Jump==0&&Link->FakeJump==0;
				else
					onGround = Link->Z==0&&Link->FakeZ==0;
				if(onGround)
				{
					lweapon dust = CreateLWeaponAt(LW_SPARKLE, Link->X+Rand(-6, 6), Link->Y+8+Rand(-4, 4));
					dust->UseSprite(SPR_DASH_DUST);
					dust->CollDetection = false;
					dust->Dir = OppositeDir(Link->Dir);
					dust->Step = STEP_DASH_DUST;
				}
			}
			++frameCount[FCI_SPRITETIMER];
			frameCount[FCI_SPRITETIMER] %= FREQ_DASH_DUST;
		}
		bool InterruptDash()
		{
			if(Link->Falling)
				return true;
			if(UserInterruptDash())
				return true;
			// This is just a set of actions during which Link is able to keep dashing
			// All others will end the dash early
			switch(Link->Action)
			{
				case LA_NONE:
				case LA_WALKING:
				case LA_SCROLLING:
				case LA_ATTACKING:
					return false;
			}
			return true;
		}
		int GetSwordID()
		{
			int highestLevel = -1;
			int highestID = -1;
			// This finds the highest level sword in Link's inventory
			// It will then be used to get tiles and damage values for the fake one
			for(int i=0; i<256; ++i)
			{
				if(Link->Item[i])
				{
					itemdata id = Game->LoadItemData(i);
					if(id->Type==IC_SWORD)
					{
						if(id->Level>=highestLevel)
						{
							highestID = i;
							highestLevel = id->Level;
						}
					}
				}
			}
			return highestID;
		}
		void DrawSword(int swordID, bool nocoll)
		{
			// Sword disabled
			if(!DASH_ENABLE_SWORD)
				return;
			// No sword item
			if(swordID==-1)
				return;
			if(DASH_REQUIRE_SWORD_EQUIPPED)
			{
				// If sword must be equipped on the button
				if(Link->ItemA!=swordID&&Link->ItemB!=swordID&&Link->ItemX!=swordID&&Link->ItemY!=swordID)
					return;
			}
			itemdata id = Game->LoadItemData(swordID);
			int damage = id->Power * 2;
			spritedata sd = Game->LoadSpriteData(id->Sprites[0]);
			int til = sd->Tile;
			int cs = sd->CSet;
			int x = Link->X+Link->DrawXOffset;
			int y = Link->Y+Link->DrawYOffset-Link->Z-Link->FakeZ;
			// Offset the sword for scrolling transitions
			if(Game->Scrolling[SCROLL_DIR]>-1)
			{
				x += Game->Scrolling[SCROLL_NX];
				y += Game->Scrolling[SCROLL_NY];
			}
			int flip = 0;
			int lyr = SPLAYER_PLAYER_DRAW;
			switch(Link->Dir)
			{
				case DIR_UP:
					x -= FAKESWORD_OFFSET_UPDOWN;
					y -= FAKESWORD_DIST;
					lyr = SPLAYER_PUSHBLOCK;
					// For whatever reason the push block layer doesn't draw during scrolling
					if(Game->Scrolling[SCROLL_DIR]!=-1)
					{
						lyr = IsBackgroundLayer(2)?1:2;
					}
					break;
				case DIR_DOWN:
					x += FAKESWORD_OFFSET_UPDOWN;
					y += FAKESWORD_DIST;
					flip = 2;
					break;
				case DIR_LEFT:
					x -= FAKESWORD_DIST;
					y += FAKESWORD_OFFSET_LEFTRIGHT;
					++til;
					flip = 1;
					break;
				case DIR_RIGHT:
					x += FAKESWORD_DIST;
					y += FAKESWORD_OFFSET_LEFTRIGHT;
					++til;
					break;
			}
			Screen->DrawTile(lyr, x, y, til, 1, 1, cs, -1, -1, 0, 0, 0, flip, true, 128);
			if(!nocoll&&Game->Scrolling[SCROLL_DIR]==-1)
			{
				lweapon hitbox = FireLWeaponDir(LW_FAKESWORD, x, y, Link->Dir, 0, damage);
				hitbox->Timeout = 2;
				hitbox->Weapon = LW_SWORD;
				hitbox->DrawYOffset = -1000;
			}
		}
		bool CanDash(int x, int y, int dir, int crystalSlot, untyped collData)
		{
			bool ret = true;
			int ht = 8;
			if(Game->FFRules[qr_LTTPCOLLISION])
				ht = 0;
			switch(dir)
			{
				case DIR_UP:
					for(int i=0; i<=15; i=Min(i+8, 15))
					{
						if(!CanDashPixel(x+i, y+ht-1, crystalSlot, collData))
							ret = false;
						if(i==15)
							break;
					}
					// Break crystals from the side when able to steer dash
					if(DASH_CAN_SIDE_SMASH)
					{
						// We're using these for their secondary effects, not return value
						if(Link->InputLeft)
							CanDashPixel(x-1, y+ht, crystalSlot, collData);
						if(Link->InputRight)
							CanDashPixel(x+16, y+ht, crystalSlot, collData);
					}
					break;
				case DIR_DOWN:
					for(int i=0; i<=15; i=Min(i+8, 15))
					{
						if(!CanDashPixel(x+i, y+16, crystalSlot, collData))
							ret = false;
						if(i==15)
							break;
					}
					// Break crystals from the side when able to steer dash
					if(DASH_CAN_SIDE_SMASH)
					{
						// We're using these for their secondary effects, not return value
						if(Link->InputLeft)
							CanDashPixel(x-1, y+15, crystalSlot, collData);
						if(Link->InputRight)
							CanDashPixel(x+16, y+15, crystalSlot, collData);
					}
					break;
				case DIR_LEFT:
					for(int i=ht; i<=15; i=Min(i+8, 15))
					{
						if(!CanDashPixel(x-1, y+i, crystalSlot, collData))
							ret = false;
						if(i==15)
							break;
					}
					// Break crystals from the side when able to steer dash
					if(DASH_CAN_SIDE_SMASH)
					{
						// We're using these for their secondary effects, not return value
						if(Link->InputUp)
							CanDashPixel(x, y+ht-1, crystalSlot, collData);
						if(Link->InputDown)
							CanDashPixel(x, y+16, crystalSlot, collData);
					}
					break;
				case DIR_RIGHT:
					for(int i=ht; i<=15; i=Min(i+8, 15))
					{
						if(!CanDashPixel(x+16, y+i, crystalSlot, collData))
							ret = false;
						if(i==15)
							break;
					}
					// Break crystals from the side when able to steer dash
					if(DASH_CAN_SIDE_SMASH)
					{
						// We're using these for their secondary effects, not return value
						if(Link->InputUp)
							CanDashPixel(x+15, y+ht-1, crystalSlot, collData);
						if(Link->InputDown)
							CanDashPixel(x+15, y+16, crystalSlot, collData);
					}
					break;
			}
			return ret;
		}
		bool CanDashPixel(int x, int y, int crystalSlot, untyped collData)
		{
			int pos = ComboAt(x, y);
			for(int i=0; i<2; ++i)
			{
				mapdata md = Game->LoadTempScreen(i);
				switch(md->ComboT[pos])
				{
					case CT_SLASH:
					case CT_SLASHITEM:
					case CT_BUSH:
					case CT_FLOWERS:
					case CT_SLASHNEXT:
					case CT_SLASHNEXTITEM:
					case CT_BUSHNEXT:
					case CT_SLASHC:
					case CT_SLASHITEMC:
					case CT_BUSHC:
					case CT_FLOWERSC:
					case CT_TALLGRASSC:
					case CT_SLASHNEXTC:
					case CT_SLASHNEXTITEMC:
					case CT_BUSHNEXTC:
						return true;
						break;
				}
				combodata cd = Game->LoadComboData(md->ComboD[pos]);
				if(cd->Script==crystalSlot)
				{
					BreakCrystal(md, pos, cd);
					collData[DC_COLLIDEDCRYSTAL] = true;
					// Don't let Link through if "bonk" is checked
					if(cd->Flags[0])
						collData[DC_FORCEBOUNCE] = true;
					return true;
						
				}
			}
			return !Screen->isSolid(x, y);
		}
		void BreakCrystal(mapdata md, int pos, combodata cd)
		{
			int advanceCount = Max(1, cd->Attrishorts[0]);
			int blockwidth = Max(1, cd->Attribytes[4]);
			int blockheight = Max(1, cd->Attribytes[5]);
			bool largeBlock;
			// If this is a large combo block, move pos to the top-left corner
			if(blockwidth>0||blockheight>0)
			{
				pos -= cd->Attribytes[6];
				pos -= 16*cd->Attribytes[7];
				largeBlock = true;
			}
			if(cd->Attribytes[0])
			{
				lweapon smash = CreateLWeaponAt(LW_SPARKLE, ComboX(pos), ComboY(pos));
				smash->UseSprite(cd->Attribytes[0]);
				smash->CollDetection = false;
				smash->Extend = EXT_NORMAL;
				smash->TileWidth = Max(1, cd->Attribytes[1]);
				smash->TileHeight = Max(1, cd->Attribytes[2]);
				// Center the sprite based on its size
				smash->X -= (8*smash->TileWidth)-8;
				smash->Y -= (8*smash->TileHeight)-8;
				// If part of a larger tile block, center the sprite on the block's center
				smash->X += (8*blockwidth)-8;
				smash->Y += (8*blockheight)-8;
			}
			if(cd->Attribytes[3])
			{
				Game->PlaySound(cd->Attribytes[3]);
			}
			if(largeBlock)
			{
				// For large blocks, multiple combos need to be advanced at once when hit
				// The top left corner is used as the point of reference for this and 
				// all other combos point to it
				for(int x=0; x<blockwidth; ++x)
				{
					for(int y=0; y<blockheight; ++y)
					{
						md->ComboD[pos+x+y*16] += advanceCount;
					}
				}
			}
			else
				md->ComboD[pos] += advanceCount;
		}
		void NoActionPegasus()
		{
			// This is a special version of NoAction() that doesn't stop the feather from being used
			if(DASH_ALLOW_FEATHER)
			{
				if(Link->ItemA>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemA);
					if(id->Type!=IC_ROCS)
					{
						Link->InputA = false; Link->PressA = false;
					}
				}
				if(Link->ItemB>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemB);
					if(id->Type!=IC_ROCS)
					{
						Link->InputB = false; Link->PressB = false;
					}
				}
				if(Link->ItemX>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemX);
					if(id->Type!=IC_ROCS)
					{
						Link->InputEx1 = false; Link->PressEx1 = false;
					}
				}
				if(Link->ItemY>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemY);
					if(id->Type!=IC_ROCS)
					{
						Link->InputEx2 = false; Link->PressEx2 = false;
					}
				}
			}
			else
			{
				Link->InputA = false; Link->PressA = false;
				Link->InputB = false; Link->PressB = false;
				Link->InputEx1 = false; Link->PressEx1 = false;
				Link->InputEx2 = false; Link->PressEx2 = false;
			}
			Link->InputL = false; Link->PressL = false;
			Link->InputR = false; Link->PressR = false;
			Link->InputUp = false; Link->PressUp = false;
			Link->InputDown = false; Link->PressDown = false;
			Link->InputLeft = false; Link->PressLeft = false;
			Link->InputRight = false; Link->PressRight = false;
		}
		void TryImitateFeather()
		{
			// Like the above, but this one does a jump if the feather is used
			if(DASH_ALLOW_FEATHER)
			{
				int usingFeather = -1;
				if(Link->PressA&&Link->ItemA>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemA);
					if(id->Type==IC_ROCS)
						usingFeather = id->ID;
				}
				if(Link->PressB&&Link->ItemB>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemB);
					if(id->Type==IC_ROCS)
						usingFeather = id->ID;
				}
				if(Link->PressEx1&&Link->ItemX>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemX);
					if(id->Type==IC_ROCS)
						usingFeather = id->ID;
				}
				if(Link->PressEx2&&Link->ItemY>=0)
				{
					itemdata id = Game->LoadItemData(Link->ItemY);
					if(id->Type==IC_ROCS)
						usingFeather = id->ID;
				}
				if(usingFeather>-1)
				{
					if(Link->Standing)
					{
						itemdata id = Game->LoadItemData(usingFeather);
						Game->PlaySound(id->UseSound);
						Link->Jump = (id->Power+2)*0.8;
						Link->Action = LA_NONE;
					}
				}
			}
			
		}
	}
	
	@Flag0("Bonk"),
	@FlagHelp0("Link bonks off the combo after colliding"),
	@Attribyte0("Shatter Sprite"),
	@AttribyteHelp0("The sprite to draw when the combo breaks. 0 for none"),
	@Attribyte1("Sprite W"),
	@AttribyteHelp1("The tile width of the sprite"),
	@Attribyte2("Sprite H"),
	@AttribyteHelp2("The tile height of the sprite"),
	@Attribyte3("Shatter SFX"),
	@AttribyteHelp3("The sound when the combo breaks"),
	@Attribyte4("Block W"),
	@AttribyteHelp4("If this is part of a larger breakable object, this is the tile width of the object"),
	@Attribyte5("Block H"),
	@AttribyteHelp5("If this is part of a larger breakable object, this is the tile height of the object"),
	@Attribyte6("Core X Off"),
	@AttribyteHelp6("If this is part of a larger breakable object, this is the X position relative to the upper-left corner"),
	@Attribyte7("Core Y Off"),
	@AttribyteHelp7("If this is part of a larger breakable object, this is the Y position relative to the upper-left corner"),
	@Attrishort0("Skip Amount"),
	@AttrishortHelp0("The number of combos to advance by in the list when broken")
	combodata script PegasusCrystal
	{
		void run()
		{
			while(true)
			{
				// This script is just used to flag combos that can be broken by the pegasus boots
				Waitframe();
			}
		}
	}
}