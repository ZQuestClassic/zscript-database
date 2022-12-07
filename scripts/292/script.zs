void HaveANotShittySubscreen()
{
    if(Link->PressR && Link->Action != LA_SCROLLING)
        Link->SelectBWeapon(DIR_RIGHT);
    if(Link->PressL && Link->Action != LA_SCROLLING)
        Link->SelectBWeapon(DIR_LEFT);
    if(Link->PressEx1 && Link->Action != LA_SCROLLING)
        Link->SelectAWeapon(DIR_RIGHT);
    if(Link->PressEx2 && Link->Action != LA_SCROLLING)
        Link->SelectAWeapon(DIR_LEFT);
}