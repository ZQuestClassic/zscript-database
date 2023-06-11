const int GOLEM_SFX_FIST = 61;
const int GOLEM_SFX_LASER = 62;
 
ffc script IceGolem
{
    void run(int enemyID)
    {
        //init
        npc ghost;
        ghost = Ghost_InitAutoGhost(this, enemyID);
        this->Flags[FFCF_CARRYOVER] = true;
 
        //reposition and transform
        Ghost_X = 120;
        Ghost_Y = 64;
        Ghost_Transform(this, ghost, -1, -1, 3, 3);
        Ghost_SetHitOffsets(ghost, 16, 0, 8, 8);
 
        //Store the starting combo.
        int baseCombo = Ghost_Data;
 
        //flags
        Ghost_SetFlag(GHF_SET_DIRECTION);
        Ghost_SetFlag(GHF_4WAY);
 
        //movement variables
        float counter = -1;
        int step = ghost->Step;
        int rate = ghost->Rate;
        int homing = ghost->Homing;
        int hunger = ghost->Hunger;
        int haltrate = ghost->Haltrate;
        int halttime = 48;
 
        //eweapon variables
        int fistStep = Ghost_GetAttribute(ghost, 0, 200);
        int fistSprite = Ghost_GetAttribute(ghost, 1, 88);
        int laserStep = Ghost_GetAttribute(ghost, 2, 400);
        int laserSprite = Ghost_GetAttribute(ghost, 3, 89);
        int laserChance = Ghost_GetAttribute(ghost, 4, haltrate, 1, 16);
        bool laser;
 
        //Spawn
        Ghost_SpawnAnimationPuff(this, ghost);
 
        //behavior
        while(Ghost_HP > 0)
        {
            int dir = Ghost_Dir;
            counter = Ghost_HaltingWalk4(counter, step, rate, homing, hunger, haltrate, halttime);
            if(counter>>0 > 0)
            {
                if(counter==halttime)
                {
 
                    if(Rand(16) < laserChance)
                    {
                        Ghost_Data = baseCombo + 8;
                        dir = RadianAngleDir8(ArcTan(Link->X-Ghost_X+8, Link->Y-Ghost_Y+4));
                        laser = true;
                    }
                    else
                    {
                        Ghost_Data = baseCombo + 4;
                        dir = RadianAngleDir4(ArcTan(Link->X-Ghost_X, Link->Y-Ghost_Y));
                        Link->PitWarp(Game->GetCurDMap(), Game->GetCurDMapScreen());
                    }
                }
                else if(counter == halttime/2)
                {
                    if(laser)
                    {
                        laser = false;
                        FireAimedEWeapon(EW_SCRIPT1, Ghost_X + 16, Ghost_Y, 0, laserStep, ghost->WeaponDamage,
                                            laserSprite, GOLEM_SFX_LASER, EWF_UNBLOCKABLE| EWF_ROTATE_360);
                    }
                    else
                        RocketFist(ghost, fistStep, fistSprite, ghost->WeaponDamage);
                }
                Ghost_ForceDir(dir);
            }
            else
            {
                Ghost_Data = baseCombo;
            }
 
            Ghost_Waitframe(this, ghost, 0, true);
        }
    }
    void RocketFist(npc ghost, int step, int sprite, int damage)
    {
        int x = Ghost_X+ghost->DrawXOffset;
        int y = Ghost_Y+ghost->DrawYOffset;
        int w = 1;
        int h = 1;
        int xdiff;
        int ydiff;
 
        if(Ghost_Dir == DIR_UP)
        {
            x += 5;
            h = 2;
            xdiff = 24;
        }
        else if(Ghost_Dir == DIR_DOWN)
        {
            x += 5;
            y += 7;
            h  = 2;
            xdiff = 24;
        }
        else if(Ghost_Dir == DIR_LEFT)
        {
            y += 1;
            w = 2;
            ydiff = 8;
        }
        else if(Ghost_Dir == DIR_RIGHT)
        {
            x += 16;
            y += 1;
            w = 2;
            ydiff = 8;
        }
        else
            return; //invalid direction.
 
        eweapon fist[2];
        fist[0] = FireBigNonAngularEWeapon(EW_SCRIPT1, x, y, Ghost_Dir, step, damage, sprite, 0, EWF_UNBLOCKABLE, w, h);
        fist[1] = FireBigNonAngularEWeapon(EW_SCRIPT1, x+xdiff, y+ydiff, Ghost_Dir, step, damage, sprite, 0, EWF_UNBLOCKABLE, w, h);
 
        for(int i; i < 2; i++)
        {
            if(Ghost_Dir==DIR_DOWN)
                fist[i]->OriginalTile += 2;
            else if(Ghost_Dir==DIR_LEFT)
                fist[i]->OriginalTile += 4;
            else if(Ghost_Dir==DIR_RIGHT)
                fist[i]->OriginalTile += 8;
        }
 
        Game->PlaySound(GOLEM_SFX_FIST);
    }
}