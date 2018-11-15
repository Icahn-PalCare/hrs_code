
local all mc_hmo_all ltc_all hospital_all nursing_home_all hospice_all doctor_all patient_all dental_all RX_all home_all special_all ///
			other_all nmed_all home_modif_all hospital_NH_all home_special_all private_medigap_all

********************************************************************************

use $savedir/exit1995_oop.dta, clear
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi1995/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do exit_brackets1995

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_all doctor_OOP
repute hospice_low hospice_high hospice_all hospice_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP
repute other_low other_high other_all other_OOP
repute non_med_low non_med_high nmed_all non_med_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/exit1995_oopi1.dta, replace

********************************************************************************

use $savedir/exit1996_oop.dta, clear
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi1996/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do exit_brackets1996

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_all doctor_OOP
repute hospice_low hospice_high hospice_all hospice_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP
repute other_low other_high other_all other_OOP
repute non_med_low non_med_high nmed_all non_med_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/exit1996_oopi1.dta, replace

********************************************************************************

use $savedir/exit1998_oop.dta, clear
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi1998/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do exit_brackets1998

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_all doctor_OOP
repute hospice_low hospice_high hospice_all hospice_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP
repute other_low other_high other_all other_OOP
repute non_med_low non_med_high nmed_all non_med_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/exit1998_oopi1.dta, replace

********************************************************************************

use $savedir/exit2000_oop.dta, clear
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2000/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

do exit_brackets2000

repute hospital_low hospital_high hospital_NH_all hospital_NH_OOP
repute doctor_low doctor_high doctor_all doctor_OOP
repute hospice_low hospice_high hospice_all hospice_OOP
repute rx_low rx_high RX_all RX_OOP
repute home_low home_high home_special_all home_special_OOP
repute other_low other_high other_all other_OOP
repute non_med_low non_med_high nmed_all non_med_OOP

drop if appended==1
drop appended
drop *_all

save $savedir/exit2000_oopi1.dta, replace

********************************************************************************

use $savedir/exit2002_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2002_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2002/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace SN016 = min( SN016 , 400*z ) if !missing(SN016)
replace SN042_1 = min( SN042_1 , cond(SN001==1,400*z,2000*z) ) if !missing(SN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace SN042_2 = min( SN042_2 , cond(SN001==1,400*z,2000*z) ) if !missing(SN042_2)
replace SN042_3 = min( SN042_3 , cond(SN001==1,400*z,2000*z) ) if !missing(SN042_3)
replace SN081 = min( SN081 , 2000*z ) if !missing(SN081)
replace SN108 = min( SN108 , 15000*z*months ) if !missing(SN108)
replace SN121 = min( SN121 , 15000*z*months ) if !missing(SN121)
replace SN158 = min( SN158 , 5000*z*months ) if !missing(SN158)
replace SN330 = min( SN330 , 5000*z*months ) if !missing(SN330)
replace SN182 = min( SN182 , 5000*z ) if !missing(SN182)
replace SN196 = min( SN196 , 15000*z*months ) if !missing(SN196)
replace SN335 = min( SN335 , 15000*z*months ) if !missing(SN335)
replace SN340 = min( SN340 , 5000*z*months ) if !missing(SN340)
replace SN247 = min( SN247 , 15000*z*months ) if !missing(SN247)

repute SN015 SN016 mc_hmo_all MC_HMO
repute SN080 SN081 ltc_all long_term_care
repute SN107 SN108 hospital_all hospital_OOP
repute SN120 SN121 nursing_home_all NH_OOP
repute SN157 SN158 doctor_all doctor_OOP
repute SN329 SN330 hospice_all hospice_OOP
repute SN181 SN182 RX_all RX_OOP
repute SN195 SN196 home_all home_OOP
repute SN334 SN335 other_all other_OOP
repute SN339 SN340 nmed_all non_med_OOP
repute SN246 SN247 special_all special_OOP

repute SN041_1 SN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute SN041_1 SN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute SN041_2 SN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute SN041_2 SN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute SN041_3 SN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute SN041_3 SN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2002_oopi1.dta, replace

********************************************************************************

use $savedir/exit2004_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2004_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2004/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace TN016 = min( TN016 , 400*z ) if !missing(TN016)
replace TN042_1 = min( TN042_1 , cond(TN001==1,400*z,2000*z) ) if !missing(TN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace TN042_2 = min( TN042_2 , cond(TN001==1,400*z,2000*z) ) if !missing(TN042_2)
replace TN042_3 = min( TN042_3 , cond(TN001==1,400*z,2000*z) ) if !missing(TN042_3)
replace TN081 = min( TN081 , 2000*z ) if !missing(TN081)
replace TN108 = min( TN108 , 15000*z*months ) if !missing(TN108)
replace TN121 = min( TN121 , 15000*z*months ) if !missing(TN121)
replace TN158 = min( TN158 , 5000*z*months ) if !missing(TN158)
replace TN330 = min( TN330 , 5000*z*months ) if !missing(TN330)
replace TN182 = min( TN182 , 5000*z ) if !missing(TN182)
replace TN196 = min( TN196 , 15000*z*months ) if !missing(TN196)
replace TN335 = min( TN335 , 15000*z*months ) if !missing(TN335)
replace TN340 = min( TN340 , 5000*z*months ) if !missing(TN340)
replace TN247 = min( TN247 , 15000*z*months ) if !missing(TN247)

repute TN015 TN016 mc_hmo_all MC_HMO
repute TN080 TN081 ltc_all long_term_care
repute TN107 TN108 hospital_all hospital_OOP
repute TN120 TN121 nursing_home_all NH_OOP
repute TN157 TN158 doctor_all doctor_OOP
repute TN329 TN330 hospice_all hospice_OOP
repute TN181 TN182 RX_all RX_OOP
repute TN195 TN196 home_all home_OOP
repute TN334 TN335 other_all other_OOP
repute TN339 TN340 nmed_all non_med_OOP
repute TN246 TN247 special_all special_OOP

repute TN041_1 TN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute TN041_1 TN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute TN041_2 TN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute TN041_2 TN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute TN041_3 TN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute TN041_3 TN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2004_oopi1.dta, replace

********************************************************************************

use $savedir/exit2006_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2006_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2006/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace UN016 = min( UN016 , 400*z ) if !missing(UN016)
replace UN042_1 = min( UN042_1 , cond(UN001==1,400*z,2000*z) ) if !missing(UN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace UN042_2 = min( UN042_2 , cond(UN001==1,400*z,2000*z) ) if !missing(UN042_2)
replace UN042_3 = min( UN042_3 , cond(UN001==1,400*z,2000*z) ) if !missing(UN042_3)
replace UN081 = min( UN081 , 2000*z ) if !missing(UN081)
replace UN108 = min( UN108 , 15000*z*months ) if !missing(UN108)
replace UN121 = min( UN121 , 15000*z*months ) if !missing(UN121)
replace UN158 = min( UN158 , 5000*z*months ) if !missing(UN158)
replace UN330 = min( UN330 , 5000*z*months ) if !missing(UN330)
replace UN182 = min( UN182 , 5000*z ) if !missing(UN182)
replace UN196 = min( UN196 , 15000*z*months ) if !missing(UN196)
replace UN335 = min( UN335 , 15000*z*months ) if !missing(UN335)
replace UN340 = min( UN340 , 5000*z*months ) if !missing(UN340)
replace UN247 = min( UN247 , 15000*z*months ) if !missing(UN247)

repute UN015 UN016 mc_hmo_all MC_HMO
repute UN080 UN081 ltc_all long_term_care
repute UN107 UN108 hospital_all hospital_OOP
repute UN120 UN121 nursing_home_all NH_OOP
repute UN157 UN158 doctor_all doctor_OOP
repute UN329 UN330 hospice_all hospice_OOP
repute UN181 UN182 RX_all RX_OOP
repute UN195 UN196 home_all home_OOP
repute UN334 UN335 other_all other_OOP
repute UN339 UN340 nmed_all non_med_OOP
repute UN246 UN247 special_all special_OOP

repute UN041_1 UN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute UN041_1 UN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute UN041_2 UN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute UN041_2 UN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute UN041_3 UN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute UN041_3 UN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2006_oopi1.dta, replace

********************************************************************************

use $savedir/exit2008_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2008_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2008/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace VN016 = min( VN016 , 400*z ) if !missing(VN016)
replace VN042_1 = min( VN042_1 , cond(VN001==1,400*z,2000*z) ) if !missing(VN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace VN042_2 = min( VN042_2 , cond(VN001==1,400*z,2000*z) ) if !missing(VN042_2)
replace VN042_3 = min( VN042_3 , cond(VN001==1,400*z,2000*z) ) if !missing(VN042_3)
replace VN081 = min( VN081 , 2000*z ) if !missing(VN081)
replace VN108 = min( VN108 , 15000*z*months ) if !missing(VN108)
replace VN121 = min( VN121 , 15000*z*months ) if !missing(VN121)
replace VN158 = min( VN158 , 5000*z*months ) if !missing(VN158)
replace VN330 = min( VN330 , 5000*z*months ) if !missing(VN330)
replace VN182 = min( VN182 , 5000*z ) if !missing(VN182)
replace VN196 = min( VN196 , 15000*z*months ) if !missing(VN196)
replace VN335 = min( VN335 , 15000*z*months ) if !missing(VN335)
replace VN340 = min( VN340 , 5000*z*months ) if !missing(VN340)
replace VN247 = min( VN247 , 15000*z*months ) if !missing(VN247)

repute VN015 VN016 mc_hmo_all MC_HMO
repute VN080 VN081 ltc_all long_term_care
repute VN107 VN108 hospital_all hospital_OOP
repute VN120 VN121 nursing_home_all NH_OOP
repute VN157 VN158 doctor_all doctor_OOP
repute VN329 VN330 hospice_all hospice_OOP
repute VN181 VN182 RX_all RX_OOP
repute VN195 VN196 home_all home_OOP
repute VN334 VN335 other_all other_OOP
repute VN339 VN340 nmed_all non_med_OOP
repute VN246 VN247 special_all special_OOP

repute VN041_1 VN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute VN041_1 VN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute VN041_2 VN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute VN041_2 VN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute VN041_3 VN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute VN041_3 VN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2008_oopi1.dta, replace

********************************************************************************

use $savedir/exit2010_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2010_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2010/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace WN016 = min( WN016 , 400*z ) if !missing(WN016)
replace WN042_1 = min( WN042_1 , cond(WN001==1,400*z,2000*z) ) if !missing(WN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace WN042_2 = min( WN042_2 , cond(WN001==1,400*z,2000*z) ) if !missing(WN042_2)
replace WN042_3 = min( WN042_3 , cond(WN001==1,400*z,2000*z) ) if !missing(WN042_3)
replace WN081 = min( WN081 , 2000*z ) if !missing(WN081)
replace WN108 = min( WN108 , 15000*z*months ) if !missing(WN108)
replace WN121 = min( WN121 , 15000*z*months ) if !missing(WN121)
replace WN141 = min( WN141 , 15000*z*months ) if !missing(WN141)
replace WN158 = min( WN158 , 5000*z*months ) if !missing(WN158)
replace WN170 = min( WN170 , 1000*z*months ) if !missing(WN170)
replace WN330 = min( WN330 , 5000*z*months ) if !missing(WN330)
replace WN182 = min( WN182 , 5000*z ) if !missing(WN182)
replace WN196 = min( WN196 , 15000*z*months ) if !missing(WN196)
replace WN335 = min( WN335 , 15000*z*months ) if !missing(WN335)
replace WN270 = min( WN270 , 5000*z*months ) if !missing(WN270)
replace WN247 = min( WN247 , 15000*z*months ) if !missing(WN247)

repute WN015 WN016 mc_hmo_all MC_HMO
repute WN080 WN081 ltc_all long_term_care
repute WN107 WN108 hospital_all hospital_OOP
repute WN120 WN121 nursing_home_all NH_OOP
repute WN140 WN141 patient_all patient_OOP
repute WN157 WN158 doctor_all doctor_OOP
repute WN169 WN170 dental_all dental_OOP
repute WN329 WN330 hospice_all hospice_OOP
repute WN181 WN182 RX_all RX_OOP
repute WN195 WN196 home_all home_OOP
repute WN334 WN335 other_all other_OOP
repute WN269 WN270 home_modif_all home_modif_OOP
repute WN246 WN247 special_all special_OOP

repute WN041_1 WN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute WN041_1 WN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute WN041_2 WN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute WN041_2 WN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute WN041_3 WN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute WN041_3 WN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2010_oopi1.dta, replace

********************************************************************************

use $savedir/exit2012_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2012_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2012/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace XN016 = min( XN016 , 400*z ) if !missing(XN016)
replace XN042_1 = min( XN042_1 , cond(XN001==1,400*z,2000*z) ) if !missing(XN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace XN042_2 = min( XN042_2 , cond(XN001==1,400*z,2000*z) ) if !missing(XN042_2)
replace XN042_3 = min( XN042_3 , cond(XN001==1,400*z,2000*z) ) if !missing(XN042_3)
replace XN081 = min( XN081 , 2000*z ) if !missing(XN081)
replace XN108 = min( XN108 , 15000*z*months ) if !missing(XN108)
replace XN121 = min( XN121 , 15000*z*months ) if !missing(XN121)
replace XN141 = min( XN141 , 15000*z*months ) if !missing(XN141)
replace XN158 = min( XN158 , 5000*z*months ) if !missing(XN158)
replace XN170 = min( XN170 , 1000*z*months ) if !missing(XN170)
replace XN330 = min( XN330 , 5000*z*months ) if !missing(XN330)
replace XN182 = min( XN182 , 5000*z ) if !missing(XN182)
replace XN196 = min( XN196 , 15000*z*months ) if !missing(XN196)
replace XN335 = min( XN335 , 15000*z*months ) if !missing(XN335)
replace XN270 = min( XN270 , 5000*z*months ) if !missing(XN270)
replace XN247 = min( XN247 , 15000*z*months ) if !missing(XN247)

repute XN015 XN016 mc_hmo_all MC_HMO
repute XN080 XN081 ltc_all long_term_care
repute XN107 XN108 hospital_all hospital_OOP
repute XN120 XN121 nursing_home_all NH_OOP
repute XN140 XN141 patient_all patient_OOP
repute XN157 XN158 doctor_all doctor_OOP
repute XN169 XN170 dental_all dental_OOP
repute XN329 XN330 hospice_all hospice_OOP
repute XN181 XN182 RX_all RX_OOP
repute XN195 XN196 home_all home_OOP
repute XN334 XN335 other_all other_OOP
repute XN269 XN270 home_modif_all home_modif_OOP
repute XN246 XN247 special_all special_OOP

repute XN041_1 XN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute XN041_1 XN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute XN041_2 XN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute XN041_2 XN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute XN041_3 XN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute XN041_3 XN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2012_oopi1.dta, replace

********************************************************************************

use $savedir/exit2014_oop.dta, clear
merge 1:1 HHID PN using $savedir/exit2014_use.dta, nogen keepusing(private_medigap_plans)
append using $savedir/exit_all.dta, gen(appended)

scalar z = cpi2014/cpiBASE

foreach v of local all {
	replace `v' = `v' * z
}

replace YN016 = min( YN016 , 400*z ) if !missing(YN016)
replace YN042_1 = min( YN042_1 , cond(YN001==1,400*z,2000*z) ) if !missing(YN042_1) //if R covered by Medicare: cap at $400/mo, o/w: cap at $2000/mo
replace YN042_2 = min( YN042_2 , cond(YN001==1,400*z,2000*z) ) if !missing(YN042_2)
replace YN042_3 = min( YN042_3 , cond(YN001==1,400*z,2000*z) ) if !missing(YN042_3)
replace YN081 = min( YN081 , 2000*z ) if !missing(YN081)
replace YN108 = min( YN108 , 15000*z*months ) if !missing(YN108)
replace YN121 = min( YN121 , 15000*z*months ) if !missing(YN121)
replace YN141 = min( YN141 , 15000*z*months ) if !missing(YN141)
replace YN158 = min( YN158 , 5000*z*months ) if !missing(YN158)
replace YN170 = min( YN170 , 1000*z*months ) if !missing(YN170)
replace YN330 = min( YN330 , 5000*z*months ) if !missing(YN330)
replace YN182 = min( YN182 , 5000*z ) if !missing(YN182)
replace YN196 = min( YN196 , 15000*z*months ) if !missing(YN196)
replace YN335 = min( YN335 , 15000*z*months ) if !missing(YN335)
replace YN270 = min( YN270 , 5000*z*months ) if !missing(YN270)
replace YN247 = min( YN247 , 15000*z*months ) if !missing(YN247)

repute YN015 YN016 mc_hmo_all MC_HMO
repute YN080 YN081 ltc_all long_term_care
repute YN107 YN108 hospital_all hospital_OOP
repute YN120 YN121 nursing_home_all NH_OOP
repute YN140 YN141 patient_all patient_OOP
repute YN157 YN158 doctor_all doctor_OOP
repute YN169 YN170 dental_all dental_OOP
repute YN329 YN330 hospice_all hospice_OOP
repute YN181 YN182 RX_all RX_OOP
repute YN195 YN196 home_all home_OOP
repute YN334 YN335 other_all other_OOP
repute YN269 YN270 home_modif_all home_modif_OOP
repute YN246 YN247 special_all special_OOP

repute YN041_1 YN042_1 private_medigap_all private_medigap_1 if private_medigap_plans==1
repute YN041_1 YN042_1 private_medigap_all private_medigap_1 if private_medigap_plans>=2 & private_medigap_plans<98
repute YN041_2 YN042_2 private_medigap_all private_medigap_2 if private_medigap_plans==1
repute YN041_2 YN042_2 private_medigap_all private_medigap_2 if private_medigap_plans>=2 & private_medigap_plans<98
repute YN041_3 YN042_3 private_medigap_all private_medigap_3 if private_medigap_plans==1
repute YN041_3 YN042_3 private_medigap_all private_medigap_3 if private_medigap_plans>=2 & private_medigap_plans<98

drop if appended==1
drop appended
drop *_all

save $savedir/exit2014_oopi1.dta, replace

********************************************************************************

use $savedir/exit1995_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1995.dta, replace

use $savedir/exit1996_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1996.dta, replace

use $savedir/exit1998_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1998.dta, replace

use $savedir/exit2000_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp2000.dta, replace

use $savedir/exit2002_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2002.dta, replace

use $savedir/exit2004_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2004.dta, replace

use $savedir/exit2006_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2006.dta, replace

use $savedir/exit2008_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2008.dta, replace

use $savedir/exit2010_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2010.dta, replace

use $savedir/exit2012_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2012.dta, replace

use $savedir/exit2014_oopi1.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2014.dta, replace

use $savedir/tmp1995.dta, clear
append using ///
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

save $savedir/exit_oopi1.dta, replace

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
