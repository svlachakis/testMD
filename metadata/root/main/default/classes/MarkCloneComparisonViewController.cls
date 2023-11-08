public with sharing class MarkCloneComparisonViewController {
    @AuraEnabled
    public static String clone(String recordId) {
        PDRI__ComparisonView__c comparisonView =
            [SELECT Name, PDRI__Active__c, PDRI__Default__c, PDRI__Description__c, 
             (SELECT PDRI__Action__c, PDRI__ComparisonView__c, PDRI__FilterType__c, 
            PDRI__FilterValue__c, PDRI__ParentRule__c, PDRI__ParentRuleFilterType__c
            from PDRI__Comparison_View_Rules__r limit 200) from PDRI__ComparisonView__c where Id =:recordId limit 1];
        
        PDRI__ComparisonView__c cloneComparisonView = 
            comparisonView.clone(false, false, false, false);
        
        cloneComparisonView.Name = cloneComparisonView.Name + ' - Clone';
        cloneComparisonView.PDRI__Default__c = false;

        
        insert cloneComparisonView;

        Map<Id,PDRI__ComparisonViewRule__c> comparisonViewRulesMap = 
            new Map<Id,PDRI__ComparisonViewRule__c>();

        List<PDRI__ComparisonViewRule__c> cloneParentComparisonViewRules =
            new List<PDRI__ComparisonViewRule__c>();
        
        List<PDRI__ComparisonViewRule__c> cloneChildComparisonViewRules =
            new List<PDRI__ComparisonViewRule__c>();

        for( PDRI__ComparisonViewRule__c comparisonViewRule : comparisonView.PDRI__Comparison_View_Rules__r ) {
            PDRI__ComparisonViewRule__c cloneComparisonViewRule = 
                comparisonViewRule.clone(false, false, false, false);
            
            cloneComparisonViewRule.PDRI__ComparisonView__c = cloneComparisonView.Id;

            if( cloneComparisonViewRule.PDRI__ParentRule__c != null ) {
                cloneChildComparisonViewRules.add(cloneComparisonViewRule); 
            } else {
                cloneParentComparisonViewRules.add(cloneComparisonViewRule);  
                comparisonViewRulesMap.put(comparisonViewRule.Id, cloneComparisonViewRule);
            }    
        }

        insert cloneParentComparisonViewRules;

        for( PDRI__ComparisonViewRule__c cloneComparisonViewRule : cloneChildComparisonViewRules ) {
            PDRI__ComparisonViewRule__c parentRule = comparisonViewRulesMap.get( cloneComparisonViewRule.PDRI__ParentRule__c );
            
            if( parentRule == null ) {
                continue;
            }
            cloneComparisonViewRule.PDRI__ParentRule__c = parentRule.Id;
        }

        insert cloneChildComparisonViewRules;

        return cloneComparisonView.Id;
    }
}