* creates an upper and lower bound for repute program
gen other_low = .
gen other_high = .

	replace other_low = 0 if Q1823 == 1
	replace other_high = 500 if Q1823 == 1

	replace other_low = 500 if Q1823 == 3
	replace other_high = 500 if Q1823 == 3

	replace other_low = 500 if Q1823 == 5
	replace other_high = 1000 if Q1823 == 5

	replace other_low = 1000 if Q1822 == 3
	replace other_high = 1000 if Q1822 == 3

	replace other_low = 1000 if Q1822 == 5
	replace other_high = 5000 if Q1822 == 5

	replace other_low = 10000 if Q1821 == 1
	replace other_high = 20000 if Q1821 == 1

	replace other_low = 5000 if Q1820 == 1
	replace other_high = 10000 if Q1820 == 1

	replace other_low = 5000 if Q1820 == 8
	replace other_high = 999999 if Q1820 == 8

	replace other_low = 5000 if Q1819 == 3
	replace other_high = 5000 if Q1819 == 3

	replace other_low = 0 if Q1819 == 8
	replace other_high = 999999 if Q1819 == 8
