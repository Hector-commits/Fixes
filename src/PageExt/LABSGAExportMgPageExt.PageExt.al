///Extend SGA Export Management page with an action to process the purchase order lines
pageextension 50999 "LAB SGA Export Mg Page Ext" extends "SGA Export Management"
{
    actions
    {
        addafter("Show Request")
        {
            action("Show Request Advanced")
            {
                ApplicationArea = All;
                Caption = 'Show Request Advanced';
                Promoted = true;
                PromotedCategory = Process;
                Image = Debug;
                PromotedIsBig = true;
                ToolTip = 'IM Internal Use Only', Comment = 'ESP="IM Internal Use Only"';

                trigger OnAction()
                begin
                    PrintAssemblyOrder(Rec);
                end;
            }
        }
    }
    procedure PrintAssemblyOrder(var SGAiOrden: Record "LAB SGA Export")
    var
        SGASetup: Record "LAB SGA Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        JsonObjCus, JsonObjBody : JsonObject;
        JsonArrayBody: JsonArray;
        Url, TextBody : Text;
    begin
        SGASetup.Get();
        SGASetup.TestField("URL API");
        SGASetup.TestField("SGA Company Code");

        ItemLedgerEntry.SetCurrentKey("Entry Type");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Output");
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Posted Assembly");
        ItemLedgerEntry.SetRange("Document No.", SGAiOrden."Document No.");

        ItemLedgerEntry.FindSet();
        repeat
            Location.Get(ItemLedgerEntry."Location Code");

            JsonObjBody.Add('CodigoEmpresa', SGASetup."SGA Company Code");
            JsonObjBody.Add('CodigoDelegacion', '01');
            JsonObjBody.Add('NumDocERP', ItemLedgerEntry."Document No.");
            JsonObjBody.Add('LinDocERP', 1);
            JsonObjBody.Add('CodigoArticulo', ItemLedgerEntry."Source No.");
            JsonObjBody.Add('Cantidad', Abs(ItemLedgerEntry.Quantity));
            JsonObjBody.Add('CodigoAlmacen', Location."LAB SGA Code");
            JsonObjBody.Add('NumLote', ItemLedgerEntry."Lot No.");
            if ItemLedgerEntry."Expiration Date" <> 0D then
                JsonObjBody.Add('FechaCaducidad', ItemLedgerEntry."Expiration Date")
            else
                JsonObjBody.Add('FechaCaducidad', '');
            JsonObjBody.Add('NumSerie', ItemLedgerEntry."Serial No.");
            JsonObjBody.Add('Maquina', 'ET');
            JsonObjBody.Add('AccionSGA', SGAiOrden."SGA Action");
            JsonArrayBody.Add(JsonObjBody);
        until ItemLedgerEntry.Next() = 0;

        JsonObjCus.Add('PRODUCTOACABADO', JsonArrayBody);
        JsonObjCus.WriteTo(TextBody);

        TextBody := '[' + TextBody + ']';

        Url := SGASetup."URL API" + 'Produccion/SetProductoAcabado';

        Message(Url + '\\' + TextBody);

    end;
}
