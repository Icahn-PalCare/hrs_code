capture log close
log using "${logs}/2002exit.log",replace
/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			02exit.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Impute the 2002 exit medical expenditures


ORGANIZATION:	Section 1: Set Up
				SECTION 2: Insurance Costs
				Section 3: Medical Expenditures
				
INPUTS: 		2002exit.dta
				
OUTPUTS: 		2002exit.log X2002OOP.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Set Up
****************************************************************/
use "${buildoutput}/2002exit.dta", clear

do "${deps}/MMS2011_repute.do"  // source repute function
/****************************************************************
	SECTION 1.1: Make weights
****************************************************************/
gen weight02 = GWGTR  // previous wave weight b/e dead have zero weight

replace weight02 = FWGTR if weight02 == 0

* adds in the early AHEAD people;
replace weight02 = DWGTR if weight02 == 0
replace weight02 = BWGTR if (GWHY0WGT == 3 & DWHY0WGT == 3 & weight02 == 0)

* ADDs in the early HRS people;
replace weight02 = EWGTR if weight02 == 0
replace weight02 = CWGTR if (GWHY0WGT == 3 & EWHY0WGT == 3 & weight02 == 0)
replace weight02 = AWGTR if (GWHY0WGT == 3 & CWHY0WGT == 3 & weight02 == 0)

/****************************************************************
	SECTION 1.2: Calculate months since previous interview
****************************************************************/
gen death_month = SA121
replace death_month = . if (death_month == 98 | death_month == 99)
gen death_year = SA123
replace death_year = . if (death_year == 9998 |death_year == 9999)

gen prev_interview_date = GIWYEAR + ((GIWMONTH - 1)/12)
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
gen cap15k = 13407 * months
gen cap5k  = 4469 * months

/****************************************************************
	SECTION 1.3: Make max expenditures into 2002 dollars
****************************************************************/
#del ;
global all "mc_hmo_all private_medigap_all ltc_all hospital_all nursing_home_all 
	doctor_all hospice_all RX_all home_all other_all nmed_all special_all";
#del cr;

foreach y of global all {
replace `y' = (`y' * (104.187/116.567))
}

/* *********************************************************************** */
* exclude two people in this exit year who died in 1998
drop if (HHID + PN == "011863010" | HHID + PN == "203802010")

/****************************************************************
	SECTION 1.4: Cap helper_OOP variable
****************************************************************/
* helper_OOP is in terms of 4 months, if the person lived for less than four 
* months since the previous interview, assign them N months * monthly cost
replace helper_OOP = min(helper_OOP, months*helper_OOP/4)

*cap at 15k per month in the same way, using the 4 month convsion cond on survival
replace helper_OOP = cap15k if (helper_OOP > cap15k & helper_OOP != .)
replace helper_OOP = 13407*4 if (helper_OOP > 13407*4 & helper_OOP != .)
sum helper_OOP, det

/****************************************************************
	SECTION 2: Insurance Costs
****************************************************************/

/****************************************************************
	SECTION 2.1: Medicare/Medicaid through an HMO (MC_HMO) 
****************************************************************/
gen MC_HMO = SN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

* Make the premium in terms of one month
replace MC_HMO = 1 * MC_HMO if SN018 == 1
replace MC_HMO = (1/3) * MC_HMO if SN018 == 2
replace MC_HMO = (1/6) * MC_HMO if SN018 == 3
replace MC_HMO = (1/12) * MC_HMO if SN018 == 4

repute SN015 SN016 mc_hmo_all MC_HMO

* Assign mean to ppl who DK about the cost of coverage
qui sum MC_HMO
replace MC_HMO = r(mean) if (inlist(SN014, 998, 999) | ///
	inlist(SN017, 98, 99) | inlist(SN018, 8, 9) | (SN009 == 1)) & mi(MC_HMO)

* people who did not have an HMO medicare/medicaid plan or did not recieve benefits
replace MC_HMO = 0 if ((SN009 == 5) & (MC_HMO == .))

* Assign this mean to ppl who DK if they coverage through an HMO
qui sum MC_HMO
replace MC_HMO = r(mean) if (SN009 == 8 | SN009 == 9) & mi(MC_HMO)

summ MC_HMO, det

/****************************************************************
	SECTION 2.2: Medicare Part B 
****************************************************************/
gen MC_B = (54) if (SN004 == 1 & SN005 != 1 & SN007 != 1)
/****************************************************************
	SECTION 2.3: Private Insurance
****************************************************************/ 
gen private_medigap_1 = SN040_1
recode private_medigap_1 (998 999 = .)

repute SN041_1 SN042_1 private_medigap_all private_medigap_1

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_1
replace private_medigap_1 = r(mean) if ((SN040_1 == 998 | SN040_1 == 999) | ///
	(SN043_1 == 98 | SN043_1 == 99)) & mi(private_medigap_1)

* people who paid nothing for their private health coverage
replace private_medigap_1 = 0 if (SN039_1 == 3 & private_medigap_1  == .)

/* *********************************************************************** */
gen private_medigap_2 = SN040_2
recode private_medigap_2 (998 999 = .)

repute SN041_2 SN042_2 private_medigap_all private_medigap_2

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_2
replace private_medigap_2 = r(mean) if ((SN040_2 == 998 | SN040_2 == 999) | ///
	(SN043_2 == 98 | SN043_2 == 99)) & mi(private_medigap_2)

*people who paid nothing for their private health coverage
replace private_medigap_2 = 0 if (SN039_2 == 3 & private_medigap_2  == .)

/* *********************************************************************** */
gen private_medigap_3 = SN040_3
recode private_medigap_3 (998 999 = .)

repute SN041_3 SN042_3 private_medigap_all private_medigap_3

* Assign mean to ppl who DK about the cost of coverage
qui sum private_medigap_3
replace private_medigap_3 = r(mean) if ((SN040_3 == 998 | SN040_3 == 999) | ///
	(SN043_3 == 98 | SN043_3 == 99)) & mi(private_medigap_3)

* people who paid nothing for their private health coverage
replace private_medigap_3 = 0 if (SN039_3 == 3 & private_medigap_3  == .)

/* *********************************************************************** */
*sum all three insurance plans

egen private_medigap = rowtotal(private_medigap_1 private_medigap_2 private_medigap_3), m

*Assign conditional mean to people with atleast 1 private medigap coverage
qui sum private_medigap
replace private_medigap = r(mean) if (SN023 > 0 & SN023 != .) & mi(private_medigap)

*people with no medigap plans
replace private_medigap = 0 if (SN023 == 0 & private_medigap == .)

*Assign unconditional mean to those who were responsible for atleast part of the coverage
qui sum private_medigap
replace private_medigap = r(mean) if (inlist(SN039_1, 1, 2, 8, 9) | ///
	inlist(SN039_2, 1, 2, 8, 9) | inlist(SN039_3, 1, 2, 8, 9)) & mi(private_medigap)

summ private_medigap, det

/****************************************************************
	SECTION 2.4: Long-term-care
****************************************************************/ 
gen long_term_care = SN079
recode long_term_care (99998 99999 = . )

* Make the premium in terms of one month
replace long_term_care = 1 * long_term_care if (SN083 == 1)
replace long_term_care = (1/3) * long_term_care if (SN083 == 2)
replace long_term_care = 4 * long_term_care if (SN083 == 3)
replace long_term_care = (1/12) * long_term_care if (SN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (SN083 == 6)

repute SN080 SN081 ltc_all long_term_care

* Assign mean to ppl who DK about the cost of coverage
qui sum long_term_care
replace long_term_care = r(mean) if ((SN079 == 99998 | SN079 == 99999) | ///
inlist(SN083, 7, 8, 9) | inlist(SN082, 98, 99) | (SN071 == 1)) & mi(long_term_care)

* Asssign zero cost to ppl w/out LTC at the time of death
replace long_term_care = 0 if (SN071 == 5 & long_term_care == . )

*Assign unconditional mean to ppl who DK if they had LTC insurance
qui sum long_term_care
replace long_term_care = r(mean) if (SN071 == 8 | SN071 == 9) & mi(long_term_care)

summ long_term_care, det

/* *********************************************************************** */
* sum all insurance costs
egen insurance_costs = rowtotal(MC_HMO long_term_care private_medigap MC_B), m

* cap exp at 2000 dollars
replace insurance_costs = 1788 if (insurance_costs > 1788 & insurance_costs != .)

* adjust insurance costs to be total exp since previous irw
replace insurance_costs = (months * insurance_costs)

summ insurance_costs, det

/****************************************************************
	SECTION 3: Medical Expenditures
****************************************************************/

/****************************************************************
	SECTION 3.1: Hospital
****************************************************************/
gen hospital_OOP = SN106
recode hospital_OOP (999998 999999 = .)

repute SN107 SN108 hospital_all hospital_OOP  //Assign means to first 100 bounds

* Assign mean to ppl who DK their hospital expenses 
qui sum hospital_OOP
#del ;
replace hospital_OOP = r(mean) if ((SN106 == 999998| SN106 == 999999) |  
(SN109 == 98 | SN109 == 99) | (SN099 == 1)) & mi(hospital_OOP);
#del cr;

*people whose hospital costs were fully covered
replace hospital_OOP = 0 if SN102 == 1

*people who were in the hospital but may have had no expenses.
qui sum hospital_OOP
replace hospital_OOP = r(mean) if (inlist(SN102, 2, 3, 5, 7, 8, 9) | ///
	(SN099 == 1))& mi(hospital_OOP)

replace hospital_OOP = 0 if SN099 == 5  //never stayed in the hospital

/* this will add in the yes answers that had no value in the above
 two question and the DKs/RFs from those questions */
qui sum hospital_OOP
replace hospital_OOP = r(mean) if inlist(SN099, 8, 9) & mi(hospital_OOP)

* Cap expenditure at 15k per month
replace hospital_OOP = cap15k if (hospital_OOP > cap15k & ~mi(hospital_OOP))

* output the data that I want
summ hospital_OOP, det

/****************************************************************
	SECTION 3.2: Nursing Home
****************************************************************/
gen NH_OOP = SN119
recode NH_OOP (999998 999999 = .)

* Assign means to first 100 bounds
repute SN120 SN121 nursing_home_all NH_OOP

* Replace the Dks with the mean; the DK variable is SN122
quietly sum NH_OOP
replace NH_OOP = r(mean) if ((SN119 == 999998 | SN119 == 999999) | ///
	inlist(SN122, 98, 99)) & mi(NH_OOP)

* Add people whose costs were completely covered by insurance
replace NH_OOP = 0 if (SN118 == 1 & NH_OOP == .)

* Add in the people who were in a NH but may have had no expenses.
quietly sum NH_OOP
replace NH_OOP = r(mean) if (inlist(SN118, 2, 3, 5, 7, 8, 9) | ///
	(SN114 == 1)) & mi(NH_OOP)

* Add in the people who never stayed overnight in a NH
*put SN001 in as a proxy for having a full interview for this section.
replace NH_OOP = 0 if (SN115 == . & SN001 != . & NH_OOP == .)

* Assign unconditional mean to DK/RF for num nights in NH
quietly sum NH_OOP
replace NH_OOP = r(mean) if inlist(SN115, 98, 99) & mi(NH_OOP) 

* Cap expenditure at 15k per month
replace NH_OOP = cap15k if (NH_OOP > cap15k & ~mi(NH_OOP))

summ NH_OOP, det

/****************************************************************
	SECTION 3.3: Doctor Visits
****************************************************************/
gen doctor_OOP = SN156
recode doctor_OOP (999998 999999 = .)

* Assign means to first 100 bounds
repute SN157 SN158 doctor_all doctor_OOP

* Replace the Dks with the mean; The DK variable is SN159
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if ((SN156 == 999998 | SN156 == 999999) | ///
(SN159 == 98 | SN159 == 99)) & mi(doctor_OOP)

* Add people whose costs were completely covered by insurance
replace doctor_OOP = 0 if (SN152 == 1 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if (SN147 != . & SN147 != 0) & mi(doctor_OOP)

* Add the people who never saw a doctor
replace doctor_OOP = 0 if (SN147 == 0 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if inlist(SN152, 2, 3, 5, 7, 8, 9) & mi(doctor_OOP)

* Cap monthly expenditure at 5,000 dollars
replace doctor_OOP = cap5k if (doctor_OOP > cap5k & ~mi(doctor_OOP))

summ doctor_OOP, det

/****************************************************************
	SECTION 3.4: Hospice
****************************************************************/
gen hospice_OOP = SN328
replace hospice_OOP = . if (hospice_OOP == 9998 | hospice_OOP == 9999)

repute SN329 SN330 hospice_all hospice_OOP

* Replace DK/RF and partial insurance coverage with mean
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (inlist(SN324, 2, 3, 5, 7, 8, 9) | ///
	(SN328 == 9999998 | SN328 == 9999999) | (SN331 == 98 | SN331 == 99) | ///
	(SN320 == 1)) & mi(hospice_OOP)

* Assign zero cost to ppl whose costs were fully covered by insurance
replace hospice_OOP = 0 if SN324 == 1

* Assign zero cost to ppl who have not been a patient in a hospice
replace hospice_OOP = 0 if SN320 == 5

*Assign unconditional mean to ppl who DK if they were a patient in hospice
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (SN320 == 8 | SN320 == 9) & mi(hospice_OOP)

* Cap monthly expenditure at 5,000 dollars
replace hospice_OOP = cap5k if (hospice_OOP > cap5k & ~mi(hospice_OOP))

summ hospice_OOP, det

/****************************************************************
	SECTION 3.5: RX costs (annual)
	The HRS reports in months, so this will have to be converted 
****************************************************************/

gen RX_OOP = SN180
replace RX_OOP = . if (RX_OOP == 9998 | RX_OOP == 9999)

* replace the imputations with the mean value for that year
repute SN181 SN182 RX_all RX_OOP
  
* Replace the Dks with the mean; SN183 is the DK variable
quietly sum RX_OOP
replace RX_OOP = r(mean) if ((SN180 == 99998 | SN180 == 99999) | ///
(SN183 == 98 | SN183 == 99) | (SN175 == 1)) & mi(RX_OOP)

* Add people whose costs were completely covered by insurance
replace RX_OOP = 0 if SN176 == 1

* Assign unconditional mean to ppl who DK about taking drugs and ins part pay
quietly sum RX_OOP
replace RX_OOP = r(mean) if inlist(SN176, 2, 3, 5, 7, 8, 9) & mi(RX_OOP)

* Assign zero cost to ppl who don't take drugs regularly
replace RX_OOP = 0 if SN175 == 5

* Assign unconditional mean to ppl who DK about taking drugs
quietly sum RX_OOP
replace RX_OOP = r(mean) if inlist(SN175, 8, 9) & mi(RX_OOP)

*sets the cut off at $ 5,000
replace RX_OOP = 4469 if (RX_OOP > 4469 & RX_OOP != .)

*Scale payments to time between interviews
replace RX_OOP = (months * RX_OOP)

summ RX_OOP, det

/****************************************************************
	SECTION 3.6: In Home health care costs 
****************************************************************/
gen home_OOP = SN194
replace home_OOP = . if (home_OOP == 99998 | home_OOP == 99999)

repute SN195 SN196 home_all home_OOP

* this will replace the Dks/RFs/NAs with the mean
qui sum home_OOP
replace home_OOP = r(mean) if ((SN194 == 999998 | SN194 == 999999) | ///
	(SN189 == 1) | (SN197 == 98 | SN197 == 99)) & mi(home_OOP)

*ppl whose costs were fully covered by insurance, or were provided for free for some reason
replace home_OOP = 0 if (SN190 == 1 | SN190 == 6)

* Assign conditional mean to ppl who had their costs partly covered by insurance
qui sum home_OOP
replace home_OOP = r(mean) if inlist(SN190, 2, 3, 5, 7, 8, 9) & mi(home_OOP)

*people who didn't use any of the services
replace home_OOP = 0 if (SN189 == 5)

* Assign unconditional mean to ppl who DK if they had these expenses
qui sum home_OOP
replace home_OOP = r(mean) if (SN189 == 8 | SN189 == 9) & mi(home_OOP)

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
gen other_OOP = SN333
recode other_OOP (99998 99999 = .)

repute SN334 SN335 other_all other_OOP

*replace the Dks/RFs/NAs with the mean. The DK variable is SN336
qui sum other_OOP
replace other_OOP = r(mean) if ((SN332 == 1) | (SN333 == 99998 | ///
	SN333 == 99999) | (SN336 == 98 | SN336 == 99)) & mi(other_OOP)

*people who had no expenses of this type
replace other_OOP = 0 if SN332 == 5

*Assign unconditional mean to ppl who DK if they had this type of expense
qui sum other_OOP
replace other_OOP = r(mean) if (SN332 == 8 | SN332 == 9) & mi(other_OOP)

* Cap expenditure at 15k per month
replace other_OOP = cap15k if (other_OOP > cap15k & ~mi(other_OOP))

summ other_OOP, det

/****************************************************************
	SECTION 3.8: Non-medical expenditure 
****************************************************************/
gen non_med_OOP = SN338
replace non_med_OOP = . if (non_med_OOP == 99998 | non_med_OOP == 99999)

* replace the imputations with the mean value for that year
repute SN339 SN340 nmed_all non_med_OOP

* replace the Dks/RFs/NAs with the mean. SN341 is the DK variable
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if ((SN337 == 1) | (SN338 == 999998 | ///
SN338 == 999999) | (SN341== 98 | SN341 == 99)) & mi(non_med_OOP)

* people who had none of these expenses
replace non_med_OOP = 0 if SN337 == 5

* Assign uncond mean to ppl who DK if had this type of expense
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if (SN337 == 8 | SN337 == 9) & mi(non_med_OOP)

*Cap exp at 5k per month
replace non_med_OOP = cap5k if (non_med_OOP > cap5k & ~mi(non_med_OOP))

summ non_med_OOP, det

/****************************************************************
	SECTION 3.9: Special services expenditures
****************************************************************/
gen spec_OOP = SN239
replace spec_OOP = . if (SN239 == 9998 | SN239 == 9999)

repute SN246 SN247 special_all spec_OOP

qui sum spec_OOP
replace spec_OOP = r(mean) if ((SN203 == 1) | (SN239 == 999998 | ///
SN239 == 999999) | (SN248 == 98 | SN248 == 99)) & mi(spec_OOP)

*ppl who did not use services or did not have costs
replace spec_OOP = 0 if (SN202 == 5 | SN203 == 5)

qui sum spec_OOP
replace spec_OOP = r(mean) if ((SN202 == 8 | SN202 == 9) | ///
(SN203 == 8 | SN203 == 9)) & mi(spec_OOP)

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
rename SA126M death_area
label values death_area death_region

#del ;
global OOP "insurance_costs hospital_OOP doctor_OOP hospice_OOP RX_OOP home_OOP 
other_OOP non_med_OOP helper_OOP total_OOP MC_HMO private_medigap 
spec_OOP NH_OOP long_term_care MC_B";
#del cr;

* make expenses in 2006 dollars
foreach y of global OOP {
	replace `y' = 0 if mi(`y') & ~mi(total_OOP)
	replace `y' = (`y' * (116.567/104.187))
}

keep *_OOP death_area HHID PN insurance_costs death_month death_year time ///
months weight02 MC_HMO long_term_care private_medigap MC_B
drop if total_OOP == .
merge 1:1 HHID PN using "${rawdata}/${trversion}", keep(match) nogen

program drop repute
save "${OOPdata}/X2002OOP.dta", replace

log close 


