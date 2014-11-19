Weather-ERF-Gateway-1000U
=========================

Collects and displays data from a Lacrosse Technology C84612 Wireless Professional Weather Center

These are the files I use to capture data from my
Lacross Technologies C84612 Weather Station
using the GW1000U ERF-100 Gateway
I'm running my webserver on a Synology Diskstation DS410j. Some of
the PHP in request.breq may need to be modified to work on yours.
I had to modify mycal and keckec's original code to get mine working.

You have to get your web server to process the request.breq file as php.
On my Synology Diskstation, I modified /etc/httpd/conf/extra/mod_fastcgi.conf
by adding .breq to the AddHandler list, and adding .breq to security.limit_extensions
in /etc/php/php-fpm.conf.

You can see a discussion about how this was created here:
http://www.wxforum.net/index.php?topic=14299

Much of the database design comes from SkyDvr.
Much of the request.breq comes from mycal, by way of keckec's version.
Much of the weather.html and wsdata.php comes from Scott_A.

I have not tested the registration functionality, which comes from
mycal or keckec's original work.  I highly recommend that you register the
weather station through Lacrosse Technologies first.

Use the Advanced Gateway Setup program from Lacrosse to redirect
the data to your webserver.  

Near the top of the request.breq file are important configuration
options:

OF_RTG: send replies to gateway.  You almost always want this set.
OF_WDB: store data to database.  Until you get the station serial
    information from Lacrosse, you want to leave this off
OF_DBG: if this flag is not set, there will be no debug information
   sent to wstation.log at all.  See DBG_LVL below.
OF_WUG: send data to Weather Underground.  You must have the account
   information set in the database first.
OF_LAC: relay the data to box.weatherdirect.com.  This can be very useful
   at first in getting the serial number, and later for comparing your
   responses with theirs.
OF_RES: send the responses from above instead of your own.  This effectively
   makes your webserver a proxy
DBG_LVL: OF_DBG must be set for this to send ouput to the wstation.log file
    0: only critical errors
    1: packet activity, useful to confirm that it's working
    2: detail, useful for debugging but fills the log fast

In the configuration branch of this repository, I have moved the above flags,
plus the ping, sensor and history intervals, into the stations table.
I have created wsconfig.html and wsconfig.php to read and modify these settings.
However, the output flags still need to be set at the beginning of request.breq,
because they are used before the values are retrieved from the database.

You will need to get the station serial number by sniffing packets
coming from Lacrosse. You can use the output flags to help with this.
You will then need to add this information to the stations table.
Note that for some reason the MAC address has its second octet zeroed
out, e.g. my MAC ends with 8C09913D but the gateway sends 8009913D.

Note on the `records` table: you must populate it yourself with a query
of your own.  The request.breq script only updates records that exist in
that table, it won't fill in missing ones.  This is so that only meaningful
records are kept.  For example, minimum rainfall and wind are pretty useless,
so there are no records for those.  I have added the script records.sql to get you started.

Please send comments to the forum topic above, so that everyone can
benefit from the discussion.

weather.htm displays data from your database.  current.html, temperature.html,
humidity.html, wind.html, rainfall.html, rainlong.html, and pressure.html display
just parts, helpful when modifying the charts to suit your tastes.
weather.htm whacks the database pretty hard, and reloads every 5 minutes, so
you might not want to sit on it all the time.

Recent optimizations to the queries and the use of historical tables like records and hourly have greatly improved the load time for the display pages.

I have updated the design to handle multiple weather stations.  If you only have one entry in the stations table, you won't notice the difference, except that you won't need to hardcode the stationid in your wsdata.php.  If you have multiple records in the stations table, you will see a dropdown list at the top of the weather.html (and its subsidiaries) which will allow you to switch which station's data is displayed.  Also, you can add ?stationid=x to the query string to force the selection.
