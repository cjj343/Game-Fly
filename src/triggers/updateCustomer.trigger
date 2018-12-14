trigger updateCustomer on GF_Account__c (after update) {
	
	List<GF_Customer__c> cust = new List<GF_Customer__c>();
	
	for(GF_Account__c acc : Trigger.new){
		
		cust = [SELECT Id, 
				GF_Customer_Email__c, 
				GF_Customer_Name__c, 
				GF_Customer_Phone__c,
				GF_Customer_Shipping_Address__c,
				GF_Customer_Billing_Address__c,			
		 		(SELECT Id FROM GF_Accounts__r) 
		 		from GF_Customer__c];

        			
        if(cust.size() != 1){
        	//TODO: handle error
        }
        else{
        	cust[0].GF_Customer_Email__c = acc.GF_Account_Customer_Email__c;
        	cust[0].GF_Customer_Name__c = acc.GF_Account_Customer_Name__c;
        	cust[0].GF_Customer_Phone__c = acc.GF_Account_Customer_Phone__c;
        	cust[0].GF_Customer_Shipping_Address__c = acc.GF_Account_Customer_Shipping_Address__c;
        	cust[0].GF_Customer_Billing_Address__c = acc.GF_Account_Customer_Billing_Address__c;
        }
	}
	
	update cust;    
}