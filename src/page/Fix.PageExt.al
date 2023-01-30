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
                begin
                    TransferRoute.SetRange("Transfer-to Code", '');
                    if TransferRoute.FindSet() then
                        repeat
                            if Confirm('Se ha encontrado ruta errónea %1 -> %2. ¿Quiere eliminarla?') then
                                if TransferRoute.Delete() then
                                    Message('Ruta eliminada');
                        until TransferRoute.Next() = 0;
                end;
            }
        }
    }
}