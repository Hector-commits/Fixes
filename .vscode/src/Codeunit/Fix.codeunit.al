
codeunit 50850 "Fix"
{

    Permissions = tabledata 1205 = md, tabledata 1206 = md;
    trigger OnRun()
    begin
        removeStuff();
    end;

    local procedure removeStuff()
    var
        CrTrReg: Record "Credit Transfer Register";
        CrTrEnt: Record "Credit Transfer Entry";
    begin
        CrTrEnt.Reset();
        CrTrEnt.SetRange("Credit Transfer Register No.", 466, 467);
        if CrTrEnt.FindSet() then
            repeat
                CrTrEnt.Delete();
            until CrTrEnt.Next() = 0;

        CrTrReg.Reset();
        CrTrReg.SetRange("No.", 466, 467);
        if CrTrReg.FindSet() then
            repeat
                CrTrReg.Delete();
            until CrTrReg.Next() = 0;
    end;
}
