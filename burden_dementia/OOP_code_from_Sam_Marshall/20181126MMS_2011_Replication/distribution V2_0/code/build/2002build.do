/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			2002build.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the 2002 exit file


ORGANIZATION:	Section 1: Create the helper files
				Section 2: Merge the files together
				
INPUTS: 		X02A_R.dta X02G_HP.dta X02N_R.dta
				${trversion} exit_expenditures.dta
				
OUTPUTS: 		02helper.dta 2002exit.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Create the helper file
****************************************************************/

use  "${rawdata}/X02G_HP.dta", clear

gen OOP_temp = SG078
gen time_temp = SG079
gen DK_temp = SG080
gen YN_temp = SG076
do "${deps}/helper.do"

save "${buildoutput}/02helper.dta",replace

/****************************************************************
	SECTION 2: Merge the files together
****************************************************************/

use "${rawdata}/X02N_R.dta", clear

merge 1:1 HHID PN using "${rawdata}/X02A_R.dta", nogen

merge 1:1 HHID PN using "${buildoutput}/02helper.dta", nogen

merge 1:1 HHID PN using "${rawdata}/${trversion}"

rename _merge dead02

append using "${buildoutput}/exit_expenditures.dta"

save "${buildoutput}/2002exit.dta", replace
