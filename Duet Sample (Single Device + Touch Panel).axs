//**********************************************************
//
//       AMX Resource Management Suite (4.1.13)
//
//**********************************************************
PROGRAM_NAME='Duet Sample (Single Device + Touch Panel)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

dvTP1               =  10001:1:0  // Touch Panel
dvTP1_RMS           =  10001:7:0  // RMS Touch Panels (Device Port for RMS TP pages)

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)
vdvRMSGui           =  41002:1:0  // RMS User Interface VDV     (Duet Module)

dvVideoProjector    =  5001:23:0  // Video Projector            (Physical Device)
vdvVideoProjector   =  41116:1:0  // Duet Video Projector       (Duet Module)


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// define the main starting touch panel page name
CHAR mainPanelPage[] = 'rmsMainPage';

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// RMS Touch Panel Array
VOLATILE DEV dvRMSTP[] =
{
   dvTP1_RMS
}

// RMS Touch Panel Array -
//  Base Device for System Keyboard handling
VOLATILE DEV dvRMSTP_Base[] =
{
   dvTP1
}

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

// Include the RMS API constants & helper functions
// only if you need to interface/interact directly
// with the RMS client API.
//#INCLUDE 'RmsApi';

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


(*************************)
(*  DUET DEVICE Modules  *)
(*************************)

// Video Projector Device (Duet Module)
#WARN 'Include your Duet device module here'
//DEFINE_MODULE 'MyVideoProjectorDuetModule_dr1_0_0' mdlVideoProjectorMod(vdvVideoProjector,dvVideoProjector);


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


//
// AMX Touch Panel Monitor
//
//  - include a touch panel monitoring module instance for each
//    touch panel device you wish to monitor.
//
DEFINE_MODULE 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitorMod(vdvRMS,dvTP1);


(******************************)
(*  RMS Duet Device Monitors  *)
(******************************)

//
// Duet device monitoring modules
//
// - a RMS Duet device monitoring module is required for each Duet device
//   you wish for RMS to register and monitor.  These Duet monitoring
//   modules include default implementations for monitored parameters,
//   control methods, and metadata properties.
//

// Video Projector RMS Monitor
DEFINE_MODULE 'RmsDuetVideoProjectorMonitor' mdlRmsVideoProjectorMonitorMod(vdvRMS, vdvVideoProjector, dvVideoProjector);

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

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


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
