capture log close
log using "${logs}/2004exit.log",replace
/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			04exit.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Impute the 2004 exit medical expenditures


ORGANIZATION:	Section 1: Set Up
				SECTION 2: Insurance Costs
				Section 3: Medical Expenditures
				
INPUTS: 		2004exit.dta
				
OUTPUTS: 		2004exit.log X2004OOP.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Set Up
****************************************************************/

use "${buildoutput}/2004exit.dta", clear

do "${deps}/MMS2011_repute.do"  // source repute function
/****************************************************************
	SECTION 1.1: Make weights
****************************************************************/
gen weight04 = HWGTR  // previous wave weight b/e dead have zero weight

replace weight04 = GWGTR if weight04 == 0
replace weight04 = FWGTR if weight04 == 0

* adds in the early AHEAD people;
replace weight04 = DWGTR if (HWHY0WGT == 3 & FWHY0WGT == 3 & weight04 == 0)
replace weight04 = BWGTR if (HWHY0WGT == 3 & DWHY0WGT == 3 & weight04 == 0)
* ADDs in the early HRS people;
replace weight04 = EWGTR if (HWHY0WGT == 3 & FWHY0WGT == 3 & weight04 == 0)
replace weight04 = CWGTR if (HWHY0WGT == 3 & EWHY0WGT == 3 & weight04 == 0)
replace weight04 = AWGTR if (HWHY0WGT == 3 & CWHY0WGT == 3 & weight04 == 0)

/****************************************************************
	SECTION 1.2: Calculate months since previous interview
****************************************************************/
gen death_month = TA121
replace death_month = . if (death_month == 98 | death_month == 99)
gen death_year = TA123
replace death_year = . if (death_year == 9998 |death_year == 9999)

gen prev_interview_date = HIWYEAR + ((HIWMONTH - 1)/12)
gen curr_interview_date = death_year + ((death_month - 1)/12)

* current interview date is really the date of death
gen time = (curr_interview_date - prev_interview_date)

* assign 1.2 to ppl with missing or negative dates (1.2 is mean time b/w intrvw)
replace time = 1/12 if (curr_interview_date == prev_interview_date)
replace time = 1.2 if (curr_interview_date != . & prev_interview_date == .)
replace time = 1.2 if (time < 0)
replace time = 1.2 if (curr_interview_date == . & prev_interview_date != .)

gen months = round(12 * time)
* ppl who skipped an interview get cut off at 3 years
replace months = 36 if (months > 36 & months != .)

gen year = (1/ time)

/****************************************************************
	SECTION 1.3: Create expenditure caps
****************************************************************/
* Expenditures are capped based on the number of months since the previous
* interview. The relevant limits need to be made into nominal amounts as well.
gen cap15k = 14086 * months
gen cap5k  = 4695 * months

/****************************************************************
	SECTION 1.3: Make max expenditures into 2004 dollars
****************************************************************/
#del ;
global all "mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all 
	doctor_all hospice_all RX_all home_all other_all nmed_all special_all";
#del cr;

foreach y of global all {
replace `y' = (`y' * (109.462/116.567))
}

/****************************************************************
	SECTION 1.4: Cap helper_OOP variable
****************************************************************/
* helper_OOP is in terms of 4 months, if the person lived for less than four 
* months since the previous interview, assign them N months * monthly cost
replace helper_OOP = min(helper_OOP, months*helper_OOP/4)

*cap at 15k per month in the same way, using the 4 month convsion cond on survival
replace helper_OOP = cap15k if (helper_OOP > cap15k & helper_OOP != .)
replace helper_OOP = 14086*4 if (helper_OOP > 14086*4 & helper_OOP != .)
sum helper_OOP, det

/****************************************************************
	SECTION 2: Insurance Costs
****************************************************************/

/****************************************************************
	SECTION 2.1: Medicare/Medicaid through an HMO (MC_HMO) 
****************************************************************/
gen MC_HMO = TN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

* Make the premium in terms of one month
replace MC_HMO = 1 * MC_HMO if TN018 == 1
replace MC_HMO = (1/3) * MC_HMO if TN018 == 2
replace MC_HMO = (1/6) * MC_HMO if TN018 == 3
replace MC_HMO = (1/12) * MC_HMO if TN018 == 4

repute TN015 TN016 mc_hmo_all MC_HMO

* Assign mean to ppl who DK about the cost of coverage
qui sum MC_HMO
replace MC_HMO = r(mean) if (inlist(TN014, 998, 999) | ///
	inlist(TN017, 98, 99) | inlist(TN018, 8, 9) | (TN009 == 1)) & mi(MC_HMO)

* people who did not have an HMO medicare/medicaid plan or did not recieve benefits
replace MC_HMO = 0 if (TN009 == 5)

* Assign this mean to ppl who DK if they coverage through an HMO
qui sum MC_HMO
replace MC_HMO = r(mean) if (TN009 == 8 | TN009 == 9) & mi(MC_HMO)

summ MC_HMO, det

/****************************************************************
	SECTION 2.2: Medicare Part B 
****************************************************************/
gen MC_B = (66.6) if (TN004 == 1 & TN005 != 1 & TN007 != 1)

/****************************************************************
	SECTION 2.3: Private Insurance
****************************************************************/
gen private_medigap_1 = TN040_1
recode private_medigap_1 (9998 9999 = .)

repute TN041_1 TN042_1 private_medigap_all private_medigap_1

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if ((TN040_1 == 9998 | TN040_1 == 9999) | ///
	(TN043_1 == 98 | TN043_1 == 99)) & mi(private_medigap_1)

* people who paid nothing for their private health coverage
replace private_medigap_1 = 0 if (TN039_1 == 3 | TN023 == 0)

/* *********************************************************************** */
gen private_medigap_2 = TN040_2
recode private_medigap_2 (9998 9999 = .)

repute TN041_2 TN042_2 private_medigap_all private_medigap_2

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if ((TN040_2 == 9998 | TN040_2 == 9999) | ///
	(TN043_2 == 98 | TN043_2 == 99)) & mi(private_medigap_2)

* this will add in the people who paid nothing for their private health coverage
replace private_medigap_2 = 0 if (TN039_2 == 3 | TN023 == 0 | TN023 == 1)

/* *********************************************************************** */
*Sum private medigap plans

egen private_medigap = rowtotal(private_medigap_1 private_medigap_2), m

*Assign unconditional mean to those who were responsible for atleast part of the coverage
qui sum private_medigap
replace private_medigap = r(mean) if (inlist(TN039_1, 1, 2, 8, 9) | ///
	inlist(TN039_2, 1, 2, 8, 9) | inlist(TN039_3, 1, 2, 8, 9) | ///
	(TN023 > 0 & TN023 != .)) & mi(private_medigap)

summ private_medigap, det

/****************************************************************
	SECTION 2.4: Long-term-care
****************************************************************/ 
gen long_term_care = TN079
recode long_term_care (99998 99999 = . )

* Make the premium in terms of one month
replace long_term_care = 1 * long_term_care if (TN083 == 1)
replace long_term_care = (1/3) * long_term_care if (TN083 == 2)
replace long_term_care = 4 * long_term_care if (TN083 == 3)
replace long_term_care = (1/12) * long_term_care if (TN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (TN083 == 6)

repute TN080 TN081 ltc_all long_term_care

* Assign mean to ppl who DK about the cost of coverage
qui sum long_term_care
replace long_term_care = r(mean) if ((TN079 == 99998 | TN079 == 99999) | ///
	inlist(TN082, 98, 99) | (TN071 == 1)) & mi(long_term_care)

* Asssign zero cost to ppl w/out LTC at the time of death
replace long_term_care = 0 if (TN071 == 5)

*Assign unconditional mean to ppl who DK if they had LTC insurance
qui sum long_term_care
replace long_term_care = r(mean) if (TN071 == 8 | TN071 == 9) & mi(long_term_care)

summ long_term_care, det

/* *********************************************************************** */
* sum all insurance costs
egen insurance_costs = rowtotal(MC_HMO long_term_care private_medigap MC_B), m

* cap exp at 2000 dollars
replace insurance_costs = 1878 if (insurance_costs > 1878 & insurance_costs != .)

* adjust insurance costs to be total exp since previous irw
replace insurance_costs = (months * insurance_costs)

summ insurance_costs, det

/****************************************************************
	SECTION 3: Medical Expenditures
****************************************************************/

/****************************************************************
	SECTION 3.1: Hospital
****************************************************************/
gen hospital_OOP = TN106
recode hospital_OOP (99998 99999 = .)

repute TN107 TN108 hospital_all hospital_OOP  //Assign means to first 100 bounds

* Assign mean to ppl who DK their hospital expenses 
qui sum hospital_OOP
#del ;
replace hospital_OOP = r(mean) if (((TN106 == 999998| TN106 == 999999) |  
(TN109 == 98 | TN109 == 99)) & (hospital_OOP == .));
#del cr;

*this puts in the people whose hospital costs were fully covered
replace hospital_OOP = 0 if TN102 == 1

*assign this mean to people who had partial insurance coverage
qui sum hospital_OOP
replace hospital_OOP = r(mean) if ((TN099 == 1) | ///
	inlist(TN102, 2, 3, 5, 7, 8, 9)) & mi(hospital_OOP)

replace hospital_OOP = 0 if TN099 == 5  //never stayed in the hospital

/* this will add in the yes answers that had no value in the above
 two question and the DKs/RFs from those questions */
qui sum hospital_OOP
replace hospital_OOP = r(mean) if inlist(TN099, 8,9) & mi(hospital_OOP)

* Cap expenditure at 15k per month
replace hospital_OOP = cap15k if (hospital_OOP > cap15k & ~mi(hospital_OOP))

summ hospital_OOP, det

/****************************************************************
	SECTION 3.2: Nursing Home
****************************************************************/
gen NH_OOP = TN119
recode NH_OOP (999998 999999 = .)

repute TN120 TN121 nursing_home_all NH_OOP

* Replace the Dks with the mean; the DK variable is TN122
quietly sum NH_OOP
replace NH_OOP = r(mean) if ((TN119 == 999998 | TN119 == 999999) | ///
	inlist(TN122, 98, 99)) & mi(NH_OOP)

* Add people whose costs were completely covered by insurance
replace NH_OOP = 0 if (TN118 == 1 & NH_OOP == .)

* Add in the people who were in a NH but may have had no expenses.
quietly sum NH_OOP
replace NH_OOP = r(mean) if (inlist(TN118, 2, 3, 5, 7, 8, 9) | ///
	(TN114 == 1)) & mi(NH_OOP)

* Add in the people who never stayed overnight in a NH
*put TN001 in as a proxy for having a full interview for this section.
replace NH_OOP = 0 if (TN115 == . & TN001 != . & NH_OOP == .)

* Assign unconditional mean to DK/RF for num nights in NH
quietly sum NH_OOP
replace NH_OOP = r(mean) if inlist(TN115, 98, 99) & mi(NH_OOP)

* Cap expenditure at 15k per month
replace NH_OOP = cap15k if (NH_OOP > cap15k & ~mi(NH_OOP))

summ NH_OOP, det

/****************************************************************
	SECTION 3.3: Doctor Visits
****************************************************************/
gen doctor_OOP = TN156
recode doctor_OOP (99998 99999 = .)

* Assign means to first 100 bounds
repute TN157 TN158 doctor_all doctor_OOP

* Replace the Dks with the mean; The DK variable is TN159
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if ((TN156 == 99998 | TN156 == 99999) | ///
(TN159 == 98 | TN159 == 99)) & mi(doctor_OOP)

* Add people whose costs were completely covered by insurance
replace doctor_OOP = 0 if (TN152 == 1 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if (TN147 != . & TN147 != 0) & mi(doctor_OOP) 

* Add the people who never saw a doctor
replace doctor_OOP = 0 if (TN147 == 0 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if inlist(TN152, 2, 3, 5, 7, 8, 9) & mi(doctor_OOP)

* Cap monthly expenditure at 5,000 dollars
replace doctor_OOP = cap5k if (doctor_OOP > cap5k & ~mi(doctor_OOP))

summ doctor_OOP, det

/****************************************************************
	SECTION 3.4: Hospice
****************************************************************/
gen hospice_OOP = TN328
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

repute TN329 TN330 hospice_all hospice_OOP

* Replace DK/RF and partial insurance coverage with mean
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (inlist(TN324, 2, 3, 5, 7, 8, 9) | ///
	(TN328 == 9999998 | TN328 == 9999999) | (TN331 == 98 | TN331 == 99) | ///
	(TN320 == 1)) & mi(hospice_OOP)

* Assign zero cost to ppl whose costs were fully covered by insurance
replace hospice_OOP = 0 if TN324 == 1

* Assign zero cost to ppl who have not been a patient in a hospice
replace hospice_OOP = 0 if TN320 == 5

*Assign unconditional mean to ppl who DK if they were a patient in hospice
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (TN320 == 8 | TN320 == 9) & mi(hospice_OOP)

* Cap monthly expenditure at 5,000 dollars
replace hospice_OOP = cap5k if (hospice_OOP > cap5k & ~mi(hospice_OOP))

*output the data that I want
summ hospice_OOP, det

/****************************************************************
	SECTION 3.5: RX costs (annual)
	The HRS reports in months, so this will have to be converted 
****************************************************************/

gen RX_OOP = TN180
replace RX_OOP = . if (RX_OOP == 9998 | RX_OOP == 9999)

* replace the imputations with the mean value for that year
repute TN181 TN182 RX_all RX_OOP

* Replace the Dks with the mean; TN183 is the DK variable
quietly sum RX_OOP
replace RX_OOP = r(mean) if ((TN180 == 99998 | TN180 == 99999) | ///
(TN183 == 98 | TN183 == 99) | (TN175 == 1)) & mi(RX_OOP)

* Costs were completely covered by insurance
replace RX_OOP = 0 if TN176 == 1

* Assign unconditional mean to ppl who DK about taking drugs and ins part pay
quietly sum RX_OOP
replace RX_OOP = r(mean) if inlist(TN176, 2, 3, 5, 7, 8, 9) & mi(RX_OOP)

* Assign zero cost to ppl who don't take drugs regularly
replace RX_OOP = 0 if TN175 == 5

* Assign unconditional mean to ppl who DK about taking drugs
quietly sum RX_OOP
replace RX_OOP = r(mean) if inlist(TN175, 8, 9) & mi(RX_OOP)

*sets the cut off at $ 5,000
replace RX_OOP = 4695 if (RX_OOP > 4695 & RX_OOP != .)

*Scale payments to time between interviews
replace RX_OOP = (months * RX_OOP)

*output the data that I want
summ RX_OOP, det

/****************************************************************
	SECTION 3.6: In Home health care costs 
****************************************************************/
gen home_OOP = TN194
replace home_OOP = . if (home_OOP == 99998 | home_OOP == 99999)

repute TN195 TN196 home_all home_OOP

* this will replace the Dks/RFs/NAs with the mean
qui sum home_OOP
replace home_OOP = r(mean) if ((TN194 == 999998 | TN194 == 999999) | ///
	(TN189 == 1) | (TN197 == 98 | TN197 == 99)) & mi(home_OOP)

*ppl whose costs were fully covered by insurance, or were provided for free for some reason
replace home_OOP = 0 if (TN190 == 1 | TN190 == 6)

* Assign conditional mean to ppl who had their costs partly covered by insurance
qui sum home_OOP
replace home_OOP = r(mean) if inlist(TN190, 2, 3, 5, 7, 8, 9) & mi(home_OOP)

*people who didn't use any of the services
replace home_OOP = 0 if (TN189 == 5)

* Assign unconditional mean to ppl who DK if they had these expenses
qui sum home_OOP
replace home_OOP = r(mean) if (TN189 == 8 | TN189 == 9) & mi(home_OOP)

* cap exp at 15k per month
replace home_OOP = cap15k if (home_OOP > cap15k & ~mi(home_OOP))

summ home_OOP, det

/****************************************************************
	SECTION 3.7: Other medical expenses
		expenses not covered by insurance, such as
                  medications, special food, equipment such as a special
                  bed or chair, visits by doctors or other health professionals,
                  or other costs
****************************************************************/
gen other_OOP = TN333
recode other_OOP (99998 99999 = .)

repute TN334 TN335 other_all other_OOP

*replace the Dks/RFs/NAs with the mean. The DK variable is TN336
qui sum other_OOP
replace other_OOP = r(mean) if ((TN332 == 1) | (TN333 == 99998 | ///
	TN333 == 99999) | (TN336 == 98 | TN336 == 99)) & mi(other_OOP)

*people who had no expenses of this type
replace other_OOP = 0 if TN332 == 5

*Assign unconditional mean to ppl who DK if they had this type of expense
qui sum other_OOP
replace other_OOP = r(mean) if (TN332 == 8 | TN332 == 9) & mi(other_OOP)

* Cap expenditure at 15k per month
replace other_OOP = cap15k if (other_OOP > cap15k & ~mi(other_OOP))

summ other_OOP, det

/****************************************************************
	SECTION 5.8: Non-medical expenditure 
****************************************************************/
gen non_med_OOP = TN338
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

* replace the imputations with the mean value for that year
repute TN339 TN340 nmed_all non_med_OOP

* replace the Dks/RFs/NAs with the mean. TN341 is the DK variable
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if ((TN337 == 1) | (TN338 == 999998 | ///
TN338 == 999999) | (TN341== 98 | TN341 == 99)) & mi(non_med_OOP)

*people who had none of these expenses
replace non_med_OOP = 0 if TN337 == 5

* Assign uncond mean to ppl who DK if had this type of expense
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if (TN337 == 8 | TN337 == 9) & mi(non_med_OOP)

*Cap exp at 5k per month
replace non_med_OOP = cap5k if (non_med_OOP > cap5k & ~mi(non_med_OOP))

summ non_med_OOP, det

/****************************************************************
	SECTION 3.9: Special services expenditures
****************************************************************/
gen spec_OOP = TN239
replace spec_OOP = . if (TN239 == 99998 | TN239 == 99999)

repute TN246 TN247 special_all spec_OOP

qui sum spec_OOP
replace spec_OOP = r(mean) if ((TN203 == 1) | (TN239 == 999998 | ///
	TN239 == 999999) | (TN248 == 98 | TN248 == 99)) & mi(spec_OOP)

*ppl who did not use services or did not have costs
replace spec_OOP = 0 if (TN202 == 5 | TN203 == 5)

qui sum spec_OOP
replace spec_OOP = r(mean) if ((TN202 == 8 | TN202 == 9) | ///
	(TN203 == 8 | TN203 == 9)) & mi(spec_OOP)

* Cap expenditure at 15k per month
replace spec_OOP = cap15k if (spec_OOP > cap15k & ~mi(spec_OOP))

summ spec_OOP, det

/****************************************************************
	SECTION 4: Total OOP expenditure
****************************************************************/

egen total_OOP = rowtotal(insurance_costs hospital_OOP NH_OOP doctor_OOP ///
	hospice_OOP RX_OOP home_OOP other_OOP non_med_OOP helper_OOP spec_OOP), m

summ total_OOP, det

/****************************************************************
	SECTION 5: Clean Up
****************************************************************/
rename TA126M death_area
label values death_area death_region

#del ;
global OOP "insurance_costs hospital_OOP doctor_OOP hospice_OOP RX_OOP home_OOP 
other_OOP non_med_OOP helper_OOP total_OOP MC_HMO private_medigap 
spec_OOP NH_OOP long_term_care MC_B";
#del cr;

* make expenses in 2006 dollars
foreach y of global OOP {
	replace `y' = 0 if mi(`y') & ~mi(total_OOP)
	replace `y' = (`y' * (116.567/109.462))
}

keep HHID PN *_OOP death_area insurance_costs death_month death_year time ///
	months weight04 MC_HMO long_term_care private_medigap MC_B
drop if total_OOP == .
merge 1:1 HHID PN using "${rawdata}/${trversion}", keep(match) nogen

program drop repute
save "${OOPdata}/X2004OOP.dta", replace

log close 
