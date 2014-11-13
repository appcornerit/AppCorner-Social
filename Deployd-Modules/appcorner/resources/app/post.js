//Prevent unauthorized users
if (!me) {
    error('errorKey', "error.user.notlogged");
    cancel("error.user.notlogged");
}
else if(!this.user){
    error('errorKey', "error.app.invalidUser");
    cancel("error.app.invalidUser");    
}
else if(me.disabled)
{
    error('errorKey', "error.user.disabled");
    cancel('error.user.disabled');       
}
else if(me.id == this.user || internal){
    // Save the date created
    this.createdAt = parseInt((new Date().getTime()) / 1000, 10);
    this.creatorId = me.id;
    this.userCountry = me.appStoreCountry;
    
    //Protect readonly/automatic properties    
    protect('updatedAt');
    
    if(!internal)
    {
        this.checkPrice = this.badges >= 65; // && this.country === me.appStoreCountry;  
        
        if(this.checkPrice)
        {
            dpd.price.post({appId:this.appId,country:me.appStoreCountry,type:"a"}, function(res, err) {
            });   
        }        
        
        //check duplicates
        dpd.app.get({appId:this.appId,user:this.user}, function(res, err) {
            if (err) cancel(err);
            //post one duplicate only for app with want badges and duplicate not contain want badges
            else if(res && (res.length > 1 || (res.length == 1 && (res[0].badges <= 7 || this.badges > 7)))) 
            {
                error('errorKey', "error.app.limit.duplicate");                  
                cancel('error.app.limit.duplicate');           
            }
           else if(this.badges <= 7 && res.length == 1 && res[0].checkPrice){           
               dpd.app.put(res[0].id, {checkPrice:false}, function(res, err) {
                    if (err) cancel(err);
               });
            }
        });   
    
        //check post limits for day
        var dayLimit = 10;
        if(me.premium)
        {
            dayLimit = 50;
        }        
        var yesterday = new Date();    
        yesterday.setDate(yesterday.getDate() - 1);
        var yesterdayInt = parseInt((yesterday.getTime()) / 1000, 10);
        dpd.app.get({user:this.user,createdAt:{"$gt": yesterdayInt}}, function(res, err) {
            if (err) cancel(err);
            else if (res && res.length >= dayLimit)
            {
                error('errorKey', "error.app.limit");                  
                cancel('error.app.limit');                     
            }
        });
        
        dpd.activity.get({toUser:this.user,type:"f"}, function(res, err) {
            if (!err)
            {
                var ids = [];
                for (var x=0; x<res.length; x++)
                {
                    ids.push(res[x].fromUser);
                }
                if(ids.length > 0)
                {
                    emit(dpd.user, {id: {$in: ids}}, 'app.follow.post',this.id); 
                }
            }
        });
    }
}
else{    
    error('errorKey', "error.app.userAuth");
    cancel('error.app.userAuth');  
}