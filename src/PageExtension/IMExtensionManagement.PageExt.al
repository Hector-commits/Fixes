pageextension 50850 "IM Extension Management" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action("Delete Tasks")
            {
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Delete tasks';
                Caption = 'Delete tasks';

                trigger OnAction()
                var
                    TaskDeleter: Codeunit "IM Task Deleter";
                begin
                    TaskDeleter.deleteTasks();
                end;
            }
        }
    }
}