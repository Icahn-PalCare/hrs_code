*LOADS AND STACKS ALL HELPER DATA, AFTER CONVERTING PAYMENTS TO MONTHLY FREQUENCY
*AND TO BASE YEAR DOLLARS.

/* *********************************************************************** */
* 1995

use  "$loaddir/x95E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

gen helper_OOP = N2148
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if N2149==1	//month
replace helper_OOP = (52/12)  * helper_OOP if N2149==2	//week
replace helper_OOP = (365/12) * helper_OOP if N2149==3	//day
replace helper_OOP = (1/12)   * helper_OOP if N2149==5	//year
replace helper_OOP = . if (N2149==7 | N2149==8 | N2149==9) & helper_OOP != .

replace helper_OOP = helper_OOP * (cpiBASE / cpi1995)

save "$savedir/helper_exit_1995.dta" , replace
clear

/* *********************************************************************** */
* 1996

use  "$loaddir/x96E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

gen helper_OOP = P1686
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if P1687==1	//month
replace helper_OOP = (52/12)  * helper_OOP if P1687==2	//week
replace helper_OOP = (365/12) * helper_OOP if P1687==3	//day
replace helper_OOP = (1/12)   * helper_OOP if P1687==5	//year
replace helper_OOP = . if (P1687==7 | P1687==8 | P1687==9) & helper_OOP != .

replace helper_OOP = helper_OOP * (cpiBASE / cpi1996)

save "$savedir/helper_exit_1996.dta" , replace
clear


/* *********************************************************************** */
* 1998

use  "$loaddir/x98E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

helper Q2117 Q2118
rename helper_OOP helper_OOP_1

*repeat for helper's spouse
helper Q2133 Q2134
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?
replace helper_OOP = helper_OOP * (cpiBASE / cpi1998)

save "$savedir/helper_exit_1998.dta" , replace
clear


/* *********************************************************************** */
* 2000

use  "$loaddir/x00E_HP.dta" , clear

by HHID PN, sort: gen numhelpers = _N

helper R2120 R2121
rename helper_OOP helper_OOP_1

*repeat for helper's spouse
helper R2146 R2147
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?
replace helper_OOP = helper_OOP * (cpiBASE / cpi2000)

save "$savedir/helper_exit_2000.dta" , replace
clear


/* *********************************************************************** */
* 2002

use  "$loaddir/x02G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper SG078 SG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2002)
save "$savedir/helper_exit_2002.dta" , replace
clear

/* *********************************************************************** */
* 2004

use  "$loaddir/x04G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper TG078 TG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2004)
save "$savedir/helper_exit_2004.dta" , replace
clear

/* *********************************************************************** */
* 2006

use  "$loaddir/X06G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper UG078 UG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2006)
save "$savedir/helper_exit_2006.dta" , replace
clear

/* *********************************************************************** */
* 2008

use  "$loaddir/X08G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper VG078 VG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2008)
save "$savedir/helper_exit_2008.dta" , replace

/* *********************************************************************** */
* 2010

use  "$loaddir/X10G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper WG078 WG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2010)
save "$savedir/helper_exit_2010.dta" , replace

/* *********************************************************************** */
* 2012

use  "$loaddir/X12G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper XG078 XG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2012)
save "$savedir/helper_exit_2012.dta" , replace


/* *********************************************************************** */
* 2014

use  "$loaddir/X14G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
helper YG078 YG079
replace helper_OOP = helper_OOP * (cpiBASE / cpi2014)
save "$savedir/helper_exit_2014.dta" , replace


/* *********************************************************************** */

append using "$savedir/helper_exit_2012.dta"
append using "$savedir/helper_exit_2010.dta"
append using "$savedir/helper_exit_2008.dta"
append using "$savedir/helper_exit_2006.dta"
append using "$savedir/helper_exit_2004.dta"
append using "$savedir/helper_exit_2002.dta"
append using "$savedir/helper_exit_2000.dta"
append using "$savedir/helper_exit_1998.dta"
append using "$savedir/helper_exit_1996.dta"
append using "$savedir/helper_exit_1995.dta"

keep numhelpers helper_OOP
drop if missing(helper_OOP)
rename helper_OOP helper_all

*cap at 15,000 / month:
replace helper_all = min( helper_all, 15000 ) if !missing(helper_all)

save "$savedir/helper_exit_all.dta" , replace

/* *********************************************************************** */

clear

rm "$savedir/helper_exit_2014.dta"
rm "$savedir/helper_exit_2012.dta"
rm "$savedir/helper_exit_2010.dta"
rm "$savedir/helper_exit_2008.dta"
rm "$savedir/helper_exit_2006.dta"
rm "$savedir/helper_exit_2004.dta"
rm "$savedir/helper_exit_2002.dta"
rm "$savedir/helper_exit_2000.dta"
rm "$savedir/helper_exit_1998.dta"
rm "$savedir/helper_exit_1996.dta"
rm "$savedir/helper_exit_1995.dta"
