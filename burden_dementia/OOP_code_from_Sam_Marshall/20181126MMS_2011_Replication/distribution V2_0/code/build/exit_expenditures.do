/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			exit expenditures.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the file of all reported OOP expenditures by type


ORGANIZATION:	Section 1: Create the annual files
				Section 2: Merge the files together
				
INPUTS: 		XyyE_R.dta XyyR_R.dta XyyN_R.dta
				
OUTPUTS: 		all_exit_exp.log exit_expenditures.dta
				
NOTE:			
******************************************************************/

capture log close
log using "${logs}/all_exit_exp.log",replace

/****************************************************************
	SECTION 1: Create the annual files
****************************************************************/


use "${rawdata}/X98E_R.dta", clear
	merge 1:1 HHID PN using "${rawdata}/X98R_R.dta"
keep Q2579 Q2668 Q1749 Q1784 Q1770 Q1794 Q1811 Q1818 Q1844

replace Q1749 = . if (Q1749 == 9999998 | Q1749 == 9999999)
replace Q2579 = . if (Q2579 == 9998 | Q2579 == 9999)
replace Q2668 = . if (Q2668 == 999998 | Q2668 == 999999)
replace Q1784 = . if (Q1784 == 999998 | Q1784 == 999999)
replace Q1770 = . if (Q1770 == 99998 | Q1770 == 99999)
replace Q1794 = . if (Q1794 == 99998 | Q1794 == 99999)
replace Q1811 = . if (Q1811 == 999998 | Q1811 == 999999)
replace Q1818 = . if (Q1818 == 999998 | Q1818 == 999999)
replace Q1844 = . if (Q1844 == 999998 | Q1844 == 999999)

global vars98 "Q2579 Q2668 Q1749 Q1784 Q1770 Q1794 Q1811 Q1818 Q1844"

foreach y of global vars98 {
replace `y' = (`y' * (116.567/96.472))
}

gen hospital_NH_all = Q1749
gen mc_hmo_all = Q2579
gen ltc_all = Q2668
gen doctor_all = Q1784
gen hospice_all = Q1770
gen RX_all = Q1794
gen home_all = Q1811
gen other_all = Q1818
gen nmed_all = Q1844

keep mc_hmo_all ltc_all doctor_all hospice_all RX_all home_all other_all nmed_all hospital_NH_all

save "${buildoutput}/1998exit_exp.dta", replace

*************************************************************************

use "${rawdata}/X00E_R.dta", clear
	merge 1:1 HHID PN using "${rawdata}/X00R_R.dta"
	
keep R2605 R2704 R1760 R1800 R1781 R1810 R1827 R1835 R1864 

replace R1760 = . if (R1760 == 9999998 | R1760 == 9999999)
replace R2605 = . if (R2605 == 9998 | R2605 == 9999)
replace R2704 = . if (R2704 == 999998 | R2704 == 999999)
replace R1800 = . if (R1800 == 99998 | R1800 == 99999)
replace R1781 = . if (R1781 == 99998 | R1781 == 99999)
replace R1810 = . if (R1810 == 99998 | R1810 == 99999)
replace R1827 = . if (R1827 == 999998 | R1827 == 999999)
replace R1835 = . if (R1835 == 999998 | R1835 == 999999)
replace R1864 = . if (R1864 == 999998 | R1864 == 999999)

global vars00 "R2605 R2704 R1760 R1800 R1781 R1810 R1827 R1835 R1864"

foreach y of global vars00 {
replace `y' = (`y' * (116.567/100.000))
}

gen hospital_NH_all = R1760
gen mc_hmo_all = R2605 
gen ltc_all = R2704 
gen doctor_all = R1800 
gen hospice_all = R1781 
gen RX_all = R1810 
gen home_all = R1827 
gen other_all = R1835 
gen nmed_all = R1864 

keep mc_hmo_all ltc_all doctor_all hospice_all RX_all home_all other_all nmed_all hospital_NH_all

save "${buildoutput}/2000exit_exp.dta", replace

*************************************************************************

use "${rawdata}/X02N_R.dta", clear

keep SN014 SN079 SN040_1 SN040_2 SN040_3 SN106 SN119 SN156 SN328 SN180 SN194 SN333 SN338 SN239

replace SN014 = . if (SN014 == 998 | SN014 == 999)
replace SN079 = . if (SN079 == 99998 | SN079 == 99999)
replace SN040_1 = . if (SN040_1 == 998 | SN040_1 == 999)
replace SN040_2 = . if (SN040_2 == 998 | SN040_2 == 999)
replace SN040_3 = . if (SN040_3 == 998 | SN040_3 == 999)
replace SN106 = . if (SN106 == 999998 | SN106 == 999999)
replace SN119 = . if (SN119 == 999998 | SN119 == 999999)
replace SN156 = . if (SN156 == 999998 | SN156 == 999999)
replace SN328 = . if (SN328 == 9998 | SN328 == 9999)
replace SN180 = . if (SN180 == 9998 | SN180 == 9999)
replace SN194 = . if (SN194 == 99998 | SN194 == 99999)
replace SN333 = . if (SN333 == 99998 | SN333 == 99999)
replace SN338 = . if (SN338 == 99998 | SN338 == 99999)
replace SN239 = . if (SN239 == 9998 | SN239 == 9999)

replace SN040_1 = 0 if ((SN040_2 != . | SN040_3 != .) & SN040_1 == .)
replace SN040_2 = 0 if ((SN040_1 != . | SN040_3 != .) & SN040_2 == .)
replace SN040_3 = 0 if ((SN040_2 != . | SN040_1 != .) & SN040_3 == .)

global vars02 "SN040_1 SN040_2 SN040_3 SN014 SN079 SN106 SN119 SN156 SN328 SN180 SN194 SN333 SN338 SN239"

foreach y of global vars02 {
replace `y' = (`y' * (116.567/104.187))
}

gen mc_hmo_all = SN014
gen private_medigap_all = SN040_1 + SN040_2 + SN040_3
gen ltc_all = SN079
gen hospital_all = SN106
gen nursing_home_all = SN119
gen doctor_all = SN156 
gen hospice_all = SN328
gen RX_all = SN180
gen home_all = SN194
gen other_all = SN333
gen nmed_all = SN338
gen special_all = SN239

keep mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all doctor_all hospice_all RX_all home_all other_all nmed_all special_all

save "${buildoutput}/2002exit_exp.dta", replace

***************************************************************
use "${rawdata}/X04N_R.dta", clear
keep TN014 TN079 TN040_1 TN040_2 TN040_3 TN106 TN119 TN156 TN328 TN180 TN194 TN333 TN338 TN239 

replace TN014 = . if (TN014 == 998 | TN014 == 999)
replace TN079 = . if (TN079 == 99998 | TN079 == 99999)
replace TN040_1 = . if (TN040_1 == 9998 | TN040_1 == 9999)
replace TN040_2 = . if (TN040_2 == 9998 | TN040_2 == 9999)
replace TN040_3 = . if (TN040_3 == 9998 | TN040_3 == 9999)
replace TN106 = . if (TN106 == 99998 | TN106 == 999999)
replace TN119 = . if (TN119 == 999998 | TN119 == 999999)
replace TN156 = . if (TN156 == 99998 | TN156 == 99999)
replace TN328 = . if (TN328 == 99998 | TN328 == 99999)
replace TN180 = . if (TN180 == 9998 | TN180 == 9999)
replace TN194 = . if (TN194 == 99998 | TN194 == 99999)
replace TN333 = . if (TN333 == 99998 | TN333 == 99999)
replace TN338 = . if (TN338 == 999998 | TN338 == 999999)
replace TN239 = . if (TN239 == 99998 | TN239 == 99999)

replace TN040_1 = 0 if (TN040_2 != . & TN040_1 == .)
replace TN040_2 = 0 if (TN040_1 != . & TN040_2 == .)

global vars04 "TN040_1 TN040_2 TN040_3 TN014 TN079 TN106 TN119 TN156 TN328 TN180 TN194 TN333 TN338 TN239"

foreach y of global vars04 {
replace `y' = (`y' * (116.567/109.462))
}

gen mc_hmo_all = TN014
gen private_medigap_all = TN040_1 + TN040_2
gen ltc_all = TN079
gen hospital_all = TN106
gen nursing_home_all = TN119
gen doctor_all = TN156 
gen hospice_all = TN328
gen RX_all = TN180
gen home_all = TN194
gen other_all = TN333
gen nmed_all = TN338
gen special_all = TN239

keep mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all doctor_all hospice_all RX_all home_all other_all nmed_all special_all

save "${buildoutput}/2004exit_exp.dta", replace

**********************************************************

use "${rawdata}/X06N_R.dta", clear
keep UN014 UN079 UN040_1 UN040_2 UN040_3 UN106 UN119 UN156 UN328 UN180 UN194 UN333 UN338 UN239

replace UN014 = . if (UN014 == 998 | UN014 == 999)
replace UN079 = . if (UN079 == 999998 | UN079 == 999999)
replace UN040_1 = . if (UN040_1 == 998 | UN040_1 == 999)
replace UN040_2 = . if (UN040_2 == 998 | UN040_2 == 999)
replace UN040_3 = . if (UN040_3 == 998 | UN040_3 == 999)
replace UN106 = . if (UN106 == 9999998 | UN106 == 9999999)
replace UN119 = . if (UN119 == 9999998 | UN119 == 9999999)
replace UN156 = . if (UN156 == 9999998 | UN156 == 9999999)
replace UN328 = . if (UN328 == 9999998 | UN328 == 9999999)
replace UN180 = . if (UN180 == 99998 | UN180 == 99999)
replace UN194 = . if (UN194 == 999998 | UN194 == 999999)
replace UN333 = . if (UN333 == 999998 | UN333 == 999999)
replace UN338 = . if (UN338 == 999998 | UN338 == 999999)
replace UN239 = . if (UN239 == 9999998 | UN239 == 9999999)

replace UN040_1 = 0 if ((UN040_2 != . | UN040_3 != .) & UN040_1 == .)
replace UN040_2 = 0 if ((UN040_1 != . | UN040_3 != .) & UN040_2 == .)
replace UN040_3 = 0 if ((UN040_2 != . | UN040_1 != .) & UN040_3 == .)

gen mc_hmo_all = UN014
gen private_medigap_all = UN040_1 + UN040_2 + UN040_3
gen ltc_all = UN079
gen hospital_all = UN106
gen nursing_home_all = UN119
gen doctor_all = UN156 
gen hospice_all = UN328
gen RX_all = UN180
gen home_all = UN194
gen other_all = UN333
gen nmed_all = UN338
gen special_all = UN239

keep mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all doctor_all hospice_all RX_all home_all other_all nmed_all special_all

save "${buildoutput}/2006exit_exp.dta", replace


/****************************************************************
	SECTION 2: Merge
****************************************************************/

append using "${buildoutput}/2004exit_exp.dta"
append using "${buildoutput}/2002exit_exp.dta"
append using "${buildoutput}/2000exit_exp.dta"
append using "${buildoutput}/1998exit_exp.dta"

save "${buildoutput}/exit_expenditures.dta", replace

erase "${buildoutput}/1998exit_exp.dta"
erase "${buildoutput}/2000exit_exp.dta"
erase "${buildoutput}/2002exit_exp.dta"
erase "${buildoutput}/2004exit_exp.dta"
erase "${buildoutput}/2006exit_exp.dta"


log close
