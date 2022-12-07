import "std.zh"

const int CR_HP_DISPLAY = 7;//set current life mirror to script 1, can be modified if needed
const int CR_MAX_HP_DISPLAY = 8;//Set max life mirror counter to script 2, can be modified if needed
const int CR_MP_DISPLAY = 9;//set current magic mirror to script 3, can be modified if needed
const int CR_MAX_MP_DISPLAY = 10;//set current magic max mirror counter to script 4, can be modified if needed

//create 4 counters on passive subscreen using script 1, 2, 3, and 4 (or chosen slots) where desired

global script Active
{
   void run()
   {
      while(true)
      {
//section may also contain other global script stuff as normal
         UpdateDisplayCounters();
         Waitdraw();
         Waitframe();
      }
   }
}

void UpdateDisplayCounters()
{
     Game->Counter[CR_HP_DISPLAY] = Link->HP;
     Game->Counter[CR_MAX_HP_DISPLAY] = Link->MaxHP;
     Game->Counter[CR_MP_DISPLAY] = Link->MP;
     Game->Counter[CR_MAX_MP_DISPLAY] = Link->MaxMP;
}