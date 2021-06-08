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
Local Enum $idSave, $idLog, $idStart, $idStop
#EndRegion ### VARIABLES ###

#Region ### START Koda GUI section ### Form=forms\fautoitpdffolderprint.kxf
$fAutoItPDFFolderPrint = GUICreate("AutoIt-PDFFolderPrint", 615, 549, -1, -1, $WS_SYSMENU)
GUISetOnEvent($GUI_EVENT_CLOSE, "fAutoItPDFFolderPrintClose")
$ilToolBar = _GUIImageList_Create(16, 16, 5)
_GUIImageList_AddIcon($ilToolBar, "icons\save_close.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\raw_access_logs.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\file_start_workflow.ico", 0, True)
_GUIImageList_AddIcon($ilToolBar, "icons\stop.ico", 0, True)
$gSoftware = GUICtrlCreateGroup("Software", 8, 96, 593, 129)
GUICtrlCreateLabel("Predefined", 32, 123, 55, 17)
$cPredefined = GUICtrlCreateCombo("", 120, 120, 377, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Custom|Foxit")
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
_GUICtrlToolbar_SetImageList($tbMain, $ilToolBar)
_GUICtrlToolbar_AddButton($tbMain, $idSave, 0, 0) ; __SaveIni()
_GUICtrlToolbar_AddButton($tbMain, $idLog, 1, 0) ; GUISetState(@SW_SHOW, $fLogs)
_GUICtrlToolbar_AddButton($tbMain, $idStart, 2, 0) ; Set $bRunning = true
_GUICtrlToolbar_AddButton($tbMain, $idStop, 3, 0) ; Set $bRunning = false
$gLog = GUICtrlCreateGroup("Log", 8, 32, 593, 57)
$cbLog = GUICtrlCreateCheckbox("Save log", 24, 56, 561, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
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
		_GUICtrlStatusBar_SetText($sbMain, "Running: " & GUICtrlRead($iFolder))
		If $aFiles <> -1 Then
			While $bRunning
				$sPdf = FileFindNextFile($aFiles)
				If @error Then ExitLoop
				_GUICtrlStatusBar_SetText($sbMain, "Running: " & GUICtrlRead($iFolder) & "\" & $sPdf)
				RunWait(GUICtrlRead($iPath) & ' ' & GUICtrlRead($iArguments) & ' "' & GUICtrlRead($iFolder) & "\" & $sPdf & '"')
				FileDelete(GUICtrlRead($iFolder) & "\" & $sPdf)
			WEnd
		EndIf
	EndIf

	Sleep(100)
WEnd

Func __GetExtension($sFilePath)
	__Log("__GetExtension(" & $sFilePath & ")")
	Local $sDrive, $sDir, $sFileName, $sExtension
	_PathSplit($sFilePath, $sDrive, $sDir, $sFileName, $sExtension)
	Return $sExtension
EndFunc   ;==>__GetExtension
Func __LoadIni()
	__Log("__LoadIni()")
	GUICtrlSetState($cbLog, IniRead($sPathIni, "SETTINGS", "DIRECTORY", $GUI_UNCHECKED))
	GUICtrlSetData($iFolder, IniRead($sPathIni, "PDF_FOLDER", "Directory", @ScriptDir))
	GUICtrlSetData($cPredefined, IniRead($sPathIni, "SOFTWARE", "Predefined", "Custom"))
	GUICtrlSetData($iPath, IniRead($sPathIni, "SOFTWARE", "Path", ""))
	GUICtrlSetData($iArguments, IniRead($sPathIni, "SOFTWARE", "Arguments", ""))
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
;~ 	TODO: Enable $idSave & if $iFolder -> Tree
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
Func __SaveIni()
	__Log("__SaveIni()")
	IniWrite($sPathIni, "SETTINGS", "Log", GUICtrlRead($cbLog))
	IniWrite($sPathIni, "PDF_FOLDER", "Directory", GUICtrlRead($iFolder))
	IniWrite($sPathIni, "SOFTWARE", "Predefined", GUICtrlRead($cPredefined))
	IniWrite($sPathIni, "SOFTWARE", "Path", GUICtrlRead($iPath))
	IniWrite($sPathIni, "SOFTWARE", "Arguments", GUICtrlRead($iArguments))
	$bChange = False
EndFunc   ;==>__SaveIni

Func cPredefinedChange()
	__Log("cPredefinedChange() [" & GUICtrlRead($cPredefined) & "]")
	Switch GUICtrlRead($cPredefined)
		Case "Custom"
			GUICtrlSetData($iPath, "")
			GUICtrlSetData($iArguments, "")
		Case "Foxit"
			GUICtrlSetData($iPath, @ProgramFilesDir & "\Foxit software\Foxit Reader\Foxit Reader.exe")
			GUICtrlSetData($iArguments, "/p")
	EndSwitch
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
