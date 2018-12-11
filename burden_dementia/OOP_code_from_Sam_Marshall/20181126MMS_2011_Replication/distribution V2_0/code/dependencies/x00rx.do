* creates an upper and lower bound for repute program
gen rx_low = .
gen rx_high = .

	replace rx_low = 0 if R1817 == 1
	replace rx_high = 5 if R1817 == 1

	replace rx_low = 5 if R1817 == 3
	replace rx_high = 5 if R1817 == 3

	replace rx_low = 5 if R1817 == 5
	replace rx_high = 10 if R1817 == 5

	replace rx_low = 0 if (R1817 == 8| R1817 == 9)
	replace rx_high = 10 if (R1817 == 8| R1817 == 9)

	replace rx_low = 10 if R1816 == 3
	replace rx_high = 10 if R1816 == 3

	replace rx_low = 10 if R1816 == 5
	replace rx_high = 20 if R1816 == 5

	replace rx_low = 0 if (R1816 == 8 | R1816 == 9)
	replace rx_high = 20 if (R1816 == 8 | R1816 == 9)

	replace rx_low = 20 if R1815 == 3
	replace rx_high = 20 if R1815 == 3

	replace rx_low = 20 if R1815 == 5
	replace rx_high = 100 if R1815 == 5

	replace rx_low = 0 if (R1815 == 8 | R1815 == 9)
	replace rx_high = 100 if (R1815 == 8 | R1815 == 9)

	replace rx_low = 100 if R1814 == 1
	replace rx_high = 500 if R1814 == 1

	replace rx_low = 500 if R1814 == 3
	replace rx_high = 500 if R1814 == 3

	replace rx_low = 500 if R1814 == 5
	replace rx_high = 999999 if R1814 == 5

	replace rx_low = 100 if (R1814 == 8 | R1814 == 9)
	replace rx_high = 999999 if (R1814 == 8 | R1814 == 9)

	replace rx_low = 20 if R1813 == 1
	replace rx_high = 100 if R1813 == 1

	replace rx_low = 100 if R1813 == 3
	replace rx_high = 100 if R1813 == 3

		replace rx_low = 20 if ((R1813 == 8 | R1813 == 9) & R1812 == 5)
		replace rx_high = 999999 if ((R1813 == 8 | R1813 == 9) & R1812 == 5)

		replace rx_low = 0 if ((R1813 == 8 | R1813 == 9) & R1812 != 5)
		replace rx_high = 999999 if ((R1813 == 8 | R1813 == 9) & R1812 != 5)

	replace rx_low = 10 if R1812 == 1
	replace rx_high = 20 if R1812 == 1

	replace rx_low = 20 if R1812 == 3
	replace rx_high = 20 if R1812 == 3

		replace rx_low = 10 if ((R1812 == 8 | R1812 == 9) & R1811 == 5)
		replace rx_high = 999999 if ((R1812 == 8 | R1812 == 9) & R1811 == 5)

	replace rx_low = 0 if ((R1812 == 8 | R1812 == 9) & R1811 != 5)
	replace rx_high = 999999 if ((R1812 == 8 | R1812 == 9) & R1811 != 5)

	replace rx_low = 10 if R1811 == 3
	replace rx_high = 10 if R1811 == 3

	replace rx_low = 0 if (R1811 == 8 | R1811 == 9)
	replace rx_high = 999999 if (R1811 == 8 | R1811 == 9)