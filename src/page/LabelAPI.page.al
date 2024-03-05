page 50851 LabelAPI
{
    PageType = API;
    Caption = 'labelApi';
    APIPublisher = 'sd';
    APIGroup = 'customapi';
    APIVersion = 'v1.0';
    EntityName = 'label';
    EntitySetName = 'labels';
    SourceTable = Item;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    //InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.")
                {
                    Caption = 'itemNo';
                }
                field(description; Rec.Description)
                {
                    Caption = 'description';
                }
                field(largeText; largeText)
                {
                    Caption = 'data';

                    trigger OnValidate()
                    begin
                        ImportPictureFromiEncodedText();
                    end;
                }
            }
        }
    }
    var
        largeText: Text;

    procedure ImportPictureFromiEncodedText()
    var
        FileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        FileName := Rec.Description + '.png';
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(largeText, OutStr);
        TempBlob.CreateInStream(InStr);
        Clear(Rec.Picture);
        Rec.Picture.ImportStream(InStr, FileName);
    end;
}