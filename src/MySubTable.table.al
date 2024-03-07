table 50851 "My Sub Table"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;

        }
        field(2; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

        }
    }


    keys
    {
        key(Key1; "Entry No.", Code)
        {
            Clustered = true;
        }
    }
}