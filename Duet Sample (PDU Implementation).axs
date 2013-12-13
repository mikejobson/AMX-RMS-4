//**********************************************************
//
//       AMX Resource Management Suite (4.1.13)
//
//**********************************************************
PROGRAM_NAME='Duet Sample (PDU Implementation)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

dvPDU_Base          =     96:1:0; // AMX PDU (Physical Device (first device))

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)

dvDSS               =  5001:10:0  // Digital Satellite System   (Physical Device)
vdvDSS              =  41103:1:0  // Duet DSS Device            (Duet Module)

dvDVR               =  5001:11:0  // Digital Video Recorder     (Physical Device)
vdvDVR              =  41104:1:0  // Duet DVR Device            (Duet Module)

dvDiscDevice        =  5001:12:0  // Disc Device (Physical Device)
vdvDiscDevice       =  41105:1:0  // Duet Disc Device

dvDocCamera         =  5001:13:0  // Document Camera (Physical Device)
vdvDocCamera        =  41106:1:0  // Duet Document Camera Device

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


#WARN 'Define the devices for the AMX PDU to monitor power consumption in RMS'
// PDU Energy./Power Monitored Device Array
//   The PDU can support up to 8 devices, 1 in each
//   of the 8 physical outlets on the unit.
VOLATILE DEV dvPowerMonitoredDevices[8] =
{
   dvDVR,            // Outlet #1
   dvDiscDevice,     // Outlet #2
   dvDocCamera,      // Outlet #3
   dvDSS,            // Outlet #4
   dvVideoProjector, // Outlet #5
   0:0:0,            // Outlet #6 -- null device (nothing plugged in here...)
   0:0:0,            // Outlet #7 -- null device (nothing plugged in here...)
   0:0:0             // Outlet #8 -- null device (nothing plugged in here...)
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


(*************************)
(*  DUET DEVICE Modules  *)
(*************************)

// Digital Satellite System Device (Duet Module)
//DEFINE_MODULE 'MySatelliteDuetModule_dr1_0_0' mdlDigitalSatelliteSystemMod(vdvDSS, dvDSS);

// Digital Video Recorder Device (Duet Module)
//DEFINE_MODULE 'MyVideoRecorderDuetModule_dr1_0_0' mdlDigitalVideoRecorderMod(vdvDVR, dvDVR);

// Disc Device (Duet Module)
//DEFINE_MODULE 'MyDiscDeviceDuetModule_dr1_0_0' mdlDiscDeviceMod(vdvDiscDevice,dvDiscDevice);

// Document Camera Device (Duet Module)
//DEFINE_MODULE 'MyDocumentCameraDuetModule_dr1_0_0' mdlDocCameraMod(vdvDocCamera,dvDocCamera);

// Video Projector Device (Duet Module)
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
// Power Distribution Unit RMS Monitor
//
// - include one of these for each physical PDU hardware unit.
//   this module will monitor and report power and energy usage
//   information into the RMS system.
//
DEFINE_MODULE 'RmsPowerDistributionUnitMonitor' mdlRmsPowerDistributionUnitMonitorMod(vdvRMS, dvPDU_Base, dvPowerMonitoredDevices);


(******************************)
(*  RMS Duet Device Monitors  *)
(******************************)

//
// Duet device monitoring modules
//
// - a RMS Duet device monitoring module is required for each Duet device
//   you wish for RMS to register and monitor.  These Duet monitoring
//   modules include default implementations for monitored parameters,
//   control methods, and metadata proeprties.
//

// Digital Satellite System RMS Monitor
DEFINE_MODULE 'RmsDuetDigitalSatelliteSystemMonitor' mdlRmsDSSMonitorMod(vdvRMS, vdvDSS, dvDSS);

//Digital Video Recorder RMS Monitor
DEFINE_MODULE 'RmsDuetDVRMonitor' mdlRmsDVRMonitorMod(vdvRMS, vdvDVR, dvDVR);

// Disc Device RMS Monitor
DEFINE_MODULE 'RmsDuetDiscDeviceMonitor' mdlRmsDiscDeviceMonitorMod(vdvRMS, vdvDiscDevice, dvDiscDevice);

// Document Camera RMS Monitor
DEFINE_MODULE 'RmsDuetDocCameraMonitor' mdlRmsDocCameraMonitorMod(vdvRMS, vdvDocCamera, dvDocCamera);

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
