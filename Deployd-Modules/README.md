AppCorner Server
============

AppCorner require facebook login, so replace or add code in your deployd to allow fblogin, the code is deployd/lib/resources/user-collection.js

Copy all modules from appcorner folder in a new app created with deployd.
Start deployd.

Add one record in SYNC resource from dashboard for example:
defaultLocale: us
numAppsPicker: 100

Add one record in COUNTRY resource from dashboard for example:
country: us

In AppCorner for iOS uncomment
//#define SERVER_URL TEST_LOCAL_URL
//#define SERVER_URI TEST_LOCAL_URI
//#define SERVER_PORT TEST_LOCAL_PORT
and comment
#define SERVER_URL PROD_SERVER_URL
#define SERVER_URI PROD_SERVER_URI
#define SERVER_PORT PROD_SERVER_PORT

have fun!