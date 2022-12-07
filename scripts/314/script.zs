import "std.zh"
global script Slot_2
{
	void run()
	{
        lweapon overlay;
        int rolltimer;
        int rollwait;
        int randStore;
        int rollSpeed = 300;
        int rollDur = 20; //in frames
        int cooldown = 10;
        int firstSFX = 61;
        int rollSprite = 97; //The first of the 4 rolling sprites (in weapon/misc.)  In order, up, down, left, right.
		while (true)
		{
           if((Link->PressEx1 == false)&&(rolltimer == 0)&&(rollwait > 0)){
                overlay->DeadState = 0;
                Link->CollDetection = true;
                Link->Invisible = false;
            }
            else if(Link->Jump){
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = true;
                    Link->Invisible = false;               
            }
            else if(Link->Action==LA_ATTACKING){
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = true;
                    Link->Invisible = false; 
            }
            else if(Link->Action==LA_SWIMMING){
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = true;
                    Link->Invisible = false; 
            }
            else if(Link->Action==LA_SPINNING){
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = true;
                    Link->Invisible = false; 
            }
            else if(Link->Action==LA_CHARGING){
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = true;
                    Link->Invisible = false; 
            }
            else if((Link->PressEx1 == true)&&(rolltimer == 0)&&(rollwait == 0)&&(Link->Action==LA_WALKING)){
                rolltimer = rollDur;
                rollwait = rollDur + cooldown;
                overlay = Screen->CreateLWeapon(LW_SCRIPT1);
                overlay->Dir = Link->Dir;
                overlay->X = Link->X;
                overlay->Y = Link->Y;
                overlay->CollDetection = false;
                if(Link->Dir == DIR_UP){
                    overlay->UseSprite(rollSprite);
                }
                else if(Link->Dir == DIR_DOWN){
                    overlay->UseSprite(rollSprite + 1);
                }
                else if(Link->Dir == DIR_LEFT){
                    overlay->UseSprite(rollSprite + 2);
                }
                else if(Link->Dir == DIR_RIGHT){
                    overlay->UseSprite(rollSprite + 3);
                }
                Link->CollDetection = false;

                Link->Invisible = true;
                randStore = Rand(1);
                if(randStore == 0){
                    Game->PlaySound(firstSFX);
                }
                }
            else if(rolltimer > 0){
                Link->InputA = false;
                Link->InputB = false;
                if(overlay->isValid() == true){
                    if(CanWalk(overlay->X, overlay->Y, overlay->Dir, rollSpeed/100, false) == true){
                        overlay->Step = rollSpeed;
                    }
                    else{
                        overlay->Step = 0;
                    }
                    Link->X = overlay->X;
                    Link->Y = overlay->Y;
                    rolltimer--;
                }
                else{
                    rolltimer = 0;
                    overlay->DeadState = 0;
                    Link->CollDetection = false;
                    Link->Invisible = false;               
                }
            }
            if(rollwait > 0){
                Link->InputA = false;
                Link->InputB = false;
                rollwait--; 
            }
            if((Link->Action > LA_WALKING)){
                rolltimer = 0;
            }
			Waitframe();
            }                 // end while
        }                  //end void run
}