import "std.zh"

int TARGET_COUNTER = CR_SCRIPT1;

global script globalscript{
    void run(){
         Game->MCounter[TARGET_COUNTER] = 1000;
    }
}

ffc script Target{
    void run(int points, int lw){
        bool isHit = false;
        float SpeedX = this->Vx;
        float SpeedY = this->Vy;
        bool MovingLeft = false;
        bool MovingRight = false;
        bool MovingUp = false;
        bool MovingDown = false;
        while(!isHit){
            for (int i = 1; i <= Screen->NumLWeapons(); i++){
                lweapon w = Screen->LoadLWeapon(i);
                if (w->ID == lw && Collision(this, w))isHit = true;
            }
            if(this->X <= 208 && !MovingLeft){
                this->Vx = SpeedX;
                MovingRight = true;
            }
            else if (this->X >= 32 && !MovingRight){
                this->Vx = -1 * SpeedX;
                MovingLeft = true;
            }
            else if (this->X >= 208) MovingRight = false;
            else if (this->X <= 32)MovingLeft = false;
            if(this->Y <= 128 && !MovingDown){
                 this->Vy = SpeedY;
                 MovingUp = true;
            }
            else if (this->Y >= 32 && !MovingUp){
                 this->Vy = -1 * SpeedY;
                 MovingDown = true;
            }
            else if (this->Y >= 128)MovingUp = false;
            else if (this->Y <= 32)MovingDown = false;
            Waitframe();
        }
        if(isHit){
            Game->Counter[TARGET_COUNTER] += points;
            this->Data = 0;
        }
    }
}

ffc script Target_Game{
    void run(int goal, int prize, int prize_message, int scriptNum){
        item reward;
        bool win = false;
        Game->Counter[TARGET_COUNTER] = 0;
        while(!win && !Screen->State[ST_SECRET]){
            if(Game->Counter[TARGET_COUNTER] >= goal)win = true;
            Waitframe();
        }
        if(win){
            reward = Screen->CreateItem(prize);
            reward->X = Link->X;
            reward->Y = Link->Y;
            reward->Pickup |= IP_HOLDUP;
            Screen->Message(prize_message);
            for(int i = 1; i<32;i++){
                ffc f;
                if(f->Script == scriptNum)f->Data = 0;
            }
            Screen->State[ST_SECRET] = true;
        }
        
    }
}