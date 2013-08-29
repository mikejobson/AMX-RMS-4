'----------------------------------------------------------------
'////////////////////////////////////////////////////////////////
'----------------------------------------------------------------
'
'                 ~ AMX WebUpdate Launch Script ~
'
'
'                                         Copyright © 2007. AMX
'                                         All rights reserved.
'----------------------------------------------------------------
'////////////////////////////////////////////////////////////////
'----------------------------------------------------------------

'---------------------------------------------------------------------
'global error handler
On Error Resume Next


'---------------------------------------------------------------------
'declare program constants.
Const vbCritical    = 16
Const vbQuestion    = 32
Const vbExclamation = 48
Const vbInformation = 64


'---------------------------------------------------------------------
'declare variables.
Dim WshArguments
Dim WshShell
Dim ProgramRegistryPath
Dim ProgramName
Dim ProgramVersion
Dim ProgramWebUpdateID
Dim lReturn
Dim lLoop


'---------------------------------------------------------------------
'//create script arguments object.
Set WshArguments = WScript.Arguments
For lLoop = 0 to WshArguments.Count - 1
   If (lLoop = 0) Then
   	'//set program registry path 
   	ProgramRegistryPath = WshArguments(lLoop)
   	
   	'// SAMPLE of argument 0 : "HKLM\Software\AMX Corp.\RMS SDK\"
   Else
     '//error encountered; invalid command line arguments.
     MsgBox "Attention, invalid command line argument: " & vbCrLf & _
            WshArguments(lLoop), vbCritical + vbOKOnly, "AMX WebUpdate"
	End If
Next


'---------------------------------------------------------------------
'//ensure a registry path was provided.
If (ProgramRegistryPath = "") Then
	
	'//no registry path was provided, so we will simply display an 'About' dialog
	MsgBox "AMX WebUpdate Launch Script" & vbCrLf & _
	       "" & vbCrLf & _
	       "" & vbCrLf & _
	       "AMX Corporation" & vbCrLf & _
	       "Copyright © 2000-2004" & vbCrLf & _
	       "All rights reserved." , vbInformation , "AMX WebUpdate : About"

Else

	'//create registry access object.
	Set WshShell = WScript.CreateObject("WScript.Shell")
	
	'//read product registry settings for webupdate command line.
	ProgramName        = WshShell.RegRead(ProgramRegistryPath & "Name")
	ProgramVersion     = WshShell.RegRead(ProgramRegistryPath & "Version")
	ProgramWebUpdateID = WshShell.RegRead(ProgramRegistryPath & "WebUpdateID")
	
	'as of 1.3 (roughly august 2008, webupdate will be in it's own qualified directory
	WebUpdateEXE = WshShell.RegRead("HKLM\Software\AMX Corp.\WebUpdate\Install\ProgramLocation")
	
	'long filenames no good in shell run, so quote them
	WebUpdateEXE = """" & WebUpdateEXE & """"
	
	'//determine if program info from registry is valid.
	If (ProgramName <> "") Then	
	
	  If (CLng(ProgramWebUpdateID) = 0) Then  	
	     '//error encountered; web update id is invalid.
	     MsgBox "Attention, this application does not have a Web Update ID associated to it." & vbCrLf & _
	            "Unable to perform Web Update.", vbCritical + vbOKOnly, ProgramName
	  Else
	     '//re-format the version string  
	     ProgramVersion = Replace(ProgramVersion, ".", ",")
	
	     '//launch web update with proper command line identifying the product.
	     lReturn = WshShell.Run(WebUpdateEXE & "  -prod[" & ProgramWebUpdateID & "] -vers[" & ProgramVersion & "]", 1, False)
	
		  If (lReturn <> "0") Then	  	
	        '//notify user, the webupdate program is not avaiable.
	        MsgBox "The AMX Web Update application could not be found." & _
	                vbCrLf & vbCrLf & "It is available on www.amx.com under ""Downloadable Applications"".", _
	                vbCritical, ProgramName
		  End If	  
	  End If
	Else
		'//error encountered; could not access program information from registry.
		MsgBox "WebUpdate Error: Unable to get program details.", vbCritical , "AMX WebUpdate"
	End If
End If
'---------------------------------------------------------------------
