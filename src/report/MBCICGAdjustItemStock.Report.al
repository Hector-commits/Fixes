/// <summary>
/// Report MBC ICG Adjust Item Stock (ID 70007).
/// </summary>
report 50999 "MBC ICG Adjust Item Stock"
{
    Caption = 'ICG Adjust Item Stock', comment = 'ESP="Ajustar Stock de Artículos ICG"';
    ProcessingOnly = true;
    dataset
    {
        dataitem(Location; Location)
        {
            dataitem(Item; Item)
            {
                DataItemTableView = where("Assembly Policy" = filter("Assemble-to-Order"));

                trigger OnPreDataItem()
                begin
                    SetRange("Location Filter", Location.Code);
                end;

                trigger OnAfterGetRecord()
                begin

                    Item.CalcFields(Inventory);

                    if Item.Inventory <> 0 then begin
                        AdjustStock(Item."No.", StrSubstNo(DocumentNoLbl, Format(Today(), 0, '<Day,2><Month,2><Year,2>')), -Item.Inventory, Item."Location Filter", '', '', '', copystr(UserId, 1, 50), 0D);
                        AdjustComponentStock(Item."No.", Item."Location Filter", Item.Inventory);
                    end;

                end;
            }
        }
    }

    /// <summary>
    /// AdjustStock.
    /// </summary>
    /// <param name="ItemCode">Code[20].</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="Quantity">Decimal.</param>
    /// <param name="Location">Code[20].</param>
    /// <param name="Bin">Code[20].</param>
    /// <param name="Lot">Code[30].</param>
    /// <param name="Serie">Code[30].</param>
    /// <param name="User">Code[50].</param>
    /// <param name="ExpirationDate">Date.</param>
    procedure AdjustStock(ItemCode: Code[20]; DocumentNo: Code[20]; Quantity: Decimal; Location: Code[20]; Bin: Code[20]; Lot: Code[30]; Serie: Code[30]; User: Code[50]; ExpirationDate: Date)
    begin
        AdjustStock(ItemCode, StrSubstNo(DocumentNoLbl, Format(Today(), 0, '<Day,2><Month,2><Year,2>')), Quantity, Location, Bin, Lot, Serie, User, ExpirationDate, 0);
    end;

    /// <summary>
    /// AdjustStock.
    /// </summary>
    /// <param name="ItemCode">Code[20].</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="Quantity">Decimal.</param>
    /// <param name="Location">Code[20].</param>
    /// <param name="Bin">Code[20].</param>
    /// <param name="Lot">Code[30].</param>
    /// <param name="Serie">Code[30].</param>
    /// <param name="User">Code[50].</param>
    /// <param name="ExpirationDate">Date.</param>
    /// <param name="DimensionSetId">Integer.</param>
    procedure AdjustStock(ItemCode: Code[20]; DocumentNo: Code[20]; Quantity: Decimal; Location: Code[20]; Bin: Code[20]; Lot: Code[30]; Serie: Code[30]; User: Code[50]; ExpirationDate: Date; DimensionSetId: Integer)
    var
        LocationTable: Record Location;
        Item: Record Item;
        ItemJNLine: Record "Item Journal Line";
        //MBCICGConnectorConfig: Record "MBC ICG Connector Config";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        IF Quantity = 0 THEN
            exit;

        LocationTable.GET(Location);
        Item.GET(ItemCode);

        ItemJNLine.Init();
        ItemJNLine.VALIDATE("Posting Date", TODAY);
        ItemJNLine."Source Code" := TXTSOURCELbl;
        IF Quantity < 0 THEN
            ItemJNLine.VALIDATE("Entry Type", ItemJNLine."Entry Type"::"Negative Adjmt.")
        ELSE
            ItemJNLine.VALIDATE("Entry Type", ItemJNLine."Entry Type"::"Positive Adjmt.");

        IF DocumentNo = '' THEN
            DocumentNo := FORMAT(TODAY, 0, '<day,2><month,2><year>');

        ItemJNLine.VALIDATE("Document No.", DocumentNo);
        ItemJNLine.VALIDATE("Item No.", ItemCode);
        ItemJNLine.VALIDATE("Location Code", Location);
        IF Bin <> '' THEN
            ItemJNLine.VALIDATE("Bin Code", Bin);

        ItemJNLine.Description := COPYSTR(User, 1, 50);

        ItemJNLine.VALIDATE(Quantity, ABS(Quantity));

        IF Lot <> '' THEN
            ItemJNLine."Lot No." := Lot;

        IF Serie <> '' THEN
            ItemJNLine."Serial No." := Serie;

        if ExpirationDate <> 0D then
            ItemJNLine."Expiration Date" := ExpirationDate;

        IF (ItemJNLine."Entry Type" = ItemJNLine."Entry Type"::"Positive Adjmt.") AND (ItemJNLine."Unit Cost" = 0) THEN
            ItemJNLine.VALIDATE("Unit Cost", Item."Unit Cost");

        //MBCICGConnectorConfig.Get();

        //if (MBCICGConnectorConfig."Adjust Stock Dimension" = MBCICGConnectorConfig."Adjust Stock Dimension"::"Sales Line")
        //and (DimensionSetId <> 0) then begin
        //    ItemJNLine."Dimension Set ID" := DimensionSetId;
        //    DimMgt.UpdateGlobalDimFromDimSetID(ItemJNLine."Dimension Set ID", ItemJNLine."Shortcut Dimension 1 Code", ItemJNLine."Shortcut Dimension 2 Code");
        //end;

        //if MBCICGConnectorConfig."Adjust Stock Dimension" = MBCICGConnectorConfig."Adjust Stock Dimension"::Location then begin
        //    ItemJNLine."Dimension Set ID" := GetDimensionbyLocation(ItemJNLine."Location Code");
        //    DimMgt.UpdateGlobalDimFromDimSetID(ItemJNLine."Dimension Set ID", ItemJNLine."Shortcut Dimension 1 Code", ItemJNLine."Shortcut Dimension 2 Code");
        //end;

        fCreateReserve(ItemJNLine);

        OnAfterAdjustStockFillItemLedgerEntry(ItemJNLine);

        IF LocationTable."Bin Mandatory" THEN
            AdjustStockWhse(ItemCode, DocumentNo, Quantity, Location, Bin, Lot, Serie, User)
        ELSE
            ItemJnlPostLine.RunWithCheck(ItemJNLine);

    end;

    local procedure AdjustStockWhse(ItemCode: Code[20]; DocumentNo: Code[20]; Quantity: Decimal; Location: Code[20]; Bin: Code[20]; Lot: Code[30]; Serie: Code[30]; User: Code[50])
    var
        LocationTable: Record Location;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        WhseJNLine: Record "Warehouse Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJNLine: Record "Item Journal Line";
        CalculateWhseAdjustment: Report "Calculate Whse. Adjustment";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        Text020Lbl: Label 'Bin Mandatory', Comment = 'ESP="Ubicacion obligatoria."';
    begin
        LocationTable.GET(Location);
        LocationTable.TESTFIELD("Directed Put-away and Pick", TRUE);

        Item.Reset();
        Item.SETRANGE("No.", ItemCode);
        Item.FindSet();

        IF (Lot <> '') OR (Serie <> '') THEN BEGIN
            ItemTrackingCode.GET(Item."Item Tracking Code");
            IF Lot <> '' THEN ItemTrackingCode.TESTFIELD("Lot Specific Tracking", TRUE);
            IF Serie <> '' THEN ItemTrackingCode.TESTFIELD("SN Specific Tracking", TRUE);
        END;

        IF Bin = '' THEN
            ERROR(Text020Lbl);

        WarehouseJournalBatch.Reset();
        WarehouseJournalBatch.SETRANGE("Template Type", WarehouseJournalBatch."Template Type"::Item);
        WarehouseJournalBatch.SETRANGE("Location Code", Location);
        WarehouseJournalBatch.FindFirst();

        WhseJNLine.Init();
        WhseJNLine.VALIDATE("Journal Template Name", WarehouseJournalBatch."Journal Template Name");
        WhseJNLine.VALIDATE("Journal Batch Name", WarehouseJournalBatch.Name);
        WhseJNLine.VALIDATE("Registering Date", TODAY);
        WhseJNLine.VALIDATE("Location Code", Location);
        WhseJNLine."Source Code" := TXTSOURCELbl;
        WhseJNLine.VALIDATE("Item No.", ItemCode);

        IF DocumentNo <> '' THEN
            WhseJNLine.VALIDATE("Whse. Document No.", DocumentNo)
        ELSE
            WhseJNLine.VALIDATE("Whse. Document No.", FORMAT(TODAY, 0, '<day,2><month,2><year>'));

        WhseJNLine.VALIDATE("Bin Code", Bin);
        WhseJNLine.VALIDATE("Unit of Measure Code", Item."Base Unit of Measure");
        WhseJNLine.Description := COPYSTR(User, 1, 50);
        WhseJNLine.VALIDATE(Quantity, Quantity);

        IF Lot <> '' THEN
            WhseJNLine."Lot No." := Lot;

        IF Serie <> '' THEN
            WhseJNLine."Serial No." := Serie;

        IF Quantity < 0 THEN BEGIN
            WhseJNLine."Entry Type" := WhseJNLine."Entry Type"::"Negative Adjmt.";
            WhseJNLine."To Bin Code" := LocationTable."Adjustment Bin Code";
        END ELSE BEGIN
            WhseJNLine."Entry Type" := WhseJNLine."Entry Type"::"Positive Adjmt.";
            WhseJNLine."From Bin Code" := LocationTable."Adjustment Bin Code";
        END;

        CLEAR(WhseJnlPostLine);
        WhseJnlPostLine.RUN(WhseJNLine);

        //<REGISTRO PRODUCTO
        ItemJournalTemplate.Reset();
        ItemJournalTemplate.SETRANGE(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SETRANGE(Recurring, FALSE);
        ItemJournalTemplate.FindFirst();

        ItemJNLine.Reset();
        ItemJNLine.SETRANGE("Journal Template Name", ItemJournalTemplate.Name);
        ItemJNLine.SETRANGE("Journal Batch Name", 'PISTOLAS');
        ItemJNLine.DELETEALL(TRUE);

        ItemJNLine.Init();
        ItemJNLine."Journal Template Name" := ItemJournalTemplate.Name;
        ItemJNLine."Journal Batch Name" := 'PISTOLAS';

        CLEAR(CalculateWhseAdjustment);
        CalculateWhseAdjustment.InitializeRequest(TODAY, DocumentNo);
        CalculateWhseAdjustment.SetHideValidationDialog(TRUE);
        CalculateWhseAdjustment.SetItemJnlLine(ItemJNLine);
        CalculateWhseAdjustment.SETTABLEVIEW(Item);
        CalculateWhseAdjustment.USEREQUESTPAGE(FALSE);
        CalculateWhseAdjustment.RUN();

        ItemJNLine.Reset();
        ItemJNLine.SETRANGE("Journal Template Name", ItemJournalTemplate.Name);
        ItemJNLine.SETRANGE("Journal Batch Name", 'PISTOLAS');
        CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post Batch", ItemJNLine);
    end;

    local procedure fCreateReserve(VAR ItemJnlLine: Record "Item Journal Line")
    var
        ReservEntry: Record "Reservation Entry";
        xItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        ForReservEntry: Record "Reservation Entry";
        //ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservEngineMzgt: Codeunit "Reservation Engine Mgt.";
        CurrentEntryStatus: Enum "Reservation Status";

    begin
        IF (ItemJnlLine."Lot No." = '') AND (ItemJnlLine."Serial No." = '') THEN
            EXIT;

        CLEAR(ReservEntry);

        IF ItemJnlLine.Quantity = 0 THEN
            EXIT;

        xItemJnlLine := ItemJnlLine;
        IF ItemJnlLine."Serial No." <> '' THEN
            xItemJnlLine."Quantity (Base)" := 1;

        ReservEntry.Init();
        CLEAR(CreateReservEntry);
        ForReservEntry."Lot No." := ItemJnlLine."Lot No.";
        ForReservEntry."Serial No." := ItemJnlLine."Serial No.";
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Item Journal Line",
          ItemJnlLine."Entry Type".AsInteger(),
          ItemJnlLine."Journal Template Name", //'',
          ItemJnlLine."Journal Batch Name", //'',
          0,
          ItemJnlLine."Line No.", //0,
          1,
          1, //Qbase
          xItemJnlLine."Quantity (Base)",
          ForReservEntry);

        IF ((ItemJnlLine.Quantity > 0) AND (ItemJnlLine."Entry Type" IN
           [ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::Transfer])) OR
           ((ItemJnlLine.Quantity < 0) AND (ItemJnlLine."Entry Type" IN
           [ItemJnlLine."Entry Type"::Sale, ItemJnlLine."Entry Type"::"Negative Adjmt."])) THEN
            CreateReservEntry.CreateEntry(ItemJnlLine."Item No.",
              ItemJnlLine."Variant Code",
              ItemJnlLine."Location Code",
              ItemJnlLine.Description,
              WORKDATE(),
              WORKDATE(), 0, CurrentEntryStatus::Surplus)
        ELSE
            CreateReservEntry.CreateEntry(ItemJnlLine."Item No.",
              ItemJnlLine."Variant Code",
              ItemJnlLine."Location Code",
              ItemJnlLine.Description,
              WORKDATE(),
              WORKDATE(), 0, CurrentEntryStatus::Prospect);

        ReservEntry.FIND('+');

        CreateReservEntry.GetLastEntry(ReservEntry);

        IF ItemJnlLine."Expiration Date" <> 0D THEN BEGIN
            ReservEntry."Expiration Date" := ItemJnlLine."Expiration Date";
            ReservEntry.Modify();
        END;


        Item.GET(ItemJnlLine."Item No.");
        IF Item."Order Tracking Policy" = Item."Order Tracking Policy"::"Tracking & Action Msg." THEN
            ReservEngineMzgt.UpdateActionMessages(ReservEntry);

        IF ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer THEN BEGIN
            ReservEntry."New Serial No." := ItemJnlLine."New Serial No.";
            ReservEntry."New Lot No." := ItemJnlLine."New Lot No.";
            ReservEntry."New Expiration Date" := ItemJnlLine."Expiration Date";
            ReservEntry.Modify();
            ItemJnlLine."New Item Expiration Date" := ItemJnlLine."Expiration Date";
        END;

        ItemJnlLine."Lot No." := '';
        ItemJnlLine."Serial No." := '';
        ItemJnlLine."New Serial No." := '';
        ItemJnlLine."New Lot No." := '';
    end;

    local procedure AdjustComponentStock(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal)
    var
        BOMComponent: Record "BOM Component";
        ItemTrackingCode: Record "Item Tracking Code";
        //MBCICGConnectorConfig: Record "MBC ICG Connector Config";
        Item: Record Item;
        //MBCICGIntegrationManagment: Codeunit "MBC ICG Integration Managment";
        UnitofMeasureManagement: Codeunit "Unit of Measure Management";
        ExpirationCalc: DateFormula;
        QtyToAdjust: Decimal;
        ExpirationDate: Date;
        LotNo: Code[30];
    begin
        //MBCICGConnectorConfig.Get();

        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", ItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if BOMComponent.IsEmpty() then
            exit;

        BOMComponent.FindSet();
        repeat
            Item.Get(BOMComponent."No.");

            if Item.Blocked then
                if not TempItem.Get(Item."No.") then begin
                    TempItem := Item;
                    TempItem.Insert();

                    Item.Blocked := false;
                    Item.Modify();
                end;

            QtyToAdjust := Round(UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, BOMComponent."Unit of Measure Code") * Qty, 0.00001);
            QtyToAdjust := QtyToAdjust * BOMComponent."Quantity per";

            if not ItemTrackingCode.Get(Item."Item Tracking Code") then
                ItemTrackingCode.Init();

            if ItemTrackingCode."Lot Specific Tracking" then
                LotNo := 'AJUSTE';//MBCICGConnectorConfig."Lot. No. Adjust";

            ExpirationDate := 0D;
            if ItemTrackingCode."Use Expiration Dates" then
                //begin
                //if ExpirationCalc <> MBCICGConnectorConfig."Expiration Calculation" then
                //    ExpirationDate := CalcDate(MBCICGConnectorConfig."Expiration Calculation", Today);
                if ExpirationCalc <> Item."Expiration Calculation" then
                    ExpirationDate := CalcDate(Item."Expiration Calculation", Today);
            //end;

            AdjustStock(Item."No.", StrSubstNo(DocumentNoLbl, Format(Today(), 0, '<Day,2><Month,2><Year,2>')), QtyToAdjust, LocationCode, '', LotNo, '', copystr(UserId, 1, 50), ExpirationDate);
        until BOMComponent.next() = 0;
    end;

    /// <summary>
    /// GetDimensionbyLocation.
    /// </summary>
    /// <param name="LocationCode">Code[20].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetDimensionbyLocation(LocationCode: Code[20]): Integer
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.Reset();
        DefaultDimension.SETRANGE("Table ID", DATABASE::Location);
        DefaultDimension.SETRANGE("No.", LocationCode);
        IF NOT DefaultDimension.ISEMPTY THEN
            EXIT(SetDimension(DefaultDimension));

        EXIT(0);
    end;

    /// <summary>
    /// SetDimension.
    /// </summary>
    /// <param name="DefaultDimension">VAR Record "Default Dimension".</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure SetDimension(var DefaultDimension: Record "Default Dimension"): Integer
    var
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" Temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        DefaultDimension.FindSet();
        REPEAT
            IF DefaultDimension."Value Posting"
              IN [DefaultDimension."Value Posting"::"Code Mandatory", DefaultDimension."Value Posting"::"Same Code", DefaultDimension."Value Posting"::" "] THEN
                IF DimVal.GET(DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code") THEN BEGIN
                    TempDimSetEntry.Init();
                    TempDimSetEntry.VALIDATE("Dimension Code", DimVal."Dimension Code");
                    TempDimSetEntry.VALIDATE("Dimension Value Code", DimVal.Code);
                    TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                    TempDimSetEntry.Insert();
                END;
        UNTIL DefaultDimension.Next() = 0;
        EXIT(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;

    /// <summary>
    /// OnAfterAdjustStockFillItemLedgerEntry.
    /// </summary>
    /// <param name="ItemJNLine">VAR Record "Item Journal Line".</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterAdjustStockFillItemLedgerEntry(var ItemJNLine: Record "Item Journal Line")
    begin
    end;

    var
        TempItem: Record Item temporary;
        DocumentNoLbl: Label 'AJ.ASSEMBLY %1', Comment = 'ESP="AJ.ENSAMBL. %1"';
        TXTSOURCELbl: Label 'IMW';
}
