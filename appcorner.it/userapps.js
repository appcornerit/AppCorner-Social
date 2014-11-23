
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
                                        var des = opts.items[i].description;
                                        if(!des)
                                        {
                                            des = '';
                                        }
                                        var n = 160;
                                        if(opts.items[i].comments != '') {des = '<p class="comment"><i>'+opts.items[i].comments +'</i></p>'+ des; n=170;}
                                        des = des.length>n ? des.substr(0,n-1)+'&hellip;' : des;
                                
                                        var button = '<a href="'+opts.items[i].trackViewUrl+'" target="_blank"><div class="appstorebadge"><div class="text"><div class="line1">Per iPad su</div><div class="line2">App Store</div></div><div class="iphone"><div class=""></div><div class="screen"></div><div class=""></div></div></div></a>';
                                
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
                                        var item = '<div id="as-item-'+i+'" class="as-item">'+scrUrl+'<div class="as-item-desc"><span class="as-icon as-icon-small"><span class="as-icon-tag"></span></span><span class="as-tag">'+opts.items[i].primaryGenreName+'</span>&nbsp;&nbsp;<span class="as-icon as-icon-small"></span>'+icon+'<h3 class="center">'+opts.items[i].trackName+'</h3>'+des+'<div><br/>'+button+'</div></div></div>';

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
           apps : function(containerName) {
                    var spinner = new Spinner(spinnerOpts).spin();
                    $('#'+containerName).append(spinner.el);
                    //http://www.appcorner.it/userapps?fb=[YOUR FACEBOOK ID]&country=[ITUNES COUNTRY CODE]&limit=[APPS LIMIT, MAX 12 BY DEFAULT]&phgat=[YOUR PHG AFFILIATE TOKEN]
            
                    //INSERT BELOW YOUR ID FACEBOOK AND THE CODE OF THE ITUNES'S COUNTRY, BOTH ARE REQUIRED
                    $.get("http://www.appcorner.it/userapps?fb=0000000000&country=us",function(apps,status){
                        var appsCounter = (apps == null?0:apps.length);
                        if(appsCounter > 0)
                        {
                            $.appstore({"items": apps, "container":containerName});
                        }
                        spinner.stop();
                });
           }
    });
});


$(document).ready(function(){
                  $.apps("userapps-container");
});

