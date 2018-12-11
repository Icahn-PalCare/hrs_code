/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			Table3-3.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	19th July 2018

LAST EDITED:	18th July 2018

DESCRIPTION: 	Replicate Table 3.3 in MMS 2011 using original and replication
				data.


ORGANIZATION:	Section 0: Set Up
				Section 1: Replicate Using Existing data
				Section 2: Make Table using 2011 data
				Section 3: Make Table using do files data
				Section 4: Make Table using exit_bld data
				
INPUTS: 		XyrOOP.dta files
				
OUTPUTS: 		Table3-3.xlsx
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Set Up
****************************************************************/

capture program drop t3
program define t3
	version 13
	syntax varlist, n(string) r(int)

	quietly sum `1' [aweight = wt], det
	putexcel A`r'=("`n'") B`r'=(r(mean)) C`r'=(r(p50)) D`r'=(r(p75)) ///
		E`r'=(r(p90)) F`r'=(r(p95)) G`r'=(r(max))
	
end

/****************************************************************
	SECTION 1: Replicate Table 3-3 using existing data
****************************************************************/

use "${OOPdata}/MMS2011_actual.dta", clear

putexcel set "${output}/Table3-3.xlsx", replace
putexcel A1=("Table 3.3 Distribution of expenditure by category for exit interviews")
putexcel A2=("Variable") B2=("Mean") C2=("Median") D2=("p75") E2=("p90") ///
	F2=("p95") G2=("Maximum")
	
t3 total_OOP , n("Total OOP") r(3)
t3 insurance_costs , n("Insurance") r(4)
t3 RX_OOP , n("Drugs") r(5)
t3 doctor_OOP , n("Physician") r(6)
t3 nh_hosp , n("Nursing home/hosp.") r(7)
t3 other_OOP , n("Other and special") r(8)
t3 home_OOP , n("Home health") r(9)
t3 non_med_OOP , n("Nonmedical") r(10)
t3 helper_OOP , n("Helpers") r(11)
t3 hospice_OOP , n("Hospice") r(12)
	


/****************************************************************
	SECTION 2: Make Table 3-3 Using 2011 data
****************************************************************/
	
use "${OOPdata}/MMS2011_replication.dta", clear
	
putexcel set "${output}/Table3-3.xlsx", sheet(3, replace) modify
putexcel A1=("Table 3.3 Distribution of expenditure by category for exit interviews")
putexcel A2=("Variable") B2=("Mean") C2=("Median") D2=("p75") E2=("p90") ///
	F2=("p95") G2=("Maximum")
	
t3 total_OOP , n("Total OOP") r(3)
t3 insurance_costs , n("Insurance") r(4)
t3 RX_OOP , n("Drugs") r(5)
t3 doctor_OOP , n("Physician") r(6)
t3 nh_hosp , n("Nursing home/hosp.") r(7)
t3 other_OOP , n("Other and special") r(8)
t3 home_OOP , n("Home health") r(9)
t3 non_med_OOP , n("Nonmedical") r(10)
t3 helper_OOP , n("Helpers") r(11)
t3 hospice_OOP , n("Hospice") r(12)

putexcel A13=("Footnote: Using Replication data")





