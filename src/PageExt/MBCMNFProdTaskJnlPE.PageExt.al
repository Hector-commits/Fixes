pageextension 50999 "MBCMNFProdTaskJnlPE" extends "MBC MNF Prod. Task Journal."
{
    actions
    {
        addfirst(Processing)
        {
            action(Delete)
            {
                ToolTip = 'Delete';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ConfirmLbl: Label 'Are you sure you want to delete the selected line?', Comment = 'ESP="¿Está seguro de que desea eliminar la línea seleccionada?"';
                begin
                    if not Confirm(ConfirmLbl) then
                        exit;

                    Rec.Delete(true);
                end;

            }
        }
    }
}
