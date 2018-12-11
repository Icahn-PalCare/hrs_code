/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			2006build.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the 2006 exit file


ORGANIZATION:	Section 1: Create the helper files
				Section 2: Merge the files together
				
INPUTS: 		X06A_R.dta X06G_HP.dta X06N_R.dta
				${trversion} exit_expenditures.dta
				
OUTPUTS: 		06helper.dta 2006exit.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Create the helper file
****************************************************************/
use  "${rawdata}/X06G_HP.dta", clear


gen OOP_temp = UG078
gen time_temp = UG079
gen DK_temp = UG080
gen YN_temp = UG076
do "${deps}/helper.do"

save "${buildoutput}/06helper.dta",replace

/****************************************************************
	SECTION 2: Merge the files together
****************************************************************/

use "${rawdata}/X06N_R.dta", clear

merge 1:1 HHID PN using "${rawdata}/X06A_R.dta"

rename _merge dead06

merge 1:1 HHID PN using "${buildoutput}/06helper.dta", nogen

merge 1:1 HHID PN using "${rawdata}/${trversion}"

append using "${buildoutput}/exit_expenditures.dta"

save "${buildoutput}/2006exit.dta",replace
