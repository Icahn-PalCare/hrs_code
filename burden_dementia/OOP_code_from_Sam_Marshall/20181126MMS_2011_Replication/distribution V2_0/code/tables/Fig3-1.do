/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			Fig3-1.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	18th September 2018

LAST EDITED:	18th September 2018

DESCRIPTION: 	Replicate Figure 3.1 in MMS 2011 with replication data


ORGANIZATION:	
				
INPUTS: 		MMS2011_replication.dta
				
OUTPUTS: 		Fig3-1.png
				
NOTE:			
******************************************************************/

use "${OOPdata}/MMS2011_replication.dta", clear

gen ln_nh_hosp = log(nh_hosp)

hist ln_nh_hosp, xtitle("Log OOP Nursing Home & Hospital Expenses") ///
	scheme(s2mono) fcolor(gs16) 
	
graph export "${output}/Fig3-1.png"
