* creates an upper and lower bound for repute program
gen rx_low = .
gen rx_high = .

	replace rx_low = 0 if Q1801 == 1
	replace rx_high = 5 if Q1801 == 1

	replace rx_low = 5 if Q1801 == 3
	replace rx_high = 5 if Q1801 == 3

	replace rx_low = 5 if Q1801 == 5
	replace rx_high = 10 if Q1801 == 5

	replace rx_low = 0 if (Q1801 == 8| Q1801 == 9)
	replace rx_high = 10 if (Q1801 == 8| Q1801 == 9)

	replace rx_low = 10 if Q1800 == 3
	replace rx_high = 10 if Q1800 == 3

	replace rx_low = 10 if Q1800 == 5
	replace rx_high = 20 if Q1800 == 5

	replace rx_low = 0 if (Q1800 == 8 | Q1800 == 9)
	replace rx_high = 20 if (Q1800 == 8 | Q1800 == 9)

	replace rx_low = 20 if Q1799 == 3
	replace rx_high = 20 if Q1799 == 3

	replace rx_low = 20 if Q1799 == 5
	replace rx_high = 100 if Q1799 == 5

	replace rx_low = 0 if (Q1799 == 8 | Q1799 == 9)
	replace rx_high = 100 if (Q1799 == 8 | Q1799 == 9)

	replace rx_low = 100 if Q1798 == 1
	replace rx_high = 500 if Q1798 == 1

	replace rx_low = 500 if Q1798 == 3
	replace rx_high = 500 if Q1798 == 3

	replace rx_low = 500 if Q1798 == 5
	replace rx_high = 999999 if Q1798 == 5

	replace rx_low = 100 if (Q1798 == 8 | Q1798 == 9)
	replace rx_high = 999999 if (Q1798 == 8 | Q1798 == 9)

	replace rx_low = 20 if Q1797 == 1
	replace rx_high = 100 if Q1797 == 1

	replace rx_low = 100 if Q1797 == 3
	replace rx_high = 100 if Q1797 == 3

		replace rx_low = 20 if ((Q1797 == 8 | Q1797 == 9) & Q1796 == 5)
		replace rx_high = 999999 if ((Q1797 == 8 | Q1797 == 9) & Q1796 == 5)

		replace rx_low = 0 if ((Q1797 == 8 | Q1797 == 9) & Q1796 != 5)
		replace rx_high = 999999 if ((Q1797 == 8 | Q1797 == 9) & Q1796 != 5)

	replace rx_low = 10 if Q1796 == 1
	replace rx_high = 20 if Q1796 == 1

	replace rx_low = 20 if Q1796 == 3
	replace rx_high = 20 if Q1796 == 3

		replace rx_low = 10 if ((Q1796 == 8 | Q1796 == 9) & Q1795 == 5)
		replace rx_high = 999999 if ((Q1796 == 8 | Q1796 == 9) & Q1795 == 5)

	replace rx_low = 0 if ((Q1796 == 8 | Q1796 == 9) & Q1795 != 5)
	replace rx_high = 999999 if ((Q1796 == 8 | Q1796 == 9) & Q1795 != 5)

	replace rx_low = 10 if Q1795 == 3
	replace rx_high = 10 if Q1795 == 3

	replace rx_low = 0 if (Q1795 == 8 | Q1795 == 9)
	replace rx_high = 999999 if (Q1795 == 8 | Q1795 == 9)