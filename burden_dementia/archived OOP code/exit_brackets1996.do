
gen doctor_low = .
gen doctor_high = .

foreach v of varlist P1314 P1315 P1316 P1317 P1318 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1314 P1315 P1316 P1317 P1318 )

replace doctor_low = 0 if P1318 == 5
replace doctor_low = 200 if P1318 == 1
replace doctor_low = 500 if P1317 == 1
replace doctor_low = 1000 if P1314 == 1
replace doctor_low = 5000 if P1315 == 1
replace doctor_low = 20000 if P1316 == 1
replace doctor_low = 0 if doctor_low == . & response > 0

replace doctor_high = 999999 if P1316 == 1
replace doctor_high = 20000 if P1316 == 5
replace doctor_high = 5000 if P1315 == 5
replace doctor_high = 1000 if P1314 == 5
replace doctor_high = 500 if P1317 == 5
replace doctor_high = 200 if P1318 == 5
replace doctor_high = 999999 if doctor_high == . & response > 0

/******************************************************************************/

gen home_low = .
gen home_high = .

foreach v of varlist P1363 P1364 P1365 P1366 P1367 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1363 P1364 P1365 P1366 P1367 )

replace home_low = 0 if P1367 == 5
replace home_low = 500 if P1367 == 1
replace home_low = 1000 if P1366 == 1
replace home_low = 5000 if P1363 == 1
replace home_low = 10000 if P1364 == 1
replace home_low = 20000 if P1365 == 1
replace home_low = 0 if home_low == . & response > 0

replace home_high = 999999 if P1365 == 1
replace home_high = 20000 if P1365 == 5
replace home_high = 10000 if P1364 == 5
replace home_high = 5000 if P1363 == 5
replace home_high = 1000 if P1366 == 5
replace home_high = 500 if P1367 == 5
replace home_high = 999999 if home_high == . & response > 0

/******************************************************************************/

gen hospice_low = .
gen hospice_high = .

foreach v of varlist P1285 P1286 P1287 P1288 P1289 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1285 P1286 P1287 P1288 P1289 )

replace hospice_low = 0 if P1289 == 5
replace hospice_low = 500 if P1289 == 1
replace hospice_low = 5000 if P1288 == 1
replace hospice_low = 10000 if P1285 == 1
replace hospice_low = 20000 if P1286 == 1
replace hospice_low = 50000 if P1287 == 1
replace hospice_low = 0 if hospice_low == . & response > 0

replace hospice_high = 999999 if P1287 == 1
replace hospice_high = 50000 if P1287 == 5
replace hospice_high = 20000 if P1286 == 5
replace hospice_high = 10000 if P1285 == 5
replace hospice_high = 5000 if P1288 == 5
replace hospice_high = 500 if P1289 == 5
replace hospice_high = 999999 if hospice_high == . & response > 0

/******************************************************************************/

gen hospital_low = .
gen hospital_high = .

foreach v of varlist P1270 P1271 P1272 P1273 P1274 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1270 P1271 P1272 P1273 P1274 )

replace hospital_low = 0 if P1274 == 5
replace hospital_low = 500 if P1274 == 1
replace hospital_low = 5000 if P1273 == 1
replace hospital_low = 10000 if P1270 == 1
replace hospital_low = 20000 if P1271 == 1
replace hospital_low = 50000 if P1272 == 1
replace hospital_low = 0 if hospital_low == . & response > 0

replace hospital_high = 999999 if P1272 == 1
replace hospital_high = 50000 if P1272 == 5
replace hospital_high = 20000 if P1271 == 5
replace hospital_high = 10000 if P1270 == 5
replace hospital_high = 5000 if P1273 == 5
replace hospital_high = 500 if P1274 == 5
replace hospital_high = 999999 if hospital_high == . & response > 0

/******************************************************************************/

gen non_med_low = .
gen non_med_high = .

foreach v of varlist P1387 P1388 P1389 P1390 P1391 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1387 P1388 P1389 P1390 P1391 )

replace non_med_low = 0 if P1391 == 5
replace non_med_low = 500 if P1391 == 1
replace non_med_low = 1000 if P1390 == 1
replace non_med_low = 5000 if P1387 == 1
replace non_med_low = 10000 if P1388 == 1
replace non_med_low = 20000 if P1389 == 1
replace non_med_low = 0 if non_med_low == . & response > 0

replace non_med_high = 999999 if P1389 == 1
replace non_med_high = 20000 if P1389 == 5
replace non_med_high = 10000 if P1388 == 5
replace non_med_high = 5000 if P1387 == 5
replace non_med_high = 1000 if P1390 == 5
replace non_med_high = 500 if P1391 == 5
replace non_med_high = 999999 if non_med_high == . & response > 0

/******************************************************************************/

gen other_low = .
gen other_high = .

foreach v of varlist P1374 P1375 P1376 P1377 P1378 {
	replace `v' = . if `v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1374 P1375 P1376 P1377 P1378 )

replace other_low = 0 if P1378 == 5
replace other_low = 500 if P1378 == 1
replace other_low = 1000 if P1377 == 1
replace other_low = 5000 if P1374 == 1
replace other_low = 10000 if P1375 == 1
replace other_low = 20000 if P1376 == 1
replace other_low = 0 if other_low == . & response > 0

replace other_high = 999999 if P1376 == 1
replace other_high = 20000 if P1376 == 5
replace other_high = 10000 if P1375 == 5
replace other_high = 5000 if P1374 == 5
replace other_high = 1000 if P1377 == 5
replace other_high = 500 if P1378 == 5
replace other_high = 999999 if other_high == . & response > 0

/******************************************************************************/

gen rx_low = .
gen rx_high = .

foreach v of varlist P1331 P1332 P1333 P1334 P1335 {
	replace `v' = . if `v' == 7 |`v' == 8 | `v' == 9
}

cap drop response
egen response = rownonmiss( P1331 P1332 P1333 P1334 P1335 )

replace rx_low = 0 if P1335 == 5
replace rx_low = 5 if P1335 == 1
replace rx_low = 10 if P1334 == 1
replace rx_low = 20 if P1331 == 1
replace rx_low = 100 if P1332 == 1
replace rx_low = 500 if P1333 == 1
replace rx_low = 0 if rx_low == . & response > 0

replace rx_high = 999999 if P1333 == 1
replace rx_high = 500 if P1333 == 5
replace rx_high = 100 if P1332 == 5
replace rx_high = 20 if P1331 == 5
replace rx_high = 10 if P1334 == 5
replace rx_high = 5 if P1335 == 5
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
