##GAPS  version 1.0  14/05/2013
=====
###Generic Android PC Suite 

Usage: 
```bash
$ ruby opt.rb [options]

Options:
    
    -S, --sync                       Sync device(s)
    -B, --backup                     Backup sms device
    -R, --restore [ARG]              Restore sms to previous backup. ARG = 0,1,2
    -O, --other [arg]                Restore sms DB from another device.
    -h, --help                       Show this message
```



* You can sync atmost two phones at same time using multi sync option
* Once you sync phone,data in phone and database is consistent and any data deleted from phone which is present in database is restored. so in case you want to premanantly delete data, you have to either do it manually from phone or you can do this by decrypting database and then deleting data.
* Once data deleted from database may not be recovered using GAPS.
* Restore function first delete all data from phone and then restores chosen data. So in case,you dont want previous data to be deleted, you can take backup before restore.
* Device is put in flight mode automatically when app is accessing the device and flight mode is removed when app is done processing with device.


###Installing under Linux Ubuntu

* The only dependancy is Ruby. 
* There is no setup file for this application. Copy the application at a location in system.
* You can use application directly from command line.
* Note that, once location for application is fixed, it is advisable not to move it from that location, as application creates database and backup files, which are present in GAPS folder in same location as application. If you cant to move it, then you have to move GAPS folder with it.
