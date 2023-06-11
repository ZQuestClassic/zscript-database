import"std.zh"

// Edit the following constants according to your tileset.

// All combos between and including these two values will be considered regular diggable combos.
// The combo dug by the player will change, and there will be a chance for an item drop.
const int DigComboStart=12;
const int DigComboEnd=19;

// The following combos are similarly diggable, but turn into a different kind of combo and
// do not give item drops. You can use this to have secret stairs, for example.
// Important: Make sure these combos directly follow the DigComboEnd one.
const int DigSpecialStart=20;
const int DigSpecialEnd=23;

// A regular diggable combo will turn into this combo when you use the shovel on it.
const int DugComboNormal=24;

// A special combo will turn into this combo when you use the shovel on it.
// You can, for example, make it a tile warp, so the player can dig for secret entrances.
// Set up the warps and the arrival points on your ZQuest screen as usual.
const int DugComboSpecial=25;

// This is the sound to be played when you successfully dig.
const int ShovelSound=100;
// The sound to be played when you attempt to dig an undiggable combo.
const int ShovelFail=101;
// The secret sound to be played when you dig a special combo.
const int SecretSound=27;

item script Shovel{
  void run(){
    int chance;
    int itemdrop;
    int itemlocx;
    int itemlocy;
    Link->Action=LA_ATTACKING;
    if((Link->Dir==0&&(Screen->ComboD[ComboAt(Link->X+8,Link->Y-8)]<DigComboStart||Screen->ComboD[ComboAt(Link->X+8,Link->Y-8)]>DigSpecialEnd))
    ||(Link->Dir==1&&(Screen->ComboD[ComboAt(Link->X+8,Link->Y+24)]<DigComboStart||Screen->ComboD[ComboAt(Link->X+8,Link->Y+24)]>DigSpecialEnd))
    ||(Link->Dir==2&&(Screen->ComboD[ComboAt(Link->X-8,Link->Y+8)]<DigComboStart||Screen->ComboD[ComboAt(Link->X-8,Link->Y+8)]>DigSpecialEnd))
    ||(Link->Dir==3&&(Screen->ComboD[ComboAt(Link->X+24,Link->Y+8)]<DigComboStart||Screen->ComboD[ComboAt(Link->X+24,Link->Y+8)]>DigSpecialEnd))){
       Game->PlaySound(ShovelFail);
    }
    else{
       Game->PlaySound(ShovelSound);
       chance=Rand(100)+1;
       if(Link->Dir==0){
           if(Screen->ComboD[ComboAt(Link->X+8,Link->Y-8)]<DigSpecialStart){
               Screen->ComboD[ComboAt(Link->X+8,Link->Y-8)]=DugComboNormal;
           }
           else{
               Game->PlaySound(SecretSound);
               Screen->ComboD[ComboAt(Link->X+8,Link->Y-8)]=DugComboSpecial;
               chance=101;
           }
       }
       if(Link->Dir==1){
           if(Screen->ComboD[ComboAt(Link->X+8,Link->Y+24)]<DigSpecialStart){
               Screen->ComboD[ComboAt(Link->X+8,Link->Y+24)]=DugComboNormal;
           }
           else{
               Game->PlaySound(SecretSound);
               Screen->ComboD[ComboAt(Link->X+8,Link->Y+24)]=DugComboSpecial;
               chance=101;
           }
       }
       if(Link->Dir==2){
           if(Screen->ComboD[ComboAt(Link->X-8,Link->Y+8)]<DigSpecialStart){
               Screen->ComboD[ComboAt(Link->X-8,Link->Y+8)]=DugComboNormal;
           }
           else{
               Game->PlaySound(SecretSound);
               Screen->ComboD[ComboAt(Link->X-8,Link->Y+8)]=DugComboSpecial;
               chance=101;
           }
       }
       if(Link->Dir==3){
           if(Screen->ComboD[ComboAt(Link->X+24,Link->Y+8)]<DigSpecialStart){
               Screen->ComboD[ComboAt(Link->X+24,Link->Y+8)]=DugComboNormal;
           }
           else{
               Game->PlaySound(SecretSound);
               Screen->ComboD[ComboAt(Link->X+24,Link->Y+8)]=DugComboSpecial;
               chance=101;
           }
       }
       // The item drops are currently set to be the same as the default tall grass combo drops.
       // The variable "chance" is a randomly generated number between 1 and 100.
       // It determines whether you will get an item, and if so, which one.
       // Here, you have a 20% chance to spawn 1 rupee, and a 15% chance to spawn a heart.
       // If you want, edit this or add more lines to spawn more drops.
       // You can use this line as a template: if(chance>=21&&chance<=35)itemdrop=2;
       // The "chance" variable determines the chance you have of obtaining the item, as we've 
       // seen before, and the "itemdrop" variable is the number of the item in ZQuest.
       if(chance<=20)itemdrop=0;
       if(chance>=21&&chance<=35)itemdrop=2;
       // NB: If you dug a special combo, the "chance" variable is automatically set to 101 so 
       // the script won't spawn drops on top of special combos like stairs.
       if(Link->Dir==0){
           itemlocx=Link->X;
           itemlocy=Link->Y-16;
       }
       if(Link->Dir==1){
           itemlocx=Link->X;
           itemlocy=Link->Y+16;
       }
       if(Link->Dir==2){
           itemlocx=Link->X-16;
           itemlocy=Link->Y;
       }
       if(Link->Dir==3){
           itemlocx=Link->X+16;
           itemlocy=Link->Y;
       }
       // This is the part of the code that spawns the item.
       // If you have edited the default item drops, change "35" and set it according to your drops.
       if(chance<=35){
           item i=Screen->CreateItem(itemdrop);
           i->X=itemlocx;
           i->Y=itemlocy;
           i->Z=10;
           i->Pickup=IP_TIMEOUT;
       }
    }
  }
}