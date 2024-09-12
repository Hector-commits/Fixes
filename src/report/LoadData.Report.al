report 50999 "Load Data"
{
    ProcessingOnly = true;
    Caption = 'Create Random Orders';

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Group)
                {
                    field(CreateOrderHeadersControl; CreateOrderHeaders)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Order Headers';
                        ToolTip = 'Enable to create order headers.';
                    }
                    field(DeleteOrderHeaderControl; DeleteOrderHeader)
                    {
                        Enabled = CreateOrderHeaders;
                        ApplicationArea = All;
                        Caption = 'Delete Order Headers';
                        ToolTip = 'Enable to delete order headers.';
                    }
                    field(NoOfRecordsControl; NoOfRecords)
                    {
                        Enabled = CreateOrderHeaders;
                        ApplicationArea = All;
                        Caption = 'Number of Records to Create';
                        ToolTip = 'Enter the number of records to create.';
                    }
                    field(NoOfLinesControl; NoOfLines)
                    {
                        Enabled = CreateOrderHeaders;
                        ApplicationArea = All;
                        Caption = 'Number of Lines per Order';
                        ToolTip = 'Enter the number of lines to create per order.';
                    }
                    field(linkDocuments; linkDocs)
                    {
                        Enabled = CreateOrderHeaders;
                        ApplicationArea = All;
                        Caption = 'Link Documents';
                        ToolTip = 'Enable to link documents to the order lines.';

                    }

                }
            }
        }
    }

    trigger OnPostReport()
    var
        OrderHeader: Record "MBC EPR Order Header";
        OrderLines: Record "MBC EPR Order Lines";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransLine: Record "Transfer Line";
        RandomText: Text[20];
        RandomNumber: Integer;
        i, j : Integer;
    begin
        /*
        if DeleteOrderHeader then begin
            OrderLines.DeleteAll();
            OrderHeader.DeleteAll();
        end;

        if CreateOrderHeaders then
            for i := 1 to NoOfRecords do begin
                OrderHeader.Init();
                RandomText := GenerateRandomText(20);
                RandomNumber := GenerateRandomNumber(1, 1000);

                OrderHeader."No." := 0;
                OrderHeader.Code := GenerateRandomText(20);
                OrderHeader.UserID := 1;
                OrderHeader."Store Code" := 'ESTE';
                OrderHeader.Status := Enum::"MBC EPR Order Status".FromInteger(GenerateRandomNumber(0, 4));
                OrderHeader."Posting Date" := CurrentDateTime;
                OrderHeader."Order Type" := Enum::"MBC EPR Order Type".FromInteger(GenerateRandomNumber(0, 3));
                OrderHeader."Store Code" := 'ESTE';
                OrderHeader."Last Time Processed" := CurrentDateTime;

                OrderHeader.Insert();

                if linkDocs then begin

                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetRandomPurchaseHeaderNo());
                    PurchaseHeader."Vendor Order No." := OrderHeader.Code;
                    PurchaseHeader.Modify();

                    TransferHeader.Get(GetRandomTransferHeaderNo());
                    TransferHeader."External Document No." := OrderHeader.Code;
                    TransferHeader.Modify();

                    PurchRcptHeader.Get(GetRandomPurchRcptHeaderNo());
                    PurchRcptHeader."Vendor Order No." := OrderHeader.Code;
                    PurchRcptHeader.Modify();

                    TransferReceiptHeader.Get(GetRandomTransferReceiptHeaderNo());
                    TransferReceiptHeader."External Document No." := OrderHeader.Code;
                    TransferReceiptHeader.Modify();

                end;


                for j := 1 to NoOfLines do begin
                    OrderLines.Init();
                    OrderLines.No := 0;
                    OrderLines."Order No." := OrderHeader."No.";
                    OrderLines."Item No." := GetRandomItemNo();
                    OrderLines.Quantity := GenerateRandomNumber(1, 100);
                    OrderLines.UnitofMeasure := GetRandomUnitOfMeasureCode(OrderLines."Item No.");
                    OrderLines."Vendor No." := GetRandomVendorNo();
                    OrderLines.Processed := GenerateRandomNumber(0, 1);
                    OrderLines."Location Code" := OrderHeader."Store Code";
                    OrderLines."Item Description" := GetItemDescription(OrderLines."Item No.");
                    OrderLines."Vendor Name" := GetVendorName(OrderLines."Vendor No.");
                    OrderLines."Order Code" := OrderHeader.Code;
                    OrderLines."Last Time Processed" := CurrentDateTime;
                    OrderLines."Order type" := OrderHeader."Order Type";
                    OrderLines."Intercompany" := GenerateRandomNumber(0, 1) = 1;
                    OrderLines."Final line price" := GenerateRandomNumber(1, 1000);
                    OrderLines."Final total price" := OrderLines."Final line price" * OrderLines.Quantity;
                    OrderLines."lineComment" := GenerateRandomText(500);
                    OrderLines."Store Code" := OrderHeader."Store Code";

                    OrderLines.Insert();
                end;
            end;
        */
        /*
        TransferHeader.Reset();
        TransferHeader.Init();
        TransferHeader."No." := '';
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", 'ESTE');
        TransferHeader.Validate("Transfer-to Code", 'OESTE');
        //   TransferHeader."Direct Transfer" := true;
        TransferHeader.Validate("External Document No.", 'DOC');
        TransferHeader.Modify();


        transline.Init();

        transline.Validate("Document No.", TransferHeader."No.");
        transline.validate("Line No.", 10000); //???
        transline.validate("Item No.", '1968-S');
        transline.validate(Quantity, -1);

        transline.Insert(true);

        transline.Reset();
        //Transfers.SETRANGE("Entry No.", eOrden."Table Entry No.");
        //Transfers.SetRange("Status BC", Transfers."Status BC"::Pending); //CAMBIAR A OPTION? 0
        //Transfers.SETRANGE("ID Company", eOrden."ID ICG Company");
        */
        transline.setfilter(quantity, '<%1', 0);
        IF not transline.ISEMPTY THEN
            Error('No se permiten cantidades negativas en transferencias');

        transline.SetRange(Quantity);
        transline.Findset();
        Message(Format(transline));

    end;

    var
        CreateOrderHeaders, DeleteOrderHeader, linkDocs, linkRcpts : Boolean;
        NoOfRecords, NoOfLines : Integer;

    local procedure GenerateRandomText(Length: Integer): Text[500]
    var
        Characters: Text[80];
        RandomText: Text[500];
        i: Integer;
        RandomIndex: Integer;
    begin
        Characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        for i := 1 to Length do begin
            RandomIndex := GenerateRandomNumber(1, StrLen(Characters));
            RandomText := RandomText + Characters[RandomIndex];
        end;
        exit(RandomText);
    end;

    local procedure GenerateRandomNumber(Min: Integer; Max: Integer): Integer
    begin
        Randomize();
        exit(Min + Random(Max - Min));
    end;

    local procedure GetRandomItemNo(): Code[20]
    var
        Item: Record Item;
        Count: Integer;
        RandomIndex: Integer;
    begin
        Item.SetRange("No.");
        if Item.FindSet then begin
            // Contar el número total de ítems
            Count := 0;
            repeat
                Count += 1;
            until Item.Next() = 0;

            // Obtener un índice aleatorio dentro del rango de ítems
            RandomIndex := GenerateRandomNumber(1, Count);

            // Volver a recorrer para obtener el ítem en el índice aleatorio
            Item.FindSet;
            for Count := 1 to RandomIndex do
                Item.Next();

            exit(Item."No.");
        end;
    end;

    local procedure GetRandomVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
        Count: Integer;
        RandomIndex: Integer;
    begin
        Vendor.SetRange("No.");
        if Vendor.FindSet then begin
            // Contar el número total de vendors
            Count := 0;
            repeat
                Count += 1;
            until Vendor.Next() = 0;

            // Obtener un índice aleatorio dentro del rango de vendors
            RandomIndex := GenerateRandomNumber(1, Count);

            // Volver a recorrer para obtener el vendor en el índice aleatorio
            Vendor.FindSet;
            for Count := 1 to RandomIndex do
                Vendor.Next();

            exit(Vendor."No.");
        end;
    end;

    local procedure GetRandomPurchaseHeaderNo(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        Count: Integer;
        RandomIndex: Integer;
    begin
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.");
        if PurchaseHeader.FindSet then begin
            // Count the total number of Purchase Headers
            Count := 0;
            repeat
                Count += 1;
            until PurchaseHeader.Next() = 0;

            // Get a random index within the range of Purchase Headers
            RandomIndex := GenerateRandomNumber(1, Count);

            // Loop again to get the Purchase Header at the random index
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.FindSet;
            for Count := 1 to RandomIndex do
                PurchaseHeader.Next();

            exit(PurchaseHeader."No.");
        end;
    end;

    local procedure GetRandomTransferHeaderNo(): Code[20]
    var
        TransferHeader: Record "Transfer Header";
        Count: Integer;
        RandomIndex: Integer;
    begin
        TransferHeader.SetRange("No.");
        if TransferHeader.FindSet then begin
            // Count the total number of Transfer Headers
            Count := 0;
            repeat
                Count += 1;
            until TransferHeader.Next() = 0;

            // Get a random index within the range of Transfer Headers
            RandomIndex := GenerateRandomNumber(1, Count);

            // Loop again to get the Transfer Header at the random index
            TransferHeader.FindSet;
            for Count := 1 to RandomIndex do
                TransferHeader.Next();

            exit(TransferHeader."No.");
        end;
    end;

    local procedure GetRandomPurchRcptHeaderNo(): Code[20]
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Count: Integer;
        RandomIndex: Integer;
    begin
        PurchRcptHeader.SetRange("No.");
        if PurchRcptHeader.FindSet then begin
            // Count the total number of Purchase Receipt Headers
            Count := 0;
            repeat
                Count += 1;
            until PurchRcptHeader.Next() = 0;

            // Get a random index within the range of Purchase Receipt Headers
            RandomIndex := GenerateRandomNumber(1, Count);

            // Loop again to get the Purchase Receipt Header at the random index
            PurchRcptHeader.FindSet;
            for Count := 1 to RandomIndex do
                PurchRcptHeader.Next();

            exit(PurchRcptHeader."No.");
        end;
    end;

    local procedure GetRandomTransferReceiptHeaderNo(): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        Count: Integer;
        RandomIndex: Integer;
    begin
        TransferReceiptHeader.SetRange("No.");
        if TransferReceiptHeader.FindSet then begin
            // Count the total number of Transfer Receipt Headers
            Count := 0;
            repeat
                Count += 1;
            until TransferReceiptHeader.Next() = 0;

            // Get a random index within the range of Transfer Receipt Headers
            RandomIndex := GenerateRandomNumber(1, Count);

            // Loop again to get the Transfer Receipt Header at the random index
            TransferReceiptHeader.FindSet;
            for Count := 1 to RandomIndex do
                TransferReceiptHeader.Next();

            exit(TransferReceiptHeader."No.");
        end;
    end;

    local procedure GetRandomUnitOfMeasureCode(ItemNo: Code[20]): Code[20]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        if ItemUnitOfMeasure.FindFirst() then
            exit(ItemUnitOfMeasure.Code);

    end;

    local procedure GetItemDescription(ItemNo: Code[20]): Text[250]
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item.Description);
    end;

    local procedure GetVendorName(VendorNo: Code[20]): Text[250]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(Vendor.Name);
    end;

}
