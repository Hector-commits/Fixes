page 50859 "Delete Reservation Entries"
{
    PageType = List;
    SourceTable = "Reservation Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value from the same field on the physical inventory tracking line.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Location of the items that have been reserved in the entry.';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the item that has been reserved in the entry.';
                }
                field("Reservation Status"; Rec."Reservation Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the reservation.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the record.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the traced record was created.';
                }
                field("Transferred from Entry No."; Rec."Transferred from Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a value when the order tracking entry is for the quantity that remains on a document line after a partial posting.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies for which source type the reservation entry is related to.';
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which source subtype the reservation entry is related to.';
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which source ID the reservation entry is related to.';
                }
                field("Source Batch Name"; Rec."Source Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the journal batch name if the reservation entry is related to a journal or requisition line.';
                }
                field("Source Prod. Order Line"; Rec."Source Prod. Order Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Prod. Order Line field.';
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a reference number for the line, which the reservation entry is related to.';
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field.';
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which the reserved items are expected to enter inventory.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the serial number of the item that is being handled on the document line.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the traced record.';
                }
                field("Changed By"; Rec."Changed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Changed By field.';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the difference is positive.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many of the base unit of measure are contained in one unit of the item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of the record.';
                }
                field("Action Message Adjustment"; Rec."Action Message Adjustment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Message Adjustment field.';
                }
                field(Binding; Rec.Binding)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Binding field.';
                }
                field("Suppressed Action Msg."; Rec."Suppressed Action Msg.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suppressed Action Msg. field.';
                }
                field("Planning Flexibility"; Rec."Planning Flexibility")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Planning Flexibility field.';
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Appl.-to Item Entry field.';
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last day of the serial/lot number''s warranty.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expiration date of the lot or serial number on the item tracking line.';
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of item, in the base unit of measure, to be handled in a warehouse activity.';
                }
                field("Qty. to Invoice (Base)"; Rec."Qty. to Invoice (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity, in the base unit of measure, that remains to be invoiced. It is calculated as Quantity - Qty. Invoiced.';
                }
                field("Quantity Invoiced (Base)"; Rec."Quantity Invoiced (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Invoiced (Base) field.';
                }
                field("New Serial No."; Rec."New Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Serial No. field.';
                }
                field("New Lot No."; Rec."New Lot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Lot No. field.';
                }
                field("Disallow Cancellation"; Rec."Disallow Cancellation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disallow Cancellation field.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lot number of the item that is being handled with the associated document line.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Appl.-from Item Entry"; Rec."Appl.-from Item Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Appl.-from Item Entry field.';
                }
                field(Correction; Rec.Correction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Correction field.';
                }
                field("New Expiration Date"; Rec."New Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Expiration Date field.';
                }
                field("Item Tracking"; Rec."Item Tracking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Tracking field.';
                }
                field("Untracked Surplus"; Rec."Untracked Surplus")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Untracked Surplus field.';
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the package number of the item that is being handled with the associated document line.';
                }
                field("New Package No."; Rec."New Package No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Package No. field.';
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Delete Entry")
            {
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Delete Entry';

                trigger OnAction()
                var
                    DeleteReservationEntry: Codeunit "Delete Reservation Entry";
                begin
                    DeleteReservationEntry.DeleteEntry(Rec);
                end;
            }
        }
    }
}