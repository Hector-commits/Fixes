pageextension 50999 "Load Data" extends "MBCB2BConfigurationCard"
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

        }
    }
}