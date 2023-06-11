// The weapon id used for animations.
const int LW_ANIMATION = 31;

// The weapon->Misc index used to store the animation id.
const int ANIMATION_ID_INDEX = 0;

// The next animation id to use.
int animationNextId = 0;

// Get the unique id of an animation.
int AnimationGetId(lweapon animation) {
    return animation->Misc[ANIMATION_ID_INDEX];}

// Creates an animation. Once you create an animation, call
// AnimationGetId(animation) to get the unique id for that animation.
// With that id you can call AnimationGet(id) in subsequent frames to
// retrieve that specific animation.
// INPUT
// spriteId - The id number of the sprite to use for the animation.
// x, y - The location on the screen, in pixels, to display the animation.
// loop - If false, after the animation has completed one full cycle,
// it will remove itself.
// OUTPUT
// Returns the created animation.
lweapon AnimationCreate(int spriteId, int x, int y, bool loop) {
    // Make a new lweapon of type animation.
    lweapon animation = Screen->CreateLWeapon(LW_ANIMATION);
    // Set it to have the next animation id.
    animation->Misc[ANIMATION_ID_INDEX] = animationNextId;
    // Increment animationNextId so the next animation will have a different id.
    animationNextId++;
    // Make it use the provided sprite.
    animation->UseSprite(spriteId);
    // Turn off collision detection so it doesn't hit any enemies by accident.
    animation->CollDetection = false;
    // Set its drawing location. If we keep it at (0,0) and only move its draw
    // location, we don't have to worry about it falling off the edge of the
    // screen and dying.
    animation->DrawXOffset = x;
    animation->DrawYOffset = y;

    // If it's not stopping itself, then set the DeadState to -2.
    // We don't want to use -1, since that would make it update its
    // position, and we're solely using the drawing offsets to make it
    // move and keeping the actual weapon at (0,0).
    if (loop) {
        animation->DeadState = -2;}

    // Otherwise, use the DeadState as a timer to run through the sprite once.
    else {
        animation->DeadState = animation->NumFrames * animation->ASpeed;}

    return animation;}

// Create an one-time running animation at x, y.
// See the first AnimationCreate for the full description.
lweapon AnimationCreate(int spriteId, int x, int y) {
    return AnimationCreate(spriteId, x, y, false);}

// Create an animation at the given tile.
// See the first AnimationCreate for the full description.
lweapon AnimationCreate(int spriteId, int location, bool loop) {
    return AnimationCreate(spriteId, ComboX(location), ComboY(location), loop);}

// Create a one-time running animation at the given tile.
// See the first AnimationCreate for the full description.
lweapon AnimationCreate(int spriteId, int location) {
    return AnimationCreate(spriteId, ComboX(location), ComboY(location), false);}


// Return the animation with the given id. Since you can't store lweapons
// across frames, store the id instead and use this to get the animation
// you want.
lweapon AnimationGet(int animationId) {
    // Loop through every lweapon on the screen.
    for (int i = 1; i <= Screen->NumLWeapons(); i++) {
        lweapon lw = Screen->LoadLWeapon(i);
        // Make sure the weapon has the animation weapon type we defined.
        if (lw->ID == LW_ANIMATION) {
            // If we know it's an animation, test to see if it has the right id.
            int thisId = AnimationGetId(lw);
            if (animationId == thisId) {
                // We found the animation we want, so stop looping
                // and return it.
                return lw;}}}}

// If you want to use the built-in movement values of a weapon
// for an animation, set them and then call this function on
// that weapon every frame. This will move the draw offsets instead.
void AnimationUpdate(lweapon animation) {
    float step = animation->Step * 0.01;

    // Angular Movement
    if (animation->Angular) {
        animation->DrawXOffset += step * RadianCos(animation->Angle);
        animation->DrawYOffset += step * RadianSin(animation->Angle);}

    // Directional Movement
    else {
        animation->DrawXOffset += step * DirToXSpeed(animation->Dir);
        animation->DrawYOffset += step * DirToYSpeed(animation->Dir);}}

// Use this version of AnimationUpdate to update every animation.
void AnimationUpdate() {
    // Loop through every lweapon on the screen.
    for (int i = 1; i <= Screen->NumLWeapons(); i++) {
        lweapon lw = Screen->LoadLWeapon(i);
        // If lw is an animation, update it.
        if (lw->ID == LW_ANIMATION) {
            AnimationUpdate(lw);}}}

// Destroys an animation.
void AnimationDestroy(lweapon animation) {
    animation->DeadState = WDS_DEAD;}

// Destroys all animations.
void AnimationDestroy() {
    // Loop through every lweapon on the screen.
    for (int i = 1; i <= Screen->NumLWeapons(); i++) {
        lweapon lw = Screen->LoadLWeapon(i);
        // If lw is an animation, destroy it.
        if (lw->ID == LW_ANIMATION) {
            AnimationDestroy(lw);}}}