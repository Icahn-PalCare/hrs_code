/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			exit_combine.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	19th July 2018

LAST EDITED:	18th July 2018

DESCRIPTION: 	Combine OOP files for paper data


ORGANIZATION:	Section 1: Combine and format
				
INPUTS: 		XyrOOP.dta files
				
OUTPUTS: 		MMS2011_replication.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Combine and format
****************************************************************/
	
use "${OOPdata}/X1998OOP.dta", clear
	gen year = 1998

append using "${OOPdata}/X2000OOP.dta"
	replace year = 2000 if year == .

append using "${OOPdata}/X2002OOP.dta"
	replace year = 2002 if year == .

append using "${OOPdata}/X2004OOP.dta"
	replace year = 2004 if year == .

append using "${OOPdata}/X2006OOP.dta"
	replace year = 2006 if year == .

gen wt = weight98 if year == 1998
	replace wt = weight00 if year == 2000
	replace wt = weight02 if year == 2002
	replace wt = weight04 if year == 2004
	replace wt = weight06 if year == 2006
	
egen nh_hosp = rowtotal(NH_OOP hospital_OOP), m

replace other_OOP = other_OOP + spec_OOP if spec_OOP != .

save "${OOPdata}/MMS2011_replication.dta", replace
