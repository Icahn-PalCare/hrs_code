* creates an upper and lower bound for repute program
gen hospice_low = .
gen hospice_high = .


	replace hospice_low = 0 if Q1777 == 1
	replace hospice_high = 500 if Q1777 == 1

	replace hospice_low = 20000 if Q1773 == 1
	replace hospice_high = 0 if Q1773 == 1

	replace hospice_low = 0 if (Q1772 == 8 | Q1771 == 9) 
	replace hospice_high = 999999 if (Q1772 == 8 | Q1771 == 9) 
