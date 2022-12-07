import "std.zh"
import "string.zh"

global script Active{
	void run(){
		StartGhostZH();
		while(true){
			UpdateGhostZH1();
			Waitdraw();
			UpdateGhostZH2();
			Waitframe();
		}
	}
}

const int TRAP_SPRITE = 90;// Blank sprite used by trap Eweapon.

// Set Vx and Vy to positive numbers to avoid unintended behavior.
// If placed at greatest X, will start going left, otherwise going right. If placed at bottom of screen will start going up, otherwise down.
//D0 - One for horizontal.
//     Two for vertical movement. Either one or two can be used for diagonal movement,
//     Three is a horizontal stationary trap. Set initial Vx and Vy to zero.
//     Four is a vertical stationary trap. Set initial Vx and Vy to zero.
//     Five is a circular trap. Set Vx to positive for clockwise movement and negative for counterclockwise.
//     Place circular trap at location that will serve as the center of the circle, then set radius.
//     Circular traps will bounce off solid objects and can get stuck if not placed correctly.
//D1 - Least X position
//D2 - Greatest X position
//D3 - Least Y position
//D4 - Greatest Y position
//D5 - How much damage you take. Defaults to one-qaurter heart.
//D6 - Radius of circle. Used in creating traps with circular movement.

ffc script ScriptTraps{
    void run(int direction, int leftX, int rightX, int bottomY, int topY, int damage, float radius){
        bool MovingLeft = false;
        bool MovingRight = false;
        bool MovingUp = false;
        float angle;
        bool MovingDown = false;
        float SpeedX = this->Vx;
        float SpeedY = this->Vy;
        int height = this->TileHeight;
        int width = this->TileWidth;
        int OrigX = this->X;
        int OrigY = this->Y;
        int EndX = this->X + (16 * width);
        int EndY = this->Y + (16 * height);
		if (damage <=4) damage = 4;
		eweapon trap;
		trap = FireBigEWeapon(EW_SCRIPT1, this->X, this->Y, DegtoRad(0), 
								0, damage, TRAP_SPRITE, 0, EWF_UNBLOCKABLE,
								this->TileWidth,this->TileHeight);
        while(true){
			trap->DeadState =WDS_ALIVE;
			trap->X = this->X;
			trap->Y = this->Y;
           if (direction == 1){
              for (int i = 0; i < height; i++){
					if (Screen->isSolid(this->X - 1, this->Y + (16 * i) + 8)){
						this->Vx = SpeedX;
						MovingRight = true;
					}
				  else if (Screen->isSolid(this->X + 17, this->Y + (16 * i) + 8)){
					  this->Vx = -1 * SpeedX;
					  MovingLeft =true;
				  }
		      }
              for (int i = 0; i < width; i++){
				  if (Screen->isSolid(this->X + (16 * i) + 8, this->Y - 1))
					  this->Vy = SpeedY;
				  else if (Screen->isSolid(this->X + (16 * i) + 8, this->Y + 17))
					  this->Vy = -1 * SpeedY;
			  }
              if (this->Y >= topY)this->Vy = -1 * SpeedY;
              if (this->Y <= bottomY) this->Vy = SpeedY;
              if(this->X <= rightX && !MovingLeft){
                 this->Vx = SpeedX;
                 MovingRight = true;
              }
              else if (this->X >= leftX && !MovingRight){
                 this->Vx = -1 * SpeedX;
                 MovingLeft = true;
              }
              else if (this->X >= rightX) MovingRight = false;
              else if (this->X <= leftX)MovingLeft = false;
           }
           else if (direction == 2){
              for (int i = 0; i < height; i++){
				  if (Screen->isSolid(this->X - 1, this->Y + (16 * i) + 8))
					this->Vx = SpeedX; 
				  else if (Screen->isSolid(this->X + 17, this->Y + (16 * i) + 8))
					  this->Vx = -1 * SpeedX;
				}
              for (int i = 0; i < width; i++){
				  if (Screen->isSolid(this->X + (16 * i) + 8, this->Y - 1)){
					  this->Vy = SpeedY;
					  MovingUp = true;
				  }
				  else if (Screen->isSolid(this->X + (16 * i) + 8, this->Y + 17)){
					  this->Vy = -1 * SpeedY;
					  MovingDown = true;
				  }
				}
              if (this->X >= rightX)this->Vx = -1 * SpeedX;
              if (this->X <= leftX) this->Vx = SpeedX;
              if(this->Y <= topY && !MovingDown){
                 this->Vy = SpeedY;
                 MovingUp = true;
              }
              else if (this->Y >= bottomY && !MovingUp){
                 this->Vy = -1 * SpeedY;
                 MovingDown = true;
              }
              else if (this->Y >= topY)MovingUp = false;
              else if (this->Y <= bottomY)MovingDown = false;
           }
           else if (direction == 3){
               this->Vx = SpeedX;
               if (Link->Y + 16 >= OrigY && Link->Y <= EndY){
                   for(int i = 0; i<height; i++){
                       if (Screen->isSolid(this->X - 1, this->Y + (16 * i) + 8)){
							SpeedX = 1;
                          MovingRight = true;
						}
					   else if (Screen->isSolid(this->X + 17, this->Y + (16 * i) + 8)){
						  SpeedX = -1;
						  MovingLeft =true;
					   }
					}
                   if(this->X <= rightX && !MovingLeft){
                       SpeedX = 1;
                       MovingRight = true;
                   }
                   else if (this->X >= leftX && !MovingRight){
                       SpeedX = -1;
                       MovingLeft = true;
                   }
                   else if (this->X >= rightX) MovingRight = false;
                   else if (this->X <= leftX)MovingLeft = false;
               }
               else{
                   MovingLeft = false;
                   MovingRight = false;
                   if(this->X <= OrigX && OrigX > leftX)SpeedX = 1;
                   else if (this->X >= OrigX && OrigX < rightX)SpeedX = -1;
                   else if ((this->X >= OrigX && OrigX>= rightX) 
							|| this->X <= OrigX && OrigX<= leftX)SpeedX = 0;
               }
           }   
           else if (direction == 4){
               this->Vy = SpeedY;
               if (Link->X + 16 >= OrigX && Link->X <= EndX){
                  for (int i = 0; i < width; i++){
					  if (Screen->isSolid(this->X + (16 * i) + 8, this->Y - 1)){
						  SpeedY = 1;
                          MovingUp = true;
                      }
					  else if (Screen->isSolid(this->X + (16 * i) + 8, this->Y + 17)){
						  SpeedY = -1;
                          MovingDown = true;
					  }
				  }
                  if(this->Y <= topY && !MovingDown){
                     SpeedY = 1;
                     MovingUp = true;
                  }
                  else if (this->Y >= bottomY && !MovingUp){
                     SpeedY = -1;
                     MovingDown = true;
                  }
                  else if (this->Y >= topY)MovingUp = false;
                  else if (this->Y <= bottomY)MovingDown = false;
               }
               else{
                   MovingDown = false;
                   MovingUp = false;
                   if(this->Y <= OrigY && OrigY > bottomY)SpeedY = 1;
                   else if (this->Y >= OrigY && OrigY < topY)SpeedY = -1;
                   else if ((this->Y >= OrigY && OrigY>= topY) 
							|| this->Y <= OrigY && OrigY<= bottomY)SpeedY = 0;
               }
           }     
           else if (direction == 5){
               for(angle = 0; true; angle = (angle + SpeedX) % 360){
				 trap->X = this->X;
				 trap->Y = this->Y;
                 this->X = OrigX + radius * Cos(angle);
                 this->Y = OrigY + radius * Sin(angle);
                 for(int i = 0; i < height; i++){
                     if (Screen->isSolid(this->X - 1, this->Y + (16 * i) + 8) 
						|| Screen->isSolid(this->X + 17, this->Y + (16 * i) + 8)) SpeedX *=-1;
                 }
                 for (int i = 0; i < width; i++){
					if (Screen->isSolid(this->X + (16 * i) + 8, this->Y - 1) 
						|| Screen->isSolid(this->X + (16 * i) + 8, this->Y + 17)) SpeedX *=-1;
                 };
                 Waitframe();
               }
           }
           Waitframe();
        }
    }
}


item script GameOver{
    void run(){
        Game->End();
    }
}

// Section 8. ghost.zh
// Version 2.7.2

// See ghost.txt for documentation.

// Standard settings -----------------------------------------------------------

// Small (1x1) shadow settings
const int GH_SHADOW_TILE = 27400;
const int GH_SHADOW_CSET = 7;
const int GH_SHADOW_FRAMES = 4;
const int GH_SHADOW_ANIM_SPEED = 8;
const int GH_SHADOW_TRANSLUCENT = 1; // 0 = No, 1 = Yes
const int GH_SHADOW_FLICKER = 0; // 0 = No, 1 = Yes

// Large (2x2) shadow settings
// If GH_LARGE_SHADOW_TILE is 0, large shadows will be disabled
const int GH_LARGE_SHADOW_TILE = 27392; // Top-left corner
const int GH_LARGE_SHADOW_CSET = 7;
const int GH_LARGE_SHADOW_FRAMES = 4;
const int GH_LARGE_SHADOW_ANIM_SPEED = 8;
const int GH_LARGE_SHADOW_MIN_WIDTH = 3; // Enemies must be at least this wide
const int GH_LARGE_SHADOW_MIN_HEIGHT = 3; // and this high to use large shadows

// AutoGhost settings
const int AUTOGHOST_MIN_FFC = 1; // Min: 1, Max: 32
const int AUTOGHOST_MAX_FFC = 32; // Min: 1, Max: 32
const int AUTOGHOST_MIN_ENEMY_ID = 20; // Min: 20, Max: 511
const int AUTOGHOST_MAX_ENEMY_ID = 511; // Min: 20, Max: 511

// Other settings
const int GH_DRAW_OVER_THRESHOLD = 32;
const float GH_GRAVITY = 0.16;
const float GH_TERMINAL_VELOCITY = 3.2;
const int GH_SPAWN_SPRITE = 22; // Min: 0, Max: 255, Default: 22
const int GH_FAKE_Z = 0; // 0 = No, 1 = Yes
const int GH_ENEMIES_FLICKER = 0; // 0 = No, 1 = Yes
const int GH_PREFER_GHOST_ZH_SHADOWS = 0; // 0 = No, 1 = Yes

// Top-left corner of a 4x4 block of blank tiles
const int GH_BLANK_TILE = 65456; // Min: 0, Max: 65456

// Invisible combo with no properties set
const int GH_INVISIBLE_COMBO = 1964; // Min: 1, Max: 65279

// End standard settings -------------------------------------------------------



// Advanced settings -----------------------------------------------------------

// AutoGhost will read a script name from the enemy's name if attribute 12
// is set to this. Must be a negative number.
const int AUTOGHOST_READ_NAME = -1;

// When reading a script from the enemy name, this character marks the
// beginning of the script name.
// Default: 64 ( @ )
const int AUTOGHOST_DELIMITER = 64;

// Misc. attribute 11 can be set to this instead of GH_INVISIBLE_COMBO.
// Must be a negative number.
const int __GH_INVISIBLE_ALT = -1;

// This will use the invisible combo, but also set npc->Extend to 3 or 4,
// hiding the initial spawn puff. Must be a negative number.
const int __GH_INVISIBLE_EXTEND = -2;

// If enabled, the FFC will be invisible, and Screen->DrawCombo will be used
// to display enemies.
const int __GH_USE_DRAWCOMBO = 1;

// Enemies flash or flicker for this many frames when hit. This does not
// affect enemies that use the invisible combo.
// Default: 32
const int __GH_FLASH_TIME = 32;

// Enemies will be knocked back for this many frames when hit.
// Default: 16
// Max: 4095
const int __GH_KNOCKBACK_TIME = 16;

// The speed at which enemies are knocked back, in pixels per frame.
// Default: 4
const int __GH_KNOCKBACK_STEP = 4;

// The imprecision setting used when a movement function is called internally
// (except for walking functions).
const int __GH_DEFAULT_IMPRECISION = 2;

// npc->Misc[] index
// Set this so it doesn't conflict with other scripts. Legal values are 0-15.
const int __GHI_NPC_DATA = 15;

// eweapon->Misc[] indices
// These must be unique numbers between 0 and 15.
const int __EWI_FLAGS          = 15; // Every index but this one can be used by non-ghost.zh EWeapons
const int __EWI_ID             = 3;
const int __EWI_XPOS           = 4;
const int __EWI_YPOS           = 5;
const int __EWI_WORK           = 6;
const int __EWI_WORK_2         = 7; // Only used by a few movement types
const int __EWI_MOVEMENT       = 8;
const int __EWI_MOVEMENT_ARG   = 9;
const int __EWI_MOVEMENT_ARG_2 = 10;
const int __EWI_LIFESPAN       = 11;
const int __EWI_LIFESPAN_ARG   = 12;
const int __EWI_ON_DEATH       = 13;
const int __EWI_ON_DEATH_ARG   = 14;

// These are only used by dummy EWeapons;
// they can use the same values as __EWI_XPOS and __EWI_YPOS
const int __EWI_DUMMY_SOUND    = 2;
const int __EWI_DUMMY_STEP     = 4;
const int __EWI_DUMMY_SPRITE   = 5;

// End advanced settings -------------------------------------------------------


import "ghost_zh/common.z"
import "ghost_zh/depreciated.z"
import "ghost_zh/drawing.z"
import "ghost_zh/eweapon.z"
import "ghost_zh/eweaponDeath.z"
import "ghost_zh/eweaponMovement.z"
import "ghost_zh/flags.z"
import "ghost_zh/global.z"
import "ghost_zh/init.z"
import "ghost_zh/modification.z"
import "ghost_zh/movement.z"
import "ghost_zh/other.z"
import "ghost_zh/update.z"

import "ghost_zh/scripts.z"