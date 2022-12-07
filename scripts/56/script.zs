const int SNOWFLAKE_TILE1=80; //The first tile used for snowflakes
const int SNOWFLAKE_TILE2=82; //The last tile used for snowflakes
const int SNOWFLAKE_CSET=2; //The cset used for snowflakes
const int SNOWFLAKE_COUNT=100; //Number of snowflakes on the screen. Change the values of the arrays manually

ffc script Snowfall{
	void run(){

		int xoffset=8;
		int yoffset=8;
		int snowflakes[100];
		float xpos[100];
		float ypos[100];
		float angle[100];
		float speed[100];
		int graphic[100];

		int i=0;
		while(i<100){
			xpos[i]=Rand(0,256)-xoffset;
			ypos[i]=Rand(0,176)-yoffset;
			angle[i]=Rand(90-20,90+20);
			graphic[i]=Rand(SNOWFLAKE_TILE1,SNOWFLAKE_TILE2);
			int range=SNOWFLAKE_TILE2-SNOWFLAKE_TILE1;
			speed[i]=0.5+0.2*Sin((graphic[i]-SNOWFLAKE_TILE1)*(90/range));
			i++;
		}

		while(true){
			i=0;
			while(i<100){

				if(xpos[i]<=0-xoffset || xpos[i]>=256-xoffset || ypos[i]>=176-yoffset){
					xpos[i]=Rand(0,256)-xoffset;
					ypos[i]=0-yoffset;
					angle[i]=Rand(90-20,90+20);
					graphic[i]=Rand(SNOWFLAKE_TILE1,SNOWFLAKE_TILE2);
					int range=SNOWFLAKE_TILE2-SNOWFLAKE_TILE1;
					speed[i]=0.5+0.2*Sin((graphic[i]-SNOWFLAKE_TILE1)*(90/range));
				}

				xpos[i]=xpos[i]+speed[i]*Cos(angle[i]);
				ypos[i]=ypos[i]+speed[i]*Sin(angle[i]);
				Screen->FastTile(6,xpos[i],ypos[i],graphic[i],SNOWFLAKE_CSET,128);

				i++;
			}

			Waitframe();
		}
	}
} //Snowfall