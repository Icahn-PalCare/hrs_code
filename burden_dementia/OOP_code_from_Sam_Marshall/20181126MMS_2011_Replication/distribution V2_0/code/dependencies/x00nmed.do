* creates an upper and lower bound for repute program
gen non_med_low = .
gen non_med_high = .

	replace non_med_low = 0 if R1869 == 1
	replace non_med_high = 500 if R1869 == 1

	replace non_med_low = 500 if R1869 == 3
	replace non_med_high = 500 if R1869 == 3

	replace non_med_low = 500 if R1869 == 5
	replace non_med_high = 1000 if R1869 == 5

	replace non_med_low = 0 if R1869 == 8
	replace non_med_high = 1000 if R1869 == 8

	replace non_med_low = 1000 if R1868 == 3
	replace non_med_high = 1000 if R1868 == 3

	replace non_med_low = 1000 if R1868 == 5
	replace non_med_high = 5000 if R1868 == 5

	replace non_med_low = 0 if R1868 == 8
	replace non_med_high = 5000 if R1868 == 8

	replace non_med_low = 10000 if R1867 == 1
	replace non_med_high = 20000 if R1867 == 1

	replace non_med_low = 20000 if R1867 == 5
	replace non_med_high = 999999 if R1867 == 5

	replace non_med_low = 5000 if R1866 == 1
	replace non_med_high = 10000 if R1866 == 1

	replace non_med_low = 10000 if R1866 == 3
	replace non_med_high = 10000 if R1866 == 3

	replace non_med_low = 5000 if R1865 == 3
	replace non_med_high = 5000 if R1865 == 3

	replace non_med_low = 0 if R1865 == 8
	replace non_med_high = 999999 if R1865 == 8
