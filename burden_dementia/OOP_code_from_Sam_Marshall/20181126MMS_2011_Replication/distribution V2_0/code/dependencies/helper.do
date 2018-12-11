/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			helper.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	21st September 2018

DESCRIPTION: 	Create the in home helper OOP expenditure variable. 
				Since there can be more than one helper per respondent, this 
				variable needs to be created separately from the others.


ORGANIZATION:	
				
INPUTS: 		
				
OUTPUTS: 		
				
NOTE:			The cap for this variable is 15k/month. This cap is applied
				in each exit file once the real adjustment has been made.
******************************************************************/

gen helper_OOP = OOP_temp
replace helper_OOP = . if (OOP_temp == 99998 | OOP_temp == 99999)

* Make expenditure in terms of 4 months
replace helper_OOP = (helper_OOP * 4) if time_temp == 1 
replace helper_OOP = (helper_OOP * 17) if time_temp == 2 
replace helper_OOP = (helper_OOP * 122) if time_temp == 3 
replace helper_OOP = (helper_OOP / 3) if time_temp == 5

*Assign value based on DK variable. Use 110 for > $100
replace helper_OOP = 50 if DK_temp == 1
replace helper_OOP = 100 if DK_temp == 2
replace helper_OOP = 110 if DK_temp == 3 

* People with zero cost
replace helper_OOP = 0 if (YN_temp == 5 & helper_OOP == .)

* Assign strictly positive mean to DK
qui sum helper_OOP if (helper_OOP != 0)
replace helper_OOP = r(mean) if ((OOP_temp == 99998 | OOP_temp == 99999) | ///
	(YN_temp == 8 | YN_temp == 9)) & mi(helper_OOP)

collapse (sum) helper_OOP, by (HHID PN)

