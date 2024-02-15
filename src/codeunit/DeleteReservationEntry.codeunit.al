codeunit 50999 "Delete Reservation Entry"
{
    Permissions = tabledata "Reservation Entry" = rimd;
    procedure DeleteEntry(ResEntry: Record "Reservation Entry")
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Get(ResEntry."Entry No.");
    end;
}