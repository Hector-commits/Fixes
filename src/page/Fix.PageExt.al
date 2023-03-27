pageextension 50850 "Fix" extends "Transfer Routes"
{

    actions
    {
        addafter("Next Set")
        {
            action("Delete Routes")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    TransferRoute: Record "Transfer Route";
                    DeleteRouteLbl: Label 'Se ha encontrado ruta errónea desde %1 -> hasta %2. ¿Quiere eliminarla?';
                begin
                    TransferRoute.SetRange("Transfer-to Code", '');
                    if TransferRoute.FindSet() then
                        repeat
                            if Confirm(StrSubstNo(DeleteRouteLbl, TransferRoute."Transfer-from Code", TransferRoute."Transfer-to Code"), false) then
                                if TransferRoute.Delete() then
                                    Message('Ruta eliminada');
                        until TransferRoute.Next() = 0;
                end;
            }
        }
    }
}