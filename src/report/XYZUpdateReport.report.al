report 50999 "XYZ Update Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;


    requestpage
    {
        layout
        {
            area(Content)
            {
                group(SalesInvoice)
                {
                    Caption = 'Documentos en Borrador';

                    field(forSalesInvoiceC; forSalesInvoice)
                    {
                        Caption = 'Para documentos en borrador';
                        ToolTip = 'Para documentos en borrador';
                        ApplicationArea = All;
                    }
                    field(rangeSalesInvoiceC; rangeSalesInvoice)
                    {
                        Caption = 'Rango documentos borrador';
                        ToolTip = 'Rango documentos borrador';
                        Enabled = forSalesInvoice;
                        ApplicationArea = All;
                    }
                }
                group(PostedSalesInvoice)
                {
                    Caption = 'Documentos en Borrador';

                    field(forPostedSalesInvoiceC; forPostedSalesInvoices)
                    {
                        Caption = 'Para documentos registrados';
                        ToolTip = 'Para documentos registrados';
                        ApplicationArea = All;
                    }
                    field(rangePostedSalesInvoiceC; rangePostedSalesInvoice)
                    {
                        Caption = 'Rango documentos registrados';
                        ToolTip = 'Rango documentos registrados';
                        Enabled = forPostedSalesInvoices;
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        XYZUpdateYourRef: Codeunit "XYZ Update Your Ref.";
    begin
        XYZUpdateYourRef.setGlobals(forSalesInvoice, forPostedSalesInvoices, rangeSalesInvoice, rangePostedSalesInvoice);
        XYZUpdateYourRef.UpdateYourReference();
    end;

    var
        forSalesInvoice, forPostedSalesInvoices : Boolean;
        rangeSalesInvoice, rangePostedSalesInvoice : Code[250];


}