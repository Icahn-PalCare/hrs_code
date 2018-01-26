/* ************************************************************************** 
** load pgms
** Sean F
** Mod By RRD, 20140708
** defines commands that are used for imputing brackets
** 		
** Imputation works as follows: takes mean value from those within range,
	will assign to 4th arg only if the value is missing
** v2: has structural changes for efficiency
	also has change in repute program for l=u case
** also added data description (move this to be in data set itself)

** v3: adds other programs: upp_cap all_impute replace_mi
************************************************************************** */

if "${ver_description}"!=""{
	file open descript using "${savedir}/_DATA_DESCRIPTION.txt", write replace
	file write descript  "${ver_description}"
	file close descript 
}

cap program drop repute

program define repute
	syntax varlist(min=4 max=4) [if/]
	tokenize `varlist'
	local low `1'
	local upp `2'
	local all `3'
	local oop `4'
	
	if "`if'"!="" {
		local if " & ( `if' )"
	}
	
	qui levelsof `low', local(lowvals)		//this is actually slower than tab but allows for more values
	qui levelsof `upp', local(uppvals)

	tempvar imputed
	quietly gen `imputed' = .
	foreach l of local lowvals{
		foreach u of local uppvals {
			if `l' < `u' {
				qui summ `all' if (`all' >= `l') & (`all' <= `u') `if'
				qui replace `imputed' = r(mean) if `low'==`l' & `upp'==`u' `if'
			}
			else if `u' == `l' {
				qui replace `imputed' = `u' if `low'==`l' & `upp'==`u' `if'		//this case should never happen since low=up => not a bracket
			}
			*else if  `l'>`u'
		}
	}
	qui replace `oop' = `imputed' if `oop' == . `if'		//important: if value exists will not impute
end

************************************************************************** 
cap program drop impute_dr_visits

program define impute_dr_visits
	args DR_20 DR_5 DR_YN DR_50
	
	gen dr_upper = .	
	gen dr_lower = .
	
	replace dr_upper = 99999 if `DR_50' == 5
	replace dr_upper = 50    if `DR_50' == 1 | `DR_50' == 3
	replace dr_upper = 20    if `DR_20' == 1 | `DR_20' == 3
	replace dr_upper = 5     if `DR_5'  == 1 | `DR_5'  == 3
	replace dr_upper = 0     if `DR_YN' == 5
	
	replace dr_lower = 0  if `DR_5'  == 1
	replace dr_lower = 5  if `DR_5'  == 3 | `DR_5'  == 5
	replace dr_lower = 20 if `DR_20' == 3 | `DR_20' == 5
	replace dr_lower = 50 if `DR_50' == 3 | `DR_50' == 5
	
	replace dr_lower = 0 if `DR_YN' == 5
	replace dr_lower = 0 if `DR_YN' == 1 & dr_lower == .
	
	foreach L of numlist 0 5 20 50 {
		foreach U of numlist 0 5 20 50 99999 {
			qui sum dr_visits if dr_visits >= `L' & dr_visits <= `U'
			replace dr_visits = r(mean) if missing(dr_visits) & dr_lower == `L' & dr_upper == `U'
		}
	}
end

************************************************************************** 

cap program drop MAKEDATE

program define MAKEDATE
	args NEWVAR MO YR 
	tempvar tempmo 
	tempvar tempyr
	
	gen `tempmo' = `MO'
	replace `tempmo' = . if `tempmo' == 98 | `tempmo' == 99
	*winter(13)=>jan(1) spring(14)=>apr(4) summer(15)=>july(7) fall(16)=>oct(10)
	replace `tempmo' = 1  if `tempmo' == 13
	replace `tempmo' = 4  if `tempmo' == 14
	replace `tempmo' = 7  if `tempmo' == 15
	replace `tempmo' = 10 if `tempmo' == 16
	
	gen `tempyr' = `YR'
	replace `tempyr' = . if `tempyr' == 9998 | `tempyr' == 9999
	
	gen `NEWVAR' = `tempyr' + ( ( `tempmo' - 1 ) / 12 )
end

************************************************************************** 

cap program drop helper

program define helper
	args OOP TIME
	
	* load, set DK/NA/RF to missing
	gen helper_OOP = `OOP'
	replace helper_OOP = . if (`OOP' == 99998 | `OOP' == 99999)
	
	* converts payments to monthly frequency
	replace helper_OOP = 1        * helper_OOP if `TIME' == 1 //month
	replace helper_OOP = (52/12)  * helper_OOP if `TIME' == 2 //week
	replace helper_OOP = (365/12) * helper_OOP if `TIME' == 3 //day
	replace helper_OOP = (1/12)   * helper_OOP if `TIME' == 5 //year
	replace helper_OOP = .                   if (`TIME' == 7 | `TIME' == 8 | `TIME' == 9) & (helper_OOP != 0)
end

/* ************************************************************************** */

cap program drop helper_impute

program define helper_impute
	args YESNO BRACKET 
	
	*This program imputes values to helper_OOP
	
	*BRACKET takes on values 1 ( < 100 ) , 3 ( =~ 100 ) , 5 ( > 100 ) :
	*This defines 3 brackets: [0,100) [100,100] (100,.)
	
	*YESNO takes on values 1 (YES) 5 (NO) 8 (DK/NA) 9 (RF)
	
	*STEPS:
	*1. impute using means where brackets provided
	*2. impute using mean where brackets not provided but helper is paid (YESNO == 1)
	*3. impute with zeros where helper not paid (YESNO == 5)
	*4. impute using mean where known whether helper paid (YESNO == 8 | 9)
	
	***NOTE***: Means are conditioned on the number of helpers.  This is the purpose 
	*           of this separate imputation procedure (i.e. as opposed to using the
	*			repute function used in YYcore and YYexit pgms).
	
	qui count if !missing(helper_OOP)
	di " "
	di "Observations for helper_OOP prior to imputation: " r(N)
	di " "	
	qui count if missing(helper_OOP) & !missing(`YESNO')
	di "Observations with missing helper_OOP but non-missing YESNO variable; imputable: " r(N)
	di " "
	qui count if missing(helper_OOP) & missing(`YESNO') & !missing(HHID)
	di "Observations with missing helper_OOP and YESNO variable; set to 0: " r(N)
	di " " 
	
	*[100,100]
	replace helper_OOP = 100 if (helper_OOP == . & `BRACKET' == 3)
	
	*[0,100), # helpers == 1
	qui sum helper_all if (helper_all < 100) & ///
						  (numhelpers == 1)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 1) & ///
						  		    (numhelpers == 1)
	
	*[0,100), # helpers == 2
	qui sum helper_all if (helper_all < 100) & ///
						  (numhelpers == 2)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 1) & ///
						  		    (numhelpers == 2)
	
	*[0,100), # helpers == 3					  
	qui sum helper_all if (helper_all < 100) & ///
						  (numhelpers == 3)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 1) & ///
						  		    (numhelpers == 3)
	
	*[0,100), # helpers >= 4					  		    
	qui sum helper_all if (helper_all < 100) & ///
						  (numhelpers >= 4)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 1) & ///
						  		    (numhelpers >= 4)
	
	*NOTE: fewer observations for this bracket, use different groupings of observations					  		    
	*(100,.), # helpers == 1 | 2
	qui sum helper_all if (helper_all > 100) & ///
						  (numhelpers == 1 | numhelpers == 2)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 5) & ///
						  		    (numhelpers == 1 | numhelpers == 2)
	
	*(100,.), # helpers >= 3
	qui sum helper_all if (helper_all > 100) & ///
						  (numhelpers >= 3)
	replace helper_OOP = r(mean) if (helper_OOP == .) & ///
						            (`BRACKET' == 5) & ///
						  		    (numhelpers >= 3)
	
	*Expenses=YES, value missing, no brackets provided
	qui sum helper_OOP if (numhelpers == 1)					//rrd: notice these imputes are post prior imputes
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 1) & (numhelpers == 1)
	
	qui sum helper_OOP if (numhelpers == 2)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 1) & (numhelpers == 2)
	
	qui sum helper_OOP if (numhelpers == 3)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 1) & (numhelpers == 3)
	
	qui sum helper_OOP if (numhelpers >= 4)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 1) & (numhelpers >= 4)
	
	*Expenses=NO, value missing
	replace helper_OOP = 0 if (helper_OOP == .) & (`YESNO' == 5)
	
	*Expenses=DK/NA/RF, value missing
	qui sum helper_OOP if (numhelpers == 1)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 8 | `YESNO' == 9) & ///
									(numhelpers == 1)
	
	qui sum helper_OOP if (numhelpers == 2)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 8 | `YESNO' == 9) & ///
									(numhelpers == 2)
									
	qui sum helper_OOP if (numhelpers == 3)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 8 | `YESNO' == 9) & ///
									(numhelpers == 3)
									
	qui sum helper_OOP if (numhelpers >= 4)
	replace helper_OOP = r(mean) if (helper_OOP == .) & (`YESNO' == 8 | `YESNO' == 9) & ///
									(numhelpers >= 4)
	
	*Fill in remaining missing values with 0.  These observations have a missing value for `YESNO', which means 
	*that they are suspected to have not had to pay (helper==SP/Partner | helper==EmployeeOfInstitution | dayshelped==0).
	*I assume that these have 0 expenses.
	replace helper_OOP = 0 if helper_OOP == . & !missing(HHID)
	
	qui count if !missing(helper_OOP)
	di " "
	di "Observations for helper_OOP post-imputation: " r(N)
	di " "

end

/* ************************************************************************** */

cap program drop upp_cap

program define upp_cap
	syntax anything [if/]  
	local capvar `1'
	local capval : list 0 - 1
	*di "capval: `capval'"		//remove if runs
	if "`if'"==""{
		local if 1
	}
		
	replace `capvar' = min( `capvar' , `capval' ) if !missing(`capvar') & `if'
	
end

/* ************************************************************************** */

cap program drop all_impute

program define all_impute 
	syntax varname(min=1 max=1)  [if/] [, GENerate(name) IMPIF(string) IMPON(string)]

	local impvar `1'
	
	local impif_full 1
	if "`if'"!=""{
		local impif_full `impif_full' & `if'
	}
	if "`impif'"!=""{
		local impif_full `impif_full' & `impif'
	}
	
	local impon_full 1
	if "`if'"!=""{
		local impon_full `impon_full' & `if'
	}
	if "`impon'"!=""{
		local impon_full `impon_full' & `impon'
	}
	
	qui summ `impvar' if `impif_full'
	
	if "`generate'"==""{
		replace `impvar' = r(mean) if missing(`impvar') & `impon_full'	
	}
	else {
		confirm new variable `generate'
		gen `generate' = r(mean) if `impon_full'	
	}
	
end

/* ************************************************************************** */

cap program drop replace_mi 

program define replace_mi 
	syntax anything [if/] 
	
	local var `1'
	
	if "`if'"==""{
		local if 1
	}
	
	local vals : list 0 - 1
	local vals_comma : subinstr local vals " " ",", all 
	*di "replace `var'  = . if inlist(`var',`vals_comma')  & `if'"		//delete this if works
	replace `var'  = . if inlist(`var',`vals_comma')  & `if'

end
