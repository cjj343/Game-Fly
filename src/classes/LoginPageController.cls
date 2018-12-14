public with sharing class LoginPageController {
    
    public String username { get; set; }
    public String password { get; set; }
    public List<GF_Account__c> userAcct {get; set;}
    public List<GF_Admin__c> adminAcct {get; set;}
    public List<GF_Account__c> accounts{ get{if(accounts == null) accounts = new List<GF_Account__c>(); return accounts;} set;}
    private Id userAccId;
    private Id adminAccId;
    public GF_Account__c newAccount {get; set;}
    public List<gameWrapper> gameWrapperList {get; set;}
   	       
	public class gameWrapper {
        public GF_Game__c game { get; set; }
        public Integer quantity { get; set; }
        public Boolean status { get; set; }
        public Boolean remove { get; set; }
        public Decimal total { get; set; }
        
        
        public gameWrapper(GF_Game__c g, Integer q){
            game = g;
            quantity = q;
            status = false;
            remove = false;
            total = 0;
 
        }
    }
    
    
    
    public LoginPageController(){
 		newAccount = new GF_Account__c();
 		userAccId = ApexPages.currentPage().getParameters().get('userAccountId');
 		adminAccId = ApexPages.currentPage().getParameters().get('adminAccountId');
 		
 		if(adminAcct == null){
 			adminAcct = new List<GF_Admin__c>();
 		}
 		
 		adminAcct = [SELECT Id, GF_Admin_Username__c FROM GF_Admin__c WHERE Id = :adminAccId];
        
        if(userAcct == null){
            userAcct = new List<GF_Account__c>();
        }
        
        userAcct = [SELECT Id, GF_Account_Customer_Email__c, 
        				GF_Account_Customer_Name__c, GF_Account_Customer_Phone__c, 
        				GF_Username__c, GF_Password__c, GF_Account_Customer_Shipping_Address__c, 
        				GF_Account_Customer_Billing_Address__c, Card_Number__c, Card_Type__c, 
        				Expiration_Date__c, Security_Code__C   
        			FROM GF_Account__c 
        			WHERE Id = :userAccId];
        
        if(gameWrapperList == null) {
            gameWrapperList = new List<gameWrapper>();
            for(GF_Game__c g: [SELECT Name, GF_Game_Console__c, GF_Game_Description__c, GF_Game_Price__c FROM GF_Game__c]) {
                gameWrapperList.add(new gameWrapper(g, 0));
            }
        }
        
        //TODO: error handling on no account or more than one acct
    }			
        			 
    public PageReference login(){
    	adminAcct = [SELECT Id, GF_Admin_Username__c, GF_Admin_Password__c FROM GF_Admin__c WHERE GF_Admin_Username__c = :username AND GF_Admin_Password__c = :password];
    	
    	if(adminAcct.size() == 1){
    		PageReference pageRef = new PageReference('/apex/Admin_Landing_Page');
		    pageRef.setRedirect(true);
		    pageRef.getParameters().put('adminAccountId', adminAcct[0].id);
		    return pageRef;	
    	}
			
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
    
    public PageReference updateAcctInfo(){
    	    PageReference pageRef = new PageReference('/apex/updateAccount');
            pageRef.setRedirect(true);
            pageRef.getParameters().put('userAccountId', adminAccId);
            return pageRef;	
    }
    
    public PageReference saveAcctInfo(){
    	update userAcct[0];
    	PageReference pageRef = new PageReference('/apex/AccountLanding');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference createAccount(){
    	//TODO: check against multiple accounts with same info
    	GF_Customer__c newCust = new GF_Customer__c();  	
    	newCust.GF_Customer_Name__c = newAccount.GF_Account_Customer_Name__c;
    	newCust.GF_Customer_Email__c = newAccount.GF_Account_Customer_Email__c;
    	newCust.GF_Customer_Phone__c = newAccount.GF_Account_Customer_Phone__c;
    	newCust.GF_Customer_Shipping_Address__C = newAccount.GF_Account_Customer_Shipping_Address__c;
    	newCust.GF_Customer_Billing_Address__C = newAccount.GF_Account_Customer_Billing_Address__c;
    	insert newCust;
    	newAccount.GF_Customer__c = newCust.Id;	
    	insert newAccount;
	   	PageReference pageRef = new PageReference('/apex/LoginPage');
        pageRef.setRedirect(true);
        return pageRef;		
    }
}