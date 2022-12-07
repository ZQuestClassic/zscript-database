const int TREE_COMBO=43; //Used combo type (43=overhead)
const int TREE_IFLAG=0; //Or use inherent flags if you prefer this over a combo type

void TreeLayers(){
int cpos=ComboAt(256,Link->Y+8);
int lpos=ComboAt(Link->X+8,Link->Y);

//Layer 4->5
if(Link->Action!=LA_SCROLLING && Link->Z>0 && ((TREE_COMBO>0 && GetLayerComboT(4,lpos)==TREE_COMBO) || (TREE_IFLAG>0 && GetLayerComboI(4,lpos)==TREE_IFLAG))){
while(cpos>=0){

if((TREE_COMBO>0 && GetLayerComboT(4,cpos)==TREE_COMBO) || (TREE_IFLAG>0 && GetLayerComboI(4,cpos)==TREE_IFLAG)){
Screen->FastCombo(5,ComboX(cpos),ComboY(cpos),GetLayerComboD(4,cpos),GetLayerComboC(4,cpos),128);
}

cpos--;
}
}

} //TreeLayers


int GetLayerComboC(int layer, int cpos){
if(layer==0){ return(Screen->ComboC[cpos]); }
else{ return(Game->GetComboCSet(Screen->LayerMap(layer),Screen->LayerScreen(layer),cpos)); }
} //GetLayerComboC

int GetLayerComboI(int layer, int cpos){
if(layer==0){ return(Screen->ComboI[cpos]); }
else{ return(Game->GetComboInherentFlag(Screen->LayerMap(layer),Screen->LayerScreen(layer),cpos)); }
} //GetLayerComboI