﻿//*********************************************************************
//
//             AMX Resource Management Suite  (4.1.13)
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
MODULE_NAME='RmsNlDocCameraMonitor'(DEV vdvRMS,
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
#DEFINE HAS_POWER
#DEFINE HAS_DOCUMENT_CAMERA
#DEFINE HAS_CAMERA_LENS
#DEFINE HAS_SOURCE_SELECT

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// RMS Asset Properties (Recommended)
CHAR MONITOR_ASSET_NAME[]             = 'Document Camera';


// RMS Asset Properties (Optional)
CHAR MONITOR_ASSET_DESCRIPTION[]      = '';
CHAR MONITOR_ASSET_MANUFACTURERNAME[] = '';
CHAR MONITOR_ASSET_MODELNAME[]        = '';
CHAR MONITOR_ASSET_MANUFACTURERURL[]  = '';
CHAR MONITOR_ASSET_MODELURL[]         = '';
CHAR MONITOR_ASSET_SERIALNUMBER[]     = '';
CHAR MONITOR_ASSET_FIRMWAREVERSION[]  = '';


// RMS Metadata Property Values


// This module's version information (for logging)
CHAR MONITOR_NAME[]       = 'RMS Document Camera Monitor';
CHAR MONITOR_DEBUG_NAME[] = 'RmsNlDocCamMon';
CHAR MONITOR_VERSION[]    = '4.1.13';


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

#IF_DEFINED HAS_SOURCE_SELECT
    METADATA_PROPERTY_SOURCE_INPUT_COUNT      = 2;
    CHAR METADATA_PROPERTY_SOURCE_INPUT[100]  = 'Document Camera|VGA 1';
#END_IF

#IF_DEFINED HAS_CAMERA_LENS
    SLONG METADATA_PROPERTY_ZOOM_LVL_INIT   = 0;
    SLONG METADATA_PROPERTY_ZOOM_LVL_MIN    = 0;
    SLONG METADATA_PROPERTY_ZOOM_LVL_MAX    = 255;
    SLONG METADATA_PROPERTY_ZOOM_LVL_RESET  = 0;

    SLONG METADATA_PROPERTY_FOCUS_LVL_INIT  = 0;
    SLONG METADATA_PROPERTY_FOCUS_LVL_MIN   = 0;
    SLONG METADATA_PROPERTY_FOCUS_LVL_MAX   = 255;
    SLONG METADATA_PROPERTY_FOCUS_LVL_RESET = 0;

    SLONG METADATA_PROPERTY_IRIS_LVL_INIT   = 0;
    SLONG METADATA_PROPERTY_IRIS_LVL_MIN    = 0;
    SLONG METADATA_PROPERTY_IRIS_LVL_MAX    = 255;
    SLONG METADATA_PROPERTY_IRIS_LVL_RESET  = 0;

    SLONG METADATA_PROPERTY_ZOOM_SPD_INIT   = 0;
    SLONG METADATA_PROPERTY_ZOOM_SPD_MIN    = 0;
    SLONG METADATA_PROPERTY_ZOOM_SPD_MAX    = 255;
    SLONG METADATA_PROPERTY_ZOOM_SPD_RESET  = 0;

    SLONG METADATA_PROPERTY_FOCUS_SPD_INIT  = 0;
    SLONG METADATA_PROPERTY_FOCUS_SPD_MIN   = 0;
    SLONG METADATA_PROPERTY_FOCUS_SPD_MAX   = 255;
    SLONG METADATA_PROPERTY_FOCUS_SPD_RESET = 0;

    SLONG METADATA_PROPERTY_IRIS_SPD_INIT   = 0;
    SLONG METADATA_PROPERTY_IRIS_SPD_MIN    = 0;
    SLONG METADATA_PROPERTY_IRIS_SPD_MAX    = 255;
    SLONG METADATA_PROPERTY_IRIS_SPD_RESET  = 0;
#END_IF


// RMS timelines to accumulate hours [RmsNlTimer.axi] (support for up to 5 user-defined timelines, plus 3 snapi-defined timelines)
  CONSTANT LONG TL_OFFSET                    = 0
  CONSTANT LONG TL_MONITOR_1                 = 1;   // Lamp consumption (lower)
  CONSTANT LONG TL_MONITOR_2                 = 2;   // Lamp consumption (upper)
//CONSTANT LONG TL_MONITOR_3                 = 3;   // Unused
//CONSTANT LONG TL_MONITOR_4                 = 4;   // Unused
//CONSTANT LONG TL_MONITOR_5                 = 5;   // Unused

  CONSTANT INTEGER TL_MAX_COUNT              = 2;


(***********************************************************)
(*               INCLUDE DEFINITIONS GO BELOW              *)
(***********************************************************)

// include RMS MONITOR COMMON AXI
#INCLUDE 'RmsMonitorCommon';

// include SNAPI
#INCLUDE 'SNAPI';

#INCLUDE 'RmsNlTimer';
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
  asset.assetType         = RMS_ASSET_TYPE_DOCUMENT_CAMERA;

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
#IF_DEFINED HAS_POWER
    CASE 'asset.power' :
    {
      SWITCH(LOWER_STRING(cValue1))
      {
        CASE 'on'  :
        {
          PULSE[vdvDeviceModule,PWR_ON]
        }
        CASE 'off' :
        {
          PULSE[vdvDeviceModule,PWR_OFF]
        }
      }
    }
#END_IF

#IF_DEFINED HAS_DOCUMENT_CAMERA
    CASE 'document.camera.light.upper.power' :
    {
      SWITCH(nValue1)
      {
        CASE TRUE  :
        {
          PULSE[vdvDeviceModule,DOCCAM_UPPER_LIGHT_ON]
        }
        CASE FALSE :
        {
          IF([vdvDeviceModule,DOCCAM_UPPER_LIGHT_FB])
            PULSE[vdvDeviceModule,DOCCAM_LIGHT]
        }
      }
    }
    CASE 'document.camera.light.lower.power' :
    {
      SWITCH(nValue1)
      {
        CASE TRUE  :
        {
          PULSE[vdvDeviceModule,DOCCAM_LOWER_LIGHT_ON]
        }
        CASE FALSE :
        {
          IF([vdvDeviceModule,DOCCAM_LOWER_LIGHT_FB])
            PULSE[vdvDeviceModule,DOCCAM_LIGHT]
        }
      }
    }
#END_IF

#IF_DEFINED HAS_CAMERA
#END_IF

#IF_DEFINED HAS_SOURCE_SELECT
    CASE 'source.input' :
    {
      SEND_COMMAND vdvDeviceModule,"'INPUTSELECT-',ITOA(RmsNlSnapiGetEnumIndex(cValue1, METADATA_PROPERTY_SOURCE_INPUT))"
    }
#END_IF

    DEFAULT :
    {
    }
  }
}


(**************************************)
(* Call Name: RMSTimerCallback        *)
(* Function:  Timer Callback          *)
(* Param:     None                    *)
(* Return:    None                    *)
(**************************************)
DEFINE_FUNCTION RMSTimerCallback(LONG lTl, LONG lMinutes)
{
  IF(IsRmsReady())
  {
    IF ((lMinutes % 60) == 0)
    {
      IF(assetClientKey != '')
      {
        SWITCH(lTl)
        {
          CASE TL_MONITOR_1 : RmsAssetParameterUpdateValue(assetClientKey,'lamp.consumption.lower',RMS_ASSET_PARAM_UPDATE_OPERATION_INCREMENT,'1')
          CASE TL_MONITOR_2 : RmsAssetParameterUpdateValue(assetClientKey,'lamp.consumption.upper',RMS_ASSET_PARAM_UPDATE_OPERATION_INCREMENT,'1')
        }
      }

      lMinutes = 0
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


#IF_DEFINED HAS_DOCUMENT_CAMERA
  CHANNEL_EVENT[vdvDeviceModule,DOCCAM_LOWER_LIGHT_FB]
  CHANNEL_EVENT[vdvDeviceModule,DOCCAM_UPPER_LIGHT_FB]
  {
    ON :
    {
      SWITCH(CHANNEL.CHANNEL)
      {
        CASE DOCCAM_LOWER_LIGHT_FB : {
          RmsAssetParameterSetValue(assetClientKey, 'document.camera.light.lower.power', 'true' );
          RMSTimerStart (TL_MONITOR_1);
        }
        CASE DOCCAM_UPPER_LIGHT_FB : {
          RmsAssetParameterSetValue(assetClientKey, 'document.camera.light.upper.power', 'true' );
          RMSTimerStart (TL_MONITOR_2);
        }
      }
    }
    OFF :
    {
      SWITCH(CHANNEL.CHANNEL)
      {
        CASE DOCCAM_LOWER_LIGHT_FB : {
          RmsAssetParameterSetValue(assetClientKey, 'document.camera.light.lower.power', 'false');
          RMSTimerStop  (TL_MONITOR_1);
        }
        CASE DOCCAM_UPPER_LIGHT_FB : {
          RmsAssetParameterSetValue(assetClientKey, 'document.camera.light.upper.power', 'false');
          RMSTimerStop  (TL_MONITOR_2);
        }
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

