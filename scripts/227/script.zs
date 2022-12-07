////////////////////////////////////////////////////////////////
// Overhead
// by grayswandir
////////////////////////////////////////////////////////////////
// Makes certain overhead layers transparent/invisible while link is
// underneath them.
////////////////////////////////////////////////////////////////
// Setup:
// Put Overhead_Update() in your active loop.
// Mess with the Configuration section if you want.
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
// Configuration

// Set to 1 to make the tiles disappear completely, instead of being drawn
// transparently.
const int OVERHEAD_INVISIBLE = 0;

// These are the layers that are used. Set to 1 to enable, and 0 to disable.
const int OVERHEAD_USE_L3 = 0;
const int OVERHEAD_USE_L4 = 0;
const int OVERHEAD_USE_L5 = 1;
const int OVERHEAD_USE_L6 = 1;

// Change this to 16 if you have very fast scrolling turned on.
const int OVERHEAD_SCROLL_SPEED = 4;

////////////////////////////////////////////////////////////////
// Code

int Overhead_Data[1416];
const int OVERHEAD_STATE = 0;
const int OVERHEAD_LAST_SCREEN = 1;
const int OVERHEAD_SCROLL_DIR = 2;
const int OVERHEAD_TIMER = 3;
const int OVERHEAD_SCREENS = 4;
const int OVERHEAD_COMBOS = 8;
const int OVERHEAD_CSETS = 712;

const int OVERHEAD_STATE_UNINIT = 0;
const int OVERHEAD_STATE_SCROLLING = 1;
const int OVERHEAD_STATE_WORKING = 2;

void Overhead_Update() {
  int map; int screen; int location; int layer; bool under; int offset;

  // If this is the first time this function has been called, do some setup.
  if (OVERHEAD_STATE_UNINIT == Overhead_Data[OVERHEAD_STATE]) {
    Overhead_Data[OVERHEAD_STATE] = OVERHEAD_STATE_SCROLLING;
    Overhead_Data[OVERHEAD_LAST_SCREEN] = -1;
    for (layer = 3; layer <= 6; ++layer) {
      Overhead_Data[OVERHEAD_SCREENS + layer - 3] = -1;
    }
  }

  // If we've left our current screen, reset the layers we killed.
  screen = (Game->GetCurMap() << 8) + Game->GetCurScreen();
  if (screen != Overhead_Data[OVERHEAD_LAST_SCREEN]) {
    for (layer = 3; layer <= 6; ++layer) {
      // Skip if this layer wasn't recorded.
      if (-1 == Overhead_Data[OVERHEAD_SCREENS + layer - 3]) {continue;}

      // Replace the lost data.
      map = Overhead_Data[OVERHEAD_SCREENS + layer - 3] >> 8;
      screen = Overhead_Data[OVERHEAD_SCREENS + layer - 3] % 256;
      offset = 176 * (layer - 3);
      for (location = 0; location < 176; ++location) {
        Game->SetComboData(map, screen, location, Overhead_Data[OVERHEAD_COMBOS + offset + location]);
      }
    }

    // Remember what screen we're on, so we can tell if we've moved.
    Overhead_Data[OVERHEAD_LAST_SCREEN] = (Game->GetCurMap() << 8) + Game->GetCurScreen();
    Overhead_Data[OVERHEAD_STATE] = OVERHEAD_STATE_SCROLLING;

    // If we've just started scrolling, figure out what direction it's in so
    // we can draw the deleted combos properly. Also reset the timer.
    if (LA_SCROLLING == Link->Action) {
      if (-16 == Link->X) {Overhead_Data[OVERHEAD_SCROLL_DIR] = DIR_RIGHT;}
      if (256 == Link->X) {Overhead_Data[OVERHEAD_SCROLL_DIR] = DIR_LEFT;}
      if (-16 == Link->Y) {Overhead_Data[OVERHEAD_SCROLL_DIR] = DIR_DOWN;}
      if (176 == Link->Y) {Overhead_Data[OVERHEAD_SCROLL_DIR] = DIR_UP;}
      Overhead_Data[OVERHEAD_TIMER] = 0;
    }
  }

  // If we've finished scrolling, copy over the layers and delete them.
  if (LA_SCROLLING != Link->Action && OVERHEAD_STATE_SCROLLING == Overhead_Data[OVERHEAD_STATE]) {
    for (layer = 3; layer <= 6; ++layer) {
      // Skip this layer if we're not configured to use it.
      if (3 == layer && !OVERHEAD_USE_L3) {continue;}
      if (4 == layer && !OVERHEAD_USE_L4) {continue;}
      if (5 == layer && !OVERHEAD_USE_L5) {continue;}
      if (6 == layer && !OVERHEAD_USE_L6) {continue;}

      // If this screen doesn't use this layer, mark as not in use and skip.
      map = Screen->LayerMap(layer);
      screen = Screen->LayerScreen(layer);
      if (-1 == map || -1 == screen) {
        Overhead_Data[OVERHEAD_SCREENS + layer - 3] = -1;
        continue;
      }

      // Save this layer's screen location.
      Overhead_Data[OVERHEAD_SCREENS + layer - 3] = (map << 8) + screen;

      // Grab every combo and cset, and delete the original.
      offset = (layer - 3) * 176;
      for (location = 0; location < 176; ++location) {
        // Grab the data.
        Overhead_Data[OVERHEAD_COMBOS + offset + location] = Game->GetComboData(map, screen, location);
        Overhead_Data[OVERHEAD_CSETS + offset + location] = Game->GetComboCSet(map, screen, location);
        // Delete the original.
        Game->SetComboData(map, screen, location, 0);
      }
    }

    // Update the state so we know we've copied the data.
    Overhead_Data[OVERHEAD_STATE] = OVERHEAD_STATE_WORKING;
  }

  // See if link is standing under a combo in one of the specified layers.
  under = false;
  location = ComboAt(Link->X + 8, Link->Y + 8);
  for (layer = 3; layer <= 6; ++layer) {
    // Skip this layer if it's not in use.
    if (-1 == Overhead_Data[OVERHEAD_SCREENS + layer - 3]) {continue;}
    // Check for there being a non-0 combo at the specified position.
    if (Overhead_Data[OVERHEAD_COMBOS + (layer - 3) * 176 + location]) {
      under = true;
      break;
    }
  }

  // Offsets for scrolling.
  int x = 0;
  int y = 0;
  if (OVERHEAD_STATE_SCROLLING == Overhead_Data[OVERHEAD_STATE]) {
    if (DIR_LEFT == Overhead_Data[OVERHEAD_SCROLL_DIR]) {x = Overhead_Data[OVERHEAD_TIMER];}
    if (DIR_RIGHT == Overhead_Data[OVERHEAD_SCROLL_DIR]) {x = -Overhead_Data[OVERHEAD_TIMER];}
    if (DIR_UP == Overhead_Data[OVERHEAD_SCROLL_DIR]) {y = Overhead_Data[OVERHEAD_TIMER];}
    if (DIR_DOWN == Overhead_Data[OVERHEAD_SCROLL_DIR]) {y = -Overhead_Data[OVERHEAD_TIMER];}
    Overhead_Data[OVERHEAD_TIMER] += OVERHEAD_SCROLL_SPEED;
  }

  // Don't draw if we're under and have it set to be invisible then.
  if (under && OVERHEAD_INVISIBLE) {return;}

  // Draw the overhead layers.
  int opaque = Cond(under, OP_TRANS, OP_OPAQUE);
  for (layer = 3; layer <= 6; ++layer) {
    // Make sure the layer exists.
    if (-1 == Overhead_Data[OVERHEAD_SCREENS + layer - 3]) {continue;}

    // Draw the layer.
    offset = (layer - 3) * 176;
    for (location = 0; location < 176; ++location) {
      int combo = Overhead_Data[OVERHEAD_COMBOS + offset + location];
      if (combo) {
        Screen->FastCombo(layer, ComboX(location) + x, ComboY(location) + y,
                          combo, Overhead_Data[OVERHEAD_CSETS + offset + location],
                          opaque);
      }
    }
  }
}