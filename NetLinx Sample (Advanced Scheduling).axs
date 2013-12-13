//**********************************************************
//
//       AMX Resource Management Suite (4.1.13)
//
//**********************************************************
PROGRAM_NAME='NetLinx Sample (Advanced Scheduling)'

(***********************************************************)
(* Note: Several commands create a data event as well as   *)
(* execute a callback, to reduce program complexity, only  *)
(* callback functions are shown.                           *)
(***********************************************************)


(***********************************************************)
(* !!Note!! Both supportConferenceRoomLocationId and       *)
(* salesConferenceRoomLocationId must be assigned          *)
(* location ID's which are correct for your site.          *)
(***********************************************************)

(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvMaster            = 0:1:0      // Control Systems Master
vdvRMS              = 41001:1:0  // RMS Client Engine VDV      (Duet Module)
dvDebug             = 0:0:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

CHAR BOOLEANS[2][5] = { 'FALSE', 'TRUE'};
INTEGER defaultMeetingLength = 15;            // For demo purposes, assume a default meeting length
INTEGER extendLength = 5;
LONG TL1 = 1;                                 // TIMELINE ID
LONG salesConferenceRoomLocationId = 8;       // Assign a valid location ID for your site 
LONG supportConferenceRoomLocationId = 3;     // Assign a valid location ID for your site     

// Maximum parameter length for parsing/packing functions
#IF_NOT_DEFINED RMS_MAX_PARAM_LEN
RMS_MAX_PARAM_LEN           = 250
#END_IF

// Maximum CHAR array size LDATE/TIME strings
#IF_NOT_DEFINED RMS_MAX_DATE_TIME_LEN
RMS_MAX_DATE_TIME_LEN       = 10
#END_IF

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR bookingQueryDate[RMS_MAX_DATE_TIME_LEN];           // CHAR[] in the format 'mm/dd/yyyy'
CHAR meetingStartDate[RMS_MAX_DATE_TIME_LEN];           // CHAR[] in the format 'mm/dd/yyyy'
CHAR meetingStartTime[RMS_MAX_DATE_TIME_LEN];           // CHAR[] in the format '23:59:59'
CHAR nowDate[RMS_MAX_DATE_TIME_LEN];                    // Current date in the format 'mm/dd/yyyy'
CHAR salesStatusMeetingBookingId[RMS_MAX_PARAM_LEN];
CHAR summaryDailyDate[RMS_MAX_PARAM_LEN];               // CHAR[] in the format 'mm/dd/yyyy'
CHAR supportStatusMeetingBookingId[RMS_MAX_PARAM_LEN];
LONG TimeArray[18]                                      // TIMELINE related entry
SINTEGER currentHour;
SINTEGER currentMinute;
SINTEGER endWorkDayHour = 18;                           // For demo purposes, End of the work day
SINTEGER meetingStartHour;
SINTEGER meetingStartMinute;
SINTEGER startWorkDayHour = 7;                          // For demo purposes, Start of the work day
SINTEGER summariesDailyQueryDayOfTheMonth;              // Day of the month 1 - 31


(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)



(***********************************************************)
(*                                                         *)
(* !!Note!! all #DEFINE INCLUDE... entries must be in      *)
(*  place before #INCLUDE 'RmsSchedulingApi'               *)
(*                                                         *)
(* Also note that for quick reference, the #DEFINE         *)
(* required for each callback is added and commented out   *)
(* before each callback function definition. There is no   *)
(* need to uncomment these entries since they were added   *)
(* only to clarify their association with a specific       *)
(* callback.                                               *)
(*                                                         *)
(***********************************************************)

#DEFINE INCLUDE_SCHEDULING_BOOKINGS_RECORD_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_BOOKING_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_ACTIVE_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_NEXT_ACTIVE_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_BOOKING_SUMMARIES_DAILY_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_BOOKING_SUMMARY_DAILY_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_CREATE_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_EXTEND_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_END_RESPONSE_CALLBACK
#DEFINE INCLUDE_SCHEDULING_ACTIVE_UPDATED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_NEXT_ACTIVE_UPDATED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_EVENT_ENDED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_EVENT_STARTED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_EVENT_UPDATED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_MONTHLY_SUMMARY_UPDATED_CALLBACK
#DEFINE INCLUDE_SCHEDULING_DAILY_COUNT_CALLBACK

// Include the RMS Scheduling API
#INCLUDE 'RmsSchedulingApi';

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

(***********************************************************)
(* Name:  RmsEventSchedulingBookingsRecordResponse   *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* ?SCHEDULING.BOOKINGS-<start-date>(,<location-id>)       *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingsRequest(CHAR startDate[], LONG locationId)   *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_BOOKINGS_RECORD_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingBookingsRecordResponse(CHAR isDefaultLocation, 
                                                              INTEGER recordIndex, 
                                                              INTEGER recordCount, 
                                                              CHAR bookingId[], 
                                                              RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingBookingsRecordResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  SEND_STRING dvDebug, "'recordCount: ', ITOA(recordCount)";
  SEND_STRING dvDebug, "'recordIndex: ', ITOA(recordIndex)";
  ShowRmsEventBookingResponse(eventBookingResponse);
    
  // Ignore the booking id if it is not valid
  IF(eventBookingResponse.bookingId != 'N/A')
  {
  	// Was this a Sales booking event?
	  IF(FIND_STRING(eventBookingResponse.subject, 'Sales', 1) > 0 )
	  {
	    salesStatusMeetingBookingId = eventBookingResponse.bookingId;
	  }
	  // Is this a support booking event?
	  ELSE IF(FIND_STRING(eventBookingResponse.subject, 'Support', 1) > 0)
	  {
	    supportStatusMeetingBookingId = eventBookingResponse.bookingId;
	  }
  }
}

(***********************************************************)
(* Name:  RmsEventSchedulingBookingResponse                *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* ?SCHEDULING.BOOKING-<booking-id>(,<location-id>)        *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingRequest(CHAR bookingId[], LONG locationId)    *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_BOOKING_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingBookingResponse(CHAR isDefaultLocation, 
                                                        CHAR bookingId[], 
                                                        RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingBookingResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingActiveResponse                 *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* ?SCHEDULING.BOOKING.ACTIVE-(<location-id>)              *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingActiveRequest(LONG locationId)                *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_ACTIVE_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingActiveResponse(CHAR isDefaultLocation, 
                                                      INTEGER recordIndex, 
                                                      INTEGER recordCount, 
                                                      CHAR bookingId[], 
                                                      RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingActiveResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  SEND_STRING dvDebug, "'recordCount: ', ITOA(recordCount)";
  SEND_STRING dvDebug, "'recordIndex: ', ITOA(recordIndex)";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingNextActiveResponse             *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* ?SCHEDULING.BOOKING.NEXT.ACTIVE-(<location-id>)         *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingNextActiveRequest(LONG locationId)            *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_NEXT_ACTIVE_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingNextActiveResponse(CHAR isDefaultLocation, 
                                                          INTEGER recordIndex, 
                                                          INTEGER recordCount, 
                                                          CHAR bookingId[], 
                                                          RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingNextActiveResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  SEND_STRING dvDebug, "'recordCount: ', ITOA(recordCount)";
  SEND_STRING dvDebug, "'recordIndex: ', ITOA(recordIndex)";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name: RmsEventSchedulingSummariesDailyResponse          *)
(* Args:                                                   *)
(* CHAR isDefaultLocation - boolean, TRUE if th location   *)
(* in the response is the default location                 *)
(*                                                         *)
(* RmsEventBookingDailyCount dailyCount - A                *)
(* structure information about a specific date             *)
(*                                                         *)
(* Desc:  Implementations of this method will be called    *)
(* in response to a query summaries daily count            *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_BOOKING_SUMMARIES_DAILY_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingSummariesDailyResponse(CHAR isDefaultLocation,
																													RmsEventBookingDailyCount dailyCount)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingSummariesDailyResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  ShowRmsEventBookingDailyCount(dailyCount);
}

(***********************************************************)
(* Name: RmsEventSchedulingSummaryDailyResponse            *)
(* Args:                                                   *)
(* CHAR isDefaultLocation - boolean, TRUE if th location   *)
(* in the response is the default location                 *)
(*                                                         *)
(* RmsEventBookingDailyCount dailyCount - A                *)
(* structure information about a specific date             *)
(*                                                         *)
(* Desc:  Implementations of this method will be called    *)
(* in response to a query summary daily                    *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_BOOKING_SUMMARY_DAILY_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingSummaryDailyResponse(CHAR isDefaultLocation,
																												RmsEventBookingDailyCount dailyCount)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingSummaryDailyResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  ShowRmsEventBookingDailyCount(dailyCount);
}

(***********************************************************)
(* Name:  RmsEventSchedulingCreateResponse                 *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* SCHEDULING.BOOKING.CREATE-<start-date>,                 *)
(*                           <start-time>,                 *)
(*                           <duration-minutes>,           *)
(*                           <subject>,                    *)
(*                           <message-body>,               *)
(*                           (<location-id>)               *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingCreate(CHAR startDate[],                      *)
(*                  CHAR startTime[],                      *)
(*                  INTEGER durationMinutes,               *)
(*                  CHAR subject[],                        *)
(*                  CHAR messageBody[],                    *)
(*                  LONG locationId)                       *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_CREATE_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingCreateResponse(CHAR isDefaultLocation, 
                                                      CHAR responseText[], 
                                                      RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingCreateResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'responseText: ', responseText";
  ShowRmsEventBookingResponse(eventBookingResponse);
  
    SEND_STRING dvDebug, "'eventBookingResponse.bookingId: ', eventBookingResponse.bookingId";
  
  // Grab the sales and support booking ID's for further processing
    
  // Ignore the booking id if it is not valid
  IF(eventBookingResponse.bookingId != 'N/A')
  {
  	// Was this a Sales booking event?
	  IF(FIND_STRING(eventBookingResponse.subject, 'Sales', 1) > 0 )
	  {
	    salesStatusMeetingBookingId = eventBookingResponse.bookingId;
	  }
	  // Is this a support booking event?
	  ELSE IF(FIND_STRING(eventBookingResponse.subject, 'Support', 1) > 0)
	  {
	    supportStatusMeetingBookingId = eventBookingResponse.bookingId;
	  }
  }
}

(***********************************************************)
(* Name:  RmsEventSchedulingExtendResponse                 *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* SCHEDULING.BOOKING.EXTEND-<booking-id>,                 *)
(*                           <extend-duration-minutes>,    *)
(*                           (<location-id>)               *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingExtend(CHAR bookingId[],                      *)
(*                  LONG extendDurationMinutes,            *)
(*                  LONG locationId)                       *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_EXTEND_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingExtendResponse(CHAR isDefaultLocation, 
                                                      CHAR responseText[], 
                                                      RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingExtendResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'responseText: ', responseText";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingEndResponse                    *)
(*                                                         *)
(* This callback is executed in response to the command:   *)
(*                                                         *)
(* SCHEDULING.BOOKING.END-<booking-id>,(<location-id>)     *)
(*                                                         *)
(* OR execution of the function:                           *)
(*                                                         *)
(* RmsBookingEnd(CHAR bookingId[], LONG locationId)        *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_END_RESPONSE_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingEndResponse(CHAR isDefaultLocation, 
                                                    CHAR responseText[], 
                                                    RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingEndResponse() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  SEND_STRING dvDebug, "'responseText: ', responseText";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingActiveUpdated                  *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* the current active booking event has updated/changed    *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_ACTIVE_UPDATED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingActiveUpdated(CHAR bookingId[], 
                                                      RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingActiveUpdated() Called';
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingNextActiveUpdated              *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* the next active booking event has updated/changed       *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_NEXT_ACTIVE_UPDATED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingNextActiveUpdated(CHAR bookingId[], 
                                                          RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingNextActiveUpdated() Called';
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingEventEnded                     *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* a booking event has ended                               *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_EVENT_ENDED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingEventEnded(CHAR bookingId[], 
                                                  RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingEventEnded() Called';
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingEventStarted                   *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* a booking event has started                             *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_EVENT_STARTED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingEventStarted(CHAR bookingId[], 
                                                    RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingEventStarted() Called';
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingEventUpdated                   *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* the a booking event has updated/changed                 *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_EVENT_UPDATED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingEventUpdated(CHAR bookingId[], 
                                                      RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingEventUpdated() Called';
  SEND_STRING dvDebug, "'bookingId: ', bookingId";
  ShowRmsEventBookingResponse(eventBookingResponse);
}

(***********************************************************)
(* Name:  RmsEventSchedulingMonthlySummaryUpdated          *)
(*                                                         *)
(* This callback is executed when RMS wants to indicate    *)
(* the a monthly summary has updated/changed               *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_MONTHLY_SUMMARY_UPDATED_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingMonthlySummaryUpdated(INTEGER dailyCountsTotal, 
                                                              RmsEventBookingMonthlySummary monthlySummary)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingMonthlySummaryUpdated() Called';
  SEND_STRING dvDebug, "'dailyCountsTotal: ', ITOA(dailyCountsTotal)";
  ShowRmsEventBookingMonthlySummary(monthlySummary);
}

(***********************************************************)
(* Name:  RmsEventSchedulingDailyCount                     *)
(* Args:                                                   *)
(* CHAR isDefaultLocation - boolean, TRUE if the location  *)
(* in the response is the default location                 *)
(*                                                         *)
(* RmsEventBookingDailyCount dailyCount - A                *)
(* structure information about a specific date             *)
(*                                                         *)
(* Desc:  Implementations of this method will be called    *)
(* when RMS provides daily count information such as in    *)
(* when there is a monthly summary update                  *)
(*                                                         *)
(***********************************************************)
//#DEFINE INCLUDE_SCHEDULING_DAILY_COUNT_CALLBACK
DEFINE_FUNCTION RmsEventSchedulingDailyCount(CHAR isDefaultLocation,
																							RmsEventBookingDailyCount dailyCount)
{
  SEND_STRING dvDebug, 'RmsEventSchedulingDailyCount() Called';
  SEND_STRING dvDebug, "'isDefaultLocation: ', BOOLEANS[isDefaultLocation + 1]";
  ShowRmsEventBookingDailyCount(dailyCount);
}

(***********************************************************)
(* Name:  ShowRmsEventBookingResponse                      *)
(*                                                         *)
(* Desc:  Display the contents of a:                       *)
(* RmsEventBookingResponse structure                       *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION ShowRmsEventBookingResponse(RmsEventBookingResponse eventBookingResponse)
{
  SEND_STRING dvDebug, "'bookingId: ', eventBookingResponse.bookingId";
  SEND_STRING dvDebug, "'location: ', ITOA(eventBookingResponse.location)";
  SEND_STRING dvDebug, "'isPrivateEvent: ', BOOLEANS[eventBookingResponse.isPrivateEvent + 1]";
  SEND_STRING dvDebug, "'startDate: ', eventBookingResponse.startDate";
  SEND_STRING dvDebug, "'startTime: ', eventBookingResponse.startTime";
  SEND_STRING dvDebug, "'endDate: ', eventBookingResponse.endDate";
  SEND_STRING dvDebug, "'endTime: ', eventBookingResponse.endTime";
  SEND_STRING dvDebug, "'subject: ', eventBookingResponse.subject";
  SEND_STRING dvDebug, "'details: ', eventBookingResponse.details";
  SEND_STRING dvDebug, "'isAllDayEvent: ', BOOLEANS[eventBookingResponse.isAllDayEvent + 1]";
  SEND_STRING dvDebug, "'organizer: ', eventBookingResponse.organizer";
  SEND_STRING dvDebug, "'elapsedMinutes: ', ITOA(eventBookingResponse.elapsedMinutes)";
  SEND_STRING dvDebug, "'minutesUntilStart: ', ITOA(eventBookingResponse.minutesUntilStart)";
  SEND_STRING dvDebug, "'remainingMinutes: ', ITOA(eventBookingResponse.remainingMinutes)";
  SEND_STRING dvDebug, "'onBehalfOf: ', eventBookingResponse.onBehalfOf";
  SEND_STRING dvDebug, "'attendees: ', eventBookingResponse.attendees";
  SEND_STRING dvDebug, "'isSuccessful: ', BOOLEANS[eventBookingResponse.isSuccessful + 1]";
  SEND_STRING dvDebug, "'failureDescription: ', eventBookingResponse.failureDescription";
}

(***********************************************************)
(* Name:  ShowRmsEventBookingMonthlySummary                *)
(*                                                         *)
(* Desc:  Display the contents of a:                       *)
(* RmsEventBookingMonthlySummary structure                 *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION ShowRmsEventBookingMonthlySummary(RmsEventBookingMonthlySummary monthlySummary)
{
  SEND_STRING dvDebug, "'location: ', ITOA(monthlySummary.location)";
  SEND_STRING dvDebug, "'startDate: ', monthlySummary.startDate";
  SEND_STRING dvDebug, "'startTime: ', monthlySummary.startTime";
  SEND_STRING dvDebug, "'endDate: ', monthlySummary.endDate";
  SEND_STRING dvDebug, "'endTime: ', monthlySummary.endTime";
  SEND_STRING dvDebug, "'dailyCountsTotal: ', ITOA(monthlySummary.dailyCountsTotal)";
}

(***********************************************************)
(* Name:  ShowRmsEventBookingDailyCount                    *)
(*                                                         *)
(* Desc:  Display the contents of a:                       *)
(* RmsEventBookingDailyCount structure                     *)
(*                                                         *)
(***********************************************************)
DEFINE_FUNCTION ShowRmsEventBookingDailyCount(RmsEventBookingDailyCount dailyCount)
{
  SEND_STRING dvDebug, "'location: ', ITOA(dailyCount.location)";
  SEND_STRING dvDebug, "'dayOfMonth: ', ITOA(dailyCount.dayOfMonth)";
  SEND_STRING dvDebug, "'bookingCount: ', ITOA(dailyCount.bookingCount)";
  SEND_STRING dvDebug, "'recordCount: ', ITOA(dailyCount.recordCount)";
  SEND_STRING dvDebug, "'recordNumber: ', ITOA(dailyCount.recordNumber)";
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

TIMELINE_EVENT[TL1]
{
    STACK_VAR CHAR subject[50];
    STACK_VAR CHAR meetingDetails[100];

  // This controls running a sequence of commands in the defined order with
  // some small delay between each
  SWITCH(Timeline.Sequence)
  {
  
    // Create An Ad Hoc Booking Event Using A Send Command
    case 1: {
      // Only create meetings within the bounds of the work day
      IF(meetingStartHour >= startWorkDayHour AND meetingStartHour < endWorkDayHour)
      {
        meetingStartTime = "ITOA(meetingStartHour), ':', ITOA(meetingStartMinute), ':00'";
        subject = "'Support Meeting at: ', meetingStartTime";
        meetingDetails = "'Details for ', subject";
        
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing SCHEDULING.BOOKING.CREATE-', 
            nowDate, ',', meetingStartTime, ',', ITOA(defaultMeetingLength), ',', 
            subject, ',', meetingDetails, ',', ITOA(supportConferenceRoomLocationId)";
            
        SEND_COMMAND vdvRMS,"'SCHEDULING.BOOKING.CREATE-', nowDate, ',', meetingStartTime, ',', 
            ITOA(defaultMeetingLength), ',', subject, ',', meetingDetails, ',', ITOA(supportConferenceRoomLocationId)";
      }
    }
    
    // Create An Ad Hoc Booking Event Using A Function
    case 2: {
      // Only create meetings within the bounds of the work day
      IF(meetingStartHour >= startWorkDayHour AND meetingStartHour < endWorkDayHour)
      {
        meetingStartTime = "ITOA(meetingStartHour), ':', ITOA(meetingStartMinute), ':00'";
        subject = "'Sales Meeting at: ', meetingStartTime";
        meetingDetails = "'Details for ', subject";
        
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingCreate(', 
          nowDate, ',', meetingStartTime, ',', ITOA(defaultMeetingLength), ',', subject, ',', 
          meetingDetails, ',', ITOA(salesConferenceRoomLocationId),')'";
          
        RmsBookingCreate(nowDate, meetingStartTime, defaultMeetingLength, 
          subject, meetingDetails, salesConferenceRoomLocationId);
      }
    }
  
    // Query The Event Booking Records For A Location And Specific Date Using A Send Command
    case 3: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKINGS-', 
        bookingQueryDate, ',', ITOA(supportConferenceRoomLocationId)";
        
      SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKINGS-', bookingQueryDate, ',', 
        ITOA(supportConferenceRoomLocationId)";
    }
    
    // Query The Event Booking Records For A Location And Specific Date Using A Function
    case 4: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingsRequest(', 
        bookingQueryDate, ',', ITOA(salesConferenceRoomLocationId),')'";
        
      RmsBookingsRequest(bookingQueryDate, salesConferenceRoomLocationId);
    }
    
    // Query Monthly Booking Summary For Specified Day Of The Month And Location Using A Send Command
    case 5: {
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKINGS.SUMMARIES.DAILY-', 
        ITOA(summariesDailyQueryDayOfTheMonth),',', ITOA(supportConferenceRoomLocationId)";
        
      SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKINGS.SUMMARIES.DAILY-', 
        ITOA(summariesDailyQueryDayOfTheMonth),',', ITOA(supportConferenceRoomLocationId)";
    }
    
    // Query Monthly Booking Summary For Specified Day Of The Month And Location Using A Function
    case 6: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingsSummariesDailyRequest(', 
        ITOA(summariesDailyQueryDayOfTheMonth), ',', ITOA(salesConferenceRoomLocationId),')'";
        
      RmsBookingsSummariesDailyRequest(summariesDailyQueryDayOfTheMonth, salesConferenceRoomLocationId);
    }
        
    // Query A Single Daily Event Summary Record By Date And Location Using A Send Command
    case 7: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKINGS.SUMMARY.DAILY-', 
        summaryDailyDate, ',', ITOA(supportConferenceRoomLocationId)";
        
      SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKINGS.SUMMARY.DAILY-', summaryDailyDate, ',', 
        ITOA(supportConferenceRoomLocationId)";
    }
    
    // Query A Single Daily Event Summary Record By Date And Location Using A Function
    case 8: {
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingsSummaryDailyRequest(', summaryDailyDate, ',', ITOA(salesConferenceRoomLocationId),')'";
      RmsBookingsSummaryDailyRequest(summaryDailyDate, salesConferenceRoomLocationId);
    }
    
    // Query The Current Active Booking For A Given Location Using A Send Command
    case 9: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKING.ACTIVE-', 
        ITOA(supportConferenceRoomLocationId)";
        
      SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKING.ACTIVE-', ITOA(supportConferenceRoomLocationId)";
    }
    
    // Query The Current Active Booking For A Given Location Using A Function
    case 10: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingActiveRequest(', 
        ITOA(salesConferenceRoomLocationId),')'";
        
      RmsBookingActiveRequest(salesConferenceRoomLocationId);
    }
    
    // Query The Next Active Booking For A Given Location Using A Send Command
    case 11: {
    
      SEND_STRING dvDebug,"'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKING.NEXT.ACTIVE-', 
        ITOA(supportConferenceRoomLocationId)";
        
      SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKING.NEXT.ACTIVE-', ITOA(supportConferenceRoomLocationId)";
    }
    
    // Query The Next Active Booking For A Given Location Using A Function
    case 12: {
    
      SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingNextActiveRequest(', 
        ITOA(salesConferenceRoomLocationId),')'";
        
      RmsBookingNextActiveRequest(salesConferenceRoomLocationId);
    }
    
    // Request Information About A Specific Booking By Booking ID Using A Send Command
    case 13: {
    
      if(supportStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug,"'Sequence ', ITOA(Timeline.Sequence), ' - executing ?SCHEDULING.BOOKING-', 
          supportStatusMeetingBookingId, ',', ITOA(supportConferenceRoomLocationId)";
          
        SEND_COMMAND vdvRMS,"'?SCHEDULING.BOOKING-', supportStatusMeetingBookingId, ',', 
          ITOA(supportConferenceRoomLocationId)";
      }
    }
          
    // Request Information About A Specific Booking By Booking ID Using A Function
    case 14: {
    
      if(salesStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingRequest(', 
          salesStatusMeetingBookingId, ',', ITOA(salesConferenceRoomLocationId),')'";
          
        RmsBookingRequest(salesStatusMeetingBookingId, salesConferenceRoomLocationId);
      }
    }
    
    // Extend An Existing Event Using a Send Command
    case 15:
    {
    
      if(supportStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing SCHEDULING.BOOKING.EXTEND-', 
          supportStatusMeetingBookingId, ',', ITOA(extendLength), ',', ITOA(supportConferenceRoomLocationId)"
          
        SEND_COMMAND vdvRMS,"'SCHEDULING.BOOKING.EXTEND-', supportStatusMeetingBookingId, ',', 
          ITOA(extendLength), ',', ITOA(supportConferenceRoomLocationId)"
      }
    }
    
    // Extend An Existing Event Using a Function
    case 16:
    {
    
      if(salesStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingExtend(', 
          salesStatusMeetingBookingId, ',', ITOA(extendLength), ',', ITOA(salesConferenceRoomLocationId),')'";
          
        RmsBookingExtend(salesStatusMeetingBookingId, extendLength, salesConferenceRoomLocationId);
      }
    }
     
    // End An Existing Event Using a Send Command
    case 17:
    {
    
      if(supportStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing SCHEDULING.BOOKING.END-', 
          supportStatusMeetingBookingId, ',', ITOA(supportConferenceRoomLocationId)"
          
        SEND_COMMAND vdvRMS,"'SCHEDULING.BOOKING.END-', supportStatusMeetingBookingId, ',', 
          ITOA(supportConferenceRoomLocationId)"
      }
    }
    
    // End An Existing Event Using a Function
    case 18:
    {
    
      if(salesStatusMeetingBookingId != '')
      {
        SEND_STRING dvDebug, "'Sequence ', ITOA(Timeline.Sequence), ' - executing RmsBookingEnd(', 
          salesStatusMeetingBookingId, ',', ITOA(salesConferenceRoomLocationId),')'";
          
        RmsBookingEnd(salesStatusMeetingBookingId, salesConferenceRoomLocationId);
      }
    }
    
  } // END SWITCH
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

  nowDate = LDATE;  
  bookingQueryDate = nowDate;
  currentHour = TIME_TO_HOUR(TIME);
  currentMinute = TIME_TO_MINUTE(TIME);
  summariesDailyQueryDayOfTheMonth = DATE_TO_DAY(nowDate);
  summaryDailyDate = nowDate;
  
  // Run the sequence only a few times each hour and only during work hours
  IF((currentMinute == 13 OR currentMinute == 28 OR currentMinute == 43 OR currentMinute == 58) AND (currentHour >= startWorkDayHour) AND (currentHour < endWorkDayHour) )
  {   
    // If the timeline is not active and RMS is ready, start a new timeline
    IF(!TIMELINE_ACTIVE(TL1) AND [vdvRMS, RMS_CHANNEL_ASSETS_REGISTER] )
    {
      SEND_STRING dvDebug, '================> Activating timeline TL1 <================';
      
      // Do each task 10 seconds apart
      TimeArray[1] = 10000;
      TimeArray[2] = 10000;
      TimeArray[3] = 10000;
      TimeArray[4] = 10000;
      TimeArray[5] = 10000;
      TimeArray[6] = 10000;
      TimeArray[7] = 10000;
      TimeArray[8] = 10000;
      TimeArray[9] = 10000;
      TimeArray[10] = 10000;
      TimeArray[11] = 10000;
      TimeArray[12] = 10000;
      TimeArray[13] = 10000;
      TimeArray[14] = 10000;
      TimeArray[15] = 10000;
      TimeArray[16] = 10000;
      TimeArray[17] = 10000;
      TimeArray[18] = 10000;
      
      TIMELINE_CREATE(TL1, TimeArray, 20, TIMELINE_RELATIVE, TIMELINE_ONCE)
      
      meetingStartHour = currentHour;
      IF(currentMinute >= 0 && currentMinute < 15)
      {
        meetingStartMinute = 15;
      }
      ELSE IF(currentMinute >= 15 && currentMinute < 30)
      {
        meetingStartMinute = 30;
      }
      ELSE IF(currentMinute >= 30 && currentMinute < 45)
      {
        meetingStartMinute = 45;
      }
      ELSE
      {
        meetingStartMinute = 00;
        meetingStartHour = meetingStartHour + 1;
      }
    }
  }  


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


