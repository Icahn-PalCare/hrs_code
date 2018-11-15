
local all mc_hmo_all mc_d_all ltc_all hospital_all nursing_home_all doctor_all patient_all dental_all RX_all home_all special_all other_all ///
			hospital_NH_all doctor_patient_dental_all home_special_all private_medigap_all hospital_NH_doctor_all

********************************************************************************

use $savedir/core1992_oop.dta, clear

//no bracket imputations this wave

save $savedir/core1992_oopi1.dta, replace

********************************************************************************

use $savedir/core1993_oop.dta, clear		//rrd: in nominal dollars

scalar z = cpi1993/cpiBASE

//We don't use _all file here for two reasons:
//First, totals reflect spending by R + SP, unlike in the other interviews (R only). 
//Second, for the non-NH spending variable, it is not entirely clear what should be included if we were to construct it from the variables available
//in later waves. We could use NH spending later waves for non-married, non-partnered individuals. However, there are only 7 observations being imputed.

gen NH_all93 = NH_OOP93
gen non_NH_all93 = non_NH_OOP93

gen upper = .
gen lower = .

replace upper = z*12*15000 if V629C==6 | V629C==9 | V629C==10	//if partial bracket missing upper bound, replace with cap
replace upper = 50000 if V629C==5
replace upper = 20000 if V629C==4
replace upper = 10000 if V629C==3 | V629C==8
replace upper =  5000 if V629C==2 | V629C==7
replace upper =   500 if V629C==1

replace lower =     0 if V629C==1 | V629C==7 | V629C==8
replace lower =   501 if V629C==2
replace lower =  5001 if V629C==3
replace lower = 10001 if V629C==4 | V629C==9
replace lower = 20001 if V629C==5 | V629C==10
replace lower = 50001 if V629C==6

//impute separately by whether married/partnered or not because totals may reflect spending by one or two individuals

repute lower upper NH_all93 NH_OOP93 if (r3mstat==1 | r3mstat==2 | r3mstat==3)		//rrd: married or partnered
repute lower upper NH_all93 NH_OOP93 if !(r3mstat==1 | r3mstat==2 | r3mstat==3)

drop upper lower

gen upper = .
gen lower = .

replace upper = z*12*(15000+15000+5000+1000+5000+15000+15000+15000) if V740C==6 | V740C==9 | V740C==10
replace upper = 10000 if V740C==5
replace upper =  6000 if V740C==4
replace upper =  3000 if V740C==3 | V740C==8
replace upper =  1000 if V740C==2 | V740C==7
replace upper =   500 if V740C==1

replace lower =     0 if V740C==1 | V740C==7 | V740C==8
replace lower =   501 if V740C==2
replace lower =  1001 if V740C==3
replace lower =  3001 if V740C==4 | V740C==9
replace lower =  6001 if V740C==5 | V740C==10
replace lower = 10001 if V740C==6

repute lower upper non_NH_all93 non_NH_OOP93 if (r3mstat==1 | r3mstat==2 | r3mstat==3)
repute lower upper non_NH_all93 non_NH_OOP93 if !(r3mstat==1 | r3mstat==2 | r3mstat==3)

drop upper lower

drop *_all93

save $savedir/core1993_oopi1.dta, replace		//rrd: in nominal dollars

********************************************************************************

use $savedir/core1994_oop.dta, clear
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi1994/cpiBASE

foreach v of local all {
	replace `v' = `v' * z		//convertnig _all to real dollars with base year to match 94
}

gen upper = .
gen lower = .

replace upper = z*months*(15000+15000+5000) if W430==1 | W430==3 | W430==5	//if partial bracket missing upper bound, replace with cap
replace upper = 100000 if W430==2
replace upper =  25000 if W430==4
replace upper =   5000 if W430==6 | W430==8
replace upper =   1000 if W430==7

replace lower = 100000 if W430==1
replace lower =  25000 if W430==2 | W430==3
replace lower =   5000 if W430==4 | W430==5
replace lower =   1000 if W430==6
replace lower = 	 0 if W430==7 | W430==8

repute lower upper hospital_NH_doctor_all hospital_NH_doctor_OOP		//rrd: everything here is in real dollars from 94

drop upper lower

drop if appended==1
drop appended
drop *_all

save $savedir/core1994_oopi1.dta, replace

********************************************************************************

use $savedir/core1995_oop.dta, clear
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi1995/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do core_brackets1995

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_patient_dental_all doctor_patient_dental_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/core1995_oopi1.dta, replace

********************************************************************************

use $savedir/core1996_oop.dta, clear
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi1996/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do core_brackets1996

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_patient_dental_all doctor_patient_dental_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/core1996_oopi1.dta, replace

********************************************************************************

use $savedir/core1998_oop.dta, clear
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi1998/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do core_brackets1998

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_patient_dental_all doctor_patient_dental_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/core1998_oopi1.dta, replace

********************************************************************************

use $savedir/core2000_oop.dta, clear
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2000/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do core_brackets2000

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_patient_dental_all doctor_patient_dental_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/core2000_oopi1.dta, replace

********************************************************************************

use $savedir/core2002_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2002_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2002/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace HN016 = min( HN016 , 400*z ) if !missing(HN016)
replace HN042_1 = min( HN042_1 , cond(HN001==1,400*z,2000*z) ) if !missing(HN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace HN042_2 = min( HN042_2 , cond(HN001==1,400*z,2000*z) ) if !missing(HN042_2)
replace HN042_3 = min( HN042_3 , cond(HN001==1,400*z,2000*z) ) if !missing(HN042_3)
replace HN081 = min( HN081 , 2000*z ) if !missing(HN081)
replace HN108 = min( HN108 , 15000*z*months ) if !missing(HN108)
replace HN121 = min( HN121 , 15000*z*months ) if !missing(HN121)
replace HN141 = min( HN141 , 15000*z*months ) if !missing(HN141)
replace HN158 = min( HN158 , 5000*z*months ) if !missing(HN158)
replace HN170 = min( HN170 , 1000*z*months ) if !missing(HN170)
replace HN182 = min( HN182 , 5000*z ) if !missing(HN182)
replace HN196 = min( HN196 , 15000*z*months ) if !missing(HN196)
replace HN247 = min( HN247 , 15000*z*months ) if !missing(HN247)

repute HN015 HN016 mc_hmo_all MC_HMO
repute HN080 HN081 ltc_all long_term_care
repute HN107 HN108 hospital_all hospital_OOP
repute HN120 HN121 nursing_home_all NH_OOP
repute HN140 HN141 patient_all patient_OOP
repute HN157 HN158 doctor_all doctor_OOP
repute HN169 HN170 dental_all dental_OOP
repute HN181 HN182 RX_all RX_OOP
repute HN195 HN196 home_all home_OOP
repute HN246 HN247 special_all special_OOP

//rrd: this next block makes no sense
repute HN041_1 HN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1		//rrd: recall, _all has only 2002 onward
repute HN041_1 HN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute HN041_2 HN042_2 private_medigap_all private_medigap_1 if private_medigap_plans==1			//rrd: this case doesnt occur. AND should it be _2? 
repute HN041_2 HN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98		//rrd: this is changed
repute HN041_3 HN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1			//rrd: _3?
repute HN041_3 HN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2002_oopi1.dta, replace

********************************************************************************

use $savedir/core2004_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2004_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2004/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace JN016 = min( JN016 , 400*z ) if !missing(JN016)
replace JN042_1 = min( JN042_1 , cond(JN001==1,400*z,2000*z) ) if !missing(JN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace JN042_2 = min( JN042_2 , cond(JN001==1,400*z,2000*z) ) if !missing(JN042_2)
replace JN042_3 = min( JN042_3 , cond(JN001==1,400*z,2000*z) ) if !missing(JN042_3)
replace JN081 = min( JN081 , 2000*z ) if !missing(JN081)
replace JN108 = min( JN108 , 15000*z*months ) if !missing(JN108)
replace JN121 = min( JN121 , 15000*z*months ) if !missing(JN121)
replace JN141 = min( JN141 , 15000*z*months ) if !missing(JN141)
replace JN158 = min( JN158 , 5000*z*months ) if !missing(JN158)
replace JN170 = min( JN170 , 1000*z*months ) if !missing(JN170)
replace JN182 = min( JN182 , 5000*z ) if !missing(JN182)
replace JN196 = min( JN196 , 15000*z*months ) if !missing(JN196)
replace JN247 = min( JN247 , 15000*z*months ) if !missing(JN247)

repute JN015 JN016 mc_hmo_all MC_HMO
repute JN080 JN081 ltc_all long_term_care
repute JN107 JN108 hospital_all hospital_OOP
repute JN120 JN121 nursing_home_all NH_OOP
repute JN140 JN141 patient_all patient_OOP
repute JN157 JN158 doctor_all doctor_OOP
repute JN169 JN170 dental_all dental_OOP
repute JN181 JN182 RX_all RX_OOP
repute JN195 JN196 home_all home_OOP
repute JN246 JN247 special_all special_OOP

repute JN041_1 JN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute JN041_1 JN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute JN041_2 JN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute JN041_2 JN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute JN041_3 JN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute JN041_3 JN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2004_oopi1.dta, replace

********************************************************************************

use $savedir/core2006_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2006_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2006/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace KN016 = min( KN016 , 400*z ) if !missing(KN016)
replace KN406 = min( KN406 , 100*z ) if !missing(KN406)
replace KN042_1 = min( KN042_1 , cond(KN001==1,400*z,2000*z) ) if !missing(KN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace KN042_2 = min( KN042_2 , cond(KN001==1,400*z,2000*z) ) if !missing(KN042_2)
replace KN042_3 = min( KN042_3 , cond(KN001==1,400*z,2000*z) ) if !missing(KN042_3)
replace KN081 = min( KN081 , 2000*z ) if !missing(KN081)
replace KN108 = min( KN108 , 15000*z*months ) if !missing(KN108)
replace KN121 = min( KN121 , 15000*z*months ) if !missing(KN121)
replace KN141 = min( KN141 , 15000*z*months ) if !missing(KN141)
replace KN158 = min( KN158 , 5000*z*months ) if !missing(KN158)
replace KN170 = min( KN170 , 1000*z*months ) if !missing(KN170)
replace KN182 = min( KN182 , 5000*z ) if !missing(KN182)
replace KN196 = min( KN196 , 15000*z*months ) if !missing(KN196)
replace KN247 = min( KN247 , 15000*z*months ) if !missing(KN247)

repute KN015 KN016 mc_hmo_all MC_HMO
repute KN405 KN406 mc_d_all MC_D
repute KN080 KN081 ltc_all long_term_care
repute KN107 KN108 hospital_all hospital_OOP
repute KN120 KN121 nursing_home_all NH_OOP
repute KN140 KN141 patient_all patient_OOP
repute KN157 KN158 doctor_all doctor_OOP
repute KN169 KN170 dental_all dental_OOP
repute KN181 KN182 RX_all RX_OOP
repute KN195 KN196 home_all home_OOP
repute KN246 KN247 special_all special_OOP

repute KN041_1 KN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute KN041_1 KN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute KN041_2 KN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute KN041_2 KN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute KN041_3 KN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute KN041_3 KN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2006_oopi1.dta, replace

********************************************************************************

use $savedir/core2008_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2008_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2008/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace LN016 = min( LN016 , 400*z ) if !missing(LN016)
replace LN406 = min( LN406 , 100*z ) if !missing(LN406)
replace LN042_1 = min( LN042_1 , cond(LN001==1,400*z,2000*z) ) if !missing(LN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace LN042_2 = min( LN042_2 , cond(LN001==1,400*z,2000*z) ) if !missing(LN042_2)
replace LN042_3 = min( LN042_3 , cond(LN001==1,400*z,2000*z) ) if !missing(LN042_3)
replace LN081 = min( LN081 , 2000*z ) if !missing(LN081)
replace LN108 = min( LN108 , 15000*z*months ) if !missing(LN108)
replace LN121 = min( LN121 , 15000*z*months ) if !missing(LN121)
replace LN141 = min( LN141 , 15000*z*months ) if !missing(LN141)
replace LN158 = min( LN158 , 5000*z*months ) if !missing(LN158)
replace LN170 = min( LN170 , 1000*z*months ) if !missing(LN170)
replace LN182 = min( LN182 , 5000*z ) if !missing(LN182)
replace LN196 = min( LN196 , 15000*z*months ) if !missing(LN196)
replace LN247 = min( LN247 , 15000*z*months ) if !missing(LN247)

repute LN015 LN016 mc_hmo_all MC_HMO
repute LN405 LN406 mc_d_all MC_D
repute LN080 LN081 ltc_all long_term_care
repute LN107 LN108 hospital_all hospital_OOP
repute LN120 LN121 nursing_home_all NH_OOP
repute LN140 LN141 patient_all patient_OOP
repute LN157 LN158 doctor_all doctor_OOP
repute LN169 LN170 dental_all dental_OOP
repute LN181 LN182 RX_all RX_OOP
repute LN195 LN196 home_all home_OOP
repute LN246 LN247 special_all special_OOP

repute LN041_1 LN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute LN041_1 LN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute LN041_2 LN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute LN041_2 LN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute LN041_3 LN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute LN041_3 LN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2008_oopi1.dta, replace

********************************************************************************

use $savedir/core2010_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2010_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2010/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace MN016 = min( MN016 , 400*z ) if !missing(MN016)
replace MN406 = min( MN406 , 100*z ) if !missing(MN406)
replace MN042_1 = min( MN042_1 , cond(MN001==1,400*z,2000*z) ) if !missing(MN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace MN042_2 = min( MN042_2 , cond(MN001==1,400*z,2000*z) ) if !missing(MN042_2)
replace MN042_3 = min( MN042_3 , cond(MN001==1,400*z,2000*z) ) if !missing(MN042_3)
replace MN081 = min( MN081 , 2000*z ) if !missing(MN081)
replace MN108 = min( MN108 , 15000*z*months ) if !missing(MN108)
replace MN121 = min( MN121 , 15000*z*months ) if !missing(MN121)
replace MN141 = min( MN141 , 15000*z*months ) if !missing(MN141)
replace MN158 = min( MN158 , 5000*z*months ) if !missing(MN158)
replace MN170 = min( MN170 , 1000*z*months ) if !missing(MN170)
replace MN182 = min( MN182 , 5000*z ) if !missing(MN182)
replace MN196 = min( MN196 , 15000*z*months ) if !missing(MN196)
replace MN247 = min( MN247 , 15000*z*months ) if !missing(MN247)
replace MN335 = min( MN335 , 15000*z*months ) if !missing(MN335)

repute MN015 MN016 mc_hmo_all MC_HMO
repute MN405 MN406 mc_d_all MC_D
repute MN080 MN081 ltc_all long_term_care
repute MN107 MN108 hospital_all hospital_OOP
repute MN120 MN121 nursing_home_all NH_OOP
repute MN140 MN141 patient_all patient_OOP
repute MN157 MN158 doctor_all doctor_OOP
repute MN169 MN170 dental_all dental_OOP
repute MN181 MN182 RX_all RX_OOP
repute MN195 MN196 home_all home_OOP
repute MN246 MN247 special_all special_OOP
repute MN334 MN335 other_all other_OOP

repute MN041_1 MN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute MN041_1 MN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute MN041_2 MN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute MN041_2 MN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute MN041_3 MN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute MN041_3 MN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2010_oopi1.dta, replace

********************************************************************************

use $savedir/core2012_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2012_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2012/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace NN016 = min( NN016 , 400*z ) if !missing(NN016)
replace NN406 = min( NN406 , 100*z ) if !missing(NN406)
replace NN042_1 = min( NN042_1 , cond(NN001==1,400*z,2000*z) ) if !missing(NN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace NN042_2 = min( NN042_2 , cond(NN001==1,400*z,2000*z) ) if !missing(NN042_2)
replace NN042_3 = min( NN042_3 , cond(NN001==1,400*z,2000*z) ) if !missing(NN042_3)
replace NN081 = min( NN081 , 2000*z ) if !missing(NN081)
replace NN108 = min( NN108 , 15000*z*months ) if !missing(NN108)
replace NN121 = min( NN121 , 15000*z*months ) if !missing(NN121)
replace NN141 = min( NN141 , 15000*z*months ) if !missing(NN141)
replace NN158 = min( NN158 , 5000*z*months ) if !missing(NN158)
replace NN170 = min( NN170 , 1000*z*months ) if !missing(NN170)
replace NN182 = min( NN182 , 5000*z ) if !missing(NN182)
replace NN196 = min( NN196 , 15000*z*months ) if !missing(NN196)
replace NN247 = min( NN247 , 15000*z*months ) if !missing(NN247)
replace NN335 = min( NN335 , 15000*z*months ) if !missing(NN335)

repute NN015 NN016 mc_hmo_all MC_HMO
repute NN405 NN406 mc_d_all MC_D
repute NN080 NN081 ltc_all long_term_care
repute NN107 NN108 hospital_all hospital_OOP
repute NN120 NN121 nursing_home_all NH_OOP
repute NN140 NN141 patient_all patient_OOP
repute NN157 NN158 doctor_all doctor_OOP
repute NN169 NN170 dental_all dental_OOP
repute NN181 NN182 RX_all RX_OOP
repute NN195 NN196 home_all home_OOP
repute NN246 NN247 special_all special_OOP
repute NN334 NN335 other_all other_OOP

repute NN041_1 NN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute NN041_1 NN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute NN041_2 NN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute NN041_2 NN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute NN041_3 NN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute NN041_3 NN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2012_oopi1.dta, replace

********************************************************************************

use $savedir/core2014_oop.dta, clear
merge 1:1 HHID PN using $savedir/core2014_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/core_all.dta, gen(appended)

scalar z = cpi2014/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace ON016 = min( ON016 , 400*z ) if !missing(ON016)
replace ON406 = min( ON406 , 100*z ) if !missing(ON406)
replace ON042_1 = min( ON042_1 , cond(ON001==1,400*z,2000*z) ) if !missing(ON042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace ON042_2 = min( ON042_2 , cond(ON001==1,400*z,2000*z) ) if !missing(ON042_2)
replace ON042_3 = min( ON042_3 , cond(ON001==1,400*z,2000*z) ) if !missing(ON042_3)
replace ON081 = min( ON081 , 2000*z ) if !missing(ON081)
replace ON108 = min( ON108 , 15000*z*months ) if !missing(ON108)
replace ON121 = min( ON121 , 15000*z*months ) if !missing(ON121)
replace ON141 = min( ON141 , 15000*z*months ) if !missing(ON141)
replace ON158 = min( ON158 , 5000*z*months ) if !missing(ON158)
replace ON170 = min( ON170 , 1000*z*months ) if !missing(ON170)
replace ON182 = min( ON182 , 5000*z ) if !missing(ON182)
replace ON196 = min( ON196 , 15000*z*months ) if !missing(ON196)
replace ON247 = min( ON247 , 15000*z*months ) if !missing(ON247)
replace ON335 = min( ON335 , 15000*z*months ) if !missing(ON335)

repute ON015 ON016 mc_hmo_all MC_HMO
repute ON405 ON406 mc_d_all MC_D
repute ON080 ON081 ltc_all long_term_care
repute ON107 ON108 hospital_all hospital_OOP
repute ON120 ON121 nursing_home_all NH_OOP
repute ON140 ON141 patient_all patient_OOP
repute ON157 ON158 doctor_all doctor_OOP
repute ON169 ON170 dental_all dental_OOP
repute ON181 ON182 RX_all RX_OOP
repute ON195 ON196 home_all home_OOP
repute ON246 ON247 special_all special_OOP
repute ON334 ON335 other_all other_OOP

repute ON041_1 ON042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute ON041_1 ON042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute ON041_2 ON042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute ON041_2 ON042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute ON041_3 ON042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute ON041_3 ON042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/core2014_oopi1.dta, replace

********************************************************************************

use $savedir/core1992_oopi1.dta, clear
keep HHID PN year private_ltc
save $savedir/tmp1992.dta, replace

use $savedir/core1993_oopi1.dta, clear
keep HHID PN year private_ltc NH_OOP93 non_NH_OOP93
save $savedir/tmp1993.dta, replace

use $savedir/core1994_oopi1.dta, clear
keep HHID PN year private_medigap_* hospital_NH_doctor_OOP RX_OOP
save $savedir/tmp1994.dta, replace

use $savedir/core1995_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1995.dta, replace

use $savedir/core1996_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1996.dta, replace

use $savedir/core1998_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1998.dta, replace

use $savedir/core2000_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp2000.dta, replace

use $savedir/core2002_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2002.dta, replace

use $savedir/core2004_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2004.dta, replace

use $savedir/core2006_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2006.dta, replace

use $savedir/core2008_oopi1.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2008.dta, replace

use $savedir/core2010_oopi1.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2010.dta, replace

use $savedir/core2012_oopi1.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2012.dta, replace

use $savedir/core2014_oopi1.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2014.dta, replace

use $savedir/tmp1992.dta, clear
append using ///
$savedir/tmp1993.dta ///
$savedir/tmp1994.dta ///
$savedir/tmp1995.dta ///
$savedir/tmp1996.dta ///
$savedir/tmp1998.dta ///
$savedir/tmp2000.dta ///
$savedir/tmp2002.dta ///
$savedir/tmp2004.dta ///
$savedir/tmp2006.dta ///
$savedir/tmp2008.dta ///
$savedir/tmp2010.dta ///
$savedir/tmp2012.dta ///
$savedir/tmp2014.dta 

save $savedir/core_oopi1.dta, replace

rm $savedir/tmp1992.dta
rm $savedir/tmp1993.dta
rm $savedir/tmp1994.dta
rm $savedir/tmp1995.dta
rm $savedir/tmp1996.dta
rm $savedir/tmp1998.dta
rm $savedir/tmp2000.dta
rm $savedir/tmp2002.dta
rm $savedir/tmp2004.dta
rm $savedir/tmp2006.dta
rm $savedir/tmp2008.dta
rm $savedir/tmp2010.dta
rm $savedir/tmp2012.dta
rm $savedir/tmp2014.dta
