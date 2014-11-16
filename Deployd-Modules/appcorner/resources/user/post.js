// Save the date created
this.createdAt = parseInt((new Date().getTime()) / 1000, 10);
//Protect readonly/automatic properties    
protect('updatedAt');      
protect('disabled');  
protect('internal'); 