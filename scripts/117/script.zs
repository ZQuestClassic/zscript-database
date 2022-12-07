const int I_BOOK_OF_DECRYPTING = 157; //Item, needed to decipher text on signboard.

//D0: String number for encrypted message.
//D1: String number for decrypted message.
//D2: 
// 0 - No secret triggering, when decrypting message.
// 1 - Trigger temporary secrets after decrypting message.
// 2+ - Trigger permanent secrets after decrypting message.
//D3: ID of item needed to decrypt text. Use this if you want to require different item for deciphering. Leave as 0 to use default book for decrypting.
ffc script EncryptedSignboard{
	void run(int encryptedstring, int decryptedstring, int secrets, int decryptor){
		if (decryptor == 0) decryptor = I_BOOK_OF_DECRYPTING;
		while(!(Screen->State[ST_SECRET])){ //Non-functional when secrets are already triggered.
			Waitframe(); //Placed here to prevent "continue" keywords from crashing ZC.
			if (!(FacingSign(this))) continue; //Link must be near sign.
			if (!(Link->InputR)) continue; 
			if (!(Link->Item[decryptor])) Screen->Message(encryptedstring); //Display abracadabra.
			else{ //Link pulls out Book of Mudora to decipher text!
				Screen->Message(decryptedstring);
				Waitframe(); //Needed to "Message freeze all action" quest rule to work.
				if (secrets>0){ //Ready to trigger secrets!
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					if (secrets > 1) Screen->State[ST_SECRET] = true;
				}
			}
		}
	}
}

//Returns TRUE, if Link faces "signboard" (given) FFC.
bool FacingSign(ffc f){
	int curx = Link->X;
	int cury = Link->Y;
	int npcx = f->X;
	int npcy = f->Y;
	int borderx = f->EffectWidth;
	int bordery = f->EffectHeight;
	if (IsSideview()){
		if (LinkCollision(f)) return true;
	}
	else{
		if (RectCollision(curx, cury, (curx+16), (cury+16), (npcx-4), npcy, npcx, (npcy+bordery))){
			if (Link->Dir == DIR_RIGHT) return true;
		}
		if (RectCollision(curx, cury, (curx+16), (cury+16), npcx, (npcy - 4), (npcx + borderx), npcy)){
			if (Link->Dir == DIR_DOWN) return true;
		}
		if (RectCollision(curx, cury, (curx+16), (cury+16), npcx, (npcy + bordery), (npcx+borderx), (npcy+bordery+4))){
			if (Link->Dir == DIR_UP) return true;
		}
		if (RectCollision(curx, cury, (curx+16), (cury+16), (npcx+borderx), npcy, (npcx+borderx+4), (npcy+bordery))){
			if (Link->Dir == DIR_LEFT) return true;
		}
	}
	return false;
}