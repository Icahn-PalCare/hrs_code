
use $savedir/core1992_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1992_use.dta, nogen
//no helper file this wave
keep HHID PN year *_iw_date months *_use *_cov *_nights *_visits private_ltc
save $savedir/core1992_merge.dta, replace

use $savedir/core1993_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1993_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_1993_imputed, nogen keepusing(numhelpers93 numpaidhelpers93 helper_OOP93)
keep HHID PN year *_iw_date months *_use93 *_cov93 *_nights *_visits private_ltc NH_OOP93 non_NH_OOP93 numhelpers93 numpaidhelpers93 helper_OOP93
save $savedir/core1993_merge.dta, replace

use $savedir/core1994_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1994_use.dta, nogen
//no helper file this wave
keep HHID PN year *_iw_date months *_use *_cov94 *_nights *_visits private_medigap* *_OOP private_ltc
save $savedir/core1994_merge.dta, replace

use $savedir/core1995_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1995_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_1995_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core1995_merge.dta, replace

use $savedir/core1996_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1996_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_1996_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core1996_merge.dta, replace

use $savedir/core1998_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core1998_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_1998_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core1998_merge.dta, replace

use $savedir/core2000_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2000_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2000_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2000_merge.dta, replace

use $savedir/core2002_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2002_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2002_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2002_merge.dta, replace

use $savedir/core2004_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2004_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2004_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2004_merge.dta, replace

use $savedir/core2006_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2006_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2006_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2006_merge.dta, replace

use $savedir/core2008_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2008_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2008_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2008_merge.dta, replace

use $savedir/core2010_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2010_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2010_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2010_merge.dta, replace

use $savedir/core2012_oopi2.dta, clear
merge 1:1 HHID PN using $savedir/core2012_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_core_2012_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
keep HHID PN year *_iw_date months *_use *_cov *_liv *_nights *_visits private_medigap* *_OOP numhelpers numpaidhelpers helper_OOP long_term_care MC_*
save $savedir/core2012_merge.dta, replace

use $savedir/core1992_merge.dta, clear
append using ///
$savedir/core1993_merge.dta ///
$savedir/core1994_merge.dta ///
$savedir/core1995_merge.dta ///
$savedir/core1996_merge.dta ///
$savedir/core1998_merge.dta ///
$savedir/core2000_merge.dta ///
$savedir/core2002_merge.dta ///
$savedir/core2004_merge.dta ///
$savedir/core2006_merge.dta ///
$savedir/core2008_merge.dta ///
$savedir/core2010_merge.dta ///
$savedir/core2012_merge.dta

sort HHID PN year

merge 1:1 HHID PN year using $savedir/core_flags.dta, nogen

scalar drop _all
do load_cpi

gen cpi = .
replace cpi = cpiBASE / cpi2012 if year==2012
replace cpi = cpiBASE / cpi2010 if year==2010
replace cpi = cpiBASE / cpi2008 if year==2008
replace cpi = cpiBASE / cpi2006 if year==2006
replace cpi = cpiBASE / cpi2004 if year==2004
replace cpi = cpiBASE / cpi2002 if year==2002
replace cpi = cpiBASE / cpi2000 if year==2000
replace cpi = cpiBASE / cpi1998 if year==1998
replace cpi = cpiBASE / cpi1996 if year==1996
replace cpi = cpiBASE / cpi1995 if year==1995
replace cpi = cpiBASE / cpi1994 if year==1994
replace cpi = cpiBASE / cpi1993 if year==1993
replace cpi = cpiBASE / cpi1992 if year==1992			//rrd: typo 1993 (down bias results)

local oop ///
	private_ltc ///1992-1994
	NH_OOP93 non_NH_OOP93 helper_OOP93 ///1993
	private_medigap_1 private_medigap_2 private_medigap_3 private_medigap_4 private_medigap_5 ///1994-2010 (_4: 1994/1996 _5: 1994)
	hospital_NH_doctor_OOP ///1994 
	RX_OOP ///1994-2010
	MC_HMO ///1995-2010
	long_term_care ///1995-2010
	hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///1995-2000
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP ///2002-2010
	MC_D ///2008-2010
	MC_B ///1993, 1995-2010
	other_OOP ///2010
	private_medigap ///1995-2010
	helper_OOP //1993, 1995-2010
	

foreach v of local oop {
	replace `v' = `v' * cpi
}			
			
keep HHID PN year `oop' flag_* *_iw_date months *_use* *_liv *_cov* *_nights *_visits numhelpers* numpaidhelpers*	

save $savedir/core_merged.dta, replace

rm $savedir/core1992_merge.dta
rm $savedir/core1993_merge.dta
rm $savedir/core1994_merge.dta
rm $savedir/core1995_merge.dta
rm $savedir/core1996_merge.dta
rm $savedir/core1998_merge.dta
rm $savedir/core2000_merge.dta
rm $savedir/core2002_merge.dta
rm $savedir/core2004_merge.dta
rm $savedir/core2006_merge.dta
rm $savedir/core2008_merge.dta
rm $savedir/core2010_merge.dta
rm $savedir/core2012_merge.dta
