// Necessary headers, uncomment (remove "//") if you haven't already imported these.
//import "std.zh"
//import "string.zh"
//import "ghost.zh"

const int COLOR_WIND = 0x01;
const int SUCK_STRENGTH = 1.3;
const int BLOW_STRENGTH = 1.3;

// ENEMY EDITOR MISC ATTRIBUTES
// Attr. 1: CSet for suck, -1 to disable suck
// Attr. 2: CSet for blow, -1 to disable blow
// Attr. 3: CSet for wind, -1 to disable wind
// Attr. 4: 1 to cycle through non-disabled attacks instead of randomizing
// Attr. 5: 1 to render enemy immobile
// Attr. 6: 1 to turn off collision detection (enemy is invincible and unable to damage player)
// Attr. 7: lower bound for random attack interval timer, defaults to 90 when Attributes 7 and 8 are both 0
// Attr. 8: upper bound for random attack interval timer, defaults to 150 when Attributes 7 and 8 are both 0
// Attr. 9: continuous attack mode, attack interval timers are ignored, no CSet flash warning, non-disabled attacks are continuously used (pair with immobile recommended)

ffc script SuckToBlow
{
	void run(int enemyID)
	{
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		int counter = -1;
		int cset_default = Ghost_CSet;
		int cset_index = -1;
		int cset1 = ghost->Attributes[0];
		int cset2 = ghost->Attributes[1];
		int cset3 = ghost->Attributes[2];
		int csets[3] = {cset1, cset2, cset3};
		int non_random = ghost->Attributes[3];
		int non_moving = ghost->Attributes[4];
		int no_collision = ghost->Attributes[5];
		int timer_attack_lower_bound = ghost->Attributes[6];
		int timer_attack_upper_bound = ghost->Attributes[7];
		int continuous = ghost->Attributes[8];
		int store_def[18];
		Ghost_StoreDefenses(ghost, store_def);
		int timer_attack = 120;
		int direct_shot;
		int wind_lines[48];
		float angle;
		float x_step;
		float y_step;
		float x_dir;
		float y_dir;
		if (non_moving)
		{
			ghost->DrawYOffset = 0;
			ghost->HitYOffset = 0;
		}
		if (no_collision)
		{
			ghost->CollDetection = false;
		}
		if (timer_attack_lower_bound == 0 && timer_attack_upper_bound == 0)
		{
			timer_attack_lower_bound = 90;
			timer_attack_upper_bound = 150;
		}
		
		while (true)
		{
			if (!non_moving)
			{
				counter = Ghost_ConstantWalk8(counter, ghost->Step, ghost->Rate, ghost->Homing, ghost->Hunger);
			}
			
			if (timer_attack <= 0)
			{
				cset_index = SuckToBlowRandomCSet(csets, cset_index, non_random);
				if (cset_index >= 0)
				{
					if (!continuous)
					{
						SuckToBlowFlashCSet(this, ghost, wind_lines, cset_default, csets[cset_index], 60);
					}
					else
					{
						Ghost_CSet = csets[cset_index];
					}
					if (cset_index == 0)
					{
						Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
						this->Misc[0] = -90;
						SuckToBlow_WindLinesRandomize(this, ghost, wind_lines, true);
						Game->PlaySound(48);
						while (this->Misc[0] < 0)
						{
							SuckToBlow_Waitframe(this, ghost, wind_lines);
						}
					}
					else if (cset_index == 1)
					{
						this->Misc[0] = 90;
						SuckToBlow_WindLinesRandomize(this, ghost, wind_lines, false);
						Game->PlaySound(49);
						while (this->Misc[0] > 0)
						{
							SuckToBlow_Waitframe(this, ghost, wind_lines);
						}
					}
					else
					{
						SuckToBlow_Waitframes(this, ghost, wind_lines, 10);
						direct_shot = Rand(10);
						for (int i = 0; i < 10; i++)
						{
							if (i == direct_shot)
							{
								angle = Angle(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), Link->X + 8, Link->Y + 8);
							}
							else
							{
								angle = Angle(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), Link->X + 8, Link->Y + 8);
								angle += Rand(-45, 45);
							}
							SuckToBlow_Wind(angle, Rand(200, 400));
							SuckToBlow_Waitframes(this, ghost, wind_lines, 6);
						}
					}
					if (!continuous)
					{
						SuckToBlowFlashCSet(this, ghost, wind_lines, csets[cset_index], cset_default, 30);
					}
					Ghost_SetDefenses(ghost, store_def);
				}
				if (!continuous)
				{
					timer_attack = Rand(timer_attack_lower_bound, timer_attack_upper_bound);
				}
				else
				{
					timer_attack = 0;
				}
			}
			
			if (timer_attack)
			{
				timer_attack--;
			}
			SuckToBlow_Waitframe(this, ghost, wind_lines);
		}
	}
}

int SuckToBlowRandomCSet(int csets, int cset_index, int non_random)
{
	int temp[3];
	int valid_csets;
	
	if (!non_random)
	{
		for (int i = 0; i < SizeOfArray(csets); i++)
		{
			if (csets[i] >= 0)
			{
				temp[valid_csets] = i;
				valid_csets++;
			}
		}
		if (valid_csets > 0)
		{
			return temp[Rand(valid_csets)];
		}
		else
		{
			return -1;
		}
	}
	else
	{
		for (int i = 0; i < SizeOfArray(csets); i++)
		{
			cset_index++;
			cset_index % SizeOfArray(csets);
			if (csets[cset_index] >= 0)
			{
				return cset_index;
			}
		}
		return -1;
	}
}

void SuckToBlowFlashCSet(ffc this, npc ghost, int wind_lines, int cset1, int cset2, int duration)
{
	for (int i = 0; i < duration; i++)
	{
		if (i % 2 == 0)
		{
			Ghost_CSet = cset1;
		}
		else
		{
			Ghost_CSet = cset2;
		}
		SuckToBlow_Waitframe(this, ghost, wind_lines);
	}
	Ghost_CSet = cset2;
}

void SuckToBlow_Wind(int angle, int step)
{
	eweapon wind = FireEWeapon(EW_SCRIPT1, Ghost_X, Ghost_Y, DegtoRad(angle), step, 0, 36, 59, EWF_NO_COLLISION);
	wind->Misc[0] = 23999;
	SetEWeaponLifespan(wind, EWL_SLOW_TO_HALT, step / 60);
	SetEWeaponDeathEffect(wind, EWD_VANISH, 0);
	wind->CollDetection = false;
}

void SuckToBlow_Waitframe(ffc this, npc ghost, int wind_lines)
{
	eweapon wind;

	for (int i = 1; i <= Screen->NumEWeapons(); i++)
	{
		wind = Screen->LoadEWeapon(i);
		if (wind->ID == EW_SCRIPT1 && wind->Misc[0] == 23999 && LinkCollisionMod(wind))
		{
			Link->Jump = 4;
			this->Misc[1] = 1;
			this->Misc[4] = RadtoDeg(wind->Angle);
		}
	}
	
	SuckToBlow_WindPush(this, ghost, wind_lines);
	Ghost_Waitframe(this, ghost);
}

void SuckToBlow_Waitframes(ffc this, npc ghost, int wind_lines, int num)
{
	for (int i = 0; i < num; i++)
	{
		SuckToBlow_Waitframe(this, ghost, wind_lines);
	}
}

void SuckToBlow_WindPush(ffc this, npc ghost, int wind_lines)
{
	int strength;
	float angle;
	float x_step;
	float y_step;
	float x = this->Misc[2];
	float y = this->Misc[3];
	float x_dir;
	float y_dir;
	bool suck;
	
	if (this->Misc[0] != 0 || this->Misc[1] > 0)
	{
		// SUCK
		if (this->Misc[0] < 0 && this->Misc[1] == 0)
		{
			angle = Angle(Link->X + 8, Link->Y + 8, Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight));
			suck = true;
			strength = SUCK_STRENGTH;
		}
		// BLOW
		else if (this->Misc[0] > 0 && this->Misc[1] == 0)
		{
			angle = Angle(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), Link->X + 8, Link->Y + 8);
			suck = false;
			strength = BLOW_STRENGTH;
		}
		else
		{
			angle = this->Misc[4];
			strength = BLOW_STRENGTH;
		}
		x_step = VectorX(strength, angle);
		y_step = VectorY(strength, angle);
		if (x_step > 0)
		{
			x_dir = DIR_RIGHT;
		}
		else
		{
			x_dir = DIR_LEFT;
		}
		if (y_step > 0)
		{
			y_dir = DIR_DOWN;
		}
		else
		{
			y_dir = DIR_UP;
		}
		if (CanWalk(Link->X, Link->Y, x_dir, x_step, false))
		{
			x += x_step;
			if (x >= 1 || x <= -1)
			{
				Link->X += x << 0;
				x -= x << 0;
			}
		}
		if (CanWalk(Link->X, Link->Y, y_dir, y_step, false))
		{
			y += y_step;
			if (y >= 1 || y <= -1)
			{
				Link->Y += y << 0;
				y -= y << 0;
			}
		}
		SuckToBlow_WindLines(this, ghost, wind_lines, suck);
	}
	
	if (this->Misc[0] > 0)
	{
		this->Misc[0]--;
	}
	if (this->Misc[0] < 0)
	{
		this->Misc[0]++;
	}
	if (this->Misc[1] > 0 && Link->Jump <= 0 && Link->Z == 0)
	{
		this->Misc[1] = 0;
	}
	this->Misc[2] = x;
	this->Misc[3] = y;
}

void SuckToBlow_WindLines(ffc this, npc ghost, int wind_lines, bool suck)
{
	int line_x1;
	int line_y1;
	int line_x2;
	int line_y2;
	int step = 4;
	float angle;
	float new_dist;
	float new_angle;
	
	if (this->Misc[1] == 0)
	{
		for (int i = 0; i < SizeOfArray(wind_lines) * 0.25; i++)
		{
			line_x1 = wind_lines[i];
			line_y1 = wind_lines[i + (SizeOfArray(wind_lines) * 0.25)];
			line_x2 = wind_lines[i + (SizeOfArray(wind_lines) * 0.5)];
			line_y2 = wind_lines[i + (SizeOfArray(wind_lines) * 0.75)];
			
			if (suck)
			{
				angle = Angle(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight));
				if (Distance(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)]) > 10)
				{
					line_x1 += VectorX(step, angle);
					line_y1 += VectorY(step, angle);
				}
				else if (Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) <= step)
				{
					new_dist = Rand(96, 112);
					new_angle = Rand(360);
					line_x1 = Ghost_X + VectorX(new_dist, new_angle);
					line_y1 = Ghost_Y + VectorY(new_dist, new_angle);
					line_x2 = line_x1;
					line_y2 = line_y1;
				}
				if (Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) >= 32 || (Distance(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)]) <= 10 && Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) > step))
				{
					line_x2 += VectorX(step, angle);
					line_y2 += VectorY(step, angle);
				}
			}
			else
			{
				angle = Angle(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)]);
				if (Distance(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)]) < 144)
				{
					line_x1 += VectorX(step, angle);
					line_y1 += VectorY(step, angle);
				}
				else if (Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) <= step)
				{
					new_dist = Rand(0, 64);
					new_angle = Rand(360);
					line_x1 = Ghost_X + VectorX(new_dist, new_angle);
					line_y1 = Ghost_Y + VectorY(new_dist, new_angle);
					line_x2 = line_x1;
					line_y2 = line_y1;
				}
				if (Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) >= 32 || (Distance(Ghost_X + (0.5 * 16 * ghost->TileWidth), Ghost_Y + (0.5 * 16 * ghost->TileHeight), wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)]) >= 144 && Distance(wind_lines[i], wind_lines[i + (SizeOfArray(wind_lines) * 0.25)], wind_lines[i + (SizeOfArray(wind_lines) * 0.5)], wind_lines[i + (SizeOfArray(wind_lines) * 0.75)]) > step))
				{
					line_x2 += VectorX(step, angle);
					line_y2 += VectorY(step, angle);
				}
			}
			Screen->Line(6, line_x1, line_y1, line_x2, line_y2, COLOR_WIND, 1, 0, 0, 0, OP_TRANS);
			wind_lines[i] = line_x1;
			wind_lines[i + (SizeOfArray(wind_lines) * 0.25)] = line_y1;
			wind_lines[i + (SizeOfArray(wind_lines) * 0.5)] = line_x2;
			wind_lines[i + (SizeOfArray(wind_lines) * 0.75)] = line_y2;
		}
	}
}

void SuckToBlow_WindLinesRandomize(ffc this, npc ghost, int wind_lines, bool suck)
{
	int new_dist;
	int new_angle;
	
	for (int i = 0; i < SizeOfArray(wind_lines) * 0.25; i++)
	{
		if (suck)
		{
			new_dist = Rand(96, 112);
		}
		else
		{
			new_dist = Rand(0, 64);
		}
		new_angle = Rand(360);
		wind_lines[i] = Ghost_X + VectorX(new_dist, new_angle);
		wind_lines[i + (SizeOfArray(wind_lines) * 0.25)] = Ghost_Y + VectorY(new_dist, new_angle);
		wind_lines[i + (SizeOfArray(wind_lines) * 0.5)] = Ghost_X + VectorX(new_dist, new_angle);
		wind_lines[i + (SizeOfArray(wind_lines) * 0.75)] = Ghost_Y + VectorY(new_dist, new_angle);
	}
}

bool LinkCollisionMod(eweapon b)
{
	int ax = Link->X + Link->HitXOffset;
	int bx = b->X + b->HitXOffset;
	int ay = Link->Y + Link->HitYOffset;
	int by = b->Y + b->HitYOffset;
	return RectCollision(ax+8, ay+8, ax+Link->HitWidth-8, ay+Link->HitHeight-8, bx, by, bx+b->HitWidth, by+b->HitHeight) && (Link->Z + Link->HitZHeight >= b->Z) && (Link->Z <= b->Z + b->HitZHeight);
}