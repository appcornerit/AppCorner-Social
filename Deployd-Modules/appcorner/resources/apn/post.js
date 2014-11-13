if (!me) {
    error('errorKey', "error.user.notlogged");   
    cancel("error.user.notlogged");
}
else if(me.disabled)
{
    error('errorKey', "error.user.disabled");               
    cancel('error.user.disabled');     
}