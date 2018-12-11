* creates an upper and lower bound for repute program
gen other_low = .
gen other_high = .

	replace other_low = 0 if R1840 == 1
	replace other_high = 500 if R1840 == 1

	replace other_low = 500 if R1840 == 3
	replace other_high = 500 if R1840 == 3

	replace other_low = 500 if R1840 == 5
	replace other_high = 1000 if R1840 == 5

	replace other_low = 0 if R1840 == 8
	replace other_high = 1000 if R1840 == 8

	replace other_low = 1000 if R1839 == 3
	replace other_high = 1000 if R1839 == 3

	replace other_low = 1000 if R1839 == 5
	replace other_high = 5000 if R1839 == 5

	replace other_low = 0 if R1839 == 8
	replace other_high = 5000 if R1839 == 8

	replace other_low = 10000 if R1838 == 1
	replace other_high = 20000 if R1838 == 1

	replace other_low = 20000 if R1838 == 5
	replace other_high = 999999 if R1838 == 5

	replace other_low = 10000 if R1837 == 3
	replace other_high = 10000 if R1837 == 3

	replace other_low = 5000 if R1837 == 8
	replace other_high = 999999 if R1837 == 8

	replace other_low = 5000 if R1836 == 3
	replace other_high = 5000 if R1836 == 3

	replace other_low = 0 if R1836 == 8
	replace other_high = 999999 if R1836 == 8

