//**********************************************************
//
//       AMX Resource Management Suite (4.1.5)
//
//**********************************************************
PROGRAM_NAME='Duet Sample (Single Device)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)

dvVideoProjector    =  5001:23:0  // Video Projector            (Physical Device)
vdvVideoProjector   =  41116:1:0  // Duet Video Projector       (Duet Module)


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

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
