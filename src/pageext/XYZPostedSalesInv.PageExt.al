pageextension 50999 "XYZ - Posted Sales Inv." extends "Posted Sales Invoices"
{



    actions
    {
        addafter(Navigate)
        {
            action("Update Invoice Data")
            {
                ApplicationArea = All;
                Caption = 'Update Invoice Data', Comment = 'ESP="Actualiza datos facturas"';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update Invoice Data', Comment = 'ESP="Actualizar datos facturas"';

                trigger OnAction()
                var
                    XYZUpdateReport: Report "XYZ Update Report";
                begin
                    XYZUpdateReport.Run();
                end;
            }
        }
    }
}