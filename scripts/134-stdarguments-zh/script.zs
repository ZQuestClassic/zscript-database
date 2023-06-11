//////////////////////////////////
/// stdArguments.zh - v6.9.9/1 ///
//////////////////////////////////

int GetRemainderAsInt(int v)
{
    int r = (v - (v << 0)) * 10000;
    return r;
}


int GetDigit(int n, int place)
{
	place = Clamp(place, -4, 4);
	if(place < 0)
	{
		n = GetRemainderAsInt(n);
		place += 4;
	}

	int r = ((n / Pow(10, place)) % 10) << 0;
	return r;
}

int GetPartialArg(int arg, int place, int num){
	place = Clamp(place, -4, 4);
	int r;
	int adj = 1;
	for(int i = num-1; i > -1; i--){
		if(place - i < -4) continue;
		r += GetDigit(arg, place - i) * adj;
		adj *= 10;
	}
	return r;
}


		

///////////////////////////
// Get Nine-Digit Values //
///////////////////////////

int GetValueAsInt(int arg) {return arg - (arg >> 0) * 10000;}
 
 // Use this to utilise all nine places as an integer; thus, the value 12345.6789 becomes the value 123,456,789.
 
////////////////////////////
// Get Eight-Digit Values //
////////////////////////////

//Need to Redo Equations for this section, as this is broken.
 
int Get8High(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
   //This gets the 8 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (12345678). Use this if you do not need a value in excess of 32767999.
 // PLACE (#####.###x)
  
int Get8Low(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) );}
  //This gets the 8 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you need a value in excess of 32767999; max 99,999,999.
// PLACE (x####.####)
 

////////////////////////////
// Get Seven-Digit Values //
////////////////////////////
 
 //Need to Redo Equations for this section, as this is broken.
 

int Get7High(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) - ( GetDigit(arg, -3) * 10000 ) );}
 //This gets the 7 HIGHEST (ten-thousands, thousands, hundreds, ones, tenths, hundredths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (1234567). Use this if you do not need a value in excess of 3276799.
 // PLACE (#####.##xx)
 
int Get7Mid(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
 //This gets the 7 MIDDLE (thousands, hundreds, ones, tenths, hundredths, thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (1234567). Use this if you do not need a value in excess of 3276799.
 // PLACE (x####.###x)
  
  
int Get7Low(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, 3) * 10000 ) );}
 //This gets the 7 LOWEST (thousands, hundreds, ones, tenths, hundredths, ten-thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you need a value in excess of 3276799; max 9,999,999.
 // PLACE (xx###.####)



 
//////////////////////////
// Get Six-Digit Values //
//////////////////////////
 
int GetValue6High(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) - ( GetDigit(arg, -3) * 10000 ) - ( GetDigit(arg, -2) * 10000 ) );}
//This gets the 6 HIGHEST (ten-thousands, thousands, hundreds, tens, ones, tenths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you do not need a value in excess of 327679.
// PLACE (#####.#xxx)
  
int GetValue6Low(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, 3) * 10000 ) - ( GetDigit(arg, 2) * 10000 ) );}
//This gets the 6 LOWEST (tens, ones, tenths, hundredths, thousandths, ten-thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456789). Use this if you need a value in excess of 327679; max 999,999.
// PLACE (xxx##.####)

////////////////////////////////
// Get Six-Digit Alternatives //
////////////////////////////////

int GetValue6Mid876543(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, -3) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
///This gets the 6 MIDDLE (thousands, hundreds, tens, ones, tenths, hundredths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you do not need a value in excess of 327679.
// PLACE (x####.##xx)

int GetValue6Mid234567(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, -3) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
///This gets the 6 MIDDLE (thousands, hundreds, tens, ones, tenths, hundredths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you do not need a value in excess of 327679.
// PLACE (x####.##xx)

int GetValue6Mid765432(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, 3) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
//This gets the 6 MIDDLE (hundreds, tens, ones, tenths, hundredths, thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you do not need a value in excess of 327679.
// PLACE (xx###.###x)

int GetValue6Mid345678(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, 3) * 10000 ) - ( GetDigit(arg, -4) * 10000 ) );}
//This gets the 6 MIDDLE (hundreds, tens, ones, tenths, hundredths, thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123456). Use this if you do not need a value in excess of 327679.
// PLACE (xx###.###x)

int GetValue6Low654321(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 4) * 10000 ) - ( GetDigit(arg, 3) * 10000 ) - ( GetDigit(arg, 2) * 10000 ) );}
//This gets the 6 LOWEST (tens, ones, tenths, hundredths, thousandths, ten-thousandths) decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456789). Use this if you need a value in excess of 327679; max 999,999.
// PLACE (xxx##.####)

///////////////////////////
// Get Five-Digit Values //
///////////////////////////

int GetValue5High(int arg) {return arg >> 0;} 
//This gets the 5 HIGHEST decimal places (ten-thousands, thousands, hundreds, tens, ones) and turns it into an individual value. Thus, 12345.6789 becomes a value of (12345). Use this if you do not need a value in excess of 32767.
// PLACE (#####.xxxx)

int GetValue5Low(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) + (GetDigit(arg, -1) * 1000 ) + (GetDigit(arg, 0) * 10000 ) );}
//This gets the 5 LOWEST decimal places (ones, tenths, hundredths, thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (56789). Use this if you do need a value in excess of 32767; max 99,999.
// PLACE (xxxx#.####)

/////////////////////////////////
// Get Five-Digit Alternatives //
/////////////////////////////////

int GetValue5High98765(int arg) {return arg >> 0;} 
//This gets the 5 HIGHEST decimal places (ten-thousands, thousands, hundreds, tens, ones) and turns it into an individual value. Thus, 12345.6789 becomes a value of (12345). Use this if you do not need a value in excess of 32767.
// PLACE (#####.xxxx)

int GetValue5Mid87654(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) + (GetDigit(arg, 2) * 1000 ) + (GetDigit(arg, 3) * 10000 ) );}
//This gets the 5 MIDDLE (thousands, hundreds, tens, ones, tenths) decimal places and turns it into an individual value. 
// PLACE (x####.#xxx)

int GetValue5Mid23456(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) + (GetDigit(arg, 2) * 1000 ) + (GetDigit(arg, 3) * 10000 ) );}
//This gets the 5 MIDDLE (thousands, hundreds, tens, ones, tenths) decimal places and turns it into an individual value. 
// PLACE (x####.#xxx)

int GetValue5Mid76543(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) + (GetDigit(arg, 0) * 100 ) + (GetDigit(arg, 1) * 1000 ) + (GetDigit(arg, 2) * 10000 ) );}
//This gets the 5 MIDDLE (hundreds, tens, ones, tenths, hundredths) decimal places and turns it into an individual value. 
// PLACE (xx###.##xx)

int GetValue5Mid34567(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) + (GetDigit(arg, 0) * 100 ) + (GetDigit(arg, 1) * 1000 ) + (GetDigit(arg, 2) * 10000 ) );}
//This gets the 5 MIDDLE (hundreds, tens, ones, tenths, hundredths) decimal places and turns it into an individual value. 
// PLACE (xx###.##xx)

int GetValue5Mid65432(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100 ) + (GetDigit(arg, 0) * 1000 ) + (GetDigit(arg, 1) * 10000 ) );}
//This gets the 5 MIDDLE (tens, ones, tenths, hundredths, thousandths) decimal places and turns it into an individual value. 
// PLACE (xxx##.###x)

int GetValue5Mid45678(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100 ) + (GetDigit(arg, 0) * 1000 ) + (GetDigit(arg, 1) * 10000 ) );}
//This gets the 5 MIDDLE (tens, ones, tenths, hundredths, thousandths) decimal places and turns it into an individual value. 
// PLACE (xxx##.###x)

int GetValue5Low54321(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) + (GetDigit(arg, -1) * 1000 ) + (GetDigit(arg, 0) * 10000 ) );}
//This gets the 5 LOWEST decimal places (ones, tenths, hundredths, thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (56789). Use this if you do need a value in excess of 32767; max 99,999.
// PLACE (xxxx#.####)


///////////////////////////
// Get Four-Digit Values //
///////////////////////////

int GetValue4High(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) + (GetDigit(arg, 3) * 100) + (GetDigit(arg, 4) * 1000) );}
//This gets the 4 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (1234). Use this if you do not need a value in excess of 3275.
// PLACE (####x.xxxx)

int GetValue4Low(int arg) {return (arg - (arg >> 0)) * 10000;}
//This gets the 4 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (6789). Use this if you need a value in excess of 3275; max 9,999.
// PLACE (xxxxx.####)

/////////////////////////////////
// Get Four-Digit Alternatives //
/////////////////////////////////

int GetValue4High9876(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) + (GetDigit(arg, 3) * 100) + (GetDigit(arg, 4) * 1000) );}
//This gets the 4 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (1234). Use this if you do not need a value in excess of 3275.
// PLACE (####x.xxxx)

int GetValue4Mid8765(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100) + (GetDigit(arg, 3) * 1000) );}
// PLACE (x####.xxxx)

int GetValue4Mid6789(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100) + (GetDigit(arg, 3) * 1000) );}
// PLACE (x####.xxxx)

int GetValue4Mid7654(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100) + (GetDigit(arg, 2) * 1000) );}
// PLACE (xx###.#xxx)

int GetValue4Mid4567(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100) + (GetDigit(arg, 2) * 1000) );}
// PLACE (xx###.#xxx)

int GetValue4Mid6543(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100) + (GetDigit(arg, 3) * 1000) );}
// PLACE (xxx##.##xx)

int GetValue4Mid3456(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100) + (GetDigit(arg, 3) * 1000) );}
// PLACE (xxx##.##xx)

int GetValue4Mid5432(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100) + (GetDigit(arg, 0) * 1000) );}
// PLACE (xxxx#.###x)

int GetValue4Mid2345(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100) + (GetDigit(arg, 0) * 1000) );}
// PLACE (xxxx#.###x)

int GetValue4Low1234(int arg) {return (arg - (arg >> 0)) * 10000;}
//This gets the 4 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (6789). Use this if you need a value in excess of 3275; max 9,999.
// PLACE (xxxxx.####)

int GetValue4Low4321(int arg) {return (arg - (arg >> 0)) * 10000;}
//This gets the 4 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (6789). Use this if you need a value in excess of 3275; max 9,999.
// PLACE (xxxxx.####)

////////////////////////////
// Get Three-Digit Values //
////////////////////////////

int GetValue3High(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) + (GetDigit(arg, 4) * 100 ) );}
//This gets the 3 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123). Use this if you need a value in excess of 326.
// PLACE (###xx.xxxx)

int GetValue3Mid(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) );}
//This gets the 3 MIDDLE decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxx##.#xxx)

int GetValue3Low(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) );}
//This gets the 3 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (789); max 999.
// PLACE (xxxxx.x###)

//////////////////////////////////
// Get Three-Digit Alternatives //
//////////////////////////////////

int GetValue3Upper987(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) + (GetDigit(arg, 4) * 100 ) );}
//This gets the 3 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123). Use this if you need a value in excess of 326.
// PLACE (###xx.xxxx)

int GetValue3Upper123(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) + (GetDigit(arg, 4) * 100 ) );}
//This gets the 3 HIGHEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (123). Use this if you need a value in excess of 326.
// PLACE (###xx.xxxx)

int GetValue3Upper876(int arg){return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) + (GetDigit(arg, 3) * 100 ) );}
//This gets 3 MIDDLE decimal (thousands, hundreds, tens) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (x###x.xxxx)

int GetValue3Upper234(int arg){return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) + (GetDigit(arg, 3) * 100 ) );}
//This gets 3 MIDDLE decimal (thousands, hundreds, tens) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (x###x.xxxx)

int GetValue3Upper765(int arg){return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100 ) );}
//This gets 3 MIDDLE decimal (thousands, hundreds, tens) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xx###.xxxx)

int GetValue3Upper345(int arg){return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100 ) );}
//This gets 3 MIDDLE decimal (thousands, hundreds, tens) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xx###.xxxx)

int GetValue3Mid654(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) );}
//This gets the 3 MIDDLE decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxx##.#xxx)

int GetValue3Mid456(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) );}
//This gets the 3 MIDDLE decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxx##.#xxx)

int GetValue3Lower543(int arg){return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) + (GetDigit(arg, 0) * 100 ) );}
//This gets 3 MIDDLE decimal (tens, tenths, hundredths) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxxx#.##xx)

int GetValue3Lower567(int arg){return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) + (GetDigit(arg, 0) * 100 ) );}
//This gets 3 MIDDLE decimal (tens, tenths, hundredths) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxxx#.##xx)

int GetValue3Lower432(int arg){return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100 ) );}
//This gets 3 MIDDLE decimal (tenths, hundredths, thousandths) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxxxx.###x)

int GetValue3Lower678(int arg){return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) + (GetDigit(arg, -1) * 100 ) );}
//This gets 3 MIDDLE decimal (tenths, hundredths, thousandths) places and turns it into an individual value. Thus, 12345.6789 becomes a value of (456); max 999.
// PLACE (xxxxx.###x)

int GetValue3Lower321(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) );}
//This gets the 3 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (789); max 999.
// PLACE (xxxxx.x###)

int GetValue3Lower123(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) );}
//This gets the 3 LOWEST decimal places and turns it into an individual value. Thus, 12345.6789 becomes a value of (789); max 999.
// PLACE (xxxxx.x###)


//////////////////////////
// Get Two-Digit Values //
//////////////////////////

int GetValue2High(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (ten-thousands, thousands) and turns it into an individual value. Thus, 12345.6789 becomes a value of (12).
// PLACE (##xxx.xxxx)

int GetValue2Low(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (89).
// PLACE (xxxx.xx##)

////////////////////////////////
// Get Two-Digit Alternatives //
////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// The following GetValue commands *DO NOT* use the ten-thousands place. //
///////////////////////////////////////////////////////////////////////////

int GetValue278(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (thousands, hundreds) and turns it into an individual value. Thus, 12345.6789 becomes a value of (23).
// PLACE (x##xx.xxxx)

int GetValue223(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (thousands, hundreds) and turns it into an individual value. Thus, 12345.6789 becomes a value of (23).
// PLACE (x##xx.xxxx)

int GetValue287(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (thousands, hundreds) and turns it into an individual value. Thus, 12345.6789 becomes a value of (23).
// PLACE (x##xx.xxxx)

int GetValue265(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) );}
//This gets the decimal places (tens, ones) and turns it into an individual value. Thus, 12345.6789 becomes a value of (45).
// PLACE (xxx##.xxxx)

int GetValue245(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) );}
//This gets the decimal places (tens, ones) and turns it into an individual value. Thus, 12345.6789 becomes a value of (45).
// PLACE (xxx##.xxxx)

int GetValue243(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) );}
//This gets the decimal places (tenths, hundredths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (67).
// PLACE (xxxxx.##xx)

int GetValue267(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) );}
//This gets the decimal places (tenths, hundredths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (67).
// PLACE (xxxxx.##xx)

int GetValue221(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (89).
// PLACE (xxxx.xx##)

int GetValue212(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (89).
// PLACE (xxxx.xx##)

///////////////////////////////////////////////////////////////////////
// The following GetValue commands *DO* use the ten-thousands place. //
///////////////////////////////////////////////////////////////////////

int GetValue2_98(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (ten-thousands, thousands) and turns it into an individual value. Thus, 12345.6789 becomes a value of (12).
// PLACE (##xxx.xxxx)

int GetValue2_12(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
//This gets the decimal places (ten-thousands, thousands) and turns it into an individual value. Thus, 12345.6789 becomes a value of (12).
// PLACE (##xxx.xxxx)

int GetValue2_76(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) );}
//This gets the decimal places (hundreds, tens) and turns it into an individual value. Thus, 12345.6789 becomes a value of (34).
// PLACE (xx##x.xxxx)

int GetValue2_34(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) );}
//This gets the decimal places (hundreds, tens) and turns it into an individual value. Thus, 12345.6789 becomes a value of (34).
// PLACE (xx##x.xxxx)

int GetValue2_45(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) );}
//This gets the decimal places (tenths, hundredths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (56).
// PLACE (xxx##.xxxx)

int GetValue2_54(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) );}
//This gets the decimal places (tenths, hundredths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (56).
// PLACE (xxxx#.#xxx)

int GetValue2_56(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) );}
//This gets the decimal places (tenths, hundredths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (56).
// PLACE (xxxx#.#xxx)

int GetValue2_32(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (78).
// PLACE (xxxxx.x##x)

int GetValue2_23(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) + (GetDigit(arg, -2) * 10) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (78).
// PLACE (xxxxx.x##x)

//////////////////////////
// Get One-Digit Values //
//////////////////////////

// 		int switch0 = GetDigit(switches, 4);
//		int switch1 = GetDigit(switches, 3);
//		int switch2 = GetDigit(switches, 2);
//		int switch3 = GetDigit(switches, 1);
//		int switch4 = GetDigit(switches, 0);
//		int switch5 = GetDigit(switches, -1);
//		int switch6 = GetDigit(switches, -2);
//		int switch7 = GetDigit(switches, -3);
//		int switch8 = GetDigit(switches, -4);

//int GetValue2Low(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) );}
//This gets the decimal places (thousandths, ten-thousandths) and turns it into an individual value. Thus, 12345.6789 becomes a value of (89).
// PLACE (xxxx.xx##)

int GetValue1Highest(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 4) );}
//This gets the single valuee of the ten-thousands (#xxxx.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (1).
// PLACE (#xxxx.xxxx)

int GetValueSingle1(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 4) );}
//This gets the single valuee of the ten-thousands decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (1).
// PLACE (#xxxx.xxxx)

int GetValue9(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 4) );}
//This gets the single valuee of the ten-thousands decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (1).
// PLACE (#xxxx.xxxx)

int GetValueSingle2(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) );}
//This gets the single valuee of the thousands (x#xxx.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (2).
// PLACE (x#xxx.xxxx)

int GetValue8(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) );}
//This gets the single valuee of the thousands (x#xxx.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (2).
// PLACE (x#xxx.xxxx)

int GetValueSingle3(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) );}
//This gets the single valuee of the hundreds (xx#xx.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (3).
// PLACE (xx#xx.xxxx)

int GetValue7(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) );}
//This gets the single valuee of the hundreds (xx#xx.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (3).
// PLACE (xx#xx.xxxx)

int GetValueSingle4(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) );}
//This gets the single valuee of the tens (xxx#x.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (4).
// PLACE (xxx#x.xxxx)

int GetValue6(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) );}
//This gets the single valuee of the tens (xxx#x.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (4).
// PLACE (xxx#x.xxxx)

int GetValueSingle5(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) );}
//This gets the single valuee of the ones (xxxx#.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (5).
// PLACE (xxxx#.xxxx)

int GetValue5(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) );}
//This gets the single valuee of the ones (xxxx#.xxxx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (5).
// PLACE (xxxx#.xxxx)

int GetValueSingle6(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) );}
//This gets the single valuee of the tenths (xxxxx.x#xx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (6).
// PLACE (xxxxx.#xxx)

int GetValue4(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) );}
//This gets the single valuee of the tenths (xxxxx.x#xx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (6).
// PLACE (xxxxx.#xxx)

int GetValueSingle7(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) );}
//This gets the single valuee of the hundredths (xxxxx.x#xx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (7).
// PLACE (xxxxx.x#xx)

int GetValue3(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) );}
//This gets the single valuee of the hundredths (xxxxx.x#xx) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (7).
// PLACE (xxxxx.x#xx)

int GetValueSingle8(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) );}
//This gets the single valuee of the thousandths (xxxxx.xx#x) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (8).
// PLACE (xxxxx.xx#x)

int GetValue2(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -3) );}
//This gets the single valuee of the thousandths (xxxxx.xx#x) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (8).
// PLACE (xxxxx.xx#x)

int GetValueSingle9(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) );}
//This gets the single valuee of the ten-thousandths (xxxxx.xxx#) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (9).
// PLACE (xxxxx.xxx#)

int GetValue1(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) );}
//This gets the single valuee of the ten-thousandths (xxxxx.xxx#) decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (9).
// PLACE (xxxxx.xxx#)


int GetValueLowest(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) );}
//This gets the single valuee of the ten-thousandths decimal place and turns it into an individual value. Thus, 12345.6789 becomes a value of (9).
// PLACE (xxxxx.xxx#)

/////////////////////
// LEGACY COMMANDS //
/////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// These functions are essentially outmoded by the commands above, but are included for legacy support to anyone    //
// that has elected to use this header up to this point. You may wish to check your scripts to ensure that all the  //
// functions of your scripts still work, and update any that do not, as I have also corrected a couple bugs in the  //
// old functions that kept them from working exactly as intended.                                                   //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


int GetHighArgument(int arg) {return arg >> 0;}
int GetLowArgument(int arg) {return (arg - (arg >> 0)) * 10000;}

int GetFiveAndFourBig(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) + (GetDigit(arg, 2) * 100 ) + (GetDigit(arg, 3) * 1000 ) + (GetDigit(arg, 4) * 10000 ) );}
int GetFiveAndFourSmall(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100) + (GetDigit(arg, -1) * 1000) );}

int GetLowTriArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) );}
int GetMidTriArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) );}
int GetHighTriArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) + (GetDigit(arg, 4) * 100 ) );}
 
int GetFiveAndThreeBig(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -1) + (GetDigit(arg, 0) * 10) + (GetDigit(arg, 1) * 100 ) + (GetDigit(arg, 2) * 1000 ) + (GetDigit(arg, 3) * 10000 ) );}
int GetFiveAndThreeSmall(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100) );}
 
int GetFiveAndDuoTwoFive(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) + (GetDigit(arg, -1) * 1000 ) + (GetDigit(arg, 0) * 10000 ) );}
int GetFiveAndDuoTwoTwoLow(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 1) + (GetDigit(arg, 2) * 10) );}
int GetFiveAndDuoTwoTwoHigh(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}
 
int GetSixAndTwoBig(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) + (GetDigit(arg, -1) * 1000 ) + (GetDigit(arg, 0) * 10000 ) + (GetDigit(arg, 1) * 100000 ) );}
int GetSixAndTwoSmall(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) );}
 
int GetSixAndThreeBig(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) + (GetDigit(arg, -2) * 100 ) + (GetDigit(arg, -1) * 1000 ) + (GetDigit(arg, 0) * 10000 ) + (GetDigit(arg, 1) * 100000 ) );}
int GetSixAndThreeSmall(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) + (GetDigit(arg, 4) * 100) );}
 
int GetSevenAndOneBig(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 2) * 10000 ) - ( GetDigit(arg, 1) * 10000 ) );}
int GetSevenAndOneSmall(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) );}
 

//Need to Redo Equations for this.

   
int GetSevenAndOTwoLow(int arg) {return arg - ( ( (arg >> 0) * 10000 ) - ( GetDigit(arg, 1) * 10000 ) );}
int GetSevenAndTwoHigh(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 3) + (GetDigit(arg, 4) * 10) );}

int GetFirstDuoArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 2) + (GetDigit(arg, 3) * 10) );}
int GetSecondDuoArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, 0) + (GetDigit(arg, 1) * 10) );}
int GetThirdDuoArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -2) + (GetDigit(arg, -1) * 10) );}
int GetFourthDuoArgument(int arg) {return arg - (arg >> 0) + ( GetDigit(arg, -4) + (GetDigit(arg, -3) * 10) );}

	////////////////////    /////////////////
	// Example Values //    // Translation //
	////////////////////    /////////////////////////////////////
	// D0: 06400.0001 //    // D0: (064)(000)(001)             //
	// D1: 00040.0126 //    // D1: (000)(400)(126)             //
	// D2: 00008.9050 //    // D2: 0(00)(08)(90)(50)           //
	// D3: 00100.2200 //   	// D3: 0(01)(00)(22)(00)           //
	// D4:            //   	// D4:                             //
	// D5:            //   	// D5:                             //
	// D6:            //   	// D6:                             //
	// D7: 10000.0000 //    // D7: (1)(0)(0)(0)(0)(0)(0)(0)(0) //
	////////////////////    /////////////////////////////////////


 
//////////////////////////////
/// CREDITS (ALPHABETICAL) ///
//////////////////////////////

///////////////////////////
/// Programming Credits ///
///////////////////////////////////////////////////////////////////////
/// Aevin                                                           ///
/// Alucard (Testing, and function discussion).                     ///
/// blackbishop89                                                   ///
/// Gleeok (GetDigit, and other key, base functions.)               ///
/// grayswandir                                                     ///        
/// jsm116 (GetHighArgument/GetLowArgument base functions.)         ///
/// MasterManiac                                                    ///
/// MoscowModder (Too much to list; possible also UseRItem)         ///
/// Saffith (Function discussion)                                   ///
/// SUCCESSOR (GetpartialArg Funtions)                              ///
/// Zecora (Forum discussions, and assistance.)                     ///
/// ZoriaRPG (Functions, testing, and /Library Maintainer.)         ///
///////////////////////////////////////////////////////////////////////