public class ContactController {
    
    public String sortField = 'FirstName';
    public String sortDirection = 'ASC'; // for future toggle

    // Main method to fetch and sort contacts
    public List<Contact> getContacts() {
        String query = 'SELECT Id, FirstName, LastName, Email FROM Contact ' +
                       'ORDER BY ' + sortField + ' ' + sortDirection + ' ' +
                       'LIMIT 20';
        return Database.query(query);
    }

    // Sorting Methods
    public PageReference sortByFirstName() {
        sortField = 'FirstName';
        return null;
    }

    public PageReference sortByLastName() {
        sortField = 'LastName';
        return null;
    }

    public PageReference sortByEmail() {
        sortField = 'Email';
        return null;
    }
}

//----------------------------
<apex:page controller="ContactController" >
    <apex:form>
        <apex:pageBlock title="Contact List" id="con_list">
            <apex:pageBlockTable value="{!contacts}" var="con">

                <!-- FirstName Column with Sortable Header -->
                <apex:column value="{!con.FirstName}">
                    <apex:facet name="header">
                        <apex:commandLink action="{!sortByFirstName}" reRender="con_list">
                            First Name
                        </apex:commandLink>
                    </apex:facet>
                </apex:column>

                <!-- LastName Column -->
                <apex:column value="{!con.LastName}">
                    <apex:facet name="header">
                        <apex:commandLink action="{!sortByLastName}" reRender="con_list">
                            Last Name
                        </apex:commandLink>
                    </apex:facet>
                </apex:column>

                <!-- Email Column -->
                <apex:column value="{!con.Email}">
                    <apex:facet name="header">
                        <apex:commandLink action="{!sortByEmail}" reRender="con_list">
                            Email
                        </apex:commandLink>
                    </apex:facet>
                </apex:column>

            </apex:pageBlockTable>
        </apex:pageBlock>
    </apex:form>
</apex:page>