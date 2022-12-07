const int I_STUNRING = 123;
const int FROZEN_TIME = 60;

ffc script Hellrobe
{
    void run(int enemyID)
    {
        npc ghost = Ghost_InitAutoGhost(this,enemyID);
        Ghost_SetFlag(GHF_NORMAL);
        int OTile = ghost->OriginalTile;
        int scriptName[] = "SnowmanLink";
        int scriptNum = Game->GetFFCScript(scriptName);
        int wizzrobeIDs[5] = {NPC_WIZZROBEFIRE, NPC_WIZZROBEBAT, NPC_WIZZROBEMIRR, NPC_WIZZROBEWIND, enemyID};
        int formTime = ghost->Attributes[5];
        int clk = formTime;
		int defenses[18];
		Ghost_StoreDefenses(ghost, defenses);

        Ghost_SpawnAnimationPuff(this,ghost);

        while(true)
        {
            if(ghost->ID == enemyID)
            {
                for(int i = Screen->NumEWeapons(); i > 0; i--)
                {
                    eweapon e = Screen->LoadEWeapon(i);
                    if(e->ID == EW_BEAM)
                    {
                        eweapon icemagic = FireNonAngularEWeapon(EW_SCRIPT1, e->X, e->Y, e->Dir, e->Step, e->Damage, 83, SFX_ICE, EWF_ROTATE);
                        SetEWeaponLifespan(icemagic, EWL_NEAR_LINK, 12);
                        SetEWeaponDeathEffect(icemagic, EWD_RUN_SCRIPT, scriptNum);
                        icemagic->CollDetection = false;
                        e->DeadState=WDS_DEAD;
                    }
                }
            }
            clk--;
            if(clk==0)
            {
                clk = formTime;
                npc newghost = Screen->CreateNPC(wizzrobeIDs[Rand(5)]);
                newghost->OriginalTile = OTile;
                if(newghost->Step!=0) newghost->OriginalTile += 60;
                newghost->CSet = Ghost_CSet;
                Ghost_ReplaceNPC(ghost, newghost, true);
                ghost->HP = -1000;
                ghost = newghost;
                Ghost_SetDefenses(ghost, defenses);
            }
            Ghost_Waitframe2(this, ghost, 1, true);
        }
    }
}

ffc script SnowmanLink
{
    void run(int weaponNum)
    {
        eweapon wpn = GetAssociatedEWeapon(weaponNum);
        wpn->DeadState = WDS_DEAD;
        if(!LinkCollision(wpn)) Quit();
        if(Link->Item[I_STUNRING]) Quit();
        Link->Item[I_STUNRING] = true;
        int stuntime = FROZEN_TIME;
        Link->HP -= wpn->Damage;
        Game->PlaySound(SFX_OUCH);
        while(stuntime>0)
        {
            stuntime--;
            WaitNoAction();
        }
        Link->Item[I_STUNRING] = false;
    }    
}