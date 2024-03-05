pageextension 50850 ZYItemCardExt extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field(LargeText; LargeText)
            {
                Caption = 'Large Text';
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
                trigger OnValidate()
                begin
                    SetLargeText(LargeText);
                end;
            }
        }
    }
    actions
    {
        addafter("Item Tracing")
        {
            action(ConvertPictureToEncodedText)
            {
                Caption = 'Convert Picture To Encoded Text';
                Image = Transactions;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Base64Convert: Codeunit "Base64 Convert";
                    ItemTenantMedia: Record "Tenant Media";
                    InStr: InStream;
                begin
                    if Rec.Picture.Count > 0 then begin
                        ItemTenantMedia.Get(Rec.Picture.Item(1));
                        ItemTenantMedia.CalcFields(Content);
                        ItemTenantMedia.Content.CreateInStream(InStr, TextEncoding::UTF8);
                        LargeText := Base64Convert.ToBase64(InStr, false);
                        SetLargeText(LargeText);
                    end;
                end;
            }
            action("Transform API to Pic")
            {
                Caption = 'Transform API to Pic';
                Image = Transactions;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var

                begin
                    ImportPictureFromiEncodedText()
                end;
            }
        }
    }
    var
        LargeText: Text;

    trigger OnAfterGetRecord()
    begin
        LargeText := GetLargeText();
    end;

    procedure SetLargeText(NewLargeText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Large Text");
        Rec."Large Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(LargeText);
        Rec.Modify();
    end;

    procedure GetLargeText() NewLargeText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        tempText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        Rec.CalcFields("Large Text");
        Rec."Large Text".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName("Large Text")));
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
    begin
        if Item.Get("No.") then begin
            if Item.Description = '' then
                Error(MustSpecifyDescriptionErr);
            if Item.Picture.Count > 0 then
                if not Confirm(OverrideImageQst) then
                    Error('');
            FileName := Description + '.png';
            TempBlob.CreateOutStream(OutStr);
            Base64Convert.FromBase64(getLargeText(), OutStr);
            TempBlob.CreateInStream(InStr);
            Clear(Item.Picture);
            Item.Picture.ImportStream(InStr, FileName);
            Item.Modify(true);
        end;
    end;

}