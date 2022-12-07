//Swindle_Haggle.zs
//Haggle Choppah by ZoriaRPG
//v0.2 24-Nov-2016

const int SCREEN_D_HAGGLE = 6;
int Haggle(){ return Screen->D[SCREEN_D_HAGGLE]; }
void Haggle(int haggle){ Screen->D[SCREEN_D_HAGGLE] = haggle; }

const int SFX_HAGGLE_GOOD = 27;
const int SFX_HAGGLE_FAIL = 28;
const int SFX_HAGGLE_NORM = 24;

const int HAGGLE = 1;
const int HAGGLE1 = 109;
const int HAGGLE2 = 110;
const int RT_HAGGLE = 10;

//Settings
//Set any of these to '1' t make pressing that button in a normal ZC shop try haggling with the merchant.
const int HAGGLE_BUTTON_B = 1;
const int HAGGLE_BUTTON_A = 1;
const int HAGGLE_BUTTON_R = 0;
const int HAGGLE_BUTTON_L = 1;
const int HAGGLE_BUTTON_EX1 = 0;
const int HAGGLE_BUTTON_EX2 = 0;
const int HAGGLE_BUTTON_EX3 = 0;
const int HAGGLE_BUTTON_EX4 = 0;

void HaggleMedals(int haggle){
	if ( haggle == 1 ) {
		if ( Link->Item[HAGGLE1] ) Link->Item[HAGGLE1] = false;
		if ( Link->Item[HAGGLE2] ) Link->Item[HAGGLE2] = false;
	}
	if ( haggle == 2 ) {
		if ( Link->Item[HAGGLE2] ) Link->Item[HAGGLE2] = false;
		if ( !Link->Item[HAGGLE1] ) Link->Item[HAGGLE1] = true;
	}
	if ( haggle == 3 ) {
		if ( !Link->Item[HAGGLE2] ) Link->Item[HAGGLE2] = true;
	}
}

int HaggleMedals(){ 
	if ( Link->Item[HAGGLE2] ) return 3;
	if ( Link->Item[HAGGLE1] ) return 2;
	return 1;
}

//This is the haggle that you swindle before WaitHaggle()
void DoHaggle(){
	if ( HaggleMedals() != 2 && !CanHaggle() ) { 
		HaggleMedals(2);
	}
	if ( CanHaggle() && Haggle() ) HaggleMedals(Haggle());
	TryHaggle();
}

bool CanHaggle(){
	return ( Screen->RoomType == RT_HAGGLE );
}

void DrawHaggle() { Waitdraw(); }
void WaitHaggle() { Waitframe(); }

void TryHaggle(){
	bool try;
	if ( HAGGLE_BUTTON_B && ( Link->PressB ) ) try = true;
	if ( HAGGLE_BUTTON_A && Link->PressA ) try = true;
	if ( HAGGLE_BUTTON_R && Link->PressR ) try = true;
	if ( HAGGLE_BUTTON_L && Link->PressL ) try = true;
	if ( HAGGLE_BUTTON_EX1 && Link->PressEx1 ) try = true;
	if ( HAGGLE_BUTTON_EX2 && Link->PressEx2 ) try = true;
	if ( HAGGLE_BUTTON_EX3 && Link->PressEx3 ) try = true;
	if ( HAGGLE_BUTTON_EX4 && Link->PressEx4 ) try = true;
	if ( try && !Haggle() && CanHaggle() ){
		Haggle( Rand(3)+1 );
		if ( Haggle() == 1 && SFX_HAGGLE_FAIL ) Game->PlaySound(SFX_HAGGLE_FAIL);
		if ( Haggle() == 2 && SFX_HAGGLE_NORM ) Game->PlaySound(SFX_HAGGLE_NORM);
		if ( Haggle() == 3 && SFX_HAGGLE_GOOD ) Game->PlaySound(SFX_HAGGLE_GOOD);
		for ( int q = 0; q <= 90; q++ ) {
			Link->InputUp = false; Link->PressUp = false;
			Link->InputDown = false; Link->PressDown = false;
			Link->InputLeft = false; Link->PressLeft = false;
			Link->InputRight = false; Link->PressRight = false;
			Link->InputR = false; Link->PressR = false;
			Link->InputL = false; Link->PressL = false;
			Link->InputA = false; Link->PressA = false;
			Link->InputB = false; Link->PressB = false;
			Link->InputEx1 = false; Link->PressEx1 = false;
			Link->InputEx2 = false; Link->PressEx2 = false;
			Link->InputEx3 = false; Link->PressEx3 = false;
			Link->InputEx4 = false; Link->PressEx4 = false;
			WaitHaggle();
		}
		HaggleMedals(Haggle());
		//Prices won't swindle without warping. Ask Mister Owl.
		Link->PitWarp( Game->GetCurDMap(), Game->GetCurScreen() );

	}
}
		
global script SwindleHaggle{
	void run(){
		while(HAGGLE){
			DoHaggle();
			DrawHaggle();
			WaitHaggle();
		}
	}
}