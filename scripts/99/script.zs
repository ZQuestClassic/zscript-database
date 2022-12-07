item script ShootBetterFire{

void run(int flamesprite, int speedone, int speedtwo, int speedthree, int damage, int soundeffect){

//D0 - weapon sprite to use for the flames; the usual flame sprite is 12
//D1 - speed of first flame; I recommend 140
//D2 - speed of second flame; I recommend 90 
//D3 - speed of third flame; I recommend 40
//D4 - damage caused by flames
//D5 - what sound to play; the usual sound for fire is 13

        //The first flame.
lweapon fireone = NextToLink(LW_FIRE,0);
Game -> PlaySound (soundeffect);
fireone->Dir = Link->Dir;
fireone->Step = speedone;
fireone->UseSprite(flamesprite);
fireone->Damage = damage;
        //The second flame.
lweapon firetwo = NextToLink(LW_FIRE,0);
firetwo->Dir = Link->Dir;
firetwo->Step = speedtwo;
firetwo->UseSprite(flamesprite);
firetwo->Damage = damage;
        //The third flame.
lweapon firethree = NextToLink(LW_FIRE,0);
firethree->Dir = Link->Dir;
firethree->Step = speedthree;
firethree->UseSprite(flamesprite);
firethree->Damage = damage;
        //The above format for each flame can be imitated for more flames, or removed for fewer flames.

}

}