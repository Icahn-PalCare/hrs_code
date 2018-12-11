/* Updated version of the repute function. This function assigns the mean value
	to all reports between an upper and lower bound, not just the first 100.
	Modified: 9-13-18
*/
capture program drop repute

/* *********************************************************************** */
program repute, rclass
	args min max all main
	tempvar imputed

	* get upper and lower bound values
	levelsof `min', local(lowerbds)
	levelsof `max', local(upperbds)

	quietly gen `imputed' = .
	quietly replace `imputed' = `min' if `min' == `max' & ~mi(`min')

	* loop through lbs and ubs to assign value
	foreach lb of local lowerbds {
		foreach ub of local upperbds {
		
		quietly count if `min' == `lb' & `max' == `ub' & `min' != `max'
			if r(N) > 0 {
				qui sum `all' if `all' >= `lb' & `all' <= `ub'
				disp "Mean expenditure for `main' between `lb' - `ub' is " r(mean)
				qui replace `imputed' = r(mean) if `min' == `lb' & `max' == `ub'
			}
		}
	}
	
	replace `main' = `imputed' if `main' == .
end

/* *********************************************************************** */
