public with sharing class LoginPageController {
    //hold username and password
    public String username { get; set; }
    public String password { get; set; }
    //repopulates with acct or admin for each page
    public List<GF_Admin__c> adminAcct { get; set;}
    public List<GF_Account__c> accounts{ get; set;}
    //pass record ID's as page parameters to keep track of admin or accr
    private Id userAccId;
    private Id adminAccId;
    //register page needs an account object to add in info
    //admin accounts can only be created through Salesforce
    public GF_Account__c newAccount {get; set;}
    
    //for admin add game page
   	public GF_Game__c newGame {get; set;}
	private List<GF_Game__c> games = new List<GF_Game__c>();
    
    //containers to hold game items
    public List<gameWrapper> gameWrapperList {get; set;}
    public List<gameWrapper> cartList {get; set;}
    public Decimal cartTotal {get; set;}
    List<gameWrapper> selectedProducts = new List<gameWrapper>();
   	
   	//game wrapper holds a game object and status variables       
	public class gameWrapper {
        public GF_Game__c game { get; set; }
        public Integer quantity { get; set; }//amount cust selects for cart
        public Boolean status { get; set; }//check if item is selected
        public Boolean remove { get; set; }//check if cust wants to remove
        public Boolean deleteGame { get; set; }//available for admin delete
        public Decimal total { get; set; }//cart total
        
        //game wrapper constructor
        public gameWrapper(GF_Game__c g, Integer q){
            game = g;
            quantity = q;
            status = false;
            remove = false;
            deleteGame = false;
            total = 0;
        }
    }
    
    //constructor  
    public LoginPageController(){
    	cartTotal = 0; //set cart total to zero
 		newAccount = new GF_Account__c();//initialize a new account if register is selected
 		newGame = new GF_Game__c(); //initialize new game object
 		userAccId = ApexPages.currentPage().getParameters().get('userAccountId');//populate id's
 		adminAccId = ApexPages.currentPage().getParameters().get('adminAccountId');
 		if(adminAcct == null){
 			adminAcct = new List<GF_Admin__c>();
 		}
 		 if(adminAcct == null){
 			accounts = new List<GF_Account__c>();
 		}
		
		//find admin and acct with saved Id
		//is null for for landing page
 		adminAcct = [SELECT Id, GF_Admin_Username__c FROM GF_Admin__c WHERE Id = :adminAccId];
        accounts = [SELECT Id, GF_Account_Customer_Email__c, 
        				GF_Account_Customer_Name__c, GF_Account_Customer_Phone__c, 
        				GF_Username__c, GF_Password__c, GF_Account_Customer_Shipping_Address__c, 
        				GF_Account_Customer_Billing_Address__c, Card_Number__c, Card_Type__c, 
        				Expiration_Date__c, Security_Code__C   
        			FROM GF_Account__c 
        			WHERE Id = :userAccId];
        
        //creates a new game wrapper
        if(gameWrapperList == null) {
            gameWrapperList = new List<gameWrapper>();
            for(GF_Game__c g: [SELECT Name, GF_Game_Console__c, GF_Game_Description__c, GF_Game_Price__c FROM GF_Game__c]) {
                gameWrapperList.add(new gameWrapper(g, 0));
            }
        }
        
        //TODO: error handling on no account or more than one acct
    }			
        			 
    public PageReference login(){
    	//look for admin accts that match password and username
    	//assign to list
    	adminAcct = [SELECT Id, GF_Admin_Username__c, GF_Admin_Password__c FROM GF_Admin__c WHERE GF_Admin_Username__c = :username AND GF_Admin_Password__c = :password];
    	
    	//make sure we only have one acct
    	if(adminAcct.size() == 1){
    		PageReference pageRef = new PageReference('/apex/Admin_Landing_Page');
		    pageRef.setRedirect(true);
		    pageRef.getParameters().put('adminAccountId', adminAcct[0].id);//put the id in page var
		    return pageRef;	
    	}
    	
    	//look for  accts that match password and username
    	//assign to list			
		accounts = [SELECT Id, GF_Username__c, GF_Password__c FROM GF_Account__c WHERE GF_Username__c = :username AND GF_Password__c = :password];	
		    
		if(accounts.size() == 1){
			PageReference pageRef = new PageReference('/apex/AccountLanding');
	        pageRef.setRedirect(true);
	        pageRef.getParameters().put('userAccountId', accounts[0].id);
	        return pageRef; 
		}
		    
		else{ 
			//TODO: error handling
			return null;         
   
		}	
    }
    
    //page redirect to update acct
    public PageReference updateAcctInfo(){
    	    PageReference pageRef = new PageReference('/apex/updateAccount');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('userAccountId', userAccId);
            return pageRef;	
    }
    
    //updates user acct based on input
    public PageReference saveAcctInfo(){

    	update accounts[0];

    	PageReference pageRef = new PageReference('/apex/AccountLanding');
    	pageRef.getParameters().put('userAccountId', userAccId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //creates new account and customer and sets appropriate relationship
    public PageReference createAccount(){
    	//TODO: check against multiple accounts with same info
    	GF_Customer__c newCust = new GF_Customer__c();  	
    	newCust.GF_Customer_Name__c = newAccount.GF_Account_Customer_Name__c;
    	newCust.GF_Customer_Email__c = newAccount.GF_Account_Customer_Email__c;
    	newCust.GF_Customer_Phone__c = newAccount.GF_Account_Customer_Phone__c;
    	newCust.GF_Customer_Shipping_Address__C = newAccount.GF_Account_Customer_Shipping_Address__c;
    	newCust.GF_Customer_Billing_Address__C = newAccount.GF_Account_Customer_Billing_Address__c;
    	insert newCust;
    	newAccount.GF_Customer__c = newCust.Id; //assign master detail relationship
    	insert newAccount;
	   	PageReference pageRef = new PageReference('/apex/LoginPage');
        pageRef.setRedirect(true);
        return pageRef;		
    }
    
    //page redirect to shopping page
    public PageReference rentGames(){
    	PageReference pageRef = new PageReference('/apex/shoppingPage');
    	pageRef.getParameters().put('userAccountId', userAccId);
        pageRef.setRedirect(true);
        return pageRef;  	
    }
    
    //takes items from product list and places them in a cart
    public void processSelected() { 
        cartList = new List<gameWrapper>();
        cartTotal = 0;
        
        //loops through all games and check if status has been set to true by checkbox
        for(gameWrapper wrapObj : gameWrapperList) {
            if(wrapObj.status == true) {
                if(selectedProducts.contains(wrapObj)){
                    selectedProducts[selectedProducts.indexOf(wrapObj)].Quantity++;
                    selectedProducts[selectedProducts.indexOf(wrapObj)].total = selectedProducts[selectedProducts.indexOf(wrapObj)].Quantity * selectedProducts[selectedProducts.indexOf(wrapObj)].game.GF_Game_Price__c;
                    selectedProducts[selectedProducts.indexOf(wrapObj)].Status = true;
                }
                else{
                    selectedProducts.add(wrapObj);
                    selectedProducts[selectedProducts.indexOf(wrapObj)].Status = true;
                    selectedProducts[selectedProducts.indexOf(wrapObj)].Quantity++;
                    selectedProducts[selectedProducts.indexOf(wrapObj)].total = selectedProducts[selectedProducts.indexOf(wrapObj)].Quantity * selectedProducts[selectedProducts.indexOf(wrapObj)].game.GF_Game_Price__c;
                }
            }
        }
        
        //then add to cart
        for(gameWrapper cartItem : selectedProducts){
            cartTotal += cartItem.total;
            cartList.add(cartItem);
        }
    }
    
    //checks if anything has been removed from the cart
    public void updateCart(){
        for(gameWrapper wrapObj : cartList) {
            if(wrapObj.remove == true) {
                    wrapObj.remove = false;
                    wrapObj.status = false;
                    wrapObj.Quantity = 0;
                    wrapObj.total = 0;
                    selectedProducts.remove(selectedProducts.indexOf(wrapObj));
            }
        }
        
        cartList = new List<gameWrapper>();
        cartTotal = 0;
        for(gameWrapper cartItem : selectedProducts){
            cartTotal += cartItem.total;
            cartList.add(cartItem);
        }
    }
    
    /*
    public void checkOut(){
        Transaction__c trans = new Transaction__c(Name = 'testtransfromVF1');
        insert trans;
        ID transID = trans.Id;
        List<Product_Order__c> prods = new List<Product_Order__c>();
        
        for(productWrapper i : selectedProducts){
            prods.add(new Product_Order__c(Transaction__c = transID, Product__c = i.prod.Id, Quantity__c = i.Quantity));
        }
        
        cartTotal = 0;
        selectedProducts.clear();
        cartList.clear();
        
        insert prods;
        update trans;
    }
    */
    
    //page redirect to admin functions
    public PageReference addGameRedirect(){
    	PageReference pageRef = new PageReference('/apex/addGamePage');
    	pageRef.getParameters().put('adminAccountId', adminAccId);
        pageRef.setRedirect(true);
        return pageRef;  	
    }
    
    //allows admin to delete games
    public PageReference deleteGames(){
    	for(gameWrapper wrapObj : gameWrapperList) {
            if(wrapObj.deleteGame == true) {
				delete wrapObj.game;
            }
        }
        PageReference tempPage = ApexPages.currentPage();           
        tempPage.setRedirect(true);
        return tempPage;
    }
    
    public PageReference done(){
    	insert games;
    	PageReference pageRef = new PageReference('/apex/Admin_Landing_Page');
    	pageRef.getParameters().put('adminAccountId', adminAccId);
        pageRef.setRedirect(true);
        return pageRef;  	
    }
    
    public void saveNewGame(){
		games.add(newGame);
		newGame = new GF_Game__c();
		
	}

}