* creates an upper and lower bound for repute program
gen dr_low = .
gen dr_high = .

	replace dr_low = 0 if R1807 == 1
	replace dr_high = 200 if R1807 == 1

	replace dr_low = 200 if R1807 == 3
	replace dr_high = 200 if R1807 == 3

	replace dr_low = 200 if R1807 == 5
	replace dr_high = 500 if R1807 == 5

	replace dr_low = 0 if (R1807 == 8| R1807 == 9)
	replace dr_high = 500 if (R1807 == 8| R1807 == 9)

	replace dr_low = 500 if R1806 == 3
	replace dr_high = 500 if R1806 == 3

	replace dr_low = 500 if R1806 == 5
	replace dr_high = 1000 if R1806 == 5

	replace dr_low = 0 if (R1806 == 8 | R1806 == 9)
	replace dr_high = 1000 if (R1806 == 8 | R1806 == 9)

	replace dr_low = 1000 if R1805 == 3
	replace dr_high = 1000 if R1805 == 3

	replace dr_low = 1000 if R1805 == 5
	replace dr_high = 5000 if R1805 == 5

	replace dr_low = 0 if (R1805 == 8 | R1805 == 9)
	replace dr_high = 5000 if (R1805 == 8 | R1805 == 9)

	replace dr_low = 5000 if R1804 == 1
	replace dr_high = 20000 if R1804 == 1

	replace dr_low = 20000 if R1804 == 3
	replace dr_high = 20000 if R1804 == 3

	replace dr_low = 20000 if R1804 == 5
	replace dr_high = 999999 if R1804 == 5

	replace dr_low = 5000 if (R1804 == 8 | R1804 == 9)
	replace dr_high = 999999 if (R1804 == 8 | R1804 == 9)

	replace dr_low = 1000 if R1803 == 1
	replace dr_high = 5000 if R1803 == 1

	replace dr_low = 5000 if R1803 == 3
	replace dr_high = 5000 if R1803 == 3

		replace dr_low = 1000 if ((R1803 == 8 | R1803 == 9) & R1802 == 5)
		replace dr_high = 999999 if ((R1803 == 8 | R1803 == 9) & R1802 == 5)

		replace dr_low = 0 if ((R1803 == 8 | R1803 == 9) & R1802 != 5)
		replace dr_high = 999999 if ((R1803 == 8 | R1803 == 9) & R1802 != 5)

	replace dr_low = 500 if R1802 == 1
	replace dr_high = 1000 if R1802 == 1

	replace dr_low = 1000 if R1802 == 3
	replace dr_high = 1000 if R1802 == 3

		replace dr_low = 500 if ((R1802 == 8 | R1802 == 9) & R1801 == 5)
		replace dr_high = 999999 if ((R1802 == 8 | R1802 == 9) & R1801 == 5)

	replace dr_low = 0 if ((R1802 == 8 | R1802 == 9) & R1801 != 5)
	replace dr_high = 999999 if ((R1802 == 8 | R1802 == 9) & R1801 != 5)

	replace dr_low = 500 if R1801 == 3
	replace dr_high = 500 if R1801 == 3

	replace dr_low = 0 if (R1801 == 8 | R1801 == 9)
	replace dr_high = 999999 if (R1801 == 8 | R1801 == 9)