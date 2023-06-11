//import "std.zh"

//Old version: supports only 4-piece heart containers
//Messages can be set automatically or manually
//D0 = First message
//D1-3 = Second-fourth messages; default to strings after D0
item script heartPieceMessageOld{
	void run (int m1, int m2, int m3, int m4){
		//Set m2-4 to follow m1 if not set explicitly
		if ( m2 == 0 ) m2 = m1+1;
		if ( m3 == 0 ) m3 = m1+2;
		if ( m4 == 0 ) m4 = m1+3;
		
		//Play the appropriate message
		if ( Game->Generic[GEN_HEARTPIECES] == 0 )
			Screen->Message(m1);
		if ( Game->Generic[GEN_HEARTPIECES] == 1 )
			Screen->Message(m2);
		if ( Game->Generic[GEN_HEARTPIECES] == 2 )
			Screen->Message(m3);
		if ( Game->Generic[GEN_HEARTPIECES] == 3 )
			Screen->Message(m4);
	}
}

//New version: supports any number of heart containers
//D0 = String # of first message
//All other messages *MUST* follow the first
item script heartPieceMessage{
	void run ( int message ){
		Screen->Message ( message + Game->Generic[GEN_HEARTPIECES] );
	}
}