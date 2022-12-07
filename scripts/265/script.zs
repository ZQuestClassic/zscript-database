// Shutter by eternaljwh, modified by Zaidyer
ffc script simple_shutter
{
void run(int dir, int openable, int layer, int comboflag)
//direction = 0-3 for closing to UDLR
//openable = 2 for if it will open when secrets are triggered
// = 1 for if it opens when no enemies are around
// = 0 if it never will
//layer are where a secret combo will be
//comboflag is what the flag it will watch for
// door opens when this flag is nowhere on the layer
{while (LinkCollision(this))
{NoAction();
Link->X += 2*Sign(InFrontX(dir,0));
Link->Y += 2*Sign(InFrontY(dir,0));
Waitframe();
}
this->Data--; //changes combo one more closed
Waitframes(5);
this->Data--; //again, now fully closed
//SFX here if desired (move to earlier in closing time also):
Game->PlaySound(SFX_SHUTTER);

Waitframe();
bool closed = true;
while (closed)
{
Waitframe();
if (LinkCollision(this))
if (dir & 2) //left/right
Link->X = this->X + InFrontX(dir,0);
else //up/down
Link->Y = this->Y + InFrontY(dir,0);
if (openable == 1)
closed = (Screen->NumNPCs() > 0);
//Counts "guys" so be aware...
else if (openable == 2)
closed = (LastComboFlagOf(comboflag, layer) != -1);
}
//SFX here if desired (move to earlier in opening time also if desired):
Waitframes(10);
Game->PlaySound(SFX_SHUTTER);
this->Data++; //half-open
Waitframes(10);
this->Data++; //open

Quit();
}
}