*IMPUTES VALUES TO HELPER_OOP USING DATA FROM WAVES 1998-2010
*THESE FILES ARE MERGED WITH OTHER EXPENSE DATA BY BUILD_EXIT.DO.
*BRACKET IMPUTATIONS ARE DONE USING DATA FILE CREATED BY HELPER_EXIT.DO.

****************************************************************************************

*STEPS:
*1. load data, set DK/NA/RF to missing, convert to monthly frequency
*2. convert to BASE YEAR $
*3. cap values at 15000 per month (necessary before imputing using means)
*4. impute
*5. sum expenses across helpers
*6. cap values again
*7. convert back to current wave dollars

****************************************************************************************
* 1995

use  "$loaddir/x95E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi1995 / cpiBASE)

gen helper_OOP = N2148
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if N2149==1	//month
replace helper_OOP = (52/12)  * helper_OOP if N2149==2	//week
replace helper_OOP = (365/12) * helper_OOP if N2149==3	//day
replace helper_OOP = (1/12)   * helper_OOP if N2149==5	//year
replace helper_OOP = . if (N2149==7 | N2149==8 | N2149==9) & helper_OOP != .


replace helper_OOP = min( helper_OOP , 15000 * (cpi1995 / cpiBASE)) if !missing(helper_OOP)

recode N2151 (5=1) (1=5)	//in later waves, the bracket question answers are 1. < 100 / 3.~= 100 / 5.> 100; Here: 1. > 100, 5. <= 100
helper_impute N2146 N2151

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1995 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_1995_imputed", replace

****************************************************************************************
* 1996

use  "$loaddir/x96E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi1996 / cpiBASE)

gen helper_OOP = P1686
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if P1687==1	//month
replace helper_OOP = (52/12)  * helper_OOP if P1687==2	//week
replace helper_OOP = (365/12) * helper_OOP if P1687==3	//day
replace helper_OOP = (1/12)   * helper_OOP if P1687==5	//year
replace helper_OOP = . if (P1687==7 | P1687==8 | P1687==9) & helper_OOP != .

replace helper_OOP = min( helper_OOP , 15000* (cpi1996 / cpiBASE) ) if !missing(helper_OOP)

recode P1689 (5=1) (1=5)	//in later waves, the bracket question answers are 1. < 100 / 3.~= 100 / 5.> 100; Here: 1. > 100, 5. <= 100
helper_impute P1684 P1689

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1996 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_1996_imputed", replace	

****************************************************************************************
* 1998

use  "$loaddir/x98E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi1998 / cpiBASE)

helper Q2117 Q2118
replace helper_OOP = min( helper_OOP , 15000* (cpi1998 / cpiBASE) ) if !missing(helper_OOP)

helper_impute Q2115 Q2120
rename helper_OOP helper_OOP_1


*helper's spouse
helper Q2133 Q2134
replace helper_OOP = min( helper_OOP , 15000* (cpi1998 / cpiBASE) ) if !missing(helper_OOP)
helper_impute Q2131 Q2136
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1998 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_1998_imputed", replace	


****************************************************************************************
* 2000

use  "$loaddir/x00E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2000 / cpiBASE)

helper R2120 R2121
replace helper_OOP = min( helper_OOP , 15000* (cpi2000 / cpiBASE) ) if !missing(helper_OOP)

helper_impute R2118 R2123
rename helper_OOP helper_OOP_1


*helper's spouse
helper R2146 R2147
replace helper_OOP = min( helper_OOP , 15000 * (cpi2000 / cpiBASE)) if !missing(helper_OOP)
helper_impute R2144 R2149
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000* (cpi2000 / cpiBASE) ) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers
save "$savedir/helper_exit_2000_imputed", replace	

****************************************************************************************
* 2002

use  "$loaddir/x02G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2002 / cpiBASE)

helper SG078 SG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2002 / cpiBASE) ) if !missing(helper_OOP)

helper_impute SG076 SG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2002 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_2002_imputed", replace					
						
****************************************************************************************
* 2004

use  "$loaddir/x04G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2004 / cpiBASE)

helper TG078 TG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2004 / cpiBASE) ) if !missing(helper_OOP)

helper_impute TG076 TG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000* (cpi2004 / cpiBASE) ) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_2004_imputed", replace	

****************************************************************************************
* 2006

use  "$loaddir/X06G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2006 / cpiBASE)

helper UG078 UG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2006 / cpiBASE) ) if !missing(helper_OOP)

helper_impute UG076 UG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2006 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_2006_imputed", replace	

****************************************************************************************
* 2008

use  "$loaddir/X08G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2008 / cpiBASE)

helper VG078 VG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2008 / cpiBASE) ) if !missing(helper_OOP)

helper_impute VG076 VG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000* (cpi2008 / cpiBASE) ) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_exit_2008_imputed", replace	

****************************************************************************************
* 2010

use  "$loaddir/X10G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2010 / cpiBASE)

helper WG078 WG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2010 / cpiBASE) ) if !missing(helper_OOP)

helper_impute WG076 WG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2010 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers
save "$savedir/helper_exit_2010_imputed", replace

****************************************************************************************
* 2012

use  "$loaddir/X12G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2012 / cpiBASE)

helper XG078 XG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2012 / cpiBASE) ) if !missing(helper_OOP)

helper_impute XG076 XG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2012 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers
save "$savedir/helper_exit_2012_imputed", replace

****************************************************************************************
* 2014

use  "$loaddir/X14G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_exit_all", gen(appended)
replace helper_all = helper_all * (cpi2014 / cpiBASE)

helper YG078 YG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2014 / cpiBASE) ) if !missing(helper_OOP)

helper_impute YG076 YG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2014 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers
save "$savedir/helper_exit_2014_imputed", replace

****************************************************************************************		
clear
