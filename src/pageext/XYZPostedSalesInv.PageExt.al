pageextension 50999 "XYZ - Posted Sales Inv." extends "Posted Sales Invoices"
{



    actions
    {
        addafter(Navigate)
        {
            action("Update Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Update Your Reference', Comment = 'ESP="Actualizar Referencia"';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update Your Reference', Comment = 'ESP="Actualizar Referencia"';

                trigger OnAction()
                var
                    XYZUpdateYourReference: Codeunit "XYZ Update Your Ref.";
                begin
                    XYZUpdateYourReference.Run();
                end;
            }
        }
    }
}