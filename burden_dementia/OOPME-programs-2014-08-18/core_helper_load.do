*LOADS AND STACKS ALL HELPER DATA, AFTER CONVERTING PAYMENTS TO MONTHLY FREQUENCY
*AND TO BASE YEAR DOLLARS.

//core 1992 and 1994 do not have helper files.

/* *********************************************************************** */
* 1993

use  "$loaddir/BHP21.dta" , clear

by HHID PN, sort: gen numhelpers = _N		//rrd: assumes no obs if no hoelper

/*
V996           [HELPER]    E64. HELPER: $ R PAY
          E64. (Not counting expenses paid by Medicaid or insurance,) about
               how much did you [and your (husband/wife/ partner)] end up
               paying HELPERn for the last month?
               
       //Note: total reflects spending by R and SP
*/

gen helper_OOP = V996
replace helper_OOP = . if helper_OOP == 9997 | helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if V997==1	//month
replace helper_OOP = (52/12)  * helper_OOP if V997==2	//week
replace helper_OOP = (365/12) * helper_OOP if V997==3	//day
replace helper_OOP = (1/12)   * helper_OOP if V997==5	//year
replace helper_OOP = . if (V997==7 | V997==8 | V997==9) & helper_OOP != .

replace helper_OOP = helper_OOP * (cpiBASE / cpi1993)

save "$savedir/helper_core_1993.dta" , replace

clear

/* *********************************************************************** */
* 1995

use  "$loaddir/A95E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

gen helper_OOP = D2148
replace helper_OOP = . if helper_OOP == 9997 | helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if D2149==1	//month
replace helper_OOP = (52/12)  * helper_OOP if D2149==2	//week
replace helper_OOP = (365/12) * helper_OOP if D2149==3	//day
replace helper_OOP = (1/12)   * helper_OOP if D2149==5	//year
replace helper_OOP = . if (D2149==7 | D2149==8 | D2149==9) & helper_OOP != .

replace helper_OOP = helper_OOP * (cpiBASE / cpi1995)

save "$savedir/helper_core_1995.dta" , replace
clear

/* *********************************************************************** */
* 1996

use  "$loaddir/H96E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

gen helper_OOP_1 = E2132
replace helper_OOP_1 = . if helper_OOP_1 == 9998 | helper_OOP_1 == 9999

replace helper_OOP_1 = 1 		* helper_OOP_1 if E2133==1	//month
replace helper_OOP_1 = (52/12)  * helper_OOP_1 if E2133==2	//week
replace helper_OOP_1 = (365/12) * helper_OOP_1 if E2133==3	//day
replace helper_OOP_1 = (1/12)   * helper_OOP_1 if E2133==5	//year
replace helper_OOP_1 = . if (E2133==7 | E2133==8 | E2133==9) & helper_OOP_1 != .

*repeat for helper's spouse
gen helper_OOP_2 = E2151
replace helper_OOP_2 = . if helper_OOP_2 == 9998 | helper_OOP_2 == 9999

replace helper_OOP_2 = 1 		* helper_OOP_2 if E2152==1	//month
replace helper_OOP_2 = (52/12)  * helper_OOP_2 if E2152==2	//week
replace helper_OOP_2 = (365/12) * helper_OOP_2 if E2152==3	//day
replace helper_OOP_2 = (1/12)   * helper_OOP_2 if E2152==5	//year
replace helper_OOP_2 = . if (E2152==7 | E2152==8 | E2152==9) & helper_OOP_2 != .

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?
replace helper_OOP = helper_OOP * (cpiBASE / cpi1996)

save "$savedir/helper_core_1996.dta" , replace
clear

/* *********************************************************************** */
* 1998

use  "$loaddir/H98E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

helper F2651 F2652
rename helper_OOP helper_OOP_1

*repeat for helper's spouse
helper F2667 F2668
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?
replace helper_OOP = helper_OOP * (cpiBASE / cpi1998)

save "$savedir/helper_core_1998.dta" , replace
clear


/* *********************************************************************** */
* 2000

use  "$loaddir/H00E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

helper G2959 G2960
rename helper_OOP helper_OOP_1

*repeat for helper's spouse
helper G2985 G2986
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?
replace helper_OOP = helper_OOP * (cpiBASE / cpi2000)

save "$savedir/helper_core_2000.dta" , replace
clear


/* *********************************************************************** */
* 2002

use  "$loaddir/H02G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper HG078 HG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2002)
save "$savedir/helper_core_2002.dta" , replace
clear

/* *********************************************************************** */
* 2004

use  "$loaddir/H04G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper JG078 JG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2004)
save "$savedir/helper_core_2004.dta" , replace
clear

/* *********************************************************************** */
* 2006

use  "$loaddir/H06G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper KG078 KG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2006)
save "$savedir/helper_core_2006.dta" , replace
clear


/* *********************************************************************** */
* 2008

use  "$loaddir/H08G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper LG078 LG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2008)
save "$savedir/helper_core_2008.dta" , replace

/* *********************************************************************** */
* 2010

use  "$loaddir/H10G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper MG078 MG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2010)
save "$savedir/helper_core_2010.dta" , replace

/* *********************************************************************** */
* 2012

use  "$loaddir/H12G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper NG078 NG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2012)
save "$savedir/helper_core_2012.dta" , replace


/* *********************************************************************** */

/* *********************************************************************** */
* 2014

use  "$loaddir/H14G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper OG078 OG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2014)
save "$savedir/helper_core_2014.dta" , replace


/* *********************************************************************** */

append using "$savedir/helper_core_2012.dta"
append using "$savedir/helper_core_2010.dta"
append using "$savedir/helper_core_2008.dta"
append using "$savedir/helper_core_2006.dta"
append using "$savedir/helper_core_2004.dta"
append using "$savedir/helper_core_2002.dta"
append using "$savedir/helper_core_2000.dta"
append using "$savedir/helper_core_1998.dta"
append using "$savedir/helper_core_1996.dta"
append using "$savedir/helper_core_1995.dta"
//not using helper_core_1993.dta b/c spending includes both R and SP; core 1994 does not have a helper file.

keep numhelpers helper_OOP
drop if missing(helper_OOP)
rename helper_OOP helper_all

*cap at 15,000 / month:
replace helper_all = min( helper_all, 15000 ) if !missing(helper_all)

save "$savedir/helper_core_all.dta" , replace

/* *********************************************************************** */

rm "$savedir/helper_core_2014.dta"
rm "$savedir/helper_core_2012.dta"
rm "$savedir/helper_core_2010.dta"
rm "$savedir/helper_core_2008.dta"
rm "$savedir/helper_core_2006.dta"
rm "$savedir/helper_core_2004.dta"
rm "$savedir/helper_core_2002.dta"
rm "$savedir/helper_core_2000.dta"
rm "$savedir/helper_core_1998.dta"
rm "$savedir/helper_core_1996.dta"
rm "$savedir/helper_core_1995.dta"
rm "$savedir/helper_core_1993.dta"
