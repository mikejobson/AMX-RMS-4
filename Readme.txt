Release Notes
=============

RMS SDK

FG #: 3004  
Current Version: 4.1.13
Release Date: 06/07/2013  


Prerequisites
-------------
--  None


Changes in this release
-----------------------
-- Updated to prevent messages from exceeding the maximum message size.

Changes in 4.1.12
-----------------------
-- Fixed an issue which could prevent parameter updates from being received from
   duet modules.

Changes in 4.1.11
-----------------------
-- Fixed an issue which prevented registration of the power status parameter and
   control method for certain TV and Monitor devices.

Changes in 4.1.10
-----------------------
--  Corrected an issue which could result in out of memory errors under certain 
    conditions. 

Changes in 4.1.9
-----------------------
--  Corrected an issue which sometimes prevented detailed meeting information
    from being correctly displayed when in a multi-location configuration.
--  Increased the page timeout values for the meeting ending dialogues that are
    included with the sample touch panel pages.
--  Asset parameter thresholds associated with the online status asset parameter
    will now be registered with a default status type of Location Communications Error.
--  Fixed an error in the HVAC NL monitoring module related to cooling and 
    heating setpoints.
--  Optimized the DVX monitoring module to be more efficient in certain scenarios.
--  Fixed an issue with the DVX monitoring module which prevented the front panel 
    lockout parameter from updating correctly.

Changes in 4.1.8
-----------------------
--  Added the ability to configure a default subject and message for new meetings.
--  Added support for the LED indicator that is included with certain Modero X
    touch panels.
--  Fixed error that sometimes occurred when a location was not mapped to 
    a scheduling resource.
--  The duration time is now unable to go below 15 minutes on the scheduling panel.
--  Fixed an issue which prevented new meetings from being created while an 
    active meeting was in progress.
--  Fixed an issue which sometimes caused the meetings to be scheduled one
    minute into the future. 
--  Fixed an issue which sometimes prevented a meeting from being able to be
    scheduled when it was back to back with another meeting.
--  When relocating a touch panel asset on the server, the client will now properly 
    reconfigure it's connected touch panel displays to reflect the new locations.
--  Text entered via help requests, maintenance requests, and the meeting creation
    pages will now allow the usage of the comma and carriage return characters.
--  Fixed an issue with the NetLinx SDK which sometimes caused the active meeting event
    to be included with the set of next active meeting events.


Changes in 4.1.5
----------------
--  Implemented scheduling support.


Changes in 4.0.32
-----------------
--  HTTP-PORT metadata now being registered for System asset.
--  Tracking of lamp hours, display usage and disc transport runtime will now properly
    start/stop based on the power state of the device. This resolves xTrack issue 506744.
 
 
Changes in 4.0.31
-----------------
--  Power Distribution Unit monitor now reports correct energy usage.
--  Power Distribution Unit monitor now reports energy in kWh (previous reported in Wh).
--  NetLinx Document Camera monitor now properly tracking upper and lower light hours.
--  NetLinx Light System monitor now registers the asset type as a "Light System".
--  NetLinx Video Projector monitor now properly tracking lamp consumption time.
--  Input Source parameter enumeration values and control method arguments will 
    now be represented by their logical groupings rather than their individual inputs.
--  NetLinx monitors with a Volume component previous registered a control method named 
    "Set Volume Mute"; this has now been renamed to "Volume Mute".
--  Controls on the RMS touch panel pages have been updated so that they're more 
    consistent with one another.
--  About RMS window on the RMS touch panel pages updated to always display the 
    correct version.
--  The Asset Online parameter state will now properly reflect the state of the SNAPI 
    channel 251 (DEVICE_COMMUNICATING).
--  NetLinx monitors updated to be more consistent with Duet monitors; Device Data 
    Initialized parameter will now be registered with RMS; SNAPI channel. 
    252(DATA_INITIALIZED) will now need to be turned to ON before the device will 
    become registered.
--  System Asset will now show the correct serial number.
--  Corrected the RMSAnterusRFIDAdapter so that exceptions are not thrown when
    RFID tracking is disabled.
--  Fixed logic that writes the rms.properties file to the "user" directory so
    that no exception occurs when RMS code is loaded for the first time.
--  Added retry logic to make the registration process with the server more
    robust.
--  Implemented optimizations to allow for greater scalability on the RMS
    server.
--  The startup time of the RMS Engine on the most recent versions of
    master firmware has been dramatically reduced.


Changes in 4.0.28
-----------------
--  Initial release


Known Issues
------------
--  No known issues. 
