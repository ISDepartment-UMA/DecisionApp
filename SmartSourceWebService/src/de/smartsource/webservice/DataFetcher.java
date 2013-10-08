package de.smartsource.webservice;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.AccessControlException;

import javax.ws.rs.Encoded;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriBuilderException;

import com.intland.codebeamer.persistence.dto.ProjectDto;
import com.intland.codebeamer.persistence.dto.TrackerDto;
import com.intland.codebeamer.persistence.dto.TrackerItemDto;
import com.intland.codebeamer.remoting.RemoteApi;
import com.intland.codebeamer.remoting.RemoteApiFactory;
import com.sun.jersey.api.uri.UriComponent;
import com.sun.jersey.api.uri.UriComponent.Type;

import de.smartsource.datamodel.ComponentInfo;
import de.smartsource.datamodel.ProjectInfo;

/**
 * @author Robert Lorenz Törmer
 * Web Service that returns Data fetched from CodeBeamer
 *
 */

@Path("/DataFetcher")
public class DataFetcher {
	
	@GET
	@Path("/checkLoginData")
	@Produces(MediaType.APPLICATION_JSON)
	public String[] checkLoginData(@QueryParam("url") @Encoded String url, @QueryParam("login") String login, @QueryParam("password") String password){
		
		// connecting
		RemoteApi api = null;
		String codeBeamerUrl = "";
		
		//decoding codebeamer url
		try {
			codeBeamerUrl = URLDecoder.decode(url, "UTF-8");
		} catch (Exception e) {
			//if decoding fails, return simple error
			String[] out = {"error"};
			return out;
		}
		
		// connect to remote api of codebeamer instance
		try {
			api = RemoteApiFactory.getInstance().connect(codeBeamerUrl);
		} catch (MalformedURLException e1) {
			//if url malformed, simple error
			String[] out = new String[1];
			out[0] = "error";
			return out;
			
		}

			
		// signing in
		String token;
		try{
			token = api.login(login, password);
		} catch (AccessControlException e){
			String[] out = new String[1];
			out[0] = "wrongLogin";
			return out;
		} catch (Exception e){
			String[] out = new String[1];
			out[0] = "wrongCodeBeamerUrl";
			return out;
		}  
		
		//if everything works --> success
		String[] out = {"success"};
		return out;
			

	
	}
	
	
	/**
	 * Method returns all Projects from a platform
	 * @param url : url of the codebeamer instance - needs to be encoded by UTF-8
	 * @param login : username of codebeamer user
	 * @param password : password of codebeamer user
	 * @return : Stringarray of all projects from the platform
	 *
	 */
	@GET
	@Path("/getAllProjects")
	@Produces(MediaType.APPLICATION_JSON)
	public String[][] getAllProjects(@QueryParam("url") @Encoded String url, @QueryParam("login") String login, @QueryParam("password") String password){


		// connecting
		RemoteApi api;
		try {

			String codeBeamerUrl = "";
			
			try {
				codeBeamerUrl = URLDecoder.decode(url, "UTF-8");
				
			} catch (Exception e) {
				
			}
			
			

			api = RemoteApiFactory.getInstance().connect(codeBeamerUrl);
			if (api == null) {
				String[][] out = new String[1][1];
				out[0][0] = "wrong url";
				return out;
			}
			
			
			
			// signing in
			String token;
			try{
				token = api.login(login, password);
			} catch (AccessControlException e){
				String[][] out = new String[1][1];
				out[0][0] = "wrong login";
				return out;
			}
			
			if (token == null) {
				String[][] out = new String[1][1];
				out[0][0] = "token null";
				return out;
			}
			

			// retrieving project names
			ProjectDto projects[] = api.findAllProjects(token);
			String[][] aus = new String[projects.length][3];
			for (int i = 0; i < projects.length; i++) {
				ProjectDto currentProject = projects[i];
				aus[i][0] = currentProject.getId().toString();
				aus[i][1] = currentProject.getName();
				aus[i][2] = currentProject.getDescription();
			}
			return aus;

		} catch (MalformedURLException e) {
			String[][] out = new String[1][1];
			out[0][0] = "malformed url";
			return out;
		}

	}
	
	/**
	 * Method that returns all components that belong to a project
	 * @param url : url of the codebeamer instance - needs to be encoded by UTF-8
	 * @param login : username of codebeamer user
	 * @param password : password of codebeamer user
	 * @param projectID : id of the appropriate project
	 * @return : array of componentinfo objects of all components that belong to the project
	 *
	 */
	@GET
	@Path("/getAllComponentsForProject")
	@Produces(MediaType.APPLICATION_JSON)
	public ComponentInfo[] getAllComponentsForProject(@QueryParam("url") @Encoded String url, @QueryParam("login") String login, @QueryParam("password") String password, @QueryParam("projectID") String projectID){
		//connecting
		RemoteApi api;
		try {
			String codeBeamerUrl = "";
			try{
				codeBeamerUrl = URLDecoder.decode(url, "UTF-8");
			} catch (Exception e) {
			}
				
			api = RemoteApiFactory.getInstance().connect(codeBeamerUrl);			
			if(api == null) {
				return null;
			}
			//signing in
			String token = api.login(login, password);
			
			//retrieving project names
			TrackerDto[] tracker = api.findTrackersByProject(token, Integer.parseInt(projectID));
			int indexOfComponents = 0;
			boolean found = false;
			for (int i=0; i<tracker.length; i++){
				if (tracker[i].getName().equalsIgnoreCase("Components") || tracker[i].getName().equalsIgnoreCase("Softwarekomponenten")) {
					indexOfComponents = i;
					found = true;
					continue;
				}
			}
			if (found = false) {
				return null;
			}
			TrackerItemDto[] item = api.findTrackerItemsByTrackerId(token, tracker[indexOfComponents].getId());
			ComponentInfo[] output = new ComponentInfo[item.length];
			for (int i=0; i<item.length; i++){
				output[i] = new ComponentInfo();
				try{
					output[i].setId(item[i].getId().toString());
				} catch (Exception e){
					output[i].setId("");
				}
				try{
					output[i].setName(item[i].getName());
				} catch (Exception e){
					output[i].setName("");
				}
				try{
					output[i].setDescription(item[i].getDescription());
				} catch (Exception e){
					output[i].setDescription("");
				}
				try{
					output[i].setEstimatedhours(item[i].getEstimatedHours().toString());
				} catch (Exception e){
					output[i].setEstimatedhours("");
				}
				try{
					output[i].setShortdescription(item[i].getShortDescription());
				} catch (Exception e){
					output[i].setDescription("");
				}
				try{
					output[i].setPriority(item[i].getPriority().toString());
				} catch (Exception e){
					output[i].setPriority("");
				}
				try{
					output[i].setModifier(item[i].getModifier().getName());
				} catch (Exception e){
					output[i].setModifier("");
				}
			}
			return output;
			
			

		} catch (MalformedURLException e) {
			return null;
		}
	}
	
	/**
	 * Method that returns info about a certain project
	 * @param url : url of the codebeamer instance - needs to be encoded by UTF-8
	 * @param login : username of codebeamer user
	 * @param password : password of codebeamer user
	 * @param projectID : id of the appropriate project
	 * @return : array of projectinfo objects with information of any project
	 *
	 */
	@GET
	@Path("/getInfoForProjectObject")
	@Produces(MediaType.APPLICATION_JSON)
	public ProjectInfo getInfoForProjectObject(@QueryParam("url") @Encoded String url, @QueryParam("login") String login, @QueryParam("password") String password, @QueryParam("projectID") String projectID){
		//connecting
		RemoteApi api;
		try {
			
			String codeBeamerUrl = "";
			try{
				codeBeamerUrl = URLDecoder.decode(url, "UTF-8");
			} catch (Exception e) {
			}
			
			api = RemoteApiFactory.getInstance().connect(codeBeamerUrl);
			if(api == null) {
				return null;
			}
			//signing in
			String token = api.login(login, password);
			
			//retrieving project names
			ProjectDto project = api.findProjectById(token, Integer.parseInt(projectID));
			ProjectInfo output = new ProjectInfo();
			output.setId(projectID);
			try{
				output.setName(project.getName());
			} catch (Exception e){
				output.setName("");
			}
			try{
				output.setDescription(project.getDescription());
			} catch (Exception e){
				output.setDescription("");
			}
			try{
				output.setCategory(project.getCategory());
			} catch (Exception e){
				output.setCategory("");
			}
			try{
				output.setStart(project.getStartDate().toString());
			} catch (Exception e){
				output.setStart("");
			}
			try{
				output.setEnd(project.getEndDate().toString());
			} catch (Exception e){
				output.setEnd("");
			}
			try{
				output.setStatus(project.getStatus().toString());
			} catch (Exception e){
				output.setStatus("");
			}
			try{
				output.setCreator(project.getCreatedBy().getName());
			} catch (Exception e){
				output.setCreator("");
			}
			
			
			return output;

		} catch (MalformedURLException e) {
			return null;
		}

}
	
	/**
	 * Method that returns info about a certain component
	 * @param url : url of the codebeamer instance - needs to be encoded by UTF-8
	 * @param login : username of codebeamer user
	 * @param password : password of codebeamer user
	 * @param componentID : id of the appropriate component
	 * @return : array of componentinfo objects with information of any component
	 *
	 */
	@GET
	@Path("/getComponentInfo")
	@Produces(MediaType.APPLICATION_JSON)
	public ComponentInfo getComponentInfo(@QueryParam("url") @Encoded String url, @QueryParam("login") String login, @QueryParam("password") String password, @QueryParam("componentID") String componentID){
		//connecting
		RemoteApi api;
		try {
			
			String codeBeamerUrl = "";
			try{
				codeBeamerUrl = URLDecoder.decode(url, "UTF-8");
			} catch (Exception e) {
			}
				
			api = RemoteApiFactory.getInstance().connect(codeBeamerUrl);
			if(api == null) {
				return null;
			}
			//signing in
			String token = api.login(login, password);
			
			//retrieving component information
			TrackerItemDto component = api.findTrackerItemById(token, Integer.parseInt(componentID));
			ComponentInfo output = new ComponentInfo();
			
			try{
				output.setId(component.getId().toString());
			} catch (Exception e){
				output.setId("");
			}
			try{
				output.setName(component.getName());
			} catch (Exception e){
				output.setName("");
			}
			try{					
				output.setDescription(component.getDescription());
			} catch (Exception e){
				output.setDescription("");
			}
			try{
				output.setEstimatedhours(component.getEstimatedHours().toString());
			} catch (Exception e){
				output.setEstimatedhours("");
			}
			try{
				output.setShortdescription(component.getShortDescription());
			} catch (Exception e){
				output.setDescription("");
			}
			try{
				output.setPriority(component.getPriority().toString());
			} catch (Exception e){
				output.setPriority("");
			}
			try{
				output.setModifier(component.getModifier().getName());
			} catch (Exception e){
				output.setModifier("");
			}
			
			return output;
			
			

		} catch (MalformedURLException e) {
			return null;
		}
	}
}
