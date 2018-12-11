capture log close
log using "${logs}/2000exit.log",replace
/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			00exit.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Impute the 2000 exit medical expenditures


ORGANIZATION:	Section 1: Set Up
				SECTION 2: Insurance Costs
				Section 3: Medical Expenditures
				
INPUTS: 		2000exit.dta
				
OUTPUTS: 		2000exit.log X2000OOP.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Set Up
****************************************************************/
use "${buildoutput}/2000exit.dta", clear

do "${deps}/MMS2011_repute.do"  // source repute function
/****************************************************************
	SECTION 1.1: Make weights
****************************************************************/
gen weight00 = FWGTR  // previous wave weight b/e dead have zero weight

* adds in the early AHEAD people;
replace weight00 = DWGTR if weight00 == 0
replace weight00 = BWGTR if weight00 == 0

* ADDs in the early HRS people;
replace weight00 = EWGTR if weight00 == 0
replace weight00 = CWGTR if weight00 == 0
replace weight00 = AWGTR if (FWHY0WGT == 3 & CWHY0WGT == 3 & weight00 == 0)

/****************************************************************
	SECTION 1.2: Calculate months since previous interview
****************************************************************/
gen death_month = R520
replace death_month = . if (death_month == 98 | death_month == 99)
gen death_year = R522
replace death_year = . if (death_year == 9998 |death_year == 9999)

gen prev_interview_date = FIWYEAR + ((FIWMONTH - 1)/12)
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
gen cap15k = 12868 * months
gen cap30k = 25736 * months
gen cap5k  = 4289  * months

/****************************************************************
	SECTION 1.3: Make max expenditures into 2000 dollars
****************************************************************/
global all "mc_hmo_all ltc_all doctor_all hospice_all RX_all home_all other_all nmed_all hospital_NH_all"

foreach y of global all {
replace `y' = (`y' * (100.000/116.567))
}

/****************************************************************
	SECTION 1.4: Cap helper_OOP variable
****************************************************************/
* helper_OOP is in terms of 4 months, if the person lived for less than four 
* months since the previous interview, assign them N months * monthly cost
replace helper_OOP = min(helper_OOP, months*helper_OOP/4)

*cap at 15k per month in the same way, using the 4 month convsion cond on survival
replace helper_OOP = cap15k if (helper_OOP > cap15k & helper_OOP != .)
replace helper_OOP = 12868*4 if (helper_OOP > 12868*4 & helper_OOP != .)
sum helper_OOP, det

/****************************************************************
	SECTION 2: Insurance Costs
****************************************************************/

/****************************************************************
	SECTION 2.1: Medicare/Medicaid through an HMO (MC_HMO) 
****************************************************************/
gen MC_HMO = R2605
replace MC_HMO = . if (MC_HMO == 9998 | MC_HMO == 9999)

* Make the premium in terms of one month
replace MC_HMO = 1 * MC_HMO if R2606 == 1
replace MC_HMO = (1/3) * MC_HMO if R2606 == 2
replace MC_HMO = (1/6) * MC_HMO if R2606 == 3
replace MC_HMO = (1/12) * MC_HMO if R2606 == 4

* Assign mean to ppl who DK about the cost of coverage
qui sum MC_HMO
replace MC_HMO = r(mean) if (inlist(R2605, 9998, 9999) | (R2601 == 1)) & mi(MC_HMO)

* people who did not have an HMO medicare/medicaid plan or did not recieve benefits
replace MC_HMO = 0 if (R2601 == 5)

* Assign this mean to ppl who DK if they coverage through an HMO
qui sum MC_HMO
replace MC_HMO = r(mean) if  (R2601 == 8 | R2601 == 9) & mi(MC_HMO)

summ MC_HMO, det

/****************************************************************
	SECTION 2.2: Medicare Part B 
****************************************************************/
gen MC_B = (45.6) if (R2587 == 1 & R2589 != 1 & R2598 != 1)

/****************************************************************
	SECTION 2.3: Private Insurance
****************************************************************/
gen ins_1 = R2620  // Insurance through a job
recode ins_1 (9998 9999 = .)

* Make the premium in terms of one month
replace ins_1 = (1/12) * ins_1 if (R2621 == 1)
replace ins_1 = (1/3) * ins_1 if (R2621 == 2)
replace ins_1 = (1/2) * ins_1 if (R2621 == 3)
replace ins_1 = 1 * ins_1 if (R2621 == 4)
replace ins_1 = 4 * ins_1 if (R2621 == 5)
replace ins_1 = (1/6) * ins_1 if (R2621 == 7)

* mean conditional on having coverage
qui sum ins_1
replace ins_1 = r(mean) if (R2620 == 9998 | R2620 == 9999) & mi(ins_1)

replace ins_1 = 0 if (R2613 == 5 | R2619 == 3)

* unconditional mean
qui sum ins_1
replace ins_1 = r(mean) if (R2619 == 8 | R2613 == 8 | R2613 == 9) & mi(ins_1)

/* *********************************************************************** */
gen ins_2 = R2636  // other insurance
recode ins_2 (999998 999999 = .)

* Make the premium in terms of one month
replace ins_2 = ((1/12) * ins_2) if (R2637 == 1)
replace ins_2 = ((1/3)* ins_2) if (R2637 == 2)
replace ins_2 = ((1/2)* ins_2) if (R2637 == 3)
replace ins_2 = (1 * ins_2) if (R2637 == 4)
replace ins_2 = (4 * ins_2) if (R2637 == 5)
replace ins_2 = (2 * ins_2) if (R2637 == 6)
replace ins_2 = ((1/6)* ins_2) if (R2637 == 7)
replace ins_2 = (2 * ins_2) if (R2637 == 8)

* mean conditional on having coverage
qui sum ins_2
replace ins_2 = r(mean) if (R2620 == 999998 | R2620 == 999999) & mi(ins_2)
* ^ definitely a coding error. Should be R2636...

replace ins_2 = 0 if (R2633 == 5 | R2635 == 3)

* unconditional mean
qui sum ins_2
replace ins_2 = r(mean) if (R2635 == 8 | R2633 == 8 | R2633 == 9) & mi(ins_2)

/* *********************************************************************** */
gen ins_3 = R2648  // if the respondent has any other insurance
recode ins_3 (999998 999999 = .)

* Make the premium in terms of one month
replace ins_3 = ((1/12) * ins_3) if (R2649 == 1)
replace ins_3 = ((1/3) * ins_3) if (R2649 == 2)
replace ins_3 = ((1/2) * ins_3) if (R2649 == 3)
replace ins_3 = (1 * ins_3) if (R2649 == 4)
replace ins_3 = (4 * ins_3) if (R2649 == 5)
replace ins_3 = (2 * ins_3) if (R2649 == 6)
replace ins_3 = ((1/6) * ins_3) if (R2649 == 7)
replace ins_3 = (2 * ins_3) if (R2649 == 8)

* mean conditional on having coverage
qui sum ins_3
replace ins_3 = r(mean) if (R2648 == 999998) & mi(ins_3)

replace ins_3 = 0 if (R2645 == 5)

* unconditional mean
qui sum ins_3
replace ins_3 = r(mean) if (R2645 == 8) & mi(ins_3)

/* *********************************************************************** */
/* Private medigap variable for comparisons with other waves. These ins 
	varss are similar, but not identical, to those in the private medigap 
	section of the 2002 onwards waves. */
egen private_medigap = rowtotal(ins_1 ins_2 ins_3), m

/****************************************************************
	SECTION 2.4: Long-term-care
****************************************************************/ 
gen long_term_care = R2704 
recode long_term_care (999998 999999 = . )

* Make the premium in terms of one month
replace long_term_care = (1/12) * long_term_care if (R2705 == 1)
replace long_term_care = (1/3) * long_term_care if (R2705 == 2)
replace long_term_care = 4 * long_term_care if (R2705 == 3)
replace long_term_care = (1) * long_term_care if (R2705 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (R2705 == 6)

*this will replace the Dks/RFs/NAs with the mean
qui sum long_term_care
#del ;
replace long_term_care = r(mean) if 
(((R2704 == 999998 | R2704 == 999999) | (R2700 == 1))  & mi(long_term_care));
#del cr;

* this puts in the people who did not have LTC
replace long_term_care = 0 if R2700 == 5

/* this will add in the yes answers that had no value in the above
 two question and the DKs/RFs from those questions */
qui sum long_term_care
replace long_term_care = r(mean) if (R2700 == 8 | R2700 == 9)  & mi(long_term_care)

summ long_term_care, det

/* *********************************************************************** */
* Create summed insurance costs var
egen insurance_costs = rowtotal(MC_HMO long_term_care ins_1 ins_2 ins_3 MC_B), m

* this will set the monthly max at 2000 dollars
replace insurance_costs = 1716 if (insurance_costs > 1716 & insurance_costs != .)

* this will make insurance costs for the time period between interviews
replace insurance_costs = (months * insurance_costs)

summ insurance_costs, det

/****************************************************************
	SECTION 3: Medical Expenditures
****************************************************************/

/****************************************************************
	SECTION 3.1: Hospital
****************************************************************/
gen hospital_OOP = R1760
recode hospital_OOP (9999998 9999999 = .)

do "${deps}/x00hospital.do"  // create bounds
repute hospital_low hospital_high hospital_NH_all hospital_OOP

*Assign conditional mean to ppl who DK the bounds of their exp
qui sum hospital_OOP
#del ;
replace hospital_OOP = r(mean) if (((R1760 == 9999998| R1760 == 9999999) | 
(R1761 == 8 | R1761 == 9) | (R1762 == 8 | R1762 == 9) | (R1763 == 8 | R1763 == 9) | 
(R1764 == 8 | R1764 == 9) | (R1765 == 8 | R1765 == 9) | (R1766 == 8 | R1766 == 9) | 
(R1767 == 8 | R1767 == 9) | (R1746 == 3 | R1746 == 5) | (R1759 == 3 | R1759 == 5)) & 
(hospital_OOP == .));
#del cr;

*hospital/Nursing Home costs were fully covered
replace hospital_OOP = 0 if ((R1759 == 1 | R1746 == 1) & (hospital_OOP == .))

/* there are two of these. The First way will assign only half of the
costs because it will be respondents who report only had one cost or the other.
 The second way will assign the average because it is for people with both costs. */
qui sum hospital_OOP

#del ;
*people with both expenses;
replace hospital_OOP = r(mean) if (inlist(R1746, 7, 8, 9) & 
	inlist(R1759, 7, 8, 9) & (hospital_OOP == . | hospital_OOP == 0));

*people with only hospital costs and no reported value;
replace hospital_OOP = r(mean)/2 if 
((R1759 == 3 | R1759 == 5 | R1759 == 7 | R1746 == 8 | R1746 == 9) &
(R1759 != 3 | R1759 != 5 | R1759 != 7 | R1759 != 8 | R1759 != 9)& (hospital_OOP == . | hospital_OOP == 0));

*people with only nursing home costs and no reported value;
replace hospital_OOP = r(mean)/2 if 
((R1746 != 3 | R1746 != 5 | R1746 != 7 | R1746 != 8 | R1746 != 9) &
inlist(R1759, 3, 5, 7, 8, 9) & (hospital_OOP == . | hospital_OOP == 0));
#del cr;

* Cap monthly expenditure at 30,000 dollars
replace hospital_OOP = cap30k if (hospital_OOP > cap30k & ~mi(hospital_OOP))

summ hospital_OOP, det

/****************************************************************
	SECTION 3.3: Doctor Visits
****************************************************************/
gen doctor_OOP = R1800
recode doctor_OOP (99998 99999 = .)

do "${deps}/x00dr.do"  // create bounds
repute dr_low dr_high doctor_all doctor_OOP

* this will replace the Dks/RFs/NAs with the mean
quietly sum doctor_OOP
#del ;
replace doctor_OOP = r(mean) if ((R1800 == 99998 | R1800 == 99999) | 
(R1801 == 8 | R1801 == 9) | (R1802 == 8 | R1802 == 9) | (R1803 == 8 | R1803 == 9) | 
(R1804 == 8 | R1804 == 9) | (R1805 == 8 | R1805 == 9) | (R1806 == 8 | R1806 == 9) | 
(R1795 == 3 | R1795 == 5)) & mi(doctor_OOP);
#del cr;

* people whose costs were fully covered by insurance
replace doctor_OOP = 0 if (R1795 == 1 & doctor_OOP == .)

* Assign mean to people who visited the doctor but may have had no expenses
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if inlist(R1795, 7, 8) & mi(doctor_OOP)

* Cap monthly expenditure at 5,000 dollars
replace doctor_OOP = cap5k if (doctor_OOP > cap5k & ~mi(doctor_OOP))

summ doctor_OOP, det

/****************************************************************
	SECTION 3.4: Hospice
****************************************************************/
gen hospice_OOP = R1781
replace hospice_OOP = . if hospice_OOP == 99998

do "${deps}/x00hospice.do"
repute hospice_low hospice_high hospice_all hospice_OOP

* Replace the Dks/RFs/NAs with the mean
qui sum hospice_OOP
replace hospice_OOP = r(mean) if ((R1781 == 99998) | (R1783 == 8) | ///
	(R1780 == 3 | R1780 == 5)) & (hospice_OOP == .)

* hospice costs were fully covered by insurance
replace hospice_OOP = 0 if (R1780 == 1 & hospice_OOP == .)

/* this will add in the yes answers that had no value in the above
 two question and the DKs/RFs from those questions */
qui sum hospice_OOP
replace hospice_OOP = r(mean) if (R1780 == 7 | R1780 == 8) & mi(hospice_OOP)

* Cap monthly expenditure at 5,000 dollars
replace hospice_OOP = cap5k if (hospice_OOP > cap5k & ~mi(hospice_OOP))

summ hospice_OOP, det

/****************************************************************
	SECTION 3.5: RX costs (annual)
	The HRS reports in months, so this will have to be converted 
****************************************************************/

gen RX_OOP = R1810
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

do "${deps}/x00rx.do"
repute rx_low rx_high RX_all RX_OOP
  
*Assign conditional mean to DK for UB or LB
quietly sum RX_OOP
#del ;
replace RX_OOP = r(mean) if ((R1810 == 99998 | R1810 == 99999) | 
(R1811 == 8 | R1811 == 9) | (R1812 == 8 | R1812 == 9) | 
(R1813 == 8 | R1813 == 9) | (R1814 == 8 | R1814 == 9) | 
(R1815 == 8 | R1815 == 9) | (R1816 == 8 | R1816 == 9) | 
(R1817 == 8 | R1817 == 9) | (R1808 == 1 & (R1809 == 3 | R1809 == 5))) & mi(RX_OOP);
#del cr;

* Assign zero cost to ppl who don't take drugs regularly
replace RX_OOP = 0 if (R1808 == 5 & RX_OOP == .)

*costs were completely covered by insurance
replace RX_OOP = 0 if (R1809 == 1 & RX_OOP == .)

*Assign unconditional mean to ppl with partial insurance coverage or DK
quietly sum RX_OOP
replace RX_OOP = r(mean) if (inlist(R1809, 3, 5, 7, 8) | ///
	inlist(R1808, 1, 7, 8)) & mi(RX_OOP)

*sets the cut off at $ 5,000
replace RX_OOP = 4289 if ((RX_OOP > 4289) & RX_OOP != .)

*Scale payments to time between interviews
replace RX_OOP = (months * RX_OOP)

summ RX_OOP, det

/****************************************************************
	SECTION 3.6: In Home health care costs 
****************************************************************/
gen home_OOP = R1827
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

do "${deps}/x00home.do"
repute home_low home_high home_all home_OOP

qui sum home_OOP
#del ;
replace home_OOP = r(mean) if (((R1827 == 999998 | R1827 == 999999) | 
(R1828 == 8 | R1828 == 9) | (R1831 == 8) | (R1832 == 8) | 
(R1820 == 1 & (R1822 == 1 | R1822 == 6)) | (R1824 == 1 & (R1822 == 1 | R1822 == 6)))  & 
(home_OOP == .));
#del cr;

*costs were fully covered by insurance or were provided for free for some reason
replace home_OOP = 0 if ((R1822 == 1 | R1822 == 6) & home_OOP == .)

*people who didn't use any of the services
replace home_OOP = 0 if ((R1824 == 5 & R1820 == 5) & home_OOP == .)

* Assign conditional mean to ppl who had their costs partly covered by insurance
qui sum home_OOP
replace home_OOP = r(mean) if inlist(R1822, 3, 5, 7, 8) & mi(home_OOP)

* people who had one cost or the other
replace home_OOP = r(mean)/2 if (inlist(R1820, 1, 8, 9) & R1824 == 5) & ///
	(home_OOP == . | home_OOP == 0)

replace home_OOP = r(mean)/2 if (inlist(R1824, 1, 8, 9) & R1820 == 5) & ///
	(home_OOP == . | home_OOP == 0)

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
gen other_OOP = R1835
replace other_OOP = . if (other_OOP == 999998)

do "${deps}/x00other.do"
repute other_low other_high other_all other_OOP

* replace the Dks/RFs/NAs with the mean
qui sum other_OOP
replace other_OOP = r(mean) if ((R1835 == 999998) | (R1836 == 8) | ///
	(R1837 == 8) | (R1839 == 8) | (R1840 == 8) | (R1834 == 1)) & mi(other_OOP)

* people who had no expenses of this type
replace other_OOP = 0 if (R1834 == 5 & other_OOP == .)

*Assign uncond mean to ppl who DK if had pos exp
qui sum other_OOP
replace other_OOP = r(mean) if (R1834 == 8) & mi(other_OOP)

* Cap expenditure at 15k per month
replace other_OOP = cap15k if (other_OOP > cap15k & ~mi(other_OOP))

summ other_OOP, det

/****************************************************************
	SECTION 3.8: Non-medical expenditure 
****************************************************************/
gen non_med_OOP = R1864
replace non_med_OOP = . if non_med_OOP == 999998

do "${deps}/x00nmed.do"
repute non_med_low non_med_high nmed_all non_med_OOP

* replace the Dks/RFs/NAs with the mean
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if ((R1864 == 999998) | ///
(R1865 == 8) | (R1868 == 8) | (R1869 == 8) | (R1863 == 1)) & mi(non_med_OOP)

*people who had none of these expenses
replace non_med_OOP = 0 if (R1863 == 5 & non_med_OOP == .)

*Assign uncond mean to ppl who DK if had pos exp
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if inlist(R1863, 8, 9) & mi(non_med_OOP)

*Cap exp at 5k per month
replace non_med_OOP = cap5k if (non_med_OOP > cap5k & ~mi(non_med_OOP))

summ non_med_OOP, det

/****************************************************************
	SECTION 4: Total OOP expenditure
****************************************************************/

egen total_OOP = rowtotal(insurance_costs hospital_OOP doctor_OOP ///
	hospice_OOP RX_OOP home_OOP other_OOP non_med_OOP helper_OOP), m

summ total_OOP, det

/****************************************************************
	SECTION 5: Clean Up
****************************************************************/
rename R526M death_area
label values death_area death_region

#del ;
global OOP "insurance_costs hospital_OOP doctor_OOP 
hospice_OOP RX_OOP home_OOP other_OOP non_med_OOP 
helper_OOP MC_HMO ins_1 ins_2 ins_3 long_term_care MC_B total_OOP";
#del cr;

* make expenses in 2006 dollars
foreach y of global OOP {
	replace `y' = 0 if mi(`y') & ~mi(total_OOP)
	replace `y' = (`y' * (116.567/100.000))
}

keep HHID PN *_OOP death_area insurance_costs death_month death_year time ///
	months weight00 MC_HMO ins_1 ins_2 ins_3 MC_B long_term_care
drop if total_OOP == .
merge 1:1 HHID PN using "${rawdata}/${trversion}", keep(match) nogen
program drop repute
save "${OOPdata}/X2000OOP.dta", replace
log close 
