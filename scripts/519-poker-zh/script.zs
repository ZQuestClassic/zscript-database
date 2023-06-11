// const int POKER_ZH_DEBUG = 0;

//poker.zh
//A library for detecting poker combinations in number arrays
//Maximum array size to work with in 40 ints. It`s not recommended to call function from this library every frame for sake of perfomance.

//Searches array for sets of the same king=d and reports result into two buffer array
// arr -> Array to search
// Bufferset -> kinds of found sets, in order of iteration i. e. set of 2s, then set of 3s, then set of 4s.
// Buffernum -> sizes of found sets, in order of iteration i. e. pair, then quad, then triplet
// For example inputing {2,4,4,2,2,4,2,3,3} will load {2,4,3} into buffernum and {4,3,2} into bufferset, as there are 4 2`s, 3 4`s and 2 3`s in input array.
void LoadNumBestN_of_a_Kind(int arr, int bufferset, int buffernum){
	int set[40];
	int num[40];
	for(int i=0;i<40;i++){
		set[i]=0;
		num[i]=0;
	}
	int c = -1;
	int seq=0;
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i]<=0)break;
		c = ArrayMatch(set, arr[i]);
		if (c<0){
			set[seq]=arr[i];
			num[seq]=1;
			seq++;
		}
		else{
			num[c]++;
		}
	}
	for (int i=0; i<SizeOfArray(bufferset); i++){
		bufferset[i]=set[i];
		// if (num[i]>0&& POKER_ZH_DEBUG>0)Trace(set[i]);
	}
	// if ( POKER_ZH_DEBUG>0)TraceNL();
	for (int i=0; i<SizeOfArray(bufferset); i++){
		buffernum[i]=num[i];
		// if (num[i]>0 && POKER_ZH_DEBUG>0)Trace(num[i]);
	}
	// if ( POKER_ZH_DEBUG>0)TraceNL();
}


//Returns number of sets in given array that are between minimum and maximum sizes, if limits are specified (>0) For instance, array {4,4,4,6,6} with maxnum =2 will return only 1, despite it being full house and it contains two pairs, if one of 4s is gone. 
int GetNumSets(int arr, int minnum, int maxnum){
	int set[40];
	int num[40];
	for(int i=0;i<40;i++){
		set[i]=0;
		num[i]=0;
	}
	int sets = 0;
	LoadNumBestN_of_a_Kind(arr, set, num);
	for (int i=0;i<40;i++){
		if (minnum>0){
			if (num[i]<minnum)continue;
		}		
		if (maxnum>0){
			if (num[i]>maxnum)continue;
		}
		sets++;
	}
	return sets;
}

//Returns number of longest stright sequence in array. For instance, {1,4,5,2,4,3} will return 5, as you can find 5 consecutive numbers in input array.
int GetBestSequence(int arr){
	int topseq=0;
	int seq=0;
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i]<=0)continue;
		seq=0;
		while(ArrayMatch(arr, i+seq)>=0) seq++;
		if (seq>topseq)topseq=seq;
		if (topseq==SizeOfArray(arr)) break;
	}
	// debugValue(1, topseq);
	return topseq;
}

//Returns index of the given element that exists in the given array or -1, if it does not exist.
int ArrayMatch(int arr, int value){
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i] == value) return i;
	}
	return -1;
}
//Returns true, if longest set of same kind in the given array is at least "numtarget" long, or exactly long, if "exact" is true. "allowothersets", if set to true, causes function to return false, if there are other sets in input array, besides the target set. "Color" restricts target set to be specific number, i,e 3 6s
bool IsNoaKind(int arr, int numtarget, bool exact, bool allowothersets, int color){
	int set[40];
	int num[40];
	for(int i=0;i<40;i++){
		set[i]=0;
		num[i]=0;
	}
	LoadNumBestN_of_a_Kind(arr, set, num);
	int numbest=0;
	for (int i=0;i<40;i++){
		if (color>0 && set[i]!=color) continue;
		if (num[i]>numbest){
			numbest=num[i];
		}
	}
	if (!exact){
		if (numbest<numtarget) return false;
	}
	else{
		if (numbest!=numtarget) return false;
	}
	// Trace(numbest);
	exact=false;
	if (!allowothersets){
		for (int i=0;i<40;i++){
			if (num[i]==numbest){
				if (!exact){
					exact=true;
					continue;
				}
				else return false;
			}
			else if (num[i]>1)  return false;
		}
	}
	return true;
}	

//Returns true, if all alements of array are a part of sets that are within minimum and maximum limits, if set(>0). If "exact" boolean is set to true, the array must in addition contain set of specific limit, i. e. if max set size is set to 4 and min is set to 3, the array must contain at least 1 triplet and 1 quad. If that array does not have target sets of specific size, or contains set that exceeds specified limit, i,e 5 of a kind, the function will return false.
bool IsMultiFullHouse(int arr, int maxset, int minset, bool exact){
	int set[40];
	int num[40];
	for(int i=0;i<40;i++){
		set[i]=0;
		num[i]=0;
	}
	bool min = false;
	bool max = false;
	LoadNumBestN_of_a_Kind(arr, set, num);
	for (int i=0;i<40;i++){
		if (num[i]==1)return false;
		if (maxset>0){
			if (exact){
				if (num[i]==maxset){
					max=true;
				}
			}
			else max=true;
			if (num[i]>maxset){
				return false;
			}
		}
		else max= true;
		
		if (minset>0){
			if (exact){
				if (num[i]==minset){
					min=true;
				}
			}
			else min=true;
			if (num[i]<minset && num[i]>1){
				return false;
			}
		}
		else min=true;
	}
	if (!min || !max){
		// Trace(Cond( max,1,0));
		// Trace(Cond(min,1,0));
		// TraceNL();
		return false;
	}
	return true;
}