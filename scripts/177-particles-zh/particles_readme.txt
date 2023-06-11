//A header used to create particle effects based on Lweapons

//

//Unlike Grayswandir`s animation.zh it has more features regarding controlling particle movement. Particles use DrawOffset variables to actually display particle at it`s position so it does not disappear on touching screen edges.

//

Setup:

1. Import header like any other headers.
2. Global script comboning: Put "UpdateAnimations();"
   between Waitdraw() and Waitframe() in your global script.

//Functions

// Creates a particle. Setting lifespan to -2 sets it to one full animation cycle.
"x" 'y" - Starting coordinates of the particle.
"sprite" - sprite used by particle.
"ax", "ay" - initial acceleration of the particle.
"vx", "vy" - initial velocity of the particle.
"lifespan" - Time, before particle disappears. Set to -2 for one full animation cycle.
"grav" - set to TRUE, and the particle will be affected by sideview gravity.

lweapon CreateAnimation (int x, int y, int sprite, int ax, int ay, int vx, int vy, int lifespan, bool grav)

//Andvanced version of animation creating. Use it if you are running out of sprite slots in Weapons/Misc animation data.
"x" 'y" - Starting coordinates of the particle.
"numframes" - number of frames in particle animation.
"aspeed" - delay between frame changing in particle animation, in frames.
"origtile" - ID of the first tile in particle animation.
"cset" - CSet used by particle animation.
"flashcset" - Flash CSet used by particle animation. Match to "cset" for no flashing.
"ax", "ay" - initial acceleration of the particle.
"vx", "vy" - initial velocity of the particle.
"lifespan" - Time, before particle disappears. Set to -2 for one full animation cycle.
"grav" - set to TRUE, and the particle will be affected by sideview gravity.

lweapon CreateAnimationAdvanced( int x, int y, int numframes, int aspeed, int origtile, 
int cset, int flashcset, int ax, int ay, int vx, int vy, int lifespan, bool grav)

//Set angular motion of particle. Angle is measured in degrees.
void SetAngularMovement(lweapon anim, int angle, int speed)

//Expands particle size. Values are measured in tiles.
void BigAnim (lweapon anim, int tilewidth, int tileheight)

//Main particle update function. Uses DrawOffset variables to actually display particle at it`s position so it does not disappear on touching screen edges.
void UpdateAnimations()