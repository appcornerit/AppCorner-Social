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