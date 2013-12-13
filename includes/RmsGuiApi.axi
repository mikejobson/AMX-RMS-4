//*********************************************************************
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
PROGRAM_NAME='RmsGuiApi'

(***********************************************************)
(*                                                         *)
(*  PURPOSE:                                               *)
(*                                                         *)
(*  This include file provides helper functions that can   *)
(*  simplify NetLinx integration with the RMS GUI          *)
(*  component.                                             *)
(*                                                         *)
(***********************************************************)

// this is a compiler guard to ensure that only one copy
// of this include file is incorporated in the final compilation
#IF_NOT_DEFINED __RMS_GUI_API__
#DEFINE __RMS_GUI_API__

// Include RmsApi if it is not already included
#INCLUDE 'RmsApi';

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

RMS_GUI_SET_INTERNAL_COMMAND_HEADER = 'SET_INTERNAL_PANEL-'; 
RMS_GUI_SET_EXTERNAL_COMMAND_HEADER = 'SET_EXTERNAL_PANEL-'; 
RMS_GUI_SET_DEFAULT_EVENT_BOOKING_SUBJECT_COMMAND_HEADER = 'SET_DEFAULT_EVENT_BOOKING_SUBJECT';
RMS_GUI_SET_DEFAULT_EVENT_BOOKING_BODY_COMMAND_HEADER = 'SET_DEFAULT_EVENT_BOOKING_BODY';
RMS_GUI_ENABLE_LED_SUPPORT_COMMAND_HEADER = 'ENABLE_LED_SUPPORT';

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

(***********************************************************)
(* Name:  RmsSetInternalPanel                              *)
(* Args:  DEV baseTouchPanelDps                            *)
(* Args:  DEV rmsTouchPanelDps                             *)
(*                                                         *)
(* Desc:  This function is used to designate an RMS Touch  *)
(*        Panel as an internal panel.                      *)
(*                                                         *)
(* Rtrn:  1 if call was successful                         *)
(*        0 if call was unsuccessful                       *)
(***********************************************************)
DEFINE_FUNCTION CHAR RmsSetInternalPanel(DEV baseTouchPanelDps, DEV rmsTouchPanelDps)
{
    STACK_VAR CHAR rmsCommand[RMS_MAX_CMD_LEN];
    rmsCommand = RmsPackCmdHeader(RMS_GUI_SET_INTERNAL_COMMAND_HEADER);
    rmsCommand = RmsPackCmdParam(rmsCommand,RmsDevToString(baseTouchPanelDPS));
    rmsCommand = RmsPackCmdParam(rmsCommand,RmsDevToString(rmsTouchPanelDps));
    SEND_COMMAND vdvRMSGui, rmsCommand;
    
    RETURN TRUE;
}

(***********************************************************)
(* Name:  RmsSetExternalPanel                              *)
(* Args:  DEV baseTouchPanelDps                            *)
(* Args:  DEV rmsTouchPanelDps                             *)
(*                                                         *)
(* Desc:  This function is used to designate an RMS Touch  *)
(*        Panel as an external panel.                      *)
(*                                                         *)
(* Rtrn:  1 if call was successful                         *)
(*        0 if call was unsuccessful                       *)
(***********************************************************)
DEFINE_FUNCTION CHAR RmsSetExternalPanel(DEV baseTouchPanelDps, DEV rmsTouchPanelDps)
{
    STACK_VAR CHAR rmsCommand[RMS_MAX_CMD_LEN];
    rmsCommand = RmsPackCmdHeader(RMS_GUI_SET_EXTERNAL_COMMAND_HEADER);
    rmsCommand = RmsPackCmdParam(rmsCommand,RmsDevToString(baseTouchPanelDPS));
    rmsCommand = RmsPackCmdParam(rmsCommand,RmsDevToString(rmsTouchPanelDps));
    SEND_COMMAND vdvRMSGui, rmsCommand;
    
    RETURN TRUE;
}

(***********************************************************)
(* Name:  RmsSetDefaultEventBookingSubject                 *)
(* Args:  CHAR subject[]                                   *)
(*                                                         *)
(* Desc:  This function is used to set a default event     *)
(*        booking subject.                                 *)
(*                                                         *)
(* Rtrn:  1 if call was successful                         *)
(*        0 if call was unsuccessful                       *)
(***********************************************************)
DEFINE_FUNCTION CHAR RmsSetDefaultEventBookingSubject(CHAR subject[RMS_MAX_PARAM_LEN])
{
    STACK_VAR CHAR rmsCommand[RMS_MAX_CMD_LEN];
    rmsCommand = RmsPackCmdHeader(RMS_GUI_SET_DEFAULT_EVENT_BOOKING_SUBJECT_COMMAND_HEADER);
    rmsCommand = RmsPackCmdParam(rmsCommand,subject);
    SEND_COMMAND vdvRMSGui, rmsCommand;
    
    RETURN TRUE;
}

(***********************************************************)
(* Name:  RmsSetDefaultEventBookingBody                    *)
(* Args:  CHAR body[]                                      *)
(*                                                         *)
(* Desc:  This function is used to set a default event     *)
(*        booking body.                                    *)
(*                                                         *)
(* Rtrn:  1 if call was successful                         *)
(*        0 if call was unsuccessful                       *)
(***********************************************************)
DEFINE_FUNCTION CHAR RmsSetDefaultEventBookingBody(CHAR body[RMS_MAX_PARAM_LEN])
{
    STACK_VAR CHAR rmsCommand[RMS_MAX_CMD_LEN];
    rmsCommand = RmsPackCmdHeader(RMS_GUI_SET_DEFAULT_EVENT_BOOKING_BODY_COMMAND_HEADER);
    rmsCommand = RmsPackCmdParam(rmsCommand,body);
    SEND_COMMAND vdvRMSGui, rmsCommand;
    
    RETURN TRUE;
}

(***********************************************************)
(* Name:  RmsEnableLedSupport                              *)
(* Args:  CHAR enableLedSupport                            *)
(*                                                         *)
(* Desc:  This function is used to enable or disable LED   *)
(*        support.                                         *)
(*                                                         *)
(* Rtrn:  1 if call was successful                         *)
(*        0 if call was unsuccessful                       *)
(***********************************************************)
DEFINE_FUNCTION CHAR RmsEnableLedSupport(CHAR enableLedSupport)
{
    STACK_VAR CHAR rmsCommand[RMS_MAX_CMD_LEN];
    rmsCommand = RmsPackCmdHeader(RMS_GUI_ENABLE_LED_SUPPORT_COMMAND_HEADER);
    rmsCommand = RmsPackCmdParam(rmsCommand,RmsBooleanString(enableLedSupport));
    SEND_COMMAND vdvRMSGui, rmsCommand;
    
    RETURN TRUE;
}

#END_IF // __RMS_GUI_API__