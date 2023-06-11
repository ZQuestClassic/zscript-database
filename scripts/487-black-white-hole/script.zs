//A black hole that sucks Link into or push away.
//Requires LinkMovement.zh
//D1 - Suction range
//D2 - suction speed (0-1). Negative for white hole effect
//D3 - 1 - can push Link off screen edge (if D2<0)
//D4 - suction sound ID
//D5 - delay between sounds, in frames
//If combo assigned to FFC changes into another combo in any way, it stops sucking/pushing until it changes back.

ffc script BlackWhiteHole{
	void run (int range, int speed, int flags, int sfx, int soundcounter){
		int origcmb = this->Data;
		float suckx = Link->X;
		float sucky = Link->Y;
		while(true){
			soundcounter--;
			if (soundcounter<=0) soundcounter=this->InitD[4];			
			float dist = Distance(this->X, this->Y, Link->X, Link->Y);
			if (dist<=range && this->Data==origcmb){
				if (soundcounter==this->InitD[4]) Game->PlaySound(sfx);
				float angle = Angle(this->X, this->Y, Link->X, Link->Y);
				suckx = -speed*Cos(angle);
				sucky = -speed*Sin(angle);
				if ((flags&1)>0) LinkMovement_Push2(suckx, sucky);
				else LinkMovement_Push2NoEdge(suckx, sucky);
			}
			Waitframe();
		}
	}
}