const int FONT_DIALOGUE_BRANCH = 0; //Default font for dialogue branches. See FONT_ in std_constants.zh
const int C_FONT_DIALOGUE_BRANCH = 0x01; //Color of the font

ffc script DialogueBranch_Simple{
	void run(int op1, int op2, int op3, int out1, int out2, int out3){
		WaitNoAction();
		int op1s[256] = " ";
		int op2s[256] = " ";
		int op3s[256] = " ";
		
		int selection;
		
		if(op1>0){
			Game->GetMessage(op1, op1s);
			String_Cap(op1s);
		}
		if(op2>0){
			Game->GetMessage(op2, op2s);
			String_Cap(op2s);
		}
		if(op3>0){
			Game->GetMessage(op3, op3s);
			String_Cap(op3s);
			
			int options[] = {op1s, op2s, op3s};
			selection = DialogueBox_Run(128, 88, options, TIL_DB_DIALOGUE_BOX, CS_DB_DIALOGUE_BOX, C_DB_DIALOGUE_BOX_BG, FONT_DIALOGUE_BRANCH, C_FONT_DIALOGUE_BRANCH, TIL_DB_DIALOGUE_SELECTOR, CS_DB_DIALOGUE_SELECTOR);
		}
		else{
			int options[] = {op1s, op2s};
			selection = DialogueBox_Run(128, 88, options, TIL_DB_DIALOGUE_BOX, CS_DB_DIALOGUE_BOX, C_DB_DIALOGUE_BOX_BG, FONT_DIALOGUE_BRANCH, C_FONT_DIALOGUE_BRANCH, TIL_DB_DIALOGUE_SELECTOR, CS_DB_DIALOGUE_SELECTOR);
		}
		
		if(selection==0){
			Screen->Message(out1);
			WaitNoAction();
		}
		else if(selection==1){
			Screen->Message(out2);
			WaitNoAction();
		}
		else if(selection==2){
			Screen->Message(out3);
			WaitNoAction();
		}
	}
}

ffc script DialogueBranch_Advanced{
	void run(int controlString){
		int currentString = controlString;
		
		int i; int j; int k; int m; int o; int p; int count;
		
		int code_mcc[] = "#MCC"; code_mcc[0] = CHAR_MCC_MARKER; //Moosh control code
		int code_br[] = "#BRANCH"; code_br[0] = CHAR_MCC_MARKER; //Branch
		int code_a[] = "#APPEND"; code_a[0] = CHAR_MCC_MARKER; //Append
		int code_rs[] = "#SCRIPT"; code_rs[0] = CHAR_MCC_MARKER; //Run Script
		int code_gi[] = "#GIVEITEM"; code_gi[0] = CHAR_MCC_MARKER; //Give item
		int code_ci[] = "#HASITEM"; code_ci[0] = CHAR_MCC_MARKER; //Check item
		int code_cc[] = "#HASCOUNTER"; code_cc[0] = CHAR_MCC_MARKER; //Check counter
		int code_secret[] = "#SECRET"; code_secret[0] = CHAR_MCC_MARKER; //Trigger screen secret
		int code_issecret[] = "#ISSECRET"; code_issecret[0] = CHAR_MCC_MARKER; //Check screen secret
		int code_warp[] = "#WARP"; code_warp[0] = CHAR_MCC_MARKER; //Warp
		int code_rand[] = "#RAND"; code_rand[0] = CHAR_MCC_MARKER; //Rand
		int code_string[] = "#STRING"; code_string[0] = CHAR_MCC_MARKER; //String
		int code_hastriforce[] = "#HASTRIFORCE"; code_hastriforce[0] = CHAR_MCC_MARKER; //Has Triforce
		
		int stringIndex;
		int lowIndex;
		int highIndex;
		
		int ctrlStr[1024];
		
		int prompt;
		int strA;
		int strB;
		int options[16];
		int outcomes[16];
		
		//Load in the first string
		Game->GetMessage(controlString, ctrlStr);
		String_Cap(ctrlStr);
		String_ToUppercase(ctrlStr);
		while(true){
			currentString = controlString; //In case we forgot, let's keep this updated
			if(String_StartsWith(ctrlStr, code_mcc)){ //If the string is a control code it will start with #MCC
				while(String_Contains(ctrlStr, code_a)){ //If an append code is found, append the specified string over it
					//First we find the start of the append code
					stringIndex = String_FindStr(ctrlStr, 0, 0, code_a, 1);
					//Then we find and load the number at the start
					k = String_FindLoadInt(ctrlStr, stringIndex, 0, 1);
					if(k==-1){
						DB_LOG(1, currentString); //Expected number
						Quit();
					}
					currentString = k;
					int tempStr[256];
					Game->GetMessage(j, tempStr);
					String_WriteOver(ctrlStr, stringIndex, tempStr);
					String_Cap(ctrlStr);
					String_ToUppercase(ctrlStr);
					DB_LOG(400, j); //Appended string
				}
				if(String_Contains(ctrlStr, code_br)){ //Branch control code #BRANCH String, Input(*n), Output(*n)
					//Get first argument: Prompt string
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_br, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(1, currentString); //Missing argument (#BRANCH)
						Quit();
					}
					currentString = k;
					prompt = k;
					
					for(i=0; i<16; i++){
						options[i] = 0;
						outcomes[i] = 0;
					}
					
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					//Get second arguments: Options
					for(i=0; i<16; i++){
						k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, i+1);
						if(k>-1){
							options[i] = -k; //This is negative because of how DialogueBox.zh reads strings. Positive = ZScript string, Negative = ZQuest string
						}
						else
							break;
					}
					count = i;
					
					lowIndex = highIndex;
					//Get third arguments: Outcomes
					for(i=0; i<16; i++){
						k = String_FindLoadInt(ctrlStr, lowIndex, 0, i+1);
						if(k>-1){
							outcomes[i] = k;
						}
						else
							break;
					}
					
					//Input and output should have the same number of arguments in them, if not, print an error
					if(i!=count){
						DB_LOG(2, controlString); //Argument mismatch (#BRANCH)
						Quit();
					}
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					
					k = DialogueBox_Run(128, 88, options, TIL_DB_DIALOGUE_BOX, CS_DB_DIALOGUE_BOX, C_DB_DIALOGUE_BOX_BG, FONT_DIALOGUE_BRANCH, C_FONT_DIALOGUE_BRANCH, TIL_DB_DIALOGUE_SELECTOR, CS_DB_DIALOGUE_SELECTOR);
					
					controlString = outcomes[k]; //The outcome of the selection sets the next control string
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_rs)){ //Script control code #SCRIPT String, ScriptID, Args(*8)
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_rs, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(3, currentString); //Missing argument (#SCRIPT)
						Quit();
					}
					prompt = k;
					
					//Get second argument: ScriptID
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(3, currentString); //Missing argument (#SCRIPT)
						Quit();
					}
					int scriptid = k;
					
					//Get arguments 3-11: FFC args
					int args[8];
					for(i=0; i<8; i++){
						lowIndex = highIndex;
						highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
						
						k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
						if(k==-1)
							break;
						args[i] = k;
					}
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					RunFFCScript(scriptid, args);
					Quit();
				}
				else if(String_Contains(ctrlStr, code_gi)){ //Give item control code #GIVEITEM String, ItemID, NextString
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_gi, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(4, currentString); //Missing argument (#GIVEITEM)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Item ID
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(4, currentString); //Missing argument (#GIVEITEM)
						Quit();
					}
					j = k;
					
					//Get third argument: String 2
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//The last argument is optional
					controlString = 0;
					if(k>-1){
						controlString = k;
					}
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					item itm = CreateItemAt(j, Link->X, Link->Y);
					itm->Pickup = IP_HOLDUP;
					while(itm->isValid()){
						itm->X = Link->X;
						itm->Y = Link->Y;
						WaitNoAction();
					}
					while(Link->Action==LA_HOLD1LAND||Link->Action==LA_HOLD2LAND||Link->Action==LA_HOLD1WATER||Link->Action==LA_HOLD2WATER){
						WaitNoAction();
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_ci)){ //Check item control code #HASITEM String, ItemID, HasItem, NoItem
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_ci, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(5, currentString); //Missing argument (#HASITEM)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Item ID
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(5, currentString); //Missing argument (#HASITEM)
						Quit();
					}
					j = k;
					
					//Get third argument: Has Item String
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(5, currentString); //Missing argument (#HASITEM)
						Quit();
					}
					strA = k;
					
					//Get fourth argument: No Item String
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(5, currentString); //Missing argument (#HASITEM)
						Quit();
					}
					strB = k;
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					//Set the next control string based on if Link has the item
					if(Link->Item[j]){
						controlString = strA;
					}
					else{
						controlString = strB;
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_cc)){ //Check counter control code #HASCOUNTER String, CounterID, CounterAmount, HasCounter, NoCounter, Take
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_cc, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(6, currentString); //Missing argument (#HASCOUNTER)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Counter ID
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(6, currentString); //Missing argument (#HASCOUNTER)
						Quit();
					}
					j = k;
					
					//Get third argument: Counter amount
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(6, currentString); //Missing argument (#HASCOUNTER)
						Quit();
					}
					m = k;
					
					//Get fourth argument: Has Counter String
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(6, currentString); //Missing argument (#HASCOUNTER)
						Quit();
					}
					strA = k;
					
					//Get fifth argument: No Counter String
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(6, currentString); //Missing argument (#HASCOUNTER)
						Quit();
					}
					strB = k;
					
					//Get sixth argument: Take (0=No, 1=Instant, 2=Drain)
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//The last argument is optional
					o = 0;
					if(k>-1){
						o = k;
					}
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					//Set the next control string based on if the counter is high enough
					if(Game->Counter[j]+Game->DCounter[j]>=m){
						if(o==1){
							Game->Counter[j] -= m;
						}
						else if(o==2){
							Game->DCounter[j] -= m;
						}
						controlString = strA;
					}
					else{
						controlString = strB;
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_secret)){ //Secret trigger control code #SECRET String, PermSecret, NextString
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_secret, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(7, currentString); //Missing argument (#SECRET)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Perm Secret (0=No, 1=Yes)
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(7, currentString); //Missing argument (#SECRET)
						Quit();
					}
					m = k;
					
					//Get third argument: Next String
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(7, currentString); //Missing argument (#SECRET)
						Quit();
					}
					controlString = k;
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					
					Screen->TriggerSecrets();
					if(m==1)
						Screen->State[ST_SECRET] = true;
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_issecret)){ //Secret check control code #ISSECRET String, IsSecret, NoSecret
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_issecret, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(8, currentString); //Missing argument (#ISSECRET)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Secret Message
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(8, currentString); //Missing argument (#ISSECRET)
						Quit();
					}
					strA = k;
					
					//Get third argument: No Secret Message
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(8, currentString); //Missing argument (#ISSECRET)
						Quit();
					}
					strB = k;
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					
					if(Screen->State[ST_SECRET]){
						controlString = strA;
					}
					else{
						controlString = strB;
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_warp)){ //Warp control code #WARP String, DMap, Screen, Direct
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_warp, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(9, currentString); //Missing argument (#WARP)
						Quit();
					}
					prompt = k;
					
					//Get second argument: DMap
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(9, currentString); //Missing argument (#WARP)
						Quit();
					}
					m = k;
					
					//Get third argument: Screen
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(9, currentString); //Missing argument (#WARP)
						Quit();
					}
					o = k;
					
					//Get fourth argument: Direct (0=No, 1=Yes)
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(9, currentString); //Missing argument (#WARP)
						Quit();
					}
					p = k;
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					if(p==1){
						Link->PitWarp(m, o);
					}
					else{
						Link->Warp(m, o);
					}
					WaitNoAction();
					Quit();
				}
				else if(String_Contains(ctrlStr, code_rand)){ //Random string control code #RAND String, Output(*n)
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_rand, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(10, currentString); //Missing argument (#RAND)
						Quit();
					}
					prompt = k;
					
					for(i=0; i<16; i++){
						options[i] = 0;
					}
					
					//Load however many numbers as the next set of arguments
					count = 0;
					for(i=0; i<16; i++){
						k = String_FindLoadInt(ctrlStr, lowIndex, 0, i+1);
						if(k>-1){
							options[i] = k;
						}
						else
							break;
					}
					count = i;
					//It's not all that random if there's less than 2, now, is it?
					if(count<2){
						DB_LOG(10, currentString); //Missing argument (#RAND)
						Quit();
					}
					
					//Get a random string from the arguments
					k = Rand(count);
					
					controlString = options[k];
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_string)){ //Play string control code #STRING String, NextString
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_string, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(11, currentString); //Missing argument (#STRING)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Next String
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(11, currentString); //Missing argument (#STRING)
						Quit();
					}
					controlString = k;
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else if(String_Contains(ctrlStr, code_hastriforce)){ //Check Triforce control code #HASTRIFORCE String, CheckCount, Count, HasTriforce, NoTriforce
					//Get first argument: String
					lowIndex = String_FindStr(ctrlStr, 0, 0, code_hastriforce, 1);
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
						Quit();
					}
					prompt = k;
					
					//Get second argument: Whether to check total count?
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
						Quit();
					}
					
					//Get third argument: List of pieces/number of pieces
					if(k==0){ //List of pieces
						lowIndex = highIndex;
						highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
						
						//Load however many numbers as the next set of arguments
						count = 0;
						for(i=0; i<16; i++){
							k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, i+1);
							if(k>-1){
								options[i] = k;
							}
							else
								break;
						}
						count = i;
						
						//Has to check for at least one triforce piece
						if(count<1){
							DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
							Quit();
						}
						
						//For each triforce piece, if Link doesn't have it, set result to false
						j = 1;
						for(i=0; i<count; i++){
							if(!(Game->LItems[options[i]]&LI_TRIFORCE))
								j = 0;
						}
					}
					else{ //Number of pieces
						lowIndex = highIndex;
						highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
						k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
						//If no argument found, return an error
						if(k==-1){
							DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
							Quit();
						}
						
						j = 0;
						if(NumTriforcePieces()>=k)
							j = 1;
					}
					
					//Get fourth argument: Has Triforce String
					lowIndex = highIndex;
					highIndex = String_FindChar(ctrlStr, lowIndex+1, 0, ',', 1);
					k = String_FindLoadInt(ctrlStr, lowIndex, highIndex, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
						Quit();
					}
					strA = k;
					
					//Get fifth argument: No Triforce String
					lowIndex = highIndex;
					k = String_FindLoadInt(ctrlStr, lowIndex, 0, 1);
					//If no argument found, return an error
					if(k==-1){
						DB_LOG(12, currentString); //Missing argument (#HASTRIFORCE)
						Quit();
					}
					strB = k;
					
					if(prompt>0){
						Screen->Message(prompt);
						WaitNoAction();
					}
					//Set the next control string based on if Link has the required Triforce
					if(j){
						controlString = strA;
					}
					else{
						controlString = strB;
					}
					
					DB_LoadControlString(ctrlStr, controlString);
				}
				else{
					DB_LOG(-1, currentString); //Unidentified control code
					Quit();
				}
			}
			else{
				Screen->Message(controlString);
				WaitNoAction();
				Quit();
			}
		}
	}
	void DB_LoadControlString(int ctrlStr, int id){
		if(id==0)
			Quit();
		Game->GetMessage(id, ctrlStr);
		String_Cap(ctrlStr);
		String_ToUppercase(ctrlStr);
	}
	void DB_LOG(int id, int misc){
		if(!MCC_ENABLE_DEBUG)
			return;
		
		if(id==-1){
			int error[] = "ERROR: Unidentified control code in string: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		
		if(id==0){
			int error[] = "ERROR: ";
			TraceS(error);
			TraceNL();
		}
		else if(id==1){
			int error[] = "ERROR: Missing argument in control code #BRANCH. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==2){
			int error[] = "ERROR: Arguments mismatched in control code #BRANCH. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==3){
			int error[] = "ERROR: Missing argument in control code #SCRIPT. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==4){
			int error[] = "ERROR: Missing argument in control code #GIVEITEM. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==5){
			int error[] = "ERROR: Missing argument in control code #HASITEM. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==6){
			int error[] = "ERROR: Missing argument in control code #HASCOUNTER. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==7){
			int error[] = "ERROR: Missing argument in control code #SECRET. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==8){
			int error[] = "ERROR: Missing argument in control code #ISSECRET. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==9){
			int error[] = "ERROR: Missing argument in control code #WARP. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==10){
			int error[] = "ERROR: Missing argument in control code #RAND. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==11){
			int error[] = "ERROR: Missing argument in control code #STRING. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==12){
			int error[] = "ERROR: Missing argument in control code #HASTRIFORCE. String: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
		else if(id==400){
			int error[] = "Appended string: ";
			TraceS(error);
			Trace(misc);
			TraceNL();
		}
	}
}