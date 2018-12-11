/* Number of helpers and helper hours by type, following the approach from Sean Fahle

1-Get helpers from core (& exit?)

2-sort into types
	a)s--spouses
	b)u--other unpaid helpers
	c)i--informal (a&b)
	d)k--kids
	e)p--other paid
	f)e--institution
	g)d--dk/na/rf whether paid
	h)m--missing whether paid
	i)o--non-kids (not pulling this)
	j)f--formal (employee/paid)
	k)n--unclear whether formal/informal (not pulling this)
	l)hp--total # helpers 
	
3-final variables hhid pn id year n_* hlphrs_* hlphrs
*/

local loadpath "E:\data\burden_dementia\oopdata\raw hrs"
local savepath "E:\data\burden_dementia\oopdata"
local logpath "E:\data\burden_dementia\logs"

/*just do from 1998 on*/

cd "`loadpath'"

/*in the end, just doing from 2002 onward, because variable names changed each year 
prior to 02.  Use 02-12 to validate against Sean Fahle's prior one, pull 98-00 from 
his, and extend past using this code.

use h98e_hp, clear

use h00e_hp, clear
*/


tokenize h j k l m n o
local type=1

foreach year in 02 04 06 08 10 12 14 {
		use "h`year'g_hp", clear
		rename *, l
		gen year=20`year'
		gen id=hhid+pn
		gen s=``type''g069==2 & ``type''g076!=1
		gen u=(inrange(``type''g069,3,19) | inrange(``type''g069,26,31) | ///
		 inlist(``type''g069,33,90,91))
		replace u=1 if ``type''g069==20 & ``type''g076==5
		gen i=s==1 | u==1
		gen k=inrange(``type''g069,3,8)
		gen p=inlist(``type''g069,23,24,25)
		replace p=1 if ``type''g069==20 & ``type''g076==1
		gen e=inlist(``type''g069,21,22)
		gen f=e==1 | p==1
		gen d=inlist(``type''g069,20,33,98,99) | missing(``type''g069)
		gen m=``type''g069==20 & (missing(``type''g076) | inrange(``type''g076,8,9))
		gen hp=1
		//get hours per day and days per week
		//days per month
		gen days=``type''g070
		replace days=30 if days==96
		replace days=. if days>31
		//set to 30 if 31
		replace days=30 if days==31
		//days per week
		replace days=``type''g071*(30/7) if inrange(``type''g071,1,7)
		replace days=30 if ``type''g072==1
		gen hrs=``type''g073*days if ``type''g073<=24
		
		
		foreach x in s u i k p e f d m hp {
		by id, sort: egen n_`x'=total(`x')
		by id: egen hlphrs_`x'=total(cond(`x'==1,hrs,0))
}

		keep hhid pn n_* hlph* year
		gen ivw_type=1
		tempfile t`year'
		save `t`year''
		
		local type=`type'+1
		
}

tokenize s t u v w x y
local type=1

foreach year in 02 04 06 08 10 12 14 {
		use "x`year'g_hp", clear
		rename *, l
		gen year=20`year'
		gen id=hhid+pn
		gen s=``type''g069==2 & ``type''g076!=1
		gen u=(inrange(``type''g069,3,19) | inrange(``type''g069,26,31) | ///
		 inlist(``type''g069,33,90,91))
		replace u=1 if ``type''g069==20 & ``type''g076==5
		gen i=s==1 | u==1
		gen k=inrange(``type''g069,3,8)
		gen p=inlist(``type''g069,23,24,25)
		replace p=1 if ``type''g069==20 & ``type''g076==1
		gen e=inlist(``type''g069,21,22)
		gen f=e==1 | p==1
		gen d=inlist(``type''g069,20,33,98,99) | missing(``type''g069)
		gen m=``type''g069==20 & (missing(``type''g076) | inrange(``type''g076,8,9))
		gen hp=1
		
		//get hours per day and days per week
		//days per month
		gen days=``type''g070
		replace days=30 if days==96
		replace days=. if days>31
		//set to 30 if 31
		replace days=30 if days==31
		//days per week
		replace days=``type''g071*(30/7) if inrange(``type''g071,1,7)
		replace days=30 if ``type''g072==1
		gen hrs=``type''g073*days if ``type''g073<=24
		
		
		foreach x in s u i k p e f d m hp {
		by id, sort: egen n_`x'=total(`x')
		by id: egen hlphrs_`x'=total(cond(`x'==1,hrs,0))
}

		keep hhid pn n_* hlph* year
		gen ivw_type=2
		tempfile x`year'
		save `x`year''
		
		local type=`type'+1
		
}

use `t02', clear
append using `x02'

foreach n in 04 06 08 10 12 14 {
	append using `t`n''
	append using `x`n''
}

label define ivw_type 1 "Core" 2 "Exit"
label values ivw_type ivw_type
rename hlphrs_hp hlphrs
/*Basic steps for validation below--it looks like the small variability is not 
meaningful and is either from rounding or from assigning 30 days instead of 31
rename n_* my_* 
rename hlphrs* myhrs*
duplicates drop
merge m:1 hhid pn year using "E:\data\hrs_oop_2010\received_data\2012\helper_hours_2012.dta"
gen dif=myhrs_s- hlphrs_s
replace dif=0 if myhrs_s=hlphrs_s*(31/30)
gen id=hhid+pn
sort year dif
list id year *hrs_s dif if dif!=0 & year==2012 & !missing(dif)
*/

append using "E:\data\hrs_oop_2010\received_data\2012\helper_hours_2012.dta"
drop if missing(ivw_type) & year>=2002
replace ivw_type=inx+1 if missing(ivw_type)

gen id=hhid+pn
order id hhid pn year ivw_type n_* 
label var n_s "Number spouse helpers"
label var n_u "Number non-spouse informal helpers (mostly kids)"
label var n_i "Number total informal helpers (spouse and other)"
label var n_k "Number kid helpers"
label var n_p "Number paid helpers (excludes institutional employees)"
label var n_e "Number institutional employee helpers"
label var n_f "Number formal helpers (paid and institutional)"
label var n_d "Number don't know formal/informal"
label var n_m "Number missing paid/unpaid"
label var n_hp "Total number of helpers"
label var hlphrs_s "Hours of help from spouse helpers"
label var hlphrs_u "Hours of help from non-spouse informal helpers (mostly kids)"
label var hlphrs_i "Hours of help from total informal helpers (spouse and other)"
label var hlphrs_k "Hours of help from kid helpers"
label var hlphrs_p "Hours of help from paid helpers (excludes institutional employees)"
label var hlphrs_e "Hours of help from institutional employee helpers"
label var hlphrs_f "Hours of help from formal helpers (paid and institutional)"
label var hlphrs_d "Hours of help from don't know formal/informal"
label var hlphrs_m "Hours of help from missing paid/unpaid"
label var hlphrs "Hours of help from all helpers"
label var ivw_type "Interview type"
label var id "HHID+PN"
label var year "Year (core or exit)"

drop *miss* *_o *_n w inx
duplicates drop
saveold "E:\data\hrs_cleaned\helper_hours_2014.dta", replace version(12)
