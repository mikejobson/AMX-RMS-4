//**********************************************************
//
//       AMX Resource Management Suite (4.1.5)
//
//**********************************************************
PROGRAM_NAME='NetLinx Sample (Source Usage)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            =      0:1:0  // Control Systems Master

dvTP1               =  10001:1:0  // Touch Panels (Not monitored in this sample)

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)

dvDSS               =  5001:10:0  // Digital Satellite System   (Physical Device)
vdvDSS              =  34001:1:0  // DSS Virtual Device Interface

dvDVR               =  5001:11:0  // Digital Video Recorder     (Physical Device)
vdvDVR              =  34002:1:0  // DVR Virtual Device Interface

dvDiscDevice        =  5001:12:0  // Disc Device (Physical Device)
vdvDiscDevice       =  34003:1:0  // Disc Device Virtual Device Interface

dvDocCamera         =  5001:13:0  // Document Camera (Physical Device)
vdvDocCamera        =  34004:1:0  // Document Camera Virtual Device Interface

dvVideoProjector    =  5001:23:0  // Video Projector            (Physical Device)
vdvVideoProjector   =  34005:1:0  // Video Projector Virtual Device Interface

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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// names and description properties for virtual source usage devices
VOLATILE CHAR AUX_INPUT_NAME[20] = 'Auxillary Input';
VOLATILE CHAR AUX_INPUT_DESCRIPTION[50] = 'Auxillary VGA Input on Podium';
VOLATILE CHAR LAPTOP_NAME[20] = 'Laptop';
VOLATILE CHAR LAPTOP_DESCRIPTION[50] = 'Laptop Input';


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


(***********************************)
(*  RMS Device Monitoring Modules  *)
(***********************************)

//
// RMS device monitoring modules
//
// - a RMS device monitoring module is required for each device
//   you wish for RMS to register and monitor.  These NetLinx-based monitoring
//   modules include default implementations for monitored parameters,
//   control methods, and metadata properties based on the SNAPI API.
//   Your NetLinx implementation code should emulate the SNAPI commands
//   channels and levels for each device type on the device virtual device
//   interface.  If you emulate the necessary SNAPI commands, channel, and
//   levels, these monitoring modules will perform all the RMS integration
//   on behalf of each device type.
//
//   The NetLinx-based RMS monitoring modules are all open source.


// Digital Satellite System RMS Monitor
DEFINE_MODULE 'RmsNlDigitalSatelliteSystemMonitor' mdlRmsDSSMonitorMod(vdvRMS, vdvDSS, dvDSS);

//Digital Video Recorder RMS Monitor
DEFINE_MODULE 'RmsNlDVRMonitor' mdlRmsDVRMonitorMod(vdvRMS, vdvDVR, dvDVR);

// Disc Device RMS Monitor
DEFINE_MODULE 'RmsNlDiscDeviceMonitor' mdlRmsDiscDeviceMonitorMod(vdvRMS, vdvDiscDevice, dvDiscDevice);

// Document Camera RMS Monitor
DEFINE_MODULE 'RmsNlDocCameraMonitor' mdlRmsDocCameraMonitorMod(vdvRMS, vdvDocCamera, dvDocCamera);

// Video Projector RMS Monitor
DEFINE_MODULE 'RmsNlVideoProjectorMonitor' mdlRmsVideoProjectorMonitorMod(vdvRMS, vdvVideoProjector, dvVideoProjector);


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
// source usage concurrently, independant from mutually exclusive
// sources, then use the following command to register those
// source assets.  If you have a scenario where the are mutiple
// sources that can be dispalyed on mutiple displays such as is the
// case using a matrix switcher, then it is best to use this non-
// mutually exclusive source usage tracking method and manually
// maintain the source activated states in your business implementation
// code.
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
// Set the selected source input to: 'DSS'
// (DSS is assigned to source index #1)
//
BUTTON_EVENT[dvTP1, 1]
{
  PUSH:
  {
    // activate the source by index
    RmsSourceUsageActivateSource(1);
  }
}

//
// Set the selected source input to: 'DVR'
// (DVR is assigned to source index #2)
//
BUTTON_EVENT[dvTP1, 2]
{
  PUSH:
  {
    // activate the source by index
    RmsSourceUsageActivateSource(2);
  }
}

//
// Set the selected source input to: 'Disc Device'
// (Disc Device is assigned to source index #3)
//
BUTTON_EVENT[dvTP1, 3]
{
  PUSH:
  {
    // activate the source by index
    RmsSourceUsageActivateSource(3);
  }
}

//
// Set the selected source input to: 'Document Camera'
// (Document CAmera is assigned to source index #4)
//
BUTTON_EVENT[dvTP1, 4]
{
  PUSH:
  {
    // activate the source by index
    RmsSourceUsageActivateSource(4);
  }
}

//
// Set the selected source input to: 'Auxillary Input'
// (Auxillary Input is assigned to source index #5)
//
BUTTON_EVENT[dvTP1, 5]
{
  PUSH:
  {
    // activate the source by channel
    // this performs the exact same function
    // but uses the channel API to perform the update
    ON[vdvRMSSourceUsage, 5];
  }
}

//
// Set the selected source input to: 'Laptop Input'
// (Laptop Input is assigned to source index #6)
//
BUTTON_EVENT[dvTP1, 6]
{
  PUSH:
  {
    // activate the source by channel
    // this performs the exact same function
    // but uses the channel API to perform the update
    ON[vdvRMSSourceUsage, 6];
  }
}

//
// Clear the selected source input
// (no input is assigned)
//
BUTTON_EVENT[dvTP1, 10]
{
  PUSH:
  {
    // activate the source by channel
    // this performs the exact same function
    // but uses the channel API to perform the update
    RmsSourceUsageDeactivateAllSources();
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
