const int SFX_KNIGHTTOUR_MOVE = 16;//Sound to play when making move.
const int SFX_KNIGHTTOUR_SOLVED = 27;//Sound to play when puzzle is solved.

const int CSET_KNIGHTTOUR_EMPTY = 2; //Cset used for unvisited spaces of board.
const int CSET_KNIGHTTOUR_AVAILABLE = 2;//Cser used to highlight spaces that knight can move on at this time.
const int CSET_KNIGHTTOUR_ACTIVE = 2;//Cst used for current position of the knight.
const int CSET_KNIGHTTOUR_VISITED = 2;//Cset used for visited spaces of board.

const int CMB_KNIGHTTOUR_SHADOW = 1011;//Combo used to render shadow.

//import "chess.zh" //REQUIRED!!

//Infamous Knight tour puzzle for ZC 2.53. Perform series of knight moves to visit each space exactly once. Stand on space and press Ex1.

//1. Set up 4 consecutive combos: empty space, knight`s actual position, available moves highlight, and visited space mark.
//2. Build board of any size and shape, using only 1st combo from step 1. 
//   If 1st combo in step 1 is fully transparent, you may build chess board on background layer.
//3. Place FFC with knight`s combo on any space of the board.

ffc script KnightTour{
	void run(){
		int cmbspace = ComboAt (CenterX (this), CenterY (this));
		cmbspace = Screen->ComboD[cmbspace];
		int pos[176];
		int curpos = -1;
		int newpos = -1;
		for (int i=0; i<176; i++){
			if (Screen->ComboD[i]==cmbspace){ 
				pos[i]=0;
				Screen->ComboC[i] = CSET_KNIGHTTOUR_EMPTY;
			}
			else pos[i]=-1;
		}
		int animcounter=0;
		int origdata = this->Data;
		this->Data = FFCS_INVISIBLE_COMBO;
		int drawx = this->X;
		int drawy = this->Y;
		int jumpz = 0;
		while (true){
			if (animcounter==0){
				if (Link->PressEx1){
					int cmb = ComboAt (CenterLinkX(), CenterLinkY());
					if (curpos<0){
						Screen->ComboC[cmb] = CSET_KNIGHTTOUR_ACTIVE;
						Screen->ComboD[cmb]++;
						pos[cmb] = 1;
						for (int i=0; i<176; i++){
							if ((pos[i]==0)&&(KnightMoveAdjacent(cmb, i))){
								Screen->ComboC[i]=CSET_KNIGHTTOUR_AVAILABLE;
								Screen->ComboD[i]=cmbspace+2;
							}
						}
						curpos=cmb;
						this->X = ComboX(curpos);
						this->Y = ComboY(curpos);
						Game->PlaySound(SFX_KNIGHTTOUR_MOVE);
					}
					else if (Screen->ComboD[cmb]==cmbspace+2){
						for (int i=0; i<176; i++){
							if (pos[i]==0){
								Screen->ComboC[i]=CSET_KNIGHTTOUR_EMPTY;
								Screen->ComboD[i]=cmbspace;
							}
						}
						pos[curpos]=2;
						Screen->ComboC[curpos] = CSET_KNIGHTTOUR_VISITED;
						Screen->ComboD[curpos] = cmbspace+3;
						//Screen->ComboC[cmb] = CSET_KNIGHTTOUR_ACTIVE;
						//Screen->ComboD[cmb]=cmbspace+1;
						newpos=cmb;
						animcounter=16;
						Game->PlaySound(SFX_KNIGHTTOUR_MOVE);
					}					
				}
				drawx=this->X;
				drawy=this->Y;
			}
			else{
				//int lerpx = Cond((ComboX(newpos)>ComboX(curpos)), (animcounter/16), (1-animcounter/16));
				//int lerpy = Cond((ComboY(newpos)>ComboY(curpos)), (animcounter/16), (1-animcounter/16));
				drawx = Lerp((ComboX(curpos)),ComboX(newpos), (1-animcounter/16));
				drawy = Lerp((ComboY(curpos)),ComboY(newpos), (1-animcounter/16));
				if (animcounter>12) jumpz+=2;
				else if (animcounter>8) jumpz+=1;
				else if (animcounter>4) jumpz-=1;
				else jumpz-=2;
				animcounter--;
				if (animcounter==0){
					int cmb=newpos;					
					curpos=cmb;
					this->X = ComboX(curpos);
					this->Y = ComboY(curpos);
					for (int i=0; i<176; i++){
						if ((pos[i]==0)&&(KnightMoveAdjacent(cmb, i))){
							Screen->ComboC[i]=CSET_KNIGHTTOUR_AVAILABLE;
							Screen->ComboD[i]=cmbspace+2;
						}
					}
					pos[cmb] = 1;
					Screen->ComboD[cmb]=cmbspace+1;
					Screen->ComboC[cmb] = CSET_KNIGHTTOUR_ACTIVE;
					for (int i=0; i<176; i++){
						if (pos[i]==0) break;
						else if (i==175){
							Game->PlaySound(SFX_KNIGHTTOUR_SOLVED);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							break;
						}
					}
				}
			}
			if ((CMB_KNIGHTTOUR_SHADOW>0) && (animcounter>0))Screen->FastCombo(1, drawx, drawy, CMB_KNIGHTTOUR_SHADOW, 7, OP_TRANS);
			if (curpos>=0)Screen->FastCombo(Cond(animcounter>0, 4,1), drawx, drawy-jumpz, origdata, this->CSet, OP_OPAQUE);
			
			//debugValue(1, pos[ComboAt (CenterLinkX(), CenterLinkY())]);
			Waitframe();
		}
	}
}