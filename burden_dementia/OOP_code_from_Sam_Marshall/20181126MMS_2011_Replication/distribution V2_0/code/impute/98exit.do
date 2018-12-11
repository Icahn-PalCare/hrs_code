capture log close
log using "${logs}/1998exit.log",replace
/*****************************************************************
PROJECT: 		MMS OOP Spending Replication Files
				
TITLE:			98exit.do
			
AUTHOR: 		Sam Marshall

DATE CREATED:	31 May 2018

LAST EDITED:	23rd July 2018

DESCRIPTION: 	Impute the 1998 exit medical expenditures


ORGANIZATION:	Section 1: Set Up
				Section 2: Insurance Costs
				Section 3: Medical Expenditures
				
INPUTS: 		1998exit.dta
				
OUTPUTS: 		1998exit.log X1998OOP.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 1: Set Up
****************************************************************/

use "${buildoutput}/1998exit.dta", clear

do "${deps}/MMS2011_repute.do"  // source repute function

/****************************************************************
	SECTION 1.1: Make weights
****************************************************************/

*community weights from previous waves
gen weight98 = DWGTR
replace weight98 = EWGTR if DWGTR == 0

* adds in the early AHEAD people;
replace weight98 = BWGTR if weight98 == 0

* ADDs in the early HRS people;
replace weight98 = CWGTR if weight98 == 0
replace weight98 = AWGTR if weight98 == 0

/****************************************************************
	SECTION 1.2: Calculate months since previous interview
****************************************************************/

gen death_month = Q488
replace death_month = . if (death_month == 98 | death_month == 99)
gen death_year = Q490
replace death_year = . if (death_year == 9998 |death_year == 9999)

*Prev interview could be in 96 or 95 wave
gen prev_interview_date = EIWYEAR + ((EIWMONTH - 1)/12)
replace prev_interview_date = (DIWYEAR + ((DIWMONTH - 1)/12)) if prev_interview_date == .

gen curr_interview_date = death_year + (death_month/12)

* current interview date is really the date of death
gen time = (curr_interview_date - prev_interview_date)
replace time = 2 if (curr_interview_date != . & prev_interview_date == .)

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
gen cap15k = 12414 * months
gen cap30k = 24828 * months
gen cap5k  = 4138  * months

/****************************************************************
	SECTION 1.3: Make max expenditures into 1998 dollars
****************************************************************/
global all "mc_hmo_all ltc_all doctor_all hospice_all RX_all home_all other_all nmed_all hospital_NH_all"

foreach y of global all {
replace `y' = (`y' * ${nom98})
}

/****************************************************************
	SECTION 1.4: Cap helper_OOP variable
****************************************************************/
* helper_OOP is in terms of 4 months, if the person lived for less than four 
* months since the previous interview, assign them N months * monthly cost
replace helper_OOP = min(helper_OOP, months*helper_OOP/4)

*cap at 15k per month in the same way, using the 4 month convsion cond on survival
replace helper_OOP = cap15k if (helper_OOP > cap15k & helper_OOP != .)
replace helper_OOP = 12414*4 if (helper_OOP > 12414*4 & helper_OOP != .)
sum helper_OOP, det

/****************************************************************
	SECTION 2: Insurance Costs
****************************************************************/

/****************************************************************
	SECTION 2.1: Medicare/Medicaid through an HMO (MC_HMO) 
****************************************************************/
gen MC_HMO = Q2579
replace MC_HMO = . if (MC_HMO == 9998 | MC_HMO == 9999)

* make the premium in terms of one month (other/DK unadjusted)
replace MC_HMO = 1 * MC_HMO if Q2580 == 1
replace MC_HMO = (1/3) * MC_HMO if Q2580 == 2
replace MC_HMO = (1/6) * MC_HMO if Q2580 == 3
replace MC_HMO = (1/12) * MC_HMO if Q2580 == 4

* Replace DKs with the mean.
qui sum MC_HMO
replace MC_HMO = r(mean) if (inlist(Q2579, 9998, 9999) | (Q2575 == 1)) & mi(MC_HMO)

* people w/out medicare/medicaid through HMO at the time of their death
replace MC_HMO = 0 if (Q2575 == 5 | Q2560 == 5)

*Assign this mean to ppl who DK if they coverage through an HMO
qui sum MC_HMO
replace MC_HMO = r(mean) if (Q2575 == 8 | Q2575 == 9) & mi(MC_HMO)

summ MC_HMO, det

/****************************************************************
	SECTION 2.2: Medicare Part B 
****************************************************************/
gen MC_B = (43.8) if (Q2561 == 1 & Q2563 != 1 & Q2572 != 1)

/****************************************************************
	SECTION 2.3: Private Insurance
****************************************************************/
gen work_ins = Q2592  // amount paid OOP for insurance through the employer
replace work_ins = . if (work_ins == 9998 | work_ins == 9999)

* Make the premium in terms of one month
replace work_ins = ((1/12) * work_ins ) if Q2593 == 1
replace work_ins = ((1/3) * work_ins ) if Q2593 == 2
replace work_ins = ((1/6) * work_ins ) if Q2593 == 3
replace work_ins = (1 * work_ins ) if Q2593 == 4
replace work_ins = (4 * work_ins ) if Q2593 == 5
replace work_ins = (2 * work_ins ) if Q2593 == 6

* Replace the DKs with the mean
qui sum work_ins
replace work_ins = r(mean) if (Q2592 == 9998 | Q2592 == 9999) & mi(work_ins)

* people w/out health ins from their employer at the time of their death
replace work_ins = 0 if Q2585 == 5

* Add people who did not have pay any of the costs for this premium
replace work_ins = 0 if Q2591 == 3

* Add yes values with no number and the DK/RFs for the above
* Q2586 is the number of plans variable 
qui sum work_ins
replace work_ins = r(mean) if (inlist(Q2585, 1, 8, 9) | ///
	inlist(Q2591, 1, 2, 8, 9)) & mi(work_ins)

summ work_ins, det

/* *********************************************************************** */
gen other_ins = Q2612  // Amt paid OOP for a medicare or medigap supplement plan
replace other_ins = . if (other_ins == 999998 | other_ins == 999999)

* Make the premium in terms of one month
replace other_ins = (1 * other_ins ) if Q2613 == 1
replace other_ins = ((1/3) * other_ins ) if Q2613 == 2
replace other_ins = ((1/6) * other_ins ) if Q2613 == 3
replace other_ins = ((1/12) * other_ins ) if Q2613 == 4

* Replace the DKs with the mean
qui sum other_ins
replace other_ins = r(mean) if (Q2612 == 999998 | Q2612 == 999999) & mi(other_ins)

* Assign zero cost to people w/out a medicare or medigap supplement plan
replace other_ins = 0 if Q2609 == 5

* Assign zero cost to people who did not pay a premium for their plan
replace other_ins = 0 if Q2611 == 3

* Assign unconditional mean tothe DK/RF above and the Yeses still missing value
qui sum other_ins
replace other_ins = r(mean) if (inlist(Q2609, 1, 8, 9) | ///
	inlist(Q2611, 1, 2, 8, 9)) & mi(other_ins)

summ other_ins, det

/* *********************************************************************** */
* Amount paid OOP for a purchased medicare plan such as AARP or a state plan
gen AARP_ins = Q2624
replace AARP_ins = . if (AARP_ins == 999998 | AARP_ins == 999999)

* Make the premium in terms of one month
replace AARP_ins = (1 * AARP_ins ) if Q2625 == 1
replace AARP_ins = ((1/3) * AARP_ins ) if Q2625 == 2
replace AARP_ins = ((1/6) * AARP_ins ) if Q2625 == 3
replace AARP_ins = ((1/12) * AARP_ins ) if Q2625 == 4

* Replace the DKs with the mean
qui sum AARP_ins
replace AARP_ins = r(mean)  if (Q2624 == 999998 | Q2624 == 999999) & mi(AARP_ins)

* Assign zero cost to people who did not purchase a separate plan
replace AARP_ins = 0 if Q2621 == 5

* Assign unconditional mean to ppl who purchased but didn't report a value & DK/RF
qui sum AARP_ins
replace AARP_ins = r(mean)  if inlist(Q2621, 1, 8, 9) & mi(AARP_ins)

summ AARP_ins, det

/* *********************************************************************** */

* this private medigap variable is asked differently than in 2002+
egen private_medigap = rowtotal(work_ins other_ins AARP_ins), m
 
/****************************************************************
	SECTION 2.4: Long-term-care
****************************************************************/ 
gen long_term_care = Q2668
recode long_term_care (999998 999999 = . )

*Make the premiums all per month
replace long_term_care = (1/12) * long_term_care if (Q2669 == 1)
replace long_term_care = (1/3) * long_term_care if (Q2669 == 2)
replace long_term_care = 4 * long_term_care if (Q2669 == 3)
replace long_term_care = (1) * long_term_care if (Q2669 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (Q2669 == 6)

*Assign the mean to the DK/RF amounts
qui sum long_term_care
replace long_term_care = r(mean) if (Q2668 == 999998 | Q2668 == 999999) & ///
	mi(long_term_care)

* Assign zero cost to ppl w/out LTC ins
replace long_term_care = 0 if (Q2664 == 5 & long_term_care == . )

* Assign unconditional mean to DK/RF and ppl w/ins but no assigned amt
qui sum long_term_care
replace long_term_care = r(mean) if inlist(Q2664, 1, 8, 9) & mi(long_term_care)

summ long_term_care, det


egen avg_long_term_care = mean(long_term_care)
drop avg_long_term_care

/****************************************************************
	SECTION 2.5: Sum Insurnace Costs
****************************************************************/ 

egen insurance_costs = rowtotal(MC_HMO private_medigap long_term_care MC_B), m

* Cap monthly premium expenditure at $2,000 (in 06 dollars)
replace insurance_costs = 1655 if (insurance_costs > 1655 & insurance_costs != .)

* Make insurance costs for the time period between interviews
replace insurance_costs = (months * insurance_costs)

summ insurance_costs, det

/****************************************************************
	SECTION 3: Medical Expenditures
****************************************************************/

/****************************************************************
	SECTION 3.1: Hospital & Nursing home
****************************************************************/
gen hospital_OOP = Q1749
recode hospital_OOP (9999998 9999999 = .)

do "${deps}/x98hospital.do"  // create upper and lower bounds from seq vars
repute hospital_low hospital_high hospital_NH_all hospital_OOP

*Assign conditional mean to ppl who DK the bounds of their exp
qui sum hospital_OOP
#del ;
replace hospital_OOP = r(mean) if ((Q1749 == 9999998| Q1749 == 9999999) |  
(Q1750 == 8 | Q1750 == 9) | (Q1751 == 8 | Q1751 == 9) | (Q1752 == 8 | Q1752 == 9) | 
(Q1753 == 8 | Q1753 == 9) | (Q1754 == 8 | Q1754 == 9) | (Q1755 == 8 | Q1755 == 9) | 
(Q1756 == 8 | Q1756 == 9)) & mi(hospital_OOP);
#del cr;

*Assign zero cost to people whose hospital/Nursing Home costs were fully covered
replace hospital_OOP = 0 if Q1748 == 1

* Assign unconditional mean to ppl with some copays or DK/RF
qui sum hospital_OOP
replace hospital_OOP = r(mean) if inlist(Q1748, 2, 3, 7, 8, 9) & mi(hospital_OOP)

* Cap monthly expenditure at 30,000 dollars
replace hospital_OOP = cap30k if (hospital_OOP > cap30k & ~mi(hospital_OOP))

summ hospital_OOP, det

/****************************************************************
	SECTION 3.3: Doctor Visits
****************************************************************/
gen doctor_OOP = Q1784
recode doctor_OOP (999998 999999 = .)

do "${deps}/x98dr.do"
repute dr_low dr_high doctor_all doctor_OOP

*Assign conditional mean to ppl who DK the bounds of their exp
quietly sum doctor_OOP
#del ;
replace doctor_OOP = r(mean) if ((Q1784 == 999998 | Q1784 == 999999) | 
(Q1785 == 8 | Q1785 == 9) | (Q1786 == 8 | Q1786 == 9) | (Q1787 == 8 | Q1787 == 9) | 
(Q1788 == 8 | Q1788 == 9) | (Q1789 == 8 | Q1789 == 9) | 
(Q1790 == 8 | Q1790 == 9) | (Q1791 == 8 | Q1791 == 9)) & mi(doctor_OOP);
#del cr;

*Assign zero cost to people whose costs were fully covered by insurance
replace doctor_OOP = 0 if Q1779 == 1

* adds in the yes values with no number and the DK/RFs for the above
quietly sum doctor_OOP
replace doctor_OOP = r(mean) if inlist(Q1779, 3, 5, 7, 8) & mi(doctor_OOP)


* Cap monthly expenditure at 5,000 dollars
replace doctor_OOP = cap5k if (doctor_OOP > cap5k & ~mi(doctor_OOP))

summ doctor_OOP, det

/****************************************************************
	SECTION 3.4: Hospice
****************************************************************/
gen hospice_OOP = Q1770
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

do "${deps}/x98hospice.do"
repute hospice_low hospice_high hospice_all hospice_OOP

*Assign conditional mean to ppl who DK the bounds of their exp
qui sum hospice_OOP
#del ;
replace hospice_OOP = r(mean) if (inlist(Q1769, 3, 5, 7, 8, 9) | 
(Q1770 == 99998 | Q1770 == 99999) | (Q1771 == 8 |  Q1771 == 9) |
(Q1772 == 8 |  Q1772 == 9) | (Q1773 == 8 |  Q1773 == 9) | 
(Q1774 == 8 |  Q1774 == 9) | (Q1775 == 8 |  Q1775 == 9) | 
(Q1776 == 8 |  Q1776 == 9) | (Q1777 == 8 |  Q1777 == 9)) & mi(hospice_OOP);
#del cr;

*Assign zero cost to people whose costs were fully covered by insurance
replace hospice_OOP = 0 if Q1769 == 1

* adds in the yes values with no number and the DK/RFs for the above
* qui sum hospice_OOP
* replace hospice_OOP = r(mean) if inlist(Q1769, 3, 5, 7, 8, 9) & mi(hospice_OOP)

* Cap expenditure at 5k per month
replace hospice_OOP = cap5k if (hospice_OOP > cap5k & ~mi(hospice_OOP))

summ hospice_OOP, det

/****************************************************************
	SECTION 3.5: RX costs (annual)
	The HRS reports in months, so this will have to be converted 
****************************************************************/
gen RX_OOP = Q1794
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

do "${deps}/x98rx.do"
repute rx_low rx_high RX_all RX_OOP
  
*Assign conditional mean to ppl who DK the bounds of their exp
quietly sum RX_OOP
#del ;
replace RX_OOP = r(mean) if ((Q1794 == 99998 | Q1794 == 99999) | (Q1795 == 8 | 
Q1795 == 9) | (Q1796 == 8 | Q1796 == 9) | (Q1797 == 8 | Q1797 == 9) | (Q1798 == 8 | 
Q1798 == 9) | (Q1799 == 8 | Q1799 == 9) | (Q1800 == 8 | Q1800 == 9) | (Q1801 == 8 | 
Q1801 == 9) | ((Q1792 == 1 | Q1792 == 7) & Q1793 != 1)) & mi(RX_OOP);
#del cr;

*Assign zero cost to people whose costs were fully covered by insurance
replace RX_OOP = 0 if Q1793 == 1

* adds in the yes values with no number and the DK/RFs for the above
quietly sum RX_OOP
replace RX_OOP = r(mean) if inlist(Q1793, 3, 5, 7, 8, 9) & (RX_OOP == . | RX_OOP == 0)

* Cap monthly expenditure at $5k
replace RX_OOP = 4138 if ((RX_OOP > 4138) & RX_OOP != .)

*Scale payments to time between interviews
replace RX_OOP = (months * RX_OOP)

summ RX_OOP, det

/****************************************************************
	SECTION 3.6: In Home health care costs 
****************************************************************/
gen home_OOP = Q1811
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

do "${deps}/x98home.do"
repute home_low home_high home_all home_OOP

* this will replace the Dks/RFs/NAs with the mean
qui sum home_OOP
#del ;
replace home_OOP = r(mean) if (((Q1811 == 999998 | Q1811 == 999999) | 
(Q1812 == 8 | Q1812 == 9) | (Q1813 == 8 | Q1813 == 9) | (Q1814 == 8 | Q1814 == 9) | 
(Q1815 == 8 | Q1815 == 9) | (Q1817 == 8 | Q1817 == 9) | (Q1808 == 1)) & (home_OOP == .));
#del cr;

*Assign zero cost to people who didn't use any of the services
replace home_OOP = 0 if (Q1808 == 5 & home_OOP == .)

* Assign unconditional mean to people with this type of expenditure or DK/RF
qui sum home_OOP
replace home_OOP = r(mean) if inlist(Q1808, 1, 8, 9) & mi(home_OOP)

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
gen other_OOP = Q1818
replace other_OOP = . if (other_OOP == 999998)

do "${deps}/x98other.do"
repute other_low other_high other_all other_OOP

* Assign DK/RF with the mean
qui sum other_OOP
#del ;
replace other_OOP = r(mean) if (((Q1818 == 999998) | (Q1819 == 8 | Q1819 == 9) | 
(Q1820 == 8 | Q1820 == 9) | (Q1821 == 8 | Q1821 == 9) |
(Q1822 == 8 | Q1822 == 9) | (Q1823 == 8 | Q1823 == 9)) & (other_OOP == .));
#del cr;

* Assign zero cost to people who had no expenses of this type
replace other_OOP = 0 if Q1817 == 5

* Assign unconditional mean to people with this type of expenditure or DK/RF
qui sum other_OOP
replace other_OOP = r(mean) if inlist(Q1817, 1, 8, 9) & mi(other_OOP)

* Cap expenditure at 15k per month
replace other_OOP = cap15k if (other_OOP > cap15k & ~mi(other_OOP))

summ other_OOP, det

/****************************************************************
	SECTION 3.8: Non-medical expenditure 
****************************************************************/
gen non_med_OOP = Q1844
replace non_med_OOP = . if non_med_OOP == 999998

do "${deps}/x98nmed.do"
repute non_med_low non_med_high nmed_all non_med_OOP

* replace the Dks/RFs/NAs with the mean
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if ((Q1845 == 8 | Q1845 == 9) | ///
	(Q1846 == 8 | Q1846 == 9) | (Q1847 == 8 | Q1847 == 9) | ///
	(Q1848 == 8 | Q1848 == 9) | (Q1849 == 8 | Q1849 == 9)) & mi(non_med_OOP)

* people who had none of these expenses
replace non_med_OOP = 0 if Q1843 == 5

* adds in the yes values with no number and the DK/RFs for pos exp
quietly sum non_med_OOP
replace non_med_OOP = r(mean) if inlist(Q1843, 1, 8, 9) & mi(non_med_OOP)

* makes the max of 5k per month
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
rename Q492M death_area
label values death_area death_region

#del ;
global OOP "insurance_costs hospital_OOP doctor_OOP 
hospice_OOP RX_OOP home_OOP other_OOP non_med_OOP total_OOP 
helper_OOP MC_HMO work_ins AARP_ins long_term_care MC_B";
#del cr;

* make expenses in 2006 dollars
foreach y of global OOP {
	replace `y' = 0 if mi(`y') & ~mi(total_OOP)
	replace `y' = (`y' * (116.567/96.472))
}

keep HHID PN *_OOP death_area insurance_costs death_month death_year time ///
	months weight98 MC_HMO work_ins other_ins AARP_ins long_term_care MC_B
drop if total_OOP == .
merge 1:1 HHID PN using "${rawdata}/${trversion}", keep(match) nogen
program drop repute
save "${OOPdata}/X1998OOP.dta", replace

* print results
foreach y of global OOP {
	sum `y', det
}

log close 
