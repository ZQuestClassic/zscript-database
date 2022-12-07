#include "std.zh"

///////////////////////
/// GUARDIANS       ///
/// NPC Script      ///
/// For ZC 2.55     ///
/// v1.0            ///
/// 13th Aug., 2019 ///
///////////////////////


npc script Guardian
{
	const int LASER_LAYER 		= 3;
	const int LASER_COLOUR 		= 0x04;
	const int LASER_OPACITY 	= 128;
	const int ANGLE_VISION		= 60;
	const int SHOT_STEP		= 120;
	const int COODOWN		= 150;
	const int WTYPE			= EW_SCRIPT1;
	const int SHOT_SFX		= 70;
	
	void run (int angleOfVision, int shotStep, int shotCooldownTime, int weaponType, int shotSFX, int laserColour)
	{  
		//Get attributes
		angleOfVision = (this->InitD[0] > 0 ) ? this->InitD[0] : ANGLE_VISION;
		shotStep = (this->InitD[1] > 0 ) ? this->InitD[1] : SHOT_STEP;
		shotCooldownTime = ((this->InitD[2] > 0) ? (this->InitD[2]) : COODOWN);
		weaponType = (this->InitD[3] > 0 ) ? this->InitD[3] : WTYPE;
		shotSFX = (this->InitD[4] > 0 ) ? this->InitD[4]: SHOT_SFX;
		laserColour = (this->InitD[5] > 0 ) ? this->InitD[5]: LASER_COLOUR;
 
		int laserStartX;
		int laserStartY;
 
		eweapon beam;
 
		while(this->isValid())
		{
			laserStartX = this->X + 8;
			laserStartY = this->Y + 8;
			//Shooting
			if ( shotCooldownTime > 0 )
				--shotCooldownTime;
			//Only one beam at a time
			else if ( !beam->isValid() )
			{
				//Check angle to Link against angle of vision
				//If Link is within this angle
				if ( (Abs((Angle(CenterX(this), CenterY(this), CenterLinkX(), CenterLinkY())) - (Dir4Angle(this->Dir)))) <= angleOfVision/2 )
				{
					shotCooldownTime = (this->InitD[2] > 0 ) ? this->InitD[2] : COODOWN; //can reduce down by reading InitD again -Z
        
					laserStartX = CenterX(this);
					laserStartY = CenterY(this);
					
					
					/*beam = Screen->CreateEWeapon(weaponType);
					beam->X = laserStartX;
					beam->Y = laserStartY;
					beam->Angular = true;
					beam->Angle = ArcTan(Link->X-beam->X, Link->Y-beam->X);
					beam->Step = shotStep;*/
					beam = FireLaser(weaponType, laserStartX, laserStartY, 0, shotStep, this->WeaponDamage);
					beam->DrawXOffset = 999; //Draw off-screen
					Audio->PlaySound(shotSFX);
					//beam->DrawXOffset = 999; //Draw off-screen
				}
			}
  
			//Draw laser beam
			if ( beam->isValid() )
			{
				Screen->Line(LASER_LAYER, laserStartX, laserStartY, CenterX(beam), CenterY(beam), laserColour, 1, 0, 0, 0, LASER_OPACITY);
			}
 
			Waitframe();
		}
	}
	
	// Set the weapon's direction based on its angle;
	// Can also makes weapons unblockable
	void LaserDir(eweapon wpn)
	{
	    float angle=wpn->Angle%6.2832;
	    int dir;
	    
	    if(angle<0)
		angle+=6.2832;
	    
	    if(angle<0.3927 || angle>5.8905)
		dir=DIR_RIGHT;
	    else if(angle<1.1781)
		dir=DIR_RIGHTDOWN;
	    else if(angle<1.9635)
		dir=DIR_DOWN;
	    else if(angle<2.7489)
		dir=DIR_LEFTDOWN;
	    else if(angle<3.5343)
		dir=DIR_LEFT;
	    else if(angle<4.3197)
		dir=DIR_LEFTUP;
	    else if(angle<5.1051)
		dir=DIR_UP;
	    else
		dir=DIR_RIGHTUP;
	    wpn->Dir=dir;
	}


	eweapon FireLaser(int weaponID, int x, int y, float angle, int step, int damage)
	{
	    eweapon wpn=Screen->CreateEWeapon(weaponID);
	    wpn->X=x;
	    wpn->Y=y;
	    wpn->Step=step;
	    wpn->Damage=damage;
	    wpn->Angular=true;
	    wpn->Angle=ArcTan(Link->X-x, Link->Y-y)+angle;


	    LaserDir(wpn); 
	    
	    return wpn;
	}

}