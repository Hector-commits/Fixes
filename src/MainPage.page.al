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
            part(FirstSubpage; "First Subpage")

            {
                ApplicationArea = All;
                Caption = 'SubPage';
                SubPageLink = "Entry No." = field("Entry No.");
                UpdatePropagation = SubPart;


            }
            part(SecondSubpage; "Second Subpage")
            {
                ApplicationArea = All;
                UpdatePropagation = SubPart;
                Provider = FirstSubpage;
                SubPageLink = "Code" = field("Code");
            }
        }

    }

}