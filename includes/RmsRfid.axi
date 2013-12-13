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
PROGRAM_NAME='RmsRfid'

(***********************************************************)
(*                                                         *)
(*  PURPOSE:                                               *)
(*                                                         *)
(*  This include file contains the NetLinx sample code to  *)
(*  implement asset tracking in RMS with AMX Anterus RFID  *)
(*  readers and RFID tags.                                 *)
(*                                                         *)
(*  This code was placed in this include file to allow     *)
(*  separation from the main RMS implementation code and   *)
(*  allow for easy inclusion/exclusion.                    *)
(*                                                         *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

vdvRMSRfid        =  41003:1:0  // RMS RFID System Adapter    (Duet Module)

vdvAnterusGateway =  41004:1:0  // Duet RFID Virtual Device   (Duet Module)

dvAnterusReader1  =    108:1:0  // AxLink Anterus RFID Reader #1
dvAnterusReader2  =    109:1:0  // AxLink Anterus RFID Reader #2
dvAnterusReader3  =    110:1:0  // AxLink Anterus RFID Reader #3


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                MODULE CODE GOES BELOW                   *)
(***********************************************************)

// RMS RFID - RFID System Monitor
//   This module is responsible for monitoring RFID
//   readers and tags for an AMX Anterus RFID system.
//   This module will relay RFID information to the
//   RMS system.
//  (Note: RMS server must be enabeld for RFID support.)
DEFINE_MODULE 'RmsAnterusRFIDAdapter_dr4_0_0' mdlRMSAnterusAdapter(vdvRMSRfid,vdvAnterusGateway)


// Anterus RFID Duet Module
//   This module enabled RFID management of AMX
//   Anterus RDIF readers and tags.
DEFINE_MODULE 'AMX_Anterus_Comm_dr1_0_0' mdlAnterusDuetMod(vdvAnterusGateway,dvAnterusReader1)


// RMS RFID Reader Device Monitor
// (include a separate module instance for each physical RFID reader device)
DEFINE_MODULE 'RmsRfidReaderMonitor' mdlRmsRfidReaderMonitorMod_1(vdvRMS,dvAnterusReader1)
DEFINE_MODULE 'RmsRfidReaderMonitor' mdlRmsRfidReaderMonitorMod_2(vdvRMS,dvAnterusReader2)
DEFINE_MODULE 'RmsRfidReaderMonitor' mdlRmsRfidReaderMonitorMod_3(vdvRMS,dvAnterusReader3)


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
