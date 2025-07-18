<apex:page standardController="Account" recordSetVar="accountList">
    <apex:form>
        <apex:pageBlock title="Account List">

            <!-- Filter Dropdown -->
            <p>Filter:</p>
            <apex:selectList value="{!filterId}" size="1">
                <apex:selectOptions value="{!listViewOptions}"/>
                <apex:actionSupport event="onchange" reRender="accounts_List"/>
            </apex:selectList>

            <!-- Account Table -->
            <apex:pageBlockTable value="{!accountList}" var="acc" id="accounts_List">
                <apex:column value="{!acc.Name}"/>
                <apex:column value="{!acc.Phone}"/>
                <apex:column value="{!acc.Rating}"/>
                <apex:column value="{!acc.Type}"/>
            </apex:pageBlockTable>

        </apex:pageBlock>
    </apex:form>
</apex:page>