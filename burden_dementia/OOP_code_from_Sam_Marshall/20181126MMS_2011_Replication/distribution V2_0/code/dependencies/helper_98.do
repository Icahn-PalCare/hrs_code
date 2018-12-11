* this will create the amt paid OOP for an inhome helper. cut off is 15K

gen helper_OOP = OOP_temp
replace helper_OOP = . if (OOP_temp == 99998 | OOP_temp == 99999)

* makes responses in terms of 1 months
replace helper_OOP = (helper_OOP * 6) if time_temp == 1 
replace helper_OOP = (helper_OOP * 26) if time_temp == 2 
replace helper_OOP = (helper_OOP * 182) if time_temp == 3 
replace helper_OOP = (helper_OOP / 2) if time_temp == 5

* adds in the DK responses
replace helper_OOP = 50 if DK_temp == 1
replace helper_OOP = 100 if DK_temp == 2
replace helper_OOP = 110 if DK_temp == 3 

* adds in the zeros
replace helper_OOP = 0 if YN_temp == 5

* assigns the mean to DKs
egen avg_helper_OOP = mean(helper_OOP) if (helper_OOP != 0)
#del ;
replace helper_OOP = avg_helper_OOP if (((OOP_temp == 99998 | OOP_temp == 99999) | 
(YN_temp == 8 | YN_temp == 9)) & (helper_OOP == .));
#del cr;

collapse (sum) helper_OOP, by (HHID PN)
