* creates an upper and lower bound for repute program
gen hospital_low = .
gen hospital_high = .

	replace hospital_low = 0 if Q1756 == 1
	replace hospital_high = 500 if Q1756 == 1

	replace hospital_low = 500 if Q1756 == 3
	replace hospital_high = 500 if Q1756 == 3

	replace hospital_low = 500 if Q1756 == 5
	replace hospital_high = 5000 if Q1756 == 5

	replace hospital_low = 0 if (Q1756 == 8| Q1756 == 9)
	replace hospital_high = 5000 if (Q1756 == 8| Q1756 == 9)

	replace hospital_low = 5000 if Q1755 == 3
	replace hospital_high = 5000 if Q1755 == 3

	replace hospital_low = 5000 if Q1755 == 5
	replace hospital_high = 10000 if Q1755 == 5

	replace hospital_low = 0 if (Q1755 == 8 | Q1755 == 9)
	replace hospital_high = 10000 if (Q1755 == 8 | Q1755 == 9)

	replace hospital_low = 10000 if Q1754 == 3
	replace hospital_high = 10000 if Q1754 == 3

	replace hospital_low = 10000 if Q1754 == 5
	replace hospital_high = 20000 if Q1754 == 5

	replace hospital_low = 0 if (Q1754 == 8 | Q1754 == 9)
	replace hospital_high = 20000 if (Q1754 == 8 | Q1754 == 9)

	replace hospital_low = 20000 if Q1753 == 1
	replace hospital_high = 50000 if Q1753 == 1

	replace hospital_low = 50000 if Q1753 == 3
	replace hospital_high = 50000 if Q1753 == 3

	replace hospital_low = 50000 if Q1753 == 5
	replace hospital_high = 999999 if Q1753 == 5

	replace hospital_low = 20000 if (Q1753 == 8 | Q1753 == 9)
	replace hospital_high = 999999 if (Q1753 == 8 | Q1753 == 9)

	replace hospital_low = 10000 if Q1752 == 1
	replace hospital_high = 20000 if Q1752 == 1

	replace hospital_low = 20000 if Q1752 == 3
	replace hospital_high = 20000 if Q1752 == 3

		replace hospital_low = 10000 if ((Q1752 == 8 | Q1752 == 9) & Q1751 == 5)
		replace hospital_high = 999999 if ((Q1752 == 8 | Q1752 == 9) & Q1751 == 5)

		replace hospital_low = 0 if ((Q1752 == 8 | Q1752 == 9) & Q1751 != 5)
		replace hospital_high = 999999 if ((Q1752 == 8 | Q1752 == 9) & Q1751 != 5)

	replace hospital_low = 5000 if Q1751 == 1
	replace hospital_high = 10000 if Q1751 == 1

	replace hospital_low = 10000 if Q1751 == 3
	replace hospital_high = 10000 if Q1751 == 3

	replace hospital_low = 0 if ((Q1751 == 8 | Q1751 == 9) | (Q1750 == 8 | Q1750 == 9))
	replace hospital_high = 999999 if ((Q1751 == 8 | Q1751 == 9) | (Q1750 == 8 | Q1750 == 9))

	replace hospital_low = 5000 if Q1750 == 3
	replace hospital_high = 5000 if Q1750 == 3
