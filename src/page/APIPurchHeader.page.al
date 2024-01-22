page 50999 "API Purch Header"
{
    PageType = API;
    Caption = 'purchHeader';
    APIPublisher = 'im';
    APIGroup = 'bc';
    APIVersion = 'v1.0';
    EntityName = 'purchHeader';
    EntitySetName = 'purchHeader';
    SourceTable = "Purchase Header";
    DelayedInsert = true;
    SaveValues = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(documentType; Rec."Document Type") { }
                field(no; Rec."No.") { }
                field(postingDate; Rec."Posting Date") { }
                field(documentDate; Rec."Document Date")
                {
                    trigger OnValidate()
                    begin
                        WorkDate(Rec."Document Date");
                    end;
                }

            }
        }
    }
}