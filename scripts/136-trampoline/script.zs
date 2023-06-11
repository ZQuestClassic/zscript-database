const int TRAMPOLINE_ANIMATION_FRAMES = 10; //The number of frames the trampoline animates after being jumped on

//Combo Setup:
//Combo 1: Trampoline - Still
//Combo 2: Trampoline - Bouncing
//D0: How high the trampoline launches Link
//D1: The number of the flag marking combos Link can jump over.

ffc script Trampoline{
	bool CanWalkFlag(int flag, int x, int y, int dir, int step, bool full_tile) {
		int c=8;
		int xx = x+15;
		int yy = y+15;
		if(full_tile) c=0;
		if(dir==0) return y-step>0&&(ComboFI(x,y+c-step, flag)||ComboFI(x+8,y+c-step, flag)||ComboFI(xx,y+c-step, flag));
		else if(dir==1) return yy+step<176&&(ComboFI(x,yy+step, flag)||ComboFI(x+8,yy+step, flag)||ComboFI(xx,yy+step, flag));
		else if(dir==2) return x-step>0&&(ComboFI(x-step,y+c, flag)||ComboFI(x-step,y+c+7, flag)||ComboFI(x-step,yy, flag));
		else if(dir==3) return xx+step<256&&(ComboFI(xx+step,y+c, flag)||ComboFI(xx+step,y+c+7, flag)||ComboFI(xx+step,yy, flag));
		return false; //invalid direction
	}
	void run(int JumpHeight, int Flag){
		int Combo = this->Data;
		int OldX;
		int OldY;
		int AnimCounter = 0;
		while(true){
			if(this->Data!=Combo)
				this->Data = Combo;
			if(SquareCollision(Link->X+4, Link->Y+4, 8, this->X+4, this->Y+4, 8)&&Link->Z==0){
				Game->PlaySound(SFX_JUMP);
				Link->Jump = JumpHeight;
				OldX = Link->X;
				OldY = Link->Y;
				this->Data = Combo+1;
				AnimCounter = TRAMPOLINE_ANIMATION_FRAMES;
				do{
					if(AnimCounter>0)	
						AnimCounter--;
					else
						this->Data = Combo;
					bool Moving = false;
					if(Link->InputUp&&(CanWalk(Link->X, Link->Y, DIR_UP, 1.5, false)||CanWalkFlag(Flag, Link->X, Link->Y, DIR_UP, 1.5, false))){
						OldY -= 1.5;
						Moving = true;
					}
					else if(Link->InputDown&&(CanWalk(Link->X, Link->Y, DIR_DOWN, 1.5, false)||CanWalkFlag(Flag, Link->X, Link->Y, DIR_DOWN, 1.5, false))){
						OldY += 1.5;
						Moving = true;
					}
					if(Link->InputLeft&&(CanWalk(Link->X, Link->Y, DIR_LEFT, 1.5, false)||CanWalkFlag(Flag, Link->X, Link->Y, DIR_LEFT, 1.5, false))){
						OldX -= 1.5;
						Moving = true;
					}
					else if(Link->InputRight&&(CanWalk(Link->X, Link->Y, DIR_RIGHT, 1.5, false)||CanWalkFlag(Flag, Link->X, Link->Y, DIR_RIGHT, 1.5, false))){
						OldX += 1.5;
						Moving = true;
					}
					if(Moving){
						Link->X = OldX;
						Link->Y = OldY;
					}
					else{
						OldX = Link->X;
						OldY = Link->Y;
					}
					Waitframe();
				}while(Link->Z>0);
			}
			Waitframe();
		}
	}
}