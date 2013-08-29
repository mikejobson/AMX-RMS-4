
//*********************************************************************
//
//             AMX Resource Management Suite  (4.1.5)
//
//*********************************************************************
/*
 *  Legal Notice :
 *
 *     Copyright, AMX LLC, 2012
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
MODULE_NAME='RmsDvx2100HDSwitcherMonitor'(DEV vdvRMS)

(***********************************************************)
(*                                                         *)
(*  PURPOSE:                                               *)
(*                                                         *)
(*  This NetLinx module contains the source code for       *)
(*  monitoring and controlling a DVX switchers in RMS.     *)
(*                                                         *)
(*  This module will register a base set of asset          *)
(*  monitoring parameters, metadata properties, and        *)
(*  contorl methods.  It will update the monitored         *)
(*  parameters as changes from the device are              *)
(*  detected.                                              *)
(*                                                         *)
(***********************************************************)

(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)

DEFINE_DEVICE

// This must be configured with the D:P:S of the DVX Switcher
dvMonitoredDevice = 5002:1:0;

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// This defines maximum string length for the purpose of
// dimentioning array sizes
INTEGER STRING_SIZE                       = 50;
CHAR MAX_INPUT_NAME                       = 20;

// These reflect default maximul values for inputs, ports, etc.
// and as such provide a consistent means to size arrays
INTEGER AUDIO_INPUT_CNT                   = 6;// total ports on the device
INTEGER AUDIO_OUTPUT_CNT                  = 2;
INTEGER VIDEO_INPUT_CNT                   = 6;
INTEGER VIDEO_OUTPUT_CNT                  = 2;
INTEGER MIC_COUNT                         = 2;

CHAR FRONT_PANEL_LOCK_TYPE_ENUM[]                       = 'All|Reserved|Configuration Menu Only'; // Front panel locked values
CHAR MONITOR_ASSET_NAME[]                               = '';                 // Leave it empty to auto-populate the device name
CHAR MONITOR_ASSET_TYPE[]                               = 'Switcher';
CHAR MONITOR_DEBUG_NAME[]                               = 'RmsDvxMon';
CHAR MONITOR_NAME[]                                     = 'RMS DVX Switcher Monitor';
CHAR MONITOR_VERSION[]                                  = '4.1.5';
CHAR SET_AUDIO_OUTPUT_ALL_ENUM[AUDIO_OUTPUT_CNT + 1][4] = { 'All', '1', '2' };
CHAR SET_FRONT_PANEL_LOCKOUT_ENUM[3][STRING_SIZE]       = { 'Unlocked', 'All','Configuration Menu Only' };  // Front panel lockout values
CHAR SET_MIC_INPUT_PLUS_ALL_ENUM[MIC_COUNT + 1][4]      = { 'All', '1', '2' };
CHAR SET_POWER_ENUM[2][STRING_SIZE]                     = { 'ON', 'OFF' };
CHAR SET_VIDEO_INPUT_ONLY_DIGITAL_FORMAT_ENUM[]         = 'HDMI|DVI';     // Valid video input signal formats for lower input ports
CHAR VIDEO_OUTPUT_PORTS[VIDEO_OUTPUT_CNT + 1][4]        = { 'All', '1', '2' };
INTEGER VIDEO_DISPLAY_INPUT_COUNT                       = VIDEO_INPUT_CNT +1; //Input ports plus 0 to disconnect
INTEGER AUDIO_DISPLAY_INPUT_COUNT                       = AUDIO_INPUT_CNT +1;
INTEGER TL_MONITOR                                      = 1;          // Timeline id
LONG DvxMonitoringTimeArray[]                           = {15000};    // Frequency of value update requests
SLONG MAX_VOLUME_LEVEL                                  = 100;        // Max AMP volume level (port 1)
SLONG MIN_VOLUME_LEVEL                                  = 0;

// Device Channels
INTEGER VIDEO_OUTPUT_ENABLE_CHANNEL                     = 70;
INTEGER AUDIO_MUTE_CHANNEL                              = 199;
INTEGER VIDEO_MUTE_CHANNEL                              = 211;

// Device levels
INTEGER VOLUME_LEVEL                                    = 1;

FLOAT dBconversionFactor                                =0.15686;// Used to convert level values(0 - 255) to dB(-20 - +20)

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCTURE Dvx2100
{
  // variables for device capabilities
  CHAR hasFan;
  CHAR hasMicInput;
  CHAR hasTemperatureSensor;

  CHAR audioDSPFirmwareVersion[STRING_SIZE];
  CHAR audioMicEnabled[MIC_COUNT];                  // An array which contains true or false to
                                                    // indicate if a microphone is enabled
  CHAR audioOutputMute;                             // Each array entry contains the audio output
                                                    // mute status (TRUE or FALSE) for a specific channel
  CHAR fanAlarm;                                    // TRUE to FALSE to indicate a fan alarm
  CHAR frontPanelLockType[STRING_SIZE]              // Lock type from valid panel lock types
  CHAR frontPanelLocked;                            // TRUE or FALSE
  CHAR tempAlarm;                                   // TRUE to FALSE to indicate a temperature alarm
  CHAR videoFPGAFirmwareVersion[STRING_SIZE];
  CHAR videoOutputEnabled[VIDEO_OUTPUT_CNT];        // An array which indicates the video output
                                                    // enabled status (TRUE or FALSE) for each channel
  CHAR videoOutputPictureMute;                      // An array which indicates the video output
                                                    // mute status (TRUE or FALSE) for each channel
  CHAR videoOutputAutoResolution[VIDEO_OUTPUT_CNT];         // Video output auto resolution

  INTEGER audioInputCount;
  INTEGER audioOutputCount;                         // The total number of audio outputs
  CHAR audioInputName[AUDIO_INPUT_CNT][MAX_INPUT_NAME];
  INTEGER selectedAudioInput;                       //Only the AMP output(port 1) can be connected to different inputs
  INTEGER audioVolumeAMP;
  SINTEGER audioVolumeLine;
  INTEGER micInputCount;                            // Number if microphone input devices
  INTEGER videoInputCount;
  INTEGER videoInputsAllFormatsCount;               // This is the number of inputs which support all formats
  INTEGER videoInputsOnlyDigitalCount;              // The number of inputs which support only digital formats
  INTEGER videoOutputCount;
  CHAR videoInputName[VIDEO_INPUT_CNT][MAX_INPUT_NAME];
  CHAR videoInputFormat[VIDEO_INPUT_CNT][STRING_SIZE];
  INTEGER selectedVideoInput[VIDEO_INPUT_CNT]
 }

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR devInit = FALSE;
CHAR hasValidDeviceId = FALSE;
DEV_INFO_STRUCT devInfo;
Dvx2100 dvx;                  // RMS device Monitoring Variable

// One DPS entry for each port number
// This array must include all DPS numbers used DVX data event processing
VOLATILE DEV dvxDeviceSet[] = {
                      5002:1:0,
                      5002:2:0,
                      5002:3:0,
                      5002:4:0,
                      5002:5:0,
                      5002:6:0,
                      5002:7:0,
                      5002:8:0,
                      5002:9:0
                    }


// Include RMS MONITOR COMMON AXI
#INCLUDE 'RmsMonitorCommon';

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(* Name:  InitDefaults                                     *)
(* Args:  NONE                                             *)
(*                                                         *)
(* Desc:  Initalize device capabilities.                   *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION InitDefaults()
{
  STACK_VAR INTEGER ndx1;
  STACK_VAR INTEGER ndx2;

  dvx.hasFan                      = FALSE;
  dvx.hasMicInput                 = FALSE;
  dvx.hasTemperatureSensor        = FALSE;

  dvx.audioDSPFirmwareVersion     = '0.0';
  dvx.audioInputCount             = 0;
  dvx.audioOutputCount            = 0;
  dvx.fanAlarm                    = FALSE;
  dvx.micInputCount               = 2;
  dvx.videoFPGAFirmwareVersion    = '0.0';
  dvx.videoInputCount             = 0;
  dvx.videoInputsAllFormatsCount  = 0;
  dvx.videoInputsOnlyDigitalCount = 0;
  dvx.videoOutputCount            = 0;

  SWITCH(devInfo.DEVICE_ID)
  {
    CASE 344:   // DVX-2100HD-SP
    {
      // Make runtime decisions about device capabilites
      hasValidDeviceId                = TRUE;
      dvx.hasFan                      = FALSE;
      dvx.hasMicInput                 = TRUE;
      dvx.hasTemperatureSensor        = FALSE;

      dvx.audioInputCount             = AUDIO_INPUT_CNT;
      dvx.audioOutputCount            = AUDIO_OUTPUT_CNT;

      dvx.micInputCount               = 2;
      dvx.videoInputCount             = VIDEO_INPUT_CNT;
      dvx.videoInputsAllFormatsCount  = VIDEO_INPUT_CNT;//4 DVI-1 multiformat input and 2 HDMI inputs
      dvx.videoOutputCount            = VIDEO_OUTPUT_CNT;
    }

    DEFAULT:
    {
      AMX_LOG(AMX_WARNING, "'RmsDvx2100HDSwitcherMonitor: InitDefaults(): Unexpected DEVICE_ID: ',  ITOA(devInfo.DEVICE_ID)");
      RETURN;
    }
  }

  // Initalize values associated with microphone input
  IF(dvx.hasMicInput == TRUE)
  {
    FOR(ndx1 = 1; ndx1 <= dvx.micInputCount; ndx1++)
    {
      dvx.audioMicEnabled[ndx1]     = FALSE;
    }
  }

  dvx.frontPanelLocked       = FALSE;
  dvx.audioOutputMute        = FALSE;
  dvx.videoOutputPictureMute = FALSE;

  FOR(ndx1 = 1; ndx1 <= dvx.audioOutputCount; ndx1++)
  {
    dvMonitoredDevice.PORT = ndx1;

    // Request the current volume level for each output
    SEND_COMMAND dvxDeviceSet[ndx1], '?VOLUME';
  }

  // Walk through each video output variable and initialize some sane
  // value, then ask the device for the current value
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    dvx.videoOutputEnabled[ndx1]        = TRUE;
    dvx.videoOutputAutoResolution[ndx1] = FALSE;
  }

  // These two items should not change without an init,
  // so only ask for them once
  SEND_COMMAND dvMonitoredDevice, "'?DSP_FWVERSION'";   // Ask for DSP firmware version
  SEND_COMMAND dvMonitoredDevice, "'?FPGA_FWVERSION'";  // Ask for FPGA firmware version

  // Ask for current audio input selected sources
  FOR(ndx1 = 1; ndx1 <= dvx.audioInputCount; ndx1++)
  {
    SEND_COMMAND dvMonitoredDevice, "'?OUTPUT-AUDIO,', ITOA(ndx1)";
    dvx.audioInputName[ndx1] =  "'Source ', ITOA(ndx1)";
    SEND_COMMAND dvxDeviceSet[ndx1], '?AUDIN_NAME';

  }

  // Ask for current video input selected sources
  FOR(ndx1 = 1; ndx1 <= dvx.videoInputCount;ndx1++)
  {
    SEND_COMMAND dvMonitoredDevice, "'?OUTPUT-VIDEO,', ITOA(ndx1)";
    //Capture the user defined Input Source names, if any
    dvx.videoInputName[ndx1] =  "'Source ', ITOA(ndx1)";
    dvx.videoInputFormat[ndx1] = '';
    SEND_COMMAND dvxDeviceSet[ndx1], '?VIDIN_NAME';
    SEND_COMMAND dvxDeviceSet[ndx1], '?VIDIN_FORMAT';
  }

  devInit = TRUE;
}

(***********************************************************)
(* Name: RegisterAsset                                     *)
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
  // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    asset.assetType = 'Unknown';
    asset.description = "'Unsupported device ID: ', ITOA(devInfo.DEVICE_ID)";
  }
  ELSE
  {
    asset.assetType = MONITOR_ASSET_TYPE;
    // perform registration of this
    // AMX Device as a RMS Asset
    //
    // (registering this asset as an 'AMX' asset
    // will pre-populate all available asset
    // data fields with information obtained
    // from a NetLinx DeviceInfo query.)
    RmsAssetRegisterAmxDevice(dvMonitoredDevice, asset);
  }
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

  STACK_VAR CHAR keyName[STRING_SIZE];
  STACK_VAR CHAR propertyCharValue[STRING_SIZE];
  STACK_VAR CHAR propertyName[STRING_SIZE];
  STACK_VAR INTEGER ndx1;
  STACK_VAR INTEGER strLenght;

  // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    RETURN;
  }

  RmsAssetMetadataEnqueueNumber(assetClientKey, 'switcher.input.video.count', 'Video Input Count', dvx.videoInputCount);
  RmsAssetMetadataEnqueueNumber(assetClientKey, 'switcher.output.video.count', 'Video Output Count', dvx.videoOutputCount);

  RmsAssetMetadataEnqueueNumber(assetClientKey, 'switcher.input.audio.count', 'Audio Input Count', dvx.audioInputCount);
  RmsAssetMetadataEnqueueNumber(assetClientKey, 'switcher.output.audio.count', 'Audio Output Count', dvx.audioOutputCount);

  RmsAssetMetadataEnqueueNumber(assetClientKey, 'switcher.input.mic.count', 'Mic Input Count', dvx.micInputCount);

  RmsAssetMetadataEnqueueString(assetClientKey, 'dsp.version', 'Audio DSP Firmware Version', dvx.audioDSPFirmwareVersion);
  RmsAssetMetadataEnqueueString(assetClientKey, 'fpga.version', 'Video FPGA Firmware Version', dvx.videoFPGAFirmwareVersion);

  // Audio Input Name
  FOR(ndx1 = 1; ndx1 <= dvx.audioInputCount; ndx1++)
  {
    keyName         = "'switcher.input.audio.name.', ITOA(ndx1)";
    propertyName    = "'Audio Input ', ITOA(ndx1), ' - Name'";
    propertyCharValue = dvx.audioInputName[ndx1];
    strLenght =LENGTH_STRING(propertyCharValue);
    IF(strLenght > 5){
        propertyCharValue = MID_STRING(propertyCharValue, 5, strLenght);
    }
    RmsAssetMetadataEnqueueString(assetClientKey, keyName, propertyName, propertyCharValue);
  }

  // Video Input Signal Format for source which support all formats
  FOR(ndx1 = 1; ndx1 <= dvx.videoInputCount; ndx1++)
  {
    keyName       = "'switcher.input.video.format.', ITOA(ndx1)";
    propertyName  = "'Video Input ', ITOA(ndx1), ' - Signal Format'";
    RmsAssetMetadataEnqueueString(assetClientKey, keyName, propertyName, dvx.videoInputFormat[ndx1]);
  }

  // Video Input Name
  FOR(ndx1 = 1; ndx1 <= dvx.videoInputCount; ndx1++)
  {
    keyName           = "'switcher.input.video.name.', ITOA(ndx1)";
    propertyName      = "'Video Input ', ITOA(ndx1), ' - Name'";
    propertyCharValue = dvx.videoInputName[ndx1];
    strLenght =LENGTH_STRING(propertyCharValue);
    IF(strLenght > 5){
        propertyCharValue = MID_STRING(propertyCharValue, 5, strLenght);
    }
    RmsAssetMetadataEnqueueString(assetClientKey, keyName, propertyName, propertyCharValue);
  }

  // submit metadata for registration now
  RmsAssetMetadataSubmit(assetClientKey);

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
  STACK_VAR CHAR paramBooleanValue;
  STACK_VAR CHAR paramCharArrayValue[STRING_SIZE];
  STACK_VAR CHAR paramDesc[STRING_SIZE];
  STACK_VAR CHAR paramKey[STRING_SIZE];
  STACK_VAR CHAR paramName[STRING_SIZE];
  STACK_VAR INTEGER ndx1;
  STACK_VAR INTEGER ndx2;

  // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    RETURN;
  }

  // register the default "Device Online" parameter
  RmsAssetOnlineParameterEnqueue (assetClientKey, DEVICE_ID(dvMonitoredDevice));

  // register asset power
  RmsAssetPowerParameterEnqueue(assetClientKey,DEVICE_ID(dvMonitoredDevice));

    // Front Panel Locked
  RmsAssetParameterEnqueueBoolean(
                                    assetClientKey,
                                    'asset.front.panel.lockout',    // Parameter key
                                    'Front Panel Locked',           // Parameter name
                                    'Front panel locked',           // Parameter description
                                    RMS_ASSET_PARAM_TYPE_NONE,      // RMS Asset Parameter (Reporting) Type
                                    dvx.frontPanelLocked,           // Default value
                                    RMS_ALLOW_RESET_NO,             // RMS Asset Parameter Reset
                                    FALSE,                          // Reset value
                                    RMS_TRACK_CHANGES_NO            // RMS Asset Parameter History Tracking
                                );

  // Front Panel Lockout Type
  RmsAssetParameterEnqueueEnumeration(assetClientKey,
                                      'asset.front.panel.lockout.type', // Parameter key
                                      'Front Panel Lockout Type',       // Parameter name
                                      'Front Panel Lockout Type',
                                       RMS_ASSET_PARAM_TYPE_NONE,        // RMS Asset Parameter (Reporting) Type
                                       dvx.frontPanelLockType,           // Default value
                                       FRONT_PANEL_LOCK_TYPE_ENUM,       // Enumeration
                                       RMS_ALLOW_RESET_NO,               // RMS Asset Parameter Reset
                                       '',                               // Reset value
                                       RMS_TRACK_CHANGES_NO              // RMS Asset Parameter History Tracking
                                     );


  // Audio Output Mute
    paramBooleanValue = dvx.audioOutputMute;
    paramDesc         = 'Audio output mute';
    paramKey          = 'switcher.output.audio.mute';
    paramName         = 'Audio Output - Mute';

    RmsAssetParameterEnqueueBoolean(assetClientKey,
                                    paramKey,                   // Parameter key
                                    paramName,                  // Parameter name
                                    paramDesc,                  // Parameter description
                                    RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                    paramBooleanValue,          // Default value
                                    RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                    FALSE,                      // Reset value
                                    RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                    );

  // Audio Output Volume Level Port 1 in AMPs

    paramDesc     = "'Audio AMP output port'";
    paramKey      = "'switcher.output.audio.volume.amp'";
    paramName     = "'Audio Output Volume AMP'";

   RmsAssetParameterEnqueueLevel(assetClientKey,                            // assetClientKey[]
                                 paramKey,                                  //CHAR parameterKey[]
                                 paramName,                                 //CHAR parameterName[]
                                 paramDesc,                                 //CHAR parameterDescription[]
                                 RMS_ASSET_PARAM_TYPE_NONE,                 //CHAR reportingType[]
                                 dvx.audioVolumeAMP,                        //SLONG initialValue,
                                 MIN_VOLUME_LEVEL,                          //SLONG minimumValue,
                                 MAX_VOLUME_LEVEL,                          //SLONG maximumValue,
                                 '%',                                       // units[],
                                 RMS_ALLOW_RESET_NO,                        //CHAR allowReset,
                                 0,                                        //SLONG resetValue,
                                 RMS_TRACK_CHANGES_NO,                      //CHAR trackChanges,
                                 RMS_ASSET_PARAM_BARGRAPH_VOLUME_LEVEL);    //CHAR bargraphKey[]

  // Audio Output Volume Level Port 2 in DBs

    paramDesc     = "'Audio Line output port'";
    paramKey      = "'switcher.output.audio.volume.line'";
    paramName     = "'Audio Output Volume Line'";

    RmsAssetParameterEnqueueNumber(assetClientKey,                            //assetClientKey[]
                                    paramKey,                                 //CHAR parameterKey[]
                                    paramName,                                //CHAR parameterName[]
                                    paramDesc,                                //CHAR parameterDescription[]
                                    RMS_ASSET_PARAM_TYPE_NONE,                //CHAR reportingType[]
                                    dvx.audioVolumeLine,                      //SLONG initialValue,
                                    -20,                                      //SLONG minimumValue,
                                    20,                                       //SLONG maximumValue,
                                    'dB',                                     //units[],
                                    RMS_ALLOW_RESET_NO,                       //CHAR allowReset,
                                    0,                                        //SLONG resetValue,
                                    RMS_TRACK_CHANGES_NO);                    //CHAR trackChanges,

    // Audio Output Selected Source
    paramDesc   = "'Audio output selected source'";
    paramKey    = 'switcher.output.audio.switch.input';
    paramName   = 'Audio Output - Selected Source';
    IF(dvx.selectedAudioInput>0)
    {
      paramCharArrayValue =dvx.audioInputName[dvx.selectedAudioInput];
    }
    ELSE
    {
      paramCharArrayValue='';
    }
    RmsAssetParameterEnqueueString(assetClientKey,
                                   paramKey,                   // Parameter key
                                   paramName,                  // Parameter name
                                   paramDesc,                  // Parameter description
                                   RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                   paramCharArrayValue,        // Default value - ITOA(dvxDeviceInfo.audioOutputSelectedSource[1])
                                   '',                         // Units
                                   RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                   '',                         // Reset value
                                   RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                  );

    // Audio Mic Enabled
    FOR(ndx1 = 1; ndx1 <= dvx.micInputCount; ndx1++)
    {
      paramBooleanValue = dvx.audioMicEnabled[ndx1];
      paramDesc         = "'Audio mic ', ITOA(ndx1), ' enabled'";
      paramKey          = "'switcher.input.mic.enabled.', ITOA(ndx1)";
      paramName         = "'Audio Mic ', ITOA(ndx1), ' - Enabled'";

      RmsAssetParameterEnqueueBoolean(
                                        assetClientKey,
                                        paramKey,                   // Parameter key
                                        paramName,                  // Parameter name
                                        paramDesc,                  // Parameter description
                                        RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                        paramBooleanValue,          // Default value
                                        RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                        FALSE,                      // Reset value
                                        RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                      );
    }

  // Video Output Enabled
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    paramBooleanValue = dvx.videoOutputEnabled[ndx1];
    paramDesc         = "'Video output ', ITOA(ndx1), ' enabled'";
    paramKey          = "'switcher.output.video.enabled.', ITOA(ndx1)";
    paramName         = "'Video Output ', ITOA(ndx1), ' - Enabled'";

    RmsAssetParameterEnqueueBoolean(
                                      assetClientKey,
                                      paramKey,                   // Parameter key
                                      paramName,                  // Parameter name
                                      paramDesc,                  // Parameter description
                                      RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                      paramBooleanValue,          // Default value
                                      RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                      FALSE,                      // Reset value
                                      RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                    );
  }

  // Video Output Picture Mute
    paramBooleanValue = dvx.videoOutputPictureMute;
    paramDesc         = "'Video output picture mute'";
    paramKey          = 'switcher.output.video.mute';
    paramName         = 'Video Output - Picture Mute';

    RmsAssetParameterEnqueueBoolean(
                                      assetClientKey,
                                      paramKey,                   // Parameter key
                                      paramName,                  // Parameter name
                                      paramDesc,                  // Parameter description
                                      RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                      paramBooleanValue,          // Default value
                                      RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                      FALSE,                      // Reset value
                                      RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                    );

  // Video Output Auto Resolution
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    paramBooleanValue    = dvx.videoOutputAutoResolution[ndx1];
    paramDesc           = "'Video output ', ITOA(ndx1), ' Auto Resolution'";
    paramKey            = "'switcher.output.video.auto.resolution.', ITOA(ndx1)";
    paramName           = "'Video Output ', ITOA(ndx1), ' - Auto Resolution'";
    RmsAssetParameterEnqueueBoolean(
                                        assetClientKey,
                                        paramKey,                   // Parameter key
                                        paramName,                  // Parameter name
                                        paramDesc,                  // Parameter description
                                        RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                        paramBooleanValue,          // Default value
                                        RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                        FALSE,                      // Reset value
                                        RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                      );
  }

  // Video Output Selected Source
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    paramCharArrayValue='';
    IF(dvx.selectedVideoInput[ndx1]>0)
    {
      paramCharArrayValue =dvx.videoInputName[dvx.selectedVideoInput[ndx1]];
    }
    paramDesc   = "'Video output ', ITOA(ndx1), ' selected source'"
    paramKey    = "'switcher.output.video.switch.input.', ITOA(ndx1)";
    paramName   = "'Video Output ', ITOA(ndx1), ' - Selected Source'";

    RmsAssetParameterEnqueueString(
                                    assetClientKey,
                                    paramKey,                   // Parameter key
                                    paramName,                  // Parameter name
                                    paramDesc,                  // Parameter description
                                    RMS_ASSET_PARAM_TYPE_NONE,  // RMS Asset Parameter (Reporting) Type
                                    paramCharArrayValue,        // Default value
                                    '',                         // Units
                                    RMS_ALLOW_RESET_NO,         // RMS Asset Parameter Reset
                                    '',                         // Reset value
                                    RMS_TRACK_CHANGES_NO        // RMS Asset Parameter History Tracking
                                  );
  }

  // submit all parameter registrations
  RmsAssetParameterSubmit(assetClientKey);
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
  STACK_VAR CHAR param1[RMS_MAX_PARAM_LEN];
  STACK_VAR CHAR param2[RMS_MAX_PARAM_LEN];
  STACK_VAR CHAR inputSource[1];
  STACK_VAR INTEGER ndx;
  STACK_VAR INTEGER input;

  SELECT
  {
    // Set audio source selection
    ACTIVE(methodKey == 'switcher.output.audio.switch'):
    {
      STACK_VAR INTEGER selectedInput;
      //We have only one audio port and only one control method argument
      //Port number one has been hardcoded
      param1 = RmsParseCmdParam(DATA.TEXT);   // Input port
      IF(LENGTH_STRING(param1)>0)
      {
        inputSource=LEFT_STRING(param1,1);
      }
      ELSE
      {
        inputSource=param1;
      }
      SEND_COMMAND dvMonitoredDevice, "'AI', inputSource, 'O1'";
    }

    // Video source selection
    ACTIVE(methodKey == 'switcher.output.video.switch'):
    {
      param1 = RmsParseCmdParam(DATA.TEXT);     // Output port
      param2 = RmsParseCmdParam(DATA.TEXT);     // Input port

      IF(LENGTH_STRING(param2)>0 && param2 != '0')
      {
        inputSource=LEFT_STRING(param2,1);
      }ELSE
      {
        inputSource=param2;
      }
      IF(param1 == VIDEO_OUTPUT_PORTS[1])
      {
        SEND_COMMAND dvMonitoredDevice, "'VI', inputSource, 'O1,2'";
      }
      ELSE
      {
      SEND_COMMAND dvMonitoredDevice, "'VI', inputSource, 'O', param1";
      }
    }

    // Set audio output volume
    ACTIVE(methodKey == 'switcher.output.audio.volume.amp'):
    {
     param1 = RmsParseCmdParam(DATA.TEXT);
     SEND_COMMAND dvxDeviceSet[1], "'VOLUME ', LEFT_STRING(param1, 2)";
    }

     ACTIVE(methodKey == 'switcher.output.audio.volume.line'):
    {
      param1 = RmsParseCmdParam(DATA.TEXT);
      SEND_COMMAND dvxDeviceSet[2], "'VOLUME ', LEFT_STRING(param1, 3)";
    }

    // Set front panel lockout
    ACTIVE(methodKey == 'asset.front.panel.lockout'):
    {
      STACK_VAR CHAR lockoutState[STRING_SIZE];
      STACK_VAR INTEGER i;
      param1 = RmsParseCmdParam(DATA.TEXT);
      //Case 1: User selected "Unlock" from drop-down
      SELECT
      {
          ACTIVE(param1 == SET_FRONT_PANEL_LOCKOUT_ENUM[1]):// "Unlocked" selected
          {
            //The lock type is irrelevant; unlock all menus
            SEND_COMMAND dvMonitoredDevice, "'FP_LOCKOUT-DISABLE'";
          }
          //Case 2: User selected "All" from drop-down
          ACTIVE(param1==SET_FRONT_PANEL_LOCKOUT_ENUM[2]):
          {
            //1. Change the lock type to all
            SEND_COMMAND dvMonitoredDevice, "'FP_LOCKTYPE-1'";
            //2. Lock the front panel
            SEND_COMMAND dvMonitoredDevice, "'FP_LOCKOUT-ENABLE'";
          }
          //Case 3: User selected "Configuration Menu only" from drop-down
          ACTIVE(param1==SET_FRONT_PANEL_LOCKOUT_ENUM[3]):
          {
            //1. Change the lock type to Configuration Menu Only
            SEND_COMMAND dvMonitoredDevice, "'FP_LOCKTYPE-3'";
            //2. Lock the front panel
            SEND_COMMAND dvMonitoredDevice, "'FP_LOCKOUT-ENABLE'";
          }
      }
    }

    // Set audio mute
    ACTIVE(methodKey == 'switcher.output.audio.mute'):
    {
      STACK_VAR CHAR muteState[STRING_SIZE];
      STACK_VAR INTEGER ndx1;

      param1 = RmsParseCmdParam(DATA.TEXT);
      IF(param1 == '0')
      {
        muteState = 'DISABLED';
      }
      ELSE IF(param1 == '1')
      {
        muteState = 'ENABLED';
      }
      ELSE
      {
        AMX_LOG(AMX_WARNING, "'RmsDvx2100HDSwitcherMonitor: ExecuteAssetControlMethod(): methodKey: ',
                  methodKey, ' param1: ', param1, ' param2: ', param2");
        RETURN;
      }
      SEND_COMMAND dvMonitoredDevice, "'AUDIO_MUTE-', muteState";
    }

    // Set audio Mic State
    ACTIVE(methodKey == 'switcher.output.audio.mic.enabled'):
    {
      STACK_VAR CHAR enableState [STRING_SIZE];
      STACK_VAR INTEGER ndx1;
      STACK_VAR INTEGER basePort;

      param1 = RmsParseCmdParam(DATA.TEXT);
      param2 = RmsParseCmdParam(DATA.TEXT);
      basePort=6;

      IF(param2 == '0')
      {
        enableState = 'DISABLE';
      }
      ELSE IF(param2 == '1')
      {
        enableState = 'ENABLE';
      }
      ELSE
      {
        AMX_LOG(AMX_WARNING, "'RmsDvx2100HDSwitcherMonitor: ExecuteAssetControlMethod(): methodKey: ',
                  methodKey, ' port: ', param1, ' unexpected state: ', param2");
        RETURN;
      }

      IF(UPPER_STRING(param1) == 'ALL')
      {
        FOR(ndx1 = 1; ndx1 <= dvx.micInputCount; ndx1++)
        {
          SEND_COMMAND dvxDeviceSet[basePort +ndx1], "'AUDMIC_ON-', enableState";
        }
      }
      ELSE
      {
        SEND_COMMAND dvxDeviceSet[basePort +ATOI(param1)], "'AUDMIC_ON-', enableState";
      }
    }

    // Video mute
    ACTIVE(methodKey == 'switcher.output.video.mute'):
    {
      STACK_VAR CHAR muteState [STRING_SIZE];
      STACK_VAR INTEGER ndx1;

      param1 = RmsParseCmdParam(DATA.TEXT);
      param2 = RmsParseCmdParam(DATA.TEXT);

      IF(param1 == '0')
      {
        muteState = 'DISABLED';
      }

      ELSE IF(param1 == '1')
      {
        muteState = 'ENABLED';
      }
      ELSE
      {
        AMX_LOG(AMX_WARNING, "'RmsDvx2100HDSwitcherMonitor: ExecuteAssetControlMethod(): methodKey: ',
                  methodKey, ' param1: ', param1, ' param2: ', param2");
        RETURN;
      }
      SEND_COMMAND dvMonitoredDevice, "'VIDEO_MUTE-', muteState";

    }
  }
}

(***********************************************************)
(* Name:  RequestDvxValuesUpdates                          *)
(* Args:  NONE                                             *)
(*                                                         *)
(* Desc:  For device information not managed by channel    *)
(* or level events, this method will query for the current *)
(* va SEND_COMMAND  to dvMonitoredDevice                   *)
(*                                                         *)
(*        This method should not be invoked/called         *)
(*        by any user implementation code.                 *)
(***********************************************************)
DEFINE_FUNCTION RequestDvxValuesUpdates()
{
  STACK_VAR INTEGER ndx1;

  // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    RETURN;
  }

  // These queries apply to the base device
  SEND_COMMAND dvMonitoredDevice, "'?FP_LOCKOUT'";    // Is the front panel locked or unlocked
  SEND_COMMAND dvMonitoredDevice, "'?FP_LOCKTYPE'";   // What is the front panel lock type

  // Get video output information
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    SEND_COMMAND dvxDeviceSet[ndx1], '?VIDOUT_RES_AUTO';
  }
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
 STACK_VAR INTEGER i;
 CHAR prefix[2];
 STACK_VAR CHAR displayAudioInputName[AUDIO_DISPLAY_INPUT_COUNT][MAX_INPUT_NAME];
 STACK_VAR CHAR displayVideoInputName[VIDEO_DISPLAY_INPUT_COUNT][MAX_INPUT_NAME];

 // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    RETURN;
  }

 SET_LENGTH_ARRAY(displayAudioInputName, dvx.audioInputCount + 1);
 SET_LENGTH_ARRAY(displayVideoInputName, dvx.videoInputCount + 1);

 FOR(i=1; i<=dvx.audioInputCount; i++)
  {
    displayAudioInputName[i]=dvx.audioInputName[i];
  }
  displayAudioInputName[dvx.audioInputCount+1]='0';

  FOR(i=1; i<=dvx.videoInputCount; i++)
  {
    displayVideoInputName[i]=dvx.videoInputName[i];
  }
  displayVideoInputName[dvx.videoInputCount+1]='0';

  RmsAssetControlMethodEnqueue(assetClientKey,
                               'asset.front.panel.lockout',
                               'Set Front Panel Lockout',
                               'Set front panel lockout.');

  RmsAssetControlMethodArgumentEnumEx(assetClientKey,
                                      'asset.front.panel.lockout',
                                      0,
                                      'Front Panel Lockout',
                                      'Select front panel lockout',
                                      SET_FRONT_PANEL_LOCKOUT_ENUM[1],
                                      SET_FRONT_PANEL_LOCKOUT_ENUM);

  RmsAssetControlMethodEnqueue(assetClientKey,
                              'switcher.output.audio.switch',
                              'Select Audio Source',
                              'Select audio source');

  RmsAssetControlMethodArgumentEnumEx(assetClientKey,
                                     'switcher.output.audio.switch',
                                      0,
                                      'Audio Inputs',
                                      "'Select Input [0-', ITOA(dvx.audioInputCount),']. Select 0 to disconnect.'",
                                      displayAudioInputName[1],
                                      displayAudioInputName);

  RmsAssetControlMethodEnqueue(assetClientKey,
                               'switcher.output.video.switch',
                               'Select Video Source',
                               'Select video source');

  RmsAssetControlMethodArgumentEnumEx(assetClientKey,
                                      'switcher.output.video.switch',
                                       0,
                                       'Video Outputs',
                                       "'Select Output [1-', ITOA(dvx.videoOutputCount), ']'",
                                       VIDEO_OUTPUT_PORTS[1],
                                       VIDEO_OUTPUT_PORTS);

  RmsAssetControlMethodArgumentEnumEx(assetClientKey,
                                      'switcher.output.video.switch',
                                       1,
                                      'Video Inputs',
                                      "'Select Input [0-', ITOA(dvx.videoInputCount),']. Select 0 to disconnect.'",
                                      displayVideoInputName[1],
                                      displayVideoInputName);
   // Control method for port1
  RmsAssetControlMethodEnqueue(assetClientKey,
                               'switcher.output.audio.volume.amp',
                               'Set AMP Volume',
                               'Set AMP Volume');

  RmsAssetControlMethodArgumentLevel(assetClientKey,
                                    'switcher.output.audio.volume.amp',
                                     0,
                                     'AMP Volume',
                                     'Volume %',
                                      dvx.audioVolumeAMP,
                                      MIN_VOLUME_LEVEL,
                                      MAX_VOLUME_LEVEL,
                                      1);

  //Control method for Line Port2 gain with range -20dB to + 20dB
  RmsAssetControlMethodEnqueue(assetClientKey,
                                'switcher.output.audio.volume.line',
                                'Set Line Volume',
                                'Set Line Volume');
  //Slider control for the Line Volume
  RmsAssetControlMethodArgumentLevel(assetClientKey,                      //CHAR assetClientKey[]
                                    'switcher.output.audio.volume.line',  //CHAR methodKey[],
                                     0,                                   //INTEGER argumentOrdinal,
                                     'Line Volume',                       //CHAR argumentName[]
                                     'Volume dB',                         //CHAR argumentDescription[]
                                     dvx.audioVolumeLine,                 //SLONG argument default value
                                     -20,                                 //min value
                                      20,                                 //max value
                                      1);

  RmsAssetControlMethodEnqueue(assetClientKey,
                               'switcher.output.audio.mute',
                               'Set Audio Mute',
                               'Set audio mute');

  RmsAssetControlMethodArgumentBoolean(assetClientKey,
                                      'switcher.output.audio.mute',
                                       0,
                                       'All outputs',
                                       'Mute',
                                       FALSE);

  RmsAssetControlMethodEnqueue(assetClientKey,
                               'switcher.output.audio.mic.enabled',
                               'Set Audio Mic State',
                               'Set Audio Mic State');

  RmsAssetControlMethodArgumentEnumEx(
                                      assetClientKey,
                                      'switcher.output.audio.mic.enabled',
                                      0,
                                      'Select Microphone',
                                      'Select Mic Input',
                                      SET_MIC_INPUT_PLUS_ALL_ENUM[1],
                                      SET_MIC_INPUT_PLUS_ALL_ENUM);

  RmsAssetControlMethodArgumentBoolean(assetClientKey,
                                      'switcher.output.audio.mic.enabled',
                                      1,
                                      'On/Off',
                                      'On',
                                      FALSE);

  RmsAssetControlMethodEnqueue(assetClientKey,
                              'switcher.output.video.mute',
                              'Set Video Mute',
                              'Set video mute');

  RmsAssetControlMethodArgumentBoolean(assetClientKey,
                                       'switcher.output.video.mute',
                                       0,
                                       'All outputs',
                                       'Mute',
                                       FALSE);

  // when finished enqueuing all asset control methods and
  // arguments for this asset, we just need to submit
  // them to finalize and register them with the RMS server
  RmsAssetControlMethodsSubmit(assetClientKey);
}

(************************************************************)
(* Name:  SynchronizeAssetMetadata                          *)
(* Args:  -none-                                            *)
(*                                                          *)
(* Desc:  This is a callback method that is invoked by      *)
(*        RMS to notify this module that it is time to      *)
(*        update/synchronize this asset metadata properties *)
(*        with RMS if needed.                               *)
(*                                                          *)
(*        This method should not be invoked/called          *)
(*        by any user implementation code.                  *)
(************************************************************)
DEFINE_FUNCTION SynchronizeAssetMetadata()
{

  STACK_VAR CHAR keyName[STRING_SIZE];
  STACK_VAR CHAR propertyCharValue[STRING_SIZE];
  STACK_VAR CHAR paramKey[STRING_SIZE];
  STACK_VAR INTEGER ndx1;

  // If this does not have a valid device ID, simply return without doing anything
  IF(hasValidDeviceId == FALSE)
  {
    RETURN;
  }

  RmsAssetMetadataUpdateNumber(assetClientKey, 'switcher.input.video.count', dvx.videoInputCount);
  RmsAssetMetadataUpdateNumber(assetClientKey, 'switcher.output.video.count', dvx.videoOutputCount);

  RmsAssetMetadataUpdateNumber(assetClientKey, 'switcher.input.audio.count', dvx.audioInputCount);
  RmsAssetMetadataUpdateNumber(assetClientKey, 'switcher.output.audio.count', dvx.audioOutputCount);

  RmsAssetMetadataUpdateNumber(assetClientKey, 'switcher.input.mic.count', dvx.micInputCount);

  RmsAssetMetadataUpdateString(assetClientKey, 'dsp.version', dvx.audioDSPFirmwareVersion);
  RmsAssetMetadataUpdateString(assetClientKey, 'fpga.version', dvx.videoFPGAFirmwareVersion);

  // Audio Input Name
  FOR(ndx1 = 1; ndx1 <= dvx.audioInputCount; ndx1++)
  {
    keyName = "'switcher.input.audio.name.', ITOA(ndx1)";
    propertyCharValue = "'Audio input ', ITOA(ndx1), ' name'";
    RmsAssetMetadataUpdateString(assetClientKey, keyName, propertyCharValue);
  }

  // Video Input Signal Format for source which support all formats
  FOR(ndx1 = 1; ndx1 <= dvx.videoInputCount; ndx1++)
  {
    keyName = "'switcher.input.video.format.', ITOA(ndx1)";
    RmsAssetMetadataUpdateString(assetClientKey, keyName, dvx.videoInputFormat[ndx1]);
  }

  // Video Input Name
  FOR(ndx1 = 1; ndx1 <= dvx.videoInputCount; ndx1++)
  {
    keyName           = "'switcher.input.video.name.', ITOA(ndx1)";
    propertyCharValue = "'Video input ', ITOA(ndx1), ' name'";
    RmsAssetMetadataUpdateString(assetClientKey, keyName, propertyCharValue);
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
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION SynchronizeAssetParameters()
{
  STACK_VAR CHAR paramBooleanValue;
  STACK_VAR CHAR paramCharArrayValue[STRING_SIZE];
  STACK_VAR CHAR paramKey[STRING_SIZE];
  STACK_VAR INTEGER ndx1;
  STACK_VAR INTEGER ndx2;
  STACK_VAR SLONG paramNumValue;

  // update device online parameter value
  RmsAssetOnlineParameterUpdate(assetClientKey, DEVICE_ID(dvMonitoredDevice));

  // update asset power parameter value
  RmsAssetPowerParameterUpdate(assetClientKey,DEVICE_ID(dvMonitoredDevice));

  paramKey = 'asset.front.panel.lockout';
  paramBooleanValue = dvx.frontPanelLocked;
  RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

  paramKey = 'asset.front.panel.lockout.type';
  paramCharArrayValue = dvx.frontPanelLockType;
  RmsAssetParameterEnqueueSetValue(assetClientKey, paramKey, paramCharArrayValue);

  paramKey = 'switcher.output.audio.mute';
  paramBooleanValue = dvx.audioOutputMute; //Only one value for both ports
  RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

  paramKey = "'switcher.output.audio.switch.input'";
  IF(dvx.selectedAudioInput>0)
  {
  paramCharArrayValue =dvx.audioInputName[dvx.selectedAudioInput];
  }ELSE
  {
  paramCharArrayValue='';
  }
  RmsAssetParameterEnqueueSetValue(assetClientKey, paramKey, paramCharArrayValue);

  //Update AMP port volume
  paramKey = "'switcher.output.audio.volume.amp'";
  paramNumValue = dvx.audioVolumeAMP;
  RmsAssetParameterEnqueueSetValueLevel(assetClientKey, paramKey, paramNumValue);

  //Update Line port volume
  paramKey = "'switcher.output.audio.volume.line'";
  paramNumValue = dvx.audioVolumeLine;
  RmsAssetParameterEnqueueSetValueNumber(assetClientKey, paramKey, paramNumValue);

  IF(dvx.hasMicInput == TRUE)
  {
    FOR(ndx1 = 1; ndx1 <= dvx.micInputCount; ndx1++)
    {
      RmsAssetParameterEnqueueSetValueBoolean(
                                              assetClientKey,
                                              "'switcher.input.mic.enabled.', ITOA(ndx1)",
                                              dvx.audioMicEnabled[ndx1]);
    }
  }

  // Sync video output parameters
  FOR(ndx1 = 1; ndx1 <= dvx.videoOutputCount; ndx1++)
  {
    paramKey = "'switcher.output.video.enabled.', ITOA(ndx1)";
    paramBooleanValue = dvx.videoOutputEnabled[ndx1];
    RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

    paramKey = "'switcher.output.video.auto.resolution.', ITOA(ndx1)";;
    paramBooleanValue = dvx.videoOutputAutoResolution[ndx1];
    RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

    paramKey = "'switcher.output.video.switch.input.', ITOA(ndx1)";
    ndx2=dvx.selectedVideoInput[ndx1];
    IF(ndx2 >0)
    {
    paramCharArrayValue =dvx.videoInputName[ndx2];
    }ELSE
    {
    paramCharArrayValue='';
    }
    RmsAssetParameterEnqueueSetValue(assetClientKey, paramKey, paramCharArrayValue );
  }

    paramKey = 'switcher.output.video.mute';
    paramBooleanValue = dvx.videoOutputPictureMute;
    RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

    paramKey = 'switcher.output.audio.mute';
    paramBooleanValue = dvx.audioOutputMute;
    RmsAssetParameterEnqueueSetValueBoolean(assetClientKey, paramKey, paramBooleanValue);

   // submit all the pending parameter updates now
    RmsAssetParameterUpdatesSubmit(assetClientKey);
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
DEFINE_FUNCTION ResetAssetParameterValue(CHAR parameterKey[],CHAR parameterValue[])
{
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvMonitoredDevice]
{
  ONLINE:
  {
    DEVICE_INFO(dvMonitoredDevice, devInfo);    // Populate version, etc. information

    // Since all the devices are processed by this handler,
    // only perform these tasks if they have not already been run
    IF(devInit == FALSE)
    {
      InitDefaults();
    }

    // For device values not managed by channel or level events, ask the
    // device for those values not
    RequestDvxValuesUpdates();

    IF(!TIMELINE_ACTIVE(TL_MONITOR))
    {
      TIMELINE_CREATE(TL_MONITOR,DvxMonitoringTimeArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT);
    }
  }

  OFFLINE:
  {
    devInit = FALSE;

    // if a panel monitoring timeline was created and is running, then permanently
    // destroy the panel monitoring timeline while the panel is offline.
    IF(TIMELINE_ACTIVE(TL_MONITOR))
    {
      TIMELINE_KILL(TL_MONITOR);
    }

    IF(assetRegistered)
    {
      // update device online parameter value
      RmsAssetOnlineParameterUpdate(assetClientKey, DEVICE_ID(dvMonitoredDevice));
    }
  }
}

DATA_EVENT[dvxDeviceSet]
{
  COMMAND:
  {
    STACK_VAR CHAR header[RMS_MAX_HDR_LEN];
    STACK_VAR CHAR param1[RMS_MAX_PARAM_LEN];
    STACK_VAR CHAR param2[RMS_MAX_PARAM_LEN];
    STACK_VAR DEV eventDevice;
    STACK_VAR INTEGER eventDeviceNdx;
    STACK_VAR INTEGER eventDeviceNumber;
    STACK_VAR INTEGER devicePort;

    // parse RMS command header
    header  = UPPER_STRING(RmsParseCmdHeader(DATA.TEXT));
    //Determine what device created the data event
    eventDeviceNdx = GET_LAST(dvxDeviceSet);
    eventDevice = dvxDeviceSet[eventDeviceNdx];
    eventDeviceNumber = eventDevice.NUMBER;
    devicePort = eventDevice.PORT;

    SELECT
    {
      // Digital signal processor version metadata
      ACTIVE(header == 'DSP_FWVERSION'):
      {
        param1  = RmsParseCmdParam(DATA.TEXT);
        REMOVE_STRING(param1,'v',1);      // eliminate any 'v' prefix character
        dvx.audioDSPFirmwareVersion = param1;
        IF(IsRmsReadyForParameterUpdates())
        {
            RmsAssetMetadataUpdateString(assetClientKey, 'dsp.version', param1);
        }
      }

          // FPGA firmware version metadata
      ACTIVE(header == 'FPGA_FWVERSION'):
      {
        param1  = RmsParseCmdParam(DATA.TEXT);
        REMOVE_STRING(param1,'v',1);      // eliminate any 'v' prefix character
        dvx.videoFPGAFirmwareVersion = param1;
        IF(IsRmsReadyForParameterUpdates())
        {
            RmsAssetMetadataUpdateString(assetClientKey, 'fpga.version', param1);
        }
      }

      // This data event handler is only used to provide initial volume information
      // when the device comes online
      ACTIVE(header == 'VOLUME'):
      {
        STACK_VAR INTEGER newVolume;
        STACK_VAR SINTEGER lineVolume;

        param1 = RmsParseCmdParam(DATA.TEXT);
        IF(devicePort ==1)
        {
            newVolume = ATOI(param1);
            IF(newVolume != dvx.audioVolumeAMP)
            {
                dvx.audioVolumeAMP=newVolume;
                IF(IsRmsReadyForParameterUpdates())
                {
                    RmsAssetParameterSetValueLevel(assetClientKey,'switcher.output.audio.volume.amp',newVolume);
                }
            }
        }
        ELSE IF(devicePort==2)
        {
            lineVolume = ATOI(param1);
            IF(lineVolume != dvx.audioVolumeLine)
            {
                dvx.audioVolumeLine=lineVolume;
                IF(IsRmsReadyForParameterUpdates())
                {
                    RmsAssetParameterSetValueNumber(assetClientKey,'switcher.output.audio.volume.line',lineVolume);
                }
            }
        }
      }

      // Front panel lockout
      ACTIVE(header == 'FP_LOCKOUT'):
      {
        STACK_VAR CHAR newState;

        param1  = RmsParseCmdParam(DATA.TEXT);
        IF(param1 == 'ENABLED')
        {
          newState = TRUE;
        }
        ELSE (*param1 == 'DISABLED'*)
        {
          newState = FALSE;
        }

        IF(dvx.frontPanelLocked != newState)
        {
          dvx.frontPanelLocked = newState;
          IF( IsRmsReadyForParameterUpdates())
          {
            RmsAssetParameterSetValueBoolean(assetClientKey, 'asset.front.panel.lockout', newState);
          }
        }
      }

      // Front panel lock type
      ACTIVE(header == 'FP_LOCKTYPE'):
      {
        STACK_VAR CHAR newLockType[30];
        STACK_VAR INTEGER lockTypeNdx;

        param1  = RmsParseCmdParam(DATA.TEXT);
        lockTypeNdx = ATOI(param1);
        newLockType = RmsGetEnumValue(lockTypeNdx, FRONT_PANEL_LOCK_TYPE_ENUM);

        // if there is a change update struct and RMS
        IF((UPPER_STRING(dvx.frontPanelLockType) != UPPER_STRING(newLockType))|| (dvx.frontPanelLockType==''))
        {
          dvx.frontPanelLockType = newLockType;
          IF( IsRmsReadyForParameterUpdates())
          {
            RmsAssetParameterSetValue(assetClientKey, 'asset.front.panel.lockout.type', newLockType);
          }
        }
      }

      ACTIVE(header == 'AUDMIC_ON'):
      {
        STACK_VAR CHAR micON;
        param1  = RmsParseCmdParam(DATA.TEXT);
        param2  = RmsParseCmdParam(DATA.TEXT);
        IF (param1=='ENABLED')
        {
            dvx.audioMicEnabled[dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT-6] = TRUE;
            micON=TRUE;
        }
        ELSE IF (param1=='DISABLED'){
            dvx.audioMicEnabled[dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT-6] = FALSE;
            micON=FALSE;
        }
        IF( IsRmsReadyForParameterUpdates())
        {
            RmsAssetParameterSetValueBoolean(assetClientKey,
                                             "'switcher.input.mic.enabled.', ITOA(dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT-6)",
                                             micON);
        }
      }

      ACTIVE(header == 'AUDIN_NAME'):
      {
        STACK_VAR CHAR newName[MAX_INPUT_NAME];

        newName ="ITOA(devicePort), ' - ', RmsParseCmdParam(DATA.TEXT)";
        // if there is a change update struct and RMS
        IF(UPPER_STRING(dvx.audioInputName[devicePort]) != UPPER_STRING(newName))
        {
          dvx.audioInputName[devicePort] = newName;

          IF( IsRmsReadyForParameterUpdates())
          {
          RmsAssetParameterSetValue(assetClientKey,  "'switcher.input.audio.name.', ITOA(devicePort)", newName);
          }
        }
      }
      // Video output scale
      ACTIVE(header == 'VIDOUT_RES_AUTO'):
      {
        STACK_VAR CHAR autoRes;

        param1  = RmsParseCmdParam(DATA.TEXT);
        IF (param1=='ENABLED')
        {
            autoRes=TRUE;
        }
        ELSE IF (param1=='DISABLED')
        {
            autoRes=FALSE;
        }

        // if there is a change update struct and RMS
        IF(dvx.videoOutputAutoResolution[devicePort] != autoRes)
        {
          dvx.videoOutputAutoResolution[devicePort] = autoRes;
          IF( IsRmsReadyForParameterUpdates())
          {
            RmsAssetParameterSetValueBoolean(assetClientKey,  "'switcher.output.video.auto.resolution.', ITOA(devicePort)", autoRes);
          }
        }
      }

      ACTIVE(header == 'VIDIN_NAME'):
      {
        STACK_VAR CHAR newName[MAX_INPUT_NAME];

        newName = "ITOA(devicePort), ' - ', RmsParseCmdParam(DATA.TEXT)";
        // if there is a change update struct and RMS
        IF(UPPER_STRING(dvx.videoInputName[devicePort]) != UPPER_STRING(newName))
        {
          dvx.videoInputName[devicePort] = newName;
          IF( IsRmsReadyForParameterUpdates())
          {
          RmsAssetParameterSetValue(assetClientKey,  "'switcher.input.video.name.', ITOA(devicePort)", newName);
          }
        }
      }

       ACTIVE(header == 'VIDIN_FORMAT'):
      {
        param1=RmsParseCmdParam(DATA.TEXT);

        IF(dvx.videoInputFormat[devicePort] != param1)
        {
          dvx.videoInputFormat[devicePort] = param1;
          IF( IsRmsReadyForParameterUpdates())
          {
          RmsAssetParameterSetValue(assetClientKey,  "'switcher.input.video.format.', ITOA(devicePort)", param1);
          }
        }
      }

      // Events for queries for connections between inputs and outputs go here
      // This applies to both audio and video
      ACTIVE(LEFT_STRING(header,8) == 'SWITCH'):
      {
        STACK_VAR CHAR input[2];
        STACK_VAR CHAR mediaRouteInfo[RMS_MAX_PARAM_LEN];
        STACK_VAR CHAR media[5];
        STACK_VAR CHAR output[2];
        STACK_VAR INTEGER inputNumber;
        STACK_VAR INTEGER ndx;
        STACK_VAR INTEGER outputNumber;
        STACK_VAR CHAR paramKey[STRING_SIZE];
        STACK_VAR CHAR paramValue[STRING_SIZE];

        param1  = RmsParseCmdParam(DATA.TEXT);
        mediaRouteInfo = param1;
        REMOVE_STRING(mediaRouteInfo, 'L', 1);
        media = LEFT_STRING(mediaRouteInfo, 5);       // AUDIO or VIDEO
        REMOVE_STRING(mediaRouteInfo, media, 1);
        REMOVE_STRING(mediaRouteInfo, 'I', 1);
        input = MID_STRING(mediaRouteInfo, 1, FIND_STRING(mediaRouteInfo, 'O', 1) - 1);
        REMOVE_STRING(mediaRouteInfo, "input,'O'", 1);

        output = mediaRouteInfo;
        outputNumber = ATOI(output);
        inputNumber = ATOI(input);
        paramValue='';

        // Parse video connection routing information
        IF(media == 'VIDEO')
        {
            IF(outputNumber !=0)//If the user selects both ports, two separate responses will be received
            {
                IF(dvx.selectedVideoInput[outputNumber]!=inputNumber)
                {
                    dvx.selectedVideoInput[outputNumber]=inputNumber;
                    paramKey = "'switcher.output.video.switch.input.', output";
                    IF(inputNumber >0)
                    {
                    paramValue = dvx.videoInputName[inputNumber];
                    }
                    IF( IsRmsReadyForParameterUpdates())
                    {
                    RmsAssetParameterSetValue(assetClientKey, paramKey, paramValue);
                    }
                }
            }
        }

        // Process audio connection routing
        ELSE IF(media == 'AUDIO')
        {
          // If output number is 0, disconnect inputs
            IF(outputNumber != 0 )
            {
                IF(dvx.selectedAudioInput!=inputNumber)
                {
                    dvx.selectedAudioInput= inputNumber;
                    paramKey = "'switcher.output.audio.switch.input'";
                    IF(inputNumber >0)
                    {
                    paramValue = dvx.audioInputName[inputNumber];
                    }
                    IF( IsRmsReadyForParameterUpdates())
                    {
                    RmsAssetParameterSetValue(assetClientKey, paramKey, paramValue);
                    }
                }
            }
        }
        ELSE
        {
          AMX_LOG(AMX_WARNING, "'RmsDvx2100HDSwitcherMonitor: DATA_EVENT.COMMAND: header: SWITCH ,
                    unexpected media type: ', media");
        }
      }

    }
  }
}

(***********************************************************)
(* Channel event for audio output mute                     *)
(***********************************************************)
CHANNEL_EVENT[dvxDeviceSet, AUDIO_MUTE_CHANNEL]
{
  ON:
  {
    dvx.audioOutputMute = TRUE;
    IF( IsRmsReadyForParameterUpdates())
    {
    RmsAssetParameterSetValueBoolean(
                                      assetClientKey,
                                      'switcher.output.audio.mute',
                                      TRUE);
    }
  }
  OFF:
  {
     dvx.audioOutputMute = FALSE;
    IF( IsRmsReadyForParameterUpdates())
    {
    RmsAssetParameterSetValueBoolean(assetClientKey,
                                       'switcher.output.audio.mute',
                                        FALSE);
    }
  }
}

(***********************************************************)
(* Channel event for video output enable                     *)
(***********************************************************)
CHANNEL_EVENT[dvxDeviceSet, VIDEO_OUTPUT_ENABLE_CHANNEL]
{
  ON:
  {
    dvx.videoOutputEnabled[dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT] = TRUE;
    IF( IsRmsReadyForParameterUpdates())
    {
    RmsAssetParameterSetValueBoolean(assetClientKey,
                                        "'switcher.output.video.enabled.', ITOA(dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT)",
                                        TRUE);
    }
  }
  OFF:
  {
    dvx.videoOutputEnabled[dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT] = FALSE;
    IF( IsRmsReadyForParameterUpdates())
    {
    RmsAssetParameterSetValueBoolean(assetClientKey,
                                     "'switcher.output.video.enabled.', ITOA(dvxDeviceSet[GET_LAST(dvxDeviceSet)].PORT)",
                                      FALSE);
    }
  }
}
(***********************************************************)
(* Channel event for video output mute                     *)
(***********************************************************)
CHANNEL_EVENT[dvxDeviceSet, VIDEO_MUTE_CHANNEL]
{
  ON:
  {
   dvx.videoOutputPictureMute = TRUE;
   IF( IsRmsReadyForParameterUpdates())
   {
    RmsAssetParameterSetValueBoolean(assetClientKey,
                                     'switcher.output.video.mute',
                                     TRUE);
    }
  }
  OFF:
  {
    dvx.videoOutputPictureMute = FALSE;
    IF( IsRmsReadyForParameterUpdates())
    {
    RmsAssetParameterSetValueBoolean(assetClientKey,
                                         'switcher.output.video.mute',
                                         FALSE);
    }
  }
}

(***********************************************************)
(* Level event for output volume                           *)
(***********************************************************)
LEVEL_EVENT[dvxDeviceSet[1],VOLUME_LEVEL]
{
   dvx.audioVolumeAMP=RmsScaleStdLevelToPercent(LEVEL.VALUE);
   IF( IsRmsReadyForParameterUpdates())
   {
      //Convert the Level value to percent, because the RMS Server expects percent value
      RmsAssetParameterSetValueLevel(assetClientKey,
                                    'switcher.output.audio.volume.amp',
                                    RmsScaleStdLevelToPercent(LEVEL.VALUE));
   }
}

(***********************************************************)
(* Level event for output volume on port 2                 *)
(***********************************************************)
LEVEL_EVENT[dvxDeviceSet[2],VOLUME_LEVEL]
{
  STACK_VAR FLOAT level_TO_dB;
  STACK_VAR SLONG whole_number;

  IF(dvx.audioVolumeLine != LEVEL.VALUE)
  {
	  //Convert the Level value to decibel
		level_TO_dB=LEVEL.VALUE*dBconversionFactor;
		whole_number=RmsRoundToSignedInt(level_TO_dB)-20;
    dvx.audioVolumeLine=TYPE_CAST(whole_number);
    IF( IsRmsReadyForParameterUpdates())
    {
      RmsAssetParameterSetValueNumber(assetClientKey,
                                      'switcher.output.audio.volume.line',
                                      whole_number);
    }
  }
}

(***********************************************************)
(* Timeline for data structure update/refresh              *)
(***********************************************************)
TIMELINE_EVENT[TL_MONITOR]
{
  IF(hasValidDeviceId == TRUE)
  {
      SWITCH(TIMELINE.SEQUENCE)
      {
        CASE 1:       // This timeline sequence will ask for current parameter values
        {
          RequestDvxValuesUpdates();
        }
      }
  }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
