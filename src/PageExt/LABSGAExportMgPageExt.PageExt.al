///Extend SGA Export Management page with an action to process the purchase order lines
pageextension 50999 "LAB SGA Export Mg Page Ext" extends "SGA Export Management"
{
    actions
    {
        addafter("Show Request")
        {
            action(MarkPurchaseOrderLinesAsExported)
            {
                ApplicationArea = All;
                Caption = 'Mark Purchase Order Lines as Exported';
                Promoted = true;
                PromotedCategory = Process;
                Image = Debug;
                PromotedIsBig = true;
                ToolTip = 'IM Internal Use Only', Comment = 'ESP="IM Internal Use Only"';

                trigger OnAction()
                begin
                    if not confirm('Are you sure you want to mark the purchase order lines as exported?') then
                        exit;

                    PostiOrdenPurchaseLines(Rec)
                end;
            }
        }
    }

    local procedure PostiOrdenPurchaseLines(LABSGAExport: Record "LAB SGA Export")
    var
        iOrdenLines: Record "LAB SGA Export";
        PurchaseHeader: Record "Purchase Header";
        SGAPostediOrden: Record "LAB SGA Posted iOrden";
        SGAExportData: Codeunit "SGA Export Data";
        counter: Integer;
    begin
        counter := 0;
        if LABSGAExport.Type <> LABSGAExport.Type::Purchase then
            exit;

        SGAPostediOrden.SetRange("Document Type", LABSGAExport."Document Type");
        SGAPostediOrden.SetRange("Document No.", LABSGAExport."Document No.");
        SGAPostediOrden.SetRange("Table Number", Database::"Purchase Header");
        if SGAPostediOrden.IsEmpty() then
            Error('The purchase order has not been exported yet.');

        SGAPostediOrden.SetRange("Document Type", LABSGAExport."Document Type");
        SGAPostediOrden.SetRange("Document No.", LABSGAExport."Document No.");
        SGAPostediOrden.SetRange("Table Number", Database::"Purchase Line");
        if SGAPostediOrden.IsEmpty() then
            Error('No Purchase Order Lines exported yet.');

        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, LABSGAExport."Document No.");

        iOrdenLines.Reset();
        iOrdenLines.SetCurrentKey(Type, "Document Type", "Document No.");
        iOrdenLines.SetRange(Type, iOrdenLines.Type::Purchase);
        iOrdenLines.SetRange("Document Type", PurchaseHeader."Document Type");
        iOrdenLines.SetRange("Document No.", PurchaseHeader."No.");
        iOrdenLines.SetRange(Status, 0);
        iOrdenLines.SetRange("Table Number", Database::"Purchase Line");
        if iOrdenLines.FindSet() then
            repeat
                counter := counter + 1;
                SGAExportData.PostiOrden(iOrdenLines)
            until iOrdenLines.Next() = 0;

        Message('%1 purchase order lines marked as exported.', counter);
        CurrPage.Update();
    end;
}
