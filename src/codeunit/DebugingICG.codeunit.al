codeunit 50850 "Debuging ICG"

{

    var
        DimMgt: Codeunit DimensionManagement;
        GetDim: Codeunit "MBC ICG Integration Managment";
        Text50000Lbl: Label 'P-';
        Text50001Lbl: Label 'Invoice Payment %1.', Comment = 'ESP="Pago %1"';
        Text50002Lbl: Label 'Difference between charges and total simplified invoices', Comment = 'ESP="Difer. entre cargos y el total de fras. simplif."';
        Text50005Lbl: Label 'R-';
        Text50006Lbl: Label 'Credit Memo Refund %1.', Comment = 'ESP="Reembolso %1"';
        Text50007Lbl: Label 'Too much difference of amont from del cuadre de la factura de la tienda %1, caja %2, z %3,  importe %4.', Comment = 'ESP="Demasiada diferencia en el importe del cuadre de la factura de la tienda %1, caja %2, z %3,  importe %4."';
        Text50008Lbl: Label 'Confirm register closeout %1 from POS %2 of shop %3?', Comment = 'Confirma que desea registrar el cierre %1 del TPV %2 de la tienda %3?';
        Text50010Lbl: Label 'Cashing Up imported.', comment = 'ESP="Cierre caja ya importado."';
        Text50011Lbl: Label 'The treasury cannot be empty', Comment = 'ESP="La tesorería no puede estar vacía"';
        Text50012Lbl: Label 'Too much difference between sales on ICG and BC on POS %1, closeout %2, z %3,  amount %4.', Comment = 'ESP="Demasiada diferencia entre ventas ICG y BC en la tienda %1, caja %2, z %3,  importe %4."';
        Text50013Lbl: Label '%1 %2 %3 %4 has invoiced lines. Closing up must be processed manually.', Comment = 'ESP="%1 %2 %3 %4 tiene líneas facturadas. Debe procederse al registro manual del cierre"';
        HideDialog: Boolean;
        salesInvoicePosted: Boolean;
        creditMemoPosted: Boolean;

    procedure CreateCashingUp(var LXDClosingDay: Record "MBC ICG Closing Day")
    var
        CashingUp: Record "MBC ICG Cashing Up";
        PaymentMethod: Record "Payment Method";
        Salesperson: Record "Salesperson/Purchaser";
    begin

        OnBeforeCreateCashingUp(LXDClosingDay);

        PaymentMethod.RESET();
        PaymentMethod.SETRANGE("MBC ICG Id", LXDClosingDay."Payment Method");
        PaymentMethod.FindFirst();

        CashingUp.RESET();
        CashingUp.SETRANGE("Shop Id.", LXDClosingDay."Shop Id.");
        CashingUp.SETRANGE("POS Id.", LXDClosingDay.POS);
        CashingUp.SETRANGE("Closing Up", LXDClosingDay.Z);
        CashingUp.SETRANGE("Payment Method", PaymentMethod.Code);
        IF NOT CashingUp.ISEMPTY THEN
            ERROR(Text50010Lbl);

        CashingUp.INIT();
        CashingUp.TRANSFERFIELDS(LXDClosingDay);
        CashingUp."Entry No." := 0;//GetLastEntryNo ;
        CashingUp."Posting Date" := LXDClosingDay."Posting Date";
        CashingUp.Closed := FALSE;
        CashingUp."Closing Up" := LXDClosingDay.Z;

        Salesperson.RESET();
        Salesperson.SETRANGE("MBC ICG Id", LXDClosingDay."ID Salesperson");
        IF NOT Salesperson.FINDSET() THEN
            Salesperson.INIT();

        CashingUp."Salesperson Code" := Salesperson.Code;
        CashingUp."Payment Method" := PaymentMethod.Code;
        CashingUp.INSERT();

        OnAfterCreateCashingUp(LXDClosingDay, CashingUp);
    end;

    procedure CreateCashingUpEntry(var treasury: Record "MBC ICG Treasury")
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
        GLSetup: Record "General Ledger Setup";
        PaymentMethod: Record "Payment Method";
        Salesperson: Record "Salesperson/Purchaser";
    begin

        OnBeforeCreateCashingUpEntry(treasury);

        PaymentMethod.Reset();
        PaymentMethod.SETRANGE("MBC ICG Id", treasury."Payment Method");
        PaymentMethod.FindFirst();

        CashingUpEntry.RESET();
        CashingUpEntry.SETRANGE("Shop Id.", treasury."Shop Id.");
        CashingUpEntry.SETRANGE("POS Id.", treasury.POS);
        CashingUpEntry.SETRANGE("Closing Up", treasury.Z);
        CashingUpEntry.SETRANGE("Payment Method Code", PaymentMethod.Code);
        CashingUpEntry.SETRANGE("Document Type", treasury."Type Document");
        CashingUpEntry.SETRANGE("Document No.", treasury."Document No.");
        CashingUpEntry.SETRANGE("Line No.", treasury.Line);
        IF NOT CashingUpEntry.ISEMPTY THEN
            ERROR(Text50010Lbl);

        GLSetup.RESET();
        GLSetup.FINDFIRST();
        GLSetup.TESTFIELD("Amount Rounding Precision");

        Salesperson.Reset();
        Salesperson.SETRANGE("MBC ICG Id", treasury.Salesperson);
        Salesperson.FindFirst();

        treasury.Amount := ROUND(treasury.Amount, GLSetup."Amount Rounding Precision");

        CashingUpEntry.Init();
        CashingUpEntry."Entry No." := GetLastEntryNo();
        CashingUpEntry."Posting Date" := treasury."Posted Date";
        CashingUpEntry."Shop Id." := treasury."Shop Id.";
        CashingUpEntry."POS Id." := treasury.POS;
        CashingUpEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);
        CashingUpEntry.Amount := treasury.Amount;
        CashingUpEntry.Description := treasury.Observation;
        CashingUpEntry."Document Type" := treasury."Type Document";
        CashingUpEntry."Document No." := treasury."Document No.";
        CashingUpEntry.Posted := FALSE;
        CashingUpEntry."Cash Concept" := treasury.Concept;
        CashingUpEntry."Closing Up" := treasury.Z;
        CashingUpEntry."Salesperson Code" := Salesperson.Code;
        CashingUpEntry."Line No." := treasury.Line;
        CashingUpEntry.INSERT();

        OnAfterCashingUpEntry(treasury, CashingUpEntry);
    end;

    procedure CreatePrePayment(var PrePayment: Record "MBC ICG Advance Payments")
    var
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        MBCICGPOS: Record "MBC ICG POS";
        PostGenJnlLine: Codeunit "Gen. Jnl.-Post Line";
    begin

        OnBeforeCreatePrePayment(PrePayment);

        IF PrePayment.Amount = 0 THEN
            exit;

        PaymentMethod.Reset();
        PaymentMethod.SetRange("MBC ICG Id", PrePayment."Payment Method");
        PaymentMethod.FindFirst();

        PaymentMethod.TestField("Bal. Account No.");

        MBCICGPOS.GET(PrePayment."Shop Id.", PrePayment.POS);
        MBCICGPOS.TestField("Prepayment Account No.");

        GenJnlLine.Init();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := MBCICGPOS."Prepayment Account No.";
        GenJnlLine."Journal Batch Name" := copystr(Prepayment.POS + '-' + format(PrePayment.Z), 1, 10);
        GenJnlLine."Posting Date" := PrePayment."Posted Date";

        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := PrePayment."Document No.";
        GenJnlLine.Description := format(PrePayment."ICG Type") + ' ' + format(PrePayment."Customer No.");

        CASE PaymentMethod."Bal. Account Type" OF
            PaymentMethod."Bal. Account Type"::"G/L Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            PaymentMethod."Bal. Account Type"::"Bank Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        END;
        GenJnlLine."Bal. Account No." := PaymentMethod."Bal. Account No.";

        GenJnlLine.validate(Amount, -PrePayment.Amount);

        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."Applied Automatically" := TRUE;

        GenJnlLine."Dimension Set ID" := GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No.");
        CLEAR(DimMgt);
        DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");

        OnAfterCreatePrePayment_BeforePosting(PrePayment, GenJnlLine);

        CLEAR(PostGenJnlLine);
        PostGenJnlLine.RunWithCheck(GenJnlLine);

    end;

    procedure PostCashingUp(CashingUp3: Record "MBC ICG Cashing Up")
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
    begin

        OnBeforePostCashingUp(CashingUp3);

        CashingUpEntry.Reset();
        CashingUpEntry.SETCURRENTKEY("Shop Id.", "POS Id.", "Closing Up", "Document Type");
        CashingUpEntry.SETRANGE("Shop Id.", CashingUp3."Shop Id.");
        CashingUpEntry.SETRANGE("POS Id.", CashingUp3."POS Id.");
        CashingUpEntry.SETRANGE("Closing Up", CashingUp3."Closing Up");
        CashingUpEntry.SETRANGE(Posted, FALSE);
        if CashingUpEntry.IsEmpty then
            Error(Text50011Lbl);

        IF NOT HideDialog THEN
            IF NOT CONFIRM(Text50008Lbl, FALSE, CashingUp3."Closing Up", CashingUp3."POS Id.", CashingUp3."Shop Id.") THEN
                ERROR('');

        if not Confirm('1-Validate Open Tickets') then
            exit;
        ValidateOpenTickets(CashingUp3);

        if not Confirm('1-PostExpensesFromCashingUp') then
            exit;
        PostExpensesFromCashingUp(CashingUp3);

        if not Confirm('1-PostSimplifiedInvoiceAndCrMemos') then
            exit;
        PostSimplifiedInvoiceAndCrMemos(CashingUp3);

        if not Confirm('1-SetProcessedCashingUp') then
            exit;
        SetProcessedCashingUp(CashingUp3);

    end;

    local procedure ApplyCustLedgEntry(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        MBCICGPOS: Record "MBC ICG POS";
        PostGenJnlLine: Codeunit "Gen. Jnl.-Post Line";
        DocumentType: Enum "MBC ICG POS Document Type";
    begin
        OnBeforeApplyCustLedgEntry(CashingUpEntry2);

        IF CashingUpEntry2.Amount = 0 THEN
            EXIT;

        MBCICGPOS.Get(CashingUpEntry2."Shop Id.", CashingUpEntry2."POS Id.");

        GenJnlLine.INIT();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := getCashingUpCustNo(CashingUpEntry2, DocumentType);
        GenJnlLine."Posting Date" := CashingUpEntry2."Posting Date";
        GenJnlLine."Journal Batch Name" := Copystr(CashingUpEntry2."POS Id." + '-' + Format(CashingUpEntry2."Closing Up"), 1, 10);
        IF DocumentType = DocumentType::Invoice THEN BEGIN
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

            GenJnlLine."Document No." := Copystr(Text50000Lbl + CashingUpEntry2."Document No.", 1, 20);
            GenJnlLine.Description := STRSUBSTNO(Text50001Lbl, CashingUpEntry2."Document No.");
        END ELSE BEGIN
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;

            GenJnlLine."Document No." := Copystr(Text50005Lbl + CashingUpEntry2."Document No.", 1, 20);
            GenJnlLine.Description := STRSUBSTNO(Text50006Lbl, CashingUpEntry2."Document No.");
        END;

        GenJnlLine."Payment Method Code" := CashingUpEntry2."Payment Method Code";

        CASE CashingUpEntry2."Bal. Account Type" OF
            CashingUpEntry2."Bal. Account Type"::"G/L Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            CashingUpEntry2."Bal. Account Type"::"Bank Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        END;

        GenJnlLine."Bal. Account No." := CashingUpEntry2."Bal. Account No.";


        IF DocumentType = DocumentType::Invoice THEN BEGIN
            GenJnlLine.Amount := -CashingUpEntry2.Amount;
            GenJnlLine."Credit Amount" := CashingUpEntry2.Amount;

            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;

            /*
            CustLedgEntry.RESET();
            CustLedgEntry.SETCURRENTKEY("Customer No.", "Document No.", Open);
            CustLedgEntry.SETRANGE("Customer No.", GenJnlLine."Account No.");
            CustLedgEntry.SETRANGE("Document No.", CashingUpEntry2."Document No.");
            CustLedgEntry.SETRANGE(Open, TRUE);
            IF CustLedgEntry.FINDFIRST() THEN
                IF CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Bill THEN BEGIN
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Bill;
                    GenJnlLine."Applies-to Bill No." := CustLedgEntry."Bill No.";
                END;
            */
        END
        ELSE BEGIN
            GenJnlLine.Amount := CashingUpEntry2.Amount;
            GenJnlLine."Debit Amount" := CashingUpEntry2.Amount;

            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
        END;

        GenJnlLine."Applies-to Doc. No." := CashingUpEntry2."Document No.";
        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."Applied Automatically" := TRUE;
        GenJnlLine."Dimension Set ID" := GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No.");
        CLEAR(DimMgt);
        DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");

        OnAfterApplyCustLedgEntry_BeforePostingMod(CashingUpEntry2, GenJnlLine);

        CLEAR(PostGenJnlLine);
        PostGenJnlLine.RunWithCheck(GenJnlLine);
    end;

    local procedure PostSimplifiedInvoiceAndCrMemos(var CashinUp2: Record "MBC ICG Cashing Up")
    var
        ConnectSetup: Record "MBC ICG Connector Config";
        tempSalesHeader: Record "Sales Header" temporary;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        TempItem: Record Item Temporary;
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
        CashingUpEntry2: Record "MBC ICG Cashing Up Entry";
        TempCashingUpEntry: Record "MBC ICG Cashing Up Entry" temporary;
        MBCICGPOS: Record "MBC ICG POS";
        salesLineCheck: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        InvoiceNo, CreditMemoNo : Code[20];
        AmountPaymets, AmountCreditMemo, AmountInvoice, TotalAmountDocs, TotalAmountICG : Decimal;
    begin
        ConnectSetup.get();
        MBCICGPOS.get(CashinUp2."Shop Id.", CashinUp2."POS Id.");

        TotalAmountDocs := 0;

        AmountInvoice := 0;
        CreateInvoice(CashinUp2, tempSalesHeader, TempItem, AmountInvoice);
        InvoiceNo := tempSalesHeader."Posting No.";

        AmountCreditMemo := 0;
        CreateCRMemo(CashinUp2, tempSalesHeader, TempItem, AmountCreditMemo);
        CreditMemoNo := tempSalesHeader."Posting No.";

        TotalAmountDocs := AmountInvoice - AmountCreditMemo;
        TotalAmountICG := getTotalAmountICG(CashinUp2);

        AmountPaymets := 0;
        GroupCashinUpEntry(CashinUp2, TempCashingUpEntry, AmountPaymets);

        OnAfterGroupCashinUpEntry(CashinUp2, TempCashingUpEntry, AmountPaymets);

        IF ConnectSetup."Check Invoice Tolerance" THEN begin
            if ordersWerePosted(salesLineCheck, InvoiceNo, CreditMemoNo) then
                Error(Text50013Lbl, salesLineCheck.FieldCaption("Document Type"), salesLineCheck."Document Type", salesLineCheck.FieldCaption("Document No."), salesLineCheck."Document No.");
            if Abs(TotalAmountDocs - AmountPaymets) > ConnectSetup."Max. Simplifed Inv. Tole. Amt." THEN
                Error(Text50007Lbl, CashinUp2."Shop Id.", CashinUp2."POS Id.", CashinUp2."Closing Up", (TotalAmountDocs - AmountPaymets));
            if Abs(
                TotalAmountDocs
                + (getAmountInvoicesAndCrMemo(CashinUp2."Shop Id.", CashinUp2."POS Id.", CashinUp2."Closing Up")
                - TotalAmountICG)
                ) > ConnectSetup."Max. Simplifed Inv. Tole. Amt." then
                Error(Text50012Lbl, CashinUp2."Shop Id.", CashinUp2."POS Id.", CashinUp2."Closing Up", (TotalAmountDocs - TotalAmountICG));
        end;


        IF (ConnectSetup."Post Invoice Tolerance") and (TotalAmountDocs - AmountPaymets <> 0) THEN
            AddToleranceLine(AmountPaymets, TotalAmountDocs, tempSalesHeader);
        if not confirm('2- posting sales') then
            exit;
        if tempSalesHeader.FindSet() then
            repeat
                CLEAR(SalesPost);
                SalesHeader.Get(tempSalesHeader."Document Type", tempSalesHeader."No.");
                SalesPost.RUN(SalesHeader);
                updatePostProgress(SalesHeader);
            until tempSalesHeader.Next() = 0;

        if not confirm('2-posging payments') then
            exit;
        //display info
        if TempCashingUpEntry.FindSet() then
            repeat
                Message(Format(TempCashingUpEntry));
            until TempCashingUpEntry.next() = 0;

        IF ConnectSetup."Post ICG Payments" THEN
            ApplyPaymentCashingUp(CashinUp2, TempCashingUpEntry, MBCICGPOS, InvoiceNo, CreditMemoNo);

        TempItem.Reset();
        IF TempItem.FindSet() THEN
            REPEAT
                Item.Reset();
                IF Item.GET(TempItem."No.") THEN BEGIN
                    Item.Blocked := TRUE;
                    Item.Modify();
                END;
            UNTIL TempItem.Next() = 0;


        CashingUpEntry.Reset();
        CashingUpEntry.SETCURRENTKEY("Shop Id.", "POS Id.", "Closing Up", "Document Type");
        CashingUpEntry.SETRANGE("Shop Id.", CashinUp2."Shop Id.");
        CashingUpEntry.SETRANGE("POS Id.", CashinUp2."POS Id.");
        CashingUpEntry.SETRANGE("Closing Up", CashinUp2."Closing Up");
        CashingUpEntry.SETRANGE(Posted, FALSE);
        CashingUpEntry.SetFilter("Document Type", '%1|%2', CashingUpEntry."Document Type"::"Simplified Invoice", CashingUpEntry."Document Type"::"Simplified Credit Memo");
        IF CashingUpEntry.FindSet() THEN
            REPEAT
                CashingUpEntry2 := CashingUpEntry;
                CashingUpEntry2.Posted := TRUE;
                CashingUpEntry2."Closed User ID" := copystr(UserId(), 1, 50);
                CashingUpEntry2.Modify();
            UNTIL CashingUpEntry.Next() = 0;

        OnAfterPostSimplifiedInvoiceAndCrMemos(CashingUpEntry);
    end;

    local procedure PostCashConcept(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry")
    var
        MBCICGPOS: Record "MBC ICG POS";
        CashConcept: Record "MBC ICG Cash Concept";
        GenJnlLine: Record "Gen. Journal Line";
        PostGenJnlLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        OnBeforePostCashConcept(CashingUpEntry2);

        IF CashingUpEntry2.Amount = 0 THEN
            exit;

        MBCICGPOS.get(CashingUpEntry2."Shop Id.", CashingUpEntry2."POS Id.");

        CashConcept.Reset();
        CashConcept.GET(CashingUpEntry2."Cash Concept");

        CashConcept.TESTFIELD("G/L Account No.");

        GenJnlLine.Init();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := CashConcept."G/L Account No.";
        GenJnlLine."Journal Batch Name" := copystr(CashingUpEntry2."POS Id." + '-' + Format(CashingUpEntry2."Closing Up"), 1, 10);
        GenJnlLine."Posting Date" := CashingUpEntry2."Posting Date";

        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := CashingUpEntry2."Document No.";
        GenJnlLine.Description := CashingUpEntry2.Description;

        CASE CashingUpEntry2."Bal. Account Type" OF
            CashingUpEntry2."Bal. Account Type"::"G/L Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            CashingUpEntry2."Bal. Account Type"::"Bank Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        END;

        GenJnlLine."Bal. Account No." := CashingUpEntry2."Bal. Account No.";

        IF CashingUpEntry2.Amount > 0 THEN BEGIN
            GenJnlLine.Amount := -CashingUpEntry2.Amount;
            GenJnlLine."Credit Amount" := CashingUpEntry2.Amount;
        END
        ELSE BEGIN
            GenJnlLine.Amount := -CashingUpEntry2.Amount;
            GenJnlLine."Debit Amount" := CashingUpEntry2.Amount;
        END;

        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."Applied Automatically" := TRUE;
        GenJnlLine."Dimension Set ID" := GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No.");

        OnAfterPostCashConcept_BeforePosting(CashingUpEntry2, GenJnlLine);

        CLEAR(DimMgt);
        DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        CLEAR(PostGenJnlLine);
        PostGenJnlLine.RunWithCheck(GenJnlLine);

    end;

    local procedure GetLastEntryNo(): Integer
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
    begin
        CashingUpEntry.Reset();
        IF NOT CashingUpEntry.FindLast() THEN
            CashingUpEntry.Init();

        EXIT(CashingUpEntry."Entry No." + 1);
    end;

    procedure SetHideDialog()
    begin
        HideDialog := TRUE;
    end;

    local procedure ValidateOpenTickets(VAR CashingUp: Record "MBC ICG Cashing Up")
    var
        MBCICGSales: Record "MBC ICG Sales";
        SalesHeader: Record "Sales Header";
        cierreInt: Integer;
        Text001Lbl: Label 'There are outstanding tickets to be processed.', Comment = 'ESP="Existen tickets pendientes de procesar."';
        Text002Lbl: Label 'There are outstanding sales to be posted.', Comment = 'ESP="Existen ventas pendientes de registrar."';
        Text003Lbl: Label 'There are outstanding sales to be invoiced.', Comment = 'ESP="Existen ventas pendientes de facturar."';
    begin
        cierreInt := CashingUp."Closing Up";

        MBCICGSales.RESET();
        MBCICGSales.SETRANGE("Shop Id.", CashingUp."Shop Id.");
        MBCICGSales.SETRANGE(POS, CashingUp."POS Id.");
        MBCICGSales.SETRANGE("Posted Date", CashingUp."Posting Date");
        MBCICGSales.SETRANGE(Z, cierreInt);
        MBCICGSales.SETRANGE("Status NAV", MBCICGSales."Status NAV"::Pending);
        IF NOT MBCICGSales.ISEMPTY() THEN
            ERROR(Text001Lbl);

        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("MBC ICG Closing Up", "MBC ICG Shop Id.", "MBC ICG POS Id.");
        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("MBC ICG Closing Up", CashingUp."Closing Up");
        SalesHeader.SetRange("MBC ICG Shop Id.", CashingUp."Shop Id.");
        SalesHeader.SetRange("MBC ICG POS Id.", CashingUp."POS Id.");
        SalesHeader.SetRange("MBC ICG Outstanding Items", true);
        SalesHeader.SetRange("Posting Date", CashingUp."Posting Date");
        if not SalesHeader.IsEmpty then
            ERROR(Text002Lbl);

        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("MBC ICG Closing Up", "MBC ICG Shop Id.", "MBC ICG POS Id.");
        SalesHeader.Setrange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("MBC ICG Closing Up", CashingUp."Closing Up");
        SalesHeader.SetRange("MBC ICG Shop Id.", CashingUp."Shop Id.");
        SalesHeader.SetRange("MBC ICG POS Id.", CashingUp."POS Id.");
        SalesHeader.SetRange("MBC ICG POS Document Type", SalesHeader."MBC ICG POS Document Type"::Invoice);
        SalesHeader.SetRange("Posting Date", CashingUp."Posting Date");
        SalesHeader.SetRange("Shipped Not Invoiced", true);
        if not SalesHeader.IsEmpty then
            ERROR(Text003Lbl);

    end;

    local procedure SalesInvoiceIsOpen(DocumentNo: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        /*If InvoiceNo = '' means there are only Cr. Memos*/
        if DocumentNo = '' then
            exit(false);

        SalesInvoiceHeader.Get(DocumentNo);
        SalesInvoiceHeader.CalcFields("Remaining Amount");
        if SalesInvoiceHeader."Remaining Amount" > 0 then
            exit(true)
        else
            exit(false);
    end;

    local procedure SalesCreditMemoIsOpen(DocumentNo: Code[20]): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if DocumentNo = '' then
            exit(false);
        SalesCrMemoHeader.Get(DocumentNo);
        SalesCrMemoHeader.CalcFields("Remaining Amount");
        if SalesCrMemoHeader."Remaining Amount" < 0 then
            exit(true)
        else
            exit(false);
    end;

    local procedure PostExpensesFromCashingUp(var CashingUp3: Record "MBC ICG Cashing Up")
    var
        ConnectSetup: Record "MBC ICG Connector Config";
        CashingUpEntry2: Record "MBC ICG Cashing Up Entry";
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
    begin
        OnBeforePostExpensesFromCashingUp(CashingUp3);

        CashingUpEntry.Reset();
        CashingUpEntry.SETCURRENTKEY("Shop Id.", "POS Id.", "Closing Up", "Document Type");
        CashingUpEntry.SETRANGE("Shop Id.", CashingUp3."Shop Id.");
        CashingUpEntry.SETRANGE("POS Id.", CashingUp3."POS Id.");
        CashingUpEntry.SETRANGE("Closing Up", CashingUp3."Closing Up");
        CashingUpEntry.SETRANGE(Posted, FALSE);
        CashingUpEntry.SETFILTER("Document Type", '<>%1&<>%2', CashingUpEntry."Document Type"::"Simplified Invoice", CashingUpEntry."Document Type"::"Simplified Credit Memo");
        if CashingUpEntry.IsEmpty then
            exit;

        ConnectSetup.Get();

        CashingUpEntry.FINDSET(TRUE);
        REPEAT
            IF ConnectSetup."Post ICG Payments" THEN BEGIN
                IF CashingUpEntry."Document Type" IN [CashingUpEntry."Document Type"::Invoice, CashingUpEntry."Document Type"::"Credit Memo"] THEN
                    ApplyCustLedgEntry(CashingUpEntry);

                IF CashingUpEntry."Cash Concept" <> 0 THEN
                    PostCashConcept(CashingUpEntry);
            END;

            CashingUpEntry2 := CashingUpEntry;
            CashingUpEntry2.Posted := TRUE;
            CashingUpEntry2."Closed User ID" := copystr(UserId(), 1, 50);
            CashingUpEntry2.MODIFY();

        UNTIL CashingUpEntry.Next() = 0;

        OnAfterPostExpensesFromCashingUp(CashingUp3, CashingUpEntry)
    end;

    local procedure SetProcessedCashingUp(var CashingUp: Record "MBC ICG Cashing Up")
    var
        CashingUp2: Record "MBC ICG Cashing Up";
    begin
        OnBeforeSetProcessedCashingUp(CashingUp);

        CashingUp2.Reset();
        CashingUp2.SETRANGE("Shop Id.", CashingUp."Shop Id.");
        CashingUp2.SETRANGE("POS Id.", CashingUp."POS Id.");
        CashingUp2.SETRANGE("Closing Up", CashingUp."Closing Up");
        CashingUp2.SETRANGE(Closed, FALSE);
        CashingUp2.FindSet();
        repeat
            CashingUp2."Closed Date" := TODAY;
            CashingUp2."Closed Time" := TIME;
            CashingUp2."Closed User ID" := copystr(UserId(), 1, 50);
            CashingUp2.Closed := TRUE;
            CashingUp2.Modify();
        until CashingUp2.Next() = 0;

        OnAfterSetProcessedCashingUp(CashingUp, CashingUp2);
    end;

    local procedure CreateCRMemo(CashinUp2: Record "MBC ICG Cashing Up"; var tempSalesHeader: Record "Sales Header" temporary;
    var TempItem: Record Item temporary; var TotalAmountSalesLineReturn: Decimal)
    var
        SalesHeader: Record "Sales Header";
        MBCICGPOS: Record "MBC ICG POS";
        ReturnReceiptLine: Record "Return Receipt Line";
        ReturnReceiptLine2: Record "Return Receipt Line";
        TotalSalesLine, SalesLineReturn : Record "Sales Line";
        Item: Record Item;
        DocumentTotals: Codeunit "Document Totals";
        VATAmount: Decimal;
    begin
        OnBeforeCreateCRMemo(CashinUp2);

        MBCICGPOS.Get(CashinUp2."Shop Id.", CashinUp2."POS Id.");

        ReturnReceiptLine.SETCURRENTKEY("MBC ICG Shop Id.", "MBC ICG POS Id.", "MBC ICG POS Document Type New", "Bill-to Customer No.", "Document No.", "MBC ICG Closing Up New", "Return Qty. Rcd. Not Invd.");
        ReturnReceiptLine.SETRANGE("MBC ICG Shop Id.", CashinUp2."Shop Id.");
        ReturnReceiptLine.SETRANGE("MBC ICG POS Id.", CashinUp2."POS Id.");
        ReturnReceiptLine.SETRANGE("MBC ICG POS Document Type New", ReturnReceiptLine."MBC ICG POS Document Type New"::"Simplified Credit Memo");
        ReturnReceiptLine.SETRANGE("Bill-to Customer No.", MBCICGPOS."Cust. Cash No.");
        ReturnReceiptLine.SETRANGE("MBC ICG Closing Up New", CashinUp2."Closing Up");
        ReturnReceiptLine.SETFILTER("Return Qty. Rcd. Not Invd.", '<>%1', 0);
        if ReturnReceiptLine.IsEmpty then
            exit;

        ReturnReceiptLine.FindSet();

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.INSERT(TRUE);

        SalesHeader.SetHideValidationDialog(TRUE);
        SalesHeader.VALIDATE("Sell-to Customer No.", MBCICGPOS."Cust. Cash No.");

        SalesHeader."Bal. Account No." := '';
        SalesHeader."Applies-to ID" := SalesHeader."No.";
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        SalesHeader.VALIDATE("Prices Including VAT", TRUE);
        SalesHeader.VALIDATE("Document Date", CashinUp2."Posting Date");
        SalesHeader.VALIDATE("Posting Date", CashinUp2."Posting Date");
        SalesHeader."Posting No." := copystr(CashinUp2."Shop Id." + '-' + CashinUp2."POS Id." + '-' + Format(CashinUp2."Closing Up"), 1, 20);
        SalesHeader."Posting No. Series" := '';
        //SalesHeader."Corrected Invoice No." := SalesHeader."Posting No.";
        SalesHeader."MBC ICG Closing Up" := CashinUp2."Closing Up";
        SalesHeader."MBC ICG POS Id." := CashinUp2."POS Id.";
        SalesHeader."MBC ICG Shop Id." := CashinUp2."Shop Id.";
        //SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::"R5 Corrected Invoice in Simplified Invoices";
        //SalesHeader."Special Scheme Code" := SalesHeader."Special Scheme Code"::"01 General";
        SalesHeader.validate("Dimension Set ID", GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No."));

        if MBCICGPOS."Responsibility Center" <> '' then
            SalesHeader.Validate("Responsibility Center", MBCICGPOS."Responsibility Center");

        OnAfterCreateCRMemo_CreateDocument(CashinUp2, SalesHeader);

        SalesHeader.MODIFY(TRUE);

        tempSalesHeader.Init();
        tempSalesHeader := SalesHeader;
        tempSalesHeader.Insert();

        REPEAT
            SalesLineReturn.Reset();
            SalesLineReturn.SETRANGE("Document Type", SalesHeader."Document Type");
            SalesLineReturn.SETRANGE("Document No.", SalesHeader."No.");
            SalesLineReturn."Document Type" := SalesHeader."Document Type";
            SalesLineReturn."Document No." := SalesHeader."No.";

            IF (ReturnReceiptLine.Type = ReturnReceiptLine.Type::Item) AND (ReturnReceiptLine."No." <> '') THEN BEGIN
                Item.Reset();
                IF Item.GET(ReturnReceiptLine."No.") THEN
                    IF Item.Blocked THEN BEGIN
                        Item.Blocked := FALSE;
                        Item.Modify();

                        TempItem.Init();
                        TempItem.TRANSFERFIELDS(Item);
                        TempItem.Insert();
                    END;
            END;

            ReturnReceiptLine2 := ReturnReceiptLine;
            ReturnReceiptLine2.InsertInvLineFromRetRcptLine(SalesLineReturn);

            IF SalesLineReturn."Dimension Set ID" = 0 THEN BEGIN
                SalesLineReturn."Dimension Set ID" := ReturnReceiptLine."Dimension Set ID";
                SalesLineReturn.VALIDATE("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
                SalesLineReturn.VALIDATE("Shortcut Dimension 2 Code", SalesHeader."Shortcut Dimension 2 Code");
                SalesLineReturn.Modify();
            END;

        UNTIL ReturnReceiptLine.Next() = 0;

        clear(DocumentTotals);
        DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(SalesLineReturn, VATAmount, TotalSalesLine);
        TotalAmountSalesLineReturn := TotalSalesLine."Amount Including VAT";

        OnAfterCreateCRMemo(CashinUp2, SalesHeader, SalesLineReturn);
    end;

    local procedure CreateInvoice(CashinUp2: Record "MBC ICG Cashing Up"; var tempSalesHeader: Record "Sales Header" temporary;
    var TempItem: Record Item temporary; var TotalAmountSalesLine: Decimal)
    var
        SalesHeader: Record "Sales Header";
        MBCICGPOS: Record "MBC ICG POS";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        TotalSalesLine, SalesLineReturn : Record "Sales Line";
        Item: Record Item;
        DocumentTotals: Codeunit "Document Totals";
        VATAmount: Decimal;
    begin
        OnBeforeCreateInvoice(CashinUp2);

        MBCICGPOS.Get(CashinUp2."Shop Id.", CashinUp2."POS Id.");

        SalesShipmentLine.SETCURRENTKEY("MBC ICG Shop Id.", "MBC ICG POS Id.", "MBC ICG POS Document Type New", "Bill-to Customer No.", "Document No.", "MBC ICG Closing Up New", "Qty. Shipped Not Invoiced");
        SalesShipmentLine.SETRANGE("MBC ICG Shop Id.", CashinUp2."Shop Id.");
        SalesShipmentLine.SETRANGE("MBC ICG POS Id.", CashinUp2."POS Id.");
        SalesShipmentLine.SETRANGE("MBC ICG POS Document Type New", SalesShipmentLine."MBC ICG POS Document Type New"::"Simplified Invoice");
        SalesShipmentLine.SETRANGE("Bill-to Customer No.", MBCICGPOS."Cust. Cash No.");
        SalesShipmentLine.SETRANGE("MBC ICG Closing Up New", CashinUp2."Closing Up");
        SalesShipmentLine.SETFILTER("Qty. Shipped Not Invoiced", '<>%1', 0);
        if SalesShipmentLine.IsEmpty then
            exit;

        SalesShipmentLine.FindSet();

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.INSERT(TRUE);

        SalesHeader.SetHideValidationDialog(TRUE);
        SalesHeader.VALIDATE("Sell-to Customer No.", MBCICGPOS."Cust. Cash No.");

        SalesHeader."Bal. Account No." := '';
        SalesHeader."Applies-to ID" := SalesHeader."No.";
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        SalesHeader.VALIDATE("Prices Including VAT", TRUE);
        SalesHeader.VALIDATE("Document Date", CashinUp2."Posting Date");
        SalesHeader.VALIDATE("Posting Date", CashinUp2."Posting Date");
        SalesHeader."Posting No." := copystr(CashinUp2."Shop Id." + '-' + CashinUp2."POS Id." + '-' + Format(CashinUp2."Closing Up"), 1, 20);
        SalesHeader."Posting No. Series" := '';
        SalesHeader."MBC ICG Closing Up" := CashinUp2."Closing Up";
        SalesHeader."MBC ICG POS Id." := CashinUp2."POS Id.";
        SalesHeader."MBC ICG Shop Id." := CashinUp2."Shop Id.";
        //SalesHeader."Invoice Type" := SalesHeader."Invoice Type"::"F4 Invoice summary entry";
        //SalesHeader."Special Scheme Code" := SalesHeader."Special Scheme Code"::"01 General";
        SalesHeader.validate("Dimension Set ID", GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No."));

        if MBCICGPOS."Responsibility Center" <> '' then
            SalesHeader.Validate("Responsibility Center", MBCICGPOS."Responsibility Center");

        OnAfterCreateInvoice_CreateDocument(CashinUp2, SalesHeader);

        SalesHeader.MODIFY(TRUE);

        tempSalesHeader.Init();
        tempSalesHeader := SalesHeader;
        tempSalesHeader.Insert();

        REPEAT
            SalesLineReturn.Reset();
            SalesLineReturn.SETRANGE("Document Type", SalesHeader."Document Type");
            SalesLineReturn.SETRANGE("Document No.", SalesHeader."No.");
            SalesLineReturn."Document Type" := SalesHeader."Document Type";
            SalesLineReturn."Document No." := SalesHeader."No.";

            IF (SalesShipmentLine.Type = SalesShipmentLine.Type::Item) AND (SalesShipmentLine."No." <> '') THEN BEGIN
                Item.Reset();
                IF Item.GET(SalesShipmentLine."No.") THEN
                    IF Item.Blocked THEN BEGIN
                        Item.Blocked := FALSE;
                        Item.Modify();

                        TempItem.Init();
                        TempItem.TRANSFERFIELDS(Item);
                        TempItem.Insert();
                    END;
            END;

            SalesShipmentLine2 := SalesShipmentLine;
            SalesShipmentLine2.InsertInvLineFromShptLine(SalesLineReturn);

            IF SalesLineReturn."Dimension Set ID" = 0 THEN BEGIN
                SalesLineReturn."Dimension Set ID" := SalesShipmentLine."Dimension Set ID";
                SalesLineReturn.VALIDATE("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
                SalesLineReturn.VALIDATE("Shortcut Dimension 2 Code", SalesHeader."Shortcut Dimension 2 Code");
                SalesLineReturn.Modify();
            END;

        UNTIL SalesShipmentLine.Next() = 0;

        clear(DocumentTotals);
        DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(SalesLineReturn, VATAmount, TotalSalesLine);
        TotalAmountSalesLine := TotalSalesLine."Amount Including VAT";

        OnAfterCreateInvoice(CashinUp2, SalesHeader, SalesLineReturn);
    end;

    procedure GroupCashinUpEntry(var CashinUp2: Record "MBC ICG Cashing Up"; var TempCashingUpEntry: Record "MBC ICG Cashing Up Entry" temporary; var TotalAmount: Decimal)
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
        EntryNo: Integer;
    begin
        EntryNo := 1;
        TotalAmount := 0;

        CashingUpEntry.Reset();
        CashingUpEntry.SETCURRENTKEY("Shop Id.", "POS Id.", "Document Type", "Document No.", "Closing Up", Posted);
        CashingUpEntry.SETRANGE("Shop Id.", CashinUp2."Shop Id.");
        CashingUpEntry.SetFilter("Document Type", '%1|%2', CashingUpEntry."Document Type"::"Simplified Invoice", CashingUpEntry."Document Type"::"Simplified Credit Memo");
        CashingUpEntry.SETRANGE("POS Id.", CashinUp2."POS Id.");
        CashingUpEntry.SETRANGE("Closing Up", CashinUp2."Closing Up");
        CashingUpEntry.SETRANGE(Posted, FALSE);
        IF CashingUpEntry.FindSet() THEN
            REPEAT

                TempCashingUpEntry.Reset();
                TempCashingUpEntry.SETRANGE("Payment Method Code", CashingUpEntry."Payment Method Code");
                TempCashingUpEntry.SETRANGE("Bal. Account Type", CashingUpEntry."Bal. Account Type");
                TempCashingUpEntry.SETRANGE("Bal. Account No.", CashingUpEntry."Bal. Account No.");
                IF NOT TempCashingUpEntry.FindFirst() THEN BEGIN
                    TempCashingUpEntry.Init();
                    TempCashingUpEntry."Entry No." := EntryNo;
                    TempCashingUpEntry."Payment Method Code" := CashingUpEntry."Payment Method Code";
                    TempCashingUpEntry."Bal. Account Type" := CashingUpEntry."Bal. Account Type";
                    TempCashingUpEntry."Bal. Account No." := CashingUpEntry."Bal. Account No.";
                    TempCashingUpEntry."POS Id." := CashingUpEntry."POS Id.";
                    TempCashingUpEntry."Shop Id." := CashingUpEntry."Shop Id.";
                    TempCashingUpEntry.Insert();

                    EntryNo += 1;
                END;

                TempCashingUpEntry.Amount += CashingUpEntry.Amount;
                TempCashingUpEntry.Modify();

                TotalAmount += CashingUpEntry.Amount;
            UNTIL CashingUpEntry.Next() = 0;
    end;

    local procedure AddToleranceLine(AmountPaymets: Decimal; TotalAmountDocs: Decimal; var SalesHeader: Record "Sales Header")
    var
        SalesLineOrder: Record "Sales Line";
        Customer: Record Customer;
        CustPostGroup: Record "Customer Posting Group";
        LineNo: Integer;
    begin
        SalesHeader.FindFirst();

        OnBeforeAddToleranceLine(AmountPaymets, TotalAmountDocs, SalesHeader);

        Customer.Reset();
        Customer.GET(SalesHeader."Sell-to Customer No.");

        Customer.TESTFIELD("Customer Posting Group");

        CustPostGroup.Reset();
        CustPostGroup.GET(Customer."Customer Posting Group");

        CustPostGroup.TESTFIELD("Invoice Rounding Account");

        SalesLineOrder.Reset();
        SalesLineOrder.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLineOrder.SETRANGE("Document No.", SalesHeader."No.");
        IF NOT SalesLineOrder.FindLast() THEN
            SalesLineOrder.Init();

        LineNo := SalesLineOrder."Line No." + 10000;

        SalesLineOrder.Init();
        SalesLineOrder.SuspendStatusCheck(true);
        SalesLineOrder."Document Type" := SalesHeader."Document Type";
        SalesLineOrder."Document No." := SalesHeader."No.";
        SalesLineOrder."Line No." := LineNo;
        SalesLineOrder.INSERT(TRUE);

        SalesLineOrder.Type := SalesLineOrder.Type::"G/L Account";
        SalesLineOrder.VALIDATE("No.", CustPostGroup."Invoice Rounding Account");
        SalesLineOrder.Description := COPYSTR(Text50002Lbl, 1, 50);

        SalesLineOrder.VALIDATE(Quantity, 1);
        SalesLineOrder.VALIDATE("Qty. to Ship", SalesLineOrder.Quantity);

        if AmountPaymets > 0 then
            SalesLineOrder.VALIDATE("Unit Price", AmountPaymets - TotalAmountDocs)
        else
            SalesLineOrder.VALIDATE("Unit Price", TotalAmountDocs - AmountPaymets);

        //SalesLineOrder."Shortcut Dimension 1 Code" := SalesShptLine."Shortcut Dimension 1 Code"; //AQUI
        //SalesLineOrder."Shortcut Dimension 2 Code" := SalesShptLine."Shortcut Dimension 2 Code";

        SalesLineOrder."Dimension Set ID" := GetDim.GetDimensionbyCustomer(SalesHeader."Sell-to Customer No.");//SalesShptLine."Dimension Set ID";
        CLEAR(DimMgt);
        DimMgt.UpdateGlobalDimFromDimSetID(SalesLineOrder."Dimension Set ID", SalesLineOrder."Shortcut Dimension 1 Code", SalesLineOrder."Shortcut Dimension 2 Code");
        SalesLineOrder.MODIFY(TRUE);

        OnAfterAddToleranceLine(AmountPaymets, TotalAmountDocs, SalesHeader, SalesLineOrder);
    end;

    local procedure updatePostProgress(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            salesInvoicePosted := true;
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
            creditMemoPosted := true;
    end;

    local procedure getTotalAmountICG(MBCICGCashingUp2: Record "MBC ICG Cashing Up") ICGSales: Decimal
    var
        MBCICGCashingUp: Record "MBC ICG Cashing Up";
    begin
        ICGSales := 0;

        MBCICGCashingUp.SetRange("Shop Id.", MBCICGCashingUp2."Shop Id.");
        MBCICGCashingUp.SetRange("POS Id.", MBCICGCashingUp2."POS Id.");
        MBCICGCashingUp.SetRange("Closing Up", MBCICGCashingUp2."Closing Up");
        if MBCICGCashingUp.FindSet() then
            repeat
                ICGSales := ICGSales + MBCICGCashingUp.Sales + MBCICGCashingUp."Credit Notes";
            until MBCICGCashingUp.Next() = 0;

        exit(ICGSales);
    end;

    local procedure ordersWerePosted(var salesLineCheck: Record "Sales Line"; InvoiceNo: Code[20]; CrMemoNo: Code[20]): Boolean
    begin
        salesLineCheck.SetRange("Document Type", salesLineCheck."Document Type"::Order);
        salesLineCheck.SetFilter("Document No.", '%1', InvoiceNo + '*');
        salesLineCheck.SetFilter("Qty. Invoiced (Base)", '<>0');
        if salesLineCheck.FindFirst() then
            exit(true);

        salesLineCheck.SetRange("Document Type", salesLineCheck."Document Type"::"Return Order");
        salesLineCheck.SetFilter("Document No.", '%1', CrMemoNo + '*');
        if salesLineCheck.FindFirst() then
            exit(true);

        exit(false);
    end;

    procedure getPostProgress(var postedInv: Boolean; var postedCrMemo: Boolean);
    begin
        postedInv := salesInvoicePosted;
        postedCrMemo := creditMemoPosted;
    end;

    local procedure getCashingUpCustNo(CashingUpEntry: Record "MBC ICG Cashing Up Entry"; var DocumentType: Enum "MBC ICG POS Document Type"): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        DocumentNotPostedLbl: Label 'Document %1 not posted!', Comment = 'ESP="Documento %1 no ha sido registrado!"';
    begin
        if SalesInvoiceHeader.Get(CashingUpEntry."Document No.") then begin
            DocumentType := DocumentType::Invoice;
            exit(SalesInvoiceHeader."Sell-to Customer No.");
        end;
        if SalesCreditMemoHeader.Get(CashingUpEntry."Document No.") then begin
            DocumentType := DocumentType::"Credit Memo";
            exit(SalesCreditMemoHeader."Sell-to Customer No.");
        end;
        Error(DocumentNotPostedLbl, CashingUpEntry."Document No.");
    end;

    local procedure getAmountInvoicesAndCrMemo(shopId: Code[20]; posId: Code[20]; closingUp: Integer) SalesAndCrAmount: Decimal
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
    begin
        SalesAndCrAmount := 0;

        CashingUpEntry.Reset();
        CashingUpEntry.SetRange("Shop Id.", shopId);
        CashingUpEntry.SetFilter("Document Type", '<>%1&<>%2', CashingUpEntry."Document Type"::"Simplified Invoice", CashingUpEntry."Document Type"::"Simplified Credit Memo");
        CashingUpEntry.SetRange("POS Id.", posId);
        CashingUpEntry.SetRange("Closing Up", closingUp);
        //CashingUpEntry.SetRange(Posted, true);
        if CashingUpEntry.FindSet() then
            repeat
                SalesAndCrAmount := SalesAndCrAmount + CashingUpEntry.Amount;
            until CashingUpEntry.Next() = 0;

        exit(SalesAndCrAmount)
    end;

    procedure ApplyPaymentCashingUp(var CashinUp2: Record "MBC ICG Cashing Up"; var TempCashingUpEntry: Record "MBC ICG Cashing Up Entry" temporary; var MBCICGPOS: Record "MBC ICG POS"; InvoiceNo: Code[20]; CreditMemoNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        CustApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        PostGenJnlLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TempCashingUpEntry.Reset();
        TempCashingUpEntry.SETCURRENTKEY(Amount);
        TempCashingUpEntry.SETFILTER(Amount, '<>%1', 0);
        TempCashingUpEntry.Ascending(false);
        IF TempCashingUpEntry.FindSet() THEN
            REPEAT
                GenJnlLine.Init();
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                GenJnlLine."Account No." := MBCICGPOS."Cust. Cash No.";

                GenJnlLine."Posting Date" := CashinUp2."Posting Date";

                IF TempCashingUpEntry.Amount > 0 THEN BEGIN
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                    GenJnlLine."Document No." := copystr(Text50000Lbl + InvoiceNo, 1, 20);
                    GenJnlLine.Description := STRSUBSTNO(Text50001Lbl, InvoiceNo);
                end else begin
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                    GenJnlLine."Document No." := copystr(Text50005Lbl + CreditMemoNo, 1, 20);
                    GenJnlLine.Description := STRSUBSTNO(Text50006Lbl, CreditMemoNo);
                END;

                GenJnlLine."Payment Method Code" := TempCashingUpEntry."Payment Method Code";

                CASE TempCashingUpEntry."Bal. Account Type" OF
                    TempCashingUpEntry."Bal. Account Type"::"G/L Account":
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                    TempCashingUpEntry."Bal. Account Type"::"Bank Account":
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
                END;

                GenJnlLine."Bal. Account No." := TempCashingUpEntry."Bal. Account No.";

                IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment THEN BEGIN
                    GenJnlLine.Amount := -TempCashingUpEntry.Amount;
                    GenJnlLine."Credit Amount" := TempCashingUpEntry.Amount;
                    if SalesInvoiceIsOpen(InvoiceNo) then begin
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                        GenJnlLine."Applies-to Doc. No." := InvoiceNo;
                    end;
                end else begin
                    GenJnlLine.Amount := -TempCashingUpEntry.Amount;
                    GenJnlLine."Debit Amount" := GenJnlLine.Amount;
                    if SalesCreditMemoIsOpen(CreditMemoNo) then begin
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                        GenJnlLine."Applies-to Doc. No." := CreditMemoNo;
                    end else begin
                        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
                        GenJnlLine."Applies-to Doc. No." := copystr(Text50000Lbl + InvoiceNo, 1, 20);
                    end;
                END;

                GenJnlLine."System-Created Entry" := TRUE;
                GenJnlLine."Applied Automatically" := TRUE;
                GenJnlLine."Dimension Set ID" := GetDim.GetDimensionbyCustomer(MBCICGPOS."Cust. Cash No.");
                CLEAR(DimMgt);
                DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
                GenJnlLine."MBC ICG From Cashing Up" := TRUE;

                OnAfterPostSimplifiedInvoiceAndCrMemos_BeforePostinPayment(TempCashingUpEntry, GenJnlLine);

                CLEAR(PostGenJnlLine);
                PostGenJnlLine.RunWithCheck(GenJnlLine);

            UNTIL TempCashingUpEntry.Next() = 0;

        if SalesInvoiceIsOpen(InvoiceNo) then begin

            CustLedgerEntry.SetRange("Document No.", CreditMemoNo);
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
            if CustLedgerEntry.FindFirst() then begin
                CustLedgerEntry.CalcFields("Remaining Amount");
                CustLedgerEntry."Applies-to ID" := copystr(UserId, 1, 50);
                CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                CustLedgerEntry."Applying Entry" := true;
                CustLedgerEntry.Modify();
            end;

            CustLedgerEntry.Reset();
            CustLedgerEntry.SetRange("Document No.", InvoiceNo);
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
            if CustLedgerEntry.FindFirst() then begin
                CustLedgerEntry.CalcFields("Remaining Amount");
                CustLedgerEntry."Applies-to ID" := copystr(UserId, 1, 50);
                CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                CustLedgerEntry.Modify();
            end;

            OnAfterPostSimplifiedInvoiceAndCrMemos_BeforeCustApply(CustLedgerEntry, CustLedgerEntry);

            CustApplyPostedEntries.Apply(CustLedgerEntry, InvoiceNo, TempCashingUpEntry."Posting Date");
        end;
    end;

    procedure getInvoiceNo(CashingUp: Record "MBC ICG Cashing Up"): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("MBC ICG Closing Up", CashingUp."Closing Up");
        SalesInvoiceHeader.SetRange("MBC ICG POS Id.", CashingUp."POS Id.");
        SalesInvoiceHeader.SetRange("MBC ICG Shop Id.", CashingUp."Shop Id.");
        if SalesInvoiceHeader.FindFirst() then
            exit(SalesInvoiceHeader."No.")
        else
            exit('')
    end;

    procedure getCreditMemoNo(CashingUp: Record "MBC ICG Cashing Up"): Code[20]
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetRange("MBC ICG Closing Up", CashingUp."Closing Up");
        SalesCrMemoHeader.SetRange("MBC ICG POS Id.", CashingUp."POS Id.");
        SalesCrMemoHeader.SetRange("MBC ICG Shop Id.", CashingUp."Shop Id.");
        if SalesCrMemoHeader.FindFirst() then
            exit(SalesCrMemoHeader."No.")
        else
            exit('')
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCashingUp(var LXDClosingDay: Record "MBC ICG Closing Day")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCashingUp(var LXDClosingDay: Record "MBC ICG Closing Day"; CashingUp: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCashingUpEntry(var treasury: Record "MBC ICG Treasury")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCashingUpEntry(var treasury: Record "MBC ICG Treasury"; CashingUpEntry: Record "MBC ICG Cashing Up Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePrePayment(var PrePayment: Record "MBC ICG Advance Payments")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePrePayment_BeforePosting(var PrePayment: Record "MBC ICG Advance Payments"; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashingUp(CashingUp3: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyCustLedgEntry(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyCustLedgEntry_BeforePosting(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry"; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyCustLedgEntry_BeforePostingMod(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry"; var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateInvoice(CashinUp2: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInvoice_CreateDocument(CashinUp2: Record "MBC ICG Cashing Up"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInvoice(CashinUp2: Record "MBC ICG Cashing Up"; SalesHeader: Record "Sales Header"; SalesLineReturn: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCRMemo(CashinUp2: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCRMemo_CreateDocument(CashinUp2: Record "MBC ICG Cashing Up"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCRMemo(CashinUp2: Record "MBC ICG Cashing Up"; SalesHeader: Record "Sales Header"; SalesLineReturn: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetProcessedCashingUp(var CashingUp: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetProcessedCashingUp(var CashingUp: Record "MBC ICG Cashing Up"; CashingUp2: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostExpensesFromCashingUp(var CashingUp3: Record "MBC ICG Cashing Up")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostExpensesFromCashingUp(var CashingUp3: Record "MBC ICG Cashing Up"; CashingUpEntry: Record "MBC ICG Cashing Up Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashConcept(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCashConcept_BeforePosting(var CashingUpEntry2: Record "MBC ICG Cashing Up Entry"; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGroupCashinUpEntry(var CashinUp2: Record "MBC ICG Cashing Up"; var TempCashingUpEntry: Record "MBC ICG Cashing Up Entry" temporary; AmountPaymets: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddToleranceLine(AmountPaymets: Decimal; TotalAmountDocs: Decimal; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddToleranceLine(AmountPaymets: Decimal; TotalAmountDocs: Decimal; var SalesHeader: Record "Sales Header"; SalesLineOrder: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSimplifiedInvoiceAndCrMemos_BeforePostinPayment(var TempCashingUpEntry: Record "MBC ICG Cashing Up Entry" temporary; GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSimplifiedInvoiceAndCrMemos_BeforeCustApply(CustLedgerEntry1: Record "Cust. Ledger Entry"; CustLedgerEntry2: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSimplifiedInvoiceAndCrMemos(CashingUpEntry: Record "MBC ICG Cashing Up Entry")
    begin
    end;
}

