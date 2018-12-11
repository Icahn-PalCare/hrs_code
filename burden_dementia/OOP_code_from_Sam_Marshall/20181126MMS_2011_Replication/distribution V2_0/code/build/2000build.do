/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			2000build.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the 2000 exit file


ORGANIZATION:	Section 1: Create the helper files
				Section 2: Merge the files together
				
INPUTS: 		X00A_R.dta X00E_HP.dta X00E_R.dta X00R_R.dta 
				${trversion} exit_expenditures.dta
				
OUTPUTS: 		00helper.dta 2000exit.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Create the helper file
****************************************************************/

use  "${rawdata}/X00E_HP.dta", clear

gen OOP_temp = R2120
gen time_temp = R2121
gen DK_temp = R2123
gen YN_temp = R2118
do "${deps}/helper.do"

save "${buildoutput}/00helper.dta",replace

use  "${rawdata}/X00E_HP.dta", clear

gen OOP_temp = R2146
gen time_temp = R2147
gen DK_temp = R2149
gen YN_temp = R2144
do "${deps}/helper.do"
rename helper_OOP helper_OOP2

merge 1:1 HHID PN using "${buildoutput}/00helper.dta", nogen
replace helper_OOP = (helper_OOP + helper_OOP2)
*replace helper_OOP = 15000 if (helper_OOP > 15000 & helper_OOP != .)

save "${buildoutput}/00helper.dta",replace

/****************************************************************
	SECTION 2: Merge the files together
****************************************************************/


use "${rawdata}/X00R_R.dta", clear

merge 1:1 HHID PN using "${rawdata}/X00E_R.dta", nogen

merge 1:1 HHID PN using "${rawdata}/X00CS_R.dta", nogen

merge 1:1 HHID PN using "${buildoutput}/00helper.dta", nogen

merge 1:1 HHID PN using "${rawdata}/X00A_R.dta", nogen


merge 1:1 HHID PN using "${rawdata}/${trversion}"

rename _merge dead00

append using "${buildoutput}/exit_expenditures.dta"

save "${buildoutput}/2000exit.dta", replace 
