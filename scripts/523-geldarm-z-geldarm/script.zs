//Geldarm - worm -like creature that lurks in one place in attempt to bite Link when he gets close enough.
ffc script FFGeldarm{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int dir = Ghost_GetAttribute(ghost, 0, 0);//Direction facing. -1 - following Link. Use right facing head for enemy tile.
		int proximity = Ghost_GetAttribute(ghost, 1, 32);//Proximity radius and monter length, in pixels.
		int speedon = Ghost_GetAttribute(ghost, 2, 3);//Attack speed, in 100th pixels per frame
		int speedoff = Ghost_GetAttribute(ghost, 3, 1);//Retraction speed, in 100th pixels per frame
		int segmenttile = Ghost_GetAttribute(ghost, 4, 0);//Combo used for rendering segments of mpnster.
		int roottile = Ghost_GetAttribute(ghost, 5, 0);//Combo used for rendering root of mpnster.
		int looseheadnpc = Ghost_GetAttribute(ghost, 6, -1);//NPC to spawn on death, -1 - no loose head spawning
		int numsegments = Ghost_GetAttribute(ghost, 7, 4);//Number of segments to render, including root tile
		int delay = Ghost_GetAttribute(ghost, 8, 60);//delay between noticing Link and attacking, in frames
		int ewsprite = Ghost_GetAttribute(ghost, 9, -1);//Eweapon sprite 	
		
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int angle= 0;
		if (dir>=0)angle=DirAngle(dir);
		else angle = 0;
		int LinkYOffset = Cond(IsSideview(),0,8);
		int State = 0;
		int origx = Ghost_X;
		int origy = Ghost_Y;
		int shoottimer =0;	
		int shotangle = 0;
		int length=0;
		int neckposX=0;
		int neckposY=0;
		int flickercnt=0;
		Ghost_SpawnAnimationPuff(this, ghost);
		ghost->DrawXOffset=1000;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				if (shoottimer==0){
					if (dir<0)angle = Angle(origx, origy, Link->X, Link->Y);
					if (Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(),CenterLinkY())<=proximity){
						shoottimer=delay;
					}
				}
				else {
					shoottimer--;
					if (shoottimer==0){
						//if (dir<0)angle = Angle(origx, origy, Link->X, Link->Y);
						State=1;
					}
				}
			}
			else if (State==1){
				length+=speedon/100;
				Ghost_X=origx+length*Cos(angle);
				Ghost_Y=origy+length*Sin(angle);
				
				if (length>=proximity){
					if (dir<0)shotangle = RadianAngle(Ghost_X, Ghost_Y, Link->X, Link->Y);
					else shotangle = DirRad(dir);
					eweapon e = FireEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, shotangle, 200, WPND, ewsprite, -1, 0);
					shoottimer=delay;
					State=2;
				}
			}
			else if (State==2){
				if (shoottimer>0){
					shoottimer--;
				}
				else {
					length-=speedoff/100;
					Ghost_X=origx+length*Cos(angle);
					Ghost_Y=origy+length*Sin(angle);
					
					if (length<=0){
						Ghost_X = origx;
						Ghost_Y = origy;
						shoottimer=0;
						State=0;
					}
				}
			}
			if (State!=0){
				for (int i=0; i< numsegments; i++){
					neckposX = Lerp(origx, Ghost_X, (1/(numsegments))*i);
					neckposY = Lerp(origy, Ghost_Y, (1/(numsegments)*i));
					if (IsEven(flickercnt))Screen->DrawCombo(3, neckposX, neckposY, Cond(i==0, roottile, segmenttile), 1, 1, Ghost_CSet, -1, -1, neckposX, neckposY, angle, 0, 0,true, OP_OPAQUE);
					if (RectCollision(Link->X, Link->Y+LinkYOffset, Link->X+15, Link->Y+Cond(IsSideview(),16,8), neckposX+4, neckposY+4, neckposX+12, neckposY+12)){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, ghost->Damage, -1, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
				}
			}
			if (flickercnt>0)flickercnt--;
			if ( Ghost_GotHit())flickercnt=45;
			// debugValue(1,angle);
			// debugValue(2,dir);
			if (IsEven(flickercnt))Screen->DrawTile(3, Ghost_X, Ghost_Y, ghost->Tile, 1, 1,Ghost_CSet, -1, -1,Ghost_X, Ghost_Y, angle, 0, true, OP_OPAQUE);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				ghost->DrawXOffset=0;
				for (int i=1;i<=Screen->NumNPCs();i++){
					if (looseheadnpc<0)continue;
					npc n=Screen->LoadNPC(i);
					if (n->ID!=enemyID) continue;
					if (n->HP==0)continue;
					npc e = CreateNPCAt(looseheadnpc, Ghost_X,Ghost_Y);
					break;
				}
				Quit();
			}
		}
	}	
}

//Z2Geldarm - worm -like creature that lurks in one place in attempt to bite Link when he gets close enough. Attack root point when he is extended to damage it.
ffc script Z2Geldarm{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int dir = Ghost_GetAttribute(ghost, 0, 0);//Direction facing. -1 - following Link. Use right facing head for enemy tile.
		int proximity = Ghost_GetAttribute(ghost, 1, 32);//Proximity radius and monter length, in pixels.
		int speedon = Ghost_GetAttribute(ghost, 2, 3);//Attack speed, in 100th pixels per frame
		int speedoff = Ghost_GetAttribute(ghost, 3, 1);//Retraction speed, in 100th pixels per frame
		int segmenttile = Ghost_GetAttribute(ghost, 4, 0);//Combo used for rendering segments of mpnster.
		int roottile = Ghost_GetAttribute(ghost, 5, 0);//Combo used for rendering root of mpnster.
		int looseheadnpc = Ghost_GetAttribute(ghost, 6, -1);//NPC to spawn on death, -1 - no loose head spawning
		int numsegments = Ghost_GetAttribute(ghost, 7, 4);//Number of segments to render, including root tile
		int delay = Ghost_GetAttribute(ghost, 8, 60);//delay between noticing Link and attacking, in frames
		int ewsprite = Ghost_GetAttribute(ghost, 9, -1);//Eweapon sprite 	
		
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int angle= 0;
		if (dir>=0)angle=DirAngle(dir);
		else angle = 0;
		int LinkYOffset = Cond(IsSideview(),0,8);
		int State = 0;
		int origx = Ghost_X;
		int origy = Ghost_Y;
		int shoottimer =0;	
		int shotangle = 0;
		int length=0;
		int neckposX=0;
		int neckposY=0;
		Ghost_SpawnAnimationPuff(this, ghost);
		ghost->DrawXOffset=1000;
		int xpos = Ghost_X;
		int ypos = Ghost_Y;
		int flickercnt=0;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				if (shoottimer==0){
					if (dir<0)angle = Angle(origx, origy, Link->X, Link->Y);
					if (Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(),CenterLinkY())<=proximity){
						shoottimer=delay;
					}
				}
				else {
					shoottimer--;
					if (shoottimer==0){
						//if (dir<0)angle = Angle(origx, origy, Link->X, Link->Y);
						State=1;
					}
				}
			}
			else if (State==1){
				length+=speedon/100;
				xpos=origx+length*Cos(angle);
				ypos=origy+length*Sin(angle);
				
				if (length>=proximity){
					if (dir<0)shotangle = RadianAngle(xpos, ypos, Link->X, Link->Y);
					else shotangle = DirRad(dir);
					eweapon e = FireEWeapon(ghost->Weapon, xpos, ypos, shotangle, 200, WPND, ewsprite, -1, 0);
					shoottimer=delay;
					State=2;
				}
			}
			else if (State==2){
				if (shoottimer>0){
					shoottimer--;
				}
				else {
					length-=speedoff/100;
					xpos=origx+length*Cos(angle);
					ypos=origy+length*Sin(angle);
					
					if (length<=0){
						xpos = origx;
						ypos = origy;
						shoottimer=0;
						State=0;
					}
				}
			}
			if (State!=0){
				for (int i=0; i< numsegments; i++){
					neckposX = Lerp(origx, xpos, (1/(numsegments))*i);
					neckposY = Lerp(origy, ypos, (1/(numsegments)*i));
					if (IsEven(flickercnt))Screen->DrawCombo(3, neckposX, neckposY, Cond(i==0, roottile, segmenttile), 1, 1, Ghost_CSet, -1, -1, neckposX, neckposY, angle, 0, 0,true, OP_OPAQUE);
					if (RectCollision(Link->X, Link->Y+LinkYOffset, Link->X+15, Link->Y+Cond(IsSideview(),16,8), neckposX+4, neckposY+4, neckposX+12, neckposY+12)){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, ghost->Damage, -1, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
				}
			}
			// debugValue(1,angle);
			// debugValue(2,dir);
			if (flickercnt>0)flickercnt--;
			if ( Ghost_GotHit())flickercnt=45;
			if (IsEven(flickercnt))Screen->DrawTile(3, xpos, ypos, ghost->Tile, 1, 1,Ghost_CSet, -1, -1,xpos, ypos, angle, 0, true, OP_OPAQUE);
			if (RectCollision(Link->X, Link->Y+LinkYOffset, Link->X+15, Link->Y+Cond(IsSideview(),16,8), xpos+1, ypos+1, xpos+13, ypos+13)){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, ghost->Damage, -1, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				ghost->DrawXOffset=0;
				for (int i=1;i<=Screen->NumNPCs();i++){
					if (looseheadnpc<0)continue;
					npc n=Screen->LoadNPC(i);
					if (n->ID!=enemyID) continue;
					if (n->HP==0)continue;
					npc e = CreateNPCAt(looseheadnpc, Ghost_X,Ghost_Y);
					break;
				}
				Quit();
			}
		}
	}	
}