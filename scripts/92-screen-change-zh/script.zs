// Last noticed DMap.
int LastDMap = -1;
// Last noticed DScreen.
int LastDScreen = -1;
// If the screen has changed.
bool ScreenChanged = false;
// If the dmap has changed.
bool DMapChanged = false;

void ScreenChange_Update() {
  int dMap = Game->GetCurDMap();
  int dScreen = Game->GetCurDMapScreen();
  DMapChanged = dMap != LastDMap;
  ScreenChanged = DMapChanged || dScreen != LastDScreen;
  LastDMap = dMap;
  LastDScreen = dScreen;}