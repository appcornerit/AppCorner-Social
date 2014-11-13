//Prevent unauthorized users
if (!me && !internal) {
    error('errorKey', "error.user.notlogged");   
    cancel("error.user.notlogged");
}
else if(!internal && me.disabled)
{
    error('errorKey', "error.user.disabled");               
    cancel('error.user.disabled');     
}
else if(!internal && me.id !== this.creatorId){
    hide('password');
    hide('email'); 
    hide('disabled');     
    hide('externalTwit');
    hide('affiliateToken');    
}