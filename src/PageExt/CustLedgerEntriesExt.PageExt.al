pageextension 50850 "Cust Ledger Entries Ext" extends "Customer Ledger Entries"
{

    actions
    {
        addafter(ReverseTransaction)
        {
            action(FixPayment)
            {
                Caption = 'Fix Payment', Comment = 'ESP="Fix Payment"';
                ToolTip = 'Fix Payment', Comment = 'ESP="Fix Payment"';
                Promoted = true;
                PromotedCategory = Process;
                Image = "8ball";
                ApplicationArea = All;

                trigger OnAction()
                var
                    invoiceAmount: Decimal;
                    refundAmount: Decimal;
                    timesMult: Integer;
                begin
                    removeOldSuggest();

                    if Rec."Document Type" <> Rec."Document Type"::Payment then
                        exit;

                    Rec.CalcFields("Remaining Amount");

                    if Rec."Remaining Amount" = 0 then
                        exit;

                    invoiceAmount := getInvoiceAmount();

                    refundAmount := invoiceAmount + getRefundAmount(invoiceAmount);

                    timesMult := Round(refundAmount / invoiceAmount, 1);

                    if not Confirm(StrSubstNo(
                                    'Inv. amount: %1, Ref. amount: %2, Times mult: %3. Procced?',
                                    Format(invoiceAmount),
                                    Format(refundAmount),
                                    Format(timesMult)), false) then
                        exit;

                    processRefund(timesMult);

                end;
            }
        }
    }
    local procedure getInvoiceAmount(): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", getSalesInvNo());
        if CustLedgerEntry.IsEmpty then
            Error('No invoice with No. %1', getSalesInvNo());

        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount", Amount);
        if CustLedgerEntry."Remaining Amount" <> 0 then
            Error('Invoice %1 is not totally applied', Rec."Document No.");

        exit(CustLedgerEntry.Amount);
    end;

    local procedure getRefundAmount(invAmount: Decimal): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        paymentAmount: Decimal;
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", Rec."Document No.");
        CustLedgerEntry.FindSet();
        repeat
            CustLedgerEntry.CalcFields(Amount);
            paymentAmount += CustLedgerEntry.Amount;
        until CustLedgerEntry.Next() = 0;

        exit(Abs(invAmount + paymentAmount));
    end;

    local procedure processRefund(timesMultiplied: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        PostGenJnlBatch: Codeunit "Gen. Jnl.-Post Batch";
        GnlJnlBatch: Record "Gen. Journal Batch";
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", Rec."Document No.");
        CustLedgerEntry.FindSet();
        repeat
            CustLedgerEntry.CalcFields(Amount);

            GenJnlLine.INIT();
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Account No." := GetCustomerNo(getSalesInvNo());
            GenJnlLine."Posting Date" := CustLedgerEntry."Posting Date";
            GenJnlLine."Journal Template Name" := 'PAGO';
            GenJnlLine."Journal Batch Name" := 'GENERICO';
            GenJnlLine."Line No." := getNextLineNo();
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
            GenJnlLine."Document No." := Copystr('R-' + getSalesInvNo(), 1, 20);
            GenJnlLine."Payment Method Code" := CustLedgerEntry."Payment Method Code";
            PaymentMethod.Get(CustLedgerEntry."Payment Method Code");
            if PaymentMethod."Bal. Account Type" = PaymentMethod."Bal. Account Type"::"Bank Account" then
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account"
            else
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";

            GenJnlLine."Bal. Account No." := PaymentMethod."Bal. Account No.";

            GenJnlLine.Amount := -CustLedgerEntry.Amount / timesMultiplied;
            GenJnlLine."Debit Amount" := -GenJnlLine.Amount;

            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
            GenJnlLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
            GenJnlLine."Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
            GenJnlLine.Insert();
        until CustLedgerEntry.Next() = 0;

        CLEAR(GnlJnlBatch);
        PostGenJnlBatch.Run(GenJnlLine);

    end;

    local procedure GetCustomerNo(DocumentNo2: Code[20]): Code[20]
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        SalesInvHeader.Reset();
        SalesInvHeader.GET(DocumentNo2);

        exit(SalesInvHeader."Bill-to Customer No.");
    end;

    local procedure getSalesInvNo(): Code[20]
    begin
        exit(DelChr(CopyStr(Rec."Document No.", 3, MaxStrLen(Rec."Document No.")), '=', ' '));
    end;

    local procedure getNextLineNo(): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Batch Name", 'GENERICO');
        GenJnlLine.SetRange("Journal Template Name", 'PAGO');
        if not GenJnlLine.IsEmpty then begin
            GenJnlLine.FindLast();
            exit(GenJnlLine."Line No." + 10000)
        end else
            exit(10000);
    end;

    local procedure removeOldSuggest()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Batch Name", 'GENERICO');
        GenJnlLine.SetRange("Journal Template Name", 'PAGO');
        if not GenJnlLine.IsEmpty then
            GenJnlLine.DeleteAll();
    end;

}