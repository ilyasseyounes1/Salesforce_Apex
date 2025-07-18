<apex:page >
    
    <apex:pageBlock>
    	<apex:pageBlockSection title="First page block section">
            {! $User.FirstName & '-' & $User.LastName}
            <p>
                Today's Date is {!TODAY()}
            </p>
            <P>
                Current Year is {!YEAR(TODAY())}
            </P>
            <P>
                {!IF (CONTAINS ('salesforce.com','force.com'),'yes','No')}
            </P>
        </apex:pageBlockSection>
        <apex:pageBlockSection title="Second page block section">
        	Helow this is the second Section
        </apex:pageBlockSection>
    </apex:pageBlock>
</apex:page>
//--------------------------------

<apex:page standardController="Account">
    <apex:form>
        <table border="1">
            <tr>
                <td>Account Name</td>
                <td><apex:inputField value="{!Account.Name}"/></td>
            </tr>
            <tr>
                <td>Phone</td>
                <td><apex:inputField value="{!Account.Phone}"/></td>
            </tr>
            <tr>
                <td>Rating</td>
                <td><apex:inputField value="{!Account.Rating__c}"/></td>
            </tr>
            <tr>
                <td><apex:commandButton value="Save" action="{!save}"/></td>
                <td><apex:commandButton value="Cancel" action="{!cancel}"/></td>
            </tr>
        </table>
    </apex:form>
</apex:page>
//---------------------------
    // looks like native Salesforce UI (classic-style) is because of the Visualforce components used, especially 
<apex:page standardController="Account">
    <apex:form>
    	<apex:pageBlock title="Account information">
            <apex:pageBlockSection columns="1">
                <apex:inputField  value="{!Account.Name}"/>
                <apex:inputField  value="{!Account.Phone}"/>
                <apex:inputField  value="{!Account.Rating}"/>
                <apex:inputField  value="{!Account.Active__c}"/>
                </apex:pageBlockSection>
            
            	<apex:pageBlockButtons>
                	<apex:commandButton value="Save" action="{!save}"/>
                    <apex:commandButton value="Cancel" action="{!cancel}"/>
                </apex:pageBlockButtons>
                         
        </apex:pageBlock>
    </apex:form>
</apex:page>