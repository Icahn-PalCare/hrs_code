/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			1998build.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the 1998 exit file


ORGANIZATION:	Section 1: Create the helper files
				Section 2: Merge the files together
				
INPUTS: 		X98A_R.dta X98E_HP.dta X98E_R.dta X98R_R.dta 
				${trversion} exit_expenditures.dta
				
OUTPUTS: 		98helper.dta 1998exit.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Create the helper file
****************************************************************/

use  "${rawdata}/X98E_HP.dta", clear

gen OOP_temp = Q2117
gen time_temp = Q2118
gen DK_temp = Q2120
gen YN_temp = Q2115
do "${deps}/helper_98.do"

save "${buildoutput}/98helper.dta",replace

use  "${rawdata}/X98E_HP.dta", clear

gen OOP_temp = Q2133
gen time_temp = Q2134
gen DK_temp = Q2136
gen YN_temp = Q2131
do "${deps}/helper_98.do"
rename helper_OOP helper_OOP2
replace helper_OOP2 = 0 if helper_OOP2 == .

merge 1:1 HHID PN using "${buildoutput}/98helper.dta", nogen
replace helper_OOP = (helper_OOP + helper_OOP2)

save "${buildoutput}/98helper.dta",replace

/****************************************************************
	SECTION 2: Merge the files together
****************************************************************/

use "${rawdata}/X98R_R.dta", clear

merge 1:1 HHID PN using "${rawdata}/X98E_R.dta", nogen

merge 1:1 HHID PN using "${rawdata}/X98CS_R.dta", nogen


merge 1:1 HHID PN using "${buildoutput}/98helper.dta", nogen

merge 1:1 HHID PN using "${rawdata}/X98A_R.dta", nogen

/*
merge 1:1 HHID PN using "C:\Documents and Settings\Administrator\My Documents\
	Sam Marshall\Economics\projects\exit_data\max_expenditures.dta"
*/

merge 1:1 HHID PN using "${rawdata}/${trversion}"

rename _merge dead98

append using "${buildoutput}/exit_expenditures.dta"

save "${buildoutput}/1998exit.dta", replace
