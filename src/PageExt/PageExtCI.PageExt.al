pageextension 50850 "Page Ext CI" extends "Company Information"
{

    actions
    {
        addafter("Non-Payment Periods")
        {
            action(Test)
            {
                ToolTip = 'Test';
                Image = Revenue;
                ApplicationArea = All;
                Caption = 'Test';


                trigger OnAction()
                begin
                    MyFun('S64T-', 'S64T-153919');
                    MyFun('E92T-16942', 'E92T-16965');
                    MyFun('E92T-16942', 'E92T-16965');
                    MyFun('E81T-2262', 'E81T-2271');
                    MyFun('E81T-2262', 'E81T-2271');
                    MyFun('E61T-163446', 'E61T-163556');
                    MyFun('E61T-163446', 'E61T-163556');
                    MyFun('C51T-44174', 'C51T-44246');
                    MyFun('C51T-44174', 'C51T-44246');
                    MyFun('C31T-28125', 'C31T-28201');
                    MyFun('C31T-28125', 'C31T-28201');
                    MyFun('S92T-18346', 'S92T-18346');
                    MyFun('S52T-160402', 'S52T-160587');
                    MyFun('S52T-160402', 'S52T-160587');
                    MyFun('S51T-150321', 'S51T-150550');
                    MyFun('S51T-150321', 'S51T-150550');
                    MyFun('S11T-116720', 'S11T-116776');
                    MyFun('S11T-116720', 'S11T-116776');
                    MyFun('E62T-155978', 'E62T-156080');
                    MyFun('E62T-155978', 'E62T-156080');
                    MyFun('E32T-129376', 'E32T-129516');
                    MyFun('E32T-129376', 'E32T-129516');
                    MyFun('E31T-72805', 'E31T-72833');
                    MyFun('E31T-72805', 'E31T-72833');
                    MyFun('S62T-183515', 'S62T-183767');
                    MyFun('S62T-183515', 'S62T-183767');
                    MyFun('S36T-112537', 'S36T-112744');
                    MyFun('S36T-112537', 'S36T-112744');
                    MyFun('R51T-34905', 'R51T-34965');
                    MyFun('R51T-34905', 'R51T-34965');
                    MyFun('R51T-34905', 'R51T-34965');
                    MyFun('C11T-14643', 'C11T-14662');
                    MyFun('C11T-14643', 'C11T-14662');
                    MyFun('S31T-144446', 'S31T-144546');
                    MyFun('S31T-144446', 'S31T-144546');
                    MyFun('S31T-144446', 'S31T-144546');
                    MyFun('S12T-105593', 'S12T-105616');
                    MyFun('S12T-105593', 'S12T-105616');
                    MyFun('R91T-12904', 'R91T-12924');
                    MyFun('R91T-12904', 'R91T-12924');
                    MyFun('E51T-139960', 'E51T-140029');
                    MyFun('E51T-139960', 'E51T-140029');
                    MyFun('C61T-54237', 'C61T-54399');
                    MyFun('C61T-54237', 'C61T-54399');
                    MyFun('S94T-45402', 'S94T-45498');
                    MyFun('S94T-45402', 'S94T-45498');
                    MyFun('S63T-239686', 'S63T-239889');
                    MyFun('S63T-239686', 'S63T-239889');
                    MyFun('R11T-9411', 'R11T-9434');
                    MyFun('R11T-9411', 'R11T-9434');
                    MyFun('R11T-9411', 'R11T-9434');
                    MyFun('S61T-72941', 'S61T-72989');
                    MyFun('S61T-72941', 'S61T-72989');
                    MyFun('E71T-12862', 'E71T-12870');
                    MyFun('E71T-12862', 'E71T-12870');
                    MyFun('E11T-66235', 'E11T-66266');
                    MyFun('E11T-66235', 'E11T-66266');
                    MyFun('C91T-18992', 'C91T-19020');
                    MyFun('C91T-18992', 'C91T-19020');
                    MyFun('A11T-429', 'A11T-431');
                    MyFun('S93T-31341', 'S93T-31375');
                    MyFun('S93T-31341', 'S93T-31375');
                    MyFun('S93T-31341', 'S93T-31375');
                    MyFun('R61T-24783', 'R61T-24852');
                    MyFun('R61T-24783', 'R61T-24852');

                    Message('Done');
                end;
            }
        }
    }


    local procedure MyFun(NextTicket: Text[50]; LastTicket: Text[50])
    var

        ProcessedLastTicket: Boolean;

        JsonObjectTicket: JsonObject;
        JsonArrayTicket: JsonArray;
        SplitNextTicket: List of [Text];

    begin

        ProcessedLastTicket := false;

        repeat

            ProcessedLastTicket := NextTicket = LastTicket;
            if NextTicket.Contains('-') and (SplitNextTicket.Count >= 2) then begin
                SplitNextTicket := NextTicket.Split('-');
                Clear(JsonObjectTicket);
                JsonObjectTicket.Add('SERIE', SplitNextTicket.Get(1));
                JsonObjectTicket.Add('NO', SplitNextTicket.Get(2));
                JsonArrayTicket.Add(JsonObjectTicket);
            end else
                ProcessedLastTicket := true;
            NextTicket := IncStr(NextTicket);
        until ProcessedLastTicket;




    end;
}