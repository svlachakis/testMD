public class qq {

    public List<String> getCustomObjectNames() {
        List<String> customObjectNames = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for (String objectName : schemaMap.keySet()) {
            Schema.SObjectType objType = schemaMap.get(objectName);
            if (objType.getDescribe().isCustom()) {
                customObjectNames.add(objectName);
            }
        }
        return customObjectNames;
    }

}