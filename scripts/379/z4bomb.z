import "std.zh"

/*Z4 BOMBS, by Ebola Zaire
	These are bombs, but they allow you to pick them up and throw them after you place them.
	Supports the following features:
		- Throw them around - bombs have """"physics"""" and will bounce off walls and floors!
		- Set a custom 2x2 animation for the explosion - just like in the Game Boy games!
		- Bombs can be configured to change sprites when they're close to detonating!
		- Bombs automatically sink and fizzle in water!  Wow!
		- Bombs can fly over certain combo types/flags even if their solid, enabling more types of puzzles!
		- Toggle between Link's Awakening and Oracle behavior for bomb fuses and throwing!
	Please go through the setup section below, in order, to configure.  
	Also refer to the example tile sheet and quest if you have any questions about graphics and script setup.
	
	REQUIRES: std.zh
*/

/*PRE-COMPILE
	This script uses a function that is handled by the Hero Active script slot.
	If you don't have any Hero Active scripts, you can use the included Hero Active block.
	If you do have an existing Hero Active script, add the line:
		z4bombHeroActive();
	inside the while(true) loop, before Waitframe();.
	
	If you already have std.zh in your scripts, remove it above.
	
	There are two Quest Script Settings that must be ENABLED for this script to work:
		Objects>Sprite Coordinates are Float
		Objects>Weapons Live One Extra Frame With WDS_DEAD
*/

//COMPILE
	//When you compile this script, you have to assign the Item Script, LWeapon Script, EWeapon Script, and Hero Active Script slots.
	//After you do this, change Z4BOMBLWSCRIPTSLOT to the LWeapon Script Slot you assigned to.
	//Then change Z4BOMBEWSCRIPTSLOT to the EWeapon Script slot you assigned to.
	//Then re-compile.
	const int Z4BOMBLWSCRIPTSLOT = 1;
	const int Z4BOMBEWSCRIPTSLOT = 1;

/*ZQUEST SETUP
	After performing the Pre-Compile and Compile steps, create your bomb item.
	The bomb can be any Custom Itemclass.  Do NOT use an existing itemclass, or the default behavior will have weird effects.
	None of its attributes matter - you'll do all settings in-script.
	On the Scripts tab, set its Action Script to z4bombItem.
	Note that you may have to update your subscreen to enable using this item, since it's a custom itemclass.
	By default, the script uses standard bomb ammunition.  Add bombs to its Pickup tab to give the player ammo when they get this.
	Then go through all of the Basic Settings below and follow the instructions.  Remember to re-compile after adjusting settings.
*/

//BASIC SETTINGS
	//BOMB BEHAVIOR
		//In Link's Awakening, Link would always throw a bomb.  In the Oracle games, he would only throw a bomb if he was walking.  Otherwise, he dropped it.
		//Set Z4BOMBORACLETHROW to 0 to use the LA behavior.  Set it to 1 to use the Oracle behavior.
		const int Z4BOMBORACLETHROW = 1;
		
		//In Link's Awakening, bombs would never explode while Link was holding them and the fuse would reset when he threw them.  In the Oracle games, they could explode in his hands.
		//Set Z4BOMBORACLEFUSE to 0 to use the LA behavior.  Set it to 1 to use the Oracle behavior.
		const int Z4BOMBORACLEFUSE = 0;
		
		//You can choose whether to use default engine bomb blasts or custom 2x2 ones.
		//If you use default engine bomb blasts, use the quest rule "Scripted Bomb LWeapons Hurt Link" if you want them to hurt Link.  Note that they do a lot of damage.
		//If you use custom bomb class, you MUST set the sprite data for "Explosion (Normal)" to the first of two blank tiles.  This is a hardcoded limitation.
		//Set Z4BOMBCUSTOMBLAST to 0 to use the default sprite.  Set it to 1 to use a custom animation.
		const int Z4BOMBCUSTOMBLAST = 1;
		
		const int Z4BOMBFUSE = 180;						//Fuse time for bomb (tics).  60 tics makes 1 second.
		const int Z4BOMBDAMAGE = 4;						//Damage to enemies in enemy HP.
		const int Z4BOMBDAMAGESELF = 8;					//Damage to hero in quarter hearts.  If you use the quest rule "Scripted Bomb LWeapons Hurt Link", leave this as 0.
		const int Z4BOMBSAFECOMBOT = CT_LADDERONLY;		//If set, bombs will ignore solidity on combos with this type set.  Use the CT_* constants in std.zh.
		const int Z4BOMBSAFECOMBOF = 103;				//If set, bombs will ignore solidity on combos with this flag set.  This applies to inherent and manual flags.
		
	//BOMB GRAPHICS
		const int Z4BOMBSPRITE = 7;			//Sprite ID of the bomb as it appears on the screen.
		const int Z4BOMBFLASH = 60;			//Time left (tics) when the bomb will switch to another sprite.  You can use a sprite of the bomb flashing, for instance.  Set to 0 to disable.
		const int Z4BOMBSPRITEFLASH = 88;	//Sprite ID of the bomb flashing. Must set Z4BOMBFLASH to enable.
		const int Z4BOMBBLASTSPRITE = 89;	//Sprite ID for top-left corner of 2x2 explosion.  Must set Z4BOMBCUSTOMBLAST to enable.  Use the example tiles for reference on how these are set up.
		const int Z4BOMBBLASTDUR = 30;		//Duration of the custom animation (frames * anim speed - 2).  Must set Z4BOMBCUSTOMBLAST to enable.
		const int Z4BOMBSPLASHTILE = 29916;	//Set to the first of two tiles that form a splash animation centered between them.  Use the example tiles for reference on how these are set up.
		const int Z4BOMBSPLASHCSET = 8;		//CSet for the splash animation.
		const int Z4BOMBSHADOWTILE = 29918;	//Set to a tile ID to use for a shadow.  If set to a blank tile, no shadow will be cast.
		const int Z4BOMBSHADOWCSET = 8;		//CSet for the shadow.

	//DUMMY EQUIPMENT ITEMS
		/*	Create two items in the same class (e.g. Custom Itemclass XX).  Check the Equipment Item box on each.
			Give one a level of 1, with GFX>Link Tile Modification set to turn the hero's graphics into picking up an object.
			Give one a level of 2, with GFX>Link Tile Modification set to turn the hero's graphics into holding over their head.
			(If you are using Zepinho's Power Bracelet script, these must be different items than those, but are set up identically)
			Change Z4BOMBPICKLTM below to the first item's ID.
			Change Z4BOMBHOLDLTM below to the second item's ID.
			
			Then, create another dunny item in the Shield class.  Check the Equipment Item box on it.
			Give it a level of 99 with and a block flag of 0.  You may need to set a Link Tile Modification depending on your setup, but usually you don't.
			Change Z4BOMBSHIELD below to its ID.
			This item is used to turn off any shield blocking while holding the bomb.
			
		*/
		const int Z4BOMBPICKLTM = 143;
		const int Z4BOMBHOLDLTM = 144;
		const int Z4BOMBSHIELD = 145;

	//SOUND EFFECTS
		//Set the following to the correct SFX ID's in your quest.
		//Note that the bomb explosion sound effect is hard-coded as SFX 3.
		const int Z4BOMBPLACESFX = 21;		//SFX ID when bomb is placed normally.
		const int Z4BOMBPICKSFX = 65;		//SFX ID when bomb is picked up.
		const int Z4BOMBBOUNCESFX = 21;		//SFX ID when bomb bounces on the floor.  In the GB games, this was the same as the place SFX.
		const int Z4BOMBTHROWSFX = 66;		//SFX ID when bomb is thrown.
		const int Z4BOMBSPLASHSFX = 67;		//SFX ID when bomb falls in water.

//ADVANCED SETTINGS
	//BOMB GRAPHICS
		/*	After testing, you can change these if needed.
			If the hero seems to hold the bomb too far above their hands, decrease the sprite offset.
			If the hero seems to hold the bomb too far below their hands, increase the sprite offset.
			If the shadow appears below the bomb, decrease the shadow offset.
			If the shadow appears above the bomb, increase the shadow offset.
		*/
		const int Z4BOMBSPRITEOFFSET = 10;
		const int Z4BOMBSHADOWOFFSET = 4;

	//BOMB PHYSICS
		//Only change these if you want to mess with how bombs behave in the air.
		const int Z4BOMBTHROWSPEED = 250;	//Initial throw velocity of bombs.  Increase to throw further.
		const int Z4BOMBTHROWDECEL = 4;		//Deceleration per frame while moving.  Decrease to throw further.
		const int Z4BOMBTHROWBRAKE = 150;	//Amount of speed bomb loses when it hits a wall.  Decrease to make it bounce more.
		const int Z4BOMBTHROWJUMP = 2;		//Amount of upward force when bomb is thrown.  Does not affect distance, just air time.
	
	//BOMB INTERNAL COUNTER/WEAPON TYPES
		//These can be changed if you have other scripts that are conflicting with the weapon types.  Otherwise leave alone.
		const int Z4BOMBCOUNTER = CR_BOMBS;
		const int Z4BOMBLW = LW_SCRIPT10;
		const int Z4BOMBBLASTEW = EW_SCRIPT10;
		

//GLOBAL VARIABLES FOR USE - DO NOT MODIFY
	lweapon Z4BOMBID;
	int Z4BOMB[100];
	const int Z4B_LSTATE = 0;
	const int Z4B_BOUNCE = 1;

hero script heroActiveZ4BombSnip{
	void run() {
		while(true) {
			z4bombHeroActive();
			Waitframe();
		}
	}
}

item script z4bombItem{
	lweapon bombCheck;
	int bombFound;
	void run(){
		bombFound = 0;
		if (!Z4BOMB[Z4B_LSTATE]) {
			for(int i=1;i<=Screen->NumLWeapons();i++){
				bombCheck = Screen->LoadLWeapon(i);
				if(bombCheck->ID == Z4BOMBLW) {
					Z4BOMBID = bombCheck;
					bombFound = 1;
				}
			}
			if (!bombFound) {
				if (Game->Counter[Z4BOMBCOUNTER]) {
					Game->Counter[Z4BOMBCOUNTER]--;
					Z4BOMB_SPAWN();
				}
			}
			else {
				if(LinkCollision(Z4BOMBID) and (!Z4BOMBID->Falling)) {
					Z4BOMB[Z4B_LSTATE] = 1;
				}
			}
		}
	}
}

lweapon script z4bombLWeapon {
	void run() {
		int corner1T;
		int corner1F;
		int corner1I;
		int corner2T;		
		int corner2F;
		int corner2I;
		while(true) {
			//Handle X/Y Movement and Collision
			//Collision is applied to 8x4 (centered horizonally, below center vertically)
			//This is so that it can clip slightly and won't get stuck if hero is against an upper wall
			if (this->Step > 0) {
				switch(this->Dir) {
					//Up movement
					case 0: {
						this->Y -= (this->Step/100);
						//Check screen edge
						if (this->Y <= 0) {
							this->Dir = 1;
							this->Step -= Z4BOMBTHROWBRAKE;
							break;
						}
						
						//Check corner 1
						corner1T = Screen->ComboT[ComboAt(this->X+4,this->Y+8)];
						corner1F = Screen->ComboF[ComboAt(this->X+4,this->Y+8)];
						corner1I = Screen->ComboI[ComboAt(this->X+4,this->Y+8)];
						if((corner1T != Z4BOMBSAFECOMBOT) and (corner1F != Z4BOMBSAFECOMBOF) and (corner1I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+4,this->Y+8)){
								this->Dir = 1;
								this->Step -= Z4BOMBTHROWBRAKE;
								break;
							}
						}
						
						//Check corner 2
						corner2T = Screen->ComboT[ComboAt(this->X+12,this->Y+8)];
						corner2F = Screen->ComboF[ComboAt(this->X+12,this->Y+8)];
						corner2I = Screen->ComboI[ComboAt(this->X+12,this->Y+8)];
						if((corner2T != Z4BOMBSAFECOMBOT) and (corner2F != Z4BOMBSAFECOMBOF) and (corner2I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+12,this->Y+8)){
								this->Dir = 1;
								this->Step -= Z4BOMBTHROWBRAKE;
							}
						}
						
						break;
					}
					//Down movement
					case 1: {
						this->Y += (this->Step/100);
						//Check screen edge
						if (this->Y+16 >= 176) {
							this->Dir = 0;
							this->Step -= Z4BOMBTHROWBRAKE;
							break;
						}
						//Check corner 1
						corner1T = Screen->ComboT[ComboAt(this->X+4,this->Y+12)];
						corner1F = Screen->ComboF[ComboAt(this->X+4,this->Y+12)];
						corner1I = Screen->ComboI[ComboAt(this->X+4,this->Y+12)];
						if((corner1T != Z4BOMBSAFECOMBOT) and (corner1F != Z4BOMBSAFECOMBOF) and (corner1I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+4,this->Y+12)){
								this->Dir = 0;
								this->Step -= Z4BOMBTHROWBRAKE;
								break;
							}
						}
						
						//Check corner 2
						corner2T = Screen->ComboT[ComboAt(this->X+12,this->Y+12)];
						corner2F = Screen->ComboF[ComboAt(this->X+12,this->Y+12)];
						corner2I = Screen->ComboI[ComboAt(this->X+12,this->Y+12)];
						if((corner2T != Z4BOMBSAFECOMBOT) and (corner2F != Z4BOMBSAFECOMBOF) and (corner2I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+12,this->Y+12)){
								this->Dir = 0;
								this->Step -= Z4BOMBTHROWBRAKE;
							}
						}
						break;
					}
					//Left movement
					case 2: {
						this->X -= (this->Step/100);
						//Check screen edge
						if (this->X <= 0) {
							this->Dir = 3;
							this->Step -= Z4BOMBTHROWBRAKE;
							break;
						}
						//Check corner 1
						corner1T = Screen->ComboT[ComboAt(this->X+4,this->Y+8)];
						corner1F = Screen->ComboF[ComboAt(this->X+4,this->Y+8)];
						corner1I = Screen->ComboI[ComboAt(this->X+4,this->Y+8)];
						if((corner1T != Z4BOMBSAFECOMBOT) and (corner1F != Z4BOMBSAFECOMBOF) and (corner1I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+4,this->Y+8)){
								this->Dir = 3;
								this->Step -= Z4BOMBTHROWBRAKE;
								break;
							}
						}
						
						//Check corner 2
						corner2T = Screen->ComboT[ComboAt(this->X+4,this->Y+12)];
						corner2F = Screen->ComboF[ComboAt(this->X+4,this->Y+12)];
						corner2I = Screen->ComboI[ComboAt(this->X+4,this->Y+12)];
						if((corner2T != Z4BOMBSAFECOMBOT) and (corner2F != Z4BOMBSAFECOMBOF) and (corner2I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+4,this->Y+12)){
								this->Dir = 3;
								this->Step -= Z4BOMBTHROWBRAKE;
							}
						}
						break;
					}
					//Right movement
					case 3: {
						this->X += (this->Step/100);
						//Check screen edge
						if (this->X+16 >= 256) {
							this->Dir = 2;
							this->Step -= Z4BOMBTHROWBRAKE;
							break;
						}
						//Check corner 1
						corner1T = Screen->ComboT[ComboAt(this->X+12,this->Y+8)];
						corner1F = Screen->ComboF[ComboAt(this->X+12,this->Y+8)];
						corner1I = Screen->ComboI[ComboAt(this->X+12,this->Y+8)];
						if((corner1T != Z4BOMBSAFECOMBOT) and (corner1F != Z4BOMBSAFECOMBOF) and (corner1I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+12,this->Y+8)){
								this->Dir = 2;
								this->Step -= Z4BOMBTHROWBRAKE;
								break;
							}
						}
						
						//Check corner 2
						corner2T = Screen->ComboT[ComboAt(this->X+12,this->Y+12)];
						corner2F = Screen->ComboF[ComboAt(this->X+12,this->Y+12)];
						corner2I = Screen->ComboI[ComboAt(this->X+12,this->Y+12)];
						if((corner2T != Z4BOMBSAFECOMBOT) and (corner2F != Z4BOMBSAFECOMBOF) and (corner2I != Z4BOMBSAFECOMBOF)) {
							if (Screen->isSolid(this->X+12,this->Y+12)){
								this->Dir = 2;
								this->Step -= Z4BOMBTHROWBRAKE;
							}
						}
						break;
					}
				}
				this->Step -= Z4BOMBTHROWDECEL;
			}
			//Handle water
			if ((this->Z == 0) and (Screen->ComboT[ComboAt(this->X+9,this->Y+9)]==CT_WATER) and !Z4BOMB[Z4B_LSTATE])  {
				Audio->PlaySound(Z4BOMBSPLASHSFX);
				this->DeadState = 6;
				for(int i=1;i<=2;i++){
					Screen->FastTile(1,this->X-8,this->Y-this->Z,Z4BOMBSPLASHTILE,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Screen->FastTile(1,this->X+8,this->Y-this->Z,Z4BOMBSPLASHTILE+1,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Waitframe();
				}
				for(int i=1;i<=2;i++){
					Screen->FastTile(1,this->X-10,this->Y-this->Z,Z4BOMBSPLASHTILE,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Screen->FastTile(1,this->X+10,this->Y-this->Z,Z4BOMBSPLASHTILE+1,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Waitframe();
				}
				for(int i=1;i<=2;i++){
					Screen->FastTile(1,this->X-12,this->Y-this->Z,Z4BOMBSPLASHTILE,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Screen->FastTile(1,this->X+12,this->Y-this->Z,Z4BOMBSPLASHTILE+1,Z4BOMBSPLASHCSET,OP_OPAQUE);
					Waitframe();
				}
				Quit();
			}
			
			//Handle Z Bouncing
			if (Z4BOMB[Z4B_BOUNCE]) {
				if (this->Z == 0) {
					Audio->PlaySound(Z4BOMBBOUNCESFX);
					this->Jump = 0.5*Z4BOMB[Z4B_BOUNCE];
					Z4BOMB[Z4B_BOUNCE]--;
				}
			}
			
			//Draw over if in the air and handle shadow
			//If this is not done, it gets really weird looking when thrown down
			if (this->Z > 2) {
				Screen->FastTile(4,this->X,this->Y-this->Z,this->Tile,this->CSet,OP_OPAQUE);
				Screen->FastTile(1,this->X,this->Y+Z4BOMBSHADOWOFFSET,Z4BOMBSHADOWTILE,Z4BOMBSHADOWCSET,OP_TRANS);
				Screen->FastTile(2,this->X,this->Y+Z4BOMBSHADOWOFFSET,Z4BOMBSHADOWTILE,Z4BOMBSHADOWCSET,OP_TRANS);
				this->DrawStyle = DS_CLOAKED;
			}
			else {
				this->DrawStyle = DS_NORMAL;
			}
			
			//Handle sprite flashing
			if (this->DeadState < Z4BOMBFLASH) {
				this->UseSprite(Z4BOMBSPRITEFLASH);
			}
			else {
				this->UseSprite(Z4BOMBSPRITE);
			}
			

			//Handle explostion
			if (this->DeadState == WDS_DEAD) {
				if (!Z4BOMBCUSTOMBLAST) {
					lweapon real = CreateLWeaponAt(LW_BOMBBLAST, this->X, this->Y);
					real->Damage = Z4BOMBDAMAGE;
					real->Z = this->Z;
				}
				else {
					//Create the enemy-damage/secret-trigger bomb blasts
					lweapon realTL = CreateLWeaponAt(LW_BOMBBLAST, this->X-8, this->Y-8);
						realTL->Z = this->Z;
						realTL->Damage = Z4BOMBDAMAGE;
						realTL->Dir = this->Dir;
					lweapon realTR = CreateLWeaponAt(LW_BOMBBLAST, this->X+8, this->Y-8);
						realTR->Z = this->Z;
						realTR->Damage = Z4BOMBDAMAGE;
						realTR->Dir = this->Dir;
					lweapon realBL = CreateLWeaponAt(LW_BOMBBLAST, this->X-8, this->Y+8);
						realBL->Z = this->Z;
						realBL->Damage = Z4BOMBDAMAGE;
						realBL->Dir = this->Dir;
					lweapon realBR = CreateLWeaponAt(LW_BOMBBLAST, this->X+8, this->Y+8);
						realBR->Z = this->Z;
						realBR->Damage = Z4BOMBDAMAGE;
						realBR->Dir = this->Dir;
					//Create the hero-damaging bomb blasts
					eweapon lomb = CreateEWeaponAt(Z4BOMBBLASTEW, this->X-8, this->Y-8);
						lomb->Z = this->Z;
						lomb->Damage = Z4BOMBDAMAGESELF;
						lomb->Dir = z4bombUnblockableDir(this->Dir);
						//lomb->Level = 1; //This doesn't work
						lomb->DrawStyle = DS_CLOAKED;
						lomb->Extend = 3;
						//Account for off-screen detonations
						if (lomb->X < 0) {
							lomb->HitWidth = 16;
							lomb->TileWidth = 1;
							lomb->X+=16;
						}
						else {lomb->HitWidth = 32; lomb->TileWidth = 2; }
						if (lomb->Y < 0) {
							lomb->HitHeight = 16;
							lomb->TileHeight = 1;
							lomb->Y+=16;
						}
						else {lomb->HitHeight = 32; lomb->TileHeight = 2; }
						lomb->Script = Z4BOMBEWSCRIPTSLOT;
					//Create the visual effect
					eweapon visual = CreateEWeaponAt(Z4BOMBBLASTEW, this->X-8, this->Y-8);
						visual->Z = this->Z;
						visual->CollDetection = false;
						visual->Extend = 3;
						visual->TileWidth = 2;
						visual->TileHeight = 2;
						visual->UseSprite(Z4BOMBBLASTSPRITE);
						visual->DeadState = Z4BOMBBLASTDUR;
						//Account for off-screen detonations
						if (visual->X <0) {
							visual->DrawXOffset = visual->X;
							visual->X = 0;
						}
						if (visual->Y <0) {
							visual->DrawYOffset = visual->Y;
							visual->Y = 0;
						}
				}
			}
			Waitframe();
		}
	}
}

eweapon script z4bombEWeapon {
	void run() {
		int counter = 0;
		while(true) {
			counter++;
			//this->Dir = Hero->Dir;
			if (counter > Z4BOMBBLASTDUR) {
				this->DeadState = WDS_DEAD;
				Quit();
			}
			Waitframe();
		}
	}
}

void z4bombHeroActive() {
	//If bomb doesn't exist, clear LTM items and reset state
	if (!Z4BOMBID->isValid()) {
		Hero->Item[Z4BOMBPICKLTM] = false;
		Hero->Item[Z4BOMBHOLDLTM] = false;	
		Hero->Item[Z4BOMBSHIELD] = false;
		Z4BOMB[Z4B_LSTATE] = 0;
	}
	
	if (Z4BOMB[Z4B_LSTATE]) {
		//If state is 1, play the pickup sound
		if (Z4BOMB[Z4B_LSTATE] == 1) {
			Audio->PlaySound(Z4BOMBPICKSFX);
		}
		
		//If the hero is doing an illegal action, drop the bomb
		if ((Hero->Action != LA_NONE) and (Hero->Action != LA_WALKING) and (Hero->Action != LA_ATTACKING)) {
			Trace(1);
			Z4BOMB[Z4B_LSTATE] = 100;
		}
		
		//If state is between 1 and 8, do the pickup animation and increment
		if (Z4BOMB[Z4B_LSTATE] <= 8) {
			NoAction();
			Hero->Item[Z4BOMBPICKLTM] = true;
			Hero->Item[Z4BOMBSHIELD] = true;
			Z4BOMBID->X = Hero->X + InFrontX(Hero->Dir,8);
			Z4BOMBID->Y = Hero->Y + InFrontY(Hero->Dir,8);
			Z4BOMBID->Z = 1;
			Z4BOMBID->Step = 0;
			Z4BOMBID->MoveFlags[1] = 0;
			Z4BOMB[Z4B_LSTATE] ++;
			if (!Z4BOMBORACLEFUSE) {
				Z4BOMBID->DeadState = Z4BOMBFUSE;
			}
		}
		
		//If the state is 9, hold the bomb and prevent item/sword usage
		else if (Z4BOMB[Z4B_LSTATE] == 9) {
			Hero->Item[Z4BOMBHOLDLTM] = true;
			Hero->Item[Z4BOMBSHIELD] = true;
			Z4BOMBID->X = Hero->X;
			Z4BOMBID->Y = Hero->Y - Z4BOMBSPRITEOFFSET;
			Z4BOMBID->MoveFlags[1] = 0;
			Hero->SwordJinx = 2;
			Hero->ItemJinx = 2;
			if (!Z4BOMBORACLEFUSE) {
				Z4BOMBID->DeadState = Z4BOMBFUSE;
			}
			
			//This handles dropping / throwing the bomb while the hero holds it
			if (Hero->PressA or Hero->PressB) {
				if ((Hero->Action == LA_WALKING) or (!Z4BOMBORACLETHROW)) {
					Hero->Action = LA_ATTACKING;
					Z4BOMB[Z4B_LSTATE] = 101;
				}
				else {
					Hero->Action = LA_ATTACKING;
					Z4BOMB[Z4B_LSTATE] = 100;
				}
			}
		}
		
		//Handles dropping
		if (Z4BOMB[Z4B_LSTATE] == 100) {
			Z4BOMBID->X = Hero->X;
			Z4BOMBID->Y = Hero->Y;
			Z4BOMBID->Z = 14;
			Z4BOMBID->MoveFlags[1] = 1;
			Hero->Item[Z4BOMBPICKLTM] = false;
			Hero->Item[Z4BOMBHOLDLTM] = false;
			Hero->Item[Z4BOMBSHIELD] = false;
			Z4BOMB[Z4B_LSTATE] = 0;
			Z4BOMB[Z4B_BOUNCE] = 1;
		}
		
		//Handles throwing
		if (Z4BOMB[Z4B_LSTATE] == 101) {
			Z4BOMBID->X = Hero->X;
			Z4BOMBID->Y = Hero->Y;
			Z4BOMBID->Z = 12;
			Z4BOMBID->Jump = Z4BOMBTHROWJUMP;
			Z4BOMBID->Dir = Hero->Dir;
			Z4BOMBID->Step = Z4BOMBTHROWSPEED;
			Z4BOMBID->MoveFlags[1] = 1;
			Hero->Item[Z4BOMBPICKLTM] = false;
			Hero->Item[Z4BOMBHOLDLTM] = false;
			Hero->Item[Z4BOMBSHIELD] = false;			
			Audio->PlaySound(Z4BOMBTHROWSFX);
			Z4BOMB[Z4B_LSTATE] = 0;
			Z4BOMB[Z4B_BOUNCE] = 2;
		}
	}
}

lweapon Z4BOMB_SPAWN() {
	lweapon bomb = Screen->CreateLWeapon(Z4BOMBLW);
	bomb->Step = 0;
	bomb->X = Hero->X + InFrontX(Hero->Dir,4);
	bomb->Y = Hero->Y + InFrontY(Hero->Dir,4);
	bomb->UseSprite(Z4BOMBSPRITE);
	bomb->DeadState = Z4BOMBFUSE;
	bomb->MoveFlags[0] = 1;
	bomb->MoveFlags[1] = 1;
	bomb->Dir = Hero->Dir;
	bomb->Script = Z4BOMBLWSCRIPTSLOT;
	Hero->Action = LA_ATTACKING;
	Audio->PlaySound(Z4BOMBPLACESFX);
	return bomb;
}

// Get the unblockable version (8-15) of a direction
//Shamelessly ripped off ghost.zh
int z4bombUnblockableDir(int dir)
{
    if(dir==DIR_UP)
        return 8;
    if(dir==DIR_DOWN)
        return 12;
    if(dir==DIR_LEFT)
        return 14;
    if(dir==DIR_RIGHT)
        return 10;
    if(dir==DIR_LEFTUP)
        return 15;
    if(dir==DIR_RIGHTUP)
        return 9;
    if(dir==DIR_LEFTDOWN)
        return 13;
    if(dir==DIR_RIGHTDOWN)
        return 11;
    
    // Should never get here
    return dir;
}