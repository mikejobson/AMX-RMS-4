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
MODULE_NAME='RmsNlHVACMonitor'(DEV vdvRMS,
                               DEV vdvDeviceModule,
                               DEV dvMonitoredDevice)

(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
// This compiler directive is provided as a clue so that other include
// files can provide SNAPI specific behavior if needed.
#DEFINE SNAPI_MONITOR_MODULE;

//
// Has-Properties
//
#DEFINE HAS_HVAC
#DEFINE HAS_FIXED_POWER

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// RMS Asset Properties (Recommended)
CHAR MONITOR_ASSET_NAME[]             = 'HVAC';


// RMS Asset Properties (Optional)
CHAR MONITOR_ASSET_DESCRIPTION[]      = '';
CHAR MONITOR_ASSET_MANUFACTURERNAME[] = '';
CHAR MONITOR_ASSET_MODELNAME[]        = '';
CHAR MONITOR_ASSET_MANUFACTURERURL[]  = '';
CHAR MONITOR_ASSET_MODELURL[]         = '';
CHAR MONITOR_ASSET_SERIALNUMBER[]     = '';
CHAR MONITOR_ASSET_FIRMWAREVERSION[]  = '';


// This module's version information (for logging)
CHAR MONITOR_NAME[]       = 'RMS HVAC Monitor';
CHAR MONITOR_DEBUG_NAME[] = 'RmsNlHVACMon';
CHAR MONITOR_VERSION[]    = '4.1.5';


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// RMS Metadata Property Values
#IF_DEFINED HAS_HVAC
    METADATA_PROPERTY_COOL_SETPOINT_LOW  =  55;
    METADATA_PROPERTY_COOL_SETPOINT_HIGH = 100;
    METADATA_PROPERTY_HEAT_SETPOINT_LOW  =  55;
    METADATA_PROPERTY_HEAT_SETPOINT_HIGH = 100;
    CHAR METADATA_PROPERTY_TEMPERATURE_SCALE[]  = 'F';
    CHAR METADATA_PROPERTY_STAT_MODES[100]  = 'Auto|Heat|Cool|Emergency Heat|Off';
#END_IF


(***********************************************************)
(*               INCLUDE DEFINITIONS GO BELOW              *)
(***********************************************************)

// include RMS MONITOR COMMON AXI
#INCLUDE 'RmsMonitorCommon';

// include SNAPI
#INCLUDE 'SNAPI';

#INCLUDE 'RmsNlSnapiComponents';


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
  // Client key must be unique for this master (recommended to leave it as DPS)
  asset.clientKey         = RmsDevToString(dvMonitoredDevice);

  // These are recommended
  asset.name              = MONITOR_ASSET_NAME;
  asset.assetType         = RMS_ASSET_TYPE_HVAC;

  // These are optional
  asset.description       = MONITOR_ASSET_DESCRIPTION;
  asset.manufacturerName  = MONITOR_ASSET_MANUFACTURERNAME;
  asset.modelName         = MONITOR_ASSET_MODELNAME;
  asset.manufacturerUrl   = MONITOR_ASSET_MANUFACTURERURL;
  asset.modelUrl          = MONITOR_ASSET_MODELURL;
  asset.serialNumber      = MONITOR_ASSET_SERIALNUMBER;
  asset.firmwareVersion   = MONITOR_ASSET_FIRMWAREVERSION;

  // perform registration of this asset
  RmsAssetRegister(dvMonitoredDevice, asset);
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
  //Register all snapi HAS_xyz components
  RegisterAssetParametersSnapiComponents(assetClientKey);

  // submit all parameter registrations
  RmsAssetParameterSubmit(assetClientKey);
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

  //Synchronize all snapi HAS_xyz components
  IF(SynchronizeAssetParametersSnapiComponents(assetClientKey))
    RmsAssetParameterSubmit (assetClientKey)
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
  //Register all snapi HAS_xyz components
  RegisterAssetMetadataSnapiComponents(assetClientKey);

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
  //Register all snapi HAS_xyz components
  IF(SynchronizeAssetMetadataSnapiComponents(assetClientKey))
    RmsAssetMetadataSubmit(assetClientKey);
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
  //Register all snapi HAS_xyz components
  RegisterAssetControlMethodsSnapiComponents(assetClientKey);

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
STACK_VAR
  CHAR cValue1[RMS_MAX_PARAM_LEN]
  INTEGER nValue1
{
  DEBUG("'<<< EXECUTE CONTROL METHOD : [',methodKey,'] args=',arguments,' >>>'");

  cValue1 = RmsParseCmdParam(arguments)
  nValue1 = ATOI(cValue1)

  SWITCH(LOWER_STRING(methodKey))
  {
#IF_DEFINED HAS_HVAC
    CASE 'hvac.fan.state' :
    {
      SWITCH(LOWER_STRING(cValue1))
      {
        CASE 'on'  :
        {
          PULSE[vdvDeviceModule,HVAC_FAN_ON]
        }
        CASE 'off' :
        {
          IF([vdvDeviceModule,HVAC_FAN_ON_FB])
            PULSE[vdvDeviceModule,HVAC_FAN_ON]
        }
      }
    }
    CASE 'hvac.state' :
    {
      SWITCH(LOWER_STRING(cValue1))
      {
        CASE 'auto'           : PULSE[vdvDeviceModule,HVAC_AUTO ]
        CASE 'cool'           : PULSE[vdvDeviceModule,HVAC_COOL ]
        CASE 'heat'           : PULSE[vdvDeviceModule,HVAC_HEAT ]
        CASE 'emergency heat' : PULSE[vdvDeviceModule,HVAC_EHEAT]
        CASE 'off'            : PULSE[vdvDeviceModule,HVAC_OFF  ]
      }
    }
    CASE 'hvac.cool.setpoint' :
    {
      SEND_LEVEL vdvDeviceModule, HVAC_COOL_LVL, LEVEL.VALUE
    }
    CASE 'hvac.heat.setpoint' :
    {
      SEND_LEVEL vdvDeviceModule, HVAC_HEAT_LVL, LEVEL.VALUE
    }
    CASE 'hvac.thermostat.hold' :
    {
      SWITCH(nValue1)
      {
        CASE TRUE  :
        {
          PULSE[vdvDeviceModule,HVAC_HOLD_ON]
        }
        CASE FALSE :
        {
          IF([vdvDeviceModule,HVAC_HOLD_FB])
            PULSE[vdvDeviceModule,HVAC_HOLD_ON]
        }
      }
    }
    CASE 'hvac.thermostat.lock' :
    {
      SWITCH(nValue1)
      {
        CASE TRUE  :
        {
          PULSE[vdvDeviceModule,HVAC_LOCK_ON]
        }
        CASE FALSE :
        {
          IF([vdvDeviceModule,HVAC_LOCK_FB])
            PULSE[vdvDeviceModule,HVAC_LOCK_ON]
        }
      }
    }
#END_IF

    DEFAULT :
    {
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
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


//
// (VIRTUAL DEVICE EVENT HANDLERS)
//
DATA_EVENT[vdvDeviceModule]
{
  ONLINE:
  {
    SEND_COMMAND vdvDeviceModule, "'PROPERTY-RMS-Type,Asset'"
  }
}


#IF_DEFINED HAS_HVAC
  LEVEL_EVENT[vdvDeviceModule,HVAC_COOL_LVL      ]
  LEVEL_EVENT[vdvDeviceModule,HVAC_HEAT_LVL      ]
  LEVEL_EVENT[vdvDeviceModule,INDOOR_TEMP_LVL    ]
  LEVEL_EVENT[vdvDeviceModule,OUTDOOR_TEMP_LVL   ]
  LEVEL_EVENT[vdvDeviceModule,INDOOR_HUMID_LVL   ]
  {
    SWITCH(LEVEL.INPUT.LEVEL)
    {
      CASE HVAC_COOL_LVL       : RmsAssetParameterSetValue(assetClientKey, 'hvac.cool.setpoint' , ITOA(LEVEL.VALUE) );
      CASE HVAC_HEAT_LVL       : RmsAssetParameterSetValue(assetClientKey, 'hvac.heat.setpoint' , ITOA(LEVEL.VALUE) );
      CASE INDOOR_TEMP_LVL     : RmsAssetParameterSetValue(assetClientKey, 'temperature.indoor' , ITOA(LEVEL.VALUE) );
      CASE OUTDOOR_TEMP_LVL    : RmsAssetParameterSetValue(assetClientKey, 'temperature.outdoor', ITOA(LEVEL.VALUE) );
    }
  }

  CHANNEL_EVENT[vdvDeviceModule,HVAC_FAN_ON_FB]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_HOLD_FB]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_LOCK_FB]
  {
    ON :
    {
      SWITCH(CHANNEL.CHANNEL)
      {
        CASE HVAC_FAN_ON_FB : RmsAssetParameterSetValue(assetClientKey, 'hvac.fan.status', 'on' );
        CASE HVAC_HOLD_FB   : RmsAssetParameterSetValue(assetClientKey, 'hvac.thermostat.hold', 'true' );
        CASE HVAC_LOCK_FB   : RmsAssetParameterSetValue(assetClientKey, 'hvac.thermostat.lock', 'true' );
      }
    }
    OFF :
    {
      SWITCH(CHANNEL.CHANNEL)
      {
        CASE HVAC_FAN_ON_FB : RmsAssetParameterSetValue(assetClientKey, 'hvac.fan.status', 'off');
        CASE HVAC_HOLD_FB   : RmsAssetParameterSetValue(assetClientKey, 'hvac.thermostat.hold', 'false');
        CASE HVAC_LOCK_FB   : RmsAssetParameterSetValue(assetClientKey, 'hvac.thermostat.lock', 'false');
      }
    }
  }

  CHANNEL_EVENT[vdvDeviceModule,HVAC_AUTO_FB ]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_COOL_FB ]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_HEAT_FB ]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_EHEAT_FB]
  CHANNEL_EVENT[vdvDeviceModule,HVAC_OFF_FB  ]
  {
    ON :
    {
      SWITCH(CHANNEL.CHANNEL)
      {
        CASE HVAC_AUTO_FB  : RmsAssetParameterSetValue(assetClientKey, 'hvac.state', 'auto'          );
        CASE HVAC_COOL_FB  : RmsAssetParameterSetValue(assetClientKey, 'hvac.state', 'cool'          );
        CASE HVAC_HEAT_FB  : RmsAssetParameterSetValue(assetClientKey, 'hvac.state', 'heat'          );
        CASE HVAC_EHEAT_FB : RmsAssetParameterSetValue(assetClientKey, 'hvac.state', 'emergency heat');
        CASE HVAC_OFF_FB   : RmsAssetParameterSetValue(assetClientKey, 'hvac.state', 'off'           );
      }
    }
  }
#END_IF


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
