AppCorner
============

Share your favorites apps on AppCorner and discover new apps around the world with your friends.

This app for iPhone use [Deployd](http://deployd.com) as server (a great open source platform over mongodb and node.js) that run on [appcorner.it](http://www.appcorner.it). 

**Build your server is quite simple**, refer to [README](https://github.com/appcornerit/AppCorner-Social/tree/master/Deployd-Modules) to try the app with your server (on localhost or aws or with loopback as backend instead of deployd).

**You can use AppCorner on appcorner.it to share your apps with others developers, your apps (available in iTunes Italy) are posted anonymously on [appcorner.it](http://www.appcorner.it/app-sviluppatori.html).**

**You can also use AppCorner for iPhone to show your posted apps (in any country and language available in iTunes) with your comments on your website using appcorner.it as service for free (without install deployd on your server), refer to [README](https://github.com/appcornerit/AppCorner-Social/tree/master/appcorner.it)**

I encourage anyone who wants to contribute and update the project.
You can build your social app that share musics, books or TV series (from iTunes) with few changes.

This project uses APN, WebSockets and containts an updated version of [DeploydKit](https://github.com/appcornerit/AppCorner-Social/tree/master/External/DeploydKit) project.

The story:
- I developed [DeploydKit](https://github.com/appcornerit/DeploydKit)
- I saw [Anypic](https://github.com/ParsePlatform/Anypic) a full featured photo sharing app built by [Parse.com](https://parse.com)
- I developed a layer called [ParseKit] (https://github.com/appcornerit/AppCorner-Social/tree/master/External/ParseKit) to replace Parse framework on top of DeploydKit
- I developed the code of the server quickly
- Anypic works with Deployd!
- I moved the photo entity as app entity (and other customizations) and so the new name is AppCorner
- AppCorner works with Deployd!
- The app not pass the [approval rule](https://developer.apple.com/app-store/review/guidelines/) 2.25 of App Store
- I forgot the app for some time
- I developed AppCornerKit and [iTunesPicker](https://github.com/appcornerit/iTunesPicker) as new project starting from pieces of AppCorner
- Now AppCorner is open source

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)

![Alt text](preview/1.png "Preview") 
![Alt text](preview/3.png "Preview") 



