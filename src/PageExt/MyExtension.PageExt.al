pageextension 50999 MyExtension extends "Transfer Orders"
{

    actions
    {
        addafter("Get Bin Content")
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Image = "Delete";
                Caption = 'Delete';
                Promoted = true;
                PromotedCategory = "Process";
                PromotedIsBig = true;


                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                    TransferLine: Record "Transfer Line";
                begin
                    if not Confirm('Are you sure you want to delete this transfer order?') then
                        exit;

                    TransferLine.SetRange("Document No.", Rec."No.");
                    TransferLine.DeleteAll(false);

                    TransferHeader.GET(Rec."No.");
                    TransferHeader.Delete(false);

                    Message('Deleted!');

                end;
            }
        }
    }
}