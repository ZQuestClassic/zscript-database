const int BLIND_HEAD = 189;//Floating Heads.
const int SFX_BLIND = 40;
const int SPR_BLIND = 40;

ffc script Blind_the_Thief{
     void run(int enemyID){
         npc n = Ghost_InitAutoGhost(this, enemyID);
         npc n2;
         npc n3;
         npc n4;
         int timer = 0;
         n->Extend = 3;
         int Blind = n->Attributes[10];
         Ghost_TileWidth = 4;
         Ghost_TileHeight = 2;
         Ghost_Transform(this,n,Blind,-1,4,2);
         int Collapse = Blind+1;
         int speed = n->Step;
         bool OneHead = false;
         bool TwoHead = false;
         bool ThreeHead = false;
         Ghost_X = 123;
         Ghost_Y = 80;
         float counter = -1;
         float angle;
         bool StartTimer = false;
         eweapon fireball;
         Ghost_SetHitOffsets(n, 0, 0, 13, 5);
         while(n->HP > 0){
             //If any heads are active, rotate them.
             angle = (angle + 1) % 360;
             counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
             if(OneHead){
                 n2->X = (n->X +32) + 32 * Cos(angle);
                 n2->Y = (n->Y +16) + 32 * Sin(angle);
                 fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 32 * Cos(angle), (n->Y +16) + 32 * Sin(angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                 SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                 SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
             }
             if(TwoHead){
                 n3->X = (n->X +32) + 48 * Cos(-1 * angle);
                 n3->Y = (n->Y +16) + 48 * Sin(-1 * angle);
                 fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 48 * Cos(-1*angle), (n->Y +16) + 48 * Sin(-1*angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                 SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                 SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
             }
             if(ThreeHead){
                 n4->X = (n->X +32) + 64 * Cos(2 * angle);
                 n4->Y = (n->Y +16)+ 64 * Sin(2 * angle);
                 fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 64 * Cos(2*angle), (n->Y +16) + 64 * Sin(2*angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                 SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                 SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
             }   
             if(n->HP < 30 && !OneHead)StartTimer = true;
             if(n->HP < 20 && !TwoHead)StartTimer = true;
             if(n->HP < 10 && !ThreeHead)StartTimer = true;
             if(StartTimer){
                 timer = 600;
                 StartTimer = false;
             }
             if(timer > 0){
                 Ghost_Data = Collapse;
                 n->Step = 0;
                 Ghost_SetAllDefenses(n, NPCDT_IGNORE);
                 //Check to see how many heads have been made and make each one in turn.
                 if(!ThreeHead && TwoHead && OneHead){
                       ThreeHead = true;
                       n4 = Screen->CreateNPC(BLIND_HEAD);
                 }
                 if(!TwoHead && OneHead && !ThreeHead){
                       TwoHead = true;
                       n3 = Screen->CreateNPC(BLIND_HEAD);
                 }
                 if(!OneHead && !TwoHead && !ThreeHead){
                       OneHead = true;
                       n2 = Screen->CreateNPC(BLIND_HEAD);
                 }
                 while(timer >0){
                     angle = (angle + 1) % 360;
                     if(OneHead){
                         n2->X = (n->X +32) + 32 * Cos(angle);
                         n2->Y = (n->Y +16) + 32 * Sin(angle);
                         fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 32 * Cos(angle), (n->Y +16) + 32 * Sin(angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                         SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                         SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                     }
                     if(TwoHead){
                         n3->X = (n->X +32) + 48 * Cos(-1 * angle);
                         n3->Y = (n->Y +16) + 48 * Sin(-1 * angle);
                         fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 48 * Cos(-1*angle), (n->Y +16) + 48 * Sin(-1*angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                         SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                         SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                     }
                     if(ThreeHead){
                         n4->X = (n->X +32) + 64 * Cos(2 * angle);
                         n4->Y = (n->Y +16)+ 64 * Sin(2 * angle);
                         fireball = FireAimedEWeapon(n->Weapon, (n->X +32) + 64 * Cos(2*angle), (n->Y +16) + 64 * Sin(2*angle), angle, 0, n->WeaponDamage, SPR_BLIND, SFX_BLIND, 0);
                         SetEWeaponLifespan(fireball,EWL_TIMER, 60);
                         SetEWeaponDeathEffect(fireball,EWD_VANISH, 0);
                     }   
                     timer--;
                     if(timer<=0)break;
                     Blind_Waitframe(this, n, n2, n3, n4);
                 }
             }
             //Body no longer invulnerable. Recreate main boss.
             Ghost_Data = Blind;
             n->Step = speed;
             Ghost_SetAllDefenses(n, NPCDT_NONE);
             //End of invulnerable loop.
             Blind_Waitframe(this, n, n2, n3, n4);
        }
    }
    void Blind_Waitframe(ffc this, npc ghost, npc head1, npc head2, npc head3){
	if(!Ghost_Waitframe(this, ghost, false, false)){
	     head1->HP = 0;
             head2->HP = 0;
             head3->HP = 0;
	     Ghost_DeathAnimation(this, ghost, 2);
	     Quit();
	}
    }
}