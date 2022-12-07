//import "std.zh" //You need these once at the top of your script file
//import "ffcscript.zh"

const int WPS_BLAST = 9; //Bomb blast sprite
const int WPS_SHADOW = 50; //Shadow sprite
const int CR_GRENADES = 2; //Defaults to bombs; check the CR_ section of std.zh

//D0: Damage to deal
//D1: Distance to travel (60)
//D2: Max height (18)
//D3: Sprite to use
//D4: # of grenade FFC script slot
item script grenade{
	void run ( int damage, int distance, int height, int sprite ){
		int ffcScriptName[] = "grenadeFFC";
		int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
		if (Game->Counter[CR_GRENADES] && !CountFFCsRunning(ffcScriptNum)){ //If Link has bombs and there are no grenades out
			int args[] = {damage, distance, height, sprite};
			Game->Counter[CR_GRENADES]--;
			RunFFCScript(ffcScriptNum, args);
		}
	}
}

ffc script grenadeFFC{
	void run ( int damage, int distance, int height, int sprite ){
		Game->PlaySound(SFX_JUMP);
		Link->Action = LA_ATTACKING;
		lweapon grenade = NextToLink(LW_SCRIPT1, 1); //Make the grenade
		grenade->UseSprite(sprite); //Add a sprite
		grenade->Z = 1; //In the air
		grenade->Step = 200;
		lweapon shadow = CreateLWeaponAt(LW_SPARKLE, grenade->X, grenade->Y);
		shadow->UseSprite(WPS_SHADOW);
		int curDistance;
		bool collision;
		while ( !collision && grenade->Z > 0 ){ //While in the air
			if ( !CanWalk(grenade->X, grenade->Y, grenade->Dir, grenade->Step/100, false) ){
				grenade->Step = 0; //If it hits a wall, stop moving forward
				grenade->Z--; //Start moving down
			}
			else{ //Otherwise adjust height normally
				curDistance++;
				grenade->Z = height * Sin(360*curDistance/distance); //Thanks Imzogelmo for the script that showed me how sinusoidal motion works
			}
			for ( int i = 1; i <= Screen->NumNPCs(); i++ ){
				npc enem = Screen->LoadNPC(i);
				if ( Collision(enem, grenade) ){
					collision = true;
					break;
				}
			}
			shadow->X = grenade->X; //Place the shadow under the grenade
			shadow->Y = grenade->Y;
			shadow->DeadState = WDS_ALIVE;

			Waitframe();
		}
		if ( !grenade->isValid() ) return; //If grenade went offscreen or vanished somehow, quit
		Game->PlaySound(SFX_BOMB);
		lweapon explosion = CreateLWeaponAt(LW_BOMBBLAST, grenade->X, grenade->Y); //Put the explosion on the grenade
		explosion->UseSprite(WPS_BLAST);
		explosion->Damage = damage;
		//if ( DistanceLink(grenade->X+8, grenade->Y+ 8) <= 18 ) explosion->Damage /= 4; //Explosion does less damage if it hurts Link
		grenade->DeadState = WDS_DEAD;
	}
}