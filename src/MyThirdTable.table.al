table 50852 "My Third Table"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[10])
        {
            caption = 'Code';
            DataClassification = CustomerContent;

        }
        field(2; Description; Text[50])
        {
            caption = 'Description';
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; Code, Description)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}