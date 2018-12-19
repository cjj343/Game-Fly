public with sharing class addGameController {
	public GF_Game__c newGame {get; set;}
	private List<GF_Game__c> games = new List<GF_Game__c>();
	private Id adminAccId;
	
	public addGameController(){
		adminAccId = ApexPages.currentPage().getParameters().get('adminAccountId');
		newGame = new GF_Game__c();
	}
	
	public void saveNewGame(){
		games.add(newGame);
		newGame = new GF_Game__c();
		
	}  
    
    public PageReference done(){
    	insert games;
    	PageReference pageRef = new PageReference('/apex/Admin_Landing_Page');
    	pageRef.getParameters().put('adminAccountId', adminAccId);
        pageRef.setRedirect(true);
        return pageRef;  	
    }
}