//**********************************************************
//
//       AMX Resource Management Suite (4.1.5)
//
//**********************************************************
PROGRAM_NAME='Sample (System Modes)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


dvMaster            =      0:1:0  // Control Systems Master

dvTP1               =  10001:1:0  // Touch Panels (Not monitored in this sample)

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// if you wish to implement system modes, you must define
// a pipe character '|' separated list of elligible mode
// names and pass this string into the 'RmsSystemModeMonitor'
// module
CHAR SYSTEM_MODES[100]  = 'None|Presentation|Video Conference|Audio Conference';

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

// Include the RMS API constants & helper functions
#INCLUDE 'RmsApi';

(***********************************************************)
(*                MODULE CODE GOES BELOW                   *)
(***********************************************************)

//
// RMS Client - NetLinx Adapter Module
//
//  - This module includes the RMS client module
//    and enables communication via SEND_COMMAND,
//    SEND_STRINGS, CHANNELS, and LEVELS with the
//    RMS Client.
//
//  ATTENTION!
//
//  - The RMS NetLinx Adapter Module must be declared first
//    so that the RMS core sevices are loaded before any other
//    RMS application or device monitoring modules.
//
DEFINE_MODULE 'RmsNetLinxAdapter_dr4_0_0' mdlRMSNetLinx(vdvRMS);


// Including the RmsEventListener.AXI will listen for RMS
// events from the RMS virtual device interface (vdvRMS)
// and invoke callback methods to notify this program when
// these event occur.
//
// The following set of INCLUDE_RMS_EVENT_xxx compiler
// directives subscribe for the desired callback event
// and the callback methods for these events must exist
// in this program file.

// subscribe to system event notification callback methods
#DEFINE INCLUDE_RMS_EVENT_SYSTEM_MODE_CALLBACK;
#DEFINE INCLUDE_RMS_EVENT_SYSTEM_MODE_REQUEST_CALLBACK;

// include RmsEventListener (which also includes RMS API)
#INCLUDE 'RmsEventListener';

(*********************************)
(*  RMS NetLinx Device Monitors  *)
(*********************************)

//
// AMX Control System Master
//
// - include only one of these control system device monitoring modules.
//   this is intended to serve as an extension point for creating
//   system wide control methods and system level monitoring parameters.
//
DEFINE_MODULE 'RmsControlSystemMonitor' mdlRmsControlSystemMonitorMod(vdvRMS,dvMaster);

// to include the system mode parameter and system mode control method
// this module definition is required
DEFINE_MODULE 'RmsSystemModeMonitor' mdlRmsSystemModeMonitorMod(vdvRMS,dvMaster,SYSTEM_MODES);


(***********************************************************)
(* Name:  ChangeMySystemMode                               *)
(* Args:  modeName - mode name for the newly applied       *)
(*                   system operating mode                 *)
(***********************************************************)
DEFINE_FUNCTION ChangeMySystemMode(CHAR modeName[])
{
    SEND_STRING 0, '************************************************';
    SEND_STRING 0,"' ChangeMySystemMode(',modeName,') called        '";
    SEND_STRING 0, '************************************************';

    #WARN 'Implement your SYSTEM MODE CHANGE logic here!'

    // after performing the system mode change implementation logic,
    // we must let RMS know that the system mode state has been
    // changed.  We can do this using a RMS API function.
    RmsSystemSetMode(modeName);
}


(***********************************************************)
(* Name:  RmsEventSystemModeChanged                        *)
(* Args:  modeName - mode name for the newly applied       *)
(*                   system operating mode                 *)
(*                                                         *)
(* Desc:  This callback method is invoked by the           *)
(*        'RmsEventListener' include file to notify this   *)
(*        program when the system operating mode has       *)
(*        changed.                                         *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RmsEventSystemModeChanged(CHAR modeName[])
{
  //
  // (RMS SYSTEM MODE CHANGE NOTIFICATION)
  //
  // upon receiving the system mode change event
  // notification from the RMS client
  //
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' SYSTEM MODE CHANGED [',modeName,']'";
  SEND_STRING 0, '**************************************';
}

(***********************************************************)
(* Name:  RmsEventSystemModeChangeRequest                  *)
(* Args:  modeName - mode name for the requested           *)
(*                   system operating mode                 *)
(*                                                         *)
(* Desc:  This callback method is invoked by the           *)
(*        'RmsEventListener' include file to notify this   *)
(*        program when the system operating mode has       *)
(*        requested to be changed.                         *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RmsEventSystemModeChangeRequest(CHAR newMode[])
{
  //
  // (RMS SYSTEM MODE CHANGE REQUEST NOTIFICATION)
  //
  // upon receiving the system mode change request
  // event notification from the RMS client
  //
  SEND_STRING 0, '************************************************';
  SEND_STRING 0,"' RMS REQUESTING SYSTEM MODE CHANGE [',newMode,']'";
  SEND_STRING 0, '************************************************';

  // call your own local function to perform the system mode change
  ChangeMySystemMode(newMode);
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// set a default starting system mode
RmsSystemSetMode('None');

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


//
// Set the 'System Mode' to the 'Presentation' mode
//
BUTTON_EVENT[dvTP1, 1]
{
  PUSH:
  {
     // call the RMS utility method to set the new system mode
     ChangeMySystemMode('Presentation');
  }
}


//
// Set the 'System Mode' to the 'Video Conference' mode
//
BUTTON_EVENT[dvTP1, 2]
{
  PUSH:
  {
     // call the RMS utility method to set the new system mode
     ChangeMySystemMode('Video Conference');
  }
}

//
// Set the 'System Mode' to the 'None' mode
//
BUTTON_EVENT[dvTP1, 3]
{
  PUSH:
  {
     // call the RMS utility method to set the new system mode
     ChangeMySystemMode('None');
  }
}





(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
