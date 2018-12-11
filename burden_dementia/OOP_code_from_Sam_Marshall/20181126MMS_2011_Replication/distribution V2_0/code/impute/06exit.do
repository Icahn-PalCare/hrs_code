capture log close
log using "${logs}/2006exit.log",replace
/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			06exit.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Impute the 2006 exit medical expenditures


ORGANIZATION:	Section 1: Set Up
				SECTION 2: Insurance Costs
				Section 3: Medical Expenditures
				
INPUTS: 		2006exit.dta
				
OUTPUTS: 		2006exit.log X2006OOP.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Set-Up
****************************************************************/

use "${buildoutput}/2006exit.dta", clear

do "${deps}/MMS2011_repute.do"  // source repute function

/****************************************************************
	SECTION 1.1: Make weights
****************************************************************/

* previous wave weight b/e dead have zero weight
gen weight06 = JWGTR 

* Nursing home residents have zero weight. Assign them a weight based on their 
*	last interview w/ non-zero weight.
	
replace weight06 = HWGTR if weight06 == 0
replace weight06 = GWGTR if weight06 == 0
replace weight06 = FWGTR if (JWHY0RWT == 2 & GWHY0WGT == 3 & weight06 == 0)

* adds in the early AHEAD people;
replace weight06 = DWGTR if (JWHY0RWT == 2 & FWHY0WGT == 3 & weight06 == 0)
replace weight06 = BWGTR if (JWHY0RWT == 2 & DWHY0WGT == 3 & weight06 == 0)

* ADDs in the early HRS people;
replace weight06 = EWGTR if (JWHY0RWT == 2 & FWHY0WGT == 3 & weight06 == 0)
replace weight06 = CWGTR if (JWHY0RWT == 2 & EWHY0WGT == 3 & weight06 == 0)

replace weight06 = . if (dead06 != 3)

/****************************************************************
	SECTION 1.2: Calculate months since previous interview
****************************************************************/
gen death_month = UA121
replace death_month = . if (death_month == 98 | death_month == 99)
gen death_year = UA123
replace death_year = . if (death_year == 9998 |death_year == 9999)

gen prev_interview_date = JIWYEAR + ((JIWMONTH - 1)/12)
gen curr_interview_date = death_year + ((death_month - 1)/12)

* current interview date is actually the date of death, not the interview date.
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
gen cap15k = 15000 * months
gen cap5k  = 5000 * months

/****************************************************************
	SECTION 1.4: Make max expenditures into 2006 dollars (just for good book keeping)
****************************************************************/
#del ;
global all "mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all 
	doctor_all hospice_all RX_all home_all other_all nmed_all special_all";
#del cr;

foreach y of global all {
replace `y' = (`y' * ${nom06})
}

/****************************************************************
	SECTION 1.5: Cap helper_OOP variable
****************************************************************/
* helper_OOP is in terms of 4 months, if the person lived for less than four 
* months since the previous interview, assign them N months * monthly cost
replace helper_OOP = min(helper_OOP, months*helper_OOP/4)

*cap at 15k per month in the same way, using the 4 month convsion cond on survival
replace helper_OOP = cap15k if (helper_OOP > cap15k & helper_OOP != .)
replace helper_OOP = 15000*4 if (helper_OOP > 15000*4 & helper_OOP != .)
sum helper_OOP, det

/****************************************************************
	SECTION 2: Insurance Costs
****************************************************************/

/****************************************************************
	SECTION 2.1: Medicare/Medicaid through an HMO (MC_HMO) 
****************************************************************/
gen MC_HMO = UN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

* Make the premium in terms of one month
replace MC_HMO = 1 * MC_HMO if UN018 == 1
replace MC_HMO = (1/3) * MC_HMO if UN018 == 2
replace MC_HMO = (1/6) * MC_HMO if UN018 == 3
replace MC_HMO = (1/12) * MC_HMO if UN018 == 4

repute UN015 UN016 mc_hmo_all MC_HMO

* Assign mean to ppl who DK about the cost of coverage
qui sum MC_HMO
replace MC_HMO = r(mean) if (inlist(UN014, 998, 999) | /// 
	inlist(UN017, 98, 99) | (UN009 == 1)) & mi(MC_HMO)

* people who did not have an HMO medicare/medicaid plan or did not recieve benefits
replace MC_HMO = 0 if (UN009 == 5)

* Assign this mean to ppl who DK if they coverage through an HMO
qui sum MC_HMO
replace MC_HMO = r(mean) if (UN009 == 8 | UN009 == 9) & mi(MC_HMO)

summ MC_HMO, det

/****************************************************************
	SECTION 2.2: Medicare Part B 
****************************************************************/
gen MC_B = (88.5) if (UN004 == 1 & UN005 != 1 & UN007 != 1)

/****************************************************************
	SECTION 2.3: Private Insurance
****************************************************************/
gen private_medigap_1 = UN040_1
recode private_medigap_1 (998 999 = .)

repute UN041_1 UN042_1 private_medigap_all private_medigap_1

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if ((UN040_1 == 998 | UN040_1 == 999) | ///
	(UN043_1 == 98 | UN043_1 == 99)) & mi(private_medigap_1)

* people who paid nothing for their private health coverage
replace private_medigap_1 = 0 if (UN039_1 == 3 | UN023 == 0)

/* *********************************************************************** */
gen private_medigap_2 = UN040_2
recode private_medigap_2 (998 999 = .)

repute UN041_2 UN042_2 private_medigap_all private_medigap_2

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if ((UN040_2 == 998 | UN040_2 == 999) | ///
	(UN043_2 == 98 | UN043_2 == 99)) & mi(private_medigap_2)

*people who paid nothing for their private health coverage
replace private_medigap_2 = 0 if (UN039_2 == 3 | UN023 == 0 | UN023 == 1)

/* *********************************************************************** */
gen private_medigap_3 = UN040_3
recode private_medigap_3 (998 999 = .)

repute UN041_3 UN042_3 private_medigap_all private_medigap_3

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if ((UN040_3 == 998 | UN040_3 == 999) | ///
	(UN043_3 == 98 | UN043_3 == 99)) & mi(private_medigap_3)

* people who paid nothing for their private health coverage
replace private_medigap_3 = 0 if (UN039_3 == 3  | UN023 == 0 | UN023 == 1 | UN023 == 2)

/* *********************************************************************** */
*put all three variables together

egen private_medigap = rowtotal(private_medigap_1 private_medigap_2 private_medigap_3), m

*Assign strictly positive mean to people with atleast 1 private plan
qui sum private_medigap if private_medigap > 0
replace private_medigap = r(mean) if (UN023 == 8 | UN023 == 9) & mi(private_medigap)

*Assign unconditional mean to those who were responsible for atleast part of the coverage
qui sum private_medigap
replace private_medigap = r(mean) if (inlist(UN039_1, 1, 2, 8, 9) | ///
	inlist(UN039_2, 1, 2, 8, 9) | inlist(UN039_3, 1, 2, 8, 9) | ///
	(UN023 > 0 & UN023 != .)) & mi(private_medigap)

summ private_medigap,det

/****************************************************************
	SECTION 2.4: Long-term-care
****************************************************************/ 
gen long_term_care = UN079
recode long_term_care (999998 999999 = . )

* Make the premium in terms of one month
replace long_term_care = 1 * long_term_care if (UN083 == 1)
replace long_term_care = (1/3) * long_term_care if (UN083 == 2)
replace long_term_care = 4 * long_term_care if (UN083 == 3)
replace long_term_care = (1/12) * long_term_care if (UN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (UN083 == 6)

repute UN080 UN081 ltc_all long_term_care

* Assign mean to ppl who DK about the cost of coverage
qui sum long_term_care
replace long_term_care = r(mean) if ((UN079 == 999998 | UN079 == 999999) | ///
	inlist(UN082, 98, 99)) & mi(long_term_care)

* Asssign zero cost to ppl w/out LTC at the time of death
replace long_term_care = 0 if (UN071 == 5)

*Assign unconditional mean to ppl who DK if they had LTC insurance
qui sum long_term_care
replace long_term_care = r(mean) if (UN071 == 8 | UN071 == 9)  & mi(long_term_care)

summ long_term_care, det

/* *********************************************************************** */
* sum all insurance costs
egen insurance_costs = rowtotal(MC_HMO long_term_care private_medigap MC_B), m

* cap exp at 2000 dollars
replace insurance_costs = 2000 if (insurance_costs > 2000 & insurance_costs != .)

* adjust insurance costs to be total exp since previous irw
replace insurance_costs = (months * insurance_costs)

summ insurance_costs,det

/****************************************************************
	SECTION 3: Medical Expenditures
****************************************************************/

/****************************************************************
	SECTION 3.1: Hospital
****************************************************************/
gen hospital_OOP = UN106
recode hospital_OOP (9999998 9999999 = .)

repute UN107 UN108 hospital_all hospital_OOP  //Assign means to first 100 bounds

* Assign mean to ppl whose costs were partially covered or DK 
qui sum hospital_OOP
replace hospital_OOP = r(mean) if ((UN106 == 9999998 | UN106 == 9999999) | /// 
	inlist(UN109, 98, 99) | inlist(UN102, 2, 3, 5, 7, 8, 9)) & mi(hospital_OOP)

*hospital costs were fully covered by ins or never stayed in a hospital
replace hospital_OOP = 0 if (UN102 == 1 | UN099 == 5)

* people who stayed overnight in a hospital but DK expense
qui sum hospital_OOP
replace hospital_OOP = r(mean) if inlist(UN099, 1, 8,9) & mi(hospital_OOP)

* Cap expenditure at 15k per month
replace hospital_OOP = cap15k if (hospital_OOP > cap15k & ~mi(hospital_OOP))

summ hospital_OOP, det

/****************************************************************
	SECTION 3.2: Nursing Home
****************************************************************/
gen NH_OOP = UN119
recode NH_OOP (9999998 9999999 = .)

repute UN120 UN121 nursing_home_all NH_OOP

* Replace the Dks with the mean; the DK variable is UN122
quietly sum NH_OOP
replace NH_OOP = r(mean) if ((UN119 == 9999998 | UN119 == 9999999) | ///
	inlist(UN122, 98, 99)) & mi(NH_OOP)

* Add people whose costs were completely covered by insurance
replace NH_OOP = 0 if (UN118 == 1 & NH_OOP == .)

* Add in the people who were in a NH but may have had no expenses.
quietly sum NH_OOP
replace NH_OOP = r(mean) if (inlist(UN118, 2, 3, 5, 7, 8, 9) | ///
	(UN114 == 1)) & mi(NH_OOP)

* Add in the people who never stayed overnight in a NH
*put UN001 in as a proxy for having a full interview for this section.
replace NH_OOP = 0 if (UN115 == . & UN001 != . & NH_OOP == .)

* Assign unconditional mean to DK/RF for num nights in NH
quietly sum NH_OOP
replace NH_OOP = r(mean) if inlist(UN115, 98, 99) & mi(NH_OOP)

* Cap expenditure at 15k per month
replace NH_OOP = cap15k if (NH_OOP > cap15k & ~mi(NH_OOP))

summ NH_OOP, det 

/****************************************************************
	SECTION 3.3: Doctor Visits
****************************************************************/
gen doctor_OOP = UN156
recode doctor_OOP (9999998 9999999 = .)

* Assign means to first 100 bounds
repute UN157 UN158 doctor_all doctor_OOP

* Replace the Dks with the mean; The DK variable is UN159
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if ((UN156 == 9999998 | UN156 == 9999999) | ///
	inlist(UN159, 98, 99)) & mi(doctor_OOP)

* Add people whose costs were completely covered by insurance
replace doctor_OOP = 0 if (UN152 == 1 & doctor_OOP == .)

* Add the people who never saw a doctor
replace doctor_OOP = 0 if (UN147 == 0 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if (inlist(UN152, 2, 3, 5, 7, 8, 9) | ///
	(UN147 != . & UN147 != 0)) & mi(doctor_OOP)

* Cap monthly expenditure at 5,000 dollars
replace doctor_OOP = cap5k if (doctor_OOP > cap5k & ~mi(doctor_OOP))

summ doctor_OOP, det

/****************************************************************
	SECTION 3.4: Hospice
****************************************************************/
gen hospice_OOP = UN328
replace hospice_OOP = . if (hospice_OOP == 9999998 | hospice_OOP == 9999999)

repute UN329 UN330 hospice_all hospice_OOP

* Replace DK/RF and partial insurance coverage with mean
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (inlist(UN324, 2, 3, 5, 7, 8, 9) | ///
(UN328 == 9999998 | UN328 == 9999999) | (UN331 == 98 | UN331 == 99) | ///
(UN320 == 1)) & mi(hospice_OOP)

* Assign zero cost to ppl whose costs were fully covered by insurance
replace hospice_OOP = 0 if UN324 == 1

* Assign zero cost to ppl who have not been a patient in a hospice
replace hospice_OOP = 0 if UN320 == 5

*Assign unconditional mean to ppl who DK if they were a patient in hospice
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (UN320 == 8 | UN320 == 9) & mi(hospice_OOP)

* Cap monthly expenditure at 5,000 dollars
replace hospice_OOP = cap5k if (hospice_OOP > cap5k & ~mi(hospice_OOP))

summ hospice_OOP, det

/****************************************************************
	SECTION 3.5: RX costs (annual)
	The HRS reports in months, so this will have to be converted 
****************************************************************/

gen RX_OOP = UN180
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

* replace the imputations with the mean value for that year
repute UN181 UN182 RX_all RX_OOP

* Replace the Dks with the mean; UN183 is the DK variable
quietly sum RX_OOP
replace RX_OOP = r(mean) if ((UN180 == 99998 | UN180 == 99999) | ///
(UN183 == 98 | UN183 == 99) | (UN175 == 1)) & mi(RX_OOP)

* Assign zero cost to people whose costs were completely covered by insurance
replace RX_OOP = 0 if UN176 == 1

* Assign zero cost to ppl who don't take drugs regularly
replace RX_OOP = 0 if UN175 == 5

* Assign unconditional mean to ppl who DK about taking drugs and ins part pay
quietly sum RX_OOP
replace RX_OOP = r(mean) if (inlist(UN176, 2, 3, 5, 7, 8, 9) | ///
	inlist(UN175, 8, 9)) & mi(RX_OOP)

*sets the cut off at $ 5,000
replace RX_OOP = 5000 if (RX_OOP > 5000 & RX_OOP != .)

*Scale payments to time between interviews
replace RX_OOP = (months * RX_OOP)

summ RX_OOP, det

/****************************************************************
	SECTION 3.6: In Home health care costs 
****************************************************************/
gen home_OOP = UN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

repute UN195 UN196 home_all home_OOP

* replace the Dks/RFs/NAs with the mean
qui sum home_OOP
replace home_OOP = r(mean) if ((UN194 == 999998 | UN194 == 999999) | ///
	(UN189 == 1) | (UN197 == 98 | UN197 == 99)) & mi(home_OOP)

*costs were fully covered by insurance
replace home_OOP = 0 if (UN190 == 1)

* Assign conditional mean to ppl who had their costs partly covered by insurance
qui sum home_OOP
replace home_OOP = r(mean) if inlist(UN190, 2, 3, 5, 7, 8, 9) & mi(home_OOP)

*people who didn't use any of the services
replace home_OOP = 0 if (UN189 == 5)

* Assign unconditional mean to ppl who DK if they had these expenses
qui sum home_OOP
replace home_OOP = r(mean) if (UN189 == 8 | UN189 == 9) & mi(home_OOP)

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
gen other_OOP = UN333
recode other_OOP (999998 999999 = .)

repute UN334 UN335 other_all other_OOP

*replace the Dks/RFs/NAs with the mean. The DK variable is UN336
qui sum other_OOP
replace other_OOP = r(mean) if ((UN332 == 1) | (UN333 == 99998 | ///
	UN333 == 99999) | (UN336 == 98 | UN336 == 99)) & mi(other_OOP)

*people who had no expenses of this type
replace other_OOP = 0 if UN332 == 5

*Assign unconditional mean to ppl who DK if they had this type of expense
qui sum other_OOP
replace other_OOP = r(mean) if (UN332 == 8 | UN332 == 9) & mi(other_OOP)

* Cap expenditure at 15k per month
replace other_OOP = cap15k if (other_OOP > cap15k & ~mi(other_OOP))

summ other_OOP, det

/****************************************************************
	SECTION 3.8: Non-medical expenditure 
****************************************************************/
gen non_med_OOP = UN338
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

* replace the imputations with the mean value for that year
repute UN339 UN340 nmed_all non_med_OOP

* this will replace the Dks/RFs/NAs with the mean. UN341 is the DK variable
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if ((UN337 == 1) | (UN338 == 999998 | ///
UN338 == 999999) | (UN341== 98 | UN341 == 99)) & mi(non_med_OOP)

* people who had none of these expenses
replace non_med_OOP = 0 if UN337 == 5

* Assign uncond mean to ppl who DK if had this type of expense
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if (UN337 == 8 | UN337 == 9) & mi(non_med_OOP)

*Cap exp at 5k per month
replace non_med_OOP = cap5k if (non_med_OOP > cap5k & ~mi(non_med_OOP))

summ non_med_OOP, det

/****************************************************************
	SECTION 3.9: Special services expenditures
****************************************************************/
gen spec_OOP = UN239
replace spec_OOP = . if (UN239 == 9999998 | UN239 == 9999999)

repute UN246 UN247 special_all spec_OOP

qui sum spec_OOP
replace spec_OOP = r(mean) if ((UN203 == 1) | (UN239 == 999998 | ///
	UN239 == 999999) | (UN248 == 98 | UN248 == 99)) & mi(spec_OOP)

*ppl who did not use services or did not have costs
replace spec_OOP = 0 if (UN202 == 5 | UN203 == 5)

qui sum spec_OOP
replace spec_OOP = r(mean) if ((UN202 == 8 | UN202 == 9) | ///
	(UN203 == 8 | UN203 == 9)) & mi(spec_OOP)

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

rename UA126M death_area
label values death_area death_region

#del ;
global OOP "insurance_costs hospital_OOP doctor_OOP hospice_OOP RX_OOP home_OOP 
other_OOP non_med_OOP helper_OOP total_OOP MC_HMO private_medigap 
spec_OOP NH_OOP long_term_care MC_B";
#del cr;

* add zero to missing costs
foreach y of global OOP {
	replace `y' = 0 if mi(`y') & ~mi(total_OOP)
}

drop if total_OOP == .
keep HHID PN *_OOP death_area insurance_costs death_month death_year time ///
	months weight06 MC_HMO long_term_care private_medigap MC_B

merge 1:1 HHID PN using "${rawdata}/${trversion}", keep(match) nogen

program drop repute
save "${OOPdata}/X2006OOP.dta", replace

log close 
