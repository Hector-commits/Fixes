codeunit 50999 "XYZ Update Your Ref."
{


    Permissions = tabledata "Sales Invoice Header" = rimd;


    trigger OnRun()
    begin
        UpdateYourReference();
    end;

    procedure UpdateYourReference()
    var
        SalesHeader, SalesOrderHeader : Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";

        Counter: Integer;
        YourReference: Text[35];
    begin
        if fSI then begin
            if rangeSI = '' then
                Error('No hay rango!');
            if Confirm('Do you want to update Payment/ShipTo/BillTo/ForeignTrade/B2R & Service Declaration fields on Invoices?') then begin

                Counter := 0;

                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                SalesHeader.SetFilter("No.", rangeSI);
                SalesHeader.Setfilter("Your Reference", '<>%1', '');
                if SalesHeader.FindSet() then
                    repeat
                        YourReference := '';

                        SalesLine.Reset();
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.SetFilter("Shipment No.", '<>%1', '');

                        if SalesLine.FindSet() then
                            repeat
                                if SalesShipmentHeader.Get(SalesLine."Shipment No.") and (SalesShipmentHeader."Your Reference" = SalesHeader."Your Reference") then begin
                                    YourReference := SalesShipmentHeader."Your Reference";
                                    Counter += 1;
                                end;
                            until (SalesLine.Next() = 0) or (YourReference <> '');

                        SalesHeader.SetHideValidationDialog(true);

                        updatePaymentAndShipmentFields(SalesHeader, SalesShipmentHeader);

                        updateShiptoFields(SalesHeader, SalesShipmentHeader);

                        updateBilltoFields(SalesHeader, SalesShipmentHeader);

                        updateForeignTradeFields(SalesHeader, SalesShipmentHeader);

                        if not SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, SalesShipmentHeader."Order No.") then
                            exit;

                        ValidateAllB2RFields(SalesOrderHeader, SalesHeader);

                        ValidateServiceDeclarationFields(SalesOrderHeader, SalesHeader);

                        SalesHeader.Modify();

                    until SalesHeader.Next() = 0;

                Message('Fields updated on %1 Invoices.', Counter);
            end;
        end;

        if fPSI then begin
            if rangePSI = '' then
                Error('No hay rango!');
            if Confirm('Do you want to update tPayment/ShipTo/BillTo/ForeignTrade/B2R & Service Declaration fields on - - POSTED - - Invoices?') then begin

                Counter := 0;

                SalesInvoiceHeader.Setfilter("Your Reference", '<>%1', '');
                SalesInvoiceHeader.SetFilter("No.", rangePSI);
                if SalesInvoiceHeader.FindSet() then
                    repeat
                        YourReference := '';

                        SalesInvoiceLine.Reset();
                        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                        SalesInvoiceLine.SetFilter("Shipment No.", '<>%1', '');

                        if SalesInvoiceLine.FindSet() then
                            repeat
                                if SalesShipmentHeader.Get(SalesInvoiceLine."Shipment No.") and (SalesShipmentHeader."Your Reference" = SalesInvoiceHeader."Your Reference") then begin
                                    YourReference := SalesShipmentHeader."Your Reference";
                                    Counter += 1;
                                end;
                            until (SalesInvoiceLine.Next() = 0) or (YourReference <> '');

                        updateShiptoFields(SalesInvoiceHeader, SalesShipmentHeader);

                        updatePaymentAndShipmentFields(SalesInvoiceHeader, SalesShipmentHeader);

                        updateBilltoFields(SalesInvoiceHeader, SalesShipmentHeader);

                        updateForeignTradeFields(SalesInvoiceHeader, SalesShipmentHeader);

                        if not SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, SalesShipmentHeader."Order No.") then
                            exit;

                        ValidateAllB2RFields(SalesOrderHeader, SalesInvoiceHeader);

                        ValidateServiceDeclarationFields(SalesOrderHeader, SalesInvoiceHeader);

                        SalesInvoiceHeader.Modify();

                    until SalesInvoiceHeader.Next() = 0;

                Message('Fields updated on %1 - - POSTED - - Invoices.', Counter);
            end;
        end;
    end;

    local procedure updateShiptoFields(var SalesInvHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader.Validate("Ship-to Code", SalesShipmentHeader."Ship-to Code");
        SalesInvHeader.Validate("Ship-to Name", SalesShipmentHeader."Ship-to Name");
        SalesInvHeader.Validate("Ship-to Name 2", SalesShipmentHeader."Ship-to Name 2");
        SalesInvHeader.Validate("Ship-to Address", SalesShipmentHeader."Ship-to Address");
        SalesInvHeader.Validate("Ship-to Address 2", SalesShipmentHeader."Ship-to Address 2");
        SalesInvHeader.Validate("Ship-to Contact", SalesShipmentHeader."Ship-to Contact");
        //These fields are inter-related so we make assignments instead of Validations
        SalesInvHeader."Ship-to City" := SalesShipmentHeader."Ship-to City";
        SalesInvHeader."Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
        SalesInvHeader."Ship-to County" := SalesShipmentHeader."Ship-to County";
        SalesInvHeader."Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
    end;

    local procedure updateShiptoFields(var SalesInvHeader: Record "Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        if SalesShipmentHeader."Ship-to Code" <> '' then
            SalesInvHeader."Ship-to Code" := SalesShipmentHeader."Ship-to Code";
        if SalesShipmentHeader."Ship-to Name" <> '' then
            SalesInvHeader."Ship-to Name" := SalesShipmentHeader."Ship-to Name";
        if SalesShipmentHeader."Ship-to Name 2" <> '' then
            SalesInvHeader."Ship-to Name 2" := SalesShipmentHeader."Ship-to Name 2";
        if SalesShipmentHeader."Ship-to Address" <> '' then
            SalesInvHeader."Ship-to Address" := SalesShipmentHeader."Ship-to Address";
        if SalesShipmentHeader."Ship-to Address 2" <> '' then
            SalesInvHeader."Ship-to Address 2" := SalesShipmentHeader."Ship-to Address 2";
        if SalesShipmentHeader."Ship-to Contact" <> '' then
            SalesInvHeader."Ship-to Contact" := SalesShipmentHeader."Ship-to Contact";
        //These fields are inter-related so we make assignments instead of Validations
        SalesInvHeader."Ship-to City" := SalesShipmentHeader."Ship-to City";
        SalesInvHeader."Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
        SalesInvHeader."Ship-to County" := SalesShipmentHeader."Ship-to County";
        SalesInvHeader."Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
    end;

    local procedure updateBilltoFields(var SalesInvHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader."Bill-to Name" := SalesShipmentHeader."Bill-to Name";
        SalesInvHeader."Bill-to Name 2" := SalesShipmentHeader."Bill-to Name 2";
        SalesInvHeader."Bill-to Address" := SalesShipmentHeader."Bill-to Address";
        SalesInvHeader."Bill-to Address 2" := SalesShipmentHeader."Bill-to Address 2";
        SalesInvHeader."Bill-to Contact No." := SalesShipmentHeader."Bill-to Contact No.";
        SalesInvHeader."Bill-to Contact" := SalesShipmentHeader."Bill-to Contact";
        //These fields are inter-related so we make assignments instead of Validations
        SalesInvHeader."Bill-to City" := SalesShipmentHeader."Bill-to City";
        SalesInvHeader."Bill-to Post Code" := SalesShipmentHeader."Bill-to Post Code";
        SalesInvHeader."Bill-to County" := SalesShipmentHeader."Bill-to County";
        SalesInvHeader."Bill-to Country/Region Code" := SalesShipmentHeader."Bill-to Country/Region Code";
    end;

    local procedure updateBilltoFields(var SalesInvHeader: Record "Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader.Validate("Bill-to Name", SalesShipmentHeader."Bill-to Name");
        SalesInvHeader.Validate("Bill-to Name 2", SalesShipmentHeader."Bill-to Name 2");
        SalesInvHeader.Validate("Bill-to Address", SalesShipmentHeader."Bill-to Address");
        SalesInvHeader.Validate("Bill-to Address 2", SalesShipmentHeader."Bill-to Address 2");
        SalesInvHeader.Validate("Bill-to Contact No.", SalesShipmentHeader."Bill-to Contact No.");
        SalesInvHeader.Validate("Bill-to Contact", SalesShipmentHeader."Bill-to Contact");
        //These fields are inter-related so we make assignments instead of Validations
        SalesInvHeader."Bill-to City" := SalesShipmentHeader."Bill-to City";
        SalesInvHeader."Bill-to Post Code" := SalesShipmentHeader."Bill-to Post Code";
        SalesInvHeader."Bill-to County" := SalesShipmentHeader."Bill-to County";
        SalesInvHeader."Bill-to Country/Region Code" := SalesShipmentHeader."Bill-to Country/Region Code";
    end;

    local procedure updateForeignTradeFields(var SalesInvHeader: Record "Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader.Validate("Transaction Specification", SalesShipmentHeader."Transaction Specification");
        SalesInvHeader.Validate("Transport Method", SalesShipmentHeader."Transport Method");
        SalesInvHeader.Validate("Exit Point", SalesShipmentHeader."Exit Point");
        SalesInvHeader.Validate("Area", SalesShipmentHeader."Area");
    end;

    local procedure updateForeignTradeFields(var SalesInvHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader.Validate("Transaction Specification", SalesShipmentHeader."Transaction Specification");
        SalesInvHeader.Validate("Transport Method", SalesShipmentHeader."Transport Method");
        SalesInvHeader.Validate("Exit Point", SalesShipmentHeader."Exit Point");
        SalesInvHeader.Validate("Area", SalesShipmentHeader."Area");
    end;

    local procedure updatePaymentAndShipmentFields(var SalesInvHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvHeader.Validate("Payment Terms Code", SalesShipmentHeader."Payment Terms Code");
        SalesInvHeader.Validate("Payment Method Code", SalesShipmentHeader."Payment Method Code");

        SalesInvHeader.Validate("Shipment Method Code", SalesShipmentHeader."Shipment Method Code");
        SalesInvHeader.Validate("Shipping Agent Code", SalesShipmentHeader."Shipping Agent Code");
        SalesInvHeader.Validate("Shipping Agent Service Code", SalesShipmentHeader."Shipping Agent Service Code");
    end;

    local procedure updatePaymentAndShipmentFields(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesInvoiceHeader.Validate("Payment Terms Code", SalesShipmentHeader."Payment Terms Code");
        SalesInvoiceHeader.Validate("Payment Method Code", SalesShipmentHeader."Payment Method Code");

        SalesInvoiceHeader.Validate("Shipment Method Code", SalesShipmentHeader."Shipment Method Code");
        SalesInvoiceHeader.Validate("Shipping Agent Code", SalesShipmentHeader."Shipping Agent Code");
        //SalesInvoiceHeader.Validate("Shipping Agent Service Code", SalesShipmentHeader."Shipping Agent Service Code");
    end;

    local procedure ValidateAllB2RFields(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Header")
    begin
        SalesInvHeader.Validate("B2R Modalidad Factura", SalesHeader."B2R Modalidad Factura");
        SalesInvHeader.Validate("B2R Numero de facturas", SalesHeader."B2R Numero de facturas");
        SalesInvHeader.Validate("B2R Tipo de factura", SalesHeader."B2R Tipo de factura");
        SalesInvHeader.Validate("B2R Clase de factura", SalesHeader."B2R Clase de factura");
        SalesInvHeader.Validate("B2R Fecha inicio Periodo Fact.", SalesHeader."B2R Fecha inicio Periodo Fact.");
        SalesInvHeader.Validate("B2R Cod. motivo rectificación", SalesHeader."B2R Cod. motivo rectificación");
        SalesInvHeader.Validate("B2R Cod. método corrección", SalesHeader."B2R Cod. método corrección");
        SalesInvHeader.Validate("B2R Corrected Invoice Date", SalesHeader."B2R Corrected Invoice Date");
        SalesInvHeader.Validate("B2R Fecha fin Periodo Fact.", SalesHeader."B2R Fecha fin Periodo Fact.");
        SalesInvHeader.Validate("B2R FacturaE generada", SalesHeader."B2R FacturaE generada");
        SalesInvHeader.Validate("B2R FacturaE enviada", SalesHeader."B2R FacturaE enviada");
        SalesInvHeader.Validate("B2R Facturación electrónica", SalesHeader."B2R Facturación electrónica");
        SalesInvHeader.Validate("B2R Fecha in. Efectos fiscales", SalesHeader."B2R Fecha in. Efectos fiscales");
        SalesInvHeader.Validate("B2R Fecha fin Efectos fiscales", SalesHeader."B2R Fecha fin Efectos fiscales");
        SalesInvHeader.Validate("B2R Cod. Fiscal", SalesHeader."B2R Cod. Fiscal");
        SalesInvHeader.Validate("B2R Cod. Receptor", SalesHeader."B2R Cod. Receptor");
        SalesInvHeader.Validate("B2R Cod. Pagador", SalesHeader."B2R Cod. Pagador");
        SalesInvHeader.Validate("B2R Cod. Comprador", SalesHeader."B2R Cod. Comprador");
        SalesInvHeader.Validate("B2R Nº Expediente", SalesHeader."B2R Nº Expediente");
        SalesInvHeader.Validate("B2R Nº Operación", SalesHeader."B2R Nº Operación");
        SalesInvHeader.Validate("B2R Ref. contrato", SalesHeader."B2R Ref. contrato");
        SalesInvHeader.Validate("B2R Fecha contrato", SalesHeader."B2R Fecha contrato");
        SalesInvHeader.Validate("B2R Fecha operación", SalesHeader."B2R Fecha operación");
        SalesInvHeader.Validate("B2R Nº Operación Emisor", SalesHeader."B2R Nº Operación Emisor");
        SalesInvHeader.Validate("B2R Ref. contrato Emisor", SalesHeader."B2R Ref. contrato Emisor");
        SalesInvHeader.Validate("B2R Fecha contrato Emisor", SalesHeader."B2R Fecha contrato Emisor");
        SalesInvHeader.Validate("B2R Fecha operación Emisor", SalesHeader."B2R Fecha operación Emisor");
        SalesInvHeader.Validate("B2R No. Factura rectificada", SalesHeader."B2R No. Factura rectificada");
        SalesInvHeader.Validate("B2R Bank Payment Code", SalesHeader."B2R Bank Payment Code");
        SalesInvHeader.Validate("B2R Factoring Assignee", SalesHeader."B2R Factoring Assignee");
        SalesInvHeader.Validate("B2R Factoring Bank Code", SalesHeader."B2R Factoring Bank Code");
        SalesInvHeader.Validate("B2R Payment Add. Information", SalesHeader."B2R Payment Add. Information");
        SalesInvHeader.Validate("B2R Group lines", SalesHeader."B2R Group lines");
        SalesInvHeader.Validate("B2R Group text", SalesHeader."B2R Group text");
        SalesInvHeader.Validate("B2R Retencion", SalesHeader."B2R Retencion");
        SalesInvHeader.Validate("B2R Razon Retencion", SalesHeader."B2R Razon Retencion");
        SalesInvHeader.Validate("B2R PaymentInKind Reason", SalesHeader."B2R PaymentInKind Reason");
        SalesInvHeader.Validate("B2R PaymentInKind Amount", SalesHeader."B2R PaymentInKind Amount");
    end;

    local procedure ValidateAllB2RFields(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesInvHeader.Validate("B2R Modalidad Factura", SalesHeader."B2R Modalidad Factura");
        SalesInvHeader.Validate("B2R Numero de facturas", SalesHeader."B2R Numero de facturas");
        SalesInvHeader.Validate("B2R Tipo de factura", SalesHeader."B2R Tipo de factura");
        SalesInvHeader.Validate("B2R Clase de factura", SalesHeader."B2R Clase de factura");
        SalesInvHeader.Validate("B2R Fecha inicio Periodo Fact.", SalesHeader."B2R Fecha inicio Periodo Fact.");
        SalesInvHeader.Validate("B2R Cod. motivo rectificación", SalesHeader."B2R Cod. motivo rectificación");
        SalesInvHeader.Validate("B2R Cod. método corrección", SalesHeader."B2R Cod. método corrección");
        SalesInvHeader.Validate("B2R Corrected Invoice Date", SalesHeader."B2R Corrected Invoice Date");
        SalesInvHeader.Validate("B2R Fecha fin Periodo Fact.", SalesHeader."B2R Fecha fin Periodo Fact.");
        SalesInvHeader.Validate("B2R FacturaE generada", SalesHeader."B2R FacturaE generada");
        SalesInvHeader.Validate("B2R FacturaE enviada", SalesHeader."B2R FacturaE enviada");
        SalesInvHeader.Validate("B2R Facturación electrónica", SalesHeader."B2R Facturación electrónica");
        SalesInvHeader.Validate("B2R Fecha in. Efectos fiscales", SalesHeader."B2R Fecha in. Efectos fiscales");
        SalesInvHeader.Validate("B2R Fecha fin Efectos fiscales", SalesHeader."B2R Fecha fin Efectos fiscales");
        SalesInvHeader.Validate("B2R Cod. Fiscal", SalesHeader."B2R Cod. Fiscal");
        SalesInvHeader.Validate("B2R Cod. Receptor", SalesHeader."B2R Cod. Receptor");
        SalesInvHeader.Validate("B2R Cod. Pagador", SalesHeader."B2R Cod. Pagador");
        SalesInvHeader.Validate("B2R Cod. Comprador", SalesHeader."B2R Cod. Comprador");
        SalesInvHeader.Validate("B2R Nº Expediente", SalesHeader."B2R Nº Expediente");
        SalesInvHeader.Validate("B2R Nº Operación", SalesHeader."B2R Nº Operación");
        SalesInvHeader.Validate("B2R Ref. contrato", SalesHeader."B2R Ref. contrato");
        SalesInvHeader.Validate("B2R Fecha contrato", SalesHeader."B2R Fecha contrato");
        SalesInvHeader.Validate("B2R Fecha operación", SalesHeader."B2R Fecha operación");
        SalesInvHeader.Validate("B2R Nº Operación Emisor", SalesHeader."B2R Nº Operación Emisor");
        SalesInvHeader.Validate("B2R Ref. contrato Emisor", SalesHeader."B2R Ref. contrato Emisor");
        SalesInvHeader.Validate("B2R Fecha contrato Emisor", SalesHeader."B2R Fecha contrato Emisor");
        SalesInvHeader.Validate("B2R Fecha operación Emisor", SalesHeader."B2R Fecha operación Emisor");
        SalesInvHeader.Validate("B2R No. Factura rectificada", SalesHeader."B2R No. Factura rectificada");
        SalesInvHeader.Validate("B2R Bank Payment Code", SalesHeader."B2R Bank Payment Code");
        SalesInvHeader.Validate("B2R Factoring Assignee", SalesHeader."B2R Factoring Assignee");
        SalesInvHeader.Validate("B2R Factoring Bank Code", SalesHeader."B2R Factoring Bank Code");
        SalesInvHeader.Validate("B2R Payment Add. Information", SalesHeader."B2R Payment Add. Information");
        SalesInvHeader.Validate("B2R Group lines", SalesHeader."B2R Group lines");
        SalesInvHeader.Validate("B2R Group text", SalesHeader."B2R Group text");
        SalesInvHeader.Validate("B2R Retencion", SalesHeader."B2R Retencion");
        SalesInvHeader.Validate("B2R Razon Retencion", SalesHeader."B2R Razon Retencion");
        SalesInvHeader.Validate("B2R PaymentInKind Reason", SalesHeader."B2R PaymentInKind Reason");
        SalesInvHeader.Validate("B2R PaymentInKind Amount", SalesHeader."B2R PaymentInKind Amount");
    end;

    local procedure validateServiceDeclarationFields(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Header")
    begin
        SalesInvHeader.Validate("Applicable For Serv. Decl.", SalesHeader."Applicable For Serv. Decl.");
    end;

    local procedure validateServiceDeclarationFields(SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesInvHeader.Validate("Applicable For Serv. Decl.", SalesHeader."Applicable For Serv. Decl.");
    end;

    procedure setGlobals(forSalesInvoices: Boolean; forPostedSalesInvoices: Boolean; rangeSalesInvoice: Code[250]; rangePostedInvoice: Code[250])

    begin
        fSI := forSalesInvoices;
        fPSI := forPostedSalesInvoices;

        rangeSI := rangeSalesInvoice;
        rangePSI := rangePostedInvoice;
    end;

    var
        fSI, fPSI : Boolean;
        rangeSI, rangePSI : Code[250];

}