//Prism Elemental

//This rather gimmicky ghosted enemy is what it is named: A crystal-like enemy that carries the attributes of the Magic Prism combos in ZQuest. Yes, you heard it, these guys split Magic blasts that hit it into multiple blasts that shoot out from their sides. As a side effect, these guys are immume to Magic blasts and optionally Sword Beams regardless of what you set these defenses to in the Enemy Editor.
//Unusually for a ghosted enemy, Prism Elemental does not read any of the Misc Attributes on the enemy aside from the default Misc Attribute 11 and Misc Attribute 12 (or not even them if you have ghost.zh only read from the enemy name) for variables. It however does read the enemy's Magic Defense entry in the Enemy Editor on initialization due to the enemy's nature. 
//Important: Read the enemy's setup instructions for the variable used
//The demo quest also includes a Wizzrobe enemy that carries the attributes of the Prism Elemental, to showcase how the script can be applied to other enemies. Not tested on and not expected to be compatible with enemies that have small hitboxes (eg. Keese, Patra eyes).

//import "std.zh"
//import "string.zh"
//import "ghost.zh" 


//The option corresponding to quest rules. Set these to 1 if their corresponding quest rules are checked.
const int QR_MIRRORS_REFLECT_BEAMS = 0; //"Magic Mirrors/Prisms Reflect Sword Beams" quest rule

//Setup:
//	1: First, import the necessary files (std.zh, string.zh, ghost.zh) and set up Ghost.zh to work with your quest if you already haven't.
//	2: Import the script and set QR_MIRRORS_REFLECT_BEAMS to 0 or 1 depending on if the "Magic Mirrors/Prisms reflect Sword Beams" quest rule in your quest is checked or not. 0 if not, 1 if it is. Setting this constant approiately is to make its reflective properties more closely match the built-in Magic Prism combos in ZQuest.
//	3: Set up the enemy. Everything is set up like a normal enemy except Misc Attributes 11 and 12 except for it's Magic Defense in the enemy editor. Set the enemy's Magic Defense to (none) to give it the properties of the 3-Way prism in ZQuest, set it to anything else to give it the properties of the 4-way prism in ZQuest.
//		Due to the fact that the script uses a built-in enemy for its base, it can not read off the Misc Attributes for variables. However, as the result of a side effect of allowing the enemy to split Magic blasts ala ZQuest Magic Prism combos, you can safely use the enemy's Magic and Reflected Magic defenses as variables provided the value you want to use for them doesn't exceed 14 without affecting the enemy's behaviour.
//	4: Enjoy.

ffc script PrismEnemy{
	void run(int EnemyID){
		//Initialize the enemy
		npc ghost = Ghost_InitAutoGhost(this, EnemyID);
		int prismtype = ghost->Defense[NPCD_MAGIC]; //Takes the Magic Defense variable as an arg on initialization, since the actual defense is getting set to ignore shortly.
		ghost->Defense[NPCD_MAGIC] = NPCDT_IGNORE;
		ghost->Defense[NPCD_REFMAGIC] = NPCDT_IGNORE;
		if(QR_MIRRORS_REFLECT_BEAMS){ //If the Quest rule corresponding to Prisms being able to split sword beams is checked, set the beam defenses
			ghost->Defense[NPCD_BEAM] = NPCDT_IGNORE;
			ghost->Defense[NPCD_REFBEAM] = NPCDT_IGNORE;
		}
		
		int reflectcooldown = 0; //The reflect cooldown counter
		
		while(true){
			if(reflectcooldown <= 0){ //Reflection cooldown is over, begin checking to see if a reflectable weapon has touched its center.
				//Checks to see if a reflectable LWeapon has touched its center
				for(int a = 1; a <= Screen->NumLWeapons(); a ++){
					lweapon wpn = Screen->LoadLWeapon(a);
					if(ZRectCollision(wpn->X+wpn->HitXOffset, wpn->Y+wpn->HitYOffset, wpn->Z, wpn->X+wpn->HitXOffset+wpn->HitWidth-1, wpn->Y+wpn->HitYOffset+wpn->HitHeight-1, wpn->Z+wpn->HitZHeight, Ghost_X+ghost->HitXOffset+Floor(ghost->HitWidth/4), Ghost_Y+ghost->HitYOffset+Floor(ghost->HitHeight/4), Ghost_Z, Ghost_X+ghost->HitXOffset+ghost->HitWidth-1-Floor(ghost->HitWidth/4), Ghost_Y+ghost->HitHeight-1-Floor(ghost->HitHeight/4), Ghost_Z+ghost->HitZHeight)){
						if(wpn->ID == LW_MAGIC || wpn->ID == LW_REFMAGIC || ((wpn->ID == LW_BEAM || wpn->ID == LW_REFBEAM) && QR_MIRRORS_REFLECT_BEAMS > 0)){
							if(wpn->Dir < 4){
								if(wpn->isValid()){  //Magic or Beam LWeapon (with the appropriate setting) set has collided with the center pixels of the prism
									if(prismtype == 0){ //3-way prism
										PrismSplit3(wpn, ghost);
									}
									else{ //4-way prism
										PrismSplit4(wpn, ghost);
									}
									reflectcooldown = 10;
									break;
								}
							}
						}
					}
				}
				//Now check for EWeapons
				for(int a = 1; a <= Screen->NumEWeapons(); a ++){
					eweapon wpn = Screen->LoadEWeapon(a);
					if(ZRectCollision(wpn->X+wpn->HitXOffset, wpn->Y+wpn->HitYOffset, wpn->Z, wpn->X+wpn->HitXOffset+wpn->HitWidth-1, wpn->Y+wpn->HitYOffset+wpn->HitHeight-1, wpn->Z+wpn->HitZHeight, Ghost_X+ghost->HitXOffset+Floor(ghost->HitWidth/4), Ghost_Y+ghost->HitYOffset+Floor(ghost->HitHeight/4), Ghost_Z, Ghost_X+ghost->HitXOffset+ghost->HitWidth-1-Floor(ghost->HitWidth/4), Ghost_Y+ghost->HitHeight-1-Floor(ghost->HitHeight/4), Ghost_Z+ghost->HitZHeight)){
						if(wpn->ID == EW_MAGIC || (wpn->ID == EW_BEAM && QR_MIRRORS_REFLECT_BEAMS > 0)){ //Magic or Beam EWeapon (with the appropriate setting) has collided with the center pixels of the prism
							if(wpn->Dir < 4){
								if(wpn->isValid()){
									//The same as with LWeapons, but with EWeapons
									if(prismtype == 0){
										PrismSplit3(wpn, ghost);
									}
									else{
										PrismSplit4(wpn, ghost);
									}
									reflectcooldown = 10;
									break;
								}
							}
						}
					}
				}
			}
			else{
				reflectcooldown --; //Decrement the cooldown variable once every frame if it is above 0.
			}
			Ghost_Waitframe2(this, ghost, true, true);
		}
	}
}

//Takes an LWeapon and splits it ala 3-Way Prism. Overloaded to take LWeapons and EWeapons as arguments. Can easily be inserted into other scripts.
void PrismSplit3(lweapon a, npc nme){ 
	if(a->ID == LW_MAGIC || a->ID == LW_REFMAGIC){
		for(int w = 0; w < 3; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFMAGIC, SpinDir((4+(DirtoSpinDir(a->Dir)-1+w))%4)); //Now split the Magic into 3
		}
	}
	if((a->ID == LW_BEAM || a->ID == LW_REFBEAM) && QR_MIRRORS_REFLECT_BEAMS){
		for(int w = 0; w < 3; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFBEAM, SpinDir((4+(DirtoSpinDir(a->Dir)-1+w))%4)); //Now split the Magic into 3
		}
	}
	Remove(a); //Clear the original LWeapon
}
void PrismSplit3(eweapon a, npc nme){ 
	for(int w = 0; w < 3; w ++){
		lweapon wpn = PrismDuplicate(a, nme, LW_REFMAGIC, SpinDir((4+(DirtoSpinDir(a->Dir)-1+w))%4)); //Now split the Magic into 3
	}
	if(a->ID == EW_BEAM && QR_MIRRORS_REFLECT_BEAMS){
		for(int w = 0; w < 3; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFBEAM, SpinDir((4+(DirtoSpinDir(a->Dir)-1+w))%4)); //Now split the Magic into 3
		}
	}
	Remove(a); //Clear the original EWeapon
}

//Takes an LWeapon and splits ala 4-Way Prism. Overloaded to take an EWeapon instead. Can easily be inserted into other scripts.
void PrismSplit4(lweapon a, npc nme){
	if(a->ID == LW_MAGIC || a->ID == LW_REFMAGIC){
		for(int w = 0; w < 4; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFMAGIC, w); //Split the Magic into 4
		}
	}
	if((a->ID == LW_BEAM || a->ID == LW_REFBEAM) && QR_MIRRORS_REFLECT_BEAMS){ //Sword beams and the option checked
		for(int w = 0; w < 4; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFBEAM, w); //Split the Beam into 4
		}
	}
	Remove(a); //Clear the original LWeapon
}
void PrismSplit4(eweapon a, npc nme){
	if(a->ID == EW_MAGIC){
		for(int w = 0; w < 4; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFMAGIC, w); //Split the Magic into 4
		}
	}
	if(a->ID == EW_BEAM && QR_MIRRORS_REFLECT_BEAMS){ //Sword beams and the option checked
		for(int w = 0; w < 4; w ++){
			lweapon wpn = PrismDuplicate(a, nme, LW_REFBEAM, w); //Split the Beam into 4
		}
	}
	Remove(a); //Clear the original EWeapon
}

//Creates and returns an exact copy of the passed LWeapon, sans type and direction and angle (since the prism doesn't use angles). Assumes that the passed pointer is valid. Overloaded to take an EWeapon as an argument instead of an LWeapon.
lweapon PrismDuplicate(lweapon a, npc nme, int type, int dir) {
	lweapon b = Screen->CreateLWeapon(type);
	b->X = nme->X;
	b->Y = nme->Y;
	b->Z = nme->Z;
	b->Jump = a->Jump;
	b->Extend = a->Extend;
	b->TileWidth = a->TileWidth;
	b->TileHeight = a->TileHeight;
	b->HitWidth = a->HitWidth;
	b->HitHeight = a->HitHeight;
	b->HitZHeight = a->HitZHeight;
	b->HitXOffset = a->HitXOffset;
	b->HitYOffset = a->HitYOffset;
	b->DrawXOffset = a->DrawXOffset;
	b->DrawYOffset = a->DrawYOffset;
	b->DrawZOffset = a->DrawZOffset;
	b->Tile = a->Tile;
	b->CSet = a->CSet;
	b->DrawStyle = a->DrawStyle;
	b->Dir = dir;
	b->OriginalTile = a->OriginalTile;
	b->OriginalCSet = a->OriginalCSet;
	b->FlashCSet = a->FlashCSet;
	b->NumFrames = a->NumFrames;
	b->Frame = a->Frame;
	b->ASpeed = a->ASpeed;
	b->Damage = a->Damage;
	b->Step = a->Step;
	b->CollDetection = a->CollDetection;
	b->DeadState = a->DeadState;
	b->Flash = a->Flash;
	b->Flip = a->Flip;
	//Properly flip the weapons
	if(a->Dir == DIR_UP){ //Original weapon facing up or diagonally up
		//Establish a base tile, derived from the original weapon's properties.
		if(dir == DIR_DOWN){ 
			b->Flip = 2;
		}
		else if(dir == DIR_LEFT){
			b->Tile ++;
			b->Flip = 1;
		}
		else if(dir == DIR_RIGHT){
			b->Tile ++;
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_DOWN){ //Original weapon facing down or diagonally down
		if(dir == DIR_UP){
			b->Flip = 0;
		}
		else if(dir == DIR_LEFT){
			b->Tile ++;
			b->Flip = 1;
		}
		else if(dir == DIR_RIGHT){
			b->Tile ++;
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_LEFT){ //Original weapon facing left
		if(dir == DIR_UP){
			b->Tile --;
			b->Flip = 0;
		}
		else if(dir == DIR_DOWN){
			b->Tile --;
			b->Flip = 2;
		}
		else if(dir == DIR_RIGHT){
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_RIGHT){ //Original weapon facing right
		if(dir == DIR_UP){
			b->Tile --;
			b->Flip = 0;
		}
		else if(dir == DIR_DOWN){
			b->Tile --;
			b->Flip = 2;
		}
		else if(dir == DIR_LEFT){
			b->Flip = 1;
		}
	}
	for (int i = 0; i < 16; i++)
		b->Misc[i] = a->Misc[i];
	return b;
}
lweapon PrismDuplicate(eweapon a, npc nme, int type, int dir) {
	lweapon b = Screen->CreateLWeapon(type);
	b->X = nme->X;
	b->Y = nme->Y;
	b->Z = nme->Z;
	b->Jump = a->Jump;
	b->Extend = a->Extend;
	b->TileWidth = a->TileWidth;
	b->TileHeight = a->TileHeight;
	b->HitWidth = a->HitWidth;
	b->HitHeight = a->HitHeight;
	b->HitZHeight = a->HitZHeight;
	b->HitXOffset = a->HitXOffset;
	b->HitYOffset = a->HitYOffset;
	b->DrawXOffset = a->DrawXOffset;
	b->DrawYOffset = a->DrawYOffset;
	b->DrawZOffset = a->DrawZOffset;
	b->Tile = a->Tile;
	b->CSet = a->CSet;
	b->DrawStyle = a->DrawStyle;
	b->Dir = dir;
	b->OriginalTile = a->OriginalTile;
	b->OriginalCSet = a->OriginalCSet;
	b->FlashCSet = a->FlashCSet;
	b->NumFrames = a->NumFrames;
	b->Frame = a->Frame;
	b->ASpeed = a->ASpeed;
	b->Damage = a->Damage;
	b->Step = a->Step;
	b->CollDetection = a->CollDetection;
	b->DeadState = a->DeadState;
	b->Flash = a->Flash;
	b->Flip = a->Flip;
	//Properly flip the weapons
	if(a->Dir == DIR_UP){ //Original weapon facing up or diagonally up
		//Establish a base tile, derived from the original weapon's properties.
		if(dir == DIR_DOWN){ 
			b->Flip = 2;
		}
		else if(dir == DIR_LEFT){
			b->Tile ++;
			b->Flip = 1;
		}
		else if(dir == DIR_RIGHT){
			b->Tile ++;
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_DOWN){ //Original weapon facing down or diagonally down
		if(dir == DIR_UP){
			b->Flip = 0;
		}
		else if(dir == DIR_LEFT){
			b->Tile ++;
			b->Flip = 1;
		}
		else if(dir == DIR_RIGHT){
			b->Tile ++;
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_LEFT){ //Original weapon facing left
		if(dir == DIR_UP){
			b->Tile --;
			b->Flip = 0;
		}
		else if(dir == DIR_DOWN){
			b->Tile --;
			b->Flip = 2;
		}
		else if(dir == DIR_RIGHT){
			b->Flip = 0;
		}
	}
	else if(a->Dir == DIR_RIGHT){ //Original weapon facing right
		if(dir == DIR_UP){
			b->Tile --;
			b->Flip = 0;
		}
		else if(dir == DIR_DOWN){
			b->Tile --;
			b->Flip = 2;
		}
		else if(dir == DIR_LEFT){
			b->Flip = 1;
		}
	}
	for (int i = 0; i < 16; i++)
		b->Misc[i] = a->Misc[i];
	return b;
}

//UTILITY FUNCTIONS
//These are various utility functions that I may reuse in other of my scripts.
//Import these only once

//Converts one of the standard directions to a direction used by SpinDir in std.zh.
int DirtoSpinDir(int dir){
	if(dir == DIR_UP) return 0;
	else if(dir == DIR_DOWN) return 2;
	else if(dir == DIR_LEFT) return 3;
	else if(dir == DIR_RIGHT) return 1;
	else if(dir == DIR_LEFTUP) return 0;
	else if(dir == DIR_RIGHTUP) return 1;
	else if(dir == DIR_LEFTDOWN) return 3;
	else if(dir == DIR_RIGHTDOWN) return 2;
	return -1;
}

//Like RectCollision, but optimized for only checking the the Z axis
bool ZCollision(int box1_z1, int box1_z2, int box2_z1, int box2_z2){
	if(box1_z2 < box2_z1) return false;
	else if(box1_z1 > box2_z2) return false;
	return true;
}

//Combines RectCollision and ZCollision
bool ZRectCollision(int box1_x1, int box1_y1, int box1_z1, int box1_x2, int box1_y2, int box1_z2, int box2_x1, int box2_y1, int box2_z1, int box2_x2, int box2_y2, int box2_z2){
	if(RectCollision(box1_x1, box1_y1, box1_x2, box1_y2, box2_x1, box2_y1, box2_x2, box2_y2)){
		if(ZCollision(box1_z1, box1_z2, box2_z1, box2_z2)){
			return true;
		}
	}
	return false;
}