Release Notes
=============

RMS SDK

FG #: 3004  
Current Version: 4.1.5
Release Date: 11/30/2012  


Prerequisites
-------------
--  None


Changes in this release
-----------------------
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
