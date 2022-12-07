//Include these lines at the top of your script file.
//import "std.zh" 
//import "string.zh"
//import "ghost.zh"
 
const int CMB_AUTOWARP = 0;
const int SFX_FLOORMASTER = 0;
 
ffc script Floormaster
{
    void run(int enemyID)
    {
        npc ghost = Ghost_InitAutoGhost(this,enemyID);
        Ghost_SetFlag(GHF_REDUCED_KNOCKBACK);
        Ghost_SetFlag(GHF_KNOCKBACK_4WAY);
        Ghost_SetFlag(GHF_STUN);
        Ghost_SetFlag(GHF_CLOCK);
        Ghost_SetFlag(GHF_IGNORE_SOLIDITY);
        Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
 
        //Variables
        int waittime = ghost->Attributes[5];
        int combo = Ghost_Data;
        float angle = ArcTan(Link->X-Ghost_X,Link->Y-Ghost_Y);
        int homing = ghost->Homing/255;
        int turningFrequency = ghost->Haltrate;
 
        //Disappear and turn off collision.
        ghost->DrawXOffset -= 1000;
        ghost->CollDetection = false;
 
        //Wait
        for(int i; i < waittime; i++)
            Floormaster_Waitframe(this, ghost, combo);
 
        //Restore drawoffset and collision then Surface.
        ghost->DrawXOffset += 1000;
        ghost->CollDetection = true;
        combo=Surface(this, ghost, combo);
 
        while(!(LinkCollision(ghost) && Link->Action == LA_GOTHURTLAND))
        {
            if(Ghost_X < 0 || Ghost_X > 240 || Ghost_Y < 0 || Ghost_Y > 160)
                angle = ArcTan(Link->X-Ghost_X,Link->Y-Ghost_Y);
            if(Rand(16) < turningFrequency)
                angle = TurnTowards(Ghost_X, Ghost_Y, Link->X, Link->Y, angle, homing);
            Ghost_MoveAtAngle(RadtoDeg(angle), ghost->Step/100, 2);
            Floormaster_Waitframe(this, ghost, combo);
        }
 
        //Submerge
        combo=Submerge(this, ghost, combo);
        Link->Invisible = false;
        Link->CollDetection = true;
 
        //Warp
        Link->Action = LA_NONE;
        Link->Dir = DIR_UP;
        int screen = MapToDMap(Game->LastEntranceScreen, Game->LastEntranceDMap);
        int dmap = Game->LastEntranceDMap;
        Screen->SetSideWarp(0, screen, dmap, WT_IWARPOPENWIPE);
        this->Data = CMB_AUTOWARP;
    }
    int Surface(ffc this, npc ghost, int combo)
    {
        int spawn = FindSpawnPoint(true,true,true,true);
        Ghost_X = ComboX(spawn);
        Ghost_Y = ComboY(spawn);
        for(int i; i < 3; i++)
        {
            combo += 2;
            for(int j; j < 24; j++)
                Floormaster_Waitframe(this, ghost, combo);
        }
        return combo;
    }
    int Submerge(ffc this, npc ghost, int combo)
    {
        Game->PlaySound(SFX_FLOORMASTER);
        if(Link->HP <= 0)
            Quit();
        Link->Invisible = true;
        Link->CollDetection = false;
        Ghost_X = Link->X;
        Ghost_Y = Link->Y;
        for(int i; i < 3; i++)
        {
            combo -= 2;
            for(int j; j < 24; j++)
            {
                NoAction();
                Link->InputStart = false;
                Link->InputMap = false;
                Floormaster_Waitframe(this, ghost, combo);
            }
        }
        return combo;
    }
    bool Floormaster_Waitframe(ffc this, npc ghost, int combo)
    {
        if(Link->X >= Ghost_X)
            Ghost_Data = combo + 1;
        else
            Ghost_Data = combo;
        return Ghost_Waitframe(this,ghost,true,true);
    }
}