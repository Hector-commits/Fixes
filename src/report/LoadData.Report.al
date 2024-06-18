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
                }
            }
        }
    }

    trigger OnPostReport()
    var
        OrderHeader: Record "MBC B2B OrderHeader";
        OrderLines: Record "MBC B2B OrderLines";
        RandomText: Text[20];
        RandomNumber: Integer;
        i, j : Integer;
    begin
        if DeleteOrderHeader then begin
            OrderLines.DeleteAll();
            OrderHeader.DeleteAll();
        end;

        if CreateOrderHeaders then
            for i := 1 to NoOfRecords do begin
                OrderHeader.Init();
                RandomText := GenerateRandomText(20);
                RandomNumber := GenerateRandomNumber(1, 1000);

                OrderHeader.No := 0;
                OrderHeader.Code := GenerateRandomText(20);
                OrderHeader.UserID := 1;
                OrderHeader."Location Code" := 'AMARILLO';
                OrderHeader.Status := Enum::"MBC B2B Order Status".FromInteger(GenerateRandomNumber(0, 4));
                OrderHeader.Fecha := CurrentDateTime;
                OrderHeader.Tipo := GenerateRandomText(10);
                OrderHeader."Store Code" := 'AMARILLO';
                OrderHeader."Last Time Processed" := CurrentDateTime;

                OrderHeader.Insert();

                for j := 1 to NoOfLines do begin
                    OrderLines.Init();
                    OrderLines.No := 0;
                    OrderLines.Order := OrderHeader.No;
                    OrderLines."Item No." := GetRandomItemNo();
                    OrderLines.Quantity := GenerateRandomNumber(1, 100);
                    OrderLines.UnitofMeasure := GetRandomUnitOfMeasureCode(OrderLines."Item No.");
                    OrderLines."Vendor No." := GetRandomVendorNo();
                    OrderLines.Processed := GenerateRandomNumber(0, 1);
                    OrderLines.Location := OrderHeader."Location Code";
                    OrderLines."Item Description" := GetItemDescription(OrderLines."Item No.");
                    OrderLines."Vendor Name" := GetVendorName(OrderLines."Vendor No.");
                    OrderLines."Order Code" := OrderHeader.Code;
                    OrderLines."Last Time Processed" := CurrentDateTime;
                    OrderLines."Order type" := OrderHeader.Tipo;
                    OrderLines."Intercompany" := GenerateRandomNumber(0, 1) = 1;
                    OrderLines."Final line price" := GenerateRandomNumber(1, 1000);
                    OrderLines."Final total price" := OrderLines."Final line price" * OrderLines.Quantity;
                    OrderLines."lineComment" := GenerateRandomText(500);
                    OrderLines."Store Code" := OrderHeader."Store Code";

                    OrderLines.Insert();
                end;
            end;
    end;

    var
        CreateOrderHeaders, DeleteOrderHeader : Boolean;
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
        exit(Min + Random(Max - Min + 1));
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
