/**************************************************************************
Seans Main File
Next Steps:
		Continue from Exit_oop on macrotizing caps and adding my programs
***************************************************************************/



clear *
macro drop _all
program drop _all
set more off
timer clear
*version 12

global creation_version "20140806_macrotized"
global ver_description 	"Added Macro loops (see word doc 'README 07-17-2014 notes)' in program dir"	//max 80 chars

** Steps 
local do_load	1		
local do_core	1
local do_exit	1		
local do_final	1

** Options 
global rand_version 	o
global tracker_name		trk2014tr_r

** define directories 
*global thisdir "//tsclient\F\RA-Kathleen\OOPME\OOPME_pgms\Updated_structure_20140716"
global thisdir "E:\hrs_code\burden_dementia\OOPME-programs-2014-08-18"
global loaddir "E:\data\burden_dementia\oopdata\raw hrs"
global randdir "E:\data\hrs_public_2014\rand2014\main"
global savedir "E:\data\burden_dementia\oopdata"
global logsdir "E:\data\burden_dementia\oopdata"

/*update 12/01/17--need to rename all variables to caps lock*/
cd "${loaddir}"
local files : dir . files "*.dta"
foreach file in `files' {
cap use `file', clear
cap rename *, u
cap save `file', replace
}

cap log close
log using "${logsdir}/log_${creation_version}", replace

timer on 1
	capture mkdir "${savedir}"

	cd "${thisdir}"

	do load_cpi
	do load_pgms_v3						//custom programs plus my new features
	do load_varcaps						//new after macrotizing
	do load_macro_lists					//macro vars needed for other do files
	
	if `do_load'==1{
		timer on 2
			do load_data							//both core and exit; read in data
			do add_months							//calculate months between iws, saveas core_motns
		timer off 2
	}
	
	** core data 
	if `do_core'==1 {
		timer on 3
		
		do core_oop					//rename spending vars, ins prems and oop, save as _oop (in nom dollars!)
			do core_utilization			//rename utilization vars (num vists, num plans), save as _use (needs ins coverage) 
			do core_all					//adjust inflation, aggregate some groups, rename oop as _all, caps (redundant from _oop!), makes private ins vars long and appends (correct this!)
			do core_helper_load			//get num helpers, total cost for helpers (monthly, inf adjusted to base dollars)
			do core_helper_impute		//repeats load, adds imputed helper values, aggregates all spending for all helpers, converts back to nominal prices, 

			timer on 4
				do core_impute_1		//converts to wave dollars, impute based on all waves (except 93), needs corrections 
			timer off 4

			timer on 5
				do core_impute_2		//imputes when brackets not given using usage, quantiles, coverage type, spending in nom dollsars
			timer off 5

			timer on 6
				do core_flags			//merges oopi1 and oop2 to id how imputation derived, needs improvement
			timer off 6

			timer on 7
				do core_merge			//merges all core data with imputes, puts in real dollars
			timer off 7

		timer off 3
	}

	** exit data
	if `do_exit'==1 {
		timer on 8

			do exit_oop					//needs to be macrotized, match to core_oop
			do exit_utilization
			do exit_all
			do exit_helper_load
			do exit_helper_impute

			timer on 9
				do exit_impute_1
			timer off 9

			timer on 10
				do exit_impute_2
			timer off 10

			timer on 11
				do exit_flags
			timer off 11

			timer on 12
				do exit_merge
			timer off 12

		timer off 8
	}

	** assemble final dataset 
	if `do_final'==1 {
		timer on 13
			do final_merge				//final caps, makes agg vars, prem vars
			do labels_recodes
		timer off 13
	}

timer off 1
timer list

log close

