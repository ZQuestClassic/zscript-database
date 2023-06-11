import "std.zh" //Must have this once at the top of the file

const int splashFreq = 10; //Number of frames between splash SFX
const int grassFreq = 10; //Number of frames between grass SFX
const int grassSFX = 0; //ID of the grass SFX - leave at 0 to disable

global script waterSplash{
	void run(){
		int splashTimer = splashFreq;
		int grassTimer = grassFreq;
		while(true){
			//Shallow water SFX
			if( Screen->ComboT[ComboAt(Link->X+7,Link->Y+15)] == CT_SHALLOWWATER
			&& Link->Action==LA_WALKING
			&& Link->Z == 0 )
			){
				if( splashTimer >= splashFreq ){
					Game->PlaySound(SFX_SPLASH);
					splashTimer = 0;
				}
				splashTimer++;
			}
			else splashTimer = splashFreq;
			//End water SFX code
			
			//Tall grass SFX
			if( ( Screen->ComboT[ComboAt(Link->X+7,Link->Y+15)] == CT_TALLGRASS
			 || Screen->ComboT[ComboAt(Link->X+7,Link->Y+15)] == CT_TALLGRASSC
			 || Screen->ComboT[ComboAt(Link->X+7,Link->Y+15)] == CT_TALLGRASSNEXT )
			&& Link->Action==LA_WALKING
			&& Link->Z == 0
			){
				if( grassTimer >= grassFreq ){
					Game->PlaySound(grassSFX);
					grassTimer = 0;
				}
				grassTimer++;
			}
			else grassTimer = grassFreq;
			//End grass SFX code

			Waitframe(); //Must have this once at the bottom of your while(true) loop
		}
	}
}