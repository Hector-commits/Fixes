pageextension 50999 "Fix SGA Import Queue" extends "SGA Import Queue"
{


    actions
    {
        addafter(SGAPost)
        {
            action("Fix link")
            {
                ApplicationArea = All;
                Caption = 'Fix link';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Fix missing links.';

                trigger OnAction()
                var
                    LABSGAImportDocument: Record "LAB SGA Import Document";
                    ImportDocLine: Record "LAB SGA Import Document Line";
                    Counter: Integer;
                begin
                    Counter := 0;

                    LABSGAImportDocument.Get(Rec."Table Entry No.");

                    ImportDocLine.SetRange("Document Entry No.", LABSGAImportDocument."Entry No.");
                    if ImportDocLine.IsEmpty() then begin
                        ImportDocLine.Reset();
                        ImportDocLine.SetRange("Document ID", LABSGAImportDocument.SystemId);
                        if not ImportDocLine.IsEmpty() then begin
                            ImportDocLine.ModifyAll("Document Entry No.", LABSGAImportDocument."Entry No.");
                            ImportDocLine.ModifyAll("Type Entry", LABSGAImportDocument."Entry Type");
                        end;
                    end;

                    Message('Fixed %1 links.', Counter);
                end;
            }
            action("Fix link All")
            {
                ApplicationArea = All;
                Caption = 'Fix link All';
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Fix All missing links.';

                trigger OnAction()
                var
                    LABSGAImportDocument: Record "LAB SGA Import Document";
                    ImportDocLine: Record "LAB SGA Import Document Line";
                    Counter: Integer;
                begin
                    Counter := 0;


                    LABSGAImportDocument.SetFilter(SystemCreatedAt, '>%1', CreateDateTime(Today, 0T));
                    if LABSGAImportDocument.FindSet() then
                        repeat
                            ImportDocLine.SetRange("Document Entry No.", LABSGAImportDocument."Entry No.");
                            if ImportDocLine.IsEmpty() then begin
                                ImportDocLine.Reset();
                                ImportDocLine.SetRange("Document ID", LABSGAImportDocument.SystemId);
                                if not ImportDocLine.IsEmpty() then begin
                                    Counter += 1;
                                    ImportDocLine.ModifyAll("Document Entry No.", LABSGAImportDocument."Entry No.");
                                    ImportDocLine.ModifyAll("Type Entry", LABSGAImportDocument."Entry Type");
                                end;
                            end;
                        until LABSGAImportDocument.Next() = 0;

                    Message('Fixed %1 links.', Counter);
                end;
            }
        }
    }
}