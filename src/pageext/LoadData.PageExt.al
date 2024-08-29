pageextension 50999 "Load Data" extends "MBC EPR Setup"
{
    actions
    {
        addfirst(Creation)
        {
            action(LoadTestData)
            {

                ApplicationArea = All;
                Caption = 'Load Test Data';
                Image = Database;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Load test data into the system.';

                trigger OnAction()
                var
                    LoadData: Report "Load Data";
                begin
                    LoadData.Run();
                end;
            }
            action(CheckPostCode)
            {

                ApplicationArea = All;
                Caption = 'Check Post Code';
                Image = Database;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Checking post code thing.';

                trigger OnAction()

                begin
                    //Message('Method 1 @ + description' + Format(checkExistingPostCode('IT', '53100', 'siena (si)', 'SIENA')));
                    Message('Method substitute with setfilter' + Format(checkExistingPostCode2('IT', '53100', 'siena (si)', 'SIENA')));
                end;
            }

        }
    }
    local procedure checkExistingPostCode(CountryCode: Code[10]; PtCode: Code[20]; CountyCode: Text[30]; CityCode: Text[30]): Boolean
    var
        PostCode: Record "Post Code";
        PostCodeErrorLbl: Label 'Post Code %1 does not exist for County %2, City %3, Country %4.', Comment = 'ESP="El código postal %1 no existe para el Condado %2, Ciudad %3, País %4."';
    begin
        PostCode.SetRange("Country/Region Code", CountryCode);
        PostCode.SetRange(Code, PtCode);
        PostCode.SetFilter(County, '@' + CountyCode);
        PostCode.SetFilter(City, '@' + CityCode);
        if PostCode.IsEmpty() then
            Error(PostCodeErrorLbl, PtCode, CountyCode, CityCode, CountryCode);

        exit(true);
    end;

    local procedure checkExistingPostCode2(CountryCode: Code[10]; PtCode: Code[20]; CountyCode: Text[30]; CityCode: Text[30]): Boolean
    var
        PostCode: Record "Post Code";
        PostCodeErrorLbl: Label 'Post Code %1 does not exist for County %2, City %3, Country %4.', Comment = 'ESP="El código postal %1 no existe para el Condado %2, Ciudad %3, País %4."';
    begin
        PostCode.SetRange("Country/Region Code", CountryCode);
        PostCode.SetRange(Code, PtCode);
        PostCode.SetFilter(County, '%1', '@' + CountyCode);
        PostCode.SetFilter(City, '%1', '@' + CityCode);
        if PostCode.IsEmpty() then
            Error(PostCodeErrorLbl, PtCode, CountyCode, CityCode, CountryCode);

        exit(true);
    end;
}