page 50999 "Number Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Integer;
    SourceTableView = where(number = const(1));


    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Number; Rec.Number)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                ApplicationArea = All;
                ToolTip = 'Does magic.';

                trigger OnAction()
                var
                    PurchRcptHeader: Record "Purch. Rcpt. Header";
                begin
                    PurchRcptHeader.SetRange("No.", '107215', '107215');
                    PurchRcptHeader.ModifyAll("Vendor Order No.", '63I5JCTGYM3HLKRR9G30');

                end;
            }
        }
    }
}