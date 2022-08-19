
pageextension 50850 "MyExtension" extends "MBC ICG Cashing Up"
{

    actions
    {
        addafter("Post All")
        {
            action(Fix)
            {
                Image = Debug;
                ToolTip = 'Debug', comment = 'ESP="Debug"';
                Caption = 'Debug', Comment = 'ESP="Debug"';
                ApplicationArea = All;

                trigger OnAction()
                var
                    Debug: Codeunit "Debuging ICG";
                begin
                    Debug.PostCashingUp(Rec);
                end;
            }
        }
    }
}
