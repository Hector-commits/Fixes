codeunit 50999 "XYZ Update Your Ref."
{
    Subtype = Install;

    Permissions = tabledata "Sales Invoice Header" = rimd;

    trigger OnInstallAppPerCompany()
    begin
        UpdateYourReference();
    end;

    local procedure UpdateYourReference()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";

        Counter: Integer;
        YourReference: Text[35];
    begin
        if Confirm('Do you want to update the Your Reference field on Invoices?') then begin

            Counter := 0;

            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
            SalesHeader.Setfilter("Your Reference", '%1', '');
            if SalesHeader.FindSet() then
                repeat
                    YourReference := '';

                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetFilter("Shipment No.", '<>%1', '');

                    if SalesLine.FindSet() then
                        repeat
                            if SalesShipmentHeader.Get(SalesLine."Shipment No.") and (SalesInvoiceHeader."Your Reference" <> '') then begin
                                YourReference := SalesShipmentHeader."Your Reference";
                                Counter += 1;
                            end;
                        until (SalesLine.Next() = 0) or (YourReference <> '');

                    SalesHeader."Your Reference" := YourReference;
                    SalesHeader.Modify();

                until SalesHeader.Next() = 0;

            Message('Your Reference updated on %1 Invoices.', Counter);
        end;

        if Confirm('Do you want to update the Your Reference field on - - POSTED - - Invoices?') then begin

            Counter := 0;

            SalesInvoiceHeader.Setfilter("Your Reference", '%1', '');
            if SalesInvoiceHeader.FindSet() then
                repeat
                    YourReference := '';

                    SalesInvoiceLine.Reset();
                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetFilter("Shipment No.", '<>%1', '');

                    if SalesInvoiceLine.FindSet() then
                        repeat
                            if SalesShipmentHeader.Get(SalesInvoiceLine."Shipment No.") and (SalesInvoiceHeader."Your Reference" <> '') then begin
                                YourReference := SalesShipmentHeader."Your Reference";
                                Counter += 1;
                            end;
                        until (SalesInvoiceLine.Next() = 0) or (YourReference <> '');

                    SalesInvoiceHeader."Your Reference" := YourReference;
                    SalesInvoiceHeader.Modify();

                until SalesInvoiceHeader.Next() = 0;

            Message('Your Reference updated on %1 - - POSTED - - Invoices.', Counter);
        end;
    end;
}