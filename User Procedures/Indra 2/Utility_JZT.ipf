#pragma rtGlobals=2		// Use modern global access method.#pragma IgorVersion = 5.05#pragma version = 2.4Menu "Graph"		"Append Multiple Graphs to a Layout",AppendGraph2LayoutN(NaN,"","")EndMenu "Layout"		"Append Multiple Graphs to a Layout",AppendGraph2LayoutN(NaN,"","")End// Puts text on the lower right corner showing when the layout was made, and on the lower left showing where it came fromProc Layout_Corner_Labels_Style_()		// This is needed to make it show up in the "Layout Macros" menu	Add_Corner_Labels_To_Layout()EndProc Add_Corner_Labels_To_Layout() : LayoutStyle	PauseUpdate; Silent 1		// modifying window...	Textbox/C/N=stamp0/F=0/A=RB/X=0.1/Y=0.1 "\\Z06\\{\"%s %s\",date(), time()}"	Textbox/C/N=stamp1/F=0/A=LB/X=0.1/Y=0.1 "\\Z06\\{\"%s\",CornerStamp1_()}"+":"+WinName(0, 1)EndMacroFunction/S CornerStamp1_()	PathInfo home			// creates String s_path	return S_path+IgorInfo(1)End// Puts text on the lower right corner showing when the graph was made, and on the lower left showing where it came fromProc Add_Corner_Labels_To_Graph() : GraphStyle	AddCornerLabelsToGraph()EndMacroFunction AddCornerLabelsToGraph()	GetWindow kwTopWin , psize	Variable pBottom=V_bottom	Variable pheight = V_bottom-V_top	GetWindow kwTopWin , gsize	Variable gBottom=V_bottom	Variable bottom = -floor(100*(gBottom-pBottom)/pheight)	Textbox/C/N=stamp0/F=0/A=RB/X=0.2/Y=(bottom)/E=2 "\\Z04\\{\"%s %s\",date(), time()}"	Textbox/C/N=stamp1/F=0/A=LB/X=0.2/Y=(bottom)/E=2 "\\Z04\\{\"%s\",CornerStamp1_()}"+":"+WinName(0, 1)End// Put up multigraph layouts.  Each time you call this, it adds another graph to the layoutWindow AppendMultiGraph2LayoutN() : Layout			// this is needed to make it appear in the "Layout Macros" menu	AppendGraph2LayoutN(NaN,"","")End// Append a graph to a multiple graph layout.  This is for making multi-graph layoutsFunction/S AppendGraph2LayoutN(Nmax,orientation,gName)	Variable Nmax									// requested maximum number of graphs in the layout, one of Nlist	String orientation								// this must be "portrait" or "landscape"	String gName									// name of graph to append, if empty string, DoPrompt	String Nlist = "1;2;3;4;6;8;9;12;16;20"		// list of allowed values for Nmax	if (!stringmatch("portrait",orientation) && !stringmatch("landscape",orientation))		orientation = ""	endif	if (Nmax<1 || Nmax>99 || numtype(Nmax))		Nmax = -1									// forces a prompt dialog	elseif (Nmax>16)		Nmax = 20	elseif (Nmax>12)		Nmax = 16	elseif (Nmax>9)		Nmax = 12	elseif (Nmax>6)		Nmax = 9	elseif (Nmax>4)		Nmax = 6	elseif (Nmax>3)		Nmax = 4	elseif (Nmax>2)		Nmax = 3	elseif (Nmax>1)		Nmax = 2	endif	Variable printIt=0	String lname	if (strlen(gName)<1 || Nmax<0)		if (Nmax<0)			lname = StringFromList(0,WinList("Layout*",";","WIN:4"))//			GetWindow $lname ,note					// window note in S_Value//			Nmax = NumberByKey("Nmax",S_Value,"=")			Nmax = NumberByKey("Nmax",GetUserData(lname,"","AppendGraph2Layout"),"=")			Nmax = numtype(Nmax) ? -1 : Nmax		endif		Nmax = Nmax<0 ? 12 : Nmax				// 12 is default for absurd inputs		Nmax = WhichListItem(num2istr(Nmax),Nlist)+1		Prompt gName, "Graph to add to layout",popup,WinList("*",";","WIN:1")		Prompt Nmax,"number of graphs/layout",popup,Nlist		DoPrompt "Pick a Graph",gName,Nmax		if (V_flag)			return ""		endif		Nmax = str2num(StringFromList(Nmax-1,Nlist))		printIt = 1	endif	if (strlen(gName)<1)		DoAlert 0, "no graph to add"		return ""	endif	lname = StringFromList(0,WinList("Layout"+num2istr(Nmax)+"_*",";","WIN:4"))		// get layout to append to	if (strlen(LayoutInfo(lname, gName ))>1)		return lname								// graph is on layout, all done	endif	// check if this layout is full	Variable i,N,NL = NumberByKey("NUMOBJECTS", LayoutInfo(lname,"Layout"))	for (i=0,N=0;i<NL;i+=1)						// check each object in the layout		N += stringmatch(StringByKey("TYPE",LayoutInfo("", num2istr(i))),"Graph")	// increlement if obj is graph	endfor	if (N>=Nmax)									// this layout is full, force creation of a new one		lname = ""	endif	if (strlen(lname)<1)		if (strlen(orientation)<1)					// orientation was not passed, ask now			orientation = SelectString(Nmax==8,"Landscape","Portrait")			Prompt orientation, "page orientation",popup,"Portrait;Landscape"			DoPrompt "Pick a Graph",orientation			if (V_flag)				return ""			endif			printIt = 1		endif		lname = UniqueName("Layout"+num2istr(Nmax)+"_",8,0)		// need to make a newlayout		NewLayout/P=$orientation		ModifyLayout mag=0.5, units=0, frame=0		DoWindow/C $lname//		SetWindow kwTopWin ,note=ReplaceNumberByKey("Nmax","",Nmax,"=")		SetWindow kwTopWin ,userdata(AppendGraph2Layout)=ReplaceNumberByKey("Nmax","",Nmax,"=")	endif	String page = StringByKey("PAGE", LayoutInfo(lname,"Layout"))	// get page size to determing landscape or portrait	Variable aspect = (str2num(StringFromList(3,page,","))-str2num(StringFromList(1,page,",")))	// aspect = height/width	aspect /= (str2num(StringFromList(2,page,","))-str2num(StringFromList(0,page,",")))	orientation = SelectString(aspect>1,"landscape","portrait")//	String rc = StringByKey(num2istr(Nmax),"1:1,1;2:2,1;3:3,1;4:2,2;6:3,2;9:3,3;12:4,3;16:4,4;20:4,5")	String rc = StringByKey(num2istr(Nmax),"1:1,1;2:2,1;3:3,1;4:2,2;6:3,2;8:4,2;9:3,3;12:4,3;16:4,4;20:4,5")	Variable rows=str2num(StringFromList(0,rc,","))	Variable columns=str2num(StringFromList(1,rc,","))	if (stringmatch("landscape",orientation))		// swap rows and columns for Landscape orientation		Variable swap = rows		rows = columns		columns = swap	endif	AppendLayoutObject/F=0/W=$lname graph $gName	String cmd	sprintf cmd, "Tile /A=(%d,%d)/O=1",rows,columns	Execute cmd	RemoveLayoutObjects/W=$lname/Z stamp0,stamp1	// make sure that text boxes are written last, so they show	Textbox/C/N=stamp0/W=$lname/F=0/A=RB/X=0.1/Y=0.1 "\\Z06\\{\"%s %s\",date(), time()}"	Textbox/C/N=stamp1/W=$lname/F=0/A=LB/X=0.1/Y=0.1 "\\Z06\\{\"%s\", CornerStamp1_()}"+":"+WinName(0,1)	if (printIt && topOfStack())		printf "\tAppendGraph2LayoutN(%d,\"%s\",\"%s\")\r",Nmax,orientation,gName	endif	return lnameEnd//Function xxx(Nmax)		// a test routine for AppendGraph2LayoutN()//	Variable Nmax//	Make/N=100/O y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12//	SetScale/I x 0,10,"", y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12//	y0 = 0.2*x -1//	y1 = sin(x/2) ; y2 = sin(x) ; y3 = sin(2*x) ; y4 = sin(3*x) ; y5 = sin(4*x)//	y5 = cos(x/2) ; y6 = cos(x) ; y7 = cos(2*x) ; y8 = cos(3*x) ; y9 = cos(4*x)//	y10 = exp(x/10)/3  ;  y11 = exp(-x/4)  ;  y12 = 2*exp(-x/2)-1//	Variable i//	String win//	for (i=0;i<=12;i+=1)//		win = "Graph"+num2istr(i)//		if (strlen(WinList(win,"","WIN:1"))<1)//			Display/K=1 $("y"+num2istr(i))//			DoWindow/C $win//			ModifyGraph tick=2, minor=1, standoff=0, mirror=1//			ModifyGraph axOffset(left)=-4.7,axOffset(bottom)=-1.5//		endif//		AppendGraph2LayoutN(Nmax,"",win)//	endfor//End//  ============================================================================  ////  ============================== Start of String Ranges ==============================  //// This section is for dealing with random or usually non contiguous sequence of integers// i.e.  you took data in scans 1-30, but scans 17, and 25 were no good.  So the valid range is "1-16,18-24,26-30"//  or perhaps you want to combine scans "3,7,9"  The following routines handle those situations in a simple fashion.Function NextInRange(range,last)	// given a string like "2-5,7,9-12,50" get the next number in this compound range									// the range is assumed to be monotonic, it returns NaN if no more values	String range					// list defining the range	Variable last					// last number obtained from this range, use -Inf to get start of range, it returns the next	// find first item in the list that should use next	String item	Variable m,i,j	Variable first						// first value in an item	do		item = StringFromList(j,range,",")		first = str2num(item)		// do we need to check for NaN in first?		if (numtype(first))			return NaN		elseif (last<first)				// skipping to the next item			return first		endif		// if last>=first, check to see if item is a '2-5' type range		m=-1							// remove any leading white space from item		do			m += 1		while (char2num(item[m])<=32)		item = item[m,strlen(item)-1]		i = strsearch(item,"-",1)		// location of first '-' after the first character		if (i<0)							// only a single number, not a dash type range, keep looking			j += 1			continue		endif		// check to see if last was in the range of item, but not the last value		if (last>=str2num(item) && last<str2num(item[i+1,Inf]))			return last+1		endif		j += 1	while(strlen(item)>0)	return NaNEnd//Function TestNextInRange(range)//	String range//	range = SelectString(strlen(range) ,"-16,-7--3,-1-2,5,50-54,99",range)//	Variable i = -Inf//	printf "for range = {%s},   ", range//	do//		i = NextInRange(range,i)//		if (numtype(i))//			break//		endif//		printf "%d  ", i//	while (!numtype(i))//	print ""//EndFunction ItemsInRange(range)	// given a string like "2-5,7,9-12,50" get the total number of values in the range	String range				// list defining the range								// the range is assumed to be monotonic, it returns NaN on error	String item							// each of the comma sepated items	Variable len=0						// the result, number of values represented	Variable m,i,j,N=ItemsInList(range,",")	for (j=0;j<N;j+=1)				// loop over each item		item = StringFromList(j,range,",")		m=-1							// remove any leading white space from item		do			m += 1		while (char2num(item[m])<=32)		item = item[m,strlen(item)-1]		i = strsearch(item,"-",1)		// location of first '-' after the first character		if (i<0)							// only a single number, not a dash type range, keep looking			len += 1		else								// item is a dash type			len += str2num(item[i+1,Inf])-str2num(item)+1		endif	endfor	return lenEnd//	print ItemsInRange("-16,-7--3,-1-2,5,50-54,99")//  17//	print ItemsInRange("1-5")//  5//Function firstInRange(range)//	String range//	return str2num(range)//End//Function lastInRange(range)			// returns the last number in the range, lastInRange("3,5,9-20") returns 20	String range	Variable i,last,c	i = strsearch(range,"Inf",Inf,3)	// do a special check to see if this ends in 'Inf'	if (i+3 == strlen(range) && i>=0)		return Inf	endif	i = strlen(range)+1	do		i -= 1		c = char2num(range[i-1])	while(c>=48 && c<=57 && i>0)	// a digit, continue	last=str2num(range[i,Inf])	if (c==45)		if (i==1)			return -last		endif		c = char2num(range[i-2])		// char preceeding minus sign		if (c==45 || c==44)			return -last		endif	endif	return lastEnd// Caution expandRange("1-100000",";") will produce a very long string!  Use NextInRange() to avoid this problemFunction/S expandRange(range,sep)	// expand a string like "2-5,7,9-12,50" to "2,3,4,5,7,9,10,11,12,50"	String range					// series of numberseparated by commas and dashes, white is space igaored	String sep						// separates final list, usually ";"	if (strsearch(range,"Inf",0,2)>=0)	// cannot put an infinite number of characters into a string		return ""	endif	if (strlen(sep)<1)				// sep defaults to ';'		sep = ";"	endif	Variable i1,i2,i	String str,out=""	Variable N=ItemsInList(range,",")	if (N<1)		return ""	endif	Variable j=0	do		str = StringFromList(j, range, ",")		Variable m=-1				// remove any leading white space		do			m += 1		while (char2num(str[m])<=32)		str = str[m,strlen(str)-1]		// now check str to see if it is a range like "20-23"		i1 = str2num(str)		i = strsearch(str,"-",strlen(num2str(i1)))		// position of "-" after first number		if (i>0)			i2 = str2num(str[i+1,inf])			i = i1			do				out += num2str(i)+sep				i += 1			while (i<=i2)		else			out += num2str(i1)+sep		endif		j += 1	while (j<N)	i = strlen(out)-1	if (char2num(out[i])==char2num(sep))		out = out[0,i-1]	endif	return outEnd// This is the inverse of expandRange()Function/S compressRange(range,sep) 	// take a range like "1;2;3;4;5;9;10;11" change it to "1-5,9-11"	String range	String sep							// sep is the separator used, will be replaced with commas and dashes	String comp=""						// the compressed string	String num	Variable j,first,last,i=0	Variable N=ItemsInList(range,sep)	if (N<1)		return ""	endif	last = str2num(StringFromList(0,range,sep))-2	// ensure that first item is at the start	for (i=0;i<N;i+=1)		j = str2num(StringFromList(i,range,sep))		num = num2str(j)		if (numtype(j))			return ""		elseif ((j-last)==1)					// keep counting			last = j		elseif ((j-last)!=1)					// new sub-range			if (i==0)							// special for first point				comp = num			elseif (first==last)					// just add a single number range				comp += ","+num			else									// close out previous range, and add single number				comp += "-"+num2str(last)+","+num			endif			last = j			first = j		endif	endfor	if (first!=last)		comp += "-"+num2str(last)	endif	return compEnd//Function test_compressRange()//	String range//	range = "//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")//	range = "1;2;3;4;5;9;10;11"//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")//	range = "4"//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")//	range = "4;7"//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")//	range = "-10;-9;-8;-7;-6;-5;-3;-2;-1;0;1;2;7;9;22"//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")//End//  =============================== End of String Ranges ==============================  ////  ============================================================================  ////  ============================================================================  ////  ========================== Start of some general utility stuff ==========================  //Function keyInList(key,keyWordList,keySepStr,listSepStr)		// returns true if key=value pair is in the keyWordList	String key						// string with key	String keyWordList				// list of keyword=value pairs	String keySepStr				// separates key and value, defaults to colon	String listSepStr				// separates key value pairs, defaults to semicolon	keySepStr = SelectString(strlen(keySepStr),":",keySepStr)	// default to colon	listSepStr = SelectString(strlen(listSepStr),";",listSepStr)	// default to semicolon	String find=key+keySepStr									// find this	if (strsearch(keyWordList,find,0)==0)						// check if it is at the start		return 1												// found key=value is first pair	endif	if ( strsearch(keyWordList,listSepStr+find,0)>0)			// check if key is after first key=value pair		return 1												// found key=value is a later pair	endif	return 0													// no key=value foundEnd//	Merges two key=value lists, if priority=0, then list0 has priority, if priority=1 then list1Function/S MergeKeywordLists(list0,list1,priority,keySepStr,listSepStr)	String list0,list1	Variable priority				// 0 or 1	String keySepStr				// separates key and value, defaults to colon	String listSepStr				// separates key value pairs, defaults to semicolon	keySepStr = SelectString(strlen(keySepStr),":",keySepStr)	// default to colon	listSepStr = SelectString(strlen(listSepStr),";",listSepStr)	// default to semicolon	String item, key,value	Variable i,N=ItemsInList(list1)	for (i=0;i<N;i+=1)				// for each keyword=value pair in list1		item = StringFromList(i,list1,listSepStr)		key = StringFromList(0,item,keySepStr)		value = StringFromList(1,item,keySepStr)		if (keyInList(key,list0,keySepStr,listSepStr) && priority==0)			continue				// skip because key already in list0, and list0 has priority		endif		list0 = ReplaceStringByKey(key,list0,value,keySepStr,listSepStr)	endfor	return list0End// return a list of waves in current folder having all tags in having a "waveClass" that is a member of the list waveClassList// The waveClassList, is a semicolon separated list, and the members can have wildcards. e.g. "speImage*"// This is similar to WaveList(), but with a finer selectionFunction/T WaveListClass(waveClassList,search,options)	String waveClassList				// a list of acceptable wave classes (semicolon separated)	String search						// same as first argument in WaveList()	String options						// same as last argument in WaveList()	String in = WaveList(search,";",options), out=""	String name,key, class	Variable m, j, add	for (m=0, name=StringFromList(0,in); strlen(name); m+=1,name=StringFromList(m,in))		class = StringByKey("waveClass",note($name),"=")		for (j=0,add=0;j<ItemsInList(waveClassList);j+=1)			if (stringmatch(class,StringFromList(j,waveClassList)))				add = 1				break			endif		endfor		if (add)			out += name+";"		endif	endfor	return outEnd//Function/T WaveListClass(waveClassList,search,options)//	String waveClassList				// a list of acceptable wave classes (semicolon separated)//	String search						// same as first argument in WaveList()//	String options						// same as last argument in WaveList()////	String in = WaveList(search,";",options), out=""//	String name,key, wnote//	Variable m//	for (m=0, name=StringFromList(0,in); strlen(name); m+=1,name=StringFromList(m,in))//		wnote = note($name)//		if (WhichListItem(StringByKey("waveClass",wnote,"="),waveClassList)<0)//			continue//		endif//		out += name+";"//	endfor//	return out//EndFunction/S FindGraphsWithWave(w)	// find the graph window which contains the specified wave	Wave w	if (!WaveExists(w))		return ""	endif	String name, name0=GetWavesDataFolder(w,2), out=""	String ilist,win,wlist = WinList("*",";","WIN:1")	Variable i,Ni,m,Nm=ItemsInList(wlist)	for (m=0;m<Nm;m+=1)		win = StringFromList(m,wlist)		ilist = ImageNameList(win,";")		// list of images in this window		Ni = ItemsInList(ilist)		for (i=0;;i+=1)					// first check for graphs (x or y trace)			Wave wi = WaveRefIndexed(win,i,3)			if (!WaveExists(wi))				break			endif			if (stringmatch(GetWavesDataFolder(wi,2),name0))				out += win+";"			endif		endfor		for (i=0;i<ItemsInList(ilist);i+=1)// next check all the images			name = GetWavesDataFolder(ImageNameToWaveRef(win,StringFromList(i,ilist)),2)			if (stringmatch(name,name0))				out += win+";"			endif		endfor	endfor	return outEndFunction compareWaves(a,b)	WAVE a,b	Variable n=numpnts(a)	Variable i	if (n!=numpnts(b))		return 0	endif	for (i=0;i<n;i+=1)		if (numtype(a[i]))			if (numtype(a[i])!=numtype(b[i]))				return 0			endif		elseif (a[i]!=b[i])			return 0		endif	endfor	return 1EndFunction monotonic(a)	// determines whether values of a particular wave are monotonic increasing (if any NaN, returns false)	Wave a		// the wave	if (strlen(NameOfWave(a))<1)		Abort "wave not found"	endif	Variable n=numpnts(a)	Variable i=1	do		if (a[i-1]>a[i])			return 0		endif		i += 1	while (i<n)	return 1EndFunction isdigit(c)	String c	Variable i=char2num(c)	return (48<=i && i<=57)End// This routine is much faster than going through an [sprintf str,"%g",val] conversionFunction roundSignificant(val,N)	// round val to N significant figures	Variable val			// input value to round	Variable N			// number of significant figures	if (val==0 || numtype(val))		return val	endif	Variable is,tens	is = sign(val) 	val = abs(val)	tens = 10^(N-floor(log(val))-1)	return is*round(val*tens)/tensEnd//Static Function hashWave(wav)	// the hash function//	Wave wav//	Variable len = numpnts(wav)//	Variable seed = 5381,hash=0,i//	for (i=0;i<len;i+=1)//		hash = (hash*seed)+wav[i]//		hash = mod(hash,0xFFFFFFFF)//	endfor//	return hash//End//Function hashJZT(str)//	String str//	Variable len = strlen(str)//	Variable seed = 5381,hash=0,i//	for (i=0;i<len;i+=1)//		hash = (hash*seed)+char2num(str[i])//		hash = mod(hash,0xFFFFFFFF)//	endfor//	return hash//End//Function test_for_hashJZT()//	String str=""//	Variable i,hh, timer,sec//	for (i=0;i<4000;i+=1)//		str += num2char(mod(i,93)+33)//	endfor//	timer = startMSTimer//	for (i=0;i<10;i+=1)//		hh = hashJZT(str)//	endfor//	sec = stopMSTimer(timer)/1e6/10//	printf "for an %d byte long string,  hashJZT(str)=%d    in  %.3f sec\r",strlen(str),hh,sec//EndFunction normalize(a)	// normalize a and return the initial magnitude	Wave a	Variable norm_a	if (WaveDims(a)==1)											// for a 1-d wave, normalize the vector		norm_a = norm(a)	elseif(WaveDims(a)==2 && DimSize(a,0)==DimSize(a,1))	// for an (n x n) wave, divide by the determinant		norm_a = MatrixDet(a)^(1/DimSize(a,0))	endif	if (norm_a==0 || numtype(norm_a))		return 0	endif	a /= norm_a	return norm_aEnd//Function normalize(a)	// normalize a and return the initial magnitude//	Wave a//	Variable norm_a = norm(a)//	a /= norm_a//	return norm_a//End// do not use num2sexigesmal() anymore, for new code use Secs2Time() directly.Function/S num2sexigesmal(seconds,places)	// convert seconds into a hh:mm:ss.sss   string	Variable seconds	Variable places	return Secs2Time(seconds,5,places)End//Function/S num2sexigesmal(seconds,places)	// convert seconds into a hh:mm:ss.sss   string//	Variable seconds//	Variable places////	Variable minutes, hours, sec//	Variable addMinus = (seconds<0)//	String str, fmt, sfrac////	seconds = abs(seconds)//	hours = trunc(seconds/3600.)		// number of hours (signed)//	seconds = mod(seconds,3600.)		// remove the hours//	minutes = trunc(seconds/60.)//	seconds = mod(seconds,60.)			// remove the minutes//	sec = trunc(seconds)////	sprintf fmt "%%.%df",places//	sprintf sfrac fmt, seconds-sec//	sfrac = sfrac[1,inf]					// remove the leading zero//	sprintf str "%02d:%02d:%02d%s",hours,minutes,seconds,sfrac//	if (addMinus)//		str = "-"+str//	endif//	return str//End// returns 1 if the  calling function was invoked from a  menu item or command line (otherwise 0)Function topOfStack()	return (ItemsInList(GetRTStackInfo(0))<3)End//Function abc()//	String cmd, pathStr="\\\"/Users/tischler/data/Sector 34/July 4, 2006/EW5/recon/\\\""//	print PathStr//	sprintf cmd, "do shell script \"ls %s\"",pathStr//	ExecuteScriptText cmd//	print cmd//	print S_value[0,72]//End
