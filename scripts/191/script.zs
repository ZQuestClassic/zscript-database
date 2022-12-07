const int TAIL = 183;//Enemy ID for tail
const int TAIL_SPIKE = 191;//Enemy Id for spiked tail segment.

ffc script Nightmare{
    void run(int enemyID){
         npc n = Ghost_InitAutoGhost(this,enemyID);
         Ghost_X= 123;
         Ghost_Y = 80;
         Ghost_SetPosition(this, n);
         npc n2= Screen->CreateNPC(TAIL);
         npc n3= Screen->CreateNPC(TAIL_SPIKE);
         npc n4= Screen->CreateNPC(TAIL);
         npc n5= Screen->CreateNPC(TAIL_SPIKE);
         npc n6= Screen->CreateNPC(TAIL);
         npc n7= Screen->CreateNPC(TAIL);
         n->Extend =3;
         Ghost_TileWidth = 2;
         Ghost_TileHeight = 2;
         int combo = n->Attributes[10];
         Ghost_Transform(this,n,combo,-1,2,2);
         float angle;
         float angle2;
         int angle_offset;
         float counter = -1;
         while(n->HP>0){
             angle = (angle + 1) % 360;
             angle2= (angle2- 1) % 360;
             angle_offset = (angle_offset+1) % 360;
             n2->X = (n->X+8)+ 28 * Cos(angle);
             n2->Y = (n->Y+8) + 28 * Sin(angle);
             n3->X= (n->X+8) + 60 * Cos(angle);
             n3->Y= (n->Y+8) + 60 * Sin(angle);
             n4->X= (n->X+8) + 28 * Cos(angle2-angle_offset);
             n4->Y= (n->Y+8) + 28 * Sin(angle2-angle_offset);
             n5->X= (n->X+8) + 60 * Cos(angle2-angle_offset);
             n5->Y= (n->Y+8) + 60 * Sin(angle2-angle_offset);
             n6->Y = (n->Y+8) + 44 * Sin(angle);
             n6->X = (n->X+8) + 44 * Cos(angle);
             n7->Y= (n->Y+8) + 44 * Sin(angle2-angle_offset);
             n7->X= (n->X+8) + 44 * Cos(angle2-angle_offset);
             counter = Ghost_HaltingWalk4(counter, n->Step, n->Rate, n->Homing, 2, n->Haltrate, 45);    
             Nightmare_Waitframe(this, n, n2,n3,n4,n5,n6,n7);
         }
    }
    void Nightmare_Waitframe(ffc this, npc ghost, npc tail1, npc tail2, npc tail3, npc tail4,npc tail5,npc tail6){
	if(!Ghost_Waitframe(this, ghost, false, false)){
	     tail1->HP = 0;
             tail2->HP = 0;
             tail3->HP = 0;
             tail4->HP = 0;
             tail5->HP = 0;
             tail6->HP = 0;
	     Ghost_DeathAnimation(this, ghost, 2);
	     Quit();
	}
    }
}