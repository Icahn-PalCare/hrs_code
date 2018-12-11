* creates an upper and lower bound for repute program
gen hospice_low = .
gen hospice_high = .

	replace hospice_low = 0 if R1788 == 1
	replace hospice_high = 500 if R1788 == 1

	replace hospice_low = 500 if R1788 == 3
	replace hospice_high = 500 if R1788 == 3

	replace hospice_low = 10000 if R1783 == 3
	replace hospice_high = 10000 if R1783 == 3

	replace hospice_low = 5000 if R1782 == 5
	replace hospice_high = 999999 if R1782 == 5

	replace hospice_low = 0 if (R1783 == 5 & R1782 == .)
	replace hospice_high = 999999 if (R1783 == 5 & R1782 == .)
