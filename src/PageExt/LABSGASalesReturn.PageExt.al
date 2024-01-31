///Extend SGA Export Management page with an action to process the purchase order lines
pageextension 50999 "LAB SGA Sales Return" extends "Sales Return Order"
{
    actions
    {
        addafter("Archive Document")
        {
            action("MarkSGASent")
            {
                ApplicationArea = All;
                Caption = 'Mark SGA Sent';
                Promoted = true;
                PromotedCategory = Process;
                Image = Debug;
                PromotedIsBig = true;
                ToolTip = 'IM Internal Use Only', Comment = 'ESP="IM Internal Use Only"';

                trigger OnAction()
                begin
                    Rec."LAB SGA Sended" := true;
                    Rec.Modify()
                end;
            }
        }
    }
}
