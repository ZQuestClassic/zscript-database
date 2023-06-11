namespace IceFloors
{
	void UserOnEnterIce()
	{
		// Things that happen when entering ice go here
	}
	bool UserOnExitIce()
	{
		// Things that happen when exiting ice go here
		// If it returns true, the part that runs jumping velocity is skipped
	}
	bool UserDisableIceMovement()
	{
		// Things that disable ice movement go here
	}
	
	// For setting ice velocity from another script
	// (getting velocity is complicated but hopefully this has some uses)
	void UserSetIceVelocity(int vX, int vY)
	{
		genericdata gd = Game->LoadGenericData(Game->GetGenericScript("IceFloors_Generic"));
		gd->DataSize = IFG_SIZE;
		int id = gd->Data[IFG_DISCRIMINATOR];
		gd->Data[IFG_VX] = vX;
		gd->Data[IFG_VY] = vY;
	}
	
	float IceVX()
	{
		genericdata gd = Game->LoadGenericData(Game->GetGenericScript("IceFloors_Generic"));
		gd->DataSize = IFG_SIZE;
		return gd->Data[IFG_VX];
	}
	
	float IceVY()
	{
		genericdata gd = Game->LoadGenericData(Game->GetGenericScript("IceFloors_Generic"));
		gd->DataSize = IFG_SIZE;
		return gd->Data[IFG_VY];
	}
	
	// Returns true if on ice
	bool OnIce()
	{
		genericdata gd = Game->LoadGenericData(Game->GetGenericScript("IceFloors_Generic"));
		gd->DataSize = IFG_SIZE;
		return gd->Data[IFG_ON_ICE];
	}

	// Defaults for when "Custom Values" is not checked on the combo
	const float ICE_FLOOR_MAX_STEP = 1.5; // Top speed while on ice (1.5 for Link's default)
	const float ICE_FLOOR_START_STEP = 0.5; // Speed when stepping onto an ice combo
	const float ICE_FLOOR_ACCEL = 0.04; // Acceleration, when holding a direction on ice
	const float ICE_FLOOR_DECEL = 0.02; // Deceleration, when not holding a direction on ice

	// Knockback
	const bool ICE_FLOOR_SPECIAL_KNOCKBACK = true; // If true, getting hit will affect ice velocity
	const float ICE_FLOOR_KNOCKBACK_STEP = 1.5; // The speed at which Link is knocked back

	// Jumping behavior
	const bool ICE_FLOOR_AIR_VELOCITY_FORCE_POS = true; // If true, air velocity on ice combos will force Link to move, else it's added to engine movement
	const float ICE_FLOOR_AIR_VELOCITY_MULTIPLIER = 1.0; // Multiplier when converting ice velocity to air velocity
	const float ICE_FLOOR_AIR_VELOCITY_DECEL = 0.02; // Deceleration over time for air velocity

	// Other settings
	const bool ICE_FLOOR_STOP_AT_WALL = true; // If true, Link will lose all acceleration when hitting a wall

	enum IceFloorGenericIndices
	{
		IFG_VX,
		IFG_VY,
		IFG_AIRVX,
		IFG_AIRVY,
		IFG_FLINGX,
		IFG_FLINGY,
		IFG_LAUNCHED,
		IFG_ON_ICE,
		IFG_ON_ICE_INTERNAL, // This one is only valid when ice combos are on the screen
		IFG_DISCRIMINATOR,
		
		IFG_SIZE
	};

	@Flag0("Custom Values"),
	@FlagHelp0("Check to enable custom speed values for this combo"),
	@Flag1("Affect Jump Velocity"),
	@FlagHelp1("Check to make jumping off the combo maintain velocity in the air"),
	@Attribyte0("Discriminator"),
	@AttribyteHelp0("A unique ID used to tell apart two instances of the script on the same screen. \nUse when you have ice combos with different physics used together."),
	@Attribute0("Max Step"),
	@AttributeHelp0("The max step speed while on ice (Link's base step is 1.5)"),
	@Attribute1("Start Step"),
	@AttributeHelp1("The starting step speed when stepping on ice (Link's base step is 1.5)"),
	@Attribute2("Acceleration"),
	@AttributeHelp2("Step speed of accelerating on ice (Link's base step is 1.5)"),
	@Attribute3("Deceleration"),
	@AttributeHelp3("Step speed of decelerating on ice when not pushing a direction (Link's base step is 1.5)")
	combodata script IceFloors
	{
		void run()
		{
			int id = this->Attribytes[0];
			
			mapdata lyr = Game->LoadTempScreen(this->Layer);
			// Only run if this is the first instance of the combo on the layer
			for(int i=0; i<176; ++i)
			{
				combodata cd = Game->LoadComboData(lyr->ComboD[i]);
				// Check based on script and discriminator to see if this is the first
				if(cd->Script==this->Script&&cd->Attribytes[0]==id)
				{
					if(i!=this->Pos)
						Quit();
					else
						break;
				}
			}
			
			genericdata hitEvents;
			// Ice floor knockback uses a generic script to get collision angles, so set that up
			if(ICE_FLOOR_SPECIAL_KNOCKBACK)
			{
				hitEvents = Game->LoadGenericData(Game->GetGenericScript("IceFloors_HitEvents"));
				hitEvents->DataSize = IFHE_SIZE;
				hitEvents->Running = true;
			}
			
			// Also another generic script for handling Link in the air
			genericdata genScript = Game->LoadGenericData(Game->GetGenericScript("IceFloors_Generic"));
			genScript->DataSize = IFG_SIZE;
			genScript->Running = true;
			
			bool customValues = this->Flags[0];
			bool affectJumpVelocity = this->Flags[1];
			
			float maxStep = this->Attributes[0];
			float startStep = this->Attributes[1];
			float accel = this->Attributes[2];
			float decel = this->Attributes[3];
			
			// If values aren't customized, set them to defaults
			if(!customValues)
			{
				maxStep = ICE_FLOOR_MAX_STEP;
				startStep = ICE_FLOOR_START_STEP;
				accel = ICE_FLOOR_ACCEL;
				decel = ICE_FLOOR_DECEL;
			}
			
			int iceX = Link->X;
			int iceY = Link->Y;
			bool wasOnIce = OnIce(this, lyr, id);
			genScript->Data[IFG_ON_ICE_INTERNAL] = OnGlobalIce(this);
						
			while(true)
			{
				PreventScrollBug(genScript->Data[IFG_VX], genScript->Data[IFG_VY]);
				
				// Get X and Y stick inputs
				int iX = (Link->InputLeft?-1:0) + (Link->InputRight?1:0);
				int iY = (Link->InputUp?-1:0) + (Link->InputDown?1:0);
				if(iX!=0&&iY!=0)
				{
					iX *= 0.7071;
					iY *= 0.7071;
				}
				
				if(OnIce(this, lyr, id))
				{
					genScript->Data[IFG_ON_ICE] = true;
					
					// If just entered ice
					if(!wasOnIce)
					{
						UserOnEnterIce();
						genScript->Data[IFG_DISCRIMINATOR] = id;
						
						// Step velocity based on startStep
						// Only when stepping onto ice
						if(!genScript->Data[IFG_ON_ICE_INTERNAL])
						{
							genScript->Data[IFG_VX] = iX * startStep;
							genScript->Data[IFG_VY] = iY * startStep;
						}
						iceX = Link->X;
						iceY = Link->Y;
						
						genScript->Data[IFG_ON_ICE_INTERNAL] = true;
						wasOnIce = true;
					}
					
					if(!InterruptIce()&&!UserDisableIceMovement())
					{
						// Handle special knockback behavior on ice
						if(ICE_FLOOR_SPECIAL_KNOCKBACK)
						{
							if(hitEvents->Data[IFHE_HITFLAG])
							{
								genScript->Data[IFG_VX] = VectorX(ICE_FLOOR_KNOCKBACK_STEP, hitEvents->Data[IFHE_HITANGLE]);
								genScript->Data[IFG_VY] = VectorY(ICE_FLOOR_KNOCKBACK_STEP, hitEvents->Data[IFHE_HITANGLE]);
								// The hit flag is in theory only being read by one combo script isntance
								// per frame, so we can unset it here and wait on the next time Link is hit.
								hitEvents->Data[IFHE_HITFLAG] = false;
							}
						}
						
						if(genScript->Data[IFG_DISCRIMINATOR]==id)
						{
							// Player input (X)
							genScript->Data[IFG_VX] += iX * accel;
							
							// Automatic deceleration (X)
							if(genScript->Data[IFG_VX]<0&&iX==0)
								genScript->Data[IFG_VX] = Decelerate(genScript->Data[IFG_VX], decel);
							if(genScript->Data[IFG_VX]>0&&iX==0)
								genScript->Data[IFG_VX] = Decelerate(genScript->Data[IFG_VX], decel); 
							
							// Y stuff doesn't happen in sideview
							if(!IsSideview())
							{
								// Player input (Y)
								genScript->Data[IFG_VY] += iY * accel;
							
								// Automatic deceleration (Y)
								if(genScript->Data[IFG_VY]<0&&iY==0)
									genScript->Data[IFG_VY] = Decelerate(genScript->Data[IFG_VY], decel);
								if(genScript->Data[IFG_VY]>0&&iY==0)
									genScript->Data[IFG_VY] = Decelerate(genScript->Data[IFG_VY], decel);
							}
						
							genScript->Data[IFG_VX] = Clamp(genScript->Data[IFG_VX], -maxStep, maxStep);
							genScript->Data[IFG_VY] = Clamp(genScript->Data[IFG_VY], -maxStep, maxStep);
							
							Link->MoveXY(genScript->Data[IFG_VX], genScript->Data[IFG_VY]);
							if(ICE_FLOOR_STOP_AT_WALL)
							{
								if(!Link->CanMoveXY(Sign(genScript->Data[IFG_VX]), 0))
									genScript->Data[IFG_VX] = 0;
								if(!Link->CanMoveXY(0, Sign(genScript->Data[IFG_VY])))
									genScript->Data[IFG_VY] = 0;
							}
						}
					}
					
					if(UserDisableIceMovement())
					{
						genScript->Data[IFG_VX] = 0;
						genScript->Data[IFG_VY] = 0;
					}
					
					// Record Link's old position to roll back his engine movement
					iceX = Link->X;
					iceY = Link->Y;
				}
				else
				{
					// Leaving ice
					if(wasOnIce)
					{
						if(!UserOnExitIce())
						{
							if(affectJumpVelocity)
							{
								// Set some data for the generic script to read
								genScript->Data[IFG_LAUNCHED] = true;
								genScript->Data[IFG_FLINGX] = Link->X;
								genScript->Data[IFG_FLINGY] = Link->Y;
								genScript->Data[IFG_AIRVX] = genScript->Data[IFG_VX] * ICE_FLOOR_AIR_VELOCITY_MULTIPLIER;
								genScript->Data[IFG_AIRVY] = genScript->Data[IFG_VY] * ICE_FLOOR_AIR_VELOCITY_MULTIPLIER;
							}
						}
						// It's possible we left this ice combo to a different type of ice, so check
						genScript->Data[IFG_ON_ICE_INTERNAL] = OnGlobalIce(this);
						wasOnIce = false;
					}
				}
				
				Waitdraw();
				
				if(genScript->Data[IFG_DISCRIMINATOR]==id)
				{
					// If on ice, roll back engine movement
					if(wasOnIce)
					{
						if(!UserDisableIceMovement())
						{
							Link->X = iceX;
							if(!IsSideview())
								Link->Y = iceY;
						}
					}
					else
					{
						genScript->Data[IFG_VX] = 0;
						genScript->Data[IFG_VY] = 0;
						iceX = Link->X;
						iceY = Link->Y;
					}
				}
				
				Waitframe();
			}
		}
		// Returns true if Link is on ice with the current script's discriminator
		bool OnIce(combodata this, mapdata lyr, int id)
		{
			if(Link->Falling)
				return false;
			if(Link->Action==LA_DROWNING)
				return false;
			
			// We're checking for two things:
			//  * That Link is not in the air
			//  * That he's on an ice combo with this script's discriminator
			if(!IsSideview())
			{
				if(Link->Z>0||Link->FakeZ>0)
					return false;
				combodata underLink = Game->LoadComboData(lyr->ComboD[ComboAt(Link->X+8, Link->Y+12)]);
				if(underLink->Script==this->Script&&underLink->Attribytes[0]==id)
					return true;
			}
			else
			{
				// If Link is rising or falling in sideview, assume he's not on solid ground
				if(Link->Jump!=0||Link->FakeJump!=0)
					return false;
					
				combodata underLink;
				// Link's position needs to be rounded in case new quest rules are on
				int linkX = Round(Link->X);
				int linkY = Round(Link->Y);
				underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+3, linkY+16)]);
				if(underLink->Script==this->Script&&underLink->Attribytes[0]==id)
					return true;
				underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+15-3, linkY+16)]);
				if(underLink->Script==this->Script&&underLink->Attribytes[0]==id)
					return true;
				underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+8, linkY+16)]);
				if(underLink->Script==this->Script&&underLink->Attribytes[0]==id)
					return true;
			}
			return false;
		}
		// Same as above, but ignores the discriminator
		bool OnGlobalIce(combodata this)
		{
			if(Link->Falling)
				return false;
			if(Link->Action==LA_DROWNING)
				return false;
			
			for(int i=0; i<=2; ++i)
			{
				mapdata lyr = Game->LoadTempScreen(i);
				// We're checking for two things:
				//  * That Link is not in the air
				//  * That he's on an ice combo with this script's discriminator
				if(!IsSideview())
				{
					if(Link->Z>0||Link->FakeZ>0)
						return false;
					combodata underLink = Game->LoadComboData(lyr->ComboD[ComboAt(Link->X+8, Link->Y+12)]);
					if(underLink->Script==this->Script)
						return true;
				}
				else
				{
					// If Link is rising or falling in sideview, assume he's not on solid ground
					if(Link->Jump!=0||Link->FakeJump!=0)
						return false;
						
					combodata underLink;
					// Link's position needs to be rounded in case new quest rules are on
					int linkX = Round(Link->X);
					int linkY = Round(Link->Y);
					underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+3, linkY+16)]);
					if(underLink->Script==this->Script)
						return true;
					underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+15-3, linkY+16)]);
					if(underLink->Script==this->Script)
						return true;
					underLink = Game->LoadComboData(lyr->ComboD[ComboAt(linkX+8, linkY+16)]);
					if(underLink->Script==this->Script)
						return true;
				}
			}
			return false;
		}
		bool InterruptIce()
		{
			// Only allow Link to slide around during approved actions
			switch(Link->Action)
			{
				case LA_NONE:
				case LA_WALKING:
				case LA_ATTACKING:
				case LA_GOTHURTLAND:
				case LA_CHARGING:
				case LA_SPINNING:
					break;
				default:
					return true;
			}
			return false;
		}
		// Decelerates step values towards 0
		float Decelerate(float val, float dec)
		{
			if(val>0)
				return Max(val-Abs(dec), 0);
			else
				return Min(val+Abs(dec), 0);
		}
		// Prevents scrolling the screen against the direction Link is being pushed by the ice
		void PreventScrollBug(int vx, int vy)
		{
			if(vx>0&&Link->X<=Ceiling(Abs(vx)))
				Link->InputLeft = false;
			if(vx<0&&Link->X>=240-Ceiling(Abs(vx)))
				Link->InputRight = false;
			if(vy>0&&Link->Y<=Ceiling(Abs(vy)))
				Link->InputUp = false;
			if(vy<0&&Link->Y>=160-Ceiling(Abs(vy)))
				Link->InputDown = false;
		}
	}

	enum IceFloors_HitEvents_Data
	{
		IFHE_HITFLAG,
		IFHE_HITANGLE,
		
		IFHE_SIZE
	};

	// This script listens for the player hit event and 
	// stores an angle in its data array for the combodata script to read
	generic script IceFloors_HitEvents
	{
		void run()
		{
			this->EventListen[GENSCR_EVENT_HERO_HIT_2] = true;
			while(true)
			{
				switch(WaitEvent())
				{
					case GENSCR_EVENT_HERO_HIT_2:
					{
						// When a collision happens, get the angle from the object
						// and set the hit flag
						switch(Game->EventData[GENEV_HEROHIT_HITTYPE])
						{
							case OBJTYPE_NPC:
							{
								npc n = Game->EventData[GENEV_HEROHIT_HITOBJ];
								int cx = n->X+n->HitXOffset+n->HitWidth/2;
								int cy = n->Y+n->HitYOffset+n->HitHeight/2;
								this->Data[IFHE_HITFLAG] = true;
								this->Data[IFHE_HITANGLE] = Angle(cx, cy, CenterLinkX(), CenterLinkY());
								break;
							}
							case OBJTYPE_EWPN:
							{
								eweapon e = Game->EventData[GENEV_HEROHIT_HITOBJ];
								int cx = e->X+e->HitXOffset+e->HitWidth/2;
								int cy = e->Y+e->HitYOffset+e->HitHeight/2;
								this->Data[IFHE_HITFLAG] = true;
								this->Data[IFHE_HITANGLE] = Angle(cx, cy, CenterLinkX(), CenterLinkY());
								break;
							}
							case OBJTYPE_COMBODATA:
							{
								this->Data[IFHE_HITFLAG] = true;
								// Combos just use the hit direction for their angle, because we have
								// no way to determine where the combo was on screen yet.
								this->Data[IFHE_HITANGLE] = DirAngle(Game->EventData[GENEV_HEROHIT_HITDIR]);
								break;
							}
						}
						break;
					}
				}
			}
		}
	}

	// This script is called by the ice floors to launch Link in the air, potentially across screens
	generic script IceFloors_Generic
	{
		void run()
		{
			while(true)
			{
				// Using FFC timing so it knows when the screen is scrolling
				WaitTo(SCR_TIMING_POST_FFCS);
				
				// Only handle launch logic when actually in the air
				if(this->Data[IFG_LAUNCHED])
				{
					if(InAir())
					{
						IceFloors.PreventScrollBug(this->Data[IFG_AIRVX], this->Data[IFG_AIRVY]);
						
						// Don't move Link during scroll animations...
						if(Link->Action!=LA_SCROLLING)
						{
							// Things that interrupt ice movement will also interrupt this
							if(!IceFloors.InterruptIce())
							{
								this->Data[IFG_AIRVX] = IceFloors.Decelerate(this->Data[IFG_AIRVX], ICE_FLOOR_AIR_VELOCITY_DECEL);
								
								if(!IsSideview())
								{
									this->Data[IFG_AIRVY] = IceFloors.Decelerate(this->Data[IFG_AIRVY], ICE_FLOOR_AIR_VELOCITY_DECEL);
								}
								
								Link->MoveXY(this->Data[IFG_AIRVX], this->Data[IFG_AIRVY]);
								if(ICE_FLOOR_STOP_AT_WALL)
								{
									if(!Link->CanMoveXY(Sign(this->Data[IFG_AIRVX]), 0))
										this->Data[IFG_AIRVX] = 0;
									if(!Link->CanMoveXY(0, Sign(this->Data[IFG_AIRVY])))
										this->Data[IFG_AIRVX] = 0;
								}
								this->Data[IFG_FLINGX] = Link->X;
								this->Data[IFG_FLINGY] = Link->Y;
							}
						}
						// ... but do track his position for when he enters the next screen
						else
						{
							this->Data[IFG_FLINGX] = Link->X;
							this->Data[IFG_FLINGY] = Link->Y;
						}
					}
					else
						this->Data[IFG_LAUNCHED] = false;
				}
				
				// Wait on the passive subscreen script because it runs just before combodata
				WaitTo(SCR_TIMING_POST_DMAPDATA_PASSIVESUBSCREEN);
				
				// Unset the on ice state for the frame
				this->Data[IFG_ON_ICE] = false;
				
				WaitTo(SCR_TIMING_WAITDRAW);
				
				if(this->Data[IFG_LAUNCHED])
				{
					if(InAir())
					{
						// If the setting is enabled, force Link's position
						if(ICE_FLOOR_AIR_VELOCITY_FORCE_POS)
						{
							Link->X = this->Data[IFG_FLINGX];
							if(!IsSideview())
							{
								Link->Y = this->Data[IFG_FLINGY];
								// If unable to scroll off the screen, clamp Link's position to the screen
								if(Game->FFRules[qr_NO_SCROLL_WHILE_IN_AIR])
								{
									Link->X = Clamp(Link->X, 0, 240);
									Link->Y = Clamp(Link->Y, 0, 160);
								}
							}
						}
					}
					// End the launch on touching the ground
					else
						this->Data[IFG_LAUNCHED] = false;
				}
			}
		}
		bool InAir()
		{
			// This prevents infinite falling into pits
			// because of the script continuing to put him 
			// where it thinks he should be
			if(Link->Falling)
				return false;
			if(Link->Action==LA_DROWNING)
				return false;
				
			// Some of this might be redundant tbh. 
			// Link->Standing on its own was not enough 
			// to determine when he was airborne.
			if(!Link->Standing)
				return true;
			if(Link->Jump!=0||Link->FakeJump!=0)
				return true;
			if(!IsSideview())
			{
				if(Link->Z>0||Link->FakeZ>0)
					return true;
			}
			return false;
		}
	}
}