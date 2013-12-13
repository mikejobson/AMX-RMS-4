//**********************************************************
//
//       AMX Resource Management Suite (4.1.13)
//
//**********************************************************
PROGRAM_NAME='Main-Duet-Sample'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

dvPDU_Base          =    192:1:0; // AMX PDU (Physical Device (first device))

dvTP1               =  10001:1:0  // Touch Panels
dvTP2               =  10002:1:0  //  (must be port 1 for base device)
dvTP3               =  10003:1:0

dvTP1_RMS           =  10001:7:0  // RMS Touch Panels (Device Port for RMS TP pages)
dvTP2_RMS           =  10002:7:0  //  (RMS uses port 7 by default)
dvTP3_RMS           =  10003:7:0

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)
vdvRMSGui           =  41002:1:0  // RMS User Interface VDV     (Duet Module)

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

// define virtual device for RMS source usage
vdvRMSSourceUsage   =  33002:1:0  // RMS Source Usage Monitor

// NOTE: these virtual device device definitions are only required if
//       you need to register source usage tracking for non-monitored
//       inputs or devices
vdvAuxInput         =  33003:1:0  // NL Virtual Device for Source Usage Tracking
vdvLaptop           =  33004:1:0  // NL Virtual Device for Source Usage Tracking


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

// if you wish to implement system modes, you must define
// a pipe character '|' separated list of elligible mode
// names and pass this string into the 'RmsSystemModeMonitor'
// module
CHAR SYSTEM_MODES[100]  = 'None|Presentation|Video Conference|Audio Conference';


// names and description properties for virtual source usage devices
VOLATILE CHAR AUX_INPUT_NAME[20] = 'Auxillary Input';
VOLATILE CHAR AUX_INPUT_DESCRIPTION[50] = 'Auxillary VGA Input on Podium';
VOLATILE CHAR LAPTOP_NAME[20] = 'Laptop';
VOLATILE CHAR LAPTOP_DESCRIPTION[50] = 'Laptop Input';


// RMS Touch Panel Array
VOLATILE DEV dvRMSTP[] =
{
   dvTP1_RMS,
   dvTP2_RMS,
   dvTP3_RMS
}

// RMS Touch Panel Array -
//  Base Device for System Keyboard handling
VOLATILE DEV dvRMSTP_Base[] =
{
   dvTP1,
   dvTP2,
   dvTP3
}

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
   0:0:0,            // Outlet #6 -- null device
   0:0:0,            // Outlet #7 -- null device
   0:0:0             // Outlet #8 -- null device
}

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

// include the RMS API constants & helper functions
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


//
// RMS GUI - User Interface Module
//
//  - This module is responsible for all the RMS
//    user interface application logic.  This
//    includes help requests, maintenance requests,
//    location hotlist, and server display messages.
//
DEFINE_MODULE 'RmsClientGui_dr4_0_0' mdlRMSGUI(vdvRMSGui,dvRMSTP,dvRMSTP_Base);


//
// RMS RFID Support
//
//  If you do not need or wish to use Anterus RFID
//  tracking then you may comment out or delete this
//  include file reference.
//
#WARN 'Uncomment this line to include RFID support with RMS'
//#INCLUDE 'RmsRfid'


//
// RMS SOURCE USAGE
//  asset source usage monitoring and tracking
//
//  If you do not need or wish to use source usage,
//  then you may comment out or delete this include
//  file reference.
//
//  If you do intend to implement source usage in RMS,
//  then please see contents of this include file.  You
//  are responsible for implementing the logic for
//  selecting/deselecting sources in your own NetLinx
//  source code.
//
#INCLUDE 'RmsSourceUsage';


//
// RMS SYSTEM POWER / SYSTEM MODE EVENT HANDLER
//  system power and system mode monitoring and tracking
//
//  If you do not need or wish to use the system power
//  or system mode concepts, then you may comment out
//  or delete this include file reference.
//
//  If you do intend to implement system power states
//  and/or system mode seldctions, then please see contents
//  of this include file.  You are responsible for
//  implementing the logic for selecting/deselecting
//  sources in your own NetLinx source code.
//
#INCLUDE 'RmsSystemEventHandler';


(*************************)
(*  DUET DEVICE Modules  *)
(*************************)

#WARN 'Include your Duet device modules here'

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
DEFINE_MODULE 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitorMod_3(vdvRMS,dvTP3);


//
// Power Distribution Unit RMS Monitor
//
// - include one of these for each physical PDU hardware unit.
//   this module will monitor and report power and energy usage
//   information into the RMS system.
//
DEFINE_MODULE 'RmsPowerDistributionUnitMonitor' mdlRmsPowerDistributionUnitMonitorMod(vdvRMS, dvPDU_Base, dvPowerMonitoredDevices);


//
// Generic NetLinx Device Monitor
//
//  - this monitoring module is intended to provide the basic asset
//    registration and device online parameter monitoring for a NetLinx
//    native devices.  (NetLinx native devices include AXLink devices.)
//
//DEFINE_MODULE 'RmsGenericNetLinxDeviceMonitor' mdlRmsNetLinxDeviceMonitorMod(vdvRMS,dvNetLinxDevice);


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


//
// NOTE: the following module definitions are only required if you need to register
//       source usage tracking for non-monitored inputs or devices
//

// Auxillary Input (Virtual Device) RMS Monitor
DEFINE_MODULE 'RmsVirtualDeviceMonitor' mdlRmsAuxInputVdvMonitorMod(vdvRMS, vdvAuxInput, AUX_INPUT_NAME, AUX_INPUT_DESCRIPTION);

// Laptop Input (Virtual Device) RMS Monitor
DEFINE_MODULE 'RmsVirtualDeviceMonitor' mdlRmsLaptopVdvMonitorMod(vdvRMS, vdvLaptop, LAPTOP_NAME, LAPTOP_DESCRIPTION);


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// set a default starting system mode
RmsSystemSetMode('None');


#WARN 'Assign all assets that should participate in source usage tracking here ...'

// add all assets to tracked for source usage
//
// using the mutually exclusive assignment method means that
// only a single mutually exclusive source can be active at
// any given time.  If a source asset is activated, then all
// other sources configured as mutually exclusive will
// be automatically deactivated.
// set of sources.
RmsSourceUsageAssignAssetMutExcl(1, dvDSS);
RmsSourceUsageAssignAssetMutExcl(2, dvDVR);
RmsSourceUsageAssignAssetMutExcl(3, dvDiscDevice);
RmsSourceUsageAssignAssetMutExcl(4, dvDocCamera);

// when you have source usage than can be attibuted to non-controlled
// devices, you must register a virtual device that represent the
// non-controlled and assign a source usage index to it.
RmsSourceUsageAssignAssetMutExcl(5, vdvAuxInput);
RmsSourceUsageAssignAssetMutExcl(6, vdvLaptop);


// if you have sources that are not mutually exclusive and may track
// source usage concurrently, indepentant from mutually exclusive
// source groups, then use the following command to register those
// source assets.
//
// <EXAMPLE> RmsSourceUsageAssignAsset(1, dvDSS);
// <EXAMPLE> RmsSourceUsageAssignAsset(2, dvDVR);


// reset all sources on program startup
RmsSourceUsageReset();

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
