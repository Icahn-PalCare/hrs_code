
gen doctor_low = .
gen doctor_high = .

foreach v of varlist Q1785 Q1786 Q1787 Q1788 Q1789 Q1790 Q1791 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1785 Q1786 Q1787 Q1788 Q1789 Q1790 Q1791 )

replace doctor_low = 0 if Q1791 == 1
replace doctor_low = 200 if Q1791 == 5
replace doctor_low = 500 if Q1785 == 5
replace doctor_low = 500 if Q1790 == 5
replace doctor_low = 1000 if Q1786 == 5
replace doctor_low = 1000 if Q1789 == 5
replace doctor_low = 5000 if Q1787 == 5
replace doctor_low = 20000 if Q1788 == 5
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if Q1788 == 5
replace doctor_high = 20000 if Q1788 == 1
replace doctor_high = 5000 if Q1787 == 1
replace doctor_high = 1000 if Q1786 == 1
replace doctor_high = 1000 if Q1789 == 1
replace doctor_high = 500 if Q1785 == 1
replace doctor_high = 500 if Q1790 == 1
replace doctor_high = 200 if Q1791 == 1
replace doctor_high = 999999 if doctor_high == . & response > 0

replace doctor_low = 200 if Q1791 == 3
replace doctor_high = 200 if Q1791 == 3

replace doctor_low = 500 if Q1785 == 3
replace doctor_high = 500 if Q1785 == 3

replace doctor_low = 500 if Q1790 == 3
replace doctor_high = 500 if Q1790 == 3

replace doctor_low = 1000 if Q1786 == 3
replace doctor_high = 1000 if Q1786 == 3

replace doctor_low = 1000 if Q1789 == 3
replace doctor_high = 1000 if Q1789 == 3

replace doctor_low = 5000 if Q1787 == 3
replace doctor_high = 5000 if Q1787 == 3

replace doctor_low = 20000 if Q1788 == 3
replace doctor_high = 20000 if Q1788 == 3

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist Q1812 Q1813 Q1814 Q1815 Q1816 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1812 Q1813 Q1814 Q1815 Q1816 )

replace home_low = 0 if Q1816 == 1
replace home_low = 500 if Q1816 == 5
replace home_low = 1000 if Q1815 == 5
replace home_low = 5000 if Q1812 == 5
replace home_low = 10000 if Q1813 == 5
replace home_low = 20000 if Q1814 == 5
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if Q1814 == 5
replace home_high = 20000 if Q1814 == 1
replace home_high = 10000 if Q1813 == 1
replace home_high = 5000 if Q1812 == 1
replace home_high = 1000 if Q1815 == 1
replace home_high = 500 if Q1816 == 1
replace home_high = 999999 if home_high == . & response > 0

replace home_low = 500 if Q1816 == 3
replace home_high = 500 if Q1816 == 3

replace home_low = 1000 if Q1815 == 3
replace home_high = 1000 if Q1815 == 3

replace home_low = 5000 if Q1812 == 3
replace home_high = 5000 if Q1812 == 3

replace home_low = 10000 if Q1813 == 3
replace home_high = 10000 if Q1813 == 3

replace home_low = 20000 if Q1814 == 3
replace home_high = 20000 if Q1814 == 3

/******************************************************************************/

gen hospice_low = .
gen hospice_high = .

foreach v of varlist Q1771 Q1772 Q1773 Q1774 Q1775 Q1776 Q1777 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1771 Q1772 Q1773 Q1774 Q1775 Q1776 Q1777 )

replace hospice_low = 0 if Q1777 == 1
replace hospice_low = 500 if Q1777 == 5
replace hospice_low = 5000 if Q1771 == 5
replace hospice_low = 5000 if Q1776 == 5
replace hospice_low = 10000 if Q1772 == 5
replace hospice_low = 10000 if Q1775 == 5
replace hospice_low = 20000 if Q1773 == 5
replace hospice_low = 50000 if Q1774 == 5
replace hospice_low = 0 if hospice_low == . & response > 0

replace hospice_high = 999999 if Q1774 == 5
replace hospice_high = 50000 if Q1774 == 1
replace hospice_high = 20000 if Q1773 == 1
replace hospice_high = 10000 if Q1772 == 1
replace hospice_high = 10000 if Q1775 == 1
replace hospice_high = 5000 if Q1771 == 1
replace hospice_high = 5000 if Q1776 == 1
replace hospice_high = 500 if Q1777 == 1
replace hospice_high = 999999 if hospice_high == . & response > 0

replace hospice_low = 500 if Q1777 == 3
replace hospice_high = 500 if Q1777 == 3

replace hospice_low = 5000 if Q1771 == 3
replace hospice_high = 5000 if Q1771 == 3

replace hospice_low = 5000 if Q1776 == 3
replace hospice_high = 5000 if Q1776 == 3

replace hospice_low = 10000 if Q1772 == 3
replace hospice_high = 10000 if Q1772 == 3

replace hospice_low = 10000 if Q1775 == 3
replace hospice_high = 10000 if Q1775 == 3

replace hospice_low = 20000 if Q1773 == 3
replace hospice_high = 20000 if Q1773 == 3

replace hospice_low = 50000 if Q1774 == 3
replace hospice_high = 50000 if Q1774 == 3

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist Q1750 Q1751 Q1752 Q1753 Q1754 Q1755 Q1756 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1750 Q1751 Q1752 Q1753 Q1754 Q1755 Q1756 )

replace hospital_low = 0 if Q1756 == 1
replace hospital_low = 500 if Q1756 == 5
replace hospital_low = 5000 if Q1750 == 5
replace hospital_low = 5000 if Q1755 == 5
replace hospital_low = 10000 if Q1751 == 5
replace hospital_low = 10000 if Q1754 == 5
replace hospital_low = 20000 if Q1752 == 5
replace hospital_low = 50000 if Q1753 == 5
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if Q1753 == 5
replace hospital_high = 50000 if Q1753 == 1
replace hospital_high = 20000 if Q1752 == 1
replace hospital_high = 10000 if Q1751 == 1
replace hospital_high = 10000 if Q1754 == 1
replace hospital_high = 5000 if Q1750 == 1
replace hospital_high = 5000 if Q1755 == 1
replace hospital_high = 500 if Q1756 == 1
replace hospital_high = 999999 if hospital_high == . & response > 0

replace hospital_low = 500 if Q1756 == 3
replace hospital_high = 500 if Q1756 == 3

replace hospital_low = 5000 if Q1750 == 3
replace hospital_high = 5000 if Q1750 == 3

replace hospital_low = 5000 if Q1755 == 3
replace hospital_high = 5000 if Q1755 == 3

replace hospital_low = 10000 if Q1751 == 3
replace hospital_high = 10000 if Q1751 == 3

replace hospital_low = 10000 if Q1754 == 3
replace hospital_high = 10000 if Q1754 == 3

replace hospital_low = 20000 if Q1752 == 3
replace hospital_high = 20000 if Q1752 == 3

replace hospital_low = 50000 if Q1753 == 3
replace hospital_high = 50000 if Q1753 == 3

/******************************************************************************/

gen non_med_low = .
gen non_med_high = .

foreach v of varlist Q1845 Q1846 Q1847 Q1848 Q1849 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1845 Q1846 Q1847 Q1848 Q1849 )

replace non_med_low = 0 if Q1849 == 1
replace non_med_low = 500 if Q1849 == 5
replace non_med_low = 1000 if Q1848 == 5
replace non_med_low = 5000 if Q1845 == 5
replace non_med_low = 10000 if Q1846 == 5
replace non_med_low = 20000 if Q1847 == 5
replace non_med_low = 0 if non_med_low == . & response > 0

replace non_med_high = 999999 if Q1847 == 5
replace non_med_high = 20000 if Q1847 == 1
replace non_med_high = 10000 if Q1846 == 1
replace non_med_high = 5000 if Q1845 == 1
replace non_med_high = 1000 if Q1848 == 1
replace non_med_high = 500 if Q1849 == 1
replace non_med_high = 999999 if non_med_high == . & response > 0

replace non_med_low = 500 if Q1849 == 3
replace non_med_high = 500 if Q1849 == 3

replace non_med_low = 1000 if Q1848 == 3
replace non_med_high = 1000 if Q1848 == 3

replace non_med_low = 5000 if Q1845 == 3
replace non_med_high = 5000 if Q1845 == 3

replace non_med_low = 10000 if Q1846 == 3
replace non_med_high = 10000 if Q1846 == 3

replace non_med_low = 20000 if Q1847 == 3
replace non_med_high = 20000 if Q1847 == 3

/******************************************************************************/

gen other_low = .
gen other_high = .

foreach v of varlist Q1819 Q1820 Q1821 Q1822 Q1823 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1819 Q1820 Q1821 Q1822 Q1823 )

replace other_low = 0 if Q1823 == 1
replace other_low = 500 if Q1823 == 5
replace other_low = 1000 if Q1822 == 5
replace other_low = 5000 if Q1819 == 5
replace other_low = 10000 if Q1820 == 5
replace other_low = 20000 if Q1821 == 5
replace other_low = 0 if other_low == . & response > 0

replace other_high = 999999 if Q1821 == 5
replace other_high = 20000 if Q1821 == 1
replace other_high = 10000 if Q1820 == 1
replace other_high = 5000 if Q1819 == 1
replace other_high = 1000 if Q1822 == 1
replace other_high = 500 if Q1823 == 1
replace other_high = 999999 if other_high == . & response > 0

replace other_low = 500 if Q1823 == 3
replace other_high = 500 if Q1823 == 3

replace other_low = 1000 if Q1822 == 3
replace other_high = 1000 if Q1822 == 3

replace other_low = 5000 if Q1819 == 3
replace other_high = 5000 if Q1819 == 3

replace other_low = 10000 if Q1820 == 3
replace other_high = 10000 if Q1820 == 3

replace other_low = 20000 if Q1821 == 3
replace other_high = 20000 if Q1821 == 3

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist Q1795 Q1796 Q1797 Q1798 Q1799 Q1800 Q1801 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( Q1795 Q1796 Q1797 Q1798 Q1799 Q1800 Q1801 )

replace rx_low = 0 if Q1801 == 1
replace rx_low = 5 if Q1801 == 5
replace rx_low = 10 if Q1795 == 5
replace rx_low = 10 if Q1800 == 5
replace rx_low = 20 if Q1796 == 5
replace rx_low = 20 if Q1799 == 5
replace rx_low = 100 if Q1797 == 5
replace rx_low = 500 if Q1798 == 5
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if Q1798 == 5
replace rx_high = 500 if Q1798 == 1
replace rx_high = 100 if Q1797 == 1
replace rx_high = 20 if Q1796 == 1
replace rx_high = 20 if Q1799 == 1
replace rx_high = 10 if Q1795 == 1
replace rx_high = 10 if Q1800 == 1
replace rx_high = 5 if Q1801 == 1
replace rx_high = 999999 if rx_high == . & response > 0

replace rx_low = 5 if Q1801 == 3
replace rx_high = 5 if Q1801 == 3

replace rx_low = 10 if Q1795 == 3
replace rx_high = 10 if Q1795 == 3

replace rx_low = 10 if Q1800 == 3
replace rx_high = 10 if Q1800 == 3

replace rx_low = 20 if Q1796 == 3
replace rx_high = 20 if Q1796 == 3

replace rx_low = 20 if Q1799 == 3
replace rx_high = 20 if Q1799 == 3

replace rx_low = 100 if Q1797 == 3
replace rx_high = 100 if Q1797 == 3

replace rx_low = 500 if Q1798 == 3
replace rx_high = 500 if Q1798 == 3

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
