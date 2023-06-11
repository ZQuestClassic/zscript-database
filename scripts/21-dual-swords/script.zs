import "std.zh"
import "ffcscript.zh"

bool RULE_FLIPRIGHTSLASH = false; //Set to true if you use "Flip right-facing slash" and false if you don't.

const int FLIP_NO = 0; //No flip
const int FLIP_H = 1; //Horizontal flip
const int FLIP_V = 2; //Vertical flip
const int FLIP_B = 3; //Both (180 degree rotation)

//D0: Damage of the second sword (0 = stun)
//D1: Sprite of the second sword
//D2: SFX of main sword
//D3: SFX of second sword
bool swordState; //State of the dual swords: true = second sword
item script dualSwords{
	void run( int damage, int sprite, int sfx1, int sfx2 ){
		swordState = !swordState; //Switch between swords
		if ( swordState ){
			int args[2] = { damage, sprite };
			Game->PlaySound(sfx2);
			RunFFCScript(swordSwitchFFC, args);
		}
		else Game->PlaySound(sfx1);
	}
}

const int swordSwitchFFC = 1; //Set to the slot of the swordSwitch FFC
ffc script swordSwitch{
	void run( int damage, int sprite ){
		//Position/sprite arrays set for facing up
		int Xpos[3] = {-13, -13, 0};
		int Ypos[3] = {0, -13, -13};
		int Sprites[3] = {5, 0, 4}; //0-3: Slash UDLR; 4-5: Stab UR
		int flips[3] = {1, 0, 0}; //Only stabs need flipping
		
		Link->Action = LA_NONE; //Cancel default sword
		
		lweapon sword = LoadLWeaponOf(LW_SWORD); //Find default sword
		Remove(sword); //Remove it
		sword = Screen->CreateLWeapon(LW_SCRIPT1); //Make a new sword
		sword->UseSprite(sprite);
		int baseTile = sword->Tile; //Save the base tile
		sword->Damage = damage;
		
		//Prepare Link's sprite for horizontal flip (DISABLED UNTIL LINK->TILE IS USABLE)
		//if ( Link->Dir == DIR_LEFT ) Link->Dir = DIR_RIGHT;
		//else if ( Link->Dir == DIR_RIGHT ) Link->Dir = DIR_LEFT;
		//Link->Invisible = true;
		
		//Set positions and sprites for each direction
		//Up is set by default
		Sprites[1] = Link->Dir; //Middle sprite always equals Link's direction
		if ( Link->Dir == DIR_DOWN || Link->Dir == DIR_LEFTDOWN || Link->Dir == DIR_RIGHTDOWN ){
			Xpos[0] = 13;
			Xpos[1] = 13;
			//X position 2 is correct
			//Y position 0 is correct
			Ypos[1] = 13;
			Ypos[2] = 13;
			Sprites[0] = 5; //Right, no flip
			Sprites[2] = 4; //Down = up + both flip
			flips[0] = FLIP_NO;
			flips[2] = FLIP_B;
		}
		else if ( Link->Dir == DIR_LEFT ){
			Xpos[0] = 0;
			//Xpos[1] = -16; //Already correct
			Xpos[2] = -13;
			Ypos[0] = 13;
			Ypos[1] = 13;
			Ypos[2] = 0;
			Sprites[0] = 4; //Down = up + both flip
			Sprites[2] = 5; //Left = right + horizontal flip
			flips[0] = FLIP_B;
			flips[2] = FLIP_B;
		}
		else if ( Link->Dir == DIR_RIGHT ){
		//NOTE: These expect "flip right-facing sword" to be enabled. If you don't use it, change the Y values below:
			Xpos[0] = 0;
			Xpos[1] = 13;
			Xpos[2] = 13;
			if ( RULE_FLIPRIGHTSLASH ){ //If "flip right-facing slash" is enabled
				Ypos[0] = -13;
				Ypos[1] = -13;
			}
			else{
				Ypos[0] = 13;
				Ypos[1] = 13;
			}
			Ypos[2] = 0;
			Sprites[0] = 4; //Up, no flip
			Sprites[2] = 5; //Right, no flip
			flips[0] = FLIP_NO;
		}
		Link->Action = LA_ATTACKING;
		for ( int i = 0; i < 3; i++ ){ //For each of 3 frames
			if ( !sword->isValid() ) return; //Quit if sword vanishes
			//Screen->DrawTile(2, Link->X, Link->Y, Link->Tile, -1, -1, 6, -1, -1, 0, 0, 0, FLIP_H, true, 128); //Draw Link's flipped tile
			sword->X = Link->X + Xpos[i]; //Set position
			sword->Y = Link->Y + Ypos[i];
			sword->Tile = baseTile + Sprites[i]; //And sprite
			sword->Flip = flips[i];
			sword->DeadState = WDS_ALIVE;
			for ( int f = 0; f < 3; f++ ){ //Wait 3 frames per position, preventing movement and preserving sword
				sword->DeadState = WDS_ALIVE;
				NoMovement();
				Waitframe();
			}
		}
		sword->DeadState = WDS_DEAD; //Remove it afterwards
		//Link->Invisible = false; //Restore Link's sprite
	}
}

void NoMovement(){ //Prevents moving in any direction
	Link->InputUp = false; Link->PressUp = false;
	Link->InputDown = false; Link->PressDown = false;
	Link->InputLeft = false; Link->PressLeft = false;
	Link->InputRight = false; Link->PressRight = false;
}