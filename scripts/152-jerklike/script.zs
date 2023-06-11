import"std.zh" // This needs to be at the top of your script file. If it's already there, there's no need to put it twice.
 
 
// The constants below need to be set manually.
const int SFX_JerkLike = 56;
const int COMBO_MagicShield = 406;
const int CSET_MagicShield = 6;
const int COMBO_Transparent = 1;
 
 
// Other scripts use the "DistanceLink" variable below. If you already have this in your script file, there's no need to put it twice.
int DistanceLink (int x, int y){
    return Distance(Link->X+8, Link->Y+8, x, y);
}
 

ffc script JerkLike{
    void run(int enemyID, int howclose, int droppercentage){
        Waitframes(5);
        npc JerkLike=Screen->LoadNPC(enemyID);
        if(JerkLike->isValid()==false)Quit();
        bool ShieldEaten=false;
        while(true){
            if(JerkLike->HP<=0){
                int dropchance=Rand(100)+1;
                if(dropchance<=droppercentage&&ShieldEaten==true){
                    item i=Screen->CreateItem( 8);
                    SetItemPickup(i, IP_HOLDUP, true);
                    i->X=JerkLike->X;
                    i->Y=JerkLike->Y;
                }
                Quit();
            }
            if((DistanceLink(JerkLike->X+8, JerkLike->Y+ 8)<=howclose)&&(Link->Item[8]==true)){
                Game->PlaySound(SFX_JerkLike);
                Link->Item[8]=false;
                ShieldEaten=true;
                this->X=Link->X+8;
                this->Y=Link->Y+8;
                this->Data=COMBO_MagicShield;
                this->CSet=CSET_MagicShield;
                while(this->X!=JerkLike->X||this->Y!=JerkLike->Y){
                    if(this->X<JerkLike->X)this->X++;
                    if(this->X>JerkLike->X)this->X--;
                    if(this->Y<JerkLike->Y)this->Y++;
                    if(this->Y>JerkLike->Y)this->Y--;
                    Waitframe();
                }
                this->Data=COMBO_Transparent;
            }
        Waitframe();
        }
    }
}