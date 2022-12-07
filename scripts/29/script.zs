//This enemy walks around, without stopping, in random directions for
//    semi-random distances.  If Link gets in its horizontal path, it
//    speeds up and zooms in his direction.
//
//This approximately recreates the behavior of crabs in Link's Awakening,
//    among other games.
//
//Enemy Attributes Used:
//    -Step Speed: Determines speed (standard: 25)
//    -Misc. Attr. 1: Minimum pixel distance for each walk phase (default: 8)
//  -Misc. Attr. 2: Maximum pixel distance for each walk phase (default: 16)
//    -Misc. Attr. 3: Amount step rate is mutliplied by when zooming (default: 6)
//    -Misc. Attr. 11: GH_INVISIBLE_COMBO
//    -Misc. Attr. 12: Script Slot

//Misc. Attribute Indexes
const int Z4CRAB_MIN_DIST_INDEX = 0;
const int Z4CRAB_MAX_DIST_INDEX = 1;
const int Z4CRAB_MULTIPLIER = 2;

ffc script Z4Crab {
    void run(int enemyID) {
    
	    npc ghost;
        int dist;
        float dir;
        float minDist;
        float maxDist;
        float step;
        float multiplier;
        int fRate;
	    
	    //Initialize
	    ghost = Ghost_InitAutoGhost(this, enemyID);
	    Ghost_SetFlag(GHF_NORMAL);
        step = ghost->Step/100;
        minDist = Ghost_GetAttribute(ghost, Z4CRAB_MIN_DIST_INDEX, 8)*.5/step;
        maxDist = Ghost_GetAttribute(ghost, Z4CRAB_MAX_DIST_INDEX, 16)*.5/step;
        multiplier = Ghost_GetAttribute(ghost, Z4CRAB_MULTIPLIER, 6);
        fRate = ghost->ASpeed;
	    
	    while(true) {		    
		    //choose dir and distance
		    dir = Rand(4);
            dist = Rand(minDist,maxDist);
            
            // Move
            ghost->ASpeed = fRate;            
            for(int i=0; i<dist; i++) {
                if (Ghost_CanMove(dir,1,3)){
                    Ghost_Move(dir,step,3);
                    if (Abs(Link->Y - Ghost_Y)<8)
                        zoom(this,ghost,step*multiplier);
                    Ghost_Waitframe(this, ghost, true, true);
                }
            }
            if (!Ghost_CanMove(dir,1,3))
                Ghost_Waitframe(this,ghost,true,true);
        }
    }
    
    void zoom(ffc this, npc ghost, float step){
        ghost->ASpeed/=2;
        if (Link->X - Ghost_X > 0) { //zoom right
            while (Ghost_CanMove(3,1,3)){
                Ghost_Move(3,step,3);
                Ghost_Waitframe(this, ghost, true, true);
            }
        }
        else if (Link->X - Ghost_X < 0) { //zoom left
            while (Ghost_CanMove(2,1,3)){
                Ghost_Move(2,step,3);
                Ghost_Waitframe(this, ghost, true, true);
            }
        }
        ghost->ASpeed*=2;
    }
}