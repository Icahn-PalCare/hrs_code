* MMS (2011) repute function. Paper version

capture program drop repute

/* *********************************************************************** */
program repute, rclass
args low upp all main
tempvar imputed
quietly gen `imputed' = .
forvalues i = 1/100 {
sort `low' `upp'
quietly gen tz = `all' if `all'>=`low'[`i'] & `all' <= `upp'[`i']
quietly sum tz if `low'[`i'] !=.
quietly replace `imputed' = r(mean) if _n == `i' & `low'[`i'] !=.
quietly replace `imputed' = `low' if ((_n == `i') & (`low' == `upp') & `low'[`i'] !=.)
capture drop tz 
}
replace `main' = `imputed' if `main' == .
end
/* *********************************************************************** */
