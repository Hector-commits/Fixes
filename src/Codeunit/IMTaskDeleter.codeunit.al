codeunit 50851 "IM Task Deleter"
{

    procedure deleteTasks()
    var
        MBCIMWWhseWorkHeader: Record "MBC IMW Whse. Work Header";
    begin
        MBCIMWWhseWorkHeader.DeleteAll();
    end;

}