codeunit 50851 "IM Task Deleter"
{

    procedure deleteTasks()
    var
        MBCIMWWhseWorkHeader: Record "MBC IMW Whse. Work Header";
        MBCIMWWhseWorkLine: Record "MBC IMW Whse. Work Line";
    begin
        MBCIMWWhseWorkHeader.DeleteAll();
        MBCIMWWhseWorkLine.DeleteAll();
    end;

}