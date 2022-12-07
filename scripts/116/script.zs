const int BIGENEMY_MISC_ORIGTILE = 0; //Index for NPC`s Misc array for Npc`s real original tile chosen in Enemy Editor
const int BIGENEMY_MISC_OLDX = 1; //Index for NPC`s Misc array for Npc`s X coordinate in previous frame.
const int BIGENEMY_MISC_OLDY = 2; //Index for NPC`s Misc array for Npc`s Y coordinate in previous frame.
const int BIGENEMY_MISC_HALTCOUNTER = 3; //Index for NPC`s Misc array for Npc`s halt counter

global script AutoBigEnemy{
	void run (){
		while (true){
			AutoBigEnemy(); //When combining with other global scripts, place this function in main loop before Waitdraw().
			Waitdraw();
			Waitframe();
		}
	}
}

//Itrates trough all enemies on screen and searches for ones that need to be extended.
void AutoBigEnemy(){
	npc big;
	for (int i=1; i<= Screen->NumNPCs(); i++){
		big = Screen->LoadNPC(i);
		SetBigEnemySettings(big);
	}
}

// Main BigEnemy definition table. When adding more enemies that need to be bigger, repeat
// "BigEnemy" function for each extend enemy with the following arguments:
// 1. "n". it`s a pointer to affected enemy. Don`t change.
// 2. Enemy ID of affected enemy.
// 3. Draw X offset
// 4. Draw Y offset
// 5. Hitbox X offset
// 5. Hitbox Y offset
// 6. Hitbox width, in pixels.
// 7. Hitbox height, in pixels.
// 8. TileWidth, in tiles.
// 9. TileHeight, in tiles.
// 10. Custom animation flags.

void SetBigEnemySettings( npc n){
	BigEnemy(n, 44, 0,-16,0,-16,16,32,1,2,0); //Rope L1 becomes 1x2 sized.
	BigEnemy(n, 29, 0,-16,0,-16,16,32,1,2,0); //Moblin L2 becomes 1x2 sized.
	BigEnemy(n, 79, 0,-16,0,-16,16,32,1,2,0); //Rope L1 becomes 1x2 sized.
	BigEnemy(n, 120, 0,-16,0,-16,16,32,1,2,0); //Stalfos L3 becomes 1x2 sized.
	BigEnemy(n, 39, -16,-16,-16,-16,48,16,3,2,0); //Giant Vampire Bat.
	BigEnemy(n, 183, 0,-32,0,-32,16,48,1,3,0);//Monster Frankenstein
	//BigEnemy(n, 188, -32,-48,-32,-48,64,64,4,4,9);//Test Giant Goomba
	
}


//Set BigEnemy parameters if enemy is not extended yet. Or run custom animation function every frame, if it is.
void BigEnemy ( npc k, int id, int drawxoffset, int drawyoffset, int hitxoffset, int hityoffset , int hitx, int hity, int tilex, int tiley, int animation){
	if (!(k->ID == id)) return;
	if (k->Extend == 3){
		BigEnemyCustomAnimation(k, animation);
		return;
	}
	else k->Misc[BIGENEMY_MISC_ORIGTILE] = k->OriginalTile;
	k->DrawXOffset = drawxoffset;
	k->DrawYOffset = drawyoffset;
	k->HitXOffset = hitxoffset;
	k->HitYOffset = hityoffset;
	k->HitWidth = hitx;
	k->HitHeight = hity;
	k->Extend = 3;
	k->TileWidth = tilex;
	k->TileHeight = tiley;
}

//Used to determine animation direction for facing Link
int FacingLink (npc b){
	if (IsSideview()){
		if (b->X > CenterLinkX()) return DIR_LEFT;
		else return DIR_RIGHT;
	}
	else{
		int LX = CenterLinkX();
		int LY = CenterLinkY();
		int BX = CenterX(b);
		int BY = CenterY(b);
		int vector = Angle(LX,LY,BX,BY);
		if (Abs(vector)>135){
			return DIR_RIGHT;
		}
		else if (Abs(vector)>45){
			if (vector > 0) return DIR_UP;
			else return DIR_DOWN;
		}
		else return DIR_LEFT;
	}
}

//Defines custom animation. Call this function every frame to prevent glitching tiles.
void BigEnemyCustomAnimation(npc b, int animflags){
	if ((animflags&1) == 0) return; //Custom animation was not enabled.
	if (b->Attributes[11] > 0) return; //Stay away from ghosted enemies.
	int OrigTileOffset = b->TileHeight * 20; //Find incremental for BigEnemy`s OriginalTile offset.
	float HaltThreshold = 100/(b->Step); //Find out the threshold used to detect whether the enemy is halting.
	if (HaltThreshold==0) HaltThreshold = 1; //Set the threshold for fast enemies.
	int andir=0; //Direction the enemy is facing. Not the npc->Dir!
     int HaltTileOffset=0; //Tile offset used for "firing"animation.
     int OrigTile = b->Misc[BIGENEMY_MISC_ORIGTILE]; //The actual original tile of enemy.
     // /!\ Must be recorded on enemy initialization.
     int OldX = b->Misc[BIGENEMY_MISC_OLDX]; //Enemy`s X coordinate on previous frame.
     int OldY = b->Misc[BIGENEMY_MISC_OLDY]; //Enemy`s Y coordinate on previous frame.
     if ((animflags&4)>0) andir = FacingLink(b); //Always face Link if approriate flag is used.
     else andir = b->Dir; //Otherwise, use npc->Dir.
     if ((animflags&8)>0){ //Firing animation is used?
     if ((b->X == OldX)&&(b->Y==OldY)&&(OldX==GridX(OldX))&&(OldY==GridY(OldY))){ //Main halting detection check. Not perfect. :-(
      	b->Misc[BIGENEMY_MISC_HALTCOUNTER]++; //Update halt counter.
      	if (b->Misc[BIGENEMY_MISC_HALTCOUNTER]>HaltThreshold){
     	if ((animflags&2)>0) HaltTileOffset=  OrigTileOffset*8; //Check diagonal allowance flag.
     	else HaltTileOffset=  OrigTileOffset*4; //And set tile offset accordingly.
     	if (b->Misc[BIGENEMY_MISC_HALTCOUNTER] >= 24) HaltTileOffset *= 2; 
      	}
	}
     else b->Misc[BIGENEMY_MISC_HALTCOUNTER] = 0; //Reset halt counter.
     }
     b->Misc[BIGENEMY_MISC_OLDX] = b->X; //Update old coordinates.
     b->Misc[BIGENEMY_MISC_OLDY] = b->Y;
     b->OriginalTile = OrigTile + HaltTileOffset+ (OrigTileOffset * andir); //And, finally, set npc`s Original Tile.
     //debugValue(1, (b->Misc[BIGENEMY_MISC_HALTCOUNTER]));
     //debugValue(2, HaltThreshold);
}