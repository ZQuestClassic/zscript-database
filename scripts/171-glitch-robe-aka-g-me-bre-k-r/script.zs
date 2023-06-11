import "std.zh"
import "string.zh"
import "ghost.zh"
import "ffcscript.zh"

const int WPS_NULLBLADE = 88;
const int SFX_NULLSBLADE = 2; //Sword Beam
const int SFX_GAMEBREAKER_OPEN = 52; //Rocket up
const int SFX_GAMEBREAKER_CLOSE = 53; //Rocket Down
const int GAMEBREAKER_BLADES = 13; //Number of sword beams the portals shoot.
const int CMB_TEAR = 32768; //The combo to use for the tear in the fabric of reality. This is 4x4 tiles mind you.

//This boss is no joke... Difficulty Level: Link is Screwed. :/
ffc script GlitchWizard
{
	void run(int enemyID)
	{
		// init
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
 		
		// flags
		//Ghost_SetFlag(GHF_SET_DIRECTION); //Done Manually
		
		// attributes
		int otile = ghost->OriginalTile;
		int position;
		int movestate=1;
		int counter;
		int deathanimation = Ghost_GetAttribute(ghost,0,0); //0 normal, 1 Explode, 2 Flash and Explode
		int chargeTime = Ghost_GetAttribute(ghost,1,120); //Delay Before Opening Portal
		int teleportDelay = Ghost_GetAttribute(ghost,2,76); //Teleport Delay
		bool solidOK = Ghost_GetAttribute(ghost,3,0); //Solid Blocks Okay?
		
		// turn Link into scraps of meat
		while(Ghost_HP > 0) //Should never happen.
		{
			//If Teleporting
			if(movestate==0)
			{
				//Teleporting In
				if(counter==0)
				{
					ghost->OriginalTile = otile;
					ghost->DrawXOffset=0;
					ghost->HitXOffset=0;
				}
				counter++;
				counter%=64;
				if(counter!=0)
					ghost->DrawXOffset = Cond(counter%2, 1000, 0);
				else
				{
					movestate = 1;
				}
			}
			//Charging
			else if(movestate==1)
			{
				//If he got hit stop charging and teleport to new spot far away
				if(Ghost_GotHit())
				{
					movestate==3;
					counter=0;
				}
				//If not keep charging
				else
				{
					if(counter==0)
					{
						ghost->OriginalTile = otile+20;
					}
					counter++;
					counter%=chargeTime;
					if(counter==0)
					{
						movestate=2;
						int args[8]= {ghost->WeaponDamage};
						int name[] = "Gamebreaker";
						int scriptslot = Game->GetFFCScript(name);
						ffc f = RunFFCScriptOrQuit(scriptslot,args);
						f->X = Rand(32,224);
						f->Y = Rand(32,144);
					}
				}
			}
			//Attacking
			else if(movestate==2)
			{
				if(counter==0)
				{
					ghost->OriginalTile = otile+40;
					counter++;
				}
				int name[] = "Gamebreaker";
				if(!CountFFCsRunning(Game->GetFFCScript(name)))
				{
					movestate=3;
				}
			}
			//Teleporting Out
			else if(movestate==3)
			{
				if(counter==0)
					ghost->OriginalTile = otile;
				counter++;
				if(counter < 22) ghost->DrawXOffset = Cond(counter%2, 1000, 0);
				else if(counter == 22)
				{
					ghost->DrawXOffset = 1000;
					ghost->HitXOffset = 1000;
				}
				else if(counter == 22+teleportDelay)
				{
					position = FindSpawnPoint(true, solidOK, false, false);
					Ghost_X = position;
					Ghost_Y = position;
					movestate = 0;
				}
			}
			GWizz_Waitframe(this, ghost, deathanimation);
		}
	}
	void GWizz_Waitframe(ffc this, npc ghost, int deathanimation)
	{
		if(ClockIsActive() || ghost->Stun>0)
		{
			int oldoffsets[2] = {ghost->DrawXOffset,ghost->HitXOffset};
			ghost->DrawXOffset=0;
			ghost->HitXOffset=0;
			do
			{
				Ghost_Waitframe(this,ghost,deathanimation,true);			
			} while(ClockIsActive() || ghost->Stun>0);
			ghost->DrawXOffset=oldoffsets[0];
			ghost->HitXOffset=oldoffsets[1];
		}
		else //we don't need an a second one to run right after the clock exits. That would be bad.
		{
			Ghost_Waitframe(this, ghost, deathanimation, true);
		}
	}
}

ffc script Gamebreaker
{
	void run(int damage)
	{	//Tear apart the fabric of reality!
		float x = CenterX(this)-32;
		float y = CenterY(this)-32;
		TearHole(x,y);
		int oldspicebodyshots = GAMEBREAKER_BLADES;
		//Call forth swords from god only knows where.
		do
		{
			int angle = Randf(PI)-(PI/2);
			eweapon nullblade = FireAimedEWeapon(EW_BEAM, x+24, y+24, angle, 200, damage, WPS_NULLBLADE, SFX_NULLSBLADE, EWF_ROTATE_360);
			oldspicebodyshots--;
			for(int i; i < 32; i++)
				Screen->DrawCombo(2,x,y,CMB_TEAR,4,4,6+(i%4),-1,-1,0,0,0,NULL,0,true,OP_OPAQUE);
			Waitframe(); //Same wait time as normal walker enemy with extra shots
		} while(oldspicebodyshots>0)
		//Not even the G4mE bReaK3r causes permanant damage, thank god.
		RepairHole(x, y);
		//Destroy the culprit.
	}
	void TearHole(float x, float y)
	{
		Game->PlaySound(SFX_GAMEBREAKER_OPEN);
		for(int i=1; i <= 64; i++) //Takes 64 frames to open the tear.
		{
			float newx = x + 32 - Floor(i/2);
			float newy = y + 32 - Floor(i/2);
			Screen->DrawCombo(2,newx,newy,CMB_TEAR,4,4,6+(i%4),i,i,0,0,0,NULL,0,true,OP_OPAQUE);
			Waitframe();
		}
	}
	void RepairHole(float x,float y)
	{
		Game->PlaySound(SFX_GAMEBREAKER_CLOSE);
		for(int i=64; i > 0; i--) //Takes 64 frames to close the tear.
		{
			float newx = x + 32 - Floor(i/2);
			float newy = y + 32 - Floor(i/2);
			Screen->DrawCombo(2,newx,newy,CMB_TEAR,4,4,6+Rand(4),i,i,0,0,0,NULL,0,true,OP_OPAQUE);
			Waitframe();
		}
	}
}