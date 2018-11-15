*IMPUTES VALUES TO HELPER_OOP USING DATA FROM WAVES 1998-2010
*THESE FILES ARE MERGED WITH OTHER EXPENSE DATA BY BUILD_core.DO.
*BRACKET IMPUTATIONS ARE DONE USING DATA FILE CREATED BY HELPER_core.DO.

****************************************************************************************

*STEPS:
*1. load data, set DK/NA/RF to missing, convert to monthly frequency (rrd: this repeats _load program)
*2. convert to BASE YEAR $
*3. cap values at 15000 per month (necessary before imputing using means)
*4. impute
*5. sum expenses across helpers
*6. cap values again
*7. convert back to current wave dollars

****************************************************************************************
* 1993

use  "$loaddir/BHP21.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi1993 / cpiBASE)						//rrd: converting all to 93 dollars, moved from line 46 for proper imputation

gen helper_OOP = V996
replace helper_OOP = . if helper_OOP == 9997 | helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if V997==1	//month
replace helper_OOP = (52/12)  * helper_OOP if V997==2	//week
replace helper_OOP = (365/12) * helper_OOP if V997==3	//day
replace helper_OOP = (1/12)   * helper_OOP if V997==5	//year
replace helper_OOP = . if (V997==7 | V997==8 | V997==9) & helper_OOP != .

*replace helper_OOP = helper_OOP * (cpiBASE / cpi1993)					//no longer need this
replace helper_OOP = min( helper_OOP , 15000 * (cpi1993 / cpiBASE)) if !missing(helper_OOP)		//rrd: every line from here need not be computed agaun! all info already in _all

recode V998 (5=1) (1=5)	//in later waves, the bracket question answers are 1. < 100 / 3.~= 100 / 5.> 100; Here: 1. > 100, 5. <= 100
helper_impute V994 V998			//rrd: program should be modified to have 100 adjusted for inflaction!!! (else we underestimate)

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000* (cpi1993 / cpiBASE) ) if !missing(helper_OOP)		//rrd: before capped helper at 15000 per helper, now for all
//rrd: used to have converting to real here
keep HHID PN helper_OOP numhelpers numpaidhelpers

ren helper_OOP helper_OOP93								//rename here because helper not comparable with other waves if total reflects spending by R+SP
ren numhelpers numhelpers93
ren numpaidhelpers numpaidhelpers93

save "$savedir/helper_core_1993_imputed", replace

****************************************************************************************
* 1995

use  "$loaddir/A95E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)

gen helper_OOP = D2148
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if D2149==1	//month
replace helper_OOP = (52/12)  * helper_OOP if D2149==2	//week
replace helper_OOP = (365/12) * helper_OOP if D2149==3	//day
replace helper_OOP = (1/12)   * helper_OOP if D2149==5	//year
replace helper_OOP = . if (D2149==7 | D2149==8 | D2149==9) & helper_OOP != .

*replace helper_OOP = helper_OOP * (cpiBASE / cpi1995)
replace helper_OOP = min( helper_OOP , 15000* (cpi1995 / cpiBASE) ) if !missing(helper_OOP)
replace helper_all = helper_all * (cpi1995 / cpiBASE)

recode D2151 (5=1) (1=5)	//in later waves, the bracket question answers are 1. < 100 / 3.~= 100 / 5.> 100; Here: 1. > 100, 5. <= 100
helper_impute D2146 D2151

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1995 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers	
save "$savedir/helper_core_1995_imputed", replace

****************************************************************************************
* 1996

use  "$loaddir/H96E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi1996 / cpiBASE)

gen helper_OOP = E2132
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if E2133==1	//month
replace helper_OOP = (52/12)  * helper_OOP if E2133==2	//week
replace helper_OOP = (365/12) * helper_OOP if E2133==3	//day
replace helper_OOP = (1/12)   * helper_OOP if E2133==5	//year
replace helper_OOP = . if (E2133==7 | E2133==8 | E2133==9) & helper_OOP != .

*replace helper_OOP = helper_OOP * (cpiBASE / cpi1996)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1996 / cpiBASE)) if !missing(helper_OOP)

recode E2135 (5=1) (1=5)	//in later waves, the bracket question answers are 1. < 100 / 3.~= 100 / 5.> 100; Here: 1. > 100, 5. <= 100
helper_impute E2130 E2135
rename helper_OOP helper_OOP_1

*helper's spouse
gen helper_OOP = E2151
replace helper_OOP = . if helper_OOP == 9998 | helper_OOP == 9999

replace helper_OOP = 1 		  * helper_OOP if E2152==1	//month
replace helper_OOP = (52/12)  * helper_OOP if E2152==2	//week
replace helper_OOP = (365/12) * helper_OOP if E2152==3	//day
replace helper_OOP = (1/12)   * helper_OOP if E2152==5	//year
replace helper_OOP = . if (E2152==7 | E2152==8 | E2152==9) & helper_OOP != .

*replace helper_OOP = helper_OOP * (cpiBASE / cpi1996)
replace helper_OOP = min( helper_OOP , 15000 * (cpi1996 / cpiBASE)) if !missing(helper_OOP)

recode E2154 (5=1) (1=5)
helper_impute E2149 E2154
rename helper_OOP helper_OOP_2

*sum helper and helper's spouse
egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)

*cap expenses
replace helper_OOP = min( helper_OOP , 15000 * (cpi1996 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_1996_imputed", replace

****************************************************************************************
* 1998

use  "$loaddir/H98E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi1998 / cpiBASE)

helper F2651 F2652
replace helper_OOP = min( helper_OOP , 15000* (cpi1998 / cpiBASE)) if !missing(helper_OOP)
helper_impute F2649 F2654
rename helper_OOP helper_OOP_1

*helper's spouse
helper F2667 F2668
replace helper_OOP = min( helper_OOP , 15000* (cpi1998 / cpiBASE) ) if !missing(helper_OOP)
helper_impute F2665 F2670
rename helper_OOP helper_OOP_2

*sum helper and helper's spouse
egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?

*sum expenses across helpers (within same individual)
drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)

*cap expenses
replace helper_OOP = min( helper_OOP , 15000 * (cpi1998 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_1998_imputed", replace	


****************************************************************************************
* 2000

use  "$loaddir/H00E_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2000 / cpiBASE)

helper G2959 G2960
replace helper_OOP = min( helper_OOP , 15000 * (cpi2000 / cpiBASE)) if !missing(helper_OOP)
helper_impute G2957 G2962
rename helper_OOP helper_OOP_1

*helper's spouse
helper G2985 G2986
replace helper_OOP = min( helper_OOP , 15000 * (cpi2000 / cpiBASE)) if !missing(helper_OOP)
helper_impute G2983 G2988
rename helper_OOP helper_OOP_2

egen helper_OOP = rowtotal( helper_OOP_1 helper_OOP_2 ), missing
drop helper_OOP_?

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2000 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2000_imputed", replace	

****************************************************************************************
* 2002

use  "$loaddir/H02G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2002 / cpiBASE)

helper HG078 HG079
replace helper_OOP = min( helper_OOP , 15000 * (cpi2002 / cpiBASE) ) if !missing(helper_OOP)
helper_impute HG076 HG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2002 / cpiBASE) ) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2002_imputed", replace					
						
****************************************************************************************
* 2004

use  "$loaddir/H04G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2004 / cpiBASE)

helper JG078 JG079
replace helper_OOP = min( helper_OOP , 15000 * (cpi2004 / cpiBASE)) if !missing(helper_OOP)
helper_impute JG076 JG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2004 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2004_imputed", replace	

****************************************************************************************
* 2006

use  "$loaddir/H06G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2006 / cpiBASE)

helper KG078 KG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2006 / cpiBASE) ) if !missing(helper_OOP)
helper_impute KG076 KG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2006 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2006_imputed", replace	

****************************************************************************************
* 2008

use  "$loaddir/H08G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2008 / cpiBASE)

helper LG078 LG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2008 / cpiBASE) ) if !missing(helper_OOP)
helper_impute LG076 LG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2008 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2008_imputed", replace	

****************************************************************************************
* 2010

use  "$loaddir/H10G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2010 / cpiBASE)

helper MG078 MG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2010 / cpiBASE)) if !missing(helper_OOP)
helper_impute MG076 MG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2010 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2010_imputed", replace

****************************************************************************************
* 2012

use  "$loaddir/H12G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2012 / cpiBASE)

helper NG078 NG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2012 / cpiBASE)) if !missing(helper_OOP)
helper_impute NG076 NG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2012 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2012_imputed", replace


****************************************************************************************		

* 2014

use  "$loaddir/H14G_HP.dta" , clear
by HHID PN, sort: gen numhelpers = _N
append using "$savedir/helper_core_all", gen(appended)
replace helper_all = helper_all * (cpi2014 / cpiBASE)

helper OG078 OG079
replace helper_OOP = min( helper_OOP , 15000* (cpi2014 / cpiBASE)) if !missing(helper_OOP)
helper_impute OG076 OG080

drop if appended==1
drop appended
sort HHID PN
gen numpaidhelpers = (helper_OOP>0) if !missing(helper_OOP)
collapse (sum) helper_OOP (first) numhelpers (sum) numpaidhelpers, by(HHID PN)
replace helper_OOP = min( helper_OOP , 15000 * (cpi2014 / cpiBASE)) if !missing(helper_OOP)

keep HHID PN helper_OOP numhelpers numpaidhelpers

save "$savedir/helper_core_2014_imputed", replace


****************************************************************************************		
clear


clear
