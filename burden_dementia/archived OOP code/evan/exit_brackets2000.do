
gen doctor_low = .
gen doctor_high = .

foreach v of varlist R1801 R1802 R1803 R1804 R1805 R1806 R1807 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1801 R1802 R1803 R1804 R1805 R1806 R1807 )

replace doctor_low = 0 if R1807 == 1
replace doctor_low = 200 if R1807 == 5
replace doctor_low = 500 if R1801 == 5
replace doctor_low = 500 if R1806 == 5
replace doctor_low = 1000 if R1802 == 5
replace doctor_low = 1000 if R1805 == 5
replace doctor_low = 5000 if R1803 == 5
replace doctor_low = 20000 if R1804 == 5
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if R1804 == 5
replace doctor_high = 20000 if R1804 == 1
replace doctor_high = 5000 if R1803 == 1
replace doctor_high = 1000 if R1802 == 1
replace doctor_high = 1000 if R1805 == 1
replace doctor_high = 500 if R1801 == 1
replace doctor_high = 500 if R1806 == 1
replace doctor_high = 200 if R1807 == 1
replace doctor_high = 999999 if doctor_high == . & response > 0

replace doctor_low = 200 if R1807 == 3
replace doctor_high = 200 if R1807 == 3

replace doctor_low = 500 if R1801 == 3
replace doctor_high = 500 if R1801 == 3

replace doctor_low = 500 if R1806 == 3
replace doctor_high = 500 if R1806 == 3

replace doctor_low = 1000 if R1802 == 3
replace doctor_high = 1000 if R1802 == 3

replace doctor_low = 1000 if R1805 == 3
replace doctor_high = 1000 if R1805 == 3

replace doctor_low = 5000 if R1803 == 3
replace doctor_high = 5000 if R1803 == 3

replace doctor_low = 20000 if R1804 == 3
replace doctor_high = 20000 if R1804 == 3

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist R1828 R1829 R1830 R1831 R1832 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1828 R1829 R1830 R1831 R1832 )

replace home_low = 0 if R1832 == 1
replace home_low = 500 if R1832 == 5
replace home_low = 1000 if R1831 == 5
replace home_low = 5000 if R1828 == 5
replace home_low = 10000 if R1829 == 5
replace home_low = 20000 if R1830 == 5
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if R1830 == 5
replace home_high = 20000 if R1830 == 1
replace home_high = 10000 if R1829 == 1
replace home_high = 5000 if R1828 == 1
replace home_high = 1000 if R1831 == 1
replace home_high = 500 if R1832 == 1
replace home_high = 999999 if home_high == . & response > 0

replace home_low = 500 if R1832 == 3
replace home_high = 500 if R1832 == 3

replace home_low = 1000 if R1831 == 3
replace home_high = 1000 if R1831 == 3

replace home_low = 5000 if R1828 == 3
replace home_high = 5000 if R1828 == 3

replace home_low = 10000 if R1829 == 3
replace home_high = 10000 if R1829 == 3

replace home_low = 20000 if R1830 == 3
replace home_high = 20000 if R1830 == 3

/******************************************************************************/

gen hospice_low = .
gen hospice_high = .

foreach v of varlist R1782 R1783 R1784 R1785 R1786 R1787 R1788 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1782 R1783 R1784 R1785 R1786 R1787 R1788 )

replace hospice_low = 0 if R1788 == 1
replace hospice_low = 500 if R1788 == 5
replace hospice_low = 5000 if R1782 == 5
replace hospice_low = 5000 if R1787 == 5
replace hospice_low = 10000 if R1783 == 5
replace hospice_low = 10000 if R1786 == 5
replace hospice_low = 20000 if R1784 == 5
replace hospice_low = 50000 if R1785 == 5
replace hospice_low = 0 if hospice_low == . & response > 0

replace hospice_high = 999999 if R1785 == 5
replace hospice_high = 50000 if R1785 == 1
replace hospice_high = 20000 if R1784 == 1
replace hospice_high = 10000 if R1783 == 1
replace hospice_high = 10000 if R1786 == 1
replace hospice_high = 5000 if R1782 == 1
replace hospice_high = 5000 if R1787 == 1
replace hospice_high = 500 if R1788 == 1
replace hospice_high = 999999 if hospice_high == . & response > 0

replace hospice_low = 500 if R1788 == 3
replace hospice_high = 500 if R1788 == 3

replace hospice_low = 5000 if R1782 == 3
replace hospice_high = 5000 if R1782 == 3

replace hospice_low = 5000 if R1787 == 3
replace hospice_high = 5000 if R1787 == 3

replace hospice_low = 10000 if R1783 == 3
replace hospice_high = 10000 if R1783 == 3

replace hospice_low = 10000 if R1786 == 3
replace hospice_high = 10000 if R1786 == 3

replace hospice_low = 20000 if R1784 == 3
replace hospice_high = 20000 if R1784 == 3

replace hospice_low = 50000 if R1785 == 3
replace hospice_high = 50000 if R1785 == 3

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist R1761 R1762 R1763 R1764 R1765 R1766 R1767 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1761 R1762 R1763 R1764 R1765 R1766 R1767 )

replace hospital_low = 0 if R1767 == 1
replace hospital_low = 500 if R1767 == 5
replace hospital_low = 5000 if R1761 == 5
replace hospital_low = 5000 if R1766 == 5
replace hospital_low = 10000 if R1762 == 5
replace hospital_low = 10000 if R1765 == 5
replace hospital_low = 20000 if R1763 == 5
replace hospital_low = 50000 if R1764 == 5
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if R1764 == 5
replace hospital_high = 50000 if R1764 == 1
replace hospital_high = 20000 if R1763 == 1
replace hospital_high = 10000 if R1762 == 1
replace hospital_high = 10000 if R1765 == 1
replace hospital_high = 5000 if R1761 == 1
replace hospital_high = 5000 if R1766 == 1
replace hospital_high = 500 if R1767 == 1
replace hospital_high = 999999 if hospital_high == . & response > 0

replace hospital_low = 500 if R1767 == 3
replace hospital_high = 500 if R1767 == 3

replace hospital_low = 5000 if R1761 == 3
replace hospital_high = 5000 if R1761 == 3

replace hospital_low = 5000 if R1766 == 3
replace hospital_high = 5000 if R1766 == 3

replace hospital_low = 10000 if R1762 == 3
replace hospital_high = 10000 if R1762 == 3

replace hospital_low = 10000 if R1765 == 3
replace hospital_high = 10000 if R1765 == 3

replace hospital_low = 20000 if R1763 == 3
replace hospital_high = 20000 if R1763 == 3

replace hospital_low = 50000 if R1764 == 3
replace hospital_high = 50000 if R1764 == 3

/******************************************************************************/

gen non_med_low = .
gen non_med_high = .

foreach v of varlist R1865 R1866 R1867 R1868 R1869 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1865 R1866 R1867 R1868 R1869 )

replace non_med_low = 0 if R1869 == 1
replace non_med_low = 500 if R1869 == 5
replace non_med_low = 1000 if R1868 == 5
replace non_med_low = 5000 if R1865 == 5
replace non_med_low = 10000 if R1866 == 5
replace non_med_low = 20000 if R1867 == 5
replace non_med_low = 0 if non_med_low == . & response > 0

replace non_med_high = 999999 if R1867 == 5
replace non_med_high = 20000 if R1867 == 1
replace non_med_high = 10000 if R1866 == 1
replace non_med_high = 5000 if R1865 == 1
replace non_med_high = 1000 if R1868 == 1
replace non_med_high = 500 if R1869 == 1
replace non_med_high = 999999 if non_med_high == . & response > 0

replace non_med_low = 500 if R1869 == 3
replace non_med_high = 500 if R1869 == 3

replace non_med_low = 1000 if R1868 == 3
replace non_med_high = 1000 if R1868 == 3

replace non_med_low = 5000 if R1865 == 3
replace non_med_high = 5000 if R1865 == 3

replace non_med_low = 10000 if R1866 == 3
replace non_med_high = 10000 if R1866 == 3

replace non_med_low = 20000 if R1867 == 3
replace non_med_high = 20000 if R1867 == 3

/******************************************************************************/

gen other_low = .
gen other_high = .

foreach v of varlist R1836 R1837 R1838 R1839 R1840 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1836 R1837 R1838 R1839 R1840 )

replace other_low = 0 if R1840 == 1
replace other_low = 500 if R1840 == 5
replace other_low = 1000 if R1839 == 5
replace other_low = 5000 if R1836 == 5
replace other_low = 10000 if R1837 == 5
replace other_low = 20000 if R1838 == 5
replace other_low = 0 if other_low == . & response > 0

replace other_high = 999999 if R1838 == 5
replace other_high = 20000 if R1838 == 1
replace other_high = 10000 if R1837 == 1
replace other_high = 5000 if R1836 == 1
replace other_high = 1000 if R1839 == 1
replace other_high = 500 if R1840 == 1
replace other_high = 999999 if other_high == . & response > 0

replace other_low = 500 if R1840 == 3
replace other_high = 500 if R1840 == 3

replace other_low = 1000 if R1839 == 3
replace other_high = 1000 if R1839 == 3

replace other_low = 5000 if R1836 == 3
replace other_high = 5000 if R1836 == 3

replace other_low = 10000 if R1837 == 3
replace other_high = 10000 if R1837 == 3

replace other_low = 20000 if R1838 == 3
replace other_high = 20000 if R1838 == 3

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist R1811 R1812 R1813 R1814 R1815 R1816 R1817 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( R1811 R1812 R1813 R1814 R1815 R1816 R1817 )

replace rx_low = 0 if R1817 == 1
replace rx_low = 5 if R1817 == 5
replace rx_low = 10 if R1811 == 5
replace rx_low = 10 if R1816 == 5
replace rx_low = 20 if R1812 == 5
replace rx_low = 20 if R1815 == 5
replace rx_low = 100 if R1813 == 5
replace rx_low = 500 if R1814 == 5
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if R1814 == 5
replace rx_high = 500 if R1814 == 1
replace rx_high = 100 if R1813 == 1
replace rx_high = 20 if R1812 == 1
replace rx_high = 20 if R1815 == 1
replace rx_high = 10 if R1811 == 1
replace rx_high = 10 if R1816 == 1
replace rx_high = 5 if R1817 == 1
replace rx_high = 999999 if rx_high == . & response > 0

replace rx_low = 5 if R1817 == 3
replace rx_high = 5 if R1817 == 3

replace rx_low = 10 if R1811 == 3
replace rx_high = 10 if R1811 == 3

replace rx_low = 10 if R1816 == 3
replace rx_high = 10 if R1816 == 3

replace rx_low = 20 if R1812 == 3
replace rx_high = 20 if R1812 == 3

replace rx_low = 20 if R1815 == 3
replace rx_high = 20 if R1815 == 3

replace rx_low = 100 if R1813 == 3
replace rx_high = 100 if R1813 == 3

replace rx_low = 500 if R1814 == 3
replace rx_high = 500 if R1814 == 3

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
