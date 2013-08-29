//**********************************************************
//
//       AMX Resource Management Suite (4.1.5)
//
//**********************************************************
PROGRAM_NAME='Sample (Custom Events)'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


dvMaster            =      0:1:0  // Control Systems Master

dvTP1               =  10001:1:0  // Touch Panels (Not monitored in this sample)

vdvRMS              =  41001:1:0  // RMS Client Engine VDV      (Duet Module)


// register for RMS events
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_CLIENT_RESPONSE_CALLBACK
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_CLIENT_LOCATION_RESPONSE_CALLBACK
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_LOCATION_INFORMATION_CALLBACK
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_ASSET_RELOCATED_CALLBACK
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_DISPLAY_MESSAGE_CALLBACK
#DEFINE INCLUDE_RMS_CUSTOM_EVENT_ASSET_METHOD_EXECUTE_CALLBACK

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

CHAR SYSTEM_MODES[100]  = 'None|Presentation|Video Conference|Audio Conference';

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

// Include the RMS API constants & helper functions
#INCLUDE 'RmsApi';

// Include the RMS event listener 
#INCLUDE 'RmsEventListener';

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
DEFINE_MODULE 'RmsSystemModeMonitor' mdlRmsSystemMonitorMod(vdvRMS,dvMaster,SYSTEM_MODES);


(*********************************)
(*  RMS NetLinx Device Monitors  *)
(*********************************)


DEFINE_FUNCTION RmsEventClientGatewayInformationResponse(RmsClientGateway clientGateway)
{
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' CLIENT GATEWAY RESPONSE';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' UID         : ',clientGateway.uid";
  SEND_STRING 0,"' NAME        : ',clientGateway.name";
  SEND_STRING 0,"' HOSTNAME    : ',clientGateway.hostname";
  SEND_STRING 0,"' IP ADDRESS  : ',clientGateway.ipAddress";
  SEND_STRING 0,"' IP PORT     : ',clientGateway.ipPort";
  SEND_STRING 0,"' GATEWAY     : ',clientGateway.gateway";
  SEND_STRING 0,"' MAC ADDRESS : ',clientGateway.macAddress";
  SEND_STRING 0,"' SUBNET MASK : ',clientGateway.subnetMask";
  SEND_STRING 0,"' SDK VERSION : ',clientGateway.sdkVersion";
  SEND_STRING 0,"' PROTOCOL    : ',ITOA(clientGateway.communicationProtocol)";
  SEND_STRING 0,"' PROTOCOL VER: ',ITOA(clientGateway.communicationProtocolVersion)";
  SEND_STRING 0, '**************************************';
}


DEFINE_FUNCTION RmsEventClientLocationInformationResponse(RmsLocation location)
{
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' CLIENT LOCATION RESPONSE';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' ID        : ',ITOA(location.id)";
  SEND_STRING 0,"' NAME      : ',location.name";
  SEND_STRING 0,"' PRESTIGE  : ',location.prestigeName";
  SEND_STRING 0,"' TIMEZONE  : ',location.timezone";
  SEND_STRING 0,"' OWNER     : ',location.owner";
  SEND_STRING 0,"' OCCUPANCY : ',ITOA(location.occupancy)";
  SEND_STRING 0, '**************************************';
}


DEFINE_FUNCTION RmsEventLocationInformation2(RmsLocation location, CHAR isClientDefaultLocation)
{
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' UPDATED LOCATION INFO RECEIVED';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' ID        : ',ITOA(location.id)";
  SEND_STRING 0,"' NAME      : ',location.name";
  SEND_STRING 0,"' PRESTIGE  : ',location.prestigeName";
  SEND_STRING 0,"' TIMEZONE  : ',location.timezone";
  SEND_STRING 0,"' OWNER     : ',location.owner";
  SEND_STRING 0,"' OCCUPANCY : ',ITOA(location.occupancy)";
  SEND_STRING 0,"' (DEFAULT) : ',RmsBooleanString(isClientDefaultLocation)";
  SEND_STRING 0, '**************************************';
}


DEFINE_FUNCTION RmsEventAssetRelocated2(CHAR assetClientKey[], 
                                        LONG assetId, 
                                        RmsLocation newLocation, 
                                        CHAR isClientDefaultLocation)
{
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' ASSET RELOCATION INFO RECEIVED';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' Asset Key : ',assetClientKey";
  SEND_STRING 0,"' Asset ID  : ',ITOA(assetId)";
  SEND_STRING 0, '--------------------------------------';
  SEND_STRING 0,"' LOC ID    : ',ITOA(newLocation.id)";
  SEND_STRING 0,"' NAME      : ',newLocation.name";
  SEND_STRING 0,"' PRESTIGE  : ',newLocation.prestigeName";
  SEND_STRING 0,"' TIMEZONE  : ',newLocation.timezone";
  SEND_STRING 0,"' OWNER     : ',newLocation.owner";
  SEND_STRING 0,"' OCCUPANCY : ',ITOA(newLocation.occupancy)";
  SEND_STRING 0,"' (DEFAULT) : ',RmsBooleanString(isClientDefaultLocation)";
  SEND_STRING 0, '**************************************';
}

DEFINE_FUNCTION RmsEventDisplayMessage2(RmsDisplayMessage displayMessage, CHAR isClientDefaultLocation)
{
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' DISPLAY MESSAGE RECEIVED';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' LOC ID     : ',ITOA(displayMessage.locationId)";
  SEND_STRING 0,"' TYPE       : ',displayMessage.type";
  SEND_STRING 0,"' TITLE      : ',displayMessage.title";
  SEND_STRING 0,"' MESSAGE    : ',displayMessage.message";
  SEND_STRING 0,"' TIMEOUT    : ',ITOA(displayMessage.timeout)";
  SEND_STRING 0,"' IS MODAL   : ',RmsBooleanString(displayMessage.isModal)";
  SEND_STRING 0,"' IS RESPONSE: ',RmsBooleanString(displayMessage.isResponse)";
  SEND_STRING 0,"' (DEFAULT)  : ',RmsBooleanString(isClientDefaultLocation)";
  SEND_STRING 0, '**************************************';
}


DEFINE_FUNCTION RmsEventAssetControlMethodExecute2(RmsAssetControlMethod controlMethod)
{
  STACK_VAR INTEGER index;
  
  SEND_STRING 0, '**************************************';
  SEND_STRING 0, ' EXECUTE CONTROL METHOD';
  SEND_STRING 0, '**************************************';
  SEND_STRING 0,"' ASSET KEY  : ',controlMethod.assetClientKey";
  SEND_STRING 0,"' METHOD KEY : ',controlMethod.methodKey";
  SEND_STRING 0,"' ARGUMENTS  : ',ITOA(LENGTH_ARRAY(controlMethod.argumentValues))";
  SEND_STRING 0, '--------------------------------------';
  FOR(index = 1; index <= LENGTH_ARRAY(controlMethod.argumentValues); index++)
  {
    SEND_STRING 0,"' (',ITOA(index),') - ',controlMethod.argumentValues[index]";
  }
  SEND_STRING 0, '**************************************';
}


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

