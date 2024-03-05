page 50851 LabelAPI
{
    PageType = API;
    Caption = 'labelApi';
    APIPublisher = 'sd';
    APIGroup = 'customapi';
    APIVersion = 'v1.0';
    EntityName = 'label';
    EntitySetName = 'labels';
    SourceTable = Item;
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
                field(no; Rec."No.")
                {
                    Caption = 'itemNo';
                }
                field(description; Rec.Description)
                {
                    Caption = 'description';
                }
                field(largeText; Rec."Large Text")
                {
                    Caption = 'data';
                }
            }
        }
    }
}