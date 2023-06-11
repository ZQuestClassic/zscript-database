// This array keeps track of the types of items already obtained
// If the item is already obtained, the string won't play again
bool itemsObtained[100];

// Play an item message only once for a given type
// Or always if no type given
item script ItemMessage{
	void run(
		// the string ID
		int m,
		// the item type. If 0, then the message is always shown
		int type
	){
		if(
			// If no type was given, we always play the string
			type == 0
			// Or if you did not obtain this type of item before
			|| (type > 0 && !itemsObtained[type])) {
			// Ensure that the string is not shown again next time
			itemsObtained[type] = true;
			
			Screen->Message(m);
		}
	}	
}