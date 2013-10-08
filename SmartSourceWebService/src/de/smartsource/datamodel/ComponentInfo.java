package de.smartsource.datamodel;


public class ComponentInfo {
	
	private String id;
	private String name;
	private String priority;
	private String description;
	private String estimatedhours;
	private String shortdescription;
	private String modifier;
	
	public ComponentInfo(){
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		if (priority.equals("1")){
			this.priority = "Really High";
		} else if (priority.equals("2")){
			this.priority = "High";
		} else if (priority.equals("3")){
			this.priority = "Normal";
		} else if (priority.equals("4")){
			this.priority = "Low";
		} else if (priority.equals("5")){
			this.priority = "Really Low";
		} else {
			this.priority = "None";
		}
			

	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getEstimatedhours() {
		return estimatedhours;
	}

	public void setEstimatedhours(String estimatedhours) {
		this.estimatedhours = estimatedhours;
	}

	public String getShortdescription() {
		return shortdescription;
	}

	public void setShortdescription(String shortdescription) {
		this.shortdescription = shortdescription;
	}

	public String getModifier() {
		return modifier;
	}

	public void setModifier(String modifier) {
		this.modifier = modifier;
	}
	
	

}

