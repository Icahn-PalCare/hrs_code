gen non_med_low = .
gen non_med_high = .

	replace non_med_low = 0 if Q1849 == 1
	replace non_med_high = 500 if Q1849 == 1

	replace non_med_low = 500 if Q1849 == 3
	replace non_med_high = 500 if Q1849 == 3

	replace non_med_low = 500 if Q1849 == 5
	replace non_med_high = 1000 if Q1849 == 5

	replace non_med_low = 0 if Q1849 == 8
	replace non_med_high = 1000 if Q1849 == 8

	replace non_med_low = 1000 if Q1848 == 3
	replace non_med_high = 1000 if Q1848 == 3

	replace non_med_low = 1000 if Q1848 == 5
	replace non_med_high = 5000 if Q1848 == 5

	replace non_med_low = 0 if Q1848 == 8
	replace non_med_high = 5000 if Q1848 == 8

	replace non_med_low = 10000 if Q1847 == 1
	replace non_med_high = 20000 if Q1847 == 1

	replace non_med_low = 20000 if Q1847 == 5
	replace non_med_high = 999999 if Q1847 == 5

	replace non_med_low = 5000 if Q1846 == 1
	replace non_med_high = 10000 if Q1846 == 1

	replace non_med_low = 10000 if Q1846 == 3
	replace non_med_high = 10000 if Q1846 == 3

	replace non_med_low = 5000 if Q1846 == 8
	replace non_med_high = 999999 if Q1846 == 8

	replace non_med_low = 5000 if Q1845 == 3
	replace non_med_high = 5000 if Q1845 == 3

	replace non_med_low = 0 if (Q1845 == 8 | Q1845 == 9)
	replace non_med_high = 999999 if (Q1845 == 8 | Q1845 == 9)
