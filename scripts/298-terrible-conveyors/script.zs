//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Place a transparent non-combo-0 ffc on the screen you wish to have conveyors function better.                                             //
//D0: The combo ID for up conveyors.                                                                                                        //
//D1: The combo ID for down conveyors.                                                                                                      //
//D2: The combo ID for left conveyors.                                                                                                      //
//D3: The combo ID for right conveyors.                                                                                                     //
//D4: Speed of conveyors. The higher the number, the slower the conveyor. 1 is standard conveyor, 0 is irresistible.                        //
//D5: Whether conveyors will push enemies or not. (Will affect ALL enemies). 0 for yes, 1 for no.                                           //
//Uses combo type 89-92.                                                                                                                    //
//Does not work with sideview screen as a solid block. Will work fine as walkable on sideview.                                              //
//                                                                                                                                          //
// AUTHOR: Emily                                                  //                                               VERSION: 1.1 (1/30/2018) //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ffc script fullConveyor{
	void run(int up, int down, int left, int right, int spd, bool noNPC){
		int frame = 0;
		int mov = 1;
		if(spd==0)mov = 2;
		while(true){
			if(spd==0||frame%spd==0){
			//start Link//
			int ul = GetLayerComboD(0,ComboAt(Link->X,Link->Y));
			int ur = GetLayerComboD(0,ComboAt(Link->X+15,Link->Y));
			int bl = GetLayerComboD(0,ComboAt(Link->X,Link->Y+15));
			int br = GetLayerComboD(0,ComboAt(Link->X+15,Link->Y+15));
			if(ul==down||ur==down||bl==down||br==down){
				if(CanWalk(Link->X,Link->Y,DIR_DOWN,1,false)){
					Link->Y+=mov;
				}
			}
			if(ul==left||ur==left||bl==left||br==left){
				if(CanWalk(Link->X,Link->Y,DIR_LEFT,1,false)){
					Link->X-=mov;
				}
			}
			if(ul==right||ur==right||bl==right||br==right){
				if(CanWalk(Link->X,Link->Y,DIR_RIGHT,1,false)){
					Link->X+=mov;
				}
			}
			if(ul==up||ur==up||bl==up||br==up){
				if(CanWalk(Link->X,Link->Y,DIR_UP,1,false)){
					Link->Y-=mov;
				}
			}
			//end Link//
			//start Item//
			for(int i = 1;i<=Screen->NumItems();i++){
				item anItem = Screen->LoadItem(i);
				int ul = GetLayerComboT(0,ComboAt(anItem->X,anItem->Y));
				int ur = GetLayerComboT(0,ComboAt(anItem->X+15,anItem->Y));
				int bl = GetLayerComboT(0,ComboAt(anItem->X,anItem->Y+15));
				int br = GetLayerComboT(0,ComboAt(anItem->X+15,anItem->Y+15));
				if(ul==down||ur==down||bl==down||br==down){
					if(CanWalk(anItem->X,anItem->Y,DIR_DOWN,1,false)){
						anItem->Y+=mov;
					}
				}
				if(ul==left||ur==left||bl==left||br==left){
					if(CanWalk(anItem->X,anItem->Y,DIR_LEFT,1,false)){
						anItem->X-=mov;
					}	
				}
				if(ul==right||ur==right||bl==right||br==right){
					if(CanWalk(anItem->X,anItem->Y,DIR_RIGHT,1,false)){
						anItem->X+=mov;
					}
				}
				if(ul==up||ur==up||bl==up||br==up){
					if(CanWalk(anItem->X,anItem->Y,DIR_UP,1,false)){
						anItem->Y-=mov;
					}
				}
			}
			//end Item//
			//start Enemies//
			if(!noNPC){
			for(int i = 1;i<=Screen->NumNPCs();i++){
				npc anNPC = Screen->LoadNPC(i);
				int ul = GetLayerComboT(0,ComboAt(anNPC->X,anNPC->Y));
				int ur = GetLayerComboT(0,ComboAt(anNPC->X+15,anNPC->Y));
				int bl = GetLayerComboT(0,ComboAt(anNPC->X,anNPC->Y+15));
				int br = GetLayerComboT(0,ComboAt(anNPC->X+15,anNPC->Y+15));
				if(ul==down||ur==down||bl==down||br==down){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_DOWN,1,false)){
						anNPC->Y+=mov;
					}
				}
				if(ul==left||ur==left||bl==left||br==left){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_LEFT,1,false)){
						anNPC->X-=mov;
					}
				}
				if(ul==right||ur==right||bl==right||br==right){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_RIGHT,1,false)){
						anNPC->X+=mov;
					}
				}
				if(ul==up||ur==up||bl==up||br==up){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_UP,1,false)){
						anNPC->Y-=mov;
					}
				}
			}
			}
			//end Enemies//
			}
			frame++;
			Waitframe();
		}
	}
}

//////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Place an invisible ffc with this script on the screen you wish to use diagonal conveyors on.                                              //
//D0: The combo ID for down-right conveyors.                                                                                                //
//D1: The combo ID for down-left conveyors.                                                                                                 //
//D2: The combo ID for up-right conveyors.                                                                                                  //
//D3: The combo ID for up-left conveyors.                                                                                                   //
//D4: The speed for conveyors. Lower is faster. 2 is standard, 0 cannot be resisted.                                                        //
//D5: Whether or not to push enemies. 0 for yes, 1 for no.                                                                                  //
//                                                                                                                                          //
// AUTHOR: Emily                                                  //                                               VERSION: 1.0 (1/13/2018) //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ffc script diagConveyor{
	void run(int dright, int dleft, int uright, int uleft, int spd, bool noNPC){
		int frame = 0;
		int mov = 1;
		if(spd==0)mov = 2;
		while(true){
			if(spd==0||frame==spd){
			frame=0;
			//start Link//
			int ul = GetLayerComboD(0,ComboAt(Link->X,Link->Y));
			int ur = GetLayerComboD(0,ComboAt(Link->X+15,Link->Y));
			int bl = GetLayerComboD(0,ComboAt(Link->X,Link->Y+15));
			int br = GetLayerComboD(0,ComboAt(Link->X+15,Link->Y+15));
			if(ul==dright||ur==dright||bl==dright||br==dright){
				if(CanWalk(Link->X,Link->Y,DIR_DOWN,1,true)&&CanWalk(Link->X,Link->Y,DIR_RIGHT,1,true)){
					Link->Y+=mov;
					Link->X+=mov;
				}
			}
			if(ul==dleft||ur==dleft||bl==dleft||br==dleft){
				if(CanWalk(Link->X,Link->Y,DIR_LEFT,1,true)&&CanWalk(Link->X,Link->Y,DIR_DOWN,1,true)){
					Link->Y+=mov;
					Link->X-=mov;
				}
			}
			if(ul==uright||ur==uright||bl==uright||br==uright){
				if(CanWalk(Link->X,Link->Y,DIR_RIGHT,1,true)&&CanWalk(Link->X,Link->Y,DIR_UP,1,true)){
					Link->Y-=mov;
					Link->X+=mov;
				}
			}
			if(ul==uleft||ur==uleft||bl==uleft||br==uleft){
				if(CanWalk(Link->X,Link->Y,DIR_UP,1,true)&&CanWalk(Link->X,Link->Y,DIR_LEFT,1,true)){
					Link->Y-=mov;
					Link->X-=mov;
				}
			}
			//end Link//
			//start Item//
			if(Screen->NumItems()>0){
			for(int i = 1;i<=Screen->NumItems();i++){
				item anItem = Screen->LoadItem(i);
				int ul = GetLayerComboD(0,ComboAt(anItem->X,anItem->Y));
				int ur = GetLayerComboD(0,ComboAt(anItem->X+15,anItem->Y));
				int bl = GetLayerComboD(0,ComboAt(anItem->X,anItem->Y+15));
				int br = GetLayerComboD(0,ComboAt(anItem->X+15,anItem->Y+15));
				if(ul==dright||ur==dright||bl==dright||br==dright){
					if(CanWalk(anItem->X,anItem->Y,DIR_DOWN,1,false)){
						anItem->Y+=mov;
						anItem->X+=mov;
					}
				}
				if(ul==dleft||ur==dleft||bl==dleft||br==dleft){
					if(CanWalk(anItem->X,anItem->Y,DIR_LEFT,1,false)){
						anItem->Y+=mov;
						anItem->X-=mov;
					}
				}
				if(ul==uright||ur==uright||bl==uright||br==uright){
					if(CanWalk(anItem->X,anItem->Y,DIR_RIGHT,1,false)){
						anItem->Y-=mov;
						anItem->X+=mov;
					}
				}
				if(ul==uleft||ur==uleft||bl==uleft||br==uleft){
					if(CanWalk(anItem->X,anItem->Y,DIR_UP,1,false)){
						anItem->Y-=mov;
						anItem->X-=mov;
					}
				}
			}
			}
			//end Item//
			//start Enemies//
			if(!noNPC && Screen->NumNPCs()>0){
			for(int i = 1;i<=Screen->NumNPCs();i++){
				npc anNPC = Screen->LoadNPC(i);
				int ul = GetLayerComboD(0,ComboAt(anNPC->X,anNPC->Y));
				int ur = GetLayerComboD(0,ComboAt(anNPC->X+15,anNPC->Y));
				int bl = GetLayerComboD(0,ComboAt(anNPC->X,anNPC->Y+15));
				int br = GetLayerComboD(0,ComboAt(anNPC->X+15,anNPC->Y+15));
				if(ul==dright||ur==dright||bl==dright||br==dright){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_DOWN,1,false)){
						anNPC->Y+=mov;
						anNPC->X+=mov;
					}
				}
				if(ul==dleft||ur==dleft||bl==dleft||br==dleft){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_LEFT,1,false)){
						anNPC->Y+=mov;
						anNPC->X-=mov;
					}
				}
				if(ul==uright||ur==uright||bl==uright||br==uright){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_RIGHT,1,false)){
						anNPC->Y-=mov;
						anNPC->X+=mov;
					}
				}
				if(ul==uleft||ur==uleft||bl==uleft||br==uleft){
					if(CanWalk(anNPC->X,anNPC->Y,DIR_UP,1,false)){
						anNPC->Y-=mov;
						anNPC->X-=mov;
					}
				}
			}}
			//end Enemies//
			}
			frame++;
			Waitframe();
		}
	}
}