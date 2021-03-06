#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         kevingrillet

 Script Function:
	Automatically print pdf in folder

	https://www.autoitscript.fr/forum/viewtopic.php?f=3&t=9835

#ce ----------------------------------------------------------------------------

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icons\file_extension_pdf.ico
#AutoIt3Wrapper_Outfile=AutoIt-PDFFolderPrint.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Automatically print pdf in folder
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Copyright (C) 2021
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Compiler Date|%date%
#AutoIt3Wrapper_Res_Field=Compiler Heure|%time%
#AutoIt3Wrapper_Res_Field=Compiler Version|AutoIt v%AutoItVer%
#AutoIt3Wrapper_Res_Field=Author|kevingrillet
#AutoIt3Wrapper_Res_Field=Github|https://github.com/kevingrillet/AutoIt-Launcher
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#Region ### INCLUDES ###
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiImageList.au3>
#include <GuiStatusBar.au3>
#include <GuiToolbar.au3>
#include <GuiToolTip.au3>
#include <GuiTreeView.au3>
#include <ImageListConstants.au3>
#include <StaticConstants.au3>
#include <ToolbarConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#EndRegion ### INCLUDES ###

#Region ### OPT ###
Opt("GUICloseOnESC", 1) ;1=ESC  closes, 0=ESC won't close
Opt("GUIOnEventMode", 1) ;0=disabled, 1=OnEvent mode enabled
Opt("TrayIconHide", 0) ;0=show, 1=hide tray icon
#EndRegion ### OPT ###

#Region ### VARIABLES ###
Local $bChange = False
Local $bRunning = False
Local $sPathIni = @ScriptDir & "\AutoIt-PDFFolderPrint.ini"
Local $sPathLog = @ScriptDir & "\AutoIt-PDFFolderPrint.log"
Local $aFiles, $sPathPdf
Local $iItem ; Command identifier of the button associated with the notification.
Local Enum $idSave = 1000, $idLog, $idStart, $idStop
#EndRegion ### VARIABLES ###

#Region ### START Koda GUI section ### Form=forms\fautoitpdffolderprint.kxf
$fAutoItPDFFolderPrint = GUICreate("AutoIt-PDFFolderPrint", 615, 549, -1, -1, $WS_SYSMENU, $WS_EX_ACCEPTFILES)
GUISetOnEvent($GUI_EVENT_CLOSE, "fAutoItPDFFolderPrintClose")
$ilToolBar = _GUIImageList_Create(16, 16, 5)
_GUIImageList_AddIcon($ilToolBar, "icons\save_close.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\raw_access_logs.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\file_start_workflow.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\stop.ico", 0, True)
$gSoftware = GUICtrlCreateGroup("Software", 8, 96, 593, 129)
GUICtrlCreateLabel("Predefined", 32, 123, 55, 17)
$cPredefined = GUICtrlCreateCombo("", 120, 120, 377, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Custom|Acrobat Reader DC|Foxit Reader|Sumatra PDF")
GUICtrlSetOnEvent(-1, "cPredefinedChange")
GUICtrlCreateLabel("Path", 32, 155, 26, 17)
$iPath = GUICtrlCreateInput("", 120, 152, 377, 21)
GUICtrlSetOnEvent(-1, "__OnChange")
GUISetOnEvent($GUI_EVENT_DROPPED, "__OnDrop")
$bPath = GUICtrlCreateButton("Open", 512, 151, 75, 23)
GUICtrlSetOnEvent(-1, "__OnClick")
GUICtrlCreateLabel("Arguments", 32, 187, 54, 17)
$iArguments = GUICtrlCreateInput("", 120, 184, 377, 21)
GUICtrlSetOnEvent(-1, "__OnChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Folder", 8, 232, 593, 257)
GUICtrlCreateLabel("Folder", 32, 259, 33, 17)
$iFolder = GUICtrlCreateInput("", 120, 256, 377, 21)
GUICtrlSetOnEvent(-1, "__OnChange")
GUISetOnEvent($GUI_EVENT_DROPPED, "__OnDrop")
$bFolder = GUICtrlCreateButton("Open", 512, 255, 75, 23)
GUICtrlSetOnEvent(-1, "__OnClick")
$tvFolder = GUICtrlCreateTreeView(24, 288, 561, 185)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$sbMain = _GUICtrlStatusBar_Create($fAutoItPDFFolderPrint)
_GUICtrlStatusBar_SetSimple($sbMain)
_GUICtrlStatusBar_SetText($sbMain, "")
$tbMain = _GUICtrlToolbar_Create($fAutoItPDFFolderPrint, 0)
$ttMain = _GUIToolTip_Create($tbMain)
_GUICtrlToolbar_SetToolTips($tbMain, $ttMain)
_GUICtrlToolbar_SetImageList($tbMain, $ilToolBar)
_GUICtrlToolbar_AddButton($tbMain, $idSave, 0, 0) ; __SaveIni()
_GUICtrlToolbar_EnableButton($tbMain, $idSave, False)
_GUICtrlToolbar_AddButton($tbMain, $idLog, 1, 0) ; GUISetState(@SW_SHOW, $fLogs)
_GUICtrlToolbar_AddButton($tbMain, $idStart, 2, 0) ; Set $bRunning = true
_GUICtrlToolbar_AddButton($tbMain, $idStop, 3, 0) ; Set $bRunning = false
_GUICtrlToolbar_EnableButton($tbMain, $idStop, False)
$gSettings = GUICtrlCreateGroup("Settings", 8, 32, 593, 57)
$cbLog = GUICtrlCreateCheckbox("Save log", 24, 56, 250, 17)
GUICtrlSetOnEvent(-1, "__OnChange")
$cbPerpetual = GUICtrlCreateCheckbox("Perpetual run", 300, 56, 250, 17)
GUICtrlSetOnEvent(-1, "__OnChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=forms\flogs.kxf
$fLogs = GUICreate("Logs", 615, 433, 192, 147, $WS_SYSMENU)
GUISetOnEvent($GUI_EVENT_CLOSE, "fLogsClose")
$eLogs = GUICtrlCreateEdit("", 8, 8, 593, 385)
;~ GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

__LoadIni()
While 1
	If $bRunning Then
		$aFiles = FileFindFirstFile(GUICtrlRead($iFolder) & "\*.pdf")
		If $aFiles <> -1 Then
			_GUICtrlStatusBar_SetText($sbMain, "Running: " & GUICtrlRead($iFolder))
			While $bRunning
				$sPdf = FileFindNextFile($aFiles)
				If @error Then ExitLoop
				_GUICtrlStatusBar_SetText($sbMain, "Running: " & GUICtrlRead($iFolder) & "\" & $sPdf)
				__Log("RunWait: " & GUICtrlRead($iPath) & ' ' & GUICtrlRead($iArguments) & ' "' & GUICtrlRead($iFolder) & "\" & $sPdf & '"')
				RunWait(GUICtrlRead($iPath) & ' ' & GUICtrlRead($iArguments) & ' "' & GUICtrlRead($iFolder) & "\" & $sPdf & '"')
				FileDelete(GUICtrlRead($iFolder) & "\" & $sPdf)
			WEnd
		EndIf
		If GUICtrlRead($cbLog) = $GUI_CHECKED Then
			_GUICtrlStatusBar_SetText($sbMain, "Perpetual run: " & GUICtrlRead($iFolder))
		Else
			_GUICtrlStatusBar_SetText($sbMain, "Finished: " & GUICtrlRead($iFolder))
			_GUICtrlToolbar_ClickButton($tbMain, $idStop)
		EndIf
	EndIf

	__RefreshTV()
	Sleep(60 * 1000) ; 60s
WEnd

Func __GetExtension($sFilePath)
	__Log("__GetExtension(" & $sFilePath & ")")
	Local $sDrive, $sDir, $sFileName, $sExtension
	_PathSplit($sFilePath, $sDrive, $sDir, $sFileName, $sExtension)
	Return $sExtension
EndFunc   ;==>__GetExtension
;~ https://www.autoitscript.com/forum/topic/132048-filling-a-treeview-with-folders-and-files/?do=findComment&comment=919808
Func __ListFiles_ToTreeView($sSourceFolder, $hItem)

	Local $sFile

	; Force a trailing \
	If StringRight($sSourceFolder, 1) <> "\" Then $sSourceFolder &= "\"

	; Start the search
	Local $hSearch = FileFindFirstFile($sSourceFolder & "*.*")
	; If no files found then return
	If $hSearch = -1 Then Return ; This is where we break the recursive loop <<<<<<<<<<<<<<<<<<<<<<<<<<

	; Now run through the contents of the folder
	While 1
		; Get next match
		$sFile = FileFindNextFile($hSearch)
		; If no more files then close search handle and return
		If @error Then ExitLoop ; This is where we break the recursive loop <<<<<<<<<<<<<<<<<<<<<<<<<<

		; Check if a folder
		If @extended Then
			; If so then call the function recursively
			__ListFiles_ToTreeView($sSourceFolder & $sFile, _GUICtrlTreeView_AddChild($tvFolder, $hItem, $sFile))
		Else
			; If a file than write path and name
			_GUICtrlTreeView_AddChild($tvFolder, $hItem, $sFile)
		EndIf
	WEnd

	; Close search handle
	FileClose($hSearch)
EndFunc   ;==>__ListFiles_ToTreeView
Func __LoadIni()
	__Log("__LoadIni()")
	GUICtrlSetState($cbLog, IniRead($sPathIni, "SETTINGS", "Log", $GUI_UNCHECKED))
	GUICtrlSetState($cbPerpetual, IniRead($sPathIni, "SETTINGS", "Perpetual", $GUI_UNCHECKED))
	GUICtrlSetData($iFolder, IniRead($sPathIni, "PDF_FOLDER", "Directory", @ScriptDir))
	GUICtrlSetData($cPredefined, IniRead($sPathIni, "SOFTWARE", "Predefined", "Custom"))
	GUICtrlSetData($iPath, IniRead($sPathIni, "SOFTWARE", "Path", ""))
	GUICtrlSetData($iArguments, IniRead($sPathIni, "SOFTWARE", "Arguments", ""))
	__RefreshTV()
EndFunc   ;==>__LoadIni
Func __Log($sToLog)
	ConsoleWrite(_NowCalc() & " : " & $sToLog & @CRLF)
	_GUICtrlEdit_InsertText($eLogs, _NowCalc() & " : " & $sToLog & @CRLF)
	If GUICtrlRead($cbLog) = $GUI_CHECKED Then
		_FileWriteLog($sPathLog, $sToLog & @CRLF)
	EndIf
EndFunc   ;==>__Log
Func __OnChange()
	__Log("__OnChange()")
	$bChange = True
	__RefreshTV()
EndFunc   ;==>__OnChange
Func __OnClick()
;~ 	__Log("__OnClick(" & @GUI_CtrlId & ")")
	Switch @GUI_CtrlId
		Case $bPath
			__Log("__OnClick($bPath)")
			Local $sFileOpenDialog = FileOpenDialog("Open File", @ScriptDir, "Exe (*.exe)", $FD_FILEMUSTEXIST)
			If @error Then
				FileChangeDir(@ScriptDir)
			Else
				FileChangeDir(@ScriptDir)
				GUICtrlSetData($iPath, $sFileOpenDialog)
			EndIf
		Case $bFolder
			__Log("__OnClick($bFolder)")
			Local $sFileSelectFolder = FileSelectFolder("Open Folder", "", 0, @ScriptDir)
			If @error Then
				FileChangeDir(@ScriptDir)
			Else
				FileChangeDir(@ScriptDir)
				GUICtrlSetData($iFolder, $sFileSelectFolder)
				__RefreshTV()
			EndIf
	EndSwitch
EndFunc   ;==>__OnClick
Func __OnDrop()
	If @GUI_DragId = -1 Then
		__OnChange()
		Local $sPath = @GUI_DragFile
		Local $sExtension = __GetExtension($sPath)
		If @GUI_DropId = $iPath Then
			If $sExtension = ".exe" Then
				GUICtrlSetData($iPath, $sPath)
			Else
				MsgBox($MB_ICONWARNING, "Wrong file extension", "The expected file extension is .exe but your file is " & $sExtension)
				GUICtrlSetData($iPath, "")
			EndIf
		ElseIf @GUI_DropId = $iFolder Then
			If $sExtension = "" Then
				GUICtrlSetData($iFolder, $sPath)
			Else
				MsgBox($MB_ICONWARNING, "Wrong folder", "Folder waited, but your file is a: " & $sExtension)
				GUICtrlSetData($iFolder, "")
			EndIf
		EndIf
	EndIf
EndFunc   ;==>__OnDrop
Func __RefreshTV()
	__Log("__RefreshTV()")
	_GUICtrlToolbar_EnableButton($tbMain, $idSave, $bChange)
	_GUICtrlTreeView_BeginUpdate($tvFolder)
	_GUICtrlTreeView_DeleteAll($tvFolder)
	If FileExists(GUICtrlRead($iFolder)) = 1 Then
		__ListFiles_ToTreeView(GUICtrlRead($iFolder), 0)
	EndIf
	_GUICtrlTreeView_EndUpdate($tvFolder)
EndFunc   ;==>__RefreshTV
Func __SaveIni()
	__Log("__SaveIni()")
	IniWrite($sPathIni, "SETTINGS", "Log", GUICtrlRead($cbLog))
	IniWrite($sPathIni, "SETTINGS", "Perpetual", GUICtrlRead($cbPerpetual))
	IniWrite($sPathIni, "PDF_FOLDER", "Directory", GUICtrlRead($iFolder))
	IniWrite($sPathIni, "SOFTWARE", "Predefined", GUICtrlRead($cPredefined))
	IniWrite($sPathIni, "SOFTWARE", "Path", GUICtrlRead($iPath))
	IniWrite($sPathIni, "SOFTWARE", "Arguments", GUICtrlRead($iArguments))
	$bChange = False
	_GUICtrlToolbar_EnableButton($tbMain, $idSave, $bChange)
EndFunc   ;==>__SaveIni

Func _WM_NOTIFY($hWndGUI, $iMsgID, $wParam, $lParam)
	#forceref $hWndGUI, $iMsgID, $wParam
	Local $tNMHDR, $hWndFrom, $iCode, $iNew, $iFlags, $iOld
	Local $tNMTBHOTITEM

;~ 	Click
	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $tbMain
			Switch $iCode
				Case $NM_LDOWN
;~ 					__Log("$NM_LDOWN: Clicked Item: " & $iItem & " at index: " & _GUICtrlToolbar_CommandToIndex($tbMain, $iItem))
					Switch $iItem
						Case $idSave
							__Log("$NM_LDOWN: $idSave")
							If _GUICtrlToolbar_IsButtonEnabled($tbMain, $idSave) Then
								__SaveIni()
							EndIf
						Case $idLog
							__Log("$NM_LDOWN: $idLog")
							GUISetState(@SW_SHOW, $fLogs)
						Case $idStart
							__Log("$NM_LDOWN: $idStart")
							$bRunning = True
							_GUICtrlToolbar_EnableButton($tbMain, $idStop, True)
							_GUICtrlToolbar_EnableButton($tbMain, $idStart, False)
						Case $idStop
							__Log("$NM_LDOWN: $idStop")
							$bRunning = False
							_GUICtrlToolbar_EnableButton($tbMain, $idStop, False)
							_GUICtrlToolbar_EnableButton($tbMain, $idStart, True)
					EndSwitch

				Case $TBN_HOTITEMCHANGE
					$tNMTBHOTITEM = DllStructCreate($tagNMTBHOTITEM, $lParam)
					$iOld = DllStructGetData($tNMTBHOTITEM, "idOld")
					$iNew = DllStructGetData($tNMTBHOTITEM, "idNew")
					$iItem = $iNew
;~ 					$iFlags = DllStructGetData($tNMTBHOTITEM, "dwFlags")
;~ 					If BitAND($iFlags, $HICF_LEAVING) = $HICF_LEAVING Then
;~ 						__Log("$HICF_LEAVING: " & $iOld)
;~ 					Else
;~ 						Switch $iNew
;~ 							Case $idSave
;~ 								__Log("$TBN_HOTITEMCHANGE: $idSave")
;~ 							Case $idLog
;~ 								__Log("$TBN_HOTITEMCHANGE: $idLog")
;~ 							Case $idStart
;~ 								__Log("$TBN_HOTITEMCHANGE: $idStart")
;~ 							Case $idStop
;~ 								__Log("$TBN_HOTITEMCHANGE: $idStop")
;~ 						EndSwitch
;~ 					EndIf
			EndSwitch
	EndSwitch

;~ 	ToolTip
	$tInfo = DllStructCreate($tagNMTTDISPINFO, $lParam)
	$iCode = DllStructGetData($tInfo, "Code")
	If $iCode = $TTN_GETDISPINFOW Then
		$iID = DllStructGetData($tInfo, "IDFrom")
		Switch $iID
			Case $idSave
				DllStructSetData($tInfo, "aText", "Save")
			Case $idLog
				DllStructSetData($tInfo, "aText", "Log")
			Case $idStart
				DllStructSetData($tInfo, "aText", "Start")
			Case $idStop
				DllStructSetData($tInfo, "aText", "Stop")
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_NOTIFY

Func cPredefinedChange()
	__Log("cPredefinedChange() [" & GUICtrlRead($cPredefined) & "]")
	Switch GUICtrlRead($cPredefined)
		Case "Custom"
			GUICtrlSetData($iPath, "")
			GUICtrlSetData($iArguments, "")
		Case "Acrobat Reader DC"
			GUICtrlSetData($iPath, "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe")
			GUICtrlSetData($iArguments, "/p")
		Case "Foxit Reader"
			GUICtrlSetData($iPath, @ProgramFilesDir & "\Foxit software\Foxit Reader\FoxitReader.exe")
			GUICtrlSetData($iArguments, "/p")
		Case "Sumatra PDF"
			GUICtrlSetData($iPath, _PathFull("Local\SumatraPDF\SumatraPDF.exe", StringRegExpReplace(@AppDataDir, '\\[^\\]*$', '')))
			GUICtrlSetData($iArguments, "-print-to-default -exit-when-done")
	EndSwitch
	__OnChange()
EndFunc   ;==>cPredefinedChange
Func fAutoItPDFFolderPrintClose()
	__Log("fAutoItPDFFolderPrintClose()")
	If $bChange Then
		If MsgBox($MB_YESNO, "Save", "Save changes?") = $IDYES Then
			__SaveIni()
		EndIf
	EndIf
	Exit 1
EndFunc   ;==>fAutoItPDFFolderPrintClose
Func fLogsClose()
	__Log("fLogsClose()")
	GUISetState(@SW_HIDE, $fLogs)
EndFunc   ;==>fLogsClose
