
pageextension 50851 ZYItemPictureExt extends "Item Picture"
{
    actions
    {
        addafter(TakePicture)
        {
            action(ImportPictureFromiEncodedText)
            {
                Caption = 'Import Picture From Encoded Text';
                Image = Import;
                ApplicationArea = All;
                trigger OnAction()
                var
                    PictureEncodedTextDialog: Page "Picture Encoded Text Dialog";
                begin
                    PictureEncodedTextDialog.SetItemInfo(Rec."No.", Rec.Description);
                    if PictureEncodedTextDialog.RunModal() = Action::OK then
                        PictureEncodedTextDialog.ImportPictureFromiEncodedText();
                end;
            }
        }
    }
}