///////////////////////////////
/// FUTHARK.Z  By: ZoriaRPG ///
////////////////////////////////////////////////////////////////////////
/// Dependencies: std.zh - NO OTHERS - v5.0 - 5th May, 2014          ///
////////////////////////////////////////////////////////////////////////
/// I designed this script for mabusTheDark, whether he uses it,     ///
/// or not. The function is to make each rune of the Elder Futhark   ///
/// (The Old Norse Runes, a collectible object, en lieu of Triforce  ///
/// pieces. This means there are twenty-four 'quest objects, so to   ///
/// help balance out a game, unless you want 24 dungeons with one    ///
/// runestone each, twelve with two, you can make a standard quest   ///
/// that has eight dungeons each, which three runestones.            ///
/// ---------------------------------------------------------------- ///
/// When the player has all twenty-four rune-stones, the script set  ///
/// automatically gives the player the whole triforce (L1-L8 pieces) ///
/// to satisfy standard Triforce Check Rooms.                        ///
/// ---------------------------------------------------------------- ///
/// In addition to this, the script is set up to allow a questmaker  ///
/// to give out quest items, rather than as stabdard, by completing  ///
/// names of the Elder Gods, such as Thor, by collecting the runes   ///
/// that spell their name. In the case of Thor, you would need to    ///
/// collect 'thurisaz' (th), 'othila' (o), and 'radio' (r), which    ///
/// of course spell (Th)(o)(r).                                      ///
/// ---------------------------------------------------------------- ///
/// You can set it up so that the player collects pieces in an order ///
/// that gives the player desired items, in a set sequence. While I  ///
/// have pre-set items, for the names of gods, based on their powers ///
/// you cal re-assign them as you see fit.                           ///
/// ---------------------------------------------------------------- ///
/// If you wish, to ensure that players have access to items in the  ///
/// case that your dungeon design makes it impossible to progress    ///
/// without them, simply change and set the constants, to other      ///
/// items of your choice. While I have tried to set these to items   ///
/// that are not usually mandatory, such as upgrades (longbow, the   ///
/// red candle, magic & health rings, and such, it also includes     ///
/// nornmally mandatory items, such as the wand, magic book, and the ///
/// whistle. If those items are mandatory, you can simply place them ///
/// where needed, and ignore the code that enables them.             ///
/// ---------------------------------------------------------------- ///
/// Alternatively, you can make L2, or L3 items that 'upgrade' the   ///
/// nornal items, when the player collects the runes.                ///
/// ---------------------------------------------------------------- ///
/// Some items are set to special constants, that are not normal ZC  ///
/// items, including VolundSword (Volund is the Smith of the Gods),  ///
/// bolt (usable with my bolt.z script set, I_Tyr, that you can set  ///
/// to an appropriate item, and some others. i suggest making a      ///
/// custom sword, or using the most powerful sword for Volund, and   ///
/// you can require a minimal health level with some slight changes. ///
/// ---------------------------------------------------------------- ///
/// The script sets constants for the 'Runestone' items, in pairs:   ///
/// THe first set, of real items, are the 'dummy' items that the     ///
/// player will see on the subscreen. (THis allows displaying them   ///
/// in a row, on the PASSIVE subscreen, rather than the normal ZC    ///
/// placement on the ACTIVE subscreen.                               ///
/// ---------------------------------------------------------------- ///
/// You should set each of these to a unique item, and a unique item ///
/// class. The standard set-up assigns these to items 150-173, and   ///
/// following this, you will need to set another 24 items up as TF   ///
/// pieces, if you want a TF fanfare. This is an optional step, and  ///
/// is only required if you want to play the TF music, cutscene, and ///
/// the health & magic refils that are normally used when the player ///
/// picks up a TF piece, and are utilised with an included pickup    ///
/// script. See 'SETUP' for information on this.                     ///
/// ---------------------------------------------------------------- ///
/// The second set should, if used, be placed on another series of   ///
/// items (another 24), all with the item class 'Triforce Piece',    ///
/// and if you use these, you should set your dungeon levels all to  ///
/// either Level 0, or to levels of 10 or higher.                    ///
////////////////////////////////////////////////////////////////////////

/////////////
/// SETUP ///
////////////////////////////////////////////////////////////////////////
/// Create either 24 items (if not uaing the TF fanfare, or 48 items ///
/// if you plan to use this feature. Assign a unique item class to   ///
/// each item, or a single item class, with levels 1 to 24, and be   ///
/// certain to set the Item override for each on the subscreen.      ///
/// ---------------------------------------------------------------- ///
/// If using the TF fanfare, create twenty-four items with the ITEM  ///
/// CLASS 'TRIFORCE PIECE', each with the same combo as its matching ///
/// RUNESTONE item.                                                  ///
/// ---------------------------------------------------------------- ///
/// For each of these, set the pickup script 'fakeRuneStoneGiveReal' ///
/// and in the D0 argument for each of them, set the item number for ///
/// the real RUNESTONE item.                                         ///
/// ---------------------------------------------------------------- ///
/// For example,if your real FEHU stoneis item 150, and your FAKE    ///
/// FEHU TRIFORCE CLASS item that matches it is item 174 (standard)  ///
/// set the pickup script on the item with the TRIFOCE PIECE class   ///
/// with the D0 argument D0 set to 150 (matching the real RUNESTONE. ///
/// ---------------------------------------------------------------- ///
/// Once you have set up your items, adjust the constants with the   ///
/// actual ITEM NUMBERS fron the ITEM EDITOR.                        ///
/// ---------------------------------------------------------------- ///
/// For the special items (bolt, VolundSword, I_Tyr), either create  ///
/// custom items (using existing, or new scripts, such as bolt.z),   ///
/// or set these to normal items, if you prefer.                     ///
/// ---------------------------------------------------------------- ///
/// The DEFAULT ITEM NUMBERS start at ITEM 150. If you start adding  ///
/// RUNESTONES (and TF CLASS DUPLICATES, should you elect to use     ///
/// them, and start at item 150, then you do not need to modify the  ///
/// CONSTANTS for the RUNESTONE ITEMS.                               ///
/// ---------------------------------------------------------------- ///
/// If you do use different numbers, you will need to modify the     ///
/// pre-set ITEM CONSTANTS to match the item numbers in the editor.  ///
/// ---------------------------------------------------------------- ///
/// Note that the RUNESTONES 'PERTH' and 'KAUNAN' are not tied to    ///
/// the names of the Norse gods in this script, but if you wish, you ///
/// can add other names (such as Loki, to use 'KAUNAN', connected    ///
/// to additional code that you muat add to enable giving out items  ///
/// for these other god-names.                                       ///
/// ---------------------------------------------------------------- ///
/// The RUNESTONES 'PERTH' and 'KAUNAN' are still required to pass a ///
/// TRIFORCE CHECK ROOM, so it may be prudent to give these last,    ///
/// unless you assign them to a god name.                            ///
////////////////////////////////////////////////////////////////////////

//import "std.zh" //Disable this if you already call to import this header.

//Set these numeric values to the Item Editor values of 
//The matching Runestone items. For example, if the item
//editor value of the runestone fehu is 160, change the value fron 150
//to 160, and change each other value accordingly.

//Not used at present:
//  perth
//  kaunan

////////////////////////////////
/// REAL RUNESTONE CONSTANTS ///
////////////////////////////////////////////////////////////////////////
/// These set the constants for the item numbers (in the ITEM EDITOR ///
/// panel) that are used by the RUNESTONES that have CUSTOM CLASSES. ///
/// ---------------------------------------------------------------- ///
/// Change these to match the actual items of the RUNESTONES that    ///
/// you create, and either set each to a unique ITEM CLASS, or to a  ///
/// UNIQUE LEVEL. If you use UNIQUE CLASSES for each, you need only  ///
/// set the ITEM CLASS on either your PASSIVE< or your ACTIVE        ///
/// SUBSCREEN(S).                                                    ///
/// ---------------------------------------------------------------- ///
/// Else if you assign the same item class to each, and use levels   ///
/// to differentiate them, be sure to set each to a unique level     ///
/// starting at level 1, and ending at Level 24, and then set each   ///
/// with an ITEM OVERRIDE on your SUBSCREEN, to avoid conflicts.     ///
////////////////////////////////////////////////////////////////////////


const int fehu = 145; 
const int uruz = 146; 
const int thurisaz = 147;
const int ansuz = 148;
const int radio = 149;
const int kaunan = 151;
const int gebo = 152;
const int wunjo = 153;
const int hagalaz = 154;
const int nuadiz = 154;
const int isaz = 156;
const int jera = 157;
const int eihwaz = 158;
const int perth = 159;
const int algiz = 160;
const int sowilo = 161;
const int teiwaz = 162;
const int berkanan = 163;
const int ehwaz = 164;
const int mannaz = 165;
const int laguz = 166;
const int injwaz = 167;
const int othila = 169;
const int dagaz = 168;

/////////////////////////////////////////
/// BOOLS FOR POSESSION OF RUNESTONES ///
////////////////////////////////////////////////////////////////////////
/// These set up if a 'letter' of a god-name is present the player's /// 
/// inventory. When collecting these, the 'letters become active,    ///
/// and when the name of a god is complete, the function that work   ///
/// to enable items for the player activate.                         ///
/// ---------------------------------------------------------------- ///
/// If the name of a god consists of more then one instance of any   ///
/// letter, such as two Ns in MANNAZ, only one RUNESTONE is needed   ///
/// to fulfill both instances of the 'N' in that name, or any other  ///
/// letter that occurs more than once.                               ///
////////////////////////////////////////////////////////////////////////

bool rune_fehu = false; 
bool rune_uruz = false;
bool rune_thurisaz = false;
bool rune_ansuz = false;
bool rune_radio = false;
bool rune_kaunan = false;
bool rune_gebo = false;
bool rune_wunjo = false;
bool rune_hagalaz = false;
bool rune_nuadiz = false;
bool rune_isaz = false;
bool rune_jera = false;
bool rune_eihwaz = false;
bool rune_perth = false;
bool rune_algiz = false;
bool rune_sowilo = false;
bool rune_teiwaz = false;
bool rune_berkanan = false;
bool rune_ehwaz = false;
bool rune_mannaz = false;
bool rune_laguz = false;
bool rune_injwaz = false;
bool rune_othila = false;
bool rune_dagaz = false;

///////////////////////////
/// BOOLS FOR GOD NAMES ///
////////////////////////////////////////////////////////////////////////
/// These are the names of the Norse Gods used in this script. You   ///
/// may add to them, remove them, or change them as you wish, but to ///
/// do this, you will need to add code to enable spelling out names. ///
////////////////////////////////////////////////////////////////////////

bool thor;
bool odin;
bool freyr;
bool volund;
bool bragi = false;
bool hilin = false;
bool njord = false;
bool tyr = false;
bool eyr = false;
bool yggdrasil = false;
bool mani = false;
bool gefion = false;
bool freyja = false;
bool gullveig = false;
bool vor = false;
bool heimdall = false;
bool iduna = false;
bool elli = false;
bool sol = false;
bool aegir = false;
bool hermod = false;

//////////////////////////////
/// SPECIAL ITEM CONSTANTS ///
////////////////////////////////////////////////////////////////////////
/// Set these constants with the ITEM EDITOR number for the items    ///
/// that you wish to give the player, fr these special objects. You  ///
/// can use in-game items, in in the case of two (e.g. Volund, Thor) ///
/// I included normal system alternatives.                           ///
/// ---------------------------------------------------------------- ///
/// I further included some alternative selections that you may opt  ///
/// to enable, or disbale, to best set the items for your game.      ///
/// ---------------------------------------------------------------- ///
///  Set the items to give in the global function itemsOfTheGods();  ///
////////////////////////////////////////////////////////////////////////

const int VolundSword = 36; //Set to strongest sword.
const int bolt = 9; //Set to bolt item, ot to hammer item is not using bolt.
const int I_Tyr = 0; //Set to item for Tyr

    
/////////////////////    
/// GLOBAL SCRIPT ///
/////////////////////


global script active {
    void run() {
        while(true) {
        runeStoneLetters();
        godNames();
        itemsOftheGods();
        runestones();
        Waitdraw();
        Waitframe();
        }
    }
}

//////////////////
/// RUNESTONES ///
////////////////////////////////////////////////////////////////////////
/// This function sets up giving the whole TRIFORCE when the player  ///
/// collects all of the RUNESTONES.                                  ///
////////////////////////////////////////////////////////////////////////

void runestones() {
    if (Link->Item[fehu] == true
    && Link->Item[uruz] == true
    && Link->Item[thurisaz] == true
    && Link->Item[ansuz] == true
    && Link->Item[radio] == true
    && Link->Item[kaunan] == true
    && Link->Item[gebo] == true
    && Link->Item[wunjo] == true
    && Link->Item[hagalaz] == true
    && Link->Item[nuadiz] == true
    && Link->Item[isaz] == true
    && Link->Item[jera] == true
    && Link->Item[eihwaz] == true
    && Link->Item[perth] == true
    && Link->Item[algiz] == true
    && Link->Item[sowilo] == true
    && Link->Item[teiwaz] == true
    && Link->Item[berkanan] == true
    && Link->Item[ehwaz] == true
    && Link->Item[mannaz] == true
    && Link->Item[laguz] == true
    && Link->Item[injwaz] == true
    && Link->Item[othila] == true
    && Link->Item[dagaz] == true ) {
        SetLevelItem(1, LI_TRIFORCE, true);
        SetLevelItem(2, LI_TRIFORCE, true);
        SetLevelItem(3, LI_TRIFORCE, true);
        SetLevelItem(4, LI_TRIFORCE, true);
        SetLevelItem(5, LI_TRIFORCE, true);
        SetLevelItem(6, LI_TRIFORCE, true);
        SetLevelItem(7, LI_TRIFORCE, true);
        SetLevelItem(8, LI_TRIFORCE, true);
    }
}

/////////////////////////
/// RUNESTONE LETTERS ///
////////////////////////////////////////////////////////////////////////
/// This function assigns 'letters' to each RUNESTONE, to use with   ///
/// the function godNames();                                         ///
////////////////////////////////////////////////////////////////////////


void runeStoneLetters(){
    if ( Link->Item[fehu] == true ) {
        rune_fehu = true;
        }
    if ( Link->Item[uruz] == true ) {
        rune_uruz = true;
        }
    if ( Link->Item[thurisaz] == true ) {
        rune_thurisaz = true;
        }
    if ( Link->Item[ansuz] == true ) {
        rune_ansuz = true;
        }
    if ( Link->Item[radio] == true ) {
        rune_radio = true;
        }
    if ( Link->Item[kaunan] == true ) {
        rune_kaunan = true;
        }
    if ( Link->Item[gebo] == true ) {
        rune_gebo = true;
        }
    if ( Link->Item[wunjo] == true ) {
        rune_wunjo = true;
        }
    if ( Link->Item[hagalaz] == true ) {
        rune_hagalaz = true;
        }
    if ( Link->Item[nuadiz] == true ) {
        rune_nuadiz = true;
        }
    if ( Link->Item[isaz] == true ) {
        rune_isaz = true;
        }
    if ( Link->Item[jera] == true ) {
        rune_jera = true;
        }    
    if ( Link->Item[eihwaz] == true ) {
        rune_eihwaz = true;
        }    
    if ( Link->Item[perth] == true ) {
        rune_perth = true;
        }  
    if ( Link->Item[algiz] == true ) {
        rune_algiz = true;
        }        
    if ( Link->Item[sowilo] == true ) {
        rune_sowilo = true;
        }    
    if ( Link->Item[teiwaz] == true ) {
        rune_teiwaz = true;
        }    
    if ( Link->Item[berkanan] == true ) {
        rune_berkanan = true;
        }    
    if ( Link->Item[ehwaz] == true ) {
        rune_ehwaz = true;
        }    
    if ( Link->Item[mannaz] == true ) {
        rune_mannaz = true;
        }     
    if ( Link->Item[laguz] == true ) {
        rune_laguz = true;
        }  
    if ( Link->Item[injwaz] == true ) {
        rune_injwaz = true;
        }       
    if ( Link->Item[othila] == true ) {
        rune_othila = true;
        } 
    if ( Link->Item[dagaz] == true ) {
        rune_dagaz = true;
        } 
    }

/////////////////
/// GOD NAMES ///
////////////////////////////////////////////////////////////////////////
/// This function sets up what RUNESTONES compose the names of gods  ///
/// that you desire to use in the game, for giving out inventory     ///
/// items to the player. Modify them as you wish, but be sure to set ///
/// up the letters for each from the runeStoneLetters(); function.   ///
////////////////////////////////////////////////////////////////////////


void godNames(){
    if ( rune_thurisaz == true
        && rune_othila == true
        && rune_radio == true )
        {
        thor = true;
        }
        if ( rune_othila == true
        && rune_dagaz == true
        && rune_isaz == true
        && rune_nuadiz == true )
        {
        odin = true;
        }
    if ( rune_fehu == true
        && rune_radio == true
        && rune_ehwaz == true
        && rune_algiz == true )
        {
        freyr = true;
        }
    if ( rune_wunjo == true
        && rune_othila == true
        && rune_laguz == true
        && rune_uruz == true
        && rune_nuadiz == true
        && rune_dagaz == true )
        {
        volund = true;
        }
    if ( rune_berkanan == true
        && rune_radio == true
        && rune_ansuz == true
        && rune_gebo == true
        && rune_isaz == true )
        {
        bragi = true;
        }
    if ( rune_hagalaz == true
        && rune_isaz == true
        && rune_laguz == true
        && rune_nuadiz == true)
        {
        hilin = true;
        } 
    if ( rune_injwaz == true
        && rune_othila == true
        && rune_radio == true
        && rune_dagaz == true )
        {
        njord = true;
        }
    if ( rune_teiwaz == true
        && rune_algiz == true
        && rune_radio == true )
        {
        tyr = true;
        }
    if ( rune_ehwaz == true
        && rune_algiz == true
        && rune_radio == true )
        {
        eyr = true;
        }
    if ( rune_algiz == true
        && rune_gebo == true
        && rune_dagaz == true
        && rune_radio == true
        && rune_ansuz == true
        && rune_sowilo == true
        && rune_isaz == true
        && rune_laguz == true )
        {
        yggdrasil = true;
        }
    if ( rune_mannaz == true
        && rune_ansuz == true
        && rune_nuadiz == true
        && rune_isaz == true )
        {
        mani = true;
        }
    if ( rune_gebo == true
        && rune_ehwaz == true
        && rune_fehu == true
        && rune_isaz == true
        && rune_othila == true
        && rune_nuadiz == true )
        {
        gefion = true;
        }
    if ( rune_fehu == true
        && rune_radio == true
        && rune_ehwaz == true
        && rune_algiz == true
        && rune_jera == true
        && rune_ansuz == true )
        {
        freyja = true;
        }
    if ( rune_gebo == true
        && rune_uruz == true
        && rune_laguz == true
        && rune_wunjo == true
        && rune_ehwaz == true
        && rune_isaz == true )
        {
        gullveig = true;
        }
    if ( rune_wunjo == true
        && rune_othila == true
        && rune_radio == true )
        {
        vor = true;
        }
    if ( rune_hagalaz == true
        && rune_ehwaz == true
        && rune_isaz == true
        && rune_mannaz == true
        && rune_dagaz == true
        && rune_ansuz == true
        && rune_laguz == true )
        {
        heimdall = true;
        }
    if ( rune_isaz == true
        && rune_dagaz == true
        && rune_uruz == true
        && rune_nuadiz == true
        && rune_ansuz == true )
        {
        iduna = true;
        }
    if ( rune_ehwaz == true
        && rune_laguz == true
        && rune_isaz == true )
        {
        elli = true;
        }
    if ( rune_nuadiz == true
        && rune_jera == true
        && rune_othila == true
        && rune_radio == true
        && rune_dagaz == true )
        {
        njord = true;
        }
    if ( rune_sowilo == true
        && rune_othila == true
        && rune_laguz == true )
        {
        sol = true;
        }
    if ( rune_eihwaz == true
        && rune_gebo == true
        && rune_isaz == true
        && rune_radio == true )
        {
        aegir = true;
        }
    if ( rune_hagalaz == true
        && rune_ehwaz == true
        && rune_radio == true
        && rune_mannaz == true
        && rune_othila == true
        && rune_dagaz == true )
        {
        hermod = true;
        }
    }

/////////////////////////
/// ITEMS OF THE GODS ///
////////////////////////////////////////////////////////////////////////
/// This function sets up the items to give to the player, when the  ///
/// player collects RUNESTONES with 'letters' corresponding to make  ///
/// the name of any god. Letters are shared, so the 'thurisaz' (TH)  ///
/// rune will be used in any god name that uses that RUNE.           ///
////////////////////////////////////////////////////////////////////////


void itemsOftheGods(){
    if ( volund == true && Link->Item[VolundSword] == false ) { //Master Smith of the Gods
       Link->Item[VolundSword] = true;
    }
    if ( volund == true && Link->Item[I_DINSFIRE] == false ) { //Master Smith of the Gods
       Link->Item[I_DINSFIRE] = true;
    }
    if ( thor == true && Link->Item[I_HAMMER] == false ) { //God of thunder, and warfare.
        //Link->Item[bolt] == true;
        Link->Item[I_HAMMER] = true;
    }
    if ( odin == true && Link->Item[I_LENS] == false ) { //Father god, the all-seeing.
        Link->Item[I_LENS] = true;
    }
    if ( freyr == true && Link->Item[I_NAYRUSLOVE] == false ) {  //Mother Goddess
        Link->Item[I_NAYRUSLOVE] = true; //Set as nayru's Love
    }
    if ( bragi == true && Link->Item[I_WHISTLE] == false ) {  //God of music.
        Link->Item[I_WHISTLE] = true;
    }
    if ( hilin == true && Link->Item[I_NAYRUSLOVE] == false ) { //Goddess of Protection
        Link->Item[I_NAYRUSLOVE] = true;
    }
    if ( njord == true && Link->Item[I_WEALTHMEDAL3] == false ) {  //God of wealth.
        Link->Item[I_WEALTHMEDAL3] = true;
    }
    if ( tyr == true && Link->Item[I_Tyr] == false ) { //God of war and skies.
        Link->Item[I_Tyr] = true;
    }   
    if ( eyr == true && Link->Item[I_HEARTRING2] == false ) { //Lesser goddess of life.
        Link->Item[I_HEARTRING2] = true;
    }
    if ( yggdrasil == true && Link->Item[I_HEARTRING2] == false ) { //Goddes of Life, and The tree of Life
        Link->Item[I_HEARTRING2] = true;
    }
    if ( mani == true && Link->Item[I_AMULET1] == false ) { //God of the moon.
        Link->Item[I_AMULET1] = true;
    }
    if ( gefion == true && Link->Item[I_WHISPRING2] == false ) { //God of prosperity, and luck.
        Link->Item[I_WHISPRING2] = true;
    }
    if ( freyja == true && Link->Item[I_WAND] == false ) {  //Goddess of magic
        Link->Item[I_WAND] = true;
    }
    if ( gullveig == true && Link->Item[I_MAGICRING2] == false ) { //God of sorcery
        Link->Item[I_MAGICRING2] = true;
    }
    if ( vor == true && Link->Item[I_FARORESWIND] == false ) { //God of wisdom and lore.
        //Link->Item[I_WAND] = true;
        //Link->Item[I_BOOK] = true;
        Link->Item[I_FARORESWIND] = true;
    }
    if ( heimdall == true && Link->Item[I_BOOK] == false ) { //God of lore, and education.
        Link->Item[I_BOOK] = true;
        //Link->Item[I_STONEAGONY] = true;
    }
    if ( iduna == true && Link->Item[I_HEARTRING3] == false ) { //Goddess of long life and eternal youth.
        Link->Item[I_HEARTRING3] = true;
    }
    if ( elli == true && Link->Item[I_BRACELET3] == false ) { //God of strength, who westled Odin.
        Link->Item[I_BRACELET3] = true;
    }
    if ( njord == true && Link->Item[I_BOW2] == false ) { //God of forests. 
        Link->Item[I_BOW2] = true;
    }
    if ( sol == true && Link->Item[I_CANDLE2] == false ) {
        Link->Item[I_CANDLE2] = true;
    }
    if ( aegir == true && Link->Item[I_FLIPPERS] == false ) { //God of the sea.
        Link->Item[I_FLIPPERS] = true;
    }
    if ( hermod == true && Link->Item[I_BOOTS] == false ) { //Messenger of the Gods.
        Link->Item[I_BOOTS] = true;
    }
}

///////////////////////////
/// GIVE REAL RUNESTONE ///
////////////////////////////////////////////////////////////////////////
/// Attach this item script to the TRIFORCE PIECE ITEM CLASS items   ///
/// that match the real RUNESTONE items. This creates the Triforce   ///
/// fanfare, and other effects, including refilling health & maigic, ///
/// playing the Triforce music, and exiting the level.               ///
/// ---------------------------------------------------------------- ///
/// Using this is optional, if you wish to use these effects when    ///
/// the player collects a RUNESTONE.                                 ///
////////////////////////////////////////////////////////////////////////
        
item script fakeRuneStoneGiveReal {
    void run(int runestone) {
        item givenitem = Screen->CreateItem(runestone);
            givenitem->X = Link->X;
            givenitem->Y = Link->Y;
            givenitem->Z = Link->Z;
    }
}

ffc script rec_MovingPlatform
    // You can pair this with any walkable FFC you want, and it will act as a platform that
    // moves Link with it while he's standing on it, rather than the silly method of having
    // to walk in time with it. :D Should work with any speeds in any directions, even diagonal!
    // The D arguments aren't even needed. ^_^
{
    void run()
    {
        int StoredX;    // these variables hold the X,Y coordinates of the FFC one frame ago
        int StoredY;    //

        while(true)
        {
            // compare the X,Y coordinates of the FFC with Link's at the START of its movement
            if(RectCollision(CenterLinkX(), (CenterLinkY() + 4), CenterLinkX(), (CenterLinkY() + 4), Floor(this->X), Floor(this->Y), (Floor(this->X) + this->EffectWidth), (Floor(this->Y) + this->EffectHeight)))
            {
                // if Link is standing on it, adjust his X,Y coordinates the same amount
                // as this FFC moved from the last frame to the next
                Link->X += (this->X - StoredX);
                Link->Y += (this->Y - StoredY);
            }
            // store the X,Y coordinates of the FFC at the END of its movement frame
            StoredX = Floor(this->X);
            StoredY = Floor(this->Y);

            Waitframe();    // we don't want to forget this! XD
        }
    }
}