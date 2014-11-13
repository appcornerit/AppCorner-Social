//Prevent unauthorized users
if (!me) {
    error('errorKey', "error.user.notlogged");  
    cancel("error.user.notlogged");
}
else if(me.disabled)
{
    error('errorKey', "error.user.disabled");                  
    cancel('error.user.disabled');        
}
else{
    // Save the date created
    this.createdAt = parseInt((new Date().getTime()) / 1000, 10); 
    this.creatorId = me.id;
    //Protect readonly/automatic properties    
    protect('updatedAt');    
}