#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.14
Constant IR2EversionNumber = 1.15

//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.15 add option to reduce output to single precision output (requested) 
//1.14 fix missign wwavelength if dsata are imported as ASII from Irena and exported again. 
//1.13 fix naming bug for Nexus which caused the names not being changed as needed, when Nexus was used. 
//1.12 fix extensions mess, force extesions, cannot make the old one to be remebered correctly... Too many options. 
//1.11 fix bug that GSAS-II data type was not updating/chaqnging output name as expected. 
//1.10 added export of xye data file for GSAS-II
//1.09 added getHelp button calling to www manual
//1.08 changes for panel scaling
//1.07 fixed multiple data erxport with QRS
//1.06 modified GUI to disable Export Data & notes on main panel, when Multiple data selection panel is opened. Confused users. Changeds call to pull up without initialization, if exists. 
//		changed mode for Listbox to enable shift-click selection of range of data, use ctrl/cmd for one-by-one data selection
//1.05 added in panel version control and added vertical scrolling 
//1.04 fixed Multiple data export which was broken by update to control procedures
//1.03 fixed QRS data export which was not working due to eventCode missing in structure
//1.02 removed all font and font size from panel definitions to enable user control
//1.01 added license for ANL
 

//This is tool to export any type of 2 -3 column data we have (x, y, and error (if exists)

Function IR2E_UniversalDataExport()

	//check for panel if exists - pull up, if not create
	DoWindow UnivDataExportPanel
	if(V_Flag)
		DoWindow/F UnivDataExportPanel
		DoWIndow IR2E_MultipleDataSelectionPnl
		if(V_Flag)
			DoWindow/F IR2E_MultipleDataSelectionPnl
		endif
	else
		//initialize, as usually
		IR2E_InitUnivDataExport()
		NVAR ExportMultipleDataSets = root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets
		ExportMultipleDataSets=0		//do nto start in multiple data export, it does not set parameters well...  
		IR2E_UnivDataExportPanel()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("UnivDataExportPanel", IR2EversionNumber,1)
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2E_MainCheckVersion()	
	DoWindow UnivDataExportPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("UnivDataExportPanel", IR2EversionNumber))
			DoAlert /T="The ASCII Export panel was created by incorrect version of Irena " 1, "Export ASCII may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				IR2E_UniversalDataExport()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2E_InitUnivDataExport()
			endif
		endif
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR2E_UnivDataExportPanel()
	//PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690) as "Universal data export tool"
	DoWindow/C UnivDataExportPanel
	
	string AllowedIrenaTypes="DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;R_Int;"
	IR2C_AddDataControls("IR2_UniversalDataExport","UnivDataExportPanel",AllowedIrenaTypes,"AllCurrentlyAllowedTypes","","","","", 0,0)
	TitleBox MainTitle title="\Zr220Universal data export panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,181},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr160Data input",pos={10,27},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	TitleBox Info2 title="\Zr160Preview Options:",pos={20,190},frame=0,fstyle=2, fixedSize=1,size={150,20},fColor=(0,0,52224)
	TitleBox Info3 title="\Zr160Output Options:",pos={20,320},frame=0,fstyle=2, fixedSize=0,size={20,15},fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,307},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)

	CheckBox ExportMultipleDataSets,pos={100,160},size={225,14},proc=IR2E_UnivExpCheckboxProc,title="Export multiple data sets?"
	CheckBox ExportMultipleDataSets,variable= root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets, help={"When checked the multiple data sets with same data can be exported"}

	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR2E_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	CheckBox GraphDataCheckbox,pos={15,220},size={225,14},noproc,title="Display graph with data?"
	CheckBox GraphDataCheckbox,variable= root:Packages:IR2_UniversalDataExport:GraphData, help={"When checked the graph displaying data will be displayed"}
	CheckBox DisplayWaveNote,pos={15,250},size={225,14},noproc,title="Display notes about data?"
	CheckBox DisplayWaveNote,variable= root:Packages:IR2_UniversalDataExport:DisplayWaveNote, help={"When checked notebook with notes about data history will be displayed"}
	Button LoadAndGraphData, pos={100,280},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Load data", help={"Load data into the tool, generate graph and display notes if checkboxes are checked."}

	//Nexus or ASCII?
	CheckBox ExportASCII,pos={10,340},size={190,14},proc=IR2E_UnivExportCheckProc,title="Export ASCII?", mode=1
	CheckBox ExportASCII,variable= root:Packages:IR2_UniversalDataExport:ExportASCII, help={"When checked ASCII files will be created"}
	CheckBox ExportGSASxye,pos={130,340},size={190,14},proc=IR2E_UnivExportCheckProc,title="Export GSAS-II xye?", mode=1
	CheckBox ExportGSASxye,variable= root:Packages:IR2_UniversalDataExport:ExportGSASxye, help={"When checked ASCII files for GSAS-II will be created"}
	CheckBox ExportCanSASNexus,pos={260,340},size={190,14},proc=IR2E_UnivExportCheckProc,title="Export NEXUS?", mode=1
	CheckBox ExportCanSASNexus,variable= root:Packages:IR2_UniversalDataExport:ExportCanSASNexus, help={"When checked Nexus (canSAS for data) files will be created"}
	
	CheckBox ExportSingleCanSASFile,pos={15,360},size={190,14},proc=IR2E_UnivExportCheckProc,title="Export Single canSAS NEXUS (with multiple data)?"
	CheckBox ExportSingleCanSASFile,variable= root:Packages:IR2_UniversalDataExport:ExportSingleCanSASFile, help={"When checked Nexus (canSAS for data) files will be created"}
	
	CheckBox AttachWaveNote,pos={10,375},size={190,14},noproc,title="Attach notes about data?"
	CheckBox AttachWaveNote,variable= root:Packages:IR2_UniversalDataExport:AttachWaveNote, help={"When checked block of text with notes about data history will be attached before the data itself"}
	CheckBox reduceOutputPrecision,pos={220,375},size={190,14},noproc,title="Reduce precision?"
	CheckBox reduceOutputPrecision,variable= root:Packages:IR2_UniversalDataExport:reduceOutputPrecision, help={"When checked, data are converted to single precision (default is double precision)"}


	CheckBox UseFolderNameForOutput,pos={10,395},size={190,14},proc=IR2E_UnivExportCheckProc,title="Use Sample/Fldr name for output?"
	CheckBox UseFolderNameForOutput,variable= root:Packages:IR2_UniversalDataExport:UseFolderNameForOutput, help={"Use Folder name for output file name"}
	CheckBox UseYWaveNameForOutput,pos={220,395},size={190,14},proc=IR2E_UnivExportCheckProc,title="Use Ywv name for output?"
	CheckBox UseYWaveNameForOutput,variable= root:Packages:IR2_UniversalDataExport:UseYWaveNameForOutput, help={"Use Y wave name for output file name"}


	SetVariable CurrentlyLoadedDataName,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:CurrentlyLoadedDataName, noedit=1,noProc,frame=0
	SetVariable CurrentlyLoadedDataName,pos={3,420},size={385,25},title="Loaded data:", help={"This is data set currently loaded in the tool. These data will be saved."},fstyle=1,labelBack=(65280,21760,0)

	SetVariable CurrentlySetOutputPath,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:CurrentlySetOutputPath, noedit=1,noProc,frame=0
	SetVariable CurrentlySetOutputPath,pos={3,455},size={370,25},title="Export Folder:", help={"This is data folder outside Igor  where the data will be saved."},fstyle=0
	Button ExportOutputPath, pos={100,480},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Set export folder:", help={"Select export folder where to save new ASCII data sets."}
//	Button ExportNexusFile, pos={100,492},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Create/Find Nexus Output file", help={"Create output Nexus file name in above location."}

	SetVariable NewFileOutputName,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:NewFileOutputName,noProc,frame=1
	SetVariable NewFileOutputName,pos={3,520},size={370,25},title="Export file name:", help={"This is name for new data file which will be created"},fstyle=1
	SetVariable OutputNameExtension,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:OutputNameExtension,noProc,frame=1
	SetVariable OutputNameExtension,pos={3,540},size={200,25},title="Export file extension:", help={"This is extension for new data file which will be created"},fstyle=1
	SetVariable HeaderSeparator,limits={0,Inf,0},value= root:Packages:IR2_UniversalDataExport:HeaderSeparator,proc=IR2E_UnivExportToolSetVarProc,frame=1
	SetVariable HeaderSeparator,pos={3,560},size={180,25},title="Header separator:", help={"This is symnol at the start of header line. Include here spaces if you want them..."},fstyle=1
//
	Button ExportData, pos={100,600},size={180,20}, proc=IR2E_InputPanelButtonProc,title="Export Data & Notes", help={"Save ASCII file with data and notes for these data"}
	IR2E_FixMainGUI()
end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
Function IR2E_FixMainGUI()
	
	DoWIndow UnivDataExportPanel
	if(V_Flag)
		NVAR MultipleData=root:Packages:IR2_UniversalDataExport:ExportMultipleDataSets
		NVAR ExportCanSASNexus = root:Packages:IR2_UniversalDataExport:ExportCanSASNexus
		NVAR ExportASCII = root:Packages:IR2_UniversalDataExport:ExportASCII
		NVAR ExportGSASxye = root:Packages:IR2_UniversalDataExport:ExportGSASxye
		NVAR ExportSingleCanSASFile = root:Packages:IR2_UniversalDataExport:ExportSingleCanSASFile

		Button ExportData, win=UnivDataExportPanel, disable=2*MultipleData
		CheckBox AttachWaveNote,win=UnivDataExportPanel, disable=(ExportCanSASNexus || ExportGSASxye)
		SetVariable HeaderSeparator, win=UnivDataExportPanel, disable=!(ExportASCII)
		CheckBox UseYWaveNameForOutput, win=UnivDataExportPanel, disable=(ExportCanSASNexus&&ExportSingleCanSASFile)
		CheckBox UseFolderNameForOutput, win=UnivDataExportPanel, disable=(ExportCanSASNexus&&ExportSingleCanSASFile)
		CheckBox ExportSingleCanSASFile, win=UnivDataExportPanel, disable=(ExportASCII || ExportGSASxye)
		CheckBox reduceOutputPrecision, win=UnivDataExportPanel, disable=(ExportCanSASNexus || ExportGSASxye)
	endif
end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
Function IR2E_UnivExpCheckboxProc(CB_Struct)
	STRUCT WMCheckboxAction &CB_Struct

//	DoAlert 0,"Fix IR2E_UnivExpCheckboxProc"
	if(CB_Struct.EventCode==2)
		if(stringMatch(CB_Struct.ctrlName,"ExportMultipleDataSets"))
			if(CB_Struct.checked)
	
				IR2E_UpdateListOfAvailFiles()
				DoWindow IR2E_MultipleDataSelectionPnl
				if(!V_Flag)				
					NewPanel/K=1 /W=(400,44,800,355) as "Multiple Data Export selection"
					DoWIndow/C IR2E_MultipleDataSelectionPnl
					SetDrawLayer UserBack
					SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65535)
					DrawText 29,29,"Multiple Data Export selection"
					DrawText 10,255,"Configure Universal export tool panel options"
					DrawText 10,275,"Select multiple data above and export : "
					ListBox DataFolderSelection,pos={4,35},size={372,200}, mode=10, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
					ListBox DataFolderSelection,listWave=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
					ListBox DataFolderSelection,selWave=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData
	
					Button UpdateData,pos={280,245},size={100,15},proc=IR2E_ButtonProc,title="Update list"
					Button UpdateData,fSize=10,fStyle=2
					
					Button AllData,pos={4,285},size={100,15},proc=IR2E_ButtonProc,title="Select all data"
					Button AllData,fSize=10,fStyle=2
					Button NoData,pos={120,285},size={100,15},proc=IR2E_ButtonProc,title="DeSelect all data"
					Button NoData,fSize=10,fStyle=2
					Button ProcessAllData,pos={240,285},size={150,15},proc=IR2E_ButtonProc,title="Export selected data"
					Button ProcessAllData,fSize=10,fStyle=2
					Button ProcessAllData fColor=(65535,16385,16385)
				else
				
					DoWindow/F IR2E_MultipleDataSelectionPnl
					
				endif
				AutoPositionWindow/M=0 /R=UnivDataExportPanel IR2E_MultipleDataSelectionPnl
			else
				KillWIndow/Z IR2E_MultipleDataSelectionPnl
			endif
		endif		//end of ExportMultipleDataSets

	endif
	IR2E_FixMainGUI()
End
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************



Function IR2E_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

		wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData
	if(stringmatch(ctrlName,"AllData"))
		SelectionOfAvailableData=1
	endif
	if(stringmatch(ctrlName,"NoData"))
		SelectionOfAvailableData=0
	endif
	if(stringmatch(ctrlName,"UpdateData"))
		IR2E_UpdateListOfAvailFiles()
	endif
	if(stringmatch(ctrlName,"ProcessAllData"))
		IR2E_ExportMultipleFiles()
		print "Export of all data is DONE!"
	endif
	
	
End

//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR2E_ExportMultipleFiles()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR UseQRSdata=root:Packages:IR2_UniversalDataExport:UseQRSData
	SVAR DataFolderName = root:Packages:IR2_UniversalDataExport:DataFolderName
	SVAR IntensityWaveName=root:Packages:IR2_UniversalDataExport:IntensityWaveName
	SVAR QWavename=root:Packages:IR2_UniversalDataExport:QWavename
	SVAR ErrorWaveName=root:Packages:IR2_UniversalDataExport:ErrorWaveName
	string StartFolderName = RemoveFromList(stringFromList(ItemsInList(DataFolderName , ":")-1,DataFolderName,":"), DataFolderName  , ":")

	Wave/T ListOfAvailableData=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData

	variable i
	
	For(i=0;i<numpnts(ListOfAvailableData);i+=1)
		if(!UseQRSdata)		//just stuff in Folder name and go ahead...
			if(SelectionOfAvailableData[i])
				DataFolderName = StartFolderName+ListOfAvailableData[i]
				if(!DataFolderExists(DataFolderName ))
					Abort "Problem with data folder definition. Please \"Update list\" and try again" 
				endif
				IR2E_LoadDataInTool()		
				DoUpdate
				sleep/S 1	
				IR2E_ExportTheData()
			endif
		else	//we need to set all strings for qrs data... 
			if(SelectionOfAvailableData[i])
				DataFolderName = StartFolderName+ListOfAvailableData[i]
				if(!DataFolderExists(DataFolderName ))
					Abort "Problem with data folder definition. Please \"Update list\" and try again" 
				endif
				//now for qrs we need to reload the other wave names... 
				STRUCT WMPopupAction PU_Struct
				PU_Struct.ctrlName = "SelectDataFolder"
				PU_Struct.popNum=-1
				PU_Struct.eventCode=2
				PU_Struct.popStr=DataFolderName
				PU_Struct.win = "UnivDataExportPanel"
				//PopupMenu SelectDataFolder win=UnivDataExportPanel, popmatch=DataFolderName
				PopupMenu SelectDataFolder win=UnivDataExportPanel, popmatch=StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":")
				IR2C_PanelPopupControl(PU_Struct)
				IR2E_LoadDataInTool()		
				DoUpdate
				sleep/S 1	
				IR2E_ExportTheData()
			endif
		endif
	
	endfor
	

	setDataFolder OldDF
end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UpdateListOfAvailFiles()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport
	
	NVAR UseIndra2Data=root:Packages:IR2_UniversalDataExport:UseIndra2Data
	NVAR UseQRSdata=root:Packages:IR2_UniversalDataExport:UseQRSData
	NVAR UseResults = root:Packages:IR2_UniversalDataExport:UseResults
	NVAR UseSMRData = root:Packages:IR2_UniversalDataExport:UseSMRData
//	SVAR StartFolderName=root:Packages:IR2_UniversalDataExport:StartFolderName
	SVAR DataFolderName = root:Packages:IR2_UniversalDataExport:DataFolderName
	string StartFolderName = RemoveFromList(stringFromList(ItemsInList(DataFolderName , ":")-1,DataFolderName,":"), DataFolderName  , ":")
	SVAR IntensityWaveName=root:Packages:IR2_UniversalDataExport:IntensityWaveName
	
	//string CurrentFolders=IR2S_GenStringOfFolders(StartFolderName,UseIndra2Data, UseQRSData,UseSMRData,1)
	string CurrentFolders
	IR2P_GenStringOfFolders(winNm="UnivDataExportPanel")
	SVAR RealLongListOfFolder = root:Packages:IR2_UniversalDataExport:RealLongListOfFolder		//after 2/2013 update this is where the list is.
	CurrentFolders = RealLongListOfFolder
	//these are all folders with data... Now we need to check for results of different type... And clean up those which are not in the same subfolder... 
	variable i, j
	string TempStr
	For(i=ItemsInList(CurrentFolders , ";")-1;i>=0;i-=1)			//cleanup from other start folders...
		TempStr =  StringFromList(i, CurrentFolders , ";")
		if(!stringmatch(TempStr, StartFolderName+"*" ))
			CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
		endif
	endfor	
	//now cleanup from different wave names... Valid only for Indra 2 data and results, not qrs data...
	if(UseIndra2Data || UseResults)
		For(i=ItemsInList(CurrentFolders , ";")-1;i>=0;i-=1)			//cleanup from other start folders...
			TempStr =  StringFromList(i, CurrentFolders , ";")
			if(UseIndra2Data)		//check for Indra 2 data of the right kind... 
				if(!stringmatch(IN2G_CreateListOfItemsInFolder(TempStr,2), "*"+IntensityWaveName+"*" ))
					CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
				endif
			else		//results... May need to modify later, this will manage only same generation results... 
				if(!stringmatch(IN2G_CreateListOfItemsInFolder(TempStr,2), "*"+IntensityWaveName+"*" ))
					CurrentFolders = RemoveListItem(i, CurrentFolders , ";")
				endif
			endif
		endfor	
		
	endif
	
	Wave/T ListOfAvailableData=root:Packages:IR2_UniversalDataExport:ListOfAvailableData
	Wave SelectionOfAvailableData=root:Packages:IR2_UniversalDataExport:SelectionOfAvailableData
		
	Redimension/N=(ItemsInList(CurrentFolders , ";")) ListOfAvailableData
	j=0
	For(i=0;i<ItemsInList(CurrentFolders , ";");i+=1)
		TempStr = ReplaceString(StartFolderName, StringFromList(i, CurrentFolders , ";"),"")
		if(strlen(TempStr)>0)
			ListOfAvailableData[j] = tempStr
			j+=1
		endif
	endfor
	Redimension/N=(Numpnts(ListOfAvailableData))  SelectionOfAvailableData
	SelectionOfAvailableData = 0
	setDataFolder OldDF
end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UnivExportToolSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr(ctrlName,"HeaderSeparator")==0)
		DoWindow ExportNoteDisplay
		if(V_Flag)
			KillWIndow/Z ExportNoteDisplay
		else
			abort
		endif

		DFref oldDf= GetDataFolderDFR()

		setDataFolder root:Packages:IR2_UniversalDataExport

		NVAR AttachWaveNote
		NVAR DisplayWaveNote
		NVAR UseFolderNameForOutput
		NVAR UseYWaveNameForOutput

		SVAR DataFolderName
		SVAR IntensityWaveName
		SVAR QWavename
		SVAR ErrorWaveName
		SVAR CurrentlyLoadedDataName
		SVAR CurrentlySetOutputPath
		SVAR NewFileOutputName
		SVAR HeaderSeparator
		
		
		Wave/Z tempY=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
		if(!WaveExists(tempY))
			setDataFolder OldDf
			abort
		endif	
		string OldNote
		String nb = "ExportNoteDisplay"
		variable i
		if(DisplayWaveNote)
			OldNote = note(TempY) +"Exported="+date()+" "+time()+";"
			NewNotebook/K=1/N=$nb/F=0/V=1/K=0/W=(300,270,700,530) as "Data Notes"
			Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
			Notebook $nb font="Arial", fStyle=0, textRGB=(0,0,0)
			For(i=0;i<ItemsInList(OldNOte);i+=1)
				Notebook $nb text=HeaderSeparator + stringFromList(i,OldNote)+"\r"
			endfor
		endif
		setDataFolder OldDf
	endif

End

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_UnivExportCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport
	
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput

	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath
	SVAR NewFileOutputName
		NVAR ExportCanSASNexus = root:Packages:IR2_UniversalDataExport:ExportCanSASNexus
		NVAR ExportASCII = root:Packages:IR2_UniversalDataExport:ExportASCII
		NVAR ExportGSASxye = root:Packages:IR2_UniversalDataExport:ExportGSASxye
			
		SVAR OutputNameExtension = root:Packages:IR2_UniversalDataExport:OutputNameExtension
		if(stringMatch(ctrlName,"ExportASCII"))
			if(checked)
				ExportASCII = 1
				ExportCanSASNexus = 0
				ExportGSASxye = 0
				OutputNameExtension  = "dat"
			endif
		endif
		if(stringMatch(ctrlName,"ExportGSASxye"))
			if(checked)
				ExportGSASxye = 1
				ExportASCII = 0
				ExportCanSASNexus = 0
				OutputNameExtension  = "xye"
			endif
		endif
		if(stringMatch(ctrlName,"ExportCanSASNexus"))
			if(checked)
				ExportGSASxye =0 
				ExportASCII = 0
				ExportCanSASNexus = 1
				OutputNameExtension  = "h5"
			endif
			if(ExportCanSASNexus)
				DoAlert /T="NXcanSAS Warning for slit smeared data" 0, "At this time NO software has been verified to be able to use slit smeared data. Export ONLY desmeared USAXS data, please."
			endif
		endif
		NVAR UseFolderNameForOutput = root:Packages:IR2_UniversalDataExport:UseFolderNameForOutput
		NVAR UseYWaveNameForOutput = root:Packages:IR2_UniversalDataExport:UseYWaveNameForOutput
		if(stringMatch(ctrlName,"UseFolderNameForOutput"))
			if(checked)
				UseFolderNameForOutput = 1
				UseYWaveNameForOutput = 0
			else
				UseFolderNameForOutput = 0
				UseYWaveNameForOutput = 1
			endif
		endif
		if(stringMatch(ctrlName,"UseYWaveNameForOutput"))
			if(checked)
				UseFolderNameForOutput = 0
				UseYWaveNameForOutput = 1
			else
				UseFolderNameForOutput = 1
				UseYWaveNameForOutput = 0
			endif
		endif
	if(cmpstr(ctrlName,"UseFolderNameForOutput")==0 || cmpstr(ctrlName,"UseYWaveNameForOutput")==0)
		
		NewFileOutputName = ""
		if(UseFolderNameForOutput)
			NewFileOutputName += IN2G_RemoveExtraQuote(StringFromList(ItemsInList(DataFolderName,":")-1,DataFolderName,":"),1,1)
		endif
		if(UseFolderNameForOutput && UseYWaveNameForOutput)
			NewFileOutputName += "_"
		endif
		if(UseYWaveNameForOutput)
			NewFileOutputName += IN2G_RemoveExtraQuote(IntensityWaveName,1,1)
		endif	
		
	endif
	nVAR ExportSingleCanSASFile = root:Packages:IR2_UniversalDataExport:ExportSingleCanSASFile
	if(stringMatch(ctrlName,"ExportSingleCanSASFile"))
		if(checked)
			ExportSingleCanSASFile=1
			DoALert 0, "Type in \"Export file name\" name of file. Make sure it is acceptable name for the OS. " 
		else
			ExportSingleCanSASFile=0
		endif
	endif
	
	

	IR2E_FixMainGUI()
	setDataFolder OldDf
End

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport
	if(cmpstr(ctrlName,"LoadAndGraphData")==0)
		//here we load the data and create default values
		IR2E_LoadDataInTool()
	endif
	if(cmpstr(ctrlName,"ExportOutputPath")==0)
		//here we set output path and patch it in the string to be seen by user 
		IR2E_ChangeExportPath()
	endif
	if(cmpstr(ctrlName,"ExportData")==0)
		//here we do whatever is apropriate...
		IR2E_ExportTheData()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/ExportData.html")
	endif
	
	setDataFolder oldDF
end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_ExportTheData()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR AttachWaveNote
	NVAR GraphData
	NVAR DisplayWaveNote
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput
	NVAR reduceOutputPrecision

	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	SVAR CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath
	SVAR NewFileOutputName
	SVAR OutputNameExtension
	SVAR HeaderSeparator
	
	string UserSampleName=IN2G_ReturnUserSampleName(DataFolderName)

	NVAR ExportCanSASNexus
	NVAR ExportASCII
	NVAR ExportGSASxye
	NVAR ExportMultipleCanSASFiles
	NVAR ExportSingleCanSASFile

	NVAR UseIndra2Data=root:Packages:IR2_UniversalDataExport:UseIndra2Data
	NVAR UseQRSdata=root:Packages:IR2_UniversalDataExport:UseQRSdata
	NVAR UseResults=root:Packages:IR2_UniversalDataExport:UseResults
	NVAR UseSMRData=root:Packages:IR2_UniversalDataExport:UseSMRData
	
	Wave/Z TempY=$(DataFolderName+possiblyquoteName(IntensityWaveName))
	Wave/Z TempX=$(DataFolderName+possiblyquoteName(QWavename))
	Wave/Z TempE=$(DataFolderName+possiblyquoteName(ErrorWaveName))
	if(!WaveExists(TempE))
		Duplicate/Free TempX, TempE
		TempE = 0
	endif
	if(UseIndra2Data)
		Wave/Z TempdX=$(DataFolderName+"SMR_dQ")
	elseif(UseQRSdata)
		Wave/Z TempdX=$(DataFolderName+possiblyquoteName(ReplaceString("s_", ErrorWaveName, "w_", 0,1)))
	else
	
	endif
	if(!WaveExists(TempdX))
		Duplicate/Free TempE, tempdX
		tempdX = 0
	endif

	if(!WaveExists(TempY) && !WaveExists(TempX))
		abort
	endif
	variable HaveErrors=0
	if(WaveExists(TempE))
		HaveErrors=1
	endif

	if(strlen(NewFileOutputName)==0)
		abort "Create output file name first, please"
	endif
	variable refnum
	string FinalOutputName, oldNote
	
	
	if(ExportASCII)			//this is old ASCII method...
		//Check for existing file and manage on our own...
		FinalOutputName=NewFileOutputName
		if(strlen(OutputNameExtension)>0)
			FinalOutputName+="."+OutputNameExtension
		endif
	
		Open/Z=1 /R/P=IR2E_ExportPath refnum as FinalOutputName
		if(V_Flag==0)
			DoAlert 1, "The file with this name: "+FinalOutputName+ " in this location already exists, overwrite?"
			if(V_Flag!=1)
				abort
			endif
			close/A
			//user wants to delete the file
			OpenNotebook/V=0/P=IR2E_ExportPath/N=JunkNbk  FinalOutputName
			DoWindow/D /K JunkNbk
		endif
			close/A
		Duplicate TempY, NoteTempY
		string OldNoteT=note(TempY)
		note/K NoteTempY
		note NoteTempY, OldNoteT+"Exported="+date()+" "+time()+";"
		make/T/O WaveNoteWave
		if (AttachWaveNote)
			IN2G_PasteWnoteToWave("NoteTempY", WaveNoteWave,HeaderSeparator)
			Save/G/M="\r\n"/P=IR2E_ExportPath WaveNoteWave as FinalOutputName
		endif
		if( UseIndra2Data || UseQRSdata)	//scattering data
			//lower precision if needed
			Duplicate/O TempX,Qvector_A
			Duplicate/O TempY,Intensity
			if(HaveErrors)
				Duplicate/O TempE, Uncertainty
			endif
			if(reduceOutputPrecision)
				Redimension/S Qvector_A,Intensity
				if(HaveErrors)
					Redimension/S Uncertainty
				endif
			endif
			if(HaveErrors)
				Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath Qvector_A,Intensity,Uncertainty as FinalOutputName			
			else
				Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath Qvector_A,Intensity as FinalOutputName		
			endif
			KillWaves/Z WaveNoteWave, NoteTempY, Qvector_A,Intensity,Uncertainty
		else		//results or other, no idea what x, y, e is... 
			//lower precision if needed
			Duplicate/O TempX,Xdata
			Duplicate/O TempY,Ydata
			if(HaveErrors)
				Duplicate/O TempE, Uncertainty
			endif
			if(reduceOutputPrecision)
				Redimension/S Xdata,Ydata
				if(HaveErrors)
					Redimension/S Uncertainty
				endif
			endif
			if(HaveErrors)
				Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath Xdata,Ydata,Uncertainty as FinalOutputName	
			else
				Save/A=2/G/W/M="\r\n"/P=IR2E_ExportPath Xdata,Ydata as FinalOutputName		
			endif
			KillWaves/Z WaveNoteWave, NoteTempY, Xdata,Ydata,Uncertainty	
		endif
	endif

	if(ExportGSASxye)			//this is GSAS-II xye file...
		//Check for existing file and manage on our own...
		FinalOutputName=NewFileOutputName
		if(strlen(OutputNameExtension)>0)
			FinalOutputName+="."+OutputNameExtension
		endif
	
		Open/Z=1 /R/P=IR2E_ExportPath refnum as FinalOutputName
		if(V_Flag==0)
			DoAlert 1, "The file with this name: "+FinalOutputName+ " in this location already exists, overwrite?"
			if(V_Flag!=1)
				abort
			endif
			close/A
			//user wants to delete the file
			OpenNotebook/V=0/P=IR2E_ExportPath/N=JunkNbk  FinalOutputName
			DoWindow/D /K JunkNbk
		endif
		close/A
		Duplicate TempY, NoteTempY
		string OldNoteT1=note(TempY)
		note/K NoteTempY
		note NoteTempY, OldNoteT1+"Exported="+date()+" "+time()+";"
		variable wvlgth = NumberByKey("Nika_Wavelength", OldNoteT1 , "=", ";")
		if(numtype(wvlgth)!=0)
			wvlgth = NumberByKey("Wavelength", OldNoteT1 , "=", ";")
			if(numtype(wvlgth)!=0)
				Prompt wvlgth, "Wavelength not found, please, provide"
				DoPrompt "Provide wavelength is A", wvlgth
				if (V_Flag || numtype(wvlgth)!=0 || wvlgth<0.01)
					return -1								// User canceled
				endif	
			endif
		endif
		//convert q or d into two theta as needed... 
		Duplicate/Free tempX, TempXCOnverted 
		if(StringMatch(QWavename, "q_*") || StringMatch(QWavename, "'q_*"))		//q wave
			TempXCOnverted = 2 * 180/pi * asin(TempX * wvlgth /(4*pi))		
		elseif(StringMatch(QWavename, "d_*") || StringMatch(QWavename, "'d_*"))		//d wave
			TempXCOnverted = 2 * 180/pi * (wvlgth / (2*TempX))
		else		//Two theta qweve nothing needed...

		endif
		
		make/T/O WaveNoteWave
		if (1)
			IN2G_PasteWnoteToWave("NoteTempY",WaveNoteWave ,HeaderSeparator)
			InsertPoints 0, 2, WaveNoteWave
			InsertPoints numpnts(WaveNoteWave), 2, WaveNoteWave
			WaveNoteWave[0] = "/*"
			WaveNoteWave[1] = HeaderSeparator+"wavelength = "+num2str(wvlgth)
			WaveNoteWave[numpnts(WaveNoteWave)-2] = "# 2Theta  Intensity  Error"	
			WaveNoteWave[numpnts(WaveNoteWave)-1] = "*/"	
			Save/G/M="\r\n"/P=IR2E_ExportPath WaveNoteWave as FinalOutputName
		endif
		if(HaveErrors)
			Save/A=2/G/M="\r\n"/P=IR2E_ExportPath TempXCOnverted,TempY,TempE as FinalOutputName		
		else
			Save/A=2/G/M="\r\n"/P=IR2E_ExportPath TempXCOnverted,TempY as FinalOutputName		
		endif
		KillWaves/Z WaveNoteWave, NoteTempY
	endif

	variable SlitLength
	
	if(ExportCanSASNexus)			//export Nexus... now assume this is data, not model results. 
		if(UseIndra2Data || UseQRSdata)
			FinalOutputName=NewFileOutputName
			if(strlen(OutputNameExtension)>0)
				FinalOutputName+="."+OutputNameExtension
			else
				OutputNameExtension= "hdf"
				FinalOutputName+="."+"hdf"
			endif
			oldNote=note(TempY)
			if(UseSMRData || stringMatch(NameOfWave(TempX),"*SMR*"))
				SlitLength = NumberByKey("SlitLength", oldNote, "=", ";")
			else
				SlitLength = 0
			endif
			PathInfo IR2E_ExportPath
			NEXUS_WriteNx1DCanSASdata(UserSampleName, S_path+FinalOutputName, TempY, TempE, TempX, TempdX, "", "Irena", oldNote, SlitLength)
		else		//results, not canSAS Nexus export available
			Abort "Cannot export Results into the canSAS Nexus files"
		endif
	endif	
	print "Saved data into : "+FinalOutputName
end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_LoadDataInTool()

	KillWIndow/Z TempExportGraph
 	KillWIndow/Z ExportNoteDisplay
 	KillWaves/Z TempX, TampY, TempE


	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport

	NVAR AttachWaveNote = root:Packages:IR2_UniversalDataExport:AttachWaveNote
	NVAR GraphData = root:Packages:IR2_UniversalDataExport:GraphData
	NVAR DisplayWaveNote = root:Packages:IR2_UniversalDataExport:DisplayWaveNote
	NVAR UseFolderNameForOutput = root:Packages:IR2_UniversalDataExport:UseFolderNameForOutput
	NVAR UseYWaveNameForOutput = root:Packages:IR2_UniversalDataExport:UseYWaveNameForOutput
	NVAR ExportCanSASNexus = root:Packages:IR2_UniversalDataExport:ExportCanSASNexus
	NVAR ExportASCII = root:Packages:IR2_UniversalDataExport:ExportASCII
	NVAR ExportMultipleCanSASFiles = root:Packages:IR2_UniversalDataExport:ExportMultipleCanSASFiles
	NVAR ExportSingleCanSASFile = root:Packages:IR2_UniversalDataExport:ExportSingleCanSASFile
	NVAR ExportGSASxye = root:Packages:IR2_UniversalDataExport:ExportGSASxye

	SVAR DataFolderName = root:Packages:IR2_UniversalDataExport:DataFolderName
	SVAR IntensityWaveName = root:Packages:IR2_UniversalDataExport:IntensityWaveName
	SVAR QWavename = root:Packages:IR2_UniversalDataExport:QWavename
	SVAR ErrorWaveName = root:Packages:IR2_UniversalDataExport:ErrorWaveName
	SVAR CurrentlyLoadedDataName = root:Packages:IR2_UniversalDataExport:CurrentlyLoadedDataName
	SVAR CurrentlySetOutputPath = root:Packages:IR2_UniversalDataExport:CurrentlySetOutputPath
	SVAR NewFileOutputName = root:Packages:IR2_UniversalDataExport:NewFileOutputName
	SVAR HeaderSeparator = root:Packages:IR2_UniversalDataExport:HeaderSeparator
	
	
	Wave/Z tempY=$(DataFolderName+possiblyquoteName(IntensityWaveName))
	Wave/Z tempX=$(DataFolderName+possiblyquoteName(QWavename))
	Wave/Z tempE=$(DataFolderName+possiblyquoteName(ErrorWaveName))
	
	if(!WaveExists(tempY) && !WaveExists(tempX))
		abort
	endif
	
	CurrentlyLoadedDataName = DataFolderName+IntensityWaveName

	if(GraphData)
		Display/K=1/W=(300,40,700,250)  TempY vs TempX as "Preview of export data"
		DoWindow/C TempExportGraph
		ModifyGraph log=1
		TextBox/C/N=text0  CurrentlyLoadedDataName
		IN2G_AutoAlignPanelAndGraph()
	endif
	string OldNote
	String nb = "ExportNoteDisplay"
	variable i
	if(DisplayWaveNote)
		OldNote = note(TempY) +"Exported="+date()+" "+time()+";"
		NewNotebook/K=1/N=$nb/F=0/V=1/K=0/W=(300,270,700,530) as "Data Notes"
		Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
		For(i=0;i<ItemsInList(OldNOte);i+=1)
			Notebook $nb text=HeaderSeparator+ stringFromList(i,OldNote)+"\r"
		endfor
			AutopositionWindow/M=0 /R=TempExportGraph ExportNoteDisplay 
	endif
	

	if(ExportASCII || ExportGSASxye ||(ExportCanSASNexus * !ExportSingleCanSASFile))
		NewFileOutputName = ""
		if(UseFolderNameForOutput)
			NewFileOutputName += IN2G_ReturnUserSampleName(DataFolderName)			
		endif
		if(UseFolderNameForOutput && UseYWaveNameForOutput)
			NewFileOutputName += "_"
		endif
		if(UseYWaveNameForOutput)
			NewFileOutputName += IN2G_RemoveExtraQuote(IntensityWaveName,1,1)
		endif	
	endif
	
	setDataFolder oldDF

end
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************

Function IR2E_ChangeExportPath()

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:IR2_UniversalDataExport
	SVAR CurrentlySetOutputPath=root:Packages:IR2_UniversalDataExport:CurrentlySetOutputPath
	NewPath/O/M="Select new output folder" IR2E_ExportPath
	PathInfo IR2E_ExportPath
	CurrentlySetOutputPath=S_Path

	setDataFolder oldDF

end

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************


Function IR2E_InitUnivDataExport()


	DFref oldDf= GetDataFolderDFR()

	setdatafolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S IR2_UniversalDataExport

	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;UseSMRData;UseUserDefinedData;"
	ListOfVariables+="AttachWaveNote;GraphData;DisplayWaveNote;UseFolderNameForOutput;UseYWaveNameForOutput;"
	ListOfVariables+="ExportMultipleDataSets;"
	ListOfVariables+="ExportCanSASNexus;ExportASCII;ExportGSASxye;"
	ListOfVariables+="ExportMultipleCanSASFiles;ExportSingleCanSASFile;reduceOutputPrecision;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	ListOfStrings+="CurrentlyLoadedDataName;CurrentlySetOutputPath;NewFileOutputName;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	


	make/O/T/N=0 ListOfAvailableData
	make/O/N=0 SelectionOfAvailableData
	
	SVAR/Z OutputNameExtension
	if(!SVAR_Exists(OutputNameExtension))
		string/G OutputNameExtension
		OutputNameExtension="dat"
	endif
	SVAR/Z HeaderSeparator
	if(!SVAR_Exists(HeaderSeparator))
		string/G HeaderSeparator
		HeaderSeparator="#   "
	endif
	//Ouptu path
	PathInfo IR2E_ExportPath
	if(!V_Flag)
		PathInfo Igor
		NewPath/Q IR2E_ExportPath S_Path
	endif
	PathInfo IR2E_ExportPath
	SVAR CurrentlySetOutputPath
	CurrentlySetOutputPath=S_Path
	
	SVAR NewFileOutputName
	NewFileOutputName=""
	SVAR CurrentlyLoadedDataName
	CurrentlyLoadedDataName = ""
	SVAR DataFolderName
	DataFolderName=""
	SVAR IntensityWaveName
	IntensityWaveName=""
	SVAR QWavename
	QWavename=""
	SVAR ErrorWaveName
	ErrorWaveName=""
	
	NVAR UseFolderNameForOutput
	NVAR UseYWaveNameForOutput
	if(UseFolderNameForOutput+UseYWaveNameForOutput !=1)
		UseFolderNameForOutput = 1
		UseYWaveNameForOutput = 0
	endif
		
	NVAR ExportASCII
	NVAR ExportCanSASNexus
	NVAR ExportGSASxye
	if(ExportASCII + ExportCanSASNexus + ExportGSASxye !=1)
		ExportASCII = 1
		ExportCanSASNexus= 0
		ExportGSASxye = 0
	endif

	setDataFolder OldDf

end

//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
//*******************************************************************************************************************************
