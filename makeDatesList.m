function [Num_year, Num_mnth, DATES] = makeDatesList(BGNYEAR, ENDYEAR, BGNMNTH, ENDMNTH)

    Num_year = ENDYEAR - BGNYEAR + 1;
    Num_mnth = 12*(Num_year) - (11 - ENDMNTH + BGNMNTH);
    DATES = cell(Num_mnth, 2);
    if BGNYEAR == ENDYEAR % for the cases less than a year
        for I = 1:Num_mnth
            mnth_c = BGNMNTH+ I - 1;
            DATES{I, 1} = sprintf('%u%02.f%02.f', BGNYEAR, mnth_c, 1);
            DATES{I, 2} = sprintf('%u%02.f%02.f', BGNYEAR, mnth_c, eomday(BGNYEAR, mnth_c));
        end
    else
        for J = 1:Num_mnth % for the cases not less than a year
        
            % for the first year
            if J <= 13 - BGNMNTH 
                mnth_c = BGNMNTH + J -1;
                DATES{J, 1} = sprintf('%u%02.f%02.f', BGNYEAR, mnth_c, 1);
                DATES{J, 2} = sprintf('%u%02.f%02.f', BGNYEAR, mnth_c, eomday(BGNYEAR, mnth_c));

            % for the last year
            elseif J >= Num_mnth - ENDMNTH + 1
                mnth_c = mod(J + BGNMNTH - 1, 12);
                if mnth_c == 0
                    mnth_c = 12;
                end
                DATES{J, 1} = sprintf('%u%02.f%02.f', ENDYEAR, mnth_c, 1);
                DATES{J, 2} = sprintf('%u%02.f%02.f', ENDYEAR, mnth_c, eomday(ENDYEAR, mnth_c));            

            % for other years
            else
                mnth_c = mod(J + BGNMNTH - 1, 12);
                if mnth_c == 0
                    mnth_c = 12;
                end
                year_c = BGNYEAR + fix((J + BGNMNTH - 2) / 12);
                DATES{J, 1} = sprintf('%u%02.f%02.f', year_c, mnth_c, 1);
                DATES{J, 2} = sprintf('%u%02.f%02.f', year_c,mnth_c, eomday(year_c, mnth_c));                  

            end
        end
    end
end