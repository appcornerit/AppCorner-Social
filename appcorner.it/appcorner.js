/*
 * 	www.appcorner.it
 *	v1.0.0
 */

//BEFORE TRY INSERT YOUR FACEBOOK ID USED TO LOGIN IN APPCORNER SOCIAL FOR IPHONE (fb=)
var YOUR_FACEBOOK_ID = '00000000';

var skipApps;
var canLoadNextPage;

var spinnerOpts = {
    lines: 17, // The number of lines to draw
    length: 0, // The length of each line
    width: 9, // The line thickness
    radius: 28, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    direction: 1, // 1: clockwise, -1: counterclockwise
    color: '#000', // #rgb or #rrggbb or array of colors
    speed: 1, // Rounds per second
    trail: 50, // Afterglow percentage
    shadow: true, // Whether to render a shadow
    hwaccel: true, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
};

$(function(){
    $.extend({
        appstore : function(opts) {
                         $.each( opts.items, function(i) {
                                    if(opts.items && opts.items[i])
                                    {
                                        var date = $.format.prettyDate(opts.items[i].created);
                                        var des = opts.items[i].description;
                                        if(!des)
                                        {
                                            des = '';
                                        }
                                        var n = 160;
                                        if(opts.items[i].comments != '') {des = '<p class="comment"><i>'+opts.items[i].comments +'</i></p>'+ des; n=170;}
                                        des = des.length>n ? des.substr(0,n-1)+'&hellip;' : des;
                                
                                        //Download the app store badges for your language https://developer.apple.com/app-store/marketing/guidelines/#downloadOnAppstore
                                        var appstorebadge = 'img/appstore_badge.png';
                                        var badgeWidth = 135;
                                        if(opts.items[i].kind == "mac-software") //mac
                                        {
                                            //Download the mac app store badges for your language https://developer.apple.com/app-store/marketing/guidelines/mac/#downloadOnAppstore
                                            appstorebadge = 'img/mac_appstore_badge.png';
                                            badgeWidth = 165;
                                        }
                                
                                        var button = '<a href="'+opts.items[i].trackViewUrl+'" target="_blank"><div style="width:'+badgeWidth+'px"><img src="'+appstorebadge+'"></img></div></a>';
                                        var icon = '<div class="center"><a href="'+opts.items[i].trackViewUrl+'" target="_blank"><img src="'+opts.items[i].artworkUrl60+'" class="as-item-logo"/></a></div>';
                                
                                        var scrUrl='<div class="owl-carousel" id="'+opts.container+opts.items[i].appcode+'">';
                                        for(x=0;x<opts.items[i].screenshotUrls.length;x++)
                                        {
                                            if(opts.items[i].screenshotUrls[x] != null)
                                            {
                                                scrUrl=scrUrl+'<div class="as-item-thumbnail"><img class="lazyOwl" data-src="'+opts.items[i].screenshotUrls[x]+'"/></div>';
                                            }
                                        }
                                
                                        scrUrl = scrUrl+'</div>';
                                        var item = '<div id="as-item-'+i+'" class="as-item">'+scrUrl+'<div class="as-item-desc"><span class="as-icon as-icon-small"><span class="as-icon-tag"></span></span><span class="as-tag">'+opts.items[i].primaryGenreName+'</span>&nbsp;&nbsp;<span class="as-icon as-icon-small"><span class="as-icon-calendar"></span></span><span class="as-date">'+date+'</span>'+icon+'<h3 class="center">'+opts.items[i].trackName+'</h3>'+des+'<div><br/>'+button+'</div></div></div>';

                                        $(item).appendTo('#'+opts.container);
                                        $('#'+opts.container+opts.items[i].appcode).owlCarousel({
                                                    items : 1,
                                                    singleItem : true,
                                                    lazyLoad : true
                                                    });
                                    }
                                });
        }
    });
  
   $.extend({
            
            loadAppsInContainer : function(containerName,target,heightOffset) {
                    if($("#"+containerName).length != 0) {
            
                        $[target](containerName);
            
                        //load next apps block on page scroll
                        $(window).scroll(function () {
                             if ($(window).scrollTop() >= $(document).height() - $(window).height() - heightOffset) {
                                         if(canLoadNextPage)
                                         {
                                            canLoadNextPage = false;
                                            $[target](containerName);
                                        }
                             }
                        });
                    }
            },
            
           userapps : function(containerName) {
                    var spinner = new Spinner(spinnerOpts).spin();
                    $('#'+containerName).append(spinner.el);
                    //BASE URL: http://www.appcorner.it/userapps
                    //REQUIRED PARAM:
                    //fb=[YOUR FACEBOOK ID]
                    //
                    //OPTIONAL PARAMS:
                    //country=[ITUNES COUNTRY CODE]
                    //limit=[APPS LIMIT, MAX 12 BY DEFAULT]
                    //skip=[NUMBER OF APPS TO SKIP]
                    //phgat=[YOUR PHG AFFILIATE TOKEN]
                    //campaign=[YOUR PHG CAMPAIGN]
                    //shortUrl=true [USE SHORT LINK INSTEAD OF STANDARD LINK https://developer.apple.com/library/ios/qa/qa1633/_index.html]
            
                    //EXAMPLE: YOUR APPS POSTED ON APPCORNER FOR IPHONE, LOADED FROM ITUNES FOR UNITED STATES
                    //BEFORE TRY INSERT YOUR FACEBOOK ID USED TO LOGIN IN APPCORNER SOCIAL FOR IPHONE (fb=)
                    $.get("http://www.appcorner.it/userapps?fb="+YOUR_FACEBOOK_ID+"&country=us&skip="+skipApps,function(apps,status){
                        var appsCounter = (apps == null?0:apps.length);
                        if(appsCounter > 0)
                        {
                            $.appstore({"items": apps, "container":containerName});
                        }
                          
                        //code to load next apps block
                        skipApps = skipApps+appsCounter;
                        if(appsCounter > 0){
                           canLoadNextPage = true;
                        }
                          
                        spinner.stop();
                });
            },
            
            pricedrops : function(containerName) {
                        var spinner = new Spinner(spinnerOpts).spin();
                        $('#'+containerName).append(spinner.el);
                        //BASE URL: http://www.appcorner.it/pricedrops
                        //REQUIRED PARAM:
                        //fb=[YOUR FACEBOOK ID]
                        //
                        //OPTIONAL PARAMS:
                        //limit=[APPS LIMIT, MAX 12 BY DEFAULT]
                        //skip=[NUMBER OF APPS TO SKIP]
                        //phgat=[YOUR PHG AFFILIATE TOKEN]
                        //campaign=[YOUR PHG CAMPAIGN]
                        //
                        //OPTIONAL FILTERS:
                        //device=[DEFAULT ALL OR ONLY ONE FROM: iphone,ipad,mac]
                        //languages=[MUST HAVE ONE OF THOSE LANGUAGES COMMAS SEPARATED]
                        //price=0 filter free app only
                        //genre=[PRIMARY GENRE ONLY ONE FROM: books, business, catalogs, education, entertainment, finance, food, games, health, lifestyle, medical, music, navigation, news, newsstand, photo video, productivity, reference, social, sports, travel, utilities, weather]
            
                        //EXAMPLE: SHOW PRICE DROPS TO FREE, GAMES FOR IPHONE ONLY THAT CONTAINS AT LEAST ENGLISH OR ITALIAN LANGUAGE, LOADED FROM THE ITUNES COUNTRY USED TO LOGIN IN APPCORNER SOCIAL (FOR THE YOUR FACEBOOK ID)
                        //BEFORE TRY INSERT YOUR FACEBOOK ID USED TO LOGIN IN APPCORNER SOCIAL FOR IPHONE (fb=), in case of empty result remove some filters.
                        $.get("http://www.appcorner.it/pricedrops?fb="+YOUR_FACEBOOK_ID+"&price=0&genre=games&device=iphone&languages=en,it&skip="+skipApps,function(apps,status){
                                  var appsCounter = (apps == null?0:apps.length);
                                  if(appsCounter > 0)
                                  {
                                    $.appstore({"items": apps, "container":containerName});
                                  }
                                  
                                  //code to load next apps block
                                  skipApps = skipApps+appsCounter;
                                  if(appsCounter > 0){
                                    canLoadNextPage = true;
                                  }
                                  
                                  spinner.stop();
                        });
            }
    });
});

$(document).ready(function(){
                  skipApps = 0;
                  canLoadNextPage = false;
                  var heightOffset = 400; //min height to load next request, change as you need
                  
                  $.loadAppsInContainer("userapps-container","userapps",heightOffset);
                  $.loadAppsInContainer("pricedrops-container","pricedrops",heightOffset);
});

