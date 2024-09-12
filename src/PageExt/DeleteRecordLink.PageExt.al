pageextension 50999 "Delete Record Link" extends "Customer List"
{


    actions
    {
        addafter(ApplyTemplate)
        {
            action(DeleteRecordLinks)
            {
                Caption = 'Delete Record Links';
                Image = Delete;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RecordLink: Record "Record Link";
                    Item: Record "Item";
                begin

                    if not confirm('Are you sure you want to delete all items recordLinks?') then
                        exit;

                    Item.Findset();
                    repeat
                        RecordLink.SetRange("Record ID", Item.RecordId);
                        if RecordLink.FindFirst() then
                            RecordLink.Delete();
                    until Item.Next() = 0;
                end;
            }
        }
    }
}