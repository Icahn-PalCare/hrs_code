/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			Table3-4.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	18th September 2018

LAST EDITED:	21st September 2018

DESCRIPTION: 	Replicate Table 3.4 in MMS 2011


ORGANIZATION:	Section 1: Define table function
				Section 2: Estimation
				Section 3: 
				
INPUTS: 		XyrOOP.dta files
				
OUTPUTS: 		Table3-4.xlsx
				
NOTE:			The quantiles are estimated without weights here and hence
				will not match the values in the paper exactly.
******************************************************************/

/****************************************************************
	SECTION 1: Define table function
****************************************************************/

capture program drop t4
program define t4
	version 13
	syntax varlist, n(string) r(int)
	
	putexcel A`r'=("`n'")  // variable name
	
	regress `1' months months2 months3 months4 [aweight = wt]
	local rm = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel B`r'=(round(`rm'))
	
	qreg `1' months months2 months3 months4, quantile(.5)
	local p50 = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel C`r'=(round(`p50'))
	
	qreg `1' months months2 months3 months4, quantile(.75)
	local p75 = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel D`r'=(round(`p75'))
	
	qreg `1' months months2 months3 months4, quantile(.90)
	local p90 = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel E`r'=(round(`p90'))
	
	qreg `1' months months2 months3 months4, quantile(.95)
	local p95 = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel F`r'=(round(`p95'))
	
	qreg `1' months months2 months3 months4, quantile(.99)
	local p99 = _b[_cons] + _b[months]*12 + _b[months2]*12^2 + _b[months3]*12^3 + _b[months4]*12^4
	quietly putexcel G`r'=(round(`p99'))

end

/****************************************************************
	SECTION 2: Estimation
****************************************************************/

use "${OOPdata}/MMS2011_replication.dta", clear

gen months2 = months^2
gen months3 = months^3
gen months4 = months^4

putexcel set "${output}/Table3-4.xlsx", replace
putexcel A1=("Table 3.4 Distribution of expenditure by category for exit interviews, normalized to a twelve-month period")
putexcel A2=("Variable") B2=("Mean") C2=("Median") D2=("p75") E2=("p90") ///
	F2=("p95") G2=("p99")
	
t4 total_OOP , n("Total OOP") r(3)
t4 insurance_costs , n("Insurance") r(4)
t4 RX_OOP , n("Drugs") r(5)
t4 doctor_OOP , n("Physician") r(6)
t4 nh_hosp , n("Nursing home/hosp.") r(7)
t4 other_OOP , n("Other and special") r(8)
t4 home_OOP , n("Home health") r(9)
t4 non_med_OOP , n("Nonmedical") r(10)
t4 helper_OOP , n("Helpers") r(11)
t4 hospice_OOP , n("Hospice") r(12)

putexcel A13=("Notes:")
