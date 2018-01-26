
gen doctor_low = .
gen doctor_high = .

foreach v of varlist D1733 D1734 D1735 D1736 D1737 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( D1733 D1734 D1735 D1736 D1737 )

replace doctor_low = 0 if D1737 == 5				//rrd: make these with cond statements
replace doctor_low = 200 if D1737 == 1
replace doctor_low = 500 if D1736 == 1
replace doctor_low = 1000 if D1733 == 1
replace doctor_low = 5000 if D1734 == 1
replace doctor_low = 20000 if D1735 == 1
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if D1735 == 1
replace doctor_high = 20000 if D1735 == 5
replace doctor_high = 5000 if D1734 == 5
replace doctor_high = 1000 if D1733 == 5
replace doctor_high = 500 if D1736 == 5
replace doctor_high = 200 if D1737 == 5
replace doctor_high = 999999 if doctor_high == . & response > 0

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist D1782 D1783 D1784 D1785 D1786 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( D1782 D1783 D1784 D1785 D1786 )

replace home_low = 0 if D1786 == 5
replace home_low = 500 if D1786 == 1
replace home_low = 1000 if D1785 == 1
replace home_low = 5000 if D1782 == 1
replace home_low = 10000 if D1783 == 1
replace home_low = 20000 if D1784 == 1
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if D1784 == 1
replace home_high = 20000 if D1784 == 5
replace home_high = 10000 if D1783 == 5
replace home_high = 5000 if D1782 == 5
replace home_high = 1000 if D1785 == 5
replace home_high = 500 if D1786 == 5
replace home_high = 999999 if home_high == . & response > 0

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist D1689 D1690 D1691 D1692 D1693 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( D1689 D1690 D1691 D1692 D1693 )

replace hospital_low = 0 if D1693 == 5
replace hospital_low = 500 if D1693 == 1
replace hospital_low = 5000 if D1692 == 1
replace hospital_low = 10000 if D1689 == 1
replace hospital_low = 20000 if D1690 == 1
replace hospital_low = 50000 if D1691 == 1
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if D1691 == 1
replace hospital_high = 50000 if D1691 == 5
replace hospital_high = 20000 if D1690 == 5
replace hospital_high = 10000 if D1689 == 5
replace hospital_high = 5000 if D1692 == 5
replace hospital_high = 500 if D1693 == 5
replace hospital_high = 999999 if hospital_high == . & response > 0

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist D1750 D1751 D1752 D1753 D1754 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( D1750 D1751 D1752 D1753 D1754 )

replace rx_low = 0 if D1754 == 5
replace rx_low = 5 if D1754 == 1
replace rx_low = 10 if D1753 == 1
replace rx_low = 20 if D1750 == 1
replace rx_low = 100 if D1751 == 1
replace rx_low = 500 if D1752 == 1
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if D1752 == 1
replace rx_high = 500 if D1752 == 5
replace rx_high = 100 if D1751 == 5
replace rx_high = 20 if D1750 == 5
replace rx_high = 10 if D1753 == 5
replace rx_high = 5 if D1754 == 5
replace rx_high = 999999 if rx_high == . & response > 0			//rrd: these are monthly!!

/******************************************************************************/

replace doctor_high = 21000 * z * months if doctor_high == 999999
replace home_high = 30000 * z * months if home_high == 999999
replace hospital_high = 30000 * z * months if hospital_high == 999999
replace rx_high = 5000 * z if rx_high == 999999

replace doctor_high = min( 21000 * z * months , doctor_high ) if doctor_high != .
replace home_high = min( 30000 * z * months , home_high ) if home_high != .
replace hospital_high = min( 30000 * z * months , hospital_high ) if hospital_high != .
replace rx_high = min( 5000 * z * months , rx_high ) if rx_high != .		//rrd: typo: remove * months for all years do files
