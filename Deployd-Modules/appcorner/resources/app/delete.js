//Prevent unauthorized users
if (!(me && me.id == this.creatorId)) {
    error('errorKey', "error.user.notlogged");
    cancel("error.user.notlogged");
}
else if(me.disabled)
{
    error('errorKey', "error.user.disabled");
    cancel('error.user.disabled');      
}
else
{
    if(!internal && this.badges <= 7)
    {
        dpd.app.get({appId:this.appId,user:this.user}, function(res, err) {        
            if (err) cancel(err);
            else{
                for (var i = 0; i < res.length; i++) {
                    var app = res[i];
                    if(app.badges >= 65 && app.id != this.id){
                        dpd.app.put(app.id, {checkPrice:true}, function(res, err) {
                            if (err) cancel(err);
                        });
                        break;
                    }                    
                }
            }
        }); 
        
    }
}