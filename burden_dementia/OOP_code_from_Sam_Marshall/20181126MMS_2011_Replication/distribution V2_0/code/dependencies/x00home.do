* creates an upper and lower bound for repute program
gen home_low = .
gen home_high = .

	replace home_low = 0 if R1832 == 1
	replace home_high = 500 if R1832 == 1

	replace home_low = 500 if R1832 == 3
	replace home_high = 500 if R1832 == 3

	replace home_low = 500 if R1832 == 5
	replace home_high = 1000 if R1832 == 5

	replace home_low = 0 if (R1832 == 8| R1832 == 9)
	replace home_high = 1000 if (R1832 == 8| R1832 == 9)

	replace home_low = 1000 if R1831 == 3
	replace home_high = 1000 if R1831 == 3

	replace home_low = 1000 if R1831 == 5
	replace home_high = 5000 if R1831 == 5

	replace home_low = 0 if (R1831 == 8 | R1831 == 9)
	replace home_high = 5000 if (R1831 == 8 | R1831 == 9)

	replace home_low = 20000 if R1830 == 3
	replace home_high = 20000 if R1830 == 3

	replace home_low = 10000 if R1830 == 1
	replace home_high = 20000 if R1830 == 1

	replace home_low = 5000 if R1829 == 1
	replace home_high = 10000 if R1829 == 1

	replace home_low = 10000 if R1829 == 3
	replace home_high = 10000 if R1829 == 3

	replace home_low = 5000 if R1828 == 3
	replace home_high = 5000 if R1828 == 3

	replace home_low = 0 if (R1828 == 8 | R1828 == 9)
	replace home_high = 999999 if (R1828 == 8 | R1828 == 9)

