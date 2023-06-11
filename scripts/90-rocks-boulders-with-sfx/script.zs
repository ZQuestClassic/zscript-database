ffc script BoulderSFX
{
    void run(int enemyID)
    {
        npc ghost = Ghost_InitAutoGhost(this, enemyID);
        int oldy = Ghost_Y;
        bool isFalling;
        do 
        {
            if(Ghost_Y == oldy && Ghost_Y < 178 && isFalling)
            {
                isFalling = false;
                Game->PlaySound(ghost->Attributes[1]);
            }
            else
            {
                isFalling = Ghost_Y > oldy;
                oldy = Ghost_Y;
            }
        } while(Ghost_Waitframe2(this, ghost, true, true));
    }
}