//import "std.zh" //Include these once at the top of your script file
//import "string.zh"
//import "ghost.zh"

const int SFX_ALARM = 67; //Error sound or sentry alert
const int SFX_LASER = 68; //Laser fired

const int LS_ATTRIB_ROTSPEED = 0; //Misc Attr 1
const int LS_ATTRIB_RADIUS = 1; //... 2
const int LS_ATTRIB_DELAY = 2; //... 3
const int LS_ATTRIB_COOLDOWN = 3; //... 4
const int LS_ATTRIB_LASERCOLOR = 4; //... 5

ffc script laserSentry{
	void run ( int ID ){
		npc ghost = Ghost_InitAutoGhost(this, ID, GHF_SET_DIRECTION | GHF_4WAY); //Initialize ghost NPC
		int rotSpeed = ghost->Attributes[LS_ATTRIB_ROTSPEED]; //Load its attributes
		int radius = ghost->Attributes[LS_ATTRIB_RADIUS];
		int delay = ghost->Attributes[LS_ATTRIB_DELAY];
		int cooldown = ghost->Attributes[LS_ATTRIB_COOLDOWN];
		int color = ghost->Attributes[LS_ATTRIB_LASERCOLOR];
		int angle;
		while(ghost->isValid()){
			Screen->Arc(3, ghost->X+8, ghost->Y+8, radius , -1*angle , -1*angle+1, color, 1, 0, 0, 0, false,false, 128); //Draw laser pointer
			if ( DistanceLink(ghost->X+8, ghost->Y+ 8) <= radius //If Link is within its radius
			&& AnglePos(ghost->X, ghost->Y, Link->X, Link->Y) >= angle //And between the two angles (new and old)
			&& AnglePos(ghost->X, ghost->Y, Link->X, Link->Y) <= angle+rotSpeed
			){
				Game->PlaySound(SFX_ALARM);
				int x = Link->X+8; //Save Link's position
				int y = Link->Y+8;
				Ghost_Waitframes(this, ghost, true, true, delay); //Wait before firing
				fireLaserLine( ghost->X+8, ghost->Y+8, 600, ghost->WeaponDamage, x, y, color, this, ghost ); //Shoot where Link was
				Ghost_Waitframes(this, ghost, true, true, cooldown); //Wait before resumed operation
			}
			angle = (angle+rotSpeed) % 360;
			Ghost_Waitframe(this, ghost, true, true);
		}
	}
}

void fireLaserLine( int origX, int origY, int speed, int damage, int targX, int targY, int color, ffc this, npc ghost ){
	int lastX;
	int lastY;
	if ( targX < 0 ) targX = Link->X;
	if ( targY < 0 ) targX = Link->Y;
	Game->PlaySound(SFX_LASER); //Play firing sound
	eweapon laser = CreateEWeaponAt(EW_ARROW, origX, origY); //Create the laser eweapon (invisible)
	laser->Step = speed;
	laser->Damage = damage;
	laser->Angular = true;
	laser->Angle = RadianAngle(origX, origY, targX, targY);
	while ( laser->isValid() ){
		Screen->Line(3, origX, origY, laser->X, laser->Y, color, 1, 0, 0, 0, 128);
		lastX = laser->X;
		lastY = laser->Y;
		Ghost_Waitframe(this, ghost, true, true);
	}
	for ( int f = 20; f > 0; f-- ){ //Let laser fade out after hit
		Screen->Line(3, origX, origY, lastX, lastY, color, 1, 0, 0, 0, 128);
		Ghost_Waitframe(this, ghost, true, true);
	}
}

//Returns value from 0 to 360 rather than -180 to 180
float AnglePos(int x1, int y1, int x2, int y2) {
	float angle = ArcTan(x2-x1, y2-y1)*57.2958;
	if ( angle < 0 )
	angle += 360;
	return angle;
}

int DistanceLink ( int x, int y ){
	return Distance ( Link->X+8, Link->Y+8, x, y );
}