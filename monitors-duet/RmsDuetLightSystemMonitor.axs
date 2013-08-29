//*********************************************************************
//
//             AMX Resource Management Suite  (4.1.5)
//
//*********************************************************************
/*
 *  Legal Notice :
 *
 *     Copyright, AMX LLC, 2011
 *
 *     Private, proprietary information, the sole property of AMX LLC.  The
 *     contents, ideas, and concepts expressed herein are not to be disclosed
 *     except within the confines of a confidential relationship and only
 *     then on a need to know basis.
 *
 *     Any entity in possession of this AMX Software shall not, and shall not
 *     permit any other person to, disclose, display, loan, publish, transfer
 *     (whether by sale, assignment, exchange, gift, operation of law or
 *     otherwise), license, sublicense, copy, or otherwise disseminate this
 *     AMX Software.
 *
 *     This AMX Software is owned by AMX and is protected by United States
 *     copyright laws, patent laws, international treaty provisions, and/or
 *     state of Texas trade secret laws.
 *
 *     Portions of this AMX Software may, from time to time, include
 *     pre-release code and such code may not be at the level of performance,
 *     compatibility and functionality of the final code. The pre-release code
 *     may not operate correctly and may be substantially modified prior to
 *     final release or certain features may not be generally released. AMX is
 *     not obligated to make or support any pre-release code. All pre-release
 *     code is provided "as is" with no warranties.
 *
 *     This AMX Software is provided with restricted rights. Use, duplication,
 *     or disclosure by the Government is subject to restrictions as set forth
 *     in subparagraph (1)(ii) of The Rights in Technical Data and Computer
 *     Software clause at DFARS 252.227-7013 or subparagraphs (1) and (2) of
 *     the Commercial Computer Software Restricted Rights at 48 CFR 52.227-19,
 *     as applicable.
*/
MODULE_NAME='RmsDuetLightSystemMonitor'(DEV vdvRMS,
                                        DEV vdvDeviceModule,
                                        DEV dvMonitoredDevice)

(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
// This compiler directive is provided as a clue so that other include
// files can provide SNAPI specific behavior if needed.
#DEFINE SNAPI_MONITOR_MODULE;

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

CHAR MONITOR_NAME[]       = 'RMS Light System Monitor';
CHAR MONITOR_DEBUG_NAME[] = 'RmsDuetLightMon';
CHAR MONITOR_VERSION[]    = '4.1.5';
CHAR MONITOR_ASSET_TYPE[] = '';
CHAR MONITOR_ASSET_NAME[] = '';


#WARN 'Define the lighting system zone names and addresses here ...'
// RMS setup lighting zone names
//  and addresses for lighting system
VOLATILE CHAR lightingZoneName[][10]  =  { 'Zone 1',
                                           'Zone 2',
                                           'Zone 3',
                                           'Zone 4',
                                           'Zone 5'};

// (NOTE: The number of elements in this array must match the number found in 'lightingZoneName')
VOLATILE CHAR lightingZoneAddress[][5] = {'1',
                                          '2',
                                          '3',
                                          '4',
                                          '5'};


#WARN 'Define the lighting scene names and keypad button addresses here ...'
// RMS setup lighting preset names
//  and keypad addresses for lighting system
VOLATILE CHAR lightingSceneName[][10]  = { 'Scene 1',
                                           'Scene 2',
                                           'Scene 3',
                                           'Scene 4',
                                           'Scene 5' }

// (NOTE: The number of elements in this array must match the number found in 'lightingSceneName')
VOLATILE CHAR lightingSceneKeypadAddress[][5] = {'1',
                                                 '2',
                                                 '3',
                                                 '4',
                                                 '5'};

#WARN 'Define the lighting system zone power (energy) consumption values here ...'
CHAR TRACK_LIGHTING_ZONE_POWER_CONSUMPTION = TRUE;

// amount of watts being consumed by each
// lighting zone while the light is powered on
// (NOTE: The number of elements in this array must match the number found in 'lightingZoneName')
VOLATILE FLOAT lightingZonePowerConsumption[] = {100,100,100,100,100};


// include RMS MONITOR COMMON AXI
#INCLUDE 'RmsMonitorCommon';

// include SNAPI
#INCLUDE 'SNAPI';


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(* Name:  RegisterAsset                                    *)
(* Args:  RmsAsset asset data object to be registered .    *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        register this asset.                             *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RegisterAsset(RmsAsset asset)
{
  // setup optional asset properties
  //asset.name        = 'My Custom Device';
  //asset.description = 'Asset Description Goes Here!';

  // perform registration of this asset
  RmsAssetRegisterDuetDevice(dvMonitoredDevice, vdvDeviceModule, asset);
}


(***********************************************************)
(* Name:  RegisterAssetParameters                          *)
(* Args:  -none-                                           *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        register this asset's parameters to be monitored *)
(*        by RMS.                                          *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RegisterAssetParameters()
{
  // This Duet-based asset monitoring module will
  // automatically register the default monitoring
  // parameters based on the asset type.

  // This module will extend the default capabilities
  // add additional monitored parameters here

  STACK_VAR INTEGER index;

  FOR(index = 1; index <= LENGTH_ARRAY(lightingZoneAddress); index++)
  {
    // light power
    RmsAssetParameterEnqueueBoolean(assetClientKey,
                                    "'light.power.',lightingZoneAddress[index]",
                                    "lightingZoneName[index],' - Power'",
                                    "'Last reported lighting power state for address: ',lightingZoneAddress[index]",
                                    RMS_ASSET_PARAM_TYPE_NONE,
                                    FALSE,
                                    RMS_ALLOW_RESET_NO,
                                    FALSE,
                                    RMS_TRACK_CHANGES_YES);

    // light level
    RmsAssetParameterEnqueueLevel(assetClientKey,
                                    "'light.level.',lightingZoneAddress[index]",
                                    "lightingZoneName[index],' - Level'",
                                    "'Last reported lighting level for address: ',lightingZoneAddress[index]",
                                    RMS_ASSET_PARAM_TYPE_LIGHT_LEVEL,
                                    0,
                                    0,255,
                                    '',
                                    RMS_ALLOW_RESET_NO,
                                    0,
                                    RMS_TRACK_CHANGES_NO,
                                    RMS_ASSET_PARAM_BARGRAPH_LIGHT_LEVEL);

    // light power consumption
    IF(TRACK_LIGHTING_ZONE_POWER_CONSUMPTION)
    {
      RmsAssetParameterEnqueueDecimal(assetClientKey,
                                      "'light.power.consumption.',lightingZoneAddress[index]",
                                      "lightingZoneName[index],' - Power Consumption Rate'",
                                      "'Last reported power consumption rate for lighting zone address: ',lightingZoneAddress[index]",
                                      RMS_ASSET_PARAM_TYPE_POWER_CONSUMPTION,
                                      0,0,0,
                                      'Watts',
                                      RMS_ALLOW_RESET_NO,
                                      0,
                                      RMS_TRACK_CHANGES_YES);
    }
  }

  // submit all parameter registrations
  RmsAssetParameterSubmit(assetClientKey);

  // query the lighting system to obtain the latest lighting power
  // states and levels, we will use these values to update the parameters
  FOR(index = 1; index <= LENGTH_ARRAY(lightingZoneAddress); index++)
  {
     SEND_COMMAND vdvDeviceModule,DuetPackCmdSimple('?LIGHTSYSTEMSTATE',lightingZoneAddress[index]);
     SEND_COMMAND vdvDeviceModule,DuetPackCmdSimple('?LIGHTSYSTEMLEVEL',lightingZoneAddress[index]);
  }
}


(***********************************************************)
(* Name:  SynchronizeAssetParameters                       *)
(* Args:  -none-                                           *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        update/synchronize this asset parameter values   *)
(*        with RMS.                                        *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION SynchronizeAssetParameters()
{
  // This callback method is invoked when either the RMS server connection
  // has been offline or this monitored device has been offline from some
  // amount of time.   Since the monitored parameter state values could
  // be out of sync with the RMS server, we must perform asset parameter
  // value updates for all monitored parameters so they will be in sync.
  // Update only asset monitoring parameters that may have changed in value.

  // This Duet-based asset monitoring module will
  // automatically synchronize the default monitored
  // parameter values.  If you extended teh monitored
  // parameters with your own custom parameters, please
  // make sure to synchronize those parameter values here.

  STACK_VAR INTEGER index;

  // query the lighting system to obtain the latest lighting power
  // states and levels, we will use these values to update the parameters
  FOR(index = 1; index <= LENGTH_ARRAY(lightingZoneAddress); index++)
  {
     SEND_COMMAND vdvDeviceModule,DuetPackCmdSimple('?LIGHTSYSTEMSTATE',lightingZoneAddress[index]);
     SEND_COMMAND vdvDeviceModule,DuetPackCmdSimple('?LIGHTSYSTEMLEVEL',lightingZoneAddress[index]);
  }
}


(***********************************************************)
(* Name:  ResetAssetParameterValue                         *)
(* Args:  parameterKey   - unique parameter key identifier *)
(*        parameterValue - new parameter value after reset *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that an asset          *)
(*        parameter value has been reset by the RMS server *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION ResetAssetParameterValue(CHAR parameterKey[],CHAR parameterValue[])
{
  // if your monitoring module performs any parameter
  // value tracking, then you may want to update the
  // tracking value based on the new reset value
  // received from the RMS server.
}


(***********************************************************)
(* Name:  RegisterAssetMetadata                            *)
(* Args:  -none-                                           *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        register this asset's metadata properties with   *)
(*        RMS.                                             *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RegisterAssetMetadata()
{
  // This Duet-based asset monitoring module will
  // automatically register the default asset
  // metadata properties based on the asset type.

  // This module will extend the default capabilities
  // add additional asset metadata properties here

  RmsAssetMetadataEnqueueNumber(assetClientKey, 'light.count', 'Lighting Zone Count', LENGTH_ARRAY(lightingZoneAddress));
  RmsAssetMetadataSubmit(assetClientKey);
}


(***********************************************************)
(* Name:  SynchronizeAssetMetadata                         *)
(* Args:  -none-                                           *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        update/synchronize this asset metadata properties *)
(*        with RMS if needed.                              *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION SynchronizeAssetMetadata()
{
  // This callback method is invoked when either the RMS server connection
  // has been offline or this monitored device has been offline from some
  // amount of time.   Traditionally, asset metadata is relatively static
  // information and thus does not require any synchronization of values.
  // However, this callback method does provide the opportunity to perform
  // any necessary metadata updates if your implementation does include
  // any dynamic metadata values.
}


(***********************************************************)
(* Name:  RegisterAssetControlMethods                      *)
(* Args:  -none-                                           *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it is time to     *)
(*        register this asset's control methods with RMS.  *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RegisterAssetControlMethods()
{
  // This Duet-based asset monitoring module will
  // automatically register the default asset type control
  // method.

  // This module will extend the default capabilities
  // add additional asset control methods here

  // set light ON
  RmsAssetControlMethodEnqueue(assetClientKey,'light.power.on','Set Light On', 'Turn light power ON for specific lighting zone');
  RmsAssetControlMethodArgumentEnumEx(assetClientKey,'light.power.on',0,'Lighting Zone','Select the lighting zone',lightingZoneName[1],lightingZoneName);

  // set light OFF
  RmsAssetControlMethodEnqueue(assetClientKey,'light.power.off','Set Light Off', 'Turn light power OFF for specific lighting zone');
  RmsAssetControlMethodArgumentEnumEx(assetClientKey,'light.power.off',0,'Lighting Zone','Select the lighting zone',lightingZoneName[1],lightingZoneName);

  // set light level
  RmsAssetControlMethodEnqueue(assetClientKey,'light.level','Set Light Level', 'Set lighting level for specific lighting zone');
  RmsAssetControlMethodArgumentEnumEx(assetClientKey,'light.level',0,'Lighting Zone','Select the lighting zone',lightingZoneName[1],lightingZoneName);
  RmsAssetControlMethodArgumentLevel(assetClientKey,'light.level',1,'Level','Select the lighting level to apply',128,0,255,1);
  RmsAssetControlMethodArgumentLevel(assetClientKey,'light.level',2,'Ramp Time','Select the ramp time for the lighting level change',0,0,60,1); // 0 to 60 seconds

  // select lighting scene
  RmsAssetControlMethodEnqueue(assetClientKey,'light.scene','Recall Lighting Scene', 'Recall a lighting scene/preset.');
  RmsAssetControlMethodArgumentEnumEx(assetClientKey,'light.scene',0,'Lighting Scene','Select the lighting scene',lightingSceneName[1],lightingSceneName);

  // when done enqueuing all asset control methods and
  // arguments for this asset, we just need to submit
  // them to finalize and register them with the RMS server
  RmsAssetControlMethodsSubmit(assetClientKey);
}


(***********************************************************)
(* Name:  ExecuteAssetControlMethod                        *)
(* Args:  methodKey - unique method key that was executed  *)
(*        arguments - array of argument values invoked     *)
(*                    with the execution of this method.   *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that it should         *)
(*        fullfill the execution of one of this asset's    *)
(*        control methods.                                 *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION ExecuteAssetControlMethod(CHAR methodKey[], CHAR arguments[])
{
  // This Duet-based asset monitoring module will
  // automatically handle the execution of the
  // default asset type control methods.

  // This module will extend the default capabilities
  // and handle the execution of the additional asset
  // control methods here

  STACK_VAR CHAR zoneName[DUET_MAX_PARAM_LEN];
            INTEGER index;
            CHAR deviceCommand[DUET_MAX_CMD_LEN];

  SELECT
  {
    // set light ON
    ACTIVE(methodKey == 'light.power.on'):
    {
      // parse lighting zone name
      zoneName = RmsParseCmdParam(arguments);

      // lookup lighintg zone index from name
      index = GetLightingZoneIndexByName(zoneName)

      // if a valid index was returned, then send the command
      // to the Duet device to execute the controm method
      IF(index > 0)
      {
        // LIGHTSYSTEMSTATE-<address>,<lightstate>
        deviceCommand = DuetPackCmdHeader('LIGHTSYSTEMSTATE');
        deviceCommand = DuetPackCmdParam(deviceCommand,lightingZoneAddress[index]);
        deviceCommand = DuetPackCmdParam(deviceCommand,'ON');
        SEND_COMMAND vdvDeviceModule,deviceCommand;
      }
    }

    // set light OFF
    ACTIVE(methodKey == 'light.power.off'):
    {
      // parse lighting zone name
      zoneName = RmsParseCmdParam(arguments);

      // lookup lighting zone index from name
      index = GetLightingZoneIndexByName(zoneName)

      // if a valid index was returned, then send the command
      // to the Duet device to execute the control method
      IF(index > 0)
      {
        // LIGHTSYSTEMSTATE-<address>,<lightstate>
        deviceCommand = DuetPackCmdHeader('LIGHTSYSTEMSTATE');
        deviceCommand = DuetPackCmdParam(deviceCommand,lightingZoneAddress[index]);
        deviceCommand = DuetPackCmdParam(deviceCommand,'OFF');
        SEND_COMMAND vdvDeviceModule,deviceCommand;
      }
    }

    // set light level
    ACTIVE(methodKey == 'light.level'):
    {
      STACK_VAR CHAR lightLevel[DUET_MAX_PARAM_LEN];
                CHAR rampTime[DUET_MAX_PARAM_LEN];

      // parse lighting zone name
      zoneName = RmsParseCmdParam(arguments);

      // parse lighting level value
      lightLevel = RmsParseCmdParam(arguments);

      // parse lighting ramping time
      rampTime = RmsParseCmdParam(arguments);

      // lookup lighting zone index from name
      index = GetLightingZoneIndexByName(zoneName)

      // if a valid index was returned, then send the command
      // to the Duet device to execute the control method
      IF(index > 0)
      {
        // LIGHTSYSTEMLEVEL-<address>,<level>,<time>
        deviceCommand = DuetPackCmdHeader('LIGHTSYSTEMLEVEL');
        deviceCommand = DuetPackCmdParam(deviceCommand,lightingZoneAddress[index]);
        deviceCommand = DuetPackCmdParam(deviceCommand,lightLevel);
        deviceCommand = DuetPackCmdParam(deviceCommand,rampTime);
        SEND_COMMAND vdvDeviceModule,deviceCommand;
      }
    }

    // set light scene (keypad button address click)
    ACTIVE(methodKey == 'light.scene'):
    {
      CHAR sceneName[DUET_MAX_PARAM_LEN];

      // parse lighting scene name
      sceneName = RmsParseCmdParam(arguments);

      // lookup lighting scene index from name
      index = GetLightingSceneIndexByName(sceneName)

      // if a valid index was returned, then send the command
      // to the Duet device to execute the control method
      IF(index > 0)
      {
        // KEYPADSYSTEMBUTTONSTATE-<keypadAddress>,<buttonState>
        deviceCommand = DuetPackCmdHeader('KEYPADSYSTEMBUTTONSTATE');
        deviceCommand = DuetPackCmdParam(deviceCommand,lightingSceneKeypadAddress[index]);
        deviceCommand = DuetPackCmdParam(deviceCommand,'CLICK');
        SEND_COMMAND vdvDeviceModule,deviceCommand;
      }
    }
  }
}


(***********************************************************)
(* Name:  SystemPowerChanged                               *)
(* Args:  powerOn - boolean value representing ON/OFF      *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that the SYSTEM POWER  *)
(*        state has changed states.                        *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION SystemPowerChanged(CHAR powerOn)
{
  // optionally implement logic based on
  // system power state.
}


(***********************************************************)
(* Name:  SystemModeChanged                                *)
(* Args:  modeName - string value representing mode change *)
(*                                                         *)
(* Desc:  This is a callback method that is invoked by     *)
(*        RMS to notify this module that the SYSTEM MODE   *)
(*        state has changed states.                        *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION SystemModeChanged(CHAR modeName[])
{
  // optionally implement logic based on
  // newly selected system mode name.
}



(***********************************************************)
(* Name:  GetLightingSceneIndexByName                      *)
(* Args:  sceneName - lighting scene friendly name         *)
(*                                                         *)
(* Desc:  This method is used to obtain the index value    *)
(*        in the lighting scene names array where this     *)
(*        lighting scene friendly name is found.           *)
(*                                                         *)
(*        Returns '0' (out of bounds) if the lighting      *)
(*        scene name is not found in the array.            *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION INTEGER GetLightingSceneIndexByName(CHAR sceneName[])
{
  STACK_VAR INTEGER index;

  // iterate over scene names and return index if a match is found
  FOR(index = 1; index <= LENGTH_ARRAY(lightingSceneName); index++)
  {
     IF(LOWER_STRING(lightingSceneName[index]) == LOWER_STRING(sceneName))
     {
       RETURN index;
     }
  }

  // scene name not found
  RETURN 0;
}


(***********************************************************)
(* Name:  GetLightingZoneIndexByName                       *)
(* Args:  zoneName - lighting zone friendly name           *)
(*                                                         *)
(* Desc:  This method is used to obtain the index value    *)
(*        in the lighting zone names array where this      *)
(*        lighting zone friendly name is found.            *)
(*                                                         *)
(*        Returns '0' (out of bounds) if the lighting      *)
(*        zone name is not found in the array.             *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION INTEGER GetLightingZoneIndexByName(CHAR zoneName[])
{
  STACK_VAR INTEGER index;

  // iterate over zone names and return index if a match is found
  FOR(index = 1; index <= LENGTH_ARRAY(lightingZoneName); index++)
  {
     IF(LOWER_STRING(lightingZoneName[index]) == LOWER_STRING(zoneName))
     {
       RETURN index;
     }
  }

  // zone name not found
  RETURN 0;
}


(***********************************************************)
(* Name:  GetLightingZoneIndexByAddress                    *)
(* Args:  address - lighting zone address string           *)
(*                                                         *)
(* Desc:  This method is used to obtain the index value    *)
(*        in the lighting zone addresses array where this  *)
(*        lighting address string is found.                *)
(*                                                         *)
(*        Returns '0' (out of bounds) if the lighting      *)
(*        address string is not found in the array.        *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION INTEGER GetLightingZoneIndexByAddress(CHAR address[])
{
  STACK_VAR INTEGER index;

  // iterate over zone addresses and return index if a match is found
  FOR(index = 1; index <= LENGTH_ARRAY(lightingZoneAddress); index++)
  {
     IF(LOWER_STRING(lightingZoneAddress[index]) == LOWER_STRING(address))
     {
       RETURN index;
     }
  }

  // zone address not found
  RETURN 0;
}


(***********************************************************)
(* Name:  SubmitPendingParameterUpdates                    *)
(***********************************************************)
DEFINE_FUNCTION SubmitPendingParameterUpdates()
{
  LOCAL_VAR INTEGER pendingTransactions;

  // only proceed if RMS is ONLINE and asset management is enabled
  IF(![vdvRMS,RMS_CHANNEL_ASSETS_REGISTER])
    RETURN;

  // increment pending transactions counter
  pendingTransactions = pendingTransactions + 1;

  // Cancel any existing submit waits
  CANCEL_WAIT 'SubmitParameterUpdates'

  // if the number of pending transaction has exceeded ten
  // updates, then send the batch immediately, else continue
  // to batch up and send in a few seconds
  IF(pendingTransactions >= 10)
  {
    // send updates immediately
    RmsAssetParameterUpdatesSubmit(assetClientKey);
    pendingTransactions = 0; // reset pending counter
  }
  ELSE
  {
    // Wait for 2 seconds, just in case there are any additional
    // parameter updates available that can be added to the pending
    // queue.  If is far more efficient to send batches of updates
    // rather than a bunch on individual updates if it is likely
    // that they will be back to back
    WAIT 20 'SubmitParameterUpdates'
    {
      RmsAssetParameterUpdatesSubmit(assetClientKey);
      pendingTransactions = 0; // reset pending counter
    }
  }
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
// (DUET DEVICE EVENT HANDLERS)
//
// handle events generated by the Duet device
// module.
//
DATA_EVENT[vdvDeviceModule]
{
  ONLINE:
  {
    // assign the 'RMS-Type' property with a value of
    // 'Asset' on the Duet device module.
    SEND_COMMAND vdvDeviceModule, "'PROPERTY-RMS-Type,Asset'"
  }

  COMMAND:
  {
    STACK_VAR CHAR header[DUET_MAX_HDR_LEN];
              CHAR address[DUET_MAX_PARAM_LEN];
              CHAR value[DUET_MAX_PARAM_LEN];
              INTEGER index;

    // only proceed in processing asset parameter updates
    // if RMS is ONLINE and asset management is enabled
    IF([vdvRMS,RMS_CHANNEL_ASSETS_REGISTER])
    {
      // parse command header
      header = DuetParseCmdHeader(DATA.TEXT);

      SELECT
      {
        // LIGHTSYSTEMSTATE-<address>,<state>
        ACTIVE(header == 'LIGHTSYSTEMSTATE'):
        {
          // parse address parameter
          address = DuetParseCmdParam(DATA.TEXT);

          // get zone index from address
          index = GetLightingZoneIndexByAddress(address);

          // only perform an update to RMS if this is a
          // known configured lighting zone address
          IF(index > 0)
          {
            // parse state value parameter
            value = DuetParseCmdParam(DATA.TEXT);

            // update parameter value
            IF(value == 'ON')
            {
              RmsAssetParameterEnqueueSetValueBoolean(assetClientKey,"'light.power.',address",TRUE);

              // update the power consumption parameter
              IF(TRACK_LIGHTING_ZONE_POWER_CONSUMPTION)
              {
                // no power consumption when the light is OFF
                RmsAssetParameterEnqueueSetValueDecimal(assetClientKey,"'light.power.consumption.',address",lightingZonePowerConsumption[index]);
              }
            }
            ELSE
            {
              RmsAssetParameterEnqueueSetValueBoolean(assetClientKey,"'light.power.',address",FALSE);

              // update the power consumption parameter
              IF(TRACK_LIGHTING_ZONE_POWER_CONSUMPTION)
              {
                // no power consumption when the light is OFF
                RmsAssetParameterEnqueueSetValueDecimal(assetClientKey,"'light.power.consumption.',address",0);
              }
            }

            // submit pending RMS parameter updates
            SubmitPendingParameterUpdates();
          }
        }

        // LIGHTSYSTEMLEVEL-<address>,<level>
        ACTIVE(header == 'LIGHTSYSTEMLEVEL'):
        {
          // parse address parameter
          address = DuetParseCmdParam(DATA.TEXT);

          // get zone index from address
          index = GetLightingZoneIndexByAddress(address);

          // only perform an update to RMS if this is a
          // known configured lighting zone address
          IF(index > 0)
          {
            // parse level value parameter
            value = DuetParseCmdParam(DATA.TEXT);

            // update parameter value
            RmsAssetParameterEnqueueSetValueLevel(assetClientKey,"'light.level.',address",ATOI(value));

            // submit pending RMS parameter updates
            SubmitPendingParameterUpdates();
          }
        }
      }
    }
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
