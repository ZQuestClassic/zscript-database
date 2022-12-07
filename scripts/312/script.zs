ffc script FollowFFC
{
    void run()
    {
	
	
        while(true) // This will repeat indefinitely
        {
		
		    
			
            // Aim toward Link
            this->Vx = (Link->X - this->X) / Distance(Link->X, Link->Y, this->X, this->Y);
            this->Vy = (Link->Y - this->Y) / Distance(Link->X, Link->Y, this->X, this->Y);
			
			
            
            // Wait two seconds, then the loop will repeat
            Waitframes(120);
        }
    }
}