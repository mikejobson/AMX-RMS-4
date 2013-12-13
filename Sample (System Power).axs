//**********************************************************
//
//       AMX Resource Management Suite (4.1.13)
//
//**********************************************************
PROGRAM_NAME='Sample (System Power)'
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



(***********************************************************)
(* Name:  SetMySystemPowerOn                               *)
(* Args:  -none-                                           *)
(***********************************************************)
DEFINE_FUNCTION SetMySystemPowerOn()
{
    #WARN 'Implement your SYSTEM POWER [ON] logic here!'

    // after performing the system power ON implementation logic,
    // we must let RMS know that the system power state has been
    // changed.  We can do this using a RMS API function or by
    // simply setting the feedback channel state.
    SEND_STRING 0, '**************************************';
    SEND_STRING 0, ' SetMySystemPowerOn() called          ';
    SEND_STRING 0, '**************************************';
    RmsSystemPowerOn();

    // -- alternative method to update the system power in RMS --
    //ON[vdvRMS,RMS_CHANNEL_SYSTEM_POWER];
}


(***********************************************************)
(* Name:  SetMySystemPowerOff                              *)
(* Args:  -none-                                           *)
(***********************************************************)
DEFINE_FUNCTION SetMySystemPowerOff()
{
    #WARN 'Implement your SYSTEM POWER [OFF] logic here!'

    // after performing the system power OFF implementation logic,
    // we must let RMS know that the system power state has been
    // changed.  We can do this using a RMS API function or by
    // simply setting the feedback channel state.
    SEND_STRING 0, '**************************************';
    SEND_STRING 0, ' SetMySystemPowerOff() called         ';
    SEND_STRING 0, '**************************************';
    RmsSystemPowerOff();

    // -- alternative method to update the system power in RMS --
    //OFF[vdvRMS,RMS_CHANNEL_SYSTEM_POWER];
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

//
// Set the 'System Power' to the ON state
//
BUTTON_EVENT[dvTP1, 1]
{
  PUSH:
  {
     // call your own local function to perform the system power change
     SetMySystemPowerOn();
  }
}


//
// Set the 'System Power' to the OFF state
//
BUTTON_EVENT[dvTP1, 2]
{
  PUSH:
  {
     // call your own local function to perform the system power change
     SetMySystemPowerOff();
  }
}


//
// (RMS SYSTEM POWER ON CHANGE REQUEST NOTIFICATION  <BUTTON API> )
//
// upon receiving the system power change request notification from
// the RMS client the user code should implement the necessary
// code logic to power the 'SYSTEM' ON
//
BUTTON_EVENT[vdvRMS, RMS_CHANNEL_SYSTEM_POWER_ON]
{
  PUSH:
  {
      SEND_STRING 0, '**************************************';
      SEND_STRING 0, ' RMS REQUESTING SYSTEM POWER [ON] ';
      SEND_STRING 0, '**************************************';

      // call your own local function to perform the system power change
      SetMySystemPowerOn();
  }
}


//
// (RMS SYSTEM POWER OFF CHANGE REQUEST NOTIFICATION  <BUTTON API> )
//
// upon receiving the system power change request notification from
// the RMS client the user code should implement the necessary
// code logic to power the 'SYSTEM' OFF
//
BUTTON_EVENT[vdvRMS, RMS_CHANNEL_SYSTEM_POWER_OFF]
{
  PUSH:
  {
      SEND_STRING 0, '**************************************';
      SEND_STRING 0, ' RMS REQUESTING SYSTEM POWER [OFF] ';
      SEND_STRING 0, '**************************************';

      // call your own local function to perform the system power change
      SetMySystemPowerOff();
  }
}



//
// (RMS SYSTEM POWER CHANGED NOTIFICATION  <CHANNEL API> )
//
// upon receiving the system power changed notification from
// the RMS client you can implement any custom logic to perform
// after the new system power state has been applied.
//
CHANNEL_EVENT[vdvRMS, RMS_CHANNEL_SYSTEM_POWER]
{
  ON:
  {
    SEND_STRING 0, '**************************************';
    SEND_STRING 0, ' SYSTEM POWER IS NOW [ON] ';
    SEND_STRING 0, '**************************************';
  }
  OFF:
  {
    SEND_STRING 0, '**************************************';
    SEND_STRING 0, ' SYSTEM POWER IS NOW [OFF] ';
    SEND_STRING 0, '**************************************';
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
