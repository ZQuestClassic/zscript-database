import "std.zh"
//start OcarinaScripts
//CURRENT VERSION 1.2
//CTRL+F for "//CHANGE//" to find things that must be changed for the script to function. CTRL+F "//CUSTOMSONG//" to find the places that must be changed to add custom songs.
//start GLOBAL SampleGlobal
//A combo representing the pressed button, with a transparent background //CHANGE//
const int NOTECOMBO_A = 0;
const int NOTECOMBO_DOWN = 0;
const int NOTECOMBO_RIGHT = 0;
const int NOTECOMBO_LEFT = 0;
const int NOTECOMBO_UP = 0;
//The CSet to draw the given combo in //CHANGE//
const int NOTECSET_A = 0;
const int NOTECSET_DOWN = 0;
const int NOTECSET_RIGHT = 0;
const int NOTECSET_LEFT = 0;
const int NOTECSET_UP = 0;
//The SFX id for the given note SFX //CHANGE// (or use the default IDs, just be sure to use the same ones in ZQuest!)
const int NOTESOUND_A = 200;
const int NOTESOUND_DOWN = 201;
const int NOTESOUND_RIGHT = 202;
const int NOTESOUND_LEFT = 203;
const int NOTESOUND_UP = 204;

bool DISPLAYTEXTONSONGLEARN = true; //CHANGE// Set to false to not display a song learned message.
//Sound FX to play if the played song is not a valid song //CHANGE//
const int SFX_ERROR = 0;
//List of songs:
int SONGNOTES_SongOfTime[] = {3,1,2,3,1,2,0,0};
int SONGNOTES_ZeldasLullaby[] = {4,5,3,4,5,3,0,0};
int SONGNOTES_EponasSong[] = {5,4,3,5,4,3,0,0};
int SONGNOTES_SariasSong[] = {2,3,4,2,3,4,0,0};
int SONGNOTES_SongOfStorms[] = {1,2,5,1,2,5,0,0};
int SONGNOTES_SunSong[] = {3,2,5,3,2,5,0,0};
int SONGNOTES_MinuetOfForest[] = {1,5,4,3,4,3,0,0};
int SONGNOTES_BoleroOfFire[] = {2,1,2,1,3,2,3,2};
int SONGNOTES_SerenadeOfWater[] = {1,2,3,3,4,0,0,0};
int SONGNOTES_NocturneOfShadow[] = {4,3,3,1,4,3,2,0};
int SONGNOTES_RequiemOfSpirit[] = {1,2,1,3,2,1,0,0};
int SONGNOTES_PreludeOfLight[] = {5,3,5,3,4,5,0,0};
int SONGNOTES_GoronsLullaby[] = {1,3,4,1,3,4,3,1};
int SONGNOTES_OathToOrder[] = {3,2,1,2,3,5,0,0};
int SONGNOTES_SongOfSoaring[] = {2,4,5,2,4,5,0,0};
int SONGNOTES_SongOfHealing[] = {4,3,2,4,3,2,0,0};
int SONGNOTES_ElegyOfEmptiness[] = {3,4,3,2,3,5,4,0};
int SONGNOTES_NewWaveBossaNova[] = {4,5,4,3,2,4,3,0};
int SONGNOTES_SongOfDoubleTime[] = {3,3,1,1,2,2,0,0};
int SONGNOTES_SongOfInvertedTime[] = {2,1,3,2,1,3,0,0};
int SONGNOTES_SonataOfAwakening[] = {5,4,5,4,1,3,1,0};
int SONGNOTES_ScarecrowsSong[8];
//Add custom songs:
//Put a name directly after the underscore, and numbers for notes in each spot.
//A=1,DOWN=2,RIGHT=3,LEFT=4,UP=5, and if the song is less than 8 notes, fill the ending spots with 0s. The // before the line of code must also be removed for the song to function.
//int[] SONGNOTES_ = {,,,,,,,};
//Song indexes
const int SONG_SongOfTime = 0;
const int SONG_ZeldasLullaby = 1;
const int SONG_EponasSong = 2;
const int SONG_SariasSong = 3;
const int SONG_SongOfStorms = 4;
const int SONG_SunSong = 5;
const int SONG_MinuetOfForest = 6;
const int SONG_BoleroOfFire = 7;
const int SONG_SerenadeOfWater = 8;
const int SONG_NocturneOfShadow = 9;
const int SONG_RequiemOfSpirit = 10;
const int SONG_PreludeOfLight = 11;
const int SONG_GoronsLullaby = 12;
const int SONG_OathToOrder = 13;
const int SONG_SongOfSoaring = 14;
const int SONG_SongOfHealing = 15;
const int SONG_ElegyOfEmptiness = 16;
const int SONG_NewWaveBossaNova = 17;
const int SONG_SongOfDoubleTime = 18;
const int SONG_SongOfInvertedTime = 19;
const int SONG_SonataOfAwakening = 20;
const int SONG_ScarecrowsSong = 21;
//CUSTOMSONG// Add your song's ID, which should simply be 22, 23, etc. for each custom song.
//Song learn strings
int SONGSTRING_SongOfTime[] = "Song of Time: >AV>AV";
int SONGSTRING_ZeldasLullaby[] = "Zelda's Lullaby: <^><^>";
int SONGSTRING_EponasSong[] = "Epona's Song: ^<>^<>";
int SONGSTRING_SariasSong[] = "Saria's Song: V><V><";
int SONGSTRING_SongOfStorms[] = "Song of Storms: AV^AV^";
int SONGSTRING_SunSong[] = "Sun's Song: >V^>V^";
int SONGSTRING_MinuetOfForest[] = "Minuet of Forest: A^<><>";
int SONGSTRING_BoleroOfFire[] = "Bolero of Fire: VAVA>V>V";
int SONGSTRING_SerenadeOfWater[] = "Serenade of Water: AV>><";
int SONGSTRING_NocturneOfShadow[] = "Nocturne of Shadow: <>>A<>V";
int SONGSTRING_RequiemOfSpirit[] = "Requiem of Spirit: AVA>VA";
int SONGSTRING_PreludeOfLight[] = "Prelude of Light: ^>^><^";
int SONGSTRING_GoronsLullaby[] = "Goron's Lullaby: A><A><>A";
int SONGSTRING_OathToOrder[] = "Oath to Order: >VAV>^";
int SONGSTRING_SongOfSoaring[] = "Song of Soaring: V<^V<^";
int SONGSTRING_SongOfHealing[] = "Song of Healing: <>V<>V";
int SONGSTRING_ElegyOfEmptiness[] = "Elegy of Emptiness: ><>V>^<";
int SONGSTRING_NewWaveBossaNova[] = "New Wave Bossa Nova: <^<>V<>";
int SONGSTRING_SongOfDoubleTime[] = "Song of Double Time: >>AAVV";
int SONGSTRING_SongOfInvertedTime[] = "Song of Inverted Time: VA>VA>";
int SONGSTRING_SonataOfAwakening[] = "Sonata of Awakening: ^<^<X>X";
int SONGSTRING_ScarecrowsSong[] = "ScarecrowsSong: Custom";
//CUSTOMSONG// Add your own song string. This is displayed when a song is learned.
int SONGSTRINGS = 0;
//Song MIDI IDs -- set these to the number of the MIDI you want to play, which should be the song played. //CHANGE//
const int SONGMIDI_SongOfTime = 0;
const int SONGMIDI_ZeldasLullaby = 0;
const int SONGMIDI_EponasSong = 0;
const int SONGMIDI_SariasSong = 0;
const int SONGMIDI_SongOfStorms = 0;
const int SONGMIDI_SunSong = 0;
const int SONGMIDI_MinuetOfForest = 0;
const int SONGMIDI_BoleroOfFire = 0;
const int SONGMIDI_SerenadeOfWater = 0;
const int SONGMIDI_NocturneOfShadow = 0;
const int SONGMIDI_RequiemOfSpirit = 0;
const int SONGMIDI_PreludeOfLight = 0;
const int SONGMIDI_GoronsLullaby = 0;
const int SONGMIDI_OathToOrder = 0;
const int SONGMIDI_SongOfSoaring = 0;
const int SONGMIDI_SongOfHealing = 0;
const int SONGMIDI_ElegyOfEmptiness = 0;
const int SONGMIDI_NewWaveBossaNova = 0;
const int SONGMIDI_SongOfDoubleTime = 0;
const int SONGMIDI_SongOfInvertedTime = 0;
const int SONGMIDI_SonataOfAwakening = 0;
//ScarecrowsSong has no SONGSOUND! This is intentional, though other songs should all have one!
//CUSTOMSONG//Add your custom song SFX ids the same as the normal ones.
//Learned songs- if you add a song, you must add to the number in the squarebrackets; it must be equal to the total number of songs! //CUSTOMSONG//
bool LEARNED_SONGS[22];
//Constants
const int NOTE_A = 1;
const int NOTE_DOWN = 2;
const int NOTE_RIGHT = 3;
const int NOTE_LEFT = 4;
const int NOTE_UP = 5;
const int NULL_NOTE = 0;
const int FRAMESOFSONGFREEZE = 600;
//Variables
bool ocarina_mode = false;
int ocIndex = 0;
int currSong[8];
int playedSong = -1;
int songFrames = 0;
int midiToReturn = 0;
bool scarecrowMode = false;
bool scarecrowRecord = false;
//
global script SampleGlobal{
	void ocarina(){
		if(Link->PressA){
			currSong[ocIndex] = NOTE_A;
			Game->PlaySound(NOTESOUND_A);
			ocIndex++;
		} else if(Link->PressDown) {
			currSong[ocIndex] = NOTE_DOWN;
			Game->PlaySound(NOTESOUND_DOWN);
			ocIndex++;
		} else if(Link->PressRight) {
			currSong[ocIndex] = NOTE_RIGHT;
			Game->PlaySound(NOTESOUND_RIGHT);
			ocIndex++;
		} else if(Link->PressLeft) {
			currSong[ocIndex] = NOTE_LEFT;
			Game->PlaySound(NOTESOUND_LEFT);
			ocIndex++;
		} else if(Link->PressUp) {
			currSong[ocIndex] = NOTE_UP;
			Game->PlaySound(NOTESOUND_UP);
			ocIndex++;
		} else if(Link->PressB){
			playedSong = -1;
			songFrames = 10;
			ocarina_mode = false;
		}
		
		if(ocIndex!=8 && ocIndex>0 && playSong(currSong)){
			for(;ocIndex<8;ocIndex++){}
			NoAction();
			ocarina_mode = false;
		} else if (ocIndex==8){
			if(playSong(currSong)){
				ocarina_mode = false;
			} else {
				ocarina_mode = false;
				Game->PlaySound(SFX_ERROR);
				playedSong = -1;
			}
		}
		drawNotes();
		NoAction();
	}
	
	void drawNotes(){
		for(int note=0;note<8;note++){
			if(currSong[note]==0){
				Screen->FastCombo(6,64+(16*note),48,0,0,128);
			} else if(currSong[note]==1){
				Screen->FastCombo(6,64+(16*note),48,NOTECOMBO_A,NOTECSET_A,128);
			} else if(currSong[note]==2){
				Screen->FastCombo(6,64+(16*note),48,NOTECOMBO_DOWN,NOTECSET_DOWN,128);
			} else if(currSong[note]==3){
				Screen->FastCombo(6,64+(16*note),48,NOTECOMBO_RIGHT,NOTECSET_RIGHT,128);
			} else if(currSong[note]==4){
				Screen->FastCombo(6,64+(16*note),48,NOTECOMBO_LEFT,NOTECSET_LEFT,128);
			} else if(currSong[note]==5){
				Screen->FastCombo(6,64+(16*note),48,NOTECOMBO_UP,NOTECSET_UP,128);
			}
		}
	}
	
	bool playSong(int song){
		midiToReturn = Game->GetMIDI();
		if(LEARNED_SONGS[SONG_SongOfTime] && compareSongs(song,SONGNOTES_SongOfTime)){
			Game->PlayMIDI(SONGMIDI_SongOfTime);
			playedSong=SONG_SongOfTime;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_ZeldasLullaby] && compareSongs(song,SONGNOTES_ZeldasLullaby)){
			Game->PlayMIDI(SONGMIDI_ZeldasLullaby);
			playedSong=SONG_ZeldasLullaby;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_EponasSong] && compareSongs(song,SONGNOTES_EponasSong)){
			Game->PlayMIDI(SONGMIDI_EponasSong);
			playedSong=SONG_EponasSong;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SariasSong] && compareSongs(song,SONGNOTES_SariasSong)){
			Game->PlayMIDI(SONGMIDI_SariasSong);
			playedSong=SONG_SariasSong;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SongOfStorms] && compareSongs(song,SONGNOTES_SongOfStorms)){
			Game->PlayMIDI(SONGMIDI_SongOfStorms);
			playedSong=SONG_SongOfStorms;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SunSong] && compareSongs(song,SONGNOTES_SunSong)){
			Game->PlayMIDI(SONGMIDI_SunSong);
			playedSong=SONG_SunSong;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_MinuetOfForest] && compareSongs(song,SONGNOTES_MinuetOfForest)){
			Game->PlayMIDI(SONGMIDI_MinuetOfForest);
			playedSong=SONG_MinuetOfForest;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_BoleroOfFire] && compareSongs(song,SONGNOTES_BoleroOfFire)){
			Game->PlayMIDI(SONGMIDI_BoleroOfFire);
			playedSong=SONG_BoleroOfFire;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SerenadeOfWater] && compareSongs(song,SONGNOTES_SerenadeOfWater)){
			Game->PlayMIDI(SONGMIDI_SerenadeOfWater);
			playedSong=SONG_SerenadeOfWater;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_NocturneOfShadow] && compareSongs(song,SONGNOTES_NocturneOfShadow)){
			Game->PlayMIDI(SONGMIDI_NocturneOfShadow);
			playedSong=SONG_NocturneOfShadow;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_RequiemOfSpirit] && compareSongs(song,SONGNOTES_RequiemOfSpirit)){
			Game->PlayMIDI(SONGMIDI_RequiemOfSpirit);
			playedSong=SONG_RequiemOfSpirit;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_PreludeOfLight] && compareSongs(song,SONGNOTES_PreludeOfLight)){
			Game->PlayMIDI(SONGMIDI_PreludeOfLight);
			playedSong=SONG_PreludeOfLight;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_GoronsLullaby] && compareSongs(song,SONGNOTES_GoronsLullaby)){
			Game->PlayMIDI(SONGMIDI_GoronsLullaby);
			playedSong=SONG_GoronsLullaby;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_OathToOrder] && compareSongs(song,SONGNOTES_OathToOrder)){
			Game->PlayMIDI(SONGMIDI_OathToOrder);
			playedSong=SONG_OathToOrder;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SongOfSoaring] && compareSongs(song,SONGNOTES_SongOfSoaring)){
			Game->PlayMIDI(SONGMIDI_SongOfSoaring);
			playedSong=SONG_SongOfSoaring;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SongOfHealing] && compareSongs(song,SONGNOTES_SongOfHealing)){
			Game->PlayMIDI(SONGMIDI_SongOfHealing);
			playedSong=SONG_SongOfHealing;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_ElegyOfEmptiness] && compareSongs(song,SONGNOTES_ElegyOfEmptiness)){
			Game->PlayMIDI(SONGMIDI_ElegyOfEmptiness);
			playedSong=SONG_ElegyOfEmptiness;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_NewWaveBossaNova] && compareSongs(song,SONGNOTES_NewWaveBossaNova)){
			Game->PlayMIDI(SONGMIDI_NewWaveBossaNova);
			playedSong=SONG_NewWaveBossaNova;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SongOfDoubleTime] && compareSongs(song,SONGNOTES_SongOfDoubleTime)){
			Game->PlayMIDI(SONGMIDI_SongOfDoubleTime);
			playedSong=SONG_SongOfDoubleTime;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SongOfInvertedTime] && compareSongs(song,SONGNOTES_SongOfInvertedTime)){
			Game->PlayMIDI(SONGMIDI_SongOfInvertedTime);
			playedSong=SONG_SongOfInvertedTime;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_SonataOfAwakening] && compareSongs(song,SONGNOTES_SonataOfAwakening)){
			Game->PlayMIDI(SONGMIDI_SonataOfAwakening);
			playedSong=SONG_SonataOfAwakening;
			songFrames = 20;//CHANGE// How many frames does your MIDI take to play?
			return true;
		} else if(LEARNED_SONGS[SONG_ScarecrowsSong] && compareSongs(song,SONGNOTES_ScarecrowsSong)){
			for(int note = 0;note<8;note++){
				if(song[note]==0){
					return false;
				}
			}
			playedSong=SONG_ScarecrowsSong;
			songFrames = 20;
			return true;
		}//Add another else/if here for custom songs! //CUSTOMSONG//
		midiToReturn = 0;
		return false;
	}
	
	void activateSong(int song){
		if(song==SONG_SongOfTime){
			//INSERT CODE//Do something here when Song of Time is played!
		} else if(song==SONG_ZeldasLullaby){
			//INSERT CODE//Do something here when Zelda's Lullaby is played!
		} else if(song==SONG_EponasSong){
			//INSERT CODE//Do something here when Epona's Song is played!
		} else if(song==SONG_SariasSong){
			//INSERT CODE//Do something here when Saria's Song is played!
		} else if(song==SONG_SongOfStorms){
			//INSERT CODE//Do something here when Song of Storms is played!
		} else if(song==SONG_SunSong){
			//INSERT CODE//Do something here when Sun's Song is played!
		} else if(song==SONG_MinuetOfForest){
			//INSERT CODE//Do something here when Minuet of Forest is played!
		} else if(song==SONG_BoleroOfFire){
			//INSERT CODE//Do something here when Bolero of Fire is played!
		} else if(song==SONG_SerenadeOfWater){
			//INSERT CODE//Do something here when Serenade of Water is played!
		} else if(song==SONG_NocturneOfShadow){
			//INSERT CODE//Do something here when Nocturne of Shadow is played!
		} else if(song==SONG_RequiemOfSpirit){
			//INSERT CODE//Do something here when Requiem of Spirit is played!
		} else if(song==SONG_PreludeOfLight){
			//INSERT CODE//Do something here when Prelude of Light is played!
		} else if(song==SONG_GoronsLullaby){
			//INSERT CODE//Do something here when Goron's Lullaby is played!
		} else if(song==SONG_OathToOrder){
			//INSERT CODE//Do something here when Oath to Order is played!
		} else if(song==SONG_SongOfSoaring){
			//INSERT CODE//Do something here when Song of Soaring is played!
		} else if(song==SONG_SongOfHealing){
			//INSERT CODE//Do something here when Song of Healing is played!
		} else if(song==SONG_ElegyOfEmptiness){
			//INSERT CODE//Do something here when Elegy of Emptiness is played!
		} else if(song==SONG_NewWaveBossaNova){
			//INSERT CODE//Do something here when New Wave Bossa Nova is played!
		} else if(song==SONG_SongOfDoubleTime){
			//INSERT CODE//Do something here when Song of Double Time is played!
		} else if(song==SONG_SongOfInvertedTime){
			//INSERT CODE//Do something here when Song of Inverted Time is played!
		} else if(song==SONG_SonataOfAwakening){
			//INSERT CODE//Do something here when Sonata of Awakening is played!
		} else if(song==SONG_ScarecrowsSong){
			//INSERT CODE//Do something here when Scarecrow's Song is played!
		}//Add another else/if here for custom songs! //CUSTOMSONG// (Not REQUIRED if you just want it to trigger the FFC secrets script)
	}
	
	bool compareSongs(int song, int song2){
		for(int note=0;note<8;note++){
			if(song[note]!=song2[note]){
				return false;
			}
		}
		return true;
	}
	
	void scarecrow(){
		if(Link->PressA){
			currSong[ocIndex] = NOTE_A;
			Game->PlaySound(NOTESOUND_A);
			ocIndex++;
		} else if(Link->PressDown) {
			currSong[ocIndex] = NOTE_DOWN;
			Game->PlaySound(NOTESOUND_DOWN);
			ocIndex++;
		} else if(Link->PressRight) {
			currSong[ocIndex] = NOTE_RIGHT;
			Game->PlaySound(NOTESOUND_RIGHT);
			ocIndex++;
		} else if(Link->PressLeft) {
			currSong[ocIndex] = NOTE_LEFT;
			Game->PlaySound(NOTESOUND_LEFT);
			ocIndex++;
		} else if(Link->PressUp) {
			currSong[ocIndex] = NOTE_UP;
			Game->PlaySound(NOTESOUND_UP);
			ocIndex++;
		} else if(Link->PressB){
			playedSong = -1;
			songFrames = 10;
			scarecrowRecord = false;
		}
		if(ocIndex==8){
			if(!isValidSong(currSong,false)){
				for(int note=0;note<8;note++){
					SONGNOTES_ScarecrowsSong[note]=currSong[note];
				}
			} else {
				Game->PlaySound(SFX_ERROR);
			}
			scarecrowRecord = false;
		}
		drawNotes();
		NoAction();
	}
	
	bool isValidSong(int song, bool reqLearned){
		if(reqLearned){
			if(LEARNED_SONGS[SONG_SongOfTime] && compareSongs(song,SONGNOTES_SongOfTime)){
				return true;
			} else if(LEARNED_SONGS[SONG_ZeldasLullaby] && compareSongs(song,SONGNOTES_ZeldasLullaby)){
				return true;
			} else if(LEARNED_SONGS[SONG_EponasSong] && compareSongs(song,SONGNOTES_EponasSong)){
				return true;
			} else if(LEARNED_SONGS[SONG_SariasSong] && compareSongs(song,SONGNOTES_SariasSong)){
				return true;
			} else if(LEARNED_SONGS[SONG_SongOfStorms] && compareSongs(song,SONGNOTES_SongOfStorms)){
				return true;
			} else if(LEARNED_SONGS[SONG_SunSong] && compareSongs(song,SONGNOTES_SunSong)){
				return true;
			} else if(LEARNED_SONGS[SONG_MinuetOfForest] && compareSongs(song,SONGNOTES_MinuetOfForest)){
				return true;
			} else if(LEARNED_SONGS[SONG_BoleroOfFire] && compareSongs(song,SONGNOTES_BoleroOfFire)){
				return true;
			} else if(LEARNED_SONGS[SONG_SerenadeOfWater] && compareSongs(song,SONGNOTES_SerenadeOfWater)){
				return true;
			} else if(LEARNED_SONGS[SONG_NocturneOfShadow] && compareSongs(song,SONGNOTES_NocturneOfShadow)){
				return true;
			} else if(LEARNED_SONGS[SONG_RequiemOfSpirit] && compareSongs(song,SONGNOTES_RequiemOfSpirit)){
				return true;
			} else if(LEARNED_SONGS[SONG_PreludeOfLight] && compareSongs(song,SONGNOTES_PreludeOfLight)){
				return true;
			} else if(LEARNED_SONGS[SONG_GoronsLullaby] && compareSongs(song,SONGNOTES_GoronsLullaby)){
				return true;
			} else if(LEARNED_SONGS[SONG_OathToOrder] && compareSongs(song,SONGNOTES_OathToOrder)){
				return true;
			} else if(LEARNED_SONGS[SONG_SongOfSoaring] && compareSongs(song,SONGNOTES_SongOfSoaring)){
				return true;
			} else if(LEARNED_SONGS[SONG_SongOfHealing] && compareSongs(song,SONGNOTES_SongOfHealing)){
				return true;
			} else if(LEARNED_SONGS[SONG_ElegyOfEmptiness] && compareSongs(song,SONGNOTES_ElegyOfEmptiness)){
				return true;
			} else if(LEARNED_SONGS[SONG_NewWaveBossaNova] && compareSongs(song,SONGNOTES_NewWaveBossaNova)){
				return true;
			} else if(LEARNED_SONGS[SONG_SongOfDoubleTime] && compareSongs(song,SONGNOTES_SongOfDoubleTime)){
				return true;
			} else if(LEARNED_SONGS[SONG_SongOfInvertedTime] && compareSongs(song,SONGNOTES_SongOfInvertedTime)){
				return true;
			} else if(LEARNED_SONGS[SONG_SonataOfAwakening] && compareSongs(song,SONGNOTES_SonataOfAwakening)){
				return true;
			}//Add another else/if here for custom songs! //CUSTOMSONG//
		} else {
			if(LEARNED_SONGS[SONG_SongOfTime] && compareSongs(song,SONGNOTES_SongOfTime)){
				return true;
			} else if(compareSongs(song,SONGNOTES_ZeldasLullaby)){
				return true;
			} else if(compareSongs(song,SONGNOTES_EponasSong)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SariasSong)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SongOfStorms)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SunSong)){
				return true;
			} else if(compareSongs(song,SONGNOTES_MinuetOfForest)){
				return true;
			} else if(compareSongs(song,SONGNOTES_BoleroOfFire)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SerenadeOfWater)){
				return true;
			} else if(compareSongs(song,SONGNOTES_NocturneOfShadow)){
				return true;
			} else if(compareSongs(song,SONGNOTES_RequiemOfSpirit)){
				return true;
			} else if(compareSongs(song,SONGNOTES_PreludeOfLight)){
				return true;
			} else if(compareSongs(song,SONGNOTES_GoronsLullaby)){
				return true;
			} else if(compareSongs(song,SONGNOTES_OathToOrder)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SongOfSoaring)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SongOfHealing)){
				return true;
			} else if(compareSongs(song,SONGNOTES_ElegyOfEmptiness)){
				return true;
			} else if(compareSongs(song,SONGNOTES_NewWaveBossaNova)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SongOfDoubleTime)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SongOfInvertedTime)){
				return true;
			} else if(compareSongs(song,SONGNOTES_SonataOfAwakening)){
				return true;
			}//Add another else/if here for custom songs! //CUSTOMSONG//
		}	
		return false;
	}
	
	void run(){
		scarecrowMode = false;
		scarecrowRecord = false;
		//CUSTOMSONG// Add your SONGSTRING_ to the end of this, in the order of the SongID.
		int songstr[] = {SONGSTRING_SongOfTime,SONGSTRING_ZeldasLullaby,SONGSTRING_EponasSong,SONGSTRING_SariasSong,SONGSTRING_SongOfStorms,SONGSTRING_SunSong,SONGSTRING_MinuetOfForest,SONGSTRING_BoleroOfFire,SONGSTRING_SerenadeOfWater,SONGSTRING_NocturneOfShadow,SONGSTRING_RequiemOfSpirit,SONGSTRING_PreludeOfLight,SONGSTRING_GoronsLullaby,SONGSTRING_OathToOrder,SONGSTRING_SongOfSoaring,SONGSTRING_SongOfHealing,SONGSTRING_ElegyOfEmptiness,SONGSTRING_NewWaveBossaNova,SONGSTRING_SongOfDoubleTime,SONGSTRING_SongOfInvertedTime,SONGSTRING_SonataOfAwakening,SONGSTRING_ScarecrowsSong};
		SONGSTRINGS = songstr;
		while(true){
			if(songFrames>0){
				ocarina_mode = false;
				NoAction();
				drawNotes();
				songFrames--;
				if(songFrames==0&&playedSong>-1){
					Game->PlayMIDI(midiToReturn);
					activateSong(playedSong);
					playedSong=-1;
				}
			}
			if(ocarina_mode){
				ocarina();
			}
			if(scarecrowRecord){
				scarecrow();
			}
			if(ocarina_mode||scarecrowRecord||songFrames>0){
				Link->CollDetection = false;
			} else {
				Link->CollDetection = true;
			}
			Waitdraw();
			Waitframe();
		}
	}
}
//end SampleGlobal
//start ITEM Ocarina
item script Ocarina{
	//
	//Set this to the item you wish to activate song mode. This item should be a Custom Item Class.
	//
	void run(){
		if(songFrames==0&&!scarecrowMode){
			for(int note = 0;note<8;note++){
				currSong[note]=0;
			}
			ocIndex = 0;
			playedSong=-1;
			ocarina_mode = true;
		} else if(songFrames==0&&scarecrowMode){
			for(int note = 0;note<8;note++){
				currSong[note]=0;
			}
			ocIndex = 0;
			playedSong=-1;
			scarecrowRecord = true;
		}
	}
}
//end Ocarina
//start FFC SongTriggersSecrets
ffc script SongTriggersSecrets{
	//
	//Var 0: Number of song to require for secret trigger
	//Var 1: Set to 0 for temporary secrets, set to 1 for permanent secrets.
	//Var 2: Set to 0 for play anywhere on screen, set to 1 for play while standing on FFC
	//
	void run(int song, bool perm, bool reqOnFFC){
		bool waiting = true;
		while(waiting){
			if(playedSong==song){
				if(!reqOnFFC||(Link->X>this->X-8&&Link->X<this->X+8&&Link->Y>this->Y-8&&Link->Y<this->Y+8)){
					Screen->TriggerSecrets();
					if(perm){
						Screen->State[ST_SECRET] = true;
					}
					waiting=false;
				}
			}
			Waitframe();
		}
	}
}
//end SongTriggersSecrets
//start FFC LearnASong
ffc script LearnASong{
	//
	//Var 0: Number of song to learn when stepping on this tile
	//Var 1: X-coordinate to display song learn message at. Leave blank for default (128).
	//Var 2: Y-coordinate to display song learn message at. Leave blank for default (32).
	//Var 3: Font color. Leave blank for default (black).
	//Var 4: Background color. Leave blank for default (transparent). Use -1 for black.
	//Var 5: Draw. If set to 0, song message will only be displayed when the song is learned. If set to 1, it will be displayed any time the screen is visited after it has been learned. If set to -1, it will not be displayed.
	//Note that the combo for this FFC will be automatically set to Combo 0 once the song is learned!
	//
	void run(int song,int displayX,int displayY,int fontColor, int bgColor, int drawstate){
		bool waiting = true;
		bool draw = false;
		if(displayX==0){
			displayX=128;
		}
		if(displayY==0){
			displayY=32;
		}
		if(bgColor==0){
			bgColor=-1;
		} else if(bgColor==-1){
			bgColor=0;
		}
		while(waiting){
			if(Link->X>this->X-8&&Link->X<this->X+8&&Link->Y>this->Y-8&&Link->Y<this->Y+8){
				LEARNED_SONGS[song]=true;
				if(drawstate==0){
					draw=true;
				}
			}
			if(LEARNED_SONGS[song]){
				waiting=false;
				this->Data=0;
				if(drawstate==1){
					draw=true;
				}
			}
			Waitframe();
		}
		while(draw){
			Screen->DrawString(6,displayX,displayY,FONT_Z3,fontColor,bgColor,TF_CENTERED,SONGSTRINGS[song],OP_OPAQUE);
			Waitframe();
		}
	}
}
//end LearnASong
//start FFC MakeScarecrowsSong
ffc script MakeScarecrowsSong{
	//
	//If Link is standing on this FFC and uses the Ocarina, he will not be able to play normal songs, but will instead play an 8-note song of his making which will be the scarecrow's song!
	//NOTE: Link must still first LEARN the ScarecrowsSong using the LearnASong script, just as any other song. You can place that here as well, or place it elsewhere to simulate "activating" the song as is done in OOT!
	//The player may come back to this spot any time to change the ScarecrowsSong.
	//
	void run(){
		while(true){
			if(Link->X>this->X-8&&Link->X<this->X+8&&Link->Y>this->Y-8&&Link->Y<this->Y+8){
				scarecrowMode = true;
			} else {
				scarecrowMode = false;
				scarecrowRecord = false;
			}
			Waitframe();
		}
	}
}
//end MakeScarecrowsSong
//end OcarinaScripts