// Set this to the font colour you want. It is set to 1 (white) by default.
const int DMG_FONTCOL=1;
// Set this to three different unused slots for the npc->Misc[] values. If you don't have any other script using those, the default values are fine.
const int DMG_MISC1=1;
const int DMG_MISC2=2;
const int DMG_MISC3=3;

void EnemyDamage(){
int offset;
for(int i=1;i<=Screen->NumNPCs();i++){
  npc enem=Screen->LoadNPC(i);
  if(enem->Misc[DMG_MISC1]==0){
   enem->Misc[DMG_MISC1]=1;
   enem->Misc[DMG_MISC2]=enem->HP;
   enem->Misc[DMG_MISC3]=0;
  }
  if(enem->Misc[DMG_MISC1]!=0&&enem->HP<enem->Misc[DMG_MISC2]){
   enem->Misc[DMG_MISC1]=45;
   enem->Misc[DMG_MISC3]=enem->Misc[DMG_MISC2]-enem->HP;
   enem->Misc[DMG_MISC2]=enem->HP;
  }
  if(enem->Misc[DMG_MISC1]>1){
   if(enem->Misc[DMG_MISC3]>9){offset=0;}
   else{offset=4;}
   if(enem->Misc[DMG_MISC1]%3!=0)Screen->DrawInteger(6, enem->X+offset, enem->Y-18+(enem->Misc[DMG_MISC1]/5), FONT_Z1, DMG_FONTCOL, -1, -1, -1, enem->Misc[DMG_MISC3], 0, 128);
   enem->Misc[DMG_MISC1]--;
  }
}
}