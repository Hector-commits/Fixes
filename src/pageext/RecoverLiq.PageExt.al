pageextension 50859 "Recover Liq." extends "MBC ICG Treasury"
{

    actions
    {
        addafter("Treasury Process All")
        {
            action("Recover Liq.")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    MBCICGTreasury: Record "MBC ICG Treasury";
                begin
                    MBCICGTreasury.Reset();
                    MBCICGTreasury.SetRange(POS, Rec.POS);
                    MBCICGTreasury.SetRange(Z, Rec.Z);
                    MBCICGTreasury.SetRange("Shop Id.", Rec."Shop Id.");
                    if MBCICGTreasury.IsEmpty() then
                        exit;

                    MBCICGTreasury.ModifyAll("Status NAV", MBCICGTreasury."Status NAV"::Pending);

                end;
            }
            action("Recover Liq2.")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                begin

                    Tesoreria(Rec);

                end;
            }
            action("Remove duplicates")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                begin

                    RemoveDuplicates();

                end;
            }
        }
    }
    local procedure Tesoreria(Trea: Record "MBC ICG Treasury")
    var
        Treasury: Record "MBC ICG Treasury";
    begin
        Treasury.Reset();
        Treasury.SetRange(POS, Trea.POS);
        Treasury.SetRange(Z, Trea.Z);
        Treasury.SetRange("Shop Id.", Trea."Shop Id.");
        Treasury.SetRange("Status NAV", Treasury."Status NAV"::Pending);
        IF Treasury.ISEMPTY THEN
            EXIT;

        Treasury.Findset();
        repeat
            CreateCashingUpEntry(Treasury);
            Treasury."Status NAV" := Treasury."Status NAV"::Processed;
            Treasury.Modify();
        until Treasury.Next() = 0;
    end;

    procedure CreateCashingUpEntry(var treasury: Record "MBC ICG Treasury")
    var
        CashingUpEntry: Record "MBC ICG Cashing Up Entry";
        GLSetup: Record "General Ledger Setup";
        PaymentMethod: Record "Payment Method";
        Salesperson: Record "Salesperson/Purchaser";
    begin


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
        //IF NOT CashingUpEntry.ISEMPTY THEN
        //    ERROR('Text50010Lbl');

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

    local procedure RemoveDuplicates()
    var
        MBCICGCashingUpEntry: Record "MBC ICG Cashing Up Entry";
        MBCICGCashingUpEntryCopy: Record "MBC ICG Cashing Up Entry";
    begin
        MBCICGCashingUpEntry.SetRange("Shop Id.", 'S4');
        MBCICGCashingUpEntry.SetRange("POS Id.", 'S41');
        MBCICGCashingUpEntry.SetRange("Closing Up", 759);
        if MBCICGCashingUpEntry.FindSet() then
            repeat
                MBCICGCashingUpEntryCopy.Reset();
                MBCICGCashingUpEntryCopy.SetRange("Shop Id.", MBCICGCashingUpEntry."Shop Id.");
                MBCICGCashingUpEntryCopy.SetRange("POS Id.", MBCICGCashingUpEntry."POS Id.");
                MBCICGCashingUpEntryCopy.SetRange("Closing Up", MBCICGCashingUpEntry."Closing Up");
                MBCICGCashingUpEntryCopy.SetRange("Document No.", MBCICGCashingUpEntry."Document No.");
                MBCICGCashingUpEntryCopy.SetRange("Payment Method Code", MBCICGCashingUpEntry."Payment Method Code");
                MBCICGCashingUpEntryCopy.SetFilter("Entry No.", '<>%1', MBCICGCashingUpEntry."Entry No.");
                if not MBCICGCashingUpEntryCopy.IsEmpty() then
                    MBCICGCashingUpEntryCopy.DeleteAll();

            until MBCICGCashingUpEntry.Next() = 0;



    end;

}