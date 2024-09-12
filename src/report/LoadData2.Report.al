report 50998 "Load Data2"
{
    ProcessingOnly = true;
    Caption = 'Create Random Orders';

    requestpage
    {
        layout
        {
            area(content)
            {


            }
        }
    }

    trigger OnPostReport()
    var
        OrderHeader: Record "MBC EPR Order Header";
        OrderLines: Record "MBC EPR Order Lines";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        TransferHeader: Record "Transfer Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        RandomText: Text[20];
        RandomNumber: Integer;
        i, j : Integer;
    begin
        i := 0;
        OrderHeader.SetRange(Code, 'OJMNLBIL0HUK5E4WNV43');
        if OrderHeader.FindFirst() then begin
            PurchaseHeader.FindFirst();
            OrderHeader."Document Type" := OrderHeader."Document Type"::"Purchase Order";
            OrderHeader."BC Document No." := PurchaseHeader."No.";
            OrderHeader.Modify();
        end;

        OrderHeader.SetRange(Code, 'ZRMZQ7MWK3QV2HUKR5HB');
        if OrderHeader.FindFirst() then begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.FindFirst();
            OrderHeader."Document Type" := OrderHeader."Document Type"::"Sales Order";
            OrderHeader."BC Document No." := SalesHeader."No.";
            OrderHeader.Modify();
        end;

        OrderHeader.SetRange(Code, 'L7EDMTE46JUXZBR4L8IC');
        if OrderHeader.FindFirst() then begin
            TransferHeader.FindFirst();
            OrderHeader."Document Type" := OrderHeader."Document Type"::"Transfer Order";
            OrderHeader."BC Document No." := TransferHeader."No.";
            OrderHeader.Modify();
        end;

    end;
}
