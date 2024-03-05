table 50850 Label
{
    DataClassification = CustomerContent;
    Caption = 'Label';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        /*
        field(3; Type; Enum "Label Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        */
        field(4; Data; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Data';
            SubType = bitmap;
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}