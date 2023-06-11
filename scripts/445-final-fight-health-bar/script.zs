//From the sand the moldorm rises.
//Fear his enlightened form.

//Optional setting. If 1, higher level bars will be solid colors.
const int FINALFIGHT_BAR_SOLIDBARS = 0;

//X and Y position of the bar on the screen. Names appear above and portrait to the left
const int FINALFIGHT_BAR_X = 32;
const int FINALFIGHT_BAR_Y = 16;
//Width and height of the bar. A border is drawn around it.
const int FINALFIGHT_BAR_WIDTH = 80;
const int FINALFIGHT_BAR_HEIGHT = 6;

//Colors of the outline and background
const int C_FINALFIGHT_BAR_OUTLINE = 0x01;
const int C_FINALFIGHT_BAR_BG = 0x81;

//Colors of the name and name's shadow
const int C_FINALFIGHT_BAR_NAME = 0x04;
const int C_FINALFIGHT_BAR_NAME_BG = 0x03;

//Max HP and colors for each of the health bars.
const int MAXHP_FINALFIGHT_BAR1 = 16;
const int C_FINALFIGHT_BAR1 = 0x12;

const int MAXHP_FINALFIGHT_BAR2 = 32;
const int C_FINALFIGHT_BAR2 = 0x75;

const int MAXHP_FINALFIGHT_BAR3 = 64;
const int C_FINALFIGHT_BAR3 = 0x72;

const int MAXHP_FINALFIGHT_BAR4 = 96;
const int C_FINALFIGHT_BAR4 = 0xC6;

const int MAXHP_FINALFIGHT_BAR5 = 128;
const int C_FINALFIGHT_BAR5 = 0x77;

const int MAXHP_FINALFIGHT_BAR6 = 160;
const int C_FINALFIGHT_BAR6 = 0xA8; 

const int MAXHP_FINALFIGHT_BAR7 = 196;
const int C_FINALFIGHT_BAR7 = 0x01;

const int NPCM_FINALFIGHTHEALTHBAR = 11; //npc->Misc used for healthbars

//D0: The ID of the enemy to check for
//D1: A ZQuest string with the boss's name. 0 for none.
//D2: A tile for the boss's portrait. 0 for none.
//D3: The CSet to use for the portrait. 14 is the boss CSet.
//D4: Set to 1 to make HP ranges on bars dynamic, based on the boss's initial HP.
//D5: Set to the number of bars to use for dynamic health bars
//D6: Special exception cases for calculating group enemy HP
//		1: Summoner. Enemies spawned after the first HP check will be excluded.
ffc script FinalFightHealthBar{
	void run(int enemyID, int nameSTR, int portraitTIL, int portraitCS, int dynamicBars, int dynamicBarsCount, int specialCases){
		int ranges[] = {0, MAXHP_FINALFIGHT_BAR1, MAXHP_FINALFIGHT_BAR2, MAXHP_FINALFIGHT_BAR3, MAXHP_FINALFIGHT_BAR4, MAXHP_FINALFIGHT_BAR5, MAXHP_FINALFIGHT_BAR6, MAXHP_FINALFIGHT_BAR7};
		dynamicBarsCount = Clamp(dynamicBarsCount, 1, 7);
		
		Waitframes(4);
		int initHP;
		npc boss;
		if(enemyID>0){
			boss = LoadNPCOf(enemyID);
			if(!boss->isValid())
				Quit();
			initHP = boss->HP;
		}
		else{
			initHP = FFHB_ScreenHPTotal(specialCases, true);
		}
		if(dynamicBars)
			FFHB_SetBarRanges(ranges, initHP, dynamicBarsCount);
		
		int str_name[145] = "";
		if(nameSTR){
			Game->GetMessage(nameSTR, str_name);
		}
		
		int hp;
		int healthbarRemainFrames = 16;
		while(healthbarRemainFrames>0){
			if(enemyID==0){
				hp = FFHB_ScreenHPTotal(specialCases, false);
			}
			else{
				if(boss->isValid())
					hp = boss->HP;
				else
					hp = 0;
			}
			FFHB_Draw(ranges, FINALFIGHT_BAR_X, FINALFIGHT_BAR_Y, str_name, portraitTIL, portraitCS, hp);
			if(hp<=0)
				--healthbarRemainFrames;
			Waitframe();
		}
	}
	void FFHB_SetBarRanges(int ranges, int initHP, int numBars){
		int hpPerBar = initHP/numBars;
		for(int i=1; i<=7; ++i){
			ranges[i] = Round(hpPerBar*i);
			if(i==numBars)
				ranges[i] = initHP;
		}
	}
	void FFHB_Draw(int ranges, int x, int y, int str_name, int portraitTIL, int portraitCS, int hp){
		int c_bg = C_FINALFIGHT_BAR_BG;
		int c_fg = C_FINALFIGHT_BAR1;
		
		int barW;
		if(hp>=ranges[0]&&hp<ranges[1]){
			barW = Clamp(hp/(ranges[1]-ranges[0])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
		}
		else if(hp>=ranges[1]&&hp<ranges[2]){
			barW = Clamp((hp-ranges[1])/(ranges[2]-ranges[1])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR1;
			c_fg = C_FINALFIGHT_BAR2;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		else if(hp>=ranges[2]&&hp<ranges[3]){
			barW = Clamp((hp-ranges[2])/(ranges[3]-ranges[2])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR2;
			c_fg = C_FINALFIGHT_BAR3;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		else if(hp>=ranges[3]&&hp<ranges[4]){
			barW = Clamp((hp-ranges[3])/(ranges[4]-ranges[3])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR3;
			c_fg = C_FINALFIGHT_BAR4;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		else if(hp>=ranges[4]&&hp<ranges[5]){
			barW = Clamp((hp-ranges[4])/(ranges[5]-ranges[4])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR4;
			c_fg = C_FINALFIGHT_BAR5;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		else if(hp>=ranges[5]&&hp<ranges[6]){
			barW = Clamp((hp-ranges[5])/(ranges[6]-ranges[5])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR5;
			c_fg = C_FINALFIGHT_BAR6;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		else if(hp>=ranges[6]){
			barW = Clamp((hp-ranges[6])/(ranges[7]-ranges[6])*FINALFIGHT_BAR_WIDTH, 0, FINALFIGHT_BAR_WIDTH);
			c_bg = C_FINALFIGHT_BAR6;
			c_fg = C_FINALFIGHT_BAR7;
			if(FINALFIGHT_BAR_SOLIDBARS)
				barW = FINALFIGHT_BAR_WIDTH;
		}
		
		//Draw the outline
		Screen->Rectangle(6, x-1, y, x+FINALFIGHT_BAR_WIDTH, y+FINALFIGHT_BAR_HEIGHT-1, C_FINALFIGHT_BAR_OUTLINE, 1, 0, 0, 0, true, 128);
		Screen->Rectangle(6, x, y-1, x+FINALFIGHT_BAR_WIDTH-1, y+FINALFIGHT_BAR_HEIGHT, C_FINALFIGHT_BAR_OUTLINE, 1, 0, 0, 0, true, 128);
		
		//Draw the bar itself
		Screen->Rectangle(6, x, y, x+FINALFIGHT_BAR_WIDTH-1, y+FINALFIGHT_BAR_HEIGHT-1, c_bg, 1, 0, 0, 0, true, 128);
		if(barW>0)
			Screen->Rectangle(6, x, y, x+barW-1, y+FINALFIGHT_BAR_HEIGHT-1, c_fg, 1, 0, 0, 0, true, 128);
	
		//Draw the name
		FFHB_DrawStringShadowed(6, x+8, y-10, FONT_Z1, C_FINALFIGHT_BAR_NAME, C_FINALFIGHT_BAR_NAME_BG, TF_NORMAL, str_name, 128);
		
		//Draw the portrait
		if(portraitTIL){
			Screen->FastTile(6, x-16, y-(16-FINALFIGHT_BAR_HEIGHT-1), portraitTIL, portraitCS, 128);
		}
	}
	void FFHB_DrawStringShadowed(int layer, int x, int y, int font, int c1, int c2, int format, int ptr, int op){
		Screen->DrawString(layer, x+1, y, font, c2, -1, format, ptr, op);
		Screen->DrawString(layer, x, y+1, font, c2, -1, format, ptr, op);
		Screen->DrawString(layer, x+1, y+1, font, c2, -1, format, ptr, op);
		
		Screen->DrawString(layer, x, y, font, c1, -1, format, ptr, op);
	}
	int FFHB_ScreenHPTotal(int exceptionType, bool firstCheck){
		int total;
		for(int i=Screen->NumNPCs(); i>0; --i){
			npc n = Screen->LoadNPC(i);
			if(n->Type==NPCT_GUY)
				continue;
			if(n->Type==NPCT_TRAP)
				continue;
			if(n->Type==NPCT_PROJECTILE)
				continue;
			if(n->Type==NPCT_FAIRY)
				continue;
			if((n->MiscFlags&NPCMF_NOT_BEATABLE)!=0)
				continue;
			if(n->HP>=900)
				continue;
			if(exceptionType==1){
				if(firstCheck)
					n->Misc[NPCM_FINALFIGHTHEALTHBAR] = 1;
				else if(!n->Misc[NPCM_FINALFIGHTHEALTHBAR])
					continue;
			}
			if(n->Type==NPCT_MANHANDLA){
				if(n->ID>7)
					continue;
			}
			total += n->HP;
		}
		return total;
	}
}