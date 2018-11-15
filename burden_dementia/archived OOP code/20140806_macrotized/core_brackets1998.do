
gen doctor_low = .
gen doctor_high = .

foreach v of varlist F2338 F2339 F2340 F2341 F2342 F2343 F2344 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( F2338 F2339 F2340 F2341 F2342 F2343 F2344 )

replace doctor_low = 0 if F2344 == 1
replace doctor_low = 200 if F2344 == 5
replace doctor_low = 500 if F2338 == 5
replace doctor_low = 500 if F2343 == 5
replace doctor_low = 1000 if F2339 == 5
replace doctor_low = 1000 if F2342 == 5
replace doctor_low = 5000 if F2340 == 5
replace doctor_low = 20000 if F2341 == 5
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if F2341 == 5
replace doctor_high = 20000 if F2341 == 1
replace doctor_high = 5000 if F2340 == 1
replace doctor_high = 1000 if F2339 == 1
replace doctor_high = 1000 if F2342 == 1
replace doctor_high = 500 if F2338 == 1
replace doctor_high = 500 if F2343 == 1
replace doctor_high = 200 if F2344 == 1
replace doctor_high = 999999 if doctor_high == . & response > 0

replace doctor_low = 200 if F2344 == 3
replace doctor_high = 200 if F2344 == 3

replace doctor_low = 500 if F2338 == 3
replace doctor_high = 500 if F2338 == 3

replace doctor_low = 500 if F2343 == 3
replace doctor_high = 500 if F2343 == 3

replace doctor_low = 1000 if F2339 == 3
replace doctor_high = 1000 if F2339 == 3

replace doctor_low = 1000 if F2342 == 3
replace doctor_high = 1000 if F2342 == 3

replace doctor_low = 5000 if F2340 == 3
replace doctor_high = 5000 if F2340 == 3

replace doctor_low = 20000 if F2341 == 3
replace doctor_high = 20000 if F2341 == 3

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist F2365 F2366 F2367 F2368 F2369 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( F2365 F2366 F2367 F2368 F2369 )

replace home_low = 0 if F2369 == 1
replace home_low = 500 if F2369 == 5
replace home_low = 1000 if F2368 == 5
replace home_low = 5000 if F2365 == 5
replace home_low = 10000 if F2366 == 5
replace home_low = 20000 if F2367 == 5
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if F2367 == 5
replace home_high = 20000 if F2367 == 1
replace home_high = 10000 if F2366 == 1
replace home_high = 5000 if F2365 == 1
replace home_high = 1000 if F2368 == 1
replace home_high = 500 if F2369 == 1
replace home_high = 999999 if home_high == . & response > 0

replace home_low = 500 if F2369 == 3
replace home_high = 500 if F2369 == 3

replace home_low = 1000 if F2368 == 3
replace home_high = 1000 if F2368 == 3

replace home_low = 5000 if F2365 == 3
replace home_high = 5000 if F2365 == 3

replace home_low = 10000 if F2366 == 3
replace home_high = 10000 if F2366 == 3

replace home_low = 20000 if F2367 == 3
replace home_high = 20000 if F2367 == 3

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist F2306 F2307 F2308 F2309 F2310 F2311 F2312 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( F2306 F2307 F2308 F2309 F2310 F2311 F2312 )

replace hospital_low = 0 if F2312 == 1
replace hospital_low = 500 if F2312 == 5
replace hospital_low = 5000 if F2306 == 5
replace hospital_low = 5000 if F2311 == 5
replace hospital_low = 10000 if F2307 == 5
replace hospital_low = 10000 if F2310 == 5
replace hospital_low = 20000 if F2308 == 5
replace hospital_low = 50000 if F2309 == 5
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if F2309 == 5
replace hospital_high = 50000 if F2309 == 1
replace hospital_high = 20000 if F2308 == 1
replace hospital_high = 10000 if F2307 == 1
replace hospital_high = 10000 if F2310 == 1
replace hospital_high = 5000 if F2306 == 1
replace hospital_high = 5000 if F2311 == 1
replace hospital_high = 500 if F2312 == 1
replace hospital_high = 999999 if hospital_high == . & response > 0

replace hospital_low = 500 if F2312 == 3
replace hospital_high = 500 if F2312 == 3

replace hospital_low = 5000 if F2306 == 3
replace hospital_high = 5000 if F2306 == 3

replace hospital_low = 5000 if F2311 == 3
replace hospital_high = 5000 if F2311 == 3

replace hospital_low = 10000 if F2307 == 3
replace hospital_high = 10000 if F2307 == 3

replace hospital_low = 10000 if F2310 == 3
replace hospital_high = 10000 if F2310 == 3

replace hospital_low = 20000 if F2308 == 3
replace hospital_high = 20000 if F2308 == 3

replace hospital_low = 50000 if F2309 == 3
replace hospital_high = 50000 if F2309 == 3

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist F2348 F2349 F2350 F2351 F2352 F2353 F2354 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( F2348 F2349 F2350 F2351 F2352 F2353 F2354 )

replace rx_low = 0 if F2354 == 1
replace rx_low = 5 if F2354 == 5
replace rx_low = 10 if F2348 == 5
replace rx_low = 10 if F2353 == 5
replace rx_low = 20 if F2349 == 5
replace rx_low = 20 if F2352 == 5
replace rx_low = 100 if F2350 == 5
replace rx_low = 500 if F2351 == 5
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if F2351 == 5
replace rx_high = 500 if F2351 == 1
replace rx_high = 100 if F2350 == 1
replace rx_high = 20 if F2349 == 1
replace rx_high = 20 if F2352 == 1
replace rx_high = 10 if F2348 == 1
replace rx_high = 10 if F2353 == 1
replace rx_high = 5 if F2354 == 1
replace rx_high = 999999 if rx_high == . & response > 0

replace rx_low = 5 if F2354 == 3
replace rx_high = 5 if F2354 == 3

replace rx_low = 10 if F2348 == 3
replace rx_high = 10 if F2348 == 3

replace rx_low = 10 if F2353 == 3
replace rx_high = 10 if F2353 == 3

replace rx_low = 20 if F2349 == 3
replace rx_high = 20 if F2349 == 3

replace rx_low = 20 if F2352 == 3
replace rx_high = 20 if F2352 == 3

replace rx_low = 100 if F2350 == 3
replace rx_high = 100 if F2350 == 3

replace rx_low = 500 if F2351 == 3
replace rx_high = 500 if F2351 == 3

/******************************************************************************/

replace doctor_high = 21000 * z * months if doctor_high == 999999
replace home_high = 30000 * z * months if home_high == 999999
replace hospital_high = 30000 * z * months if hospital_high == 999999
replace rx_high = 5000 * z if rx_high == 999999

replace doctor_high = min( 21000 * z * months , doctor_high ) if doctor_high != .
replace home_high = min( 30000 * z * months , home_high ) if home_high != .
replace hospital_high = min( 30000 * z * months , hospital_high ) if hospital_high != .
replace rx_high = min( 5000 * z * months , rx_high ) if rx_high != .
