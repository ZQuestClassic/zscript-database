ffc script reset{
	void run(){
		int i;
		for(i = 0; i<123;i++){
			if(Link->Item[i]){
				Link->Item[i]=false;
			}
		}
		if(Link->MaxHP>48){
			Link->HP = 48;
			Link->MaxHP = 48;		
		}
		if(Link->MaxMP>0){
			Link->MP = 0;
			Link->MaxMP = 0;
		}	

	}
}