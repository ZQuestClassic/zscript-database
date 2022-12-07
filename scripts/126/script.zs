import "std.zh"
import "ffcscript.zh"

item script AutofireBow
{
    void run(int fireRate, int sprite, int itemID)
    {
	int string[] = "AutofireBowFFC";
	int ffcscript = Game->GetFFCScript(string);
        if(CountFFCsRunning(ffcscript)==0)
        {
            int args[8] = {fireRate, sprite, itemID};
            RunFFCScript(ffcscript, args);
        }
    }
}

ffc script AutofireBowFFC
{
    void run(int fireRate, int sprite, int itemID)
    {
        int timer;
        itemdata itmdata = Game->LoadItemData(GetHighestLevelInventoryItem(IC_BOW));
        if(itmdata->InitD[0] != 1) Quit();
        int speed = itmdata->Power*200; //Base Arrow Speed is 200
        itmdata = Game->LoadItemData(itemID);
        LINK_AUTOFIRE = Link->Dir;
        while(UsingItem(itemID) && 
              (Link->Item[I_QUIVER4] || Game->Counter[CR_ARROWS] > 0))
             //(Link->Item[I_WALLET3] || Game->Counter[CR_RUPEES] > 0))
        {            
            timer = (timer+1)%fireRate;
            if(timer==0)
            {
		if(!Link->Item[I_QUIVER4]) Game->Counter[CR_ARROWS]--;
		//if(!Link->Item[I_WALLET3]) Game->Counter[CR_RUPEES]--;
                lweapon l = Screen->CreateLWeapon(LW_ARROW);
                l->X = Link->X+InFrontX(Link->Dir,-3);
                l->Y = Link->Y+InFrontY(Link->Dir,-3);
                l->Dir = LINK_AUTOFIRE;
                l->Step = speed;
                l->UseSprite(sprite);
                if(Link->Dir==DIR_DOWN) l->Flip=3;
                else if(Link->Dir==DIR_LEFT) l->Flip=7;
                else if(Link->Dir==DIR_RIGHT) l->Flip=4;
                l->Damage = itmdata->Power*2;
                Game->PlaySound(itmdata->UseSound);
            }
            Waitframe();
        }
        LINK_AUTOFIRE = -1;
    }
    int GetHighestLevelInventoryItem(int itemclass)
    {
	itemdata id;
        int ret = -1;
	int curlevel = -1000;
	//143 is default max items, increase if you add lots of your own
	for(int i = 0; i < 143; i++)
	{
		id = Game->LoadItemData(i);
		if(id->Family != itemclass)
			continue;
		if(!Link->Item[i])
			continue;
		if(id->Level > curlevel)
		{
			curlevel = id->Level;
			ret = i;
		}
	}
	return ret;
    }
}

int LINK_AUTOFIRE;

global script slot2
{
    void run()
    {
        LINK_AUTOFIRE=-1;
        while(true)
        {
            Waitdraw();
            if(LINK_AUTOFIRE != -1) Link->Dir = LINK_AUTOFIRE;
            Waitframe();
        }
    }
}