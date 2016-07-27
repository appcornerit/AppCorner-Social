AppCorner
============

Share your favorites apps on AppCorner and discover new apps around the world with your friends, it's also the easiest way to bookmarks apps with your iPhone on your website!

This app for iPhone use [Deployd](http://deployd.com) as server (a great open source platform over mongodb and node.js) that run on [appcorner.it](http://www.appcorner.it/en/). 

You can use AppCorner on appcorner.it to share your apps with others developers, your apps are posted anonymously on [appcorner.it](http://www.appcorner.it/en/app-devs.html).

**To see your app on appcorner.it (website/twitter/facebook) and iTunesPicker as price reduction, post your app on appcorner social with the red clock icon enabled at least 12 hours before change the price from the App Store.**  

###Show apps on your web site for free and make money with iTunes Affiliate Program
**You can create a website with price drops as [appcorner.it](http://www.appcorner.it/en/) in minutes**, refer to [README](https://github.com/appcornerit/AppCorner-Social/tree/master/appcorner.it).
 Price drops are also available on your iPhone, take a look at the [iTunesPicker](https://github.com/appcornerit/iTunesPicker) project.

You can also use AppCorner for iPhone to show your posted apps (in any country and language available in App Store) with your comments on your website using appcorner.it as service for free (without install deployd on your server), refer to [README](https://github.com/appcornerit/AppCorner-Social/tree/master/appcorner.it)

###AppCorner on your server
**Build your server is quite simple**, refer to [README](https://github.com/appcornerit/AppCorner-Social/tree/master/Deployd-Modules) to try the app with your server (on localhost or aws or with loopback as backend instead of deployd).

This project uses APN, WebSockets and containts an updated version of [DeploydKit](https://github.com/appcornerit/AppCorner-Social/tree/master/External/DeploydKit) project.

###Publish on App Store
You can build your social app to publish on App Store that share musics, books or TV series (from iTunes) quickly with few changes in DAAppsViewController.m, PAAppStoreQuery.m.

###The story
- I developed [DeploydKit](https://github.com/appcornerit/DeploydKit)
- I saw [Anypic](https://github.com/ParsePlatform/Anypic) a full featured photo sharing app built by [Parse.com](https://parse.com)
- I developed a layer called [ParseKit] (https://github.com/appcornerit/AppCorner-Social/tree/master/External/ParseKit) to replace Parse framework (it wasn't open source at the time) on top of DeploydKit
- I developed the code of the server quickly
- Anypic works with Deployd!
- I moved the photo entity as app entity (and other customizations) and so the new name is AppCorner
- AppCorner works with Deployd!
- I forgot the app for some time
- I developed [iTunesPicker](https://github.com/appcornerit/iTunesPicker) as new project starting from pieces of AppCorner
- I released AppCorner open source
- I forgot the app again, but still works fine

To retrieve statistics about apps (or any other iTunes entity) take a look at the [iTunesPicker](https://github.com/appcornerit/iTunesPicker) project.
I encourage anyone who wants to contribute and update the project.

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)
