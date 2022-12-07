const int FAST_COUNTER_DRAIN_THRESHOLD = 30; //Threshold for triggering accelerated drain.

//Fast counter drain.
//When the counter drain exceeds certain value, drain process is accelerated by 10-fold until DCounter Abs value falls below threshold.
//This speeds up counter drain. For instance, rupees counter when buying expensive item/s.

//Global script combining: put "FastCounterDrain();" command into main loop of global script, between Waitdraw and Waitframe.

global script FastCounterDrain{
	void run(){
		while(true){
			Waitdraw();
			FastCounterDrain();
			Waitframe();
		}
	}
}

void FastCounterDrain(){
	for (int i=0;i<32;i++){
		if (Game->DCounter[i]>FAST_COUNTER_DRAIN_THRESHOLD){
			Game->Counter[i]=Min((Game->Counter[i]+9), Game->MCounter[i]);
			Game->DCounter[i]-=9;
		}
		if (Game->DCounter[i]<-FAST_COUNTER_DRAIN_THRESHOLD){
			Game->Counter[i]=Max((Game->Counter[i]-9), 0);
			Game->DCounter[i]+=9;
		}
	}
}