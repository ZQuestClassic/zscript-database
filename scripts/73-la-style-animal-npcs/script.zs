//Attributes
//Type: Walking enemy
//Step speed: How fast to move
//3 = Death Attr 1: How high to jump (1-2 is a good value)
//4 = Death Attr 2: How long to stand still (in frames)
//5 = Death Attr 3: How long to move (ditto)
//6 = Extra shots: Collision detection (0: intangible; 1: deals damage and can be killed)
//11 = MUST BE equal to GH_INVISIBLE_COMBO in ghost.zh
//12 = Script slot number (check as you're assigning this to an FFC slot)

const int ANIMAL_ATTRIB_JUMPHEIGHT = 2;
const int ANIMAL_ATTRIB_STANDTIME = 3;
const int ANIMAL_ATTRIB_MOVETIME = 4;
const int ANIMAL_ATTRIB_COLLDETECT = 5;

ffc script animalNPC{
	void run ( int enemyID ){
		//Initialize the autoghost 'enemy'
		npc ghost = Ghost_InitAutoGhost(this, enemyID, GHF_SET_DIRECTION | GHF_4WAY);
		if ( !ghost->Attributes[ANIMAL_ATTRIB_COLLDETECT] ) //If collision attrib is off,
		ghost->CollDetection = false; //Make ghost intangible
		int moveCounter = 0 + Rand(ghost->Attributes[ANIMAL_ATTRIB_STANDTIME]);
		bool moving = false;
		int ghostStep = ghost->Step; //Save step speed
		while ( true ){

			//If it is moving and on the ground
			if ( moving && ghost->Z == 0 ){
				ghost->Jump = ghost->Attributes[ANIMAL_ATTRIB_JUMPHEIGHT]; //Jump
			}

			//Move the ghost unless at an edge and facing it
			Ghost_Move( ghost->Dir, ghost->Step/100, 0 );

			//Keep away from screen borders
			if ( ghost->Y > 170 )
			ghost->Y--;
			else if ( ghost->Y < 4 )
			ghost->Y++;
			if ( ghost->X > 252 )
			ghost->X--;
			else if ( ghost->X < 4 )
			ghost->X++;

			//Increment move counter
			moveCounter++;
			if ( moving && moveCounter > ghost->Attributes[ANIMAL_ATTRIB_MOVETIME] ){
				moving = false;
				moveCounter = 0 + Rand(ghost->Attributes[ANIMAL_ATTRIB_MOVETIME])/10;
				ghost->Step = 0;
			}
			else if ( !moving && moveCounter > ghost->Attributes[ANIMAL_ATTRIB_STANDTIME] ){
				moving = true;
				moveCounter = 0 + Rand(ghost->Attributes[ANIMAL_ATTRIB_STANDTIME])/10;
				ghost->Dir = Rand( 8);
				ghost->Step = ghostStep;
			}

			//Special waitframe for autoGhost scripts
			Ghost_WaitframeLight();
		}
	}
}