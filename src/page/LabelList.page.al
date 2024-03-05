page 50851 "Label List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Label;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Data; Rec.Data)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemId field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                }
                field(workDescription; GetWorkDescription2())
                {
                    ApplicationArea = All;
                    ToolTip = 'workdescription';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Download)
            {
                Promoted = true;
                Caption = 'Download';
                Image = Picture;
                ApplicationArea = All;

                trigger OnAction();
                var
                    InStream: InStream;
                    OutStr: OutStream;
                    myImageName: Text;
                    b64: Codeunit "Base64 Convert";
                    tempBlob: Codeunit "Temp Blob";
                    workDesc: Text;
                    JsonToken: JsonToken;
                    JsonObject: JsonObject;

                begin
                    /*
                    myImageName := 'image.jpg';
                    Rec.CalcFields(Data);
                    Rec.Data.CreateInStream(InStream, TextEncoding::UTF8);
                    b64.ToBase64(InStream, false);
                    DownloadFromStream(InStream, '', '', '', myImageName);
                    
                    myImageName := 'image.jpg';
                    JsonObject.ReadFrom(GetWorkDescription());

                    JsonObject.Get('data', JsonToken);

                    JsonToken.WriteTo(workDesc);

                    tempBlob.CreateInStream(InStream, TextEncoding::UTF8);

                    b64.ToBase64(InStream, false);

                    DownloadFromStream(InStream, '', '', '', myImageName);
                    */
                    ImportPictureFromiEncodedText();
                end;
            }
        }
    }


    procedure GetWorkDescription2(): Text
    var
        InStream: InStream;
        OutStr: OutStream;
        myImageName: Text;
        b64: Codeunit "Base64 Convert";
        tempBlob: Codeunit "Temp Blob";
        workDesc: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;

    begin
        myImageName := 'image.jpg';
        JsonObject.ReadFrom(GetWorkDescription());

        JsonObject.Get('data', JsonToken);

        JsonToken.WriteTo(workDesc);

        workDesc := DelChr(workDesc, '=', '"');

        exit(workDesc);

        workDesc := b64.FromBase64(workDesc);

        tempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(workDesc);

        tempBlob.CreateInStream(InStream);

        DownloadFromStream(InStream, '', '', '', myImageName);
    end;

    procedure GetWorkDescription() WorkDescription: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields(Rec.Data);
        Rec.Data.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));

    end;


    procedure SetItemInfo(NewItemNo: Code[20]; NewItemDesc: Text[100])
    begin
        ItemNo := NewItemNo;
        ItemDesc := NewItemDesc;
    end;

    procedure ImportPictureFromiEncodedText()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        ClientFileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Item: Record Item;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';
        Base64Convert: Codeunit "Base64 Convert";
        PictureEncodedTextDialog: Text;
    begin

        FileName := 'image' + '.png';
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(PictureEncodedTextDialog, OutStr);
        TempBlob.CreateInStream(InStr);
        /*
        Clear(Item.Picture);
        Item.Picture.ImportStream(InStr, FileName);
        Item.Modify(true);
        */
        DownloadFromStream(InStr, '', '', '', FileName);
    end;
}