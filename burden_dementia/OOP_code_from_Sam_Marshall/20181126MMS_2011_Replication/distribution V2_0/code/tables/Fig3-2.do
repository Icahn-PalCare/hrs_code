/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			Fig3-2.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	18th September 2018

LAST EDITED:	18th September 2018

DESCRIPTION: 	Replicate Figure 3.2 in MMS 2011 with replication data


ORGANIZATION:	
				
INPUTS: 		MMS2011_replication.dta
				
OUTPUTS: 		Fig3-2.png
				
NOTE:			
******************************************************************/

use "${OOPdata}/MMS2011_replication.dta", clear

gen month_bin = 1 if months <= 3
	replace month_bin = 2 if months >= 4 & months <= 6
	replace month_bin = 3 if months >= 7 & months <= 9
	replace month_bin = 4 if months >= 10 & months <= 12
	replace month_bin = 5 if months >= 13 & months <= 15
	replace month_bin = 6 if months >= 16 & months <= 18
	replace month_bin = 7 if months >= 19 & months <= 21
	replace month_bin = 8 if months >= 22 & months <= 24
	replace month_bin = 9 if months >= 25 & months <= 30
	replace month_bin = 10 if months >= 31 & months <= 35
	
collapse (mean) total_OOP [aweight = wt], by(month_bin)

gen inc_OOP = total_OOP - total_OOP[_n-1]
replace inc_OOP = total_OOP if inc_OOP == .

label define m_bin 1 "1-3" 2 "4-6" 3 "7-9" 4 "10-12" 5 "13-15" 6 "16-18" ///
	7 "19-21" 8 "22-14" 9 "25-30" 10 "31-35"
	
label values month_bin m_bin

graph bar total_OOP inc_OOP, over(month_bin, label( angle(45))) scheme(s2mono) ///
	legend(label(1 "Cumulative OOP") label(2 "Incremental OOP"))
	
graph export "${output}/Fig3-2.png"
