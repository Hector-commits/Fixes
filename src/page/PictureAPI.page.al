page 50851 "Picture API"
{
    PageType = API;
    Caption = 'pictureAPI';
    APIPublisher = 'hp';
    APIGroup = 'pictures';
    APIVersion = 'v1.0';
    EntityName = 'picture';
    EntitySetName = 'picture';
    SourceTable = Item;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.") { }
                field(base64Pic; base64Pic)
                {
                    trigger OnValidate()
                    begin
                        ImportPictureFromiEncodedText();
                    end;
                }
            }
        }
    }
    var
        base64Pic: Text;

    procedure ImportPictureFromiEncodedText()
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        FileName: Text;
        InStr: InStream;
        OutStr: OutStream;
    begin
        FileName := Rec.Description + '.png';
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(base64Pic, OutStr);
        TempBlob.CreateInStream(InStr);
        Clear(Rec.Picture);
        Rec.Picture.ImportStream(InStr, FileName);
    end;
}