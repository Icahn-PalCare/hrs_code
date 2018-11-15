
use $savedir/core_merged.dta, replace
append using $savedir/exit_merged.dta, gen(iwtype)
lab def IWTYPE 0 "0.Core IW" 1 "1.Exit IW", replace
lab val iwtype IWTYPE
sort HHID PN year

/* re-apply caps */

replace MC_HMO = min( MC_HMO, 400 ) if !missing(MC_HMO)
replace MC_D = min( MC_D, 100 ) if !missing(MC_D)

replace private_medigap = min( private_medigap , cond(mc_cov==1,400,2000) ) if !missing(private_medigap)

replace private_medigap_1 = min( private_medigap_1 , cond(mc_cov==1,400,2000) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(mc_cov==1,400,2000) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(mc_cov==1,400,2000) ) if !missing(private_medigap_3)
replace private_medigap_4 = min( private_medigap_4 , cond(mc_cov==1,400,2000) ) if !missing(private_medigap_4)
replace private_medigap_5 = min( private_medigap_5 , 2000 ) if !missing(private_medigap_5)

replace private_ltc = min( private_ltc , 2000 ) if !missing(private_ltc)
replace long_term_care = min( long_term_care , 2000 ) if !missing(long_term_care)

replace hospital_OOP = min( 15000*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*months , NH_OOP) if !missing(NH_OOP)

replace patient_OOP = min( 15000*months , patient_OOP ) if !missing(patient_OOP)
replace doctor_OOP = min( 5000*months , doctor_OOP) if !missing(doctor_OOP)
replace dental_OOP = min( 1000*months , dental_OOP ) if !missing(dental_OOP)

replace RX_OOP = min( 5000 , RX_OOP) if !missing(RX_OOP)

replace home_OOP = min( 15000*months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*months , special_OOP ) if !missing(special_OOP)

replace other_OOP = min( 15000*months , other_OOP ) if !missing(other_OOP)
replace hospice_OOP = min( 5000*months , hospice_OOP ) if !missing(hospice_OOP)
replace non_med_OOP = min( 5000*months , non_med_OOP ) if !missing(non_med_OOP)
replace home_modif_OOP = min( 5000*months , home_modif_OOP ) if !missing(home_modif_OOP)

replace NH_OOP93 = min( 15000*12 , NH_OOP93) if !missing(NH_OOP93)
replace non_NH_OOP93 = min( non_NH_OOP93 , 12*(15000+15000+5000+1000+5000+15000+15000+15000) ) if !missing(non_NH_OOP93)

replace hospital_NH_OOP = min( 30000*months, hospital_NH_OOP ) if !missing(hospital_NH_OOP)
replace hospital_NH_doctor_OOP = min( 35000*months, hospital_NH_doctor_OOP ) if !missing(hospital_NH_doctor_OOP)
replace doctor_patient_dental_OOP = min( 21000*months, doctor_patient_dental ) if !missing(doctor_patient_dental)
replace home_special_OOP = min( 30000*months, home_special_OOP ) if !missing(home_special_OOP)

/*
Final steps: 
1) adjust private insurance spending for individuals who turn 65 between interviews, 
2) re-scale monthly spending to inter-IW spending, 
3) compute oop medical expenditure totals
*/

*Premiums:

gen MC_B_prem = MC_B
gen MC_HMO_prem = MC_HMO
gen MC_D_prem = MC_D
gen private_medigap_prem = private_medigap
gen private_ltc_prem = private_ltc
gen long_term_care_prem = long_term_care

egen insurance_prem = rowtotal(MC_B_prem ///
							  MC_D_prem ///
							  MC_HMO_prem ///
							  long_term_care_prem ///
							  private_medigap_prem), m
							  
replace insurance_prem = min( insurance_prem , 2000 ) if !missing(insurance_prem)

/*
NOTES:

*** Medicare (MC_HMO, MC_B, MC_D) ***

Assume that monthly spending on Medicare prior to age 65 is 0 and that spending reported at the current IW only applies to the period after 65.
In addition, require that Part D spending is zero prior to 2006.

*** Private / Medigap Insurance (private_medigap) ***

Assume that monthly private insurance spending reported at prior IW is a good proxy for monthly spending before age 65 and that monthly spending reported 
at the current interview measures monthly spending after age 65. Then, take the average of the two, weighting by the former by the share of the time 
between interviews that took place before 65 and the latter by the share that took place after 65.  

Important: If previous spending not available, no adjustment to private_medigap.

Note that due to differences in the waves 1992-1994, where some of reported private/medigap spending includes LTC, the spending variable in those waves
is called private_ltc and is not used in this adjustment.

*/

*Determine Date When Medicare Eligible (Age 65)

merge m:1 HHID PN using "$loaddir/${tracker_name}", keep(master match) nogen keepusing(BIRTHYR BIRTHMO)

gen DOB = BIRTHYR + ( (1/12) * (BIRTHMO - 1) ) if BIRTHYR!=0 & BIRTHMO!=0
gen date_65 = DOB + 65

*Determine whether turned 65 between waves

gen turned_65 = prev_iw_date < date_65 & date_65 < curr_iw_date if !missing(prev_iw_date,date_65,curr_iw_date)

*Calculate share of time between IWs that occurred before/after age 65

gen months_pre65  = round( 12 * (date_65 - prev_iw_date) ) if turned_65==1
replace months_pre65  = 0 if turned_65==0

gen months_post65 = round( 12 * (curr_iw_date - date_65) ) if turned_65==1
replace months_post65 = months if turned_65==0

*Calculate total insurance costs

replace MC_B = months_post65 * MC_B_prem if turned_65==1
replace MC_B = months * MC_B_prem if turned_65!=1

replace MC_HMO = months_post65 * MC_HMO_prem if turned_65==1
replace MC_HMO = months * MC_HMO_prem if turned_65!=1

replace MC_D = MC_D_prem * min( months, max( round( 12 * (curr_iw_date - 2006) ), 0) )

*grab spending from private/medigap spending from prior wave
sort HHID PN year
by HHID PN: gen private_medigap_prev = private_medigap_prem[_n-1]

replace private_medigap = (months_pre65 * private_medigap_prev) + (months_post65 * private_medigap_prem) if turned_65==1 & !missing(private_medigap_prev)
replace private_medigap = months * private_medigap_prem if turned_65!=1 | (turned_65==1 & missing(private_medigap_prev))

replace long_term_care = months * long_term_care_prem

egen insurance_costs = rowtotal( MC_HMO ///
								 MC_B ///
								 MC_D ///
								 private_medigap ///
								 long_term_care ) , missing

* set the monthly max at 2000 dollars 
replace insurance_costs = min( 2000*months , insurance_costs) if !missing(insurance_costs)

* extend private/ltc spending to cover entire inter-IW period in 1992-1994
replace private_ltc = private_ltc_prem * months

* extend monthly RX and helper spending to cover entire inter-IW period
replace RX_OOP = RX_OOP * months

replace helper_OOP = helper_OOP * min( 4 , months )
replace helper_OOP = 0 if missing(helper_OOP)

replace helper_OOP93 = helper_OOP93 * min( 4 , months )
replace helper_OOP93 = 0 if missing(helper_OOP93)

* set # helpers to 0 if missing (i.e. assume no helpers)
replace numhelpers = 0 if missing(numhelpers)
replace numpaidhelpers = 0 if numhelpers==0

replace numhelpers93 = 0 if missing(numhelpers93)
replace numpaidhelpers93 = 0 if numhelpers93==0

* compute certain aggregates for comparability across waves
egen x = rowtotal( hospital_OOP NH_OOP ),m
replace hospital_NH_OOP = x if missing(hospital_NH_OOP)
drop x

egen x = rowtotal( home_OOP special_OOP ),m
replace home_special_OOP = x if missing(home_special_OOP)
drop x

egen x = rowtotal( doctor_OOP patient_OOP dental_OOP ),m
replace doctor_patient_dental_OOP = x if missing(doctor_patient_dental_OOP)
drop x

egen x = rowtotal( hospital_OOP NH_OOP doctor_OOP ),m
replace hospital_NH_doctor_OOP = x if missing(hospital_NH_doctor_OOP)
drop x

egen total_OOP = rowtotal( ///
								insurance_costs ///
								hospital_NH_OOP ///
								doctor_patient_dental ///
								hospice_OOP ///
								RX_OOP ///
								home_special_OOP ///
								other_OOP ///
								non_med_OOP ///
								home_modif_OOP ///
								helper_OOP) if year>=1995 ,m

egen x = rowtotal( MC_B private_ltc NH_OOP93 non_NH_OOP93 helper_OOP93 ) if year==1993 ,m 
replace total_OOP = x if year==1993
drop x

egen x = rowtotal( private_ltc hospital_NH_doctor_OOP RX_OOP ) if year==1994 ,m 
replace total_OOP = x if year==1994
drop x

save $savedir/oopme_final.dta, replace
