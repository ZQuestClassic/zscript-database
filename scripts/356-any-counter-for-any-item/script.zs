import "std.zh"
int GItem;
int GCounter;
int GCost;
item script CounterItem{
   void run(int Item, int Counter, int Cost){

      if((Game->Counter[Counter]>=Cost)&&(Link->Action==LA_ATTACKING)){
   Game->Counter[Counter]-=Cost;
      }
      if((Game->Counter[Counter]>=Cost)&&(Link->Action==LA_CASTING)){
   Game->Counter[Counter]-=Cost;
      }
      if((Game->Counter[Counter]>=Cost)&&(Link->Jump>0)){
   Game->Counter[Counter]-=Cost;
      }
      if(Game->Counter[CR_MAGIC]){
   Cost = Cost*Game->Generic[GEN_MAGICDRAINRATE];
      }
   GItem=Item;
   GCounter=Counter;
   GCost=Cost;
   }
}


void GlobalCounter(){
if ((GetEquipmentA()==GItem)&&(Game->Counter[GCounter]<GCost)){
Link->InputA=false;
}
if ((GetEquipmentB()==GItem)&&(Game->Counter[GCounter]<GCost)){
Link->InputB=false;
}
if ((GetEquipmentA()==GItem)&&(GCounter==CR_LIFE)&&(Game->Counter[CR_LIFE]<=GCost)){
Link->InputA=false;
}
if ((GetEquipmentB()==GItem)&&(GCounter==CR_LIFE)&&(Game->Counter[CR_LIFE]<=GCost)){
Link->InputB=false;
}
if(Link->InputA){
int id = GetEquipmentA();
if(id>0){
itemdata A = Game->LoadItemData(id);
if((A->Family==IC_ROCS)&&(Link->Jump>0)){
Link->InputA=false;
}
}
}
else if(Link->InputB){
int id = GetEquipmentB();
if(id>0){
itemdata B = Game->LoadItemData(id);
if((B->Family==IC_ROCS)&&(Link->Jump>0)){
Link->InputB=false;
}
}
}
}
global script SLOT_2{
	void run(){
		while(true){

			GlobalCounter();

			Waitdraw();

			Waitframe();
		}
	}
}