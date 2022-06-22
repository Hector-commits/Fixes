pageextension 50851 "MyExtension2" extends "General Ledger Entries"
{

    actions
    {
        addafter("&Navigate")
        {
            action(RemoveStuff)
            {
                ApplicationArea = All;
                ToolTip = 'RemoveStuff', Comment = 'ESP="RemoveStuff"';
                Caption = 'RemoveStuff', Comment = 'ESP"RemoveStuff"';
                Promoted = true;
                Image = "8ball";



                trigger OnAction()
                var
                    Fix: Codeunit Fix;
                begin
                    Fix.Run();
                    Message('end');
                end;
            }
        }
    }
}
