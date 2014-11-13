//Prevent unauthorized users
if (!me && !internal) {
    error('errorKey', "error.user.notlogged");    
    cancel("error.user.notlogged");
}
else if(!this.fromUser && !internal){
    error('errorKey', "error.activity.invalidFromUser");      
    cancel('error.activity.invalidFromUser');
}
else if(!internal && me.disabled)
{
    error('errorKey', "error.user.disabled");                   
    cancel('error.user.disabled');        
}
else if(internal || me.id == this.fromUser){
    // Save the date created
    this.createdAt = parseInt((new Date().getTime()) / 1000, 10);
    if(!internal)
    {
        this.creatorId = me.id;
    }
    //Protect readonly/automatic properties    
    protect('updatedAt');    
    
        //check post (love/like) limits for day
        if(this.type === "c" || this.type === "l") //comment or like
        {
            var dayLimit = 50;
            if(me.premium)
            {
                dayLimit = 200;
            }
            var yesterday = new Date();    
            yesterday.setDate(yesterday.getDate() - 1);
            var yesterdayInt = parseInt((yesterday.getTime()) / 1000, 10);
                        
            dpd.activity.get({fromUser:this.fromUser,$or:[{type:"c"}, {type:"l"}],createdAt:{"$gt": yesterdayInt}}, function(res, err) {
                if (err) cancel(err);
                else if (res && res.length >= dayLimit)
                {
                    error('errorKey', "error.activity.limit");
                    cancel("error.activity.limit");
                }
                else
                {
                    if(this.toUser && this.toUser != me.id)
                    {                        
                        dpd.apn.post({user:me,activity:this}, function(res, err) {
                            //if (err) cancel(err);
                        });                                                  
                    }
                    dpd.social.post({user:me,id:this.appId,comment:this.content}, function(res, err) {   
                        //if (err) cancel(err);            
                    });                      
                }
            });         
        }           
        else if(this.toUser && this.toUser != me.id)
        {
            dpd.apn.post({user:me,activity:this}, function(res, err) {            
                //if (err) cancel(err);
            });        
        }
        
}
else{
    error('errorKey', "error.activity.fromUser");
    cancel('error.activity.fromUser');   
}