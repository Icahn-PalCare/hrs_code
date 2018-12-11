* creates an upper and lower bound for repute program
gen dr_low = .
gen dr_high = .

	replace dr_low = 0 if Q1791 == 1
	replace dr_high = 200 if Q1791 == 1

	replace dr_low = 200 if Q1791 == 3
	replace dr_high = 200 if Q1791 == 3

	replace dr_low = 200 if Q1791 == 5
	replace dr_high = 500 if Q1791 == 5

	replace dr_low = 0 if (Q1791 == 8| Q1791 == 9)
	replace dr_high = 500 if (Q1791 == 8| Q1791 == 9)

	replace dr_low = 500 if Q1790 == 3
	replace dr_high = 500 if Q1790 == 3

	replace dr_low = 500 if Q1790 == 5
	replace dr_high = 1000 if Q1790 == 5

	replace dr_low = 0 if (Q1790 == 8 | Q1790 == 9)
	replace dr_high = 1000 if (Q1790 == 8 | Q1790 == 9)

	replace dr_low = 1000 if Q1789 == 3
	replace dr_high = 1000 if Q1789 == 3

	replace dr_low = 1000 if Q1789 == 5
	replace dr_high = 5000 if Q1789 == 5

	replace dr_low = 0 if (Q1789 == 8 | Q1789 == 9)
	replace dr_high = 5000 if (Q1789 == 8 | Q1789 == 9)

	replace dr_low = 5000 if Q1788 == 1
	replace dr_high = 20000 if Q1788 == 1

	replace dr_low = 20000 if Q1788 == 3
	replace dr_high = 20000 if Q1788 == 3

	replace dr_low = 20000 if Q1788 == 5
	replace dr_high = 999999 if Q1788 == 5

	replace dr_low = 5000 if (Q1788 == 8 | Q1788 == 9)
	replace dr_high = 999999 if (Q1788 == 8 | Q1788 == 9)

	replace dr_low = 1000 if Q1787 == 1
	replace dr_high = 5000 if Q1787 == 1

	replace dr_low = 5000 if Q1787 == 3
	replace dr_high = 5000 if Q1787 == 3

		replace dr_low = 1000 if ((Q1787 == 8 | Q1787 == 9) & Q1786 == 5)
		replace dr_high = 999999 if ((Q1787 == 8 | Q1787 == 9) & Q1786 == 5)

		replace dr_low = 0 if ((Q1787 == 8 | Q1787 == 9) & Q1786 != 5)
		replace dr_high = 999999 if ((Q1787 == 8 | Q1787 == 9) & Q1786 != 5)

	replace dr_low = 500 if Q1786 == 1
	replace dr_high = 1000 if Q1786 == 1

	replace dr_low = 1000 if Q1786 == 3
	replace dr_high = 1000 if Q1786 == 3

		replace dr_low = 500 if ((Q1786 == 8 | Q1786 == 9) & Q1785 == 5)
		replace dr_high = 999999 if ((Q1786 == 8 | Q1786 == 9) & Q1785 == 5)

	replace dr_low = 0 if ((Q1786 == 8 | Q1786 == 9) & Q1785 != 5)
	replace dr_high = 999999 if ((Q1786 == 8 | Q1786 == 9) & Q1785 != 5)

	replace dr_low = 500 if Q1785 == 3
	replace dr_high = 500 if Q1785 == 3

	replace dr_low = 0 if (Q1785 == 8 | Q1785 == 9)
	replace dr_high = 999999 if (Q1785 == 8 | Q1785 == 9)