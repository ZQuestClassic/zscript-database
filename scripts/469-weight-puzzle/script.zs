const int CF_WEIGHT_BUTTON = 98;//Combo inherent flag used to define weights 
const int CF_WEIGHT_LOCKED = 67;//Combo flag used for locked weights
const int CF_WEIGHT_REMOVEABLE = 66;//Combo flag used for weights that can be removed from scales.

const int CSET_WEIGHT_LEFT = 8; //Cset used for weights (and to render weight on scales) placed on left side of the scales.
const int CSET_WEIGHT_RIGHT = 5;//Cset used for weights (and to render weight on scales) placed on right side of the scales.
const int CSET_WEIGHT_NOT_ON_SCALE = 11;//Cset used for weights that don`t exist on either side of the scales.

const int FONT_WEIGHT_NUMBER = 0;//Font used to render total weight on each side of scales.

//Weight puzzle
//You have pair of balance scales and number of different weights, some of them are locked to either side of the scales. You can send weights to either side of the scale or remove them complelely from scales, if allowed. Stand on weight combo and press Ex1 to either put on left side, on right side, or remove completely. Balance the scales to solve the puzzle.
//
//Set up consecitove combos for weight combos, starting from 0, and ending as you want. Assign CF_WEIGHT_BUTTON inherent flag to them.
//Set up 3 combos for scales themselves, fist tilted "/", then balanced, then tilted "\" they should pint at top-left corner of 3*2 tile image of scales.
//Place weight combos. Assign CSETs to set initial position of weights (left side, right side, not on scale). By default, left side is CSet 8, right side is CSet 5, 11 for weights not on scale. Flag with CF_WEIGHT_LOCKED to lock weight position, or CF_WEIGHT_REMOVEABLE to allow Link to remove weight from scale at all.
//Place 3*2 FFC of scales themselves, assign second combo for scales from step 2 (balanced state).
// D0 - ID of 1st combo from step 1.
ffc script WeightPuzzle{
	void run (int origcmb){
		int origdata=this->Data;
		int left = 0;
		int right = 0;
		while(true){
			int cmb = ComboAt(CenterLinkX(),CenterLinkY());
			if  (ComboFI(cmb, CF_WEIGHT_BUTTON) && !ComboFI(cmb,CF_WEIGHT_LOCKED) && Link->PressEx1){
				Game->PlaySound(16);
				if (Screen->ComboC[cmb]==CSET_WEIGHT_LEFT)Screen->ComboC[cmb]=CSET_WEIGHT_RIGHT;
				else if (Screen->ComboC[cmb]==CSET_WEIGHT_RIGHT){
					if (ComboFI(cmb,CF_WEIGHT_REMOVEABLE))Screen->ComboC[cmb]=CSET_WEIGHT_NOT_ON_SCALE;
					else Screen->ComboC[cmb]=CSET_WEIGHT_LEFT;
				}
				else if (Screen->ComboC[cmb]==CSET_WEIGHT_NOT_ON_SCALE)Screen->ComboC[cmb]=CSET_WEIGHT_LEFT;
			}
			left=0;
			right=0;
			for (int i=0; i<176;i++){
				if (ComboFI(i, CF_WEIGHT_BUTTON)){
					if (Screen->ComboC[i]==CSET_WEIGHT_LEFT) left += (Screen->ComboD[i]-origcmb);
					if (Screen->ComboC[i]==CSET_WEIGHT_RIGHT) right += (Screen->ComboD[i]-origcmb);
				}
			}
			int drawx = this->X;
			int drawy = this->Y+12;
			if (left<right)drawy-=8;
			if (left>right)drawy+=8;
			Screen->DrawInteger(2, drawx, drawy, FONT_WEIGHT_NUMBER,CSET_WEIGHT_LEFT*16+2,0, -1, -1, left, 0, OP_OPAQUE);
			drawx = this->X+this->TileWidth*16-16;
			drawy = this->Y+12;
			if (left<right)drawy+=8;
			if (left>right)drawy-=8;
			Screen->DrawInteger(2, drawx, drawy, FONT_WEIGHT_NUMBER, CSET_WEIGHT_RIGHT*16+2, 0,-1,-1, right,0, OP_OPAQUE);
			if (left==right){
				this->Data = origdata;
				if (!Screen->State[ST_SECRET]){
					Trace(left);
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
				}
			}
			else if (left>right) this->Data = origdata-1;
			else this->Data = origdata+1;
			Waitframe();
		}
	}
}