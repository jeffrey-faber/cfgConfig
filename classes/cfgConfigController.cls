public with sharing class cfgConfigController {

	public List<cfgConfigTableItem>  CKJList {get; private set; }
	public List<Product_Type__c>  productTypes {get; private set; }
	public List<CFG_ConfigKey__c>  cfgKeys {get; private set; }
	public String  selectedProductType {get; set; }
	public String  selectedProductTypeName {get; set; }
	public String  selectedProductTypeForCkj {get; set; }
	public Boolean isLoading {get; set;}
	public Boolean deleteAllowed {get; set;}
	public Integer ckjCreateCount {get; set;}

	public cfgConfigController() {
		this.productTypes = new List<Product_Type__c>();
		this.productTypes = new List<Product_Type__c>();
		refreshPageData();
	}

	public void refreshPageData() {
		deleteAllowed = false;
		ckjCreateCount = 0;
		populateCKJ();
		populateProductTypes();
		populateCfgKeys();
	}

	public void updateCkjCreateCount() {
		selectedListItems listItems = getSelectedListItems();
		this.ckjCreateCount = listItems.keys.size() * listItems.values.size();
	}

	public selectedListItems getSelectedListItems() {
		Set<Id> keys = new Set<Id>();
		Set<Id> values = new Set<Id>();

		for (cfgConfigTableItem tableItem : this.CKJList) {
			if (tableItem.keySelected && tableItem.keyId != null) {
				keys.add(tableItem.keyId);
			}
			if (tableItem.valueSelected && tableItem.valueId != null) {
				values.add(tableItem.valueId );
			}
		}

		return new selectedListItems(keys, values);
	}

	public void createSelectedCKJs(){
		List<CFG_CKJ__c> newCKJs = new List<CFG_CKJ__c>();
		selectedListItems listItems = getSelectedListItems();

		for (Id key : listItems.keys) {

			for (Id value : listItems.values) {
				CFG_CKJ__c ckj = new CFG_CKJ__c();
				ckj.CFG_ConfigValue__c = value;
				ckj.CFG_ConfigKeys__c = key;
				ckj.Product_Type__c = this.selectedProductTypeForCkj;
				newCKJs.add(ckj);
			}
		}

		insert newCKJs;
		refreshPageData();

	}
	public List<SelectOption> getProductTypesOptions() {

		return createStandardOptionsList(this.productTypes,'null');
	}

	public List<SelectOption> getKeysOptions() {

		return createStandardOptionsList(this.cfgKeys,'Please Select a Key');
	}

	public void populateCKJ() {
		this.CKJList = new List<cfgConfigTableItem> ();
		List<CFG_CKJ__c> ckjlist = getFullList((Id) selectedProductType);

		for (CFG_CKJ__c cfg : ckjlist) {
			if (cfg != null) {
				cfgConfigTableItem tableItem = new cfgConfigController.cfgConfigTableItem(cfg);
				this.CKJList.add(tableItem);
			}
		}
	}

	public void populateProductTypes() {
		this.productTypes = cfgSelector.getAllProductTypes();
	}

	public void populateCfgKeys() {
		this.cfgKeys = cfgSelector.getAllCFGKeys();
	}

	public List<CFG_CKJ__c> getFullList(Id prodType){
		List<CFG_CKJ__c> allObjs = cfgSelector.getAllCKJs(prodType);
		if (prodType == null) {

			for (CFG_ConfigValue__c val : cfgSelector.getAllNonLinkedConfigValues()) {
				CFG_CKJ__c ckj = new CFG_CKJ__c(
					CFG_ConfigValue__r = val
				);
				allObjs.add(ckj);
			}

			for (CFG_ConfigKey__c val : cfgSelector.getAllNonLinkedConfigKeys()) {
				CFG_CKJ__c ckj = new CFG_CKJ__c(
					CFG_ConfigKeys__r = val
				);
				allObjs.add(ckj);
			}
		}
		updateSelectedPTName();
		return allObjs;
	}

	private List<SelectOption> createStandardOptionsList(List<sObject> objs, String emptySelection) {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', emptySelection)};

		for (sObject obj : objs) {
			String name = String.valueOf(obj.get('name'));
			options.add(new SelectOption(obj.Id, name));
		}

		return options;
	}

	public void deleteSelected() {
		if (this.deleteAllowed) {
			List<CFG_CKJ__c> ckjList = new List<CFG_CKJ__c>();

			for (cfgConfigTableItem row : this.CKJList) {
				if (row.ckjSelected) {
					ckjList.add(row.ckj);
				}
			}
			delete ckjList;
			refreshPageData();
		}
	}

	public void updateSelectedPTName() {
		for (Product_Type__c pt : this.productTypes){
			if (pt.id == selectedProductType) {
				this.selectedProductTypeName = pt.name;
			}
		}
		this.selectedProductTypeName = this.selectedProductTypeName == null ? EMPTY_PRODUCT_TYPE : this.selectedProductTypeName;
	}

	public class cfgConfigTableItem {
		public CFG_CKJ__c ckj  {get; set; }
		public Boolean keySelected  {get; set; }
		public Boolean valueSelected  {get; set; }
		public Boolean ckjSelected  {get; set; }
		public Id keyId {get; set;}
		public Id valueId {get; set;}

		public cfgConfigTableItem(CFG_CKJ__c cfgCkj) {
			this.ckj = cfgCkj;
			this.keySelected = false;
			this.valueSelected = false;
			this.ckjSelected = false;
			this.valueId = cfgCkj.CFG_ConfigValue__r.Id;
			this.keyId = cfgCkj.CFG_ConfigKeys__r.Id;
		}
	}

	public class selectedListItems {
		public Set<Id> keys;
		public Set<Id> values;

		public selectedListItems(Set<Id> keys, Set<Id> values) {
			this.keys = keys;
			this.values = values;
		}

	}

	private final String EMPTY_PRODUCT_TYPE = '<Empty Product Type>';

	private cfgConfigSelector cfgSelector = new cfgConfigSelector();
}
