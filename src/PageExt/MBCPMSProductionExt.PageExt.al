pageextension 50999 "MBC PMS Production Ext" extends "MBC PMS Production Summary"
{

    actions
    {
        addafter(Process)
        {
            action(UnMarkProcessed)
            {
                ApplicationArea = All;
                Caption = 'UnMark Processed', Comment = 'ESP="Desmarcar Procesado"';
                ToolTip = 'UnMark Processed', Comment = 'ESP="Desmarcar Procesado"';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                begin
                    if not confirm('Está seguro de desmarcar este registro como procesado', true) then
                        exit;
                    Rec."Process Production" := false;
                    Rec.Modify();
                end;
            }
        }
    }

}