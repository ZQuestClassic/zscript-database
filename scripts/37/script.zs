//eSword.z
//makes an enemy and has it hold a weapon IF screen->D0 is 0
//arguments: 0=which enemy, 1=x, 2=y. 3=how many pixels ahead of enemy, 4=sprite to use for weapon, 5=how much damage in quarter hearts, 6=delay before forming new if hit something
ffc script eSword{
	void run(int enemy, int x0, int y0, int forward, int sprite, int hurts, int delay){
		if(Screen->D[0]==0){
			npc knight=CreateNPCAt(enemy, x0, y0);
			eweapon sword=CreateEWeaponAt(EW_ARROW,knight->X,knight->Y);
			sword->UseSprite(sprite);
			sword->Dir=DIR_UP;
			sword->Damage=hurts;
			sword->HitXOffset=0;
			sword->HitYOffset=0;
			sword->HitWidth=16;
			sword->HitHeight=16;
			while(knight->isValid()){
				if(!sword->isValid()){
					Waitframes(delay);
					sword=CreateEWeaponAt(EW_ARROW,knight->X,knight->Y);
					sword->UseSprite(sprite);
					sword->Damage=hurts;
					sword->Damage=hurts;
					sword->HitXOffset=0;
					sword->HitYOffset=0;
					sword->HitWidth=16;
					sword->HitHeight=16;
					for(int i=0; i++; i<forward){
						if(!sword->isValid())break;
						if(knight->Dir==DIR_UP){
							sword->X=knight->X;
							sword->Y=knight->Y-i;
							if(sword->Dir!=DIR_UP){
								sword->Dir=DIR_UP;
								sword->UseSprite(sprite);
								sword->Flip=0;
							}
						} else if(knight->Dir==DIR_DOWN){
							sword->X=knight->X;
							sword->Y=knight->Y+i;
							if(sword->Dir!=DIR_DOWN){
								sword->Dir=DIR_DOWN;
								sword->UseSprite(sprite);
								sword->Flip=2;
							}
						} else if(knight->Dir==DIR_LEFT||knight->Dir==DIR_LEFTUP||knight->Dir==DIR_LEFTDOWN){
							sword->X=knight->X-i;
							sword->Y=knight->Y;
							if(sword->Dir!=DIR_LEFT){
								sword->Dir=DIR_LEFT;
								sword->UseSprite(sprite);
								sword->OriginalTile+=sword->NumFrames+intbool(sword->NumFrames==0);
								sword->Tile=sword->OriginalTile;
								sword->Flip=1;
							}
						} else {
							sword->X=knight->X+i;
							sword->Y=knight->Y;
							if(sword->Dir!=DIR_RIGHT){
								sword->Dir=DIR_RIGHT;
								sword->UseSprite(sprite);
								sword->OriginalTile+=sword->NumFrames+intbool(sword->NumFrames==0);
								sword->Tile=sword->OriginalTile;
								sword->Flip=0;
							}
						}
						Waitframe();
					}
				} else {
					if(knight->Dir==DIR_UP){
						sword->X=knight->X;
						sword->Y=knight->Y-forward;
						if(sword->Dir!=DIR_UP){
							sword->Dir=DIR_UP;
							sword->UseSprite(sprite);
							sword->Flip=0;
						}
					} else if(knight->Dir==DIR_DOWN){
						sword->X=knight->X;
						sword->Y=knight->Y+forward;
						if(sword->Dir!=DIR_DOWN){
							sword->Dir=DIR_DOWN;
							sword->UseSprite(sprite);
							sword->Flip=2;
						}
					} else if(knight->Dir==DIR_LEFT||knight->Dir==DIR_LEFTUP||knight->Dir==DIR_LEFTDOWN){
						sword->X=knight->X-forward;
						sword->Y=knight->Y;
						if(sword->Dir!=DIR_LEFT){
							sword->Dir=DIR_LEFT;
							sword->UseSprite(sprite);
							sword->OriginalTile+=sword->NumFrames+intbool(sword->NumFrames==0);
							sword->Tile=sword->OriginalTile;
							sword->Flip=1;
						}
					} else {
						sword->X=knight->X+forward;
						sword->Y=knight->Y;
						if(sword->Dir!=DIR_RIGHT){
							sword->Dir=DIR_RIGHT;
							sword->UseSprite(sprite);
							sword->OriginalTile+=sword->NumFrames+intbool(sword->NumFrames==0);
							sword->Tile=sword->OriginalTile;
							sword->Flip=0;
						}
					}
				Waitframe();
				}
			}
			if(sword->isValid()) sword->DeadState=0;
		}
	}
}

int intbool(bool ean){
	if(ean)return 1;
	return 0;
}