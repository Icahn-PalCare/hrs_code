/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			2004build.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Create the 2004 exit file


ORGANIZATION:	Section 1: Create the helper files
				Section 2: Merge the files together
				
INPUTS: 		X04A_R.dta X04G_HP.dta X04N_R.dta
				${trversion} exit_expenditures.dta
				
OUTPUTS: 		04helper.dta 2004exit.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Create the helper file
****************************************************************/

use  "${rawdata}/X04G_HP.dta", clear

gen OOP_temp = TG078
gen time_temp = TG079
gen DK_temp = TG080
gen YN_temp = TG076
do "${deps}/helper.do"

save "${buildoutput}/04helper.dta",replace

/****************************************************************
	SECTION 2: Merge the files together
****************************************************************/

use "${rawdata}/X04N_R.dta", clear

merge 1:1 HHID PN using "${rawdata}/X04A_R.dta", nogen

merge 1:1 HHID PN using "${buildoutput}/04helper.dta", nogen

merge 1:1 HHID PN using "${rawdata}/${trversion}"

rename _merge dead04

append using "${buildoutput}/exit_expenditures.dta"

save "${buildoutput}/2004exit.dta", replace
