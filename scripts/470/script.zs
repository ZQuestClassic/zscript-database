const int OracleIntYLocation = 16; //changing this will change the distance the player moves upwards

ffc script OracleIntEntry{
    void run(){
		if(LinkCollision(this)){
						while(Hero->Y > this->Y - OracleIntYLocation) {
						NoAction();
						Input->Button[CB_UP] = true;
						Waitframe();
					}
			Hero->Dir = DIR_UP;
			Quit();
		}
    }
}