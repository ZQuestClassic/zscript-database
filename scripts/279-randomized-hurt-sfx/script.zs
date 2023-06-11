void LinkHurtSounds_Update(int hurtSFX){
	if(hurtSFX[0]==0){ //Link isn't in hurt frames
		if(Link->Action==LA_GOTHURTLAND||Link->Action==LA_GOTHURTWATER){
			int size = SizeOfArray(hurtSFX)-1;
			Game->PlaySound(hurtSFX[Rand(size)+1]); //Play a random sound from the array
			hurtSFX[0] = 1; //Mark Link as in hurt frames
		}
	}
	else{ //Link is in hurt frames
		if(Link->Action!=LA_GOTHURTLAND&&Link->Action!=LA_GOTHURTWATER){
			hurtSFX[0] = 0; //Mark Link as not in hurt frames
		}
	}
}

//SFX for Link getting hurt. You can add more of these and add them to the hurtSFX[] array for more options
const int SFX_LINKHURT1 = 61;
const int SFX_LINKHURT2 = 62;
const int SFX_LINKHURT3 = 63;

global script LinkHurtSounds{
	void run(){
		//The first number in this array should be 0. The rest are the SFX options.
		int hurtSFX[] = {0, SFX_LINKHURT1, SFX_LINKHURT2, SFX_LINKHURT3};
		while(true){
			LinkHurtSounds_Update(hurtSFX);
			Waitframe();
		}
	}
}