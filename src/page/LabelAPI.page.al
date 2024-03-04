page 50850 LabelAPI
{
    PageType = API;
    Caption = 'labelApi';
    APIPublisher = 'sd';
    APIGroup = 'customapi';
    APIVersion = 'v1.0';
    EntityName = 'label';
    EntitySetName = 'labels';
    SourceTable = Label;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    //InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(itemNo; "Item No.")
                {
                    Caption = 'itemNo';
                }
                field(description; Description)
                {
                    Caption = 'description';
                }
                /*
                field(type; Type)
                {
                    Caption = 'type';
                }
                */
                field(data; Data)
                {
                    Caption = 'data';
                }
            }
        }
    }
}