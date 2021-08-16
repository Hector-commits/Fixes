
codeunit 50850 "Fix"
{
    trigger OnRun()
    begin
        processStuff();
    end;

    local procedure processStuff()
    var
        CashingUP: Record "MBC ICG Cashing Up";
    begin
        if CashingUP.Get(2568) then begin
            CashingUP.Sales := 718.77;
            if CashingUP.Modify() then
                Message('End!');
        end;


    end;
}
