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
else if(this.type === 'f') //follow
{
  dpd.user.get({id:this.toUser}, function(res, err) {
     if (err) cancel(err);
     else if (res && res.internal)
     {
        error('errorKey', "error.activity.unfollow.internalUser");
        cancel('error.activity.unfollow.internalUser');       
     }
  });
}
