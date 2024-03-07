page 50850 "Main Page"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = MyTable;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'The unique identifier of the record.';
                }
            }
            part(PartName; "SubPage")
            {
                ApplicationArea = All;
                Caption = 'SubPage';
                SubPageLink = "Entry No." = field("Entry No.");
                UpdatePropagation = SubPart;
            }
            part(AnothePart; SubSubPage)
            {
                ApplicationArea = All;
                UpdatePropagation = SubPart;
            }
        }

    }
    trigger OnAfterGetCurrRecord()
    var
        MyThirdTable: Record "My Third Table";
    begin
        currCode := CurrPage.PartName.Page.getCurrCode();
        MyThirdTable.SetRange(Code, currCode);
        CurrPage.AnothePart.Page.SetTableView(MyThirdTable);
        CurrPage.AnothePart.Page.Update();
    end;

    var
        currCode: Code[10];

}