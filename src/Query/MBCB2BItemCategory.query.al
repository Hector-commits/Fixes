query 50999 "MBC B2B Item Category"
{
    APIGroup = 'b2b';
    APIPublisher = 'im';
    APIVersion = 'v1.0';
    EntityName = 'itemCategoryDrillDown';
    EntitySetName = 'itemCategoriesDrillDown';
    QueryType = API;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(itemCategory; "Item Category")
        {
            column(code; "Code") { }
            column(description; Description) { }

            dataitem(item; Item)
            {
                DataItemLink = "Item Category Code" = itemCategory.Code;
                SqlJoinType = InnerJoin;

                //column(no; "No.") { }
                //column(itemDescription; Description) { }

                dataitem(valueEntry; "Value Entry")
                {
                    DataItemLink = "Item No." = item."No.";
                    DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Purchase | Transfer);
                    SqlJoinType = InnerJoin;

                    column(locationCode; "Location Code") { }
                    column(quantity; "Valued Quantity")
                    {
                        Method = Sum;
                    }
                    column(costAmountActual; "Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }
                    column(costAmountExpected; "Cost Amount (Expected)")
                    {
                        Method = Sum;
                    }
                    column(itemLedgerEntryType; "Item Ledger Entry Type")
                    {

                    }
                    column(postingDateMonth; "Posting Date")
                    {
                        Method = Month;
                    }
                    filter(postingDateFilter; "Posting Date")
                    {
                        Caption = 'DateFilter', Locked = true;
                    }
                }
            }
        }
    }
}

