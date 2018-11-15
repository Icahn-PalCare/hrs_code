
gen doctor_low = .
gen doctor_high = .

foreach v of varlist N1733 N1734 N1735 N1736 N1737 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1733 N1734 N1735 N1736 N1737 )

replace doctor_low = 0 if N1737 == 5
replace doctor_low = 200 if N1737 == 1
replace doctor_low = 500 if N1736 == 1
replace doctor_low = 1000 if N1733 == 1
replace doctor_low = 5000 if N1734 == 1
replace doctor_low = 20000 if N1735 == 1
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if N1735 == 1
replace doctor_high = 20000 if N1735 == 5
replace doctor_high = 5000 if N1734 == 5
replace doctor_high = 1000 if N1733 == 5
replace doctor_high = 500 if N1736 == 5
replace doctor_high = 200 if N1737 == 5
replace doctor_high = 999999 if doctor_high == . & response > 0

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist N1782 N1783 N1784 N1785 N1786 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1782 N1783 N1784 N1785 N1786 )

replace home_low = 0 if N1786 == 5
replace home_low = 500 if N1786 == 1
replace home_low = 1000 if N1785 == 1
replace home_low = 5000 if N1782 == 1
replace home_low = 10000 if N1783 == 1
replace home_low = 20000 if N1784 == 1
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if N1784 == 1
replace home_high = 20000 if N1784 == 5
replace home_high = 10000 if N1783 == 5
replace home_high = 5000 if N1782 == 5
replace home_high = 1000 if N1785 == 5
replace home_high = 500 if N1786 == 5
replace home_high = 999999 if home_high == . & response > 0

/******************************************************************************/

gen hospice_low = .
gen hospice_high = .

foreach v of varlist N1704 N1705 N1706 N1707 N1708 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1704 N1705 N1706 N1707 N1708 )

replace hospice_low = 0 if N1708 == 5
replace hospice_low = 500 if N1708 == 1
replace hospice_low = 5000 if N1707 == 1
replace hospice_low = 10000 if N1704 == 1
replace hospice_low = 20000 if N1705 == 1
replace hospice_low = 50000 if N1706 == 1
replace hospice_low = 0 if hospice_low == . & response > 0

replace hospice_high = 999999 if N1706 == 1
replace hospice_high = 50000 if N1706 == 5
replace hospice_high = 20000 if N1705 == 5
replace hospice_high = 10000 if N1704 == 5
replace hospice_high = 5000 if N1707 == 5
replace hospice_high = 500 if N1708 == 5
replace hospice_high = 999999 if hospice_high == . & response > 0

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist N1689 N1690 N1691 N1692 N1693 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1689 N1690 N1691 N1692 N1693 )

replace hospital_low = 0 if N1693 == 5
replace hospital_low = 500 if N1693 == 1
replace hospital_low = 5000 if N1692 == 1
replace hospital_low = 10000 if N1689 == 1
replace hospital_low = 20000 if N1690 == 1
replace hospital_low = 50000 if N1691 == 1
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if N1691 == 1
replace hospital_high = 50000 if N1691 == 5
replace hospital_high = 20000 if N1690 == 5
replace hospital_high = 10000 if N1689 == 5
replace hospital_high = 5000 if N1692 == 5
replace hospital_high = 500 if N1693 == 5
replace hospital_high = 999999 if hospital_high == . & response > 0

/******************************************************************************/

gen non_med_low = .
gen non_med_high = .

foreach v of varlist N1806 N1807 N1808 N1809 N1810 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1806 N1807 N1808 N1809 N1810 )

replace non_med_low = 0 if N1810 == 5
replace non_med_low = 500 if N1810 == 1
replace non_med_low = 1000 if N1809 == 1
replace non_med_low = 5000 if N1806 == 1
replace non_med_low = 10000 if N1807 == 1
replace non_med_low = 20000 if N1808 == 1
replace non_med_low = 0 if non_med_low == . & response > 0

replace non_med_high = 999999 if N1808 == 1
replace non_med_high = 20000 if N1808 == 5
replace non_med_high = 10000 if N1807 == 5
replace non_med_high = 5000 if N1806 == 5
replace non_med_high = 1000 if N1809 == 5
replace non_med_high = 500 if N1810 == 5
replace non_med_high = 999999 if non_med_high == . & response > 0

/******************************************************************************/

gen other_low = .
gen other_high = .

foreach v of varlist N1793 N1794 N1795 N1796 N1797 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1793 N1794 N1795 N1796 N1797 )

replace other_low = 0 if N1797 == 5
replace other_low = 500 if N1797 == 1
replace other_low = 1000 if N1796 == 1
replace other_low = 5000 if N1793 == 1
replace other_low = 10000 if N1794 == 1
replace other_low = 20000 if N1795 == 1
replace other_low = 0 if other_low == . & response > 0

replace other_high = 999999 if N1795 == 1
replace other_high = 20000 if N1795 == 5
replace other_high = 10000 if N1794 == 5
replace other_high = 5000 if N1793 == 5
replace other_high = 1000 if N1796 == 5
replace other_high = 500 if N1797 == 5
replace other_high = 999999 if other_high == . & response > 0

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist N1750 N1751 N1752 N1753 N1754 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( N1750 N1751 N1752 N1753 N1754 )

replace rx_low = 0 if N1754 == 5
replace rx_low = 5 if N1754 == 1
replace rx_low = 10 if N1753 == 1
replace rx_low = 20 if N1750 == 1
replace rx_low = 100 if N1751 == 1
replace rx_low = 500 if N1752 == 1
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if N1752 == 1
replace rx_high = 500 if N1752 == 5
replace rx_high = 100 if N1751 == 5
replace rx_high = 20 if N1750 == 5
replace rx_high = 10 if N1753 == 5
replace rx_high = 5 if N1754 == 5
replace rx_high = 999999 if rx_high == . & response > 0

/******************************************************************************/

replace doctor_high = 5000 * z * months if doctor_high == 999999
replace home_high = 30000 * z * months if home_high == 999999
replace hospice_high = 5000 * z * months if hospice_high == 999999
replace hospital_high = 30000 * z * months if hospital_high == 999999
replace non_med_high = 5000 * z * months if non_med_high == 999999
replace other_high = 15000 * z * months if other_high == 999999
replace rx_high = 5000 * z if rx_high == 999999

replace doctor_high = min( 5000 * z * months , doctor_high ) if doctor_high != .
replace home_high = min( 30000 * z * months , home_high ) if home_high != .
replace hospice_high = min( 5000 * z * months , hospice_high ) if hospice_high != .
replace hospital_high = min( 30000 * z * months , hospital_high ) if hospital_high != .
replace non_med_high = min( 5000 * z * months , non_med_high ) if non_med_high != .
replace other_high = min( 15000 * z * months , other_high ) if other_high != .
replace rx_high = min( 5000 * z * months , rx_high ) if rx_high != .
