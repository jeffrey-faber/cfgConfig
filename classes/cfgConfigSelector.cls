public with sharing class cfgConfigSelector  {

	public List<CFG_CKJ__c> getAllCKJs(Id prodType) {
		return [
			SELECT
				Id,
				Name,
				CFG_ConfigKeys__c,
				CFG_ConfigValue__c,
				CFG_ConfigKeys__r.Name,
				CFG_ConfigValue__r.Key__c,
				CFG_ConfigValue__r.Category__c,
				CFG_ConfigValue__r.fieldValue__c
			FROM
				CFG_CKJ__c
			WHERE
				Product_Type__c = :prodType
			ORDER BY
				CFG_ConfigKeys__r.Name,
				CFG_ConfigValue__r.Key__c
		];
	}

	public List<CFG_ConfigKey__c> getAllNonLinkedConfigKeys() {

		return [
			SELECT
				Id,
				Name
			FROM
				CFG_ConfigKey__c
			WHERE
				ID NOT IN (
					SELECT
						CFG_ConfigKeys__c
					FROM
						CFG_CKJ__c
				)
		];
	}

	public List<CFG_ConfigValue__c> getAllNonLinkedConfigValues() {

		return [
			SELECT
				ID,
				Name,
				Key__c,
				Category__c,
				fieldValue__c
			FROM
				CFG_ConfigValue__c
			WHERE
				ID NOT IN (
					SELECT
						CFG_ConfigValue__c
					FROM
						CFG_CKJ__c
				)
		];
	}

	public List<Product_Type__c> getAllProductTypes() {
		return [
			SELECT
				Id,
				Name
			FROM
				Product_Type__c
		];
	}

	public List<CFG_ConfigKey__c> getAllCFGKeys() {
		return [
			SELECT
				Id,
				Name
			FROM
				CFG_ConfigKey__c
		];
	}
}