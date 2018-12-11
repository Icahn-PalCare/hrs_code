* this will create the amt paid OOP for an inhome helper. cut off is 15K

gen helper_OOP = OOP_temp
replace helper_OOP = . if (OOP_temp == 99998 | OOP_temp == 99999)

* makes responses in terms of 4 months
replace helper_OOP = (helper_OOP * 4) if time_temp == 1 
replace helper_OOP = (helper_OOP * 17) if time_temp == 2 
replace helper_OOP = (helper_OOP * 122) if time_temp == 3 
replace helper_OOP = (helper_OOP / 3) if time_temp == 5

* adds in the DK responses
replace helper_OOP = 50 if DK_temp == 1
replace helper_OOP = 100 if DK_temp == 3
replace helper_OOP = 110 if DK_temp == 5 

* adds in the zeros
replace helper_OOP = 0 if (YN_temp == 5 & helper_OOP == .)

* assigns the mean to DKs
sum helper_OOP if helper_OOP > 0
replace helper_OOP = r(mean) if (inlist( OOP_temp, 99998, 99999) | ///
	inlist( YN_temp, 8, 9)) & (helper_OOP == .)


collapse (sum) helper_OOP, by (HHID PN)

