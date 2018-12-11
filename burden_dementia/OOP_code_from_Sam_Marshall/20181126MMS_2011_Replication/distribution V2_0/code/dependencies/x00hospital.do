* creates an upper and lower bound for repute program
gen hospital_low = .
gen hospital_high = .

	replace hospital_low = 0 if R1767 == 1
	replace hospital_high = 500 if R1767 == 1

	replace hospital_low = 500 if R1767 == 3
	replace hospital_high = 500 if R1767 == 3

	replace hospital_low = 500 if R1767 == 5
	replace hospital_high = 5000 if R1767 == 5

	replace hospital_low = 0 if (R1767 == 8| R1767 == 9)
	replace hospital_high = 5000 if (R1767 == 8| R1767 == 9)

	replace hospital_low = 5000 if R1766 == 3
	replace hospital_high = 5000 if R1766 == 3

	replace hospital_low = 5000 if R1766 == 5
	replace hospital_high = 10000 if R1766 == 5

	replace hospital_low = 0 if (R1766 == 8 | R1766 == 9)
	replace hospital_high = 10000 if (R1766 == 8 | R1766 == 9)

	replace hospital_low = 10000 if R1765 == 3
	replace hospital_high = 10000 if R1765 == 3

	replace hospital_low = 10000 if R1765 == 5
	replace hospital_high = 20000 if R1765 == 5

	replace hospital_low = 0 if (R1765 == 8 | R1765 == 9)
	replace hospital_high = 20000 if (R1765 == 8 | R1765 == 9)

	replace hospital_low = 20000 if R1764 == 1
	replace hospital_high = 50000 if R1764 == 1

	replace hospital_low = 50000 if R1764 == 3
	replace hospital_high = 50000 if R1764 == 3

	replace hospital_low = 50000 if R1764 == 5
	replace hospital_high = 999999 if R1764 == 5

	replace hospital_low = 20000 if (R1764 == 8 | R1764 == 9)
	replace hospital_high = 999999 if (R1764 == 8 | R1764 == 9)

	replace hospital_low = 10000 if R1763 == 1
	replace hospital_high = 20000 if R1763 == 1

	replace hospital_low = 20000 if R1763 == 3
	replace hospital_high = 20000 if R1763 == 3

		replace hospital_low = 10000 if ((R1763 == 8 | R1763 == 9) & R1762 == 5)
		replace hospital_high = 999999 if ((R1763 == 8 | R1763 == 9) & R1762 == 5)

		replace hospital_low = 0 if ((R1763 == 8 | R1763 == 9) & R1762 != 5)
		replace hospital_high = 999999 if ((R1763 == 8 | R1763 == 9) & R1762 != 5)

	replace hospital_low = 5000 if R1762 == 1
	replace hospital_high = 10000 if R1762 == 1

	replace hospital_low = 10000 if R1762 == 3
	replace hospital_high = 10000 if R1762 == 3

	replace hospital_low = 0 if ((R1762 == 8 | R1762 == 9) | (R1761 == 8 | R1761 == 9))
	replace hospital_high = 999999 if ((R1762 == 8 | R1762 == 9) | (R1761 == 8 | R1761 == 9))

	replace hospital_low = 5000 if R1761 == 3
	replace hospital_high = 5000 if R1761 == 3
