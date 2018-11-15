
gen doctor_low = .
gen doctor_high = .

foreach v of varlist E1805 E1806 E1807 E1808 E1809 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( E1805 E1806 E1807 E1808 E1809 )

replace doctor_low = 0 if E1809 == 5
replace doctor_low = 200 if E1809 == 1
replace doctor_low = 500 if E1808 == 1
replace doctor_low = 1000 if E1805 == 1
replace doctor_low = 5000 if E1806 == 1
replace doctor_low = 20000 if E1807 == 1
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if E1807 == 1
replace doctor_high = 20000 if E1807 == 5
replace doctor_high = 5000 if E1806 == 5
replace doctor_high = 1000 if E1805 == 5
replace doctor_high = 500 if E1808 == 5
replace doctor_high = 200 if E1809 == 5
replace doctor_high = 999999 if doctor_high == . & response > 0

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist E1835 E1836 E1837 E1838 E1839 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( E1835 E1836 E1837 E1838 E1839 )

replace home_low = 0 if E1839 == 5
replace home_low = 500 if E1839 == 1
replace home_low = 1000 if E1838 == 1
replace home_low = 5000 if E1835 == 1
replace home_low = 10000 if E1836 == 1
replace home_low = 20000 if E1837 == 1
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if E1837 == 1
replace home_high = 20000 if E1837 == 5
replace home_high = 10000 if E1836 == 5
replace home_high = 5000 if E1835 == 5
replace home_high = 1000 if E1838 == 5
replace home_high = 500 if E1839 == 5
replace home_high = 999999 if home_high == . & response > 0

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist E1784 E1785 E1786 E1787 E1788 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( E1784 E1785 E1786 E1787 E1788 )

replace hospital_low = 0 if E1788 == 5
replace hospital_low = 500 if E1788 == 1
replace hospital_low = 5000 if E1787 == 1
replace hospital_low = 10000 if E1784 == 1
replace hospital_low = 20000 if E1785 == 1
replace hospital_low = 50000 if E1786 == 1
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if E1786 == 1
replace hospital_high = 50000 if E1786 == 5
replace hospital_high = 20000 if E1785 == 5
replace hospital_high = 10000 if E1784 == 5
replace hospital_high = 5000 if E1787 == 5
replace hospital_high = 500 if E1788 == 5
replace hospital_high = 999999 if hospital_high == . & response > 0

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist E1817 E1818 E1819 E1820 E1821 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( E1817 E1818 E1819 E1820 E1821 )

replace rx_low = 0 if E1821 == 5
replace rx_low = 5 if E1821 == 1
replace rx_low = 10 if E1820 == 1
replace rx_low = 20 if E1817 == 1
replace rx_low = 100 if E1818 == 1
replace rx_low = 500 if E1819 == 1
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if E1819 == 1
replace rx_high = 500 if E1819 == 5
replace rx_high = 100 if E1818 == 5
replace rx_high = 20 if E1817 == 5
replace rx_high = 10 if E1820 == 5
replace rx_high = 5 if E1821 == 5
replace rx_high = 999999 if rx_high == . & response > 0

/******************************************************************************/

replace doctor_high = 21000 * z * months if doctor_high == 999999
replace home_high = 30000 * z * months if home_high == 999999
replace hospital_high = 30000 * z * months if hospital_high == 999999
replace rx_high = 5000 * z if rx_high == 999999

replace doctor_high = min( 21000 * z * months , doctor_high ) if doctor_high != .
replace home_high = min( 30000 * z * months , home_high ) if home_high != .
replace hospital_high = min( 30000 * z * months , hospital_high ) if hospital_high != .
replace rx_high = min( 5000 * z * months , rx_high ) if rx_high != .
