/*****************************************************************
PROJECT: 		HRS OOP Expenditure in the last 5 years
				
TITLE:			Table3-2.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	18th September 2018

LAST EDITED:	18th September 2018

DESCRIPTION: 	Replicate Table 3.2 in MMS 2011 with replication data


ORGANIZATION:	
				
INPUTS: 		MMS2011_replication.dta
				
OUTPUTS: 		Table 3-2.xlsx
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Define Table Function
****************************************************************/

capture program drop t3
program define t3
	version 13
	syntax varlist, yr(int) col(string)
	
	qui count if year == `yr'  // sample size
	putexcel `col'3=("`yr'") `col'4=("(n = `r(N)')")
	
	* age
	qui sum age if year == `yr' [aweight = wt], det
	putexcel `col'5=(round(`r(mean)', 0.1))
	
	* male
	qui sum male if year == `yr' [aweight = wt], det
	putexcel `col'6=(round(`r(mean)', 0.001))
	
	* years of schooling
	qui sum SCHLYRS if year == `yr' [aweight = wt], det
	putexcel `col'7=(round(`r(mean)', 0.1))
	
	* nonwhite
	qui sum nonwhite if year == `yr' [aweight = wt], det
	putexcel `col'8=(round(`r(mean)', 0.001))
	
	* hispanic
	qui sum HISPANIC if year == `yr' [aweight = wt], det
	putexcel `col'9=(round(`r(mean)', 0.001))
	
	* birth year
	qui sum BIRTHYR if year == `yr' [aweight = wt], det
	putexcel `col'10=(round(`r(mean)', 0.1))
	
	* total OOP
	qui sum total_OOP if year == `yr' [aweight = wt], det
	putexcel `col'11=(round(`r(mean)'))

end

/****************************************************************
	SECTION 2: Clean data
****************************************************************/

use "${OOPdata}/MMS2011_replication.dta", clear

gen male = GENDER == 1

recode BIRTHYR (0 = .)
gen age = death_year - BIRTHYR
replace age = . if age == 0

recode SCHLYRS (99 = .)

gen nonwhite = RACE != 1

recode HISPANIC (5 = 0) (2/3 = 1)

/****************************************************************
	SECTION 3: Create Table
****************************************************************/

putexcel set "${output}/Table3-2.xlsx", replace
putexcel A1=("Table 3.2 Variable means, total and by year 1998 to 2006")
putexcel B2=("Year of exit interview") A5=("Age at death") A6=("Sex(1 - male)") 
putexcel A7=("Years of Schooling") A8=("Nonwhite") A9=("Hispanic") ///
A10=("Birth year") A11=("OOP expenditures") ///
A12=("Net Worth (less house equity) in prior period") ///
	A13=("Net worth in prior period") A14=("Income in prior period") A15=("Note:")
	
* All column
qui count
putexcel B3=("All") B4=("(n = `r(N)')")

qui sum age [aweight = wt], det
putexcel B5=(round(`r(mean)', 0.1))

qui sum male [aweight = wt], det
putexcel B6=(`r(mean)')

qui sum SCHLYRS [aweight = wt], det
putexcel B7=(`r(mean)')

* nonwhite
qui sum nonwhite [aweight = wt], det
putexcel B8=(round(`r(mean)', 0.001))

* hispanic
qui sum HISPANIC [aweight = wt], det
putexcel B9=(round(`r(mean)', 0.001))
	
* birth year
qui sum BIRTHYR [aweight = wt], det
putexcel B10=(round(`r(mean)', 0.1))
	
* total OOP
qui sum total_OOP [aweight = wt], det
	putexcel B11=(round(`r(mean)'))

t3 total_OOP, yr(1998) col("C")
t3 total_OOP, yr(2000) col("D")
t3 total_OOP, yr(2002) col("E")
t3 total_OOP, yr(2004) col("F")
t3 total_OOP, yr(2006) col("G")

