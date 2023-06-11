import "std.zh"

const int PILLAR_SENSITIVITY=8; //Number of frames the block needs to be pushed before it starts moving

ffc script PushablePillars{
    void run(int orientation, int distance){ //Horizontal/Vertical pushing
    distance=distance*16;
    int undercombo;
    int framecounter=0;
    int pushcounter=0;
    int anicounter=0;
    int anitile=0;
    int originaltile=this->Data;
    int pushspeed=1;
    int width=this->TileWidth;
    int height=this->TileHeight;

        Waitframe();
        undercombo=GetLayerComboD(1,this->Y+(this->X>>4));
        if(orientation==1){ SetSolidCombo(3,this->X,this->Y,width,height,this->Data); } //Horizontally
        if(orientation==2){ SetSolidCombo(1,this->X,this->Y,width,height,this->Data); } //Vertically

        while(true){
            if((Link->X==this->X-16 && (Link->Y<this->Y+4+((height-1)*16) && Link->Y>this->Y-4)
            && Link->InputRight && Link->Dir==DIR_RIGHT && orientation==1) || // Right

            (Link->X==this->X+16 && (Link->Y<this->Y+4+((height-1)*16) && Link->Y>this->Y-4)
            && Link->InputLeft && Link->Dir==DIR_LEFT && orientation==1) || // Left

            (Link->Y==this->Y-16 && (Link->X<this->X+4+((width-1)*16) && Link->X>this->X-4)
            && Link->InputDown && Link->Dir==DIR_DOWN && orientation==2) || // Down

            (Link->Y==this->Y+8 && (Link->X<this->X+4+((width-1)*16) && Link->X>this->X-4) //Change the 8 to 16 if you use big Link
            && Link->InputUp && Link->Dir==DIR_UP && orientation==2)
            ){ // Up
        framecounter++;
        }
        else{ framecounter=0; }

        if(framecounter>=PILLAR_SENSITIVITY){

            if(Link->Dir==DIR_RIGHT){
                while(
                this->X<240 &&
                !ComboFI(this->X+16,this->Y,CF_NOBLOCKS) &&
                NoSolidBlocks(4,this->X,this->Y,width,height)==true &&
                pushcounter<distance
                ){
                    if(pushcounter==0){ Game->PlaySound(SFX_PUSHBLOCK); }
                    if(pushcounter<distance/2){ NoAction(); }
                    if(pushcounter%4==0 && pushcounter!=0){ anitile+=1; }
                    if(anitile>3){ anitile=0; }
                    SetSolidCombo(4,this->X,this->Y,width,height,undercombo);
                    this->Vx=pushspeed;
                    this->Data=originaltile+anitile;
                    pushcounter+=pushspeed;
                    Waitframe();
                    if(pushcounter%16==0){ SetUnderCombo(4,this->X-16,this->Y,width,height); }
                }
            this->Vx=0;
            this->Data=originaltile;
            pushcounter=0;
            anitile=0;
            SetSolidCombo(4,this->X,this->Y,width,height,this->Data);
            }

            else if(Link->Dir==DIR_LEFT){
                while(
                this->X>0 &&
                !ComboFI(this->X-1,this->Y,CF_NOBLOCKS) &&
                NoSolidBlocks(3,this->X,this->Y,width,height)==true &&
                pushcounter<distance
                ){
                    if(pushcounter==0){ Game->PlaySound(SFX_PUSHBLOCK); }
                    if(pushcounter<distance/2){ NoAction(); }
                    if(pushcounter%4==0 && pushcounter!=0){ anitile-=1; }
                    if(anitile<0){ anitile=3; }
                    SetSolidCombo(3,this->X,this->Y,width,height,undercombo);
                    this->Vx=-pushspeed;
                    this->Data=originaltile+anitile;
                    pushcounter+=pushspeed;
                    Waitframe();
                    if(pushcounter%16==0){ SetUnderCombo(3,this->X+16,this->Y,width,height); }
                }
            this->Vx=0;
            this->Data=originaltile;
            pushcounter=0;
            anitile=0;
            SetSolidCombo(3,this->X,this->Y,width,height,this->Data);
            }

            else if(Link->Dir==DIR_DOWN){
                while(
                this->Y<160 &&
                !ComboFI(this->X, this->Y+16, CF_NOBLOCKS) &&
                NoSolidBlocks(2,this->X,this->Y,width,height)==true &&
                pushcounter<distance
                ){
                    if(pushcounter==0){ Game->PlaySound(SFX_PUSHBLOCK); }
                    if(pushcounter<distance/2){ NoAction(); }
                    if(pushcounter%4==0 && pushcounter!=0){ anitile+=4; }
                    if(anitile>12){ anitile=0; }
                    SetSolidCombo(2,this->X,this->Y,width,height,undercombo);
                    this->Vy=pushspeed;
                    this->Data=originaltile+anitile;
                    pushcounter+=pushspeed;
                    Waitframe();
                    if(pushcounter%16==0){ SetUnderCombo(2,this->X,this->Y-16,width,height); }
                }
            this->Vy=0;
            this->Data=originaltile;
            pushcounter=0;
            anitile=0;
            SetSolidCombo(2,this->X,this->Y,width,height,this->Data);
            }

            else if(Link->Dir==DIR_UP){
                while(
                this->Y>0 &&
                !ComboFI(this->X, this->Y-1, CF_NOBLOCKS) &&
                NoSolidBlocks(1,this->X,this->Y,width,height)==true &&
                pushcounter<distance
                ){
                    if(pushcounter==0){ Game->PlaySound(SFX_PUSHBLOCK); }
                    if(pushcounter<distance/2){ NoAction(); }
                    if(pushcounter%4==0 && pushcounter!=0){ anitile-=4; }
                    if(anitile<0){ anitile=12; }
                    SetSolidCombo(1,this->X,this->Y,width,height,undercombo);
                    this->Vy=-pushspeed;
                    this->Data=originaltile+anitile;
                    pushcounter+=pushspeed;
                    Waitframe();
                    if(pushcounter%16==0){ SetUnderCombo(1,this->X,this->Y+16,width,height); }
                }
            this->Vy=0;
            this->Data=originaltile;
            pushcounter=0;
            anitile=0;
            SetSolidCombo(1,this->X,this->Y,width,height,this->Data);
            }

         framecounter=0;
         }

         Waitframe();
      }
   }
}


bool NoSolidBlocks(int direction, int xpos, int ypos, int width, int height){
int size=1;
    if(direction==1 || direction==2){ size=width; } //Vertical pushing
    if(direction==3 || direction==4){ size=height; } //Horizontal pushing

    for(int i=size-1; i>=0; i--){
        if(xpos%16==0 && ypos%16==0){
            if(direction==1){ if(Screen->ComboS[ypos-16+((xpos+(i*16))>>4)]!=0000b){ return(false); } }
            if(direction==2){ if(Screen->ComboS[ypos+16+((xpos+(i*16))>>4)]!=0000b){ return(false); } }
            if(direction==3){ if(Screen->ComboS[ypos+(i*16)+((xpos-16)>>4)]!=0000b){ return(false); } }
            if(direction==4){ if(Screen->ComboS[ypos+(i*16)+((xpos+16)>>4)]!=0000b){ return(false); } }
        }
    }
    return(true);
}

int SetSolidCombo(int direction, int xpos, int ypos, int width, int height, int data){
int size=1;
    if(direction==1 || direction==2){ size=width; } //Vertical pushing
    if(direction==3 || direction==4){ size=height; } //Horizontal pushing

    for(int i=size-1; i>=0; i--){
        if(xpos%16==0 && ypos%16==0){
            if(direction==1){ Screen->ComboD[ypos+((xpos+(i*16))>>4)]=data; }
            if(direction==2){ Screen->ComboD[ypos+((xpos+(i*16))>>4)]=data; }
            if(direction==3){ Screen->ComboD[ypos+(i*16)+(xpos>>4)]=data; }
            if(direction==4){ Screen->ComboD[ypos+(i*16)+(xpos>>4)]=data; }
        }
    }
}

int SetUnderCombo(int direction, int xpos, int ypos, int width, int height){
int size=1;
    if(direction==1 || direction==2){ size=width; } //Vertical pushing
    if(direction==3 || direction==4){ size=height; } //Horizontal pushing

    for(int i=size-1; i>=0; i--){
        if(xpos%16==0 && ypos%16==0){
            if(direction==1){ Screen->ComboD[ypos+((xpos+(i*16))>>4)]=GetLayerComboD(1,ComboAt(xpos+(i*16),ypos)); }
            if(direction==2){ Screen->ComboD[ypos+((xpos+(i*16))>>4)]=GetLayerComboD(1,ComboAt(xpos+(i*16),ypos)); }
            if(direction==3){ Screen->ComboD[ypos+(i*16)+(xpos>>4)]=GetLayerComboD(1,ComboAt(xpos,ypos+(i*16))); }
            if(direction==4){ Screen->ComboD[ypos+(i*16)+(xpos>>4)]=GetLayerComboD(1,ComboAt(xpos,ypos+(i*16))); }
            if(direction==1){ Screen->ComboT[ypos+((xpos+(i*16))>>4)]=GetLayerComboT(1,ComboAt(xpos+(i*16),ypos)); }
            if(direction==2){ Screen->ComboT[ypos+((xpos+(i*16))>>4)]=GetLayerComboT(1,ComboAt(xpos+(i*16),ypos)); }
            if(direction==3){ Screen->ComboT[ypos+(i*16)+(xpos>>4)]=GetLayerComboT(1,ComboAt(xpos,ypos+(i*16))); }
            if(direction==4){ Screen->ComboT[ypos+(i*16)+(xpos>>4)]=GetLayerComboT(1,ComboAt(xpos,ypos+(i*16))); }
        }
    }
}