
gen doctor_low = .
gen doctor_high = .

foreach v of varlist G2615 G2616 G2617 G2618 G2619 G2620 G2621 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( G2615 G2616 G2617 G2618 G2619 G2620 G2621 )

replace doctor_low = 0 if G2621 == 1
replace doctor_low = 200 if G2621 == 5
replace doctor_low = 500 if G2615 == 5
replace doctor_low = 500 if G2620 == 5
replace doctor_low = 1000 if G2616 == 5
replace doctor_low = 1000 if G2619 == 5
replace doctor_low = 5000 if G2617 == 5
replace doctor_low = 20000 if G2618 == 5
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if G2618 == 5
replace doctor_high = 20000 if G2618 == 1
replace doctor_high = 5000 if G2617 == 1
replace doctor_high = 1000 if G2616 == 1
replace doctor_high = 1000 if G2619 == 1
replace doctor_high = 500 if G2615 == 1
replace doctor_high = 500 if G2620 == 1
replace doctor_high = 200 if G2621 == 1
replace doctor_high = 999999 if doctor_high == . & response > 0

replace doctor_low = 200 if G2621 == 3
replace doctor_high = 200 if G2621 == 3

replace doctor_low = 500 if G2615 == 3
replace doctor_high = 500 if G2615 == 3

replace doctor_low = 500 if G2620 == 3
replace doctor_high = 500 if G2620 == 3

replace doctor_low = 1000 if G2616 == 3
replace doctor_high = 1000 if G2616 == 3

replace doctor_low = 1000 if G2619 == 3
replace doctor_high = 1000 if G2619 == 3

replace doctor_low = 5000 if G2617 == 3
replace doctor_high = 5000 if G2617 == 3

replace doctor_low = 20000 if G2618 == 3
replace doctor_high = 20000 if G2618 == 3

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist G2642 G2643 G2644 G2645 G2646 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( G2642 G2643 G2644 G2645 G2646 )

replace home_low = 0 if G2646 == 1
replace home_low = 500 if G2646 == 5
replace home_low = 1000 if G2645 == 5
replace home_low = 5000 if G2642 == 5
replace home_low = 10000 if G2643 == 5
replace home_low = 20000 if G2644 == 5
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if G2644 == 5
replace home_high = 20000 if G2644 == 1
replace home_high = 10000 if G2643 == 1
replace home_high = 5000 if G2642 == 1
replace home_high = 1000 if G2645 == 1
replace home_high = 500 if G2646 == 1
replace home_high = 999999 if home_high == . & response > 0

replace home_low = 500 if G2646 == 3
replace home_high = 500 if G2646 == 3

replace home_low = 1000 if G2645 == 3
replace home_high = 1000 if G2645 == 3

replace home_low = 5000 if G2642 == 3
replace home_high = 5000 if G2642 == 3

replace home_low = 10000 if G2643 == 3
replace home_high = 10000 if G2643 == 3

replace home_low = 20000 if G2644 == 3
replace home_high = 20000 if G2644 == 3

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist G2578 G2579 G2580 G2581 G2582 G2583 G2584 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( G2578 G2579 G2580 G2581 G2582 G2583 G2584 )

replace hospital_low = 0 if G2584 == 1
replace hospital_low = 500 if G2584 == 5
replace hospital_low = 5000 if G2578 == 5
replace hospital_low = 5000 if G2583 == 5
replace hospital_low = 10000 if G2579 == 5
replace hospital_low = 10000 if G2582 == 5
replace hospital_low = 20000 if G2580 == 5
replace hospital_low = 50000 if G2581 == 5
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if G2581 == 5
replace hospital_high = 50000 if G2581 == 1
replace hospital_high = 20000 if G2580 == 1
replace hospital_high = 10000 if G2579 == 1
replace hospital_high = 10000 if G2582 == 1
replace hospital_high = 5000 if G2578 == 1
replace hospital_high = 5000 if G2583 == 1
replace hospital_high = 500 if G2584 == 1
replace hospital_high = 999999 if hospital_high == . & response > 0

replace hospital_low = 500 if G2584 == 3
replace hospital_high = 500 if G2584 == 3

replace hospital_low = 5000 if G2578 == 3
replace hospital_high = 5000 if G2578 == 3

replace hospital_low = 5000 if G2583 == 3
replace hospital_high = 5000 if G2583 == 3

replace hospital_low = 10000 if G2579 == 3
replace hospital_high = 10000 if G2579 == 3

replace hospital_low = 10000 if G2582 == 3
replace hospital_high = 10000 if G2582 == 3

replace hospital_low = 20000 if G2580 == 3
replace hospital_high = 20000 if G2580 == 3

replace hospital_low = 50000 if G2581 == 3
replace hospital_high = 50000 if G2581 == 3

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist G2625 G2626 G2627 G2628 G2629 G2630 G2631 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( G2625 G2626 G2627 G2628 G2629 G2630 G2631 )

replace rx_low = 0 if G2631 == 1
replace rx_low = 5 if G2631 == 5
replace rx_low = 10 if G2625 == 5
replace rx_low = 10 if G2630 == 5
replace rx_low = 20 if G2626 == 5
replace rx_low = 20 if G2629 == 5
replace rx_low = 100 if G2627 == 5
replace rx_low = 500 if G2628 == 5
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if G2628 == 5
replace rx_high = 500 if G2628 == 1
replace rx_high = 100 if G2627 == 1
replace rx_high = 20 if G2626 == 1
replace rx_high = 20 if G2629 == 1
replace rx_high = 10 if G2625 == 1
replace rx_high = 10 if G2630 == 1
replace rx_high = 5 if G2631 == 1
replace rx_high = 999999 if rx_high == . & response > 0

replace rx_low = 5 if G2631 == 3
replace rx_high = 5 if G2631 == 3

replace rx_low = 10 if G2625 == 3
replace rx_high = 10 if G2625 == 3

replace rx_low = 10 if G2630 == 3
replace rx_high = 10 if G2630 == 3

replace rx_low = 20 if G2626 == 3
replace rx_high = 20 if G2626 == 3

replace rx_low = 20 if G2629 == 3
replace rx_high = 20 if G2629 == 3

replace rx_low = 100 if G2627 == 3
replace rx_high = 100 if G2627 == 3

replace rx_low = 500 if G2628 == 3
replace rx_high = 500 if G2628 == 3

/******************************************************************************/

replace doctor_high = 21000 * z * months if doctor_high == 999999
replace home_high = 30000 * z * months if home_high == 999999
replace hospital_high = 30000 * z * months if hospital_high == 999999
replace rx_high = 5000 * z if rx_high == 999999

replace doctor_high = min( 21000 * z * months , doctor_high ) if doctor_high != .
replace home_high = min( 30000 * z * months , home_high ) if home_high != .
replace hospital_high = min( 30000 * z * months , hospital_high ) if hospital_high != .
replace rx_high = min( 5000 * z * months , rx_high ) if rx_high != .
