* creates an upper and lower bound for repute program
gen home_low = .
gen home_high = .

	replace home_low = 0 if Q1816 == 1
	replace home_high = 500 if Q1816 == 1

	replace home_low = 500 if Q1816 == 3
	replace home_high = 500 if Q1816 == 3

	replace home_low = 500 if Q1816 == 5
	replace home_high = 1000 if Q1816 == 5

	replace home_low = 0 if (Q1816 == 8| Q1816 == 9)
	replace home_high = 1000 if (Q1816 == 8| Q1816 == 9)

	replace home_low = 1000 if Q1815 == 3
	replace home_high = 1000 if Q1815 == 3

	replace home_low = 1000 if Q1815 == 5
	replace home_high = 5000 if Q1815 == 5

	replace home_low = 0 if (Q1815 == 8 | Q1815 == 9)
	replace home_high = 5000 if (Q1815 == 8 | Q1815 == 9)

	replace home_low = 20000 if Q1814 == 3
	replace home_high = 20000 if Q1814 == 3

	replace home_low = 10000 if Q1814 == 1
	replace home_high = 20000 if Q1814 == 1

	replace home_low = 5000 if Q1813 == 1
	replace home_high = 10000 if Q1813 == 1

	replace home_low = 10000 if Q1813 == 3
	replace home_high = 10000 if Q1813 == 3

	replace home_low = 5000 if Q1812 == 3
	replace home_high = 5000 if Q1812 == 3

	replace home_low = 0 if (Q1812 == 8 | Q1812 == 9)
	replace home_high = 999999 if (Q1812 == 8 | Q1812 == 9)

