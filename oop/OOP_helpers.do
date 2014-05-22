/*do file to merge oop and helper datasets in Stata*/

capture log close

clear all
set mem 200m
set more off

//mac file path
//local datapath /Users/rebeccagorges/Documents/data/hrs

//pen drive file path, RG
local datapath H:\OOP\data

use `datapath'/oopme_final_oldv.dta

rename HHID hhid
rename PN pn

merge 1:1 hhid pn year using `datapath'/helper_hours_oldv.dta

//create indicator for having oop and helper data
gen ind_helper_and_oop = 0
replace ind_helper_and_oop=1 if _merge==3
tab ind_helper_and_oop

drop _merge

replace n_hp=0 if n_hp==.

sum n_hp if ind_helper_and_oop==1

sum numhelpers  if ind_helper_and_oop==1

sum n_p if ind_helper_and_oop==1

sum numpaidhelpers  if ind_helper_and_oop==1

//create oop spending per month vairables
local oopvars NH_OOP hospital_OOP doctor_OOP dental_OOP patient_OOP home_OOP ///
RX_OOP special_OOP  other_OOP hospice_OOP non_med_OOP total_OOP insurance_costs
foreach v in `oopvars'{
gen `v'_mo=`v'/months
sum `v'_mo, detail
sum `v'_mo if `v'_mo>0, detail
replace `v'=0 if `v'==. 
}

//per codebook, helper spending inflated for 4 months or number
//of elapsed months if less than 4
gen helper_OOP_mo = helper_OOP / 4 if months>4 & months!=.
replace helper_OOP_mo = helper_OOP / months if months<4
sum helper_OOP_mo, detail
sum helper_OOP_mo if helper_OOP_mo>0, detail

sca hrsmo=r(mean)/21 //uses mean hourly rate $21/hour
sca hrsday=hrsmo/30.5
sca list 

//helper spending, look at spending per paid helper
gen per_paidhelper_mo = helper_OOP_mo / numpaidhelpers
sum per_paidhelper_mo, detail

//does total oop include insurance costs variable? - YES!
gen total_OOP_calc = NH_OOP + hospital_OOP + doctor_OOP + dental_OOP + patient_OOP + home_OOP + ///
RX_OOP + special_OOP +   hospice_OOP + non_med_OOP
gen total_OOP_calc_w_ins =   NH_OOP + hospital_OOP + doctor_OOP + dental_OOP + patient_OOP + home_OOP + ///
RX_OOP + special_OOP +   hospice_OOP + non_med_OOP +  insurance_costs

gen check_oop_total = total_OOP - total_OOP_calc
gen check_oop_total_w_ins = total_OOP - total_OOP_calc_w_ins

sum check_oop_total, detail
sum check_oop_total_w_ins, detail

//look at change in number of helpers between waves
sort hhid pn year
//number of helpers previous year
by hhid pn: gen bef1_numpaidhelpers=numpaidhelpers[_n-1]
by hhid pn: gen bef1_numhelpers=numhelpers[_n-1]

tab numpaidhelpers bef1_numpaidhelpers if numpaidhelpers>0
tab numhelpers bef1_numhelpers if numhelpers>0

