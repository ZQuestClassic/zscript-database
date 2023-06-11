const int dayLength = 8; //Length of a day or night in minutes;
const int I_NIGHT = 45; //An unused item ID, placed into Link's inventory or removed to change day/night
const int dayDMAP1 = 0; //Daytime DMap #1
const int nightDMAP1 = 1; //Night DMap #1
const int dayDMAP2 = -1; //Daytime DMap #2
const int nightDMAP2 = -1; //Night DMap #2



global script DayNight{
	void changeNight(bool cycle){
		if(cycle){
			if(Link->Item[I_NIGHT])Link->Item[I_NIGHT]=false;
			else{Link->Item[I_NIGHT]=true;}
		}
		if(Game->GetCurScreen()!=128){
		if(dayDMAP1>=0&&nightDMAP1>=0){
			if(Game->GetCurDMap()==dayDMAP1 && Link->Item[I_NIGHT]){
				Link->PitWarp(nightDMAP1, Game->GetCurScreen());
			} else if(Game->GetCurDMap()==nightDMAP1 && !Link->Item[I_NIGHT]){
				Link->PitWarp(dayDMAP1, Game->GetCurScreen());
			}
		}
		if(dayDMAP2>=0&&nightDMAP2>=0){
			if(Game->GetCurDMap()==dayDMAP2 && Link->Item[I_NIGHT]){
				Link->PitWarp(nightDMAP2, Game->GetCurScreen());
			} else if(Game->GetCurDMap()==nightDMAP2 && !Link->Item[I_NIGHT]){
				Link->PitWarp(dayDMAP2, Game->GetCurScreen());
			}
		}// You can copy this entire IF statement and change it to, say, dayDMAP3 and nightDMAP3 to create an 
		 // additional DMap to have a day/night cycle for. This can be done indefinitely.
		
		}
	}

	void run(){
		int frame = 0;
		int min = 0;
		while(true){
			bool cycle = false;
			if(min==dayLength){cycle=true;min=0;}
			changeNight(cycle);
			Waitdraw();
			frame++;
			if(frame==3600){
				frame=0;
				min++;
			}
			Waitframe();
		}
	}
}