//**********************************************************
//
//       AMX Resource Management Suite (4.1.5)
//
//**********************************************************

//
//
// This program uses system modes as a means to demonstrate
// how the RMS scheduling API can be used to execute tasks
// when event bookings start and end.
//

PROGRAM_NAME='NetLinx Sample (Scheduling)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

dvTP1               =  10001:1:0  // Touch Panels
dvTP2               =  10002:1:0  //  (must be port 1 for base device)

dvTP1_RMS           =  10001:7:0  // RMS Touch Panels (Device Port for RMS TP pages)
dvTP2_RMS           =  10002:7:0  //  (RMS uses port 7 by default)

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)
vdvRMSGui           =  41002:1:0  // RMS User Interface VDV     (Duet Module)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

CHAR BOOLEANS[2][5] = { 'FALSE', 'TRUE'};

CHAR MONITOR_DEBUG_NAME[] = 'RmsSchedulingMonitor';

// define the main starting touch panel page name
CHAR mainPanelPage[] = 'rmsMainPage';
// alternatively, the main page could be set to the scheduling
// page named: 'rmsSchedulingPage'
//CHAR mainPanelPage[] = 'rmsSchedulingPage';

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR SYSTEM_MODES[100]		= 'None|Presentation|Video Conference|Audio Conference';

CHAR DEFAULT_SYSTEM_MODE[20]	= 'None';

// RMS Touch Panel Array
VOLATILE DEV dvRMSTP[] =
{
   dvTP1_RMS,
   dvTP2_RMS
}

// RMS Touch Panel Array -
//  Base Device for System Keyboard handling
VOLATILE DEV dvRMSTP_Base[] =
{
   dvTP1,
   dvTP2
}

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

// subscribe to scheduling notification callback methods
#DEFINE INCLUDE_SCHEDULING_EVENT_ENDED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_EVENT_STARTED_CALLBACK

// Include the RMS API constants & helper functions
#INCLUDE 'RmsApi';

// Include the RMS Scheduling API
#INCLUDE 'RmsSchedulingApi';

// Include the RMS GUI API constants & helper functions
#INCLUDE 'RmsGuiApi';

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

//
// RMS GUI - User Interface Module
//
//  - This module is responsible for all the RMS
//    user interface application logic.  This
//    includes help requests, maintenance requests,
//    location hotlist, and server display messages.
//
DEFINE_MODULE 'RmsClientGui_dr4_0_0' mdlRMSGUI(vdvRMSGui,dvRMSTP,dvRMSTP_Base);

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

// to include the system power parameter and system power control methods
// this module definition is required
DEFINE_MODULE 'RmsSystemPowerMonitor' mdlRmsSystemPowerMonitorMod(vdvRMS,dvMaster);

// to include the system mode parameter and system mode control method
// this module definition is required
DEFINE_MODULE 'RmsSystemModeMonitor' mdlRmsSystemPowerMonitorMod(vdvRMS,dvMaster,SYSTEM_MODES);

//
// AMX Touch Panel Monitor
//
//  - include a touch panel monitoring module instance for each
//    touch panel device you wish to monitor.
//
DEFINE_MODULE 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitorMod_1(vdvRMS,dvTP1);
DEFINE_MODULE 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitorMod_2(vdvRMS,dvTP2);

(***********************************************************)
(* Name:  Debug                                            *)
(* Args:  data - message string to display.                *)
(*                                                         *)
(* Desc:  This is a convienance method to print debugging  *)
(*        and diagnostics information message to the       *)
(*        master's telnet console.  The message string     *)
(*        will be prepended with the RMS monitoring module *)
(*        name and source usage virutal device ID string   *)
(*        to help identify from which module instance the  *)
(*        message originated.                              *)
(***********************************************************)
DEFINE_FUNCTION Debug(CHAR data[])
{
  SEND_STRING 0, "'[',MONITOR_DEBUG_NAME,'-',RmsDevToString(dvMaster),'] ',data";
}

(***********************************************************)
(* Name:  RmsEventSchedulingEventStarted             *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* a booking event has started                             *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION RmsEventSchedulingEventStarted(CHAR bookingId[],
                                                    RmsEventBookingResponse eventBookingResponse)
{
  DEBUG("'RmsEventSchedulingEventStarted() called [',bookingId,']'");

	// When a booking event starts, put the system into Presentation
	ChangeMySystemMode('Presentation');
}

(***********************************************************)
(* Name:  RmsEventSchedulingEventEnded               *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* a booking event has ended                               *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION RmsEventSchedulingEventEnded(CHAR bookingId[],
                                                  RmsEventBookingResponse eventBookingResponse)
{
  DEBUG("'RmsEventSchedulingEventEnded() called [',bookingId,']'");

	// When a booking event ends, put the system into Audio Conference
	ChangeMySystemMode('Audio Conference');
}

(***********************************************************)
(* Name:  ChangeMySystemMode                               *)
(* Args:  modeName - mode name for the newly applied       *)
(*                   system operating mode                 *)
(***********************************************************)
DEFINE_FUNCTION ChangeMySystemMode(CHAR modeName[])
{
	DEBUG("'ChangeMySystemMode() called [',modeName,']'");

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
	DEBUG("'RmsEventSystemModeChanged() system mode changed [',modeName,']'");
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
	DEBUG("'RmsEventSystemModeChangeRequest() RMS requesting system mode change [',newMode,']'");

  // call your own local function to perform the system mode change
  ChangeMySystemMode(newMode);
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// set a default starting system mode
RmsSystemSetMode(DEFAULT_SYSTEM_MODE);

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

//
// When each touch panel comes online,
// set the starting/main page.
//
DATA_EVENT[dvRMSTP]
{
  ONLINE:
  {
    // display the main touch panel page
    SEND_COMMAND DATA.DEVICE, "'PAGE-',mainPanelPage";
  }
}

//
// When the GUI virtual device comes online,
// specify whether each panel is for internal
// or external use.
//
DATA_EVENT[vdvRMSGui]
{
  ONLINE:
  {
    // Designate touch panel for internal use
    RmsSetInternalPanel(dvTP1, dvTP1_RMS);

    // Alternatively, the touch panel can be designated for external use
    RmsSetExternalPanel(dvTP2, dvTP2_RMS);
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
