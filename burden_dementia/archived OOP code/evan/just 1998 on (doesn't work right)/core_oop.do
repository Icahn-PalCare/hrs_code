/*note--11/30/17--only running for 1998 on
********************************************************************************

use $savedir/core1992.dta, clear
merge 1:1 HHID PN using $savedir/core1992_months.dta, nogen keep(match)

//Note: one respondent answers this section; they answer twice if married: once for R and once for SP
//rrd: if pn!= APN_fin then information must come from someone else, hence use question re: spouse
/*

//Respondent

        6632    R14.    Do you have any type of health insurance coverage,
        16632           Medigap or other supplemental coverage, or long-term
                        care insurance that is purchased directly from an
                        insurance company or through a membership
                        organization such as AARP (the American Association
                        of Retired Persons)? [IMPUTED]

    	6638    R14b.   How much do you pay for this insurance (per month
        16638           or per quarter)? [IMPUTED]

    	6639    R14b.   PER [IMPUTED]
        16639   

//Spouse

        6832    R37.    Does your (husband/wife/partner) have any type of
        16832           health insurance coverage, Medigap or other
                        supplemental coverage, or long-term care insurance
                        that is purchased directly from an insurance company
                        or through a membership organization such as AARP
                        (the American Association of Retired Persons)?
                        [IMPUTED]

        6838    R37b.   How much does (he/she) pay for this insurance (per
    	16838           month or per quarter)? [IMPUTED]
        
        6839    R37b.   PER [IMPUTED]
    	16839 

*/

//respondent (financial respondent: PN==APN_FIN)

gen private_ltc = V6638 if PN==APN_FIN
replace private_ltc = 0 if private_ltc == 9996 & PN==APN_FIN & V6632==5				//9996.  Inap, 5, 8-9 in V6632
replace private_ltc = . if private_ltc == 9996 & PN==APN_FIN & (V6632==8 | V6632==9)		//rrd: these cases dont exist

replace private_ltc = 1      * private_ltc if V6639==4 & PN==APN_FIN	//month
replace private_ltc = (1/3)  * private_ltc if V6639==5 & PN==APN_FIN	//quarter
replace private_ltc = (1/12) * private_ltc if V6639==6 & PN==APN_FIN	//year
replace private_ltc = .      * private_ltc if V6639==7 & PN==APN_FIN & !missing(private_ltc)	//other
replace private_ltc = ((1/20)*(1/12)) * private_ltc if V6639==8 & PN==APN_FIN	//lump sum (assume paid other 20 years)
replace private_ltc = 0      * private_ltc if V6639==0 & PN==APN_FIN	//inap

//spouse		//rrd: why are there people that say they dont have insurance for themselves yet we have them flagged from sps with costs

replace private_ltc = V6838 if PN!=APN_FIN
replace private_ltc = 0 if private_ltc == 9996 & PN!=APN_FIN & V6832==5				//9996.  Inap, 5, 8-9 in V6832
replace private_ltc = . if private_ltc == 9996 & PN!=APN_FIN & (V6832==8 | V6832==9)

replace private_ltc = 1      * private_ltc if V6839==4 & PN!=APN_FIN	//month
replace private_ltc = (1/3)  * private_ltc if V6839==5 & PN!=APN_FIN	//quarter
replace private_ltc = (1/12) * private_ltc if V6839==6 & PN!=APN_FIN	//year
replace private_ltc = .      * private_ltc if V6839==7 & PN!=APN_FIN & !missing(private_ltc)	//other
replace private_ltc = ((1/20)*(1/12)) * private_ltc if V6839==8 & PN!=APN_FIN	//lump sum (assume paid other 20 years)
replace private_ltc = 0      * private_ltc if V6839==0 & PN!=APN_FIN	//inap

*summarize
*fsum private_ltc, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
sum private_ltc

*caps

scalar z = cpi1992/cpiBASE

upp_cap private_ltc ${private_ltc_cap}*z 

save $savedir/core1992_oop.dta, replace

********************************************************************************

use $savedir/core1993.dta, clear
merge 1:1 HHID PN using $savedir/core1993_months.dta, nogen keep(match)

//Note: questions refer to last 12 months in 1993 interviews.  (Compared to last 2 years or since last interview in later waves)

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 36.60 if V755==1 & V1838!=1 & V1848!=1

//In this wave, respondent reports all private insurance premium data in a single amount, combing private/medigap/LTC.

gen private_ltc = V1867
replace_mi private_ltc  999998 999999

*convert payment periodicity to monthly:
replace private_ltc = 4      * private_ltc if (V1868 == 1)
replace private_ltc = (1/2)  * private_ltc if (V1868 == 2)
replace private_ltc = 1      * private_ltc if (V1868 == 3)
replace private_ltc = (1/3)  * private_ltc if (V1868 == 4)
replace private_ltc = (1/6)  * private_ltc if (V1868 == 5)
replace private_ltc = (1/12) * private_ltc if (V1868 == 6)
replace private_ltc = (1/2)  * private_ltc if (V1868 == 8)
replace private_ltc = . if (V1868==7 | V1868==98 | V1868==99) & ///
								 (private_ltc != 0)

//Spending information is available in two amounts (a) NH, and (b) everything else (hospital, doctor, other medical or dental expenses). 
//In addition, the following have this note: "NOTE: This question is only asked of an Only R or the Financial Respondent" (i.e. R/SP report a single totals)

/*
	V629 [HH]    E10. $ R/SP PAY NURSING HOME           
	E10. About how much did you [and your (husband/wife/partner)] end up paying for nursing home bills?
*/

gen NH_OOP93 = V629
replace_mi NH_OOP93 99998 99999

/*
	V740 [HH]    E26. $ R/SP PAY ANY MED EXP LAST 12 MOS           
	E26. Not counting costs covered by insurance, about how much did you [and your (husband/wife/partner)] end up paying for any part of hospital and doctor bills 
	and any other medical or dental expenses in the last 12 months, since MONTH of (1992/1993)?
*/

gen non_NH_OOP93 = V740
replace_mi non_NH_OOP93 99998 99999

*summarize
*fsum private_ltc *_OOP93, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
sum private_ltc *_OOP93

*caps

scalar z = cpi1993/cpiBASE

//caps use 12 months instead of the "months" variable (questions refer to 12 month period)
//for non_NH, I sum all caps for hospital/outpatient/doctor/dental/drugs/home/special/other

upp_cap private_ltc ${private_ltc_cap}*z 
upp_cap NH_OOP93 ${NH_OOP_cap}*z*12 
upp_cap non_NH_OOP93 (${hospital_OOP_cap}+${patient_OOP_cap}+${doctor_OOP_cap}+${dental_OOP_cap}+${RX_OOP_cap}+${home_OOP_cap}+${special_OOP_cap}+${other_OOP_cap})*z*12 

save $savedir/core1993_oop.dta, replace

********************************************************************************

use $savedir/core1994.dta, clear
merge 1:1 HHID PN using $savedir/core1994_months.dta, nogen keep(match)

//No MC_B information

// EPHI: W6705-W6709

gen private_medigap_1 = W6711
replace_mi private_medigap_1  99997 99998 99999

/*
        W6724   R4.     Do you currently have any type of health insurance
                        coverage obtained through your [or your (husband's/
                        wife's/partner's)] employer, former employer, or
                        union, such as Blue Cross-Blue Shield or a Health
                        Maintenance Organization?
*/

gen private_medigap_2 = W6728
replace_mi private_medigap_2 997 998 999

gen private_medigap_3 = W6742
replace_mi private_medigap_3 997 998 999


/*
        W6754   R14.    Do you have any basic health insurance coverage,
                        purchased directly from an insurance company or
                        through a membership organization such as AARP
                        (American Association of Retired Persons)?
*/

gen private_medigap_4 = W6755
replace_mi private_medigap_4  99997 99998 99999

*convert payment periodicity to monthly:
replace private_medigap_4 = 1      * private_medigap_4 if (W6756 == 4)
replace private_medigap_4 = (1/3)  * private_medigap_4 if (W6756 == 5)
replace private_medigap_4 = (1/12) * private_medigap_4 if (W6756 == 6)
replace private_medigap_4 = . if (W6756==97 | W6756==98 | W6756==99) & ///
								 (private_medigap_4 != 0)

/*
        W6757   R14b.   Do you have any type of supplementary health
                        insurance coverage, such as Medigap or long-term
                        care insurance that is purchased directly from an
                        insurance company or through a membership
                        organization such as AARP (American Association of
                        Retired  Persons)?
*/

//Note: contains both private_medigap and long_term_care

gen private_medigap_5 = W6762
replace_mi private_medigap_5  99997 99998 99999

*convert payment periodicity to monthly:
replace private_medigap_5 = 1      * private_medigap_5 if (W6763 == 4)
replace private_medigap_5 = (1/3)  * private_medigap_5 if (W6763 == 5)
replace private_medigap_5 = (1/12) * private_medigap_5 if (W6763 == 6)
replace private_medigap_5 = . if (W6763==97 | W6763==98 | W6763==99) & ///
								 (private_medigap_5 != 0)	
								 							 
/*
        W429    B33a-3. Roughly how much did you spend out-of-pocket for
                        [your hospital stay/nursing home stay/visits to a
                        doctor]?
*/

gen hospital_NH_doctor_OOP = W429
replace_mi hospital_NH_doctor_OOP 9999994 9999995 9999997 9999998 9999999

/*
        W433   B33-1a.  Do you regularly purchase medications prescribed
                        for you by a doctor?
        W434    B33-1b. In the last 12 months, how much did you spend per
                        week, month, or year?                      
*/

gen RX_OOP = W434
replace_mi RX_OOP 99997 99998 99999

replace RX_OOP = (52/12)  * RX_OOP if W435==2
replace RX_OOP = 1        * RX_OOP if W435==4
replace RX_OOP = (1/12)   * RX_OOP if W435==6
replace RX_OOP = (365/12) * RX_OOP if W435==11
replace RX_OOP = . if (W435==98 | W435==99 | W435==.) & !missing(RX_OOP)

*summarize
*fsum private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum private_medigap_* *_OOP

*caps

scalar z = cpi1994/cpiBASE

*If any of the "check all that apply" questions (W6701-W6704) is equal to 1 (Medicare), use the lower cap of $400.  Otherwise, use $2000.
forvalues pm=1/4{
	upp_cap private_medigap_`pm' cond(inlist(1,W6701,W6702,W6703,W6704),${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap private_medigap_5 ${private_ltc_cap}*z  //cap differs b/c may include LTC spending.


upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap hospital_NH_doctor_OOP z*months*(${hospital_OOP_cap}+${NH_OOP_cap}+${doctor_OOP_cap})

save $savedir/core1994_oop.dta, replace





********************************************************************************


use $savedir/core1995.dta, clear
merge 1:1 HHID PN using $savedir/core1995_months.dta, nogen keep(match)

gen MC_HMO = D5193
replace_mi MC_HMO 99997 99998 99999

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if D5194 == 1 //month
replace MC_HMO = (1/3)  * MC_HMO if D5194 == 2 //quarter
replace MC_HMO = (1/12) * MC_HMO if D5194 == 3 //year
replace MC_HMO = 0      * MC_HMO if D5194 == 4 //no premium
replace MC_HMO = . 				 if (D5194 == 7 | D5194 == 8 | D5194 == 9) & ///
									(MC_HMO!=0)

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 46.1 if (D5145 == 1 & D5155 != 1 & D5175 != 1)

*Other insurance #1

/*
          R9. Not counting long-term care insurance or
          IF Q126 IS (1) OR Q5144 IS (1) Medicare,
          END

          IF Q5158 IS (1) "Medicaid",
          END

          IF Q5176 IS (1 OR 2 OR 3) your government health insurance,
          END
           do you have any health insurance that pays any part of hospital or doctor
          bills? (Sometimes this is called a Medi-Gap policy).
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_1 = D5227
replace_mi private_medigap_1  99997 99998 99999

*convert payment periodicity to monthly:
replace private_medigap_1 = 1      * private_medigap_1 if (D5228 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (D5228 == 2)
replace private_medigap_1 = (1/12) * private_medigap_1 if (D5228 == 3)
replace private_medigap_1 = . if (D5228==7 | D5228==8 | D5228==9) & ///
								 (private_medigap_1 != 0)

*Other insurance #2

/*
          R9. Not counting long-term care insurance or
          IF Q126 IS (1) OR Q5144 IS (1) Medicare,
          END

          IF Q5158 IS (1) "Medicaid",
          END

          IF Q5176 IS (1 OR 2 OR 3) your government health insurance,
          END
           do you have any health insurance that pays any part of hospital or doctor
          bills? (Sometimes this is called a Medi-Gap policy).
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_2 = D5244
replace_mi private_medigap_2  99997 99998 99999

*convert payment periodicity to monthly:
replace private_medigap_2 = 1      * private_medigap_2 if (D5245 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (D5245 == 2)
replace private_medigap_2 = (1/12) * private_medigap_2 if (D5245 == 3)
replace private_medigap_2 = . if (D5245==7 | D5245==8 | D5245==9) & ///
								 (private_medigap_2 != 0)
								 
gen long_term_care = D5267
replace_mi long_term_care 99997 99998 99999

replace long_term_care = 1      * long_term_care if (D5268 == 1)
replace long_term_care = (1/3)  * long_term_care if (D5268 == 2)
replace long_term_care = (1/12) * long_term_care if (D5268 == 3)
replace long_term_care = . if (D5268 == 7 | D5268 == 8 | D5268 == 9) & (long_term_care!=0)

gen hospital_NH_OOP = D1688
replace_mi hospital_NH_OOP 999997 999998 999999

gen doctor_patient_dental_OOP = D1732
replace_mi doctor_patient_dental_OOP 99997 99998 99999

gen RX_OOP = D1749
replace_mi RX_OOP 99997 99998 99999

gen home_special_OOP = D1781
replace_mi home_special_OOP 99997 99998 99999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
sum MC_HMO private_medigap_* long_term_care *_OOP
								 								 								 
*caps

scalar z = cpi1995/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap private_medigap_1 cond(D5144==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
upp_cap private_medigap_2 cond(D5144==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_NH_OOP (${hospital_OOP_cap}+${NH_OOP_cap})*z*months
upp_cap doctor_patient_dental_OOP (${patient_OOP_cap}+${doctor_OOP_cap}+${dental_OOP_cap})*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_special_OOP (${home_OOP_cap}+${special_OOP_cap})*z*months

save $savedir/core1995_oop.dta, replace
								 





********************************************************************************

use $savedir/core1996.dta, clear
merge 1:1 HHID PN using $savedir/core1996_months.dta, nogen keep(match)

gen MC_HMO = E5152
replace MC_HMO = . if (MC_HMO == 9997 | MC_HMO == 9998 | MC_HMO == 9999)

replace MC_HMO = 1      * MC_HMO if E5153 == 1
replace MC_HMO = (1/3)  * MC_HMO if E5153 == 2
replace MC_HMO = (1/6)  * MC_HMO if E5153 == 3
replace MC_HMO = (1/12) * MC_HMO if E5153 == 4
replace MC_HMO = . 				 if (E5153 == 7 | E5153 == 8 | E5153 == 9) & (MC_HMO!=0) //NOTE: if frequency is unknown and amount is not zero, set to missing

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 42.5 if (E5134 == 1 & E5135 != 1 & E5145 != 1)

*Employer-Provided: Plan #1

/*
          R13. (Not including Medicare/Medicaid/Champus-Champva) are you covered by
          any employer-provided health insurance?
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_1 = E5167_1
replace private_medigap_1  = . if (private_medigap_1 == 9997 | private_medigap_1== 9998 | private_medigap_1== 9999)

*convert payment periodicity to monthly:
replace private_medigap_1 = (1/12) * private_medigap_1 if (E5168_1 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (E5168_1 == 2)
replace private_medigap_1 = (1/2)  * private_medigap_1 if (E5168_1 == 3)
replace private_medigap_1 = 1      * private_medigap_1 if (E5168_1 == 4)
replace private_medigap_1 = 4      * private_medigap_1 if (E5168_1 == 5)
replace private_medigap_1 = 2      * private_medigap_1 if (E5168_1 == 6)
replace private_medigap_1 = (1/6)  * private_medigap_1 if (E5168_1 == 7)
replace private_medigap_1 = 2      * private_medigap_1 if (E5168_1 == 8)
replace private_medigap_1 = . if (E5168_1==97 | E5168_1==98 | E5168_1==99) & ///
								 (private_medigap_1 != 0)

*Employer-Provided: Plan #2

/*
          R13. (Not including Medicare/Medicaid/Champus-Champva) are you covered by
          any employer-provided health insurance?
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_2 = E5167_2
replace_mi private_medigap_2  9997 9998 9999

*convert payment periodicity to monthly:
replace private_medigap_2 = (1/12) * private_medigap_2 if (E5168_2 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (E5168_2 == 2)
replace private_medigap_2 = (1/2)  * private_medigap_2 if (E5168_2 == 3)
replace private_medigap_2 = 1      * private_medigap_2 if (E5168_2 == 4)
replace private_medigap_2 = 4      * private_medigap_2 if (E5168_2 == 5)
replace private_medigap_2 = 2      * private_medigap_2 if (E5168_2 == 6)
replace private_medigap_2 = (1/6)  * private_medigap_2 if (E5168_2 == 7)
replace private_medigap_2 = 2      * private_medigap_2 if (E5168_2 == 8)
replace private_medigap_2 = . if (E5168_2==97 | E5168_2==98 | E5168_2==99) & ///
								 (private_medigap_2 != 0)
								 
*Supplemental Insurance

/*
          R46. Not counting long-term care insurance or Medicare, (or Medicaid/or any
          other insurance we've discussed), do you have any other insurance that pays
          any part of hospital or doctor bills? Sometimes this is called a Medigap or
          Medicare Supplement policy.
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_3 = E5209
replace_mi private_medigap_3  999998 999999

*convert payment periodicity to monthly:
replace private_medigap_3 = (1/12) * private_medigap_3 if (E5210 == 1)
replace private_medigap_3 = (1/3)  * private_medigap_3 if (E5210 == 2)
replace private_medigap_3 = (1/2)  * private_medigap_3 if (E5210 == 3)
replace private_medigap_3 = 1      * private_medigap_3 if (E5210 == 4)
replace private_medigap_3 = 4      * private_medigap_3 if (E5210 == 5)
replace private_medigap_3 = 2      * private_medigap_3 if (E5210 == 6)
replace private_medigap_3 = (1/6)  * private_medigap_3 if (E5210 == 7)
replace private_medigap_3 = 2      * private_medigap_3 if (E5210 == 8)
replace private_medigap_3 = . if (E5210==97 | E5210==98 | E5210==99) & ///
								 (private_medigap_3 != 0)
								 
*Other insurance

/*
          R48. Do you have any basic health insurance coverage purchased directly from
          an insurance company or through a membership organization?

          INSURANCE FROM ORGANIZATIONS SUCH AS AARP OR PROFESSIONAL ORGANIZATIONS, OR
          FROM STATE OR HEALTH ALLIANCES ARE EXAMPLES OF SUCH INSURANCE.
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_4 = E5221
replace_mi private_medigap_4  999997 999998 999999

*convert payment periodicity to monthly:
replace private_medigap_4 = (1/12) * private_medigap_4 if (E5222 == 1)
replace private_medigap_4 = (1/3)  * private_medigap_4 if (E5222 == 2)
replace private_medigap_4 = (1/2)  * private_medigap_4 if (E5222 == 3)
replace private_medigap_4 = 1      * private_medigap_4 if (E5222 == 4)
replace private_medigap_4 = 4      * private_medigap_4 if (E5222 == 5)
replace private_medigap_4 = 2      * private_medigap_4 if (E5222 == 6)
replace private_medigap_4 = (1/6)  * private_medigap_4 if (E5222 == 7)
replace private_medigap_4 = 2      * private_medigap_4 if (E5222 == 8)
replace private_medigap_4 = . if (E5222==97 | E5222==98 | E5222==99) & ///
								 (private_medigap_4 != 0)

gen long_term_care = E5270
replace_mi long_term_care 999995 999997 999998 999999

replace long_term_care = (1/12)            * long_term_care if (E5271 == 1)
replace long_term_care = (1/3)             * long_term_care if (E5271 == 2)
replace long_term_care = 4                 * long_term_care if (E5271 == 3)
replace long_term_care = 1                 * long_term_care if (E5271 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (E5271 == 6)	//NOTE: F6004==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = . if (E5271 == 7 | E5271 == 8 | E5271 == 9) & (long_term_care!=0)

gen hospital_NH_OOP = E1783
replace hospital_NH_OOP = . if (hospital_NH_OOP >= 999996 & hospital_NH_OOP <= 9999999)		//rrd: consider changing this

gen doctor_patient_dental_OOP = E1804
replace_mi doctor_patient_dental_OOP 99997 99998 99999

gen RX_OOP = E1816
replace_mi RX_OOP 99997 99998 99999

gen home_special_OOP = E1834
replace_mi home_special_OOP 99997 99998 99999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO private_medigap_* long_term_care *_OOP	
							 								 								 
*caps

scalar z = cpi1996/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
forvalues pm=1/4{
	upp_cap private_medigap_`pm' cond(E5133==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_NH_OOP (${hospital_OOP_cap}+${NH_OOP_cap})*z*months 
upp_cap doctor_patient_dental_OOP (${patient_OOP_cap}+${doctor_OOP_cap}+${dental_OOP_cap})*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_special_OOP (${home_OOP_cap}+${special_OOP_cap})*z*months

save $savedir/core1996_oop.dta, replace
*/

********************************************************************************

use $savedir/core1998.dta, clear
merge 1:1 HHID PN using $savedir/core1998_months.dta, nogen keep(match)

gen MC_HMO = F5885
replace_mi MC_HMO 9998 9999

replace MC_HMO = 1      * MC_HMO if F5886 == 1
replace MC_HMO = (1/3)  * MC_HMO if F5886 == 2
replace MC_HMO = (1/6)  * MC_HMO if F5886 == 3
replace MC_HMO = (1/12) * MC_HMO if F5886 == 4
replace MC_HMO = . 				 if (F5886 == 7 | F5886 == 8 | F5886 == 9) & (MC_HMO!=0) //NOTE: if frequency is unknown and amount is not zero, set to missing

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 43.8 if (F5867 == 1 & F5868 != 1 & F5878 != 1)

gen private_medigap_1 = F5900
replace_mi private_medigap_1  9998 9999

replace private_medigap_1 = (1/12) * private_medigap_1 if (F5901 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (F5901 == 2)
replace private_medigap_1 = (1/2)  * private_medigap_1 if (F5901 == 3)
replace private_medigap_1 = 1      * private_medigap_1 if (F5901 == 4)
replace private_medigap_1 = 4      * private_medigap_1 if (F5901 == 5)
replace private_medigap_1 = 2      * private_medigap_1 if (F5901 == 6)
replace private_medigap_1 = (1/6)  * private_medigap_1 if (F5901 == 7)
replace private_medigap_1 = 2      * private_medigap_1 if (F5901 == 8)
replace private_medigap_1 = . if (F5901==97 | F5901==98 | F5901==99) & (private_medigap_1 != 0)

gen private_medigap_2 = F5941
replace_mi private_medigap_2  999998 999999

replace private_medigap_2 = (1/12) * private_medigap_2 if (F5942 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (F5942 == 2)
replace private_medigap_2 = (1/2)  * private_medigap_2 if (F5942 == 3)
replace private_medigap_2 = 1      * private_medigap_2 if (F5942 == 4)
replace private_medigap_2 = 4      * private_medigap_2 if (F5942 == 5)
replace private_medigap_2 = 2      * private_medigap_2 if (F5942 == 6)
replace private_medigap_2 = (1/6)  * private_medigap_2 if (F5942 == 7)
replace private_medigap_2 = 2      * private_medigap_2 if (F5942 == 8)
replace private_medigap_2 = . if (F5942==97 | F5942==98 | F5942==99) & (private_medigap_2 != 0)
									
gen private_medigap_3 = F5953
replace_mi private_medigap_3  999998 999999

replace private_medigap_3 = (1/12) * private_medigap_3 if (F5954 == 1)
replace private_medigap_3 = (1/3)  * private_medigap_3 if (F5954 == 2)
replace private_medigap_3 = (1/2)  * private_medigap_3 if (F5954 == 3)
replace private_medigap_3 = 1      * private_medigap_3 if (F5954 == 4)
replace private_medigap_3 = 4      * private_medigap_3 if (F5954 == 5)
replace private_medigap_3 = 2      * private_medigap_3 if (F5954 == 6)
replace private_medigap_3 = (1/6)  * private_medigap_3 if (F5954 == 7)
replace private_medigap_3 = 2      * private_medigap_3 if (F5954 == 8)
replace private_medigap_3 = . if (F5954==97 | F5954==98 | F5954==99) & (private_medigap_3 != 0)			

gen long_term_care = F6003
replace_mi long_term_care 999998 999999

replace long_term_care = (1/12)            * long_term_care if (F6004 == 1)
replace long_term_care = (1/3)             * long_term_care if (F6004 == 2)
replace long_term_care = 4                 * long_term_care if (F6004 == 3)
replace long_term_care = 1                 * long_term_care if (F6004 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (F6004 == 6)	//NOTE: F6004==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = . if (F6004 == 7 | F6004 == 8 | F6004 == 9) & (long_term_care!=0)

gen hospital_NH_OOP = F2305
replace_mi hospital_NH_OOP 9999998 9999999

gen doctor_patient_dental_OOP = F2337
replace_mi doctor_patient_dental_OOP 999998 999999

gen RX_OOP = F2347
replace_mi RX_OOP 99998 99999

gen home_special_OOP = F2364
replace_mi home_special_OOP 999998 999999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO private_medigap_* long_term_care *_OOP

*caps

scalar z = cpi1998/cpiBASE


upp_cap MC_HMO ${MC_HMO_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(F5866==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_NH_OOP (${hospital_OOP_cap}+${NH_OOP_cap})*z*months 
upp_cap doctor_patient_dental_OOP (${patient_OOP_cap}+${doctor_OOP_cap}+${dental_OOP_cap})*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_special_OOP (${home_OOP_cap}+${special_OOP_cap})*z*months


save $savedir/core1998_oop.dta, replace




********************************************************************************

use $savedir/core2000.dta, clear
merge 1:1 HHID PN using $savedir/core2000_months.dta, nogen keep(match)

gen MC_HMO = G6258
replace_mi MC_HMO 9998 9999

replace MC_HMO = 1      * MC_HMO if G6259 == 1
replace MC_HMO = (1/3)  * MC_HMO if G6259 == 2
replace MC_HMO = (1/6)  * MC_HMO if G6259 == 3
replace MC_HMO = (1/12) * MC_HMO if G6259 == 4
replace MC_HMO = . 				 if (G6259 == 7 | G6259 == 8 | G6259 == 9) & (MC_HMO!=0) //NOTE: if frequency is unknown and amount is not zero, set to missing

gen MC_B = 45.5 if (G6240 == 1 & G6241 != 1 & G6251 != 1)		//rrd: changed to match source

gen private_medigap_1 = G6273
replace_mi private_medigap_1  99998 99999

replace private_medigap_1 = (1/12) * private_medigap_1 if (G6274 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (G6274 == 2)
replace private_medigap_1 = (1/2)  * private_medigap_1 if (G6274 == 3)
replace private_medigap_1 = 1      * private_medigap_1 if (G6274 == 4)
replace private_medigap_1 = 4      * private_medigap_1 if (G6274 == 5)
replace private_medigap_1 = 2      * private_medigap_1 if (G6274 == 6)
replace private_medigap_1 = (1/6)  * private_medigap_1 if (G6274 == 7)
replace private_medigap_1 = 2      * private_medigap_1 if (G6274 == 8)
replace private_medigap_1 = . if (G6274==97 | G6274==98 | G6274==99) & (private_medigap_1 != 0)

gen private_medigap_2 = G6315
replace_mi private_medigap_2  999998 999999

replace private_medigap_2 = (1/12) * private_medigap_2 if (G6316 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (G6316 == 2)
replace private_medigap_2 = (1/2)  * private_medigap_2 if (G6316 == 3)
replace private_medigap_2 = 1      * private_medigap_2 if (G6316 == 4)
replace private_medigap_2 = 4      * private_medigap_2 if (G6316 == 5)
replace private_medigap_2 = 2      * private_medigap_2 if (G6316 == 6)
replace private_medigap_2 = (1/6)  * private_medigap_2 if (G6316 == 7)
replace private_medigap_2 = 2      * private_medigap_2 if (G6316 == 8)
replace private_medigap_2 = . if (G6316==97 | G6316==98 | G6316==99) & (private_medigap_2 != 0)

gen private_medigap_3 = G6327
replace_mi private_medigap_3  999998 999999

replace private_medigap_3 = (1/12) * private_medigap_3 if (G6328 == 1)
replace private_medigap_3 = (1/3)  * private_medigap_3 if (G6328 == 2)
replace private_medigap_3 = (1/2)  * private_medigap_3 if (G6328 == 3)
replace private_medigap_3 = 1      * private_medigap_3 if (G6328 == 4)
replace private_medigap_3 = 4      * private_medigap_3 if (G6328 == 5)
replace private_medigap_3 = 2      * private_medigap_3 if (G6328 == 6)
replace private_medigap_3 = (1/6)  * private_medigap_3 if (G6328 == 7)
replace private_medigap_3 = 2      * private_medigap_3 if (G6328 == 8)
replace private_medigap_3 = . if (G6328==97 | G6328==98 | G6328==99) & (private_medigap_3 != 0)

gen long_term_care = G6397
replace_mi long_term_care 999998 999999
replace long_term_care = 0 if (long_term_care == 999995) //(NOTE: 999995 "Amount included with other insurance payments")
//Note: the note re: 999995 was not included in the 2000 codebook, but since several observations take this value, I assume that the note applies here as well.

replace long_term_care = (1/12)            * long_term_care if (G6398 == 1)
replace long_term_care = (1/3)             * long_term_care if (G6398 == 2)
replace long_term_care = 4                 * long_term_care if (G6398 == 3)
replace long_term_care = 1                 * long_term_care if (G6398 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (G6398 == 6) //NOTE: G6398==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = . if (G6398 == 7 | G6398 == 8 | G6398 == 9) & (long_term_care!=0)

gen hospital_NH_OOP = G2577
replace_mi hospital_NH_OOP 9999998 9999999

gen doctor_patient_dental_OOP = G2614
replace_mi doctor_patient_dental_OOP 999998 999999

gen RX_OOP = G2624
replace_mi RX_OOP 99998 99999

gen home_special_OOP = G2641
replace_mi home_special_OOP 999998 999999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO private_medigap_* long_term_care *_OOP	
			
*caps

scalar z = cpi2000/cpiBASE


upp_cap MC_HMO ${MC_HMO_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(G6238==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_NH_OOP (${hospital_OOP_cap}+${NH_OOP_cap})*z*months 
upp_cap doctor_patient_dental_OOP (${patient_OOP_cap}+${doctor_OOP_cap}+${dental_OOP_cap})*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_special_OOP (${home_OOP_cap}+${special_OOP_cap})*z*months
					 
save $savedir/core2000_oop.dta, replace




********************************************************************************

use $savedir/core2002.dta, clear
merge 1:1 HHID PN using $savedir/core2002_months.dta, nogen keep(match)

gen MC_HMO = HN014
replace_mi MC_HMO 9998 9999

replace MC_HMO = 1      * MC_HMO if HN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if HN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if HN018 == 3
replace MC_HMO = (1/12) * MC_HMO if HN018 == 4
replace MC_HMO = . 				 if (HN018 == 7 | HN018 == 8 | HN018 == 9) & (MC_HMO!=0) //NOTE: if frequency is unknown and amount is not zero, set to missing

gen MC_B = 54.0 if (HN004 == 1 & HN005 != 1 & HN007 != 1)

gen private_medigap_1 = HN040_1
replace_mi private_medigap_1  998 999

gen private_medigap_2 = HN040_2
replace_mi private_medigap_2  998 999

gen private_medigap_3 = HN040_3
replace_mi private_medigap_3  998 999

gen long_term_care = HN079
replace_mi long_term_care 999998 999999
replace long_term_care = 0 if (long_term_care == 999995) //(NOTE: 999995 "Amount included with other insurance payments")

replace long_term_care = (1/12)            * long_term_care if (HN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (HN083 == 2)
replace long_term_care = 4                 * long_term_care if (HN083 == 3)
replace long_term_care = 1                 * long_term_care if (HN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (HN083 == 6) //NOTE: HN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = . if (HN083 == 7 | HN083 == 8 | HN083 == 9) & (long_term_care!=0)

gen hospital_OOP = HN106
replace_mi hospital_OOP 99998 99999

gen NH_OOP = HN119
replace_mi NH_OOP 999998 999999

gen patient_OOP = HN139
replace_mi patient_OOP 99998 99999

gen doctor_OOP = HN156
replace_mi doctor_OOP 999998 999999

gen dental_OOP = HN168
replace_mi dental_OOP 99998 99999

gen RX_OOP = HN180
replace_mi RX_OOP 99998 99999

gen home_OOP = HN194
replace_mi home_OOP 99998 99999

gen special_OOP = HN239
replace_mi special_OOP 99998 99999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO private_medigap_* long_term_care *_OOP

*caps
scalar z = cpi2002/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(HN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  


save $savedir/core2002_oop.dta, replace




********************************************************************************

use $savedir/core2004.dta, clear
merge 1:1 HHID PN using $savedir/core2004_months.dta, nogen keep(match)

gen MC_HMO = JN014
replace_mi MC_HMO 9998 9999

replace MC_HMO = 1      * MC_HMO if JN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if JN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if JN018 == 3
replace MC_HMO = (1/12) * MC_HMO if JN018 == 4
replace MC_HMO = . 				 if (JN018 == 7 | JN018 == 8 | JN018 == 9) & (MC_HMO!=0) //NOTE: if frequency is unknown and amount is not zero, set to missing

gen MC_B = 66.6 if (JN004 == 1 & JN005 != 1 & JN007 != 1)

gen private_medigap_1 = JN040_1
replace_mi private_medigap_1  9998 9999

gen private_medigap_2 = JN040_2
replace_mi private_medigap_2  9998 9999

gen private_medigap_3 = JN040_3
replace_mi private_medigap_3  9998 9999

gen long_term_care = JN079
replace_mi long_term_care 99998 99999
replace long_term_care = 0 if (long_term_care == 99995)

replace long_term_care = (1/12)            * long_term_care if (JN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (JN083 == 2)
replace long_term_care = 4                 * long_term_care if (JN083 == 3)
replace long_term_care = 1                 * long_term_care if (JN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (JN083 == 6) //NOTE: JN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = . if (JN083 == 7 | JN083 == 8 | JN083 == 9) & (long_term_care!=0)

gen hospital_OOP = JN106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = JN119
replace_mi NH_OOP 999998 999999

gen patient_OOP = JN139
replace_mi patient_OOP 999998 999999

gen doctor_OOP = JN156
replace_mi doctor_OOP 999998 999999

gen dental_OOP = JN168
replace_mi dental_OOP 99998 99999

gen RX_OOP = JN180
replace_mi RX_OOP 99998 99999

gen home_OOP = JN194
replace_mi home_OOP 999998 999999

gen special_OOP = JN239
replace_mi special_OOP 99998 99999

*summarize
*fsum MC_HMO private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO private_medigap_* long_term_care *_OOP

*caps

scalar z = cpi2004/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(JN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  


save $savedir/core2004_oop.dta, replace




********************************************************************************

use $savedir/core2006.dta, clear
merge 1:1 HHID PN using $savedir/core2006_months.dta, nogen keep(match)

gen MC_HMO = KN014
replace_mi MC_HMO 998 999

replace MC_HMO = 1      * MC_HMO if KN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if KN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if KN018 == 3
replace MC_HMO = (1/12) * MC_HMO if KN018 == 4
replace MC_HMO = . 				 if (KN018 == 7 | KN018 == 8 | KN018 == 9) & (MC_HMO!=0)

gen MC_B = 88.5 if (KN004 == 1 & KN005 != 1 & KN007 != 1)		//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2011/2b-2c.html#table2.c1

gen MC_D = KN404
replace_mi MC_D 9998 9999
replace MC_D = 0 if (MC_D == 9996) //"9996: Not Ascertained; Amount included in N014 or N040" (N014 is MC HMO; N040 is private insurance)

gen private_medigap_1 = KN040_1
replace_mi private_medigap_1  9998 9999

gen private_medigap_2 = KN040_2
replace_mi private_medigap_2  9998 9999

gen private_medigap_3 = KN040_3
replace_mi private_medigap_3  9998 9999

gen long_term_care = KN079
replace_mi long_term_care 999998 999999
replace long_term_care = 0 if (long_term_care == 999995)

replace long_term_care = 1                 * long_term_care if (KN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (KN083 == 2)
replace long_term_care = 4                 * long_term_care if (KN083 == 3)
replace long_term_care = (1/12)            * long_term_care if (KN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (KN083 == 6)
replace long_term_care = . if (KN083 == 7 | KN083 == 8 | KN083 == 9) & (long_term_care!=0)

gen hospital_OOP = KN106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = KN119
replace_mi NH_OOP 9999998 9999999

gen patient_OOP = KN139
replace_mi patient_OOP 9999998 9999999

gen doctor_OOP = KN156
replace_mi doctor_OOP 9999998 9999999

gen dental_OOP = KN168
replace_mi dental_OOP 9999998 9999999

gen RX_OOP = KN180
replace_mi RX_OOP 99998 99999

gen home_OOP = KN194
replace_mi home_OOP 999998 999999

gen special_OOP = KN239
replace_mi special_OOP 9999998 9999999

*summarize
*fsum MC_HMO MC_D private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO MC_D private_medigap_* long_term_care *_OOP

*caps

scalar z = cpi2006/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap MC_D ${MC_D_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(KN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  



save $savedir/core2006_oop.dta, replace




********************************************************************************

use $savedir/core2008.dta, clear
merge 1:1 HHID PN using $savedir/core2008_months.dta, nogen keep(match)

gen MC_HMO = LN014
replace_mi MC_HMO 998 999

replace MC_HMO = 1      * MC_HMO if LN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if LN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if LN018 == 3
replace MC_HMO = (1/12) * MC_HMO if LN018 == 4
replace MC_HMO = . 				 if (LN018 == 7 | LN018 == 8 | LN018 == 9) & (MC_HMO!=0)

//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2007/medicare.html#partBtable
gen MC_B = 96.4 if (LN004 == 1 & LN005 != 1 & LN007 != 1)		

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r9mstat!=1 & r9mstat!=2 & h9itot<=82000
replace MC_B_adjustment = 25.80  if r9mstat!=1 & r9mstat!=2 & h9itot>82000  & h9itot<=102000
replace MC_B_adjustment = 64.50  if r9mstat!=1 & r9mstat!=2 & h9itot>102000 & h9itot<=153000
replace MC_B_adjustment = 103.30 if r9mstat!=1 & r9mstat!=2 & h9itot>153000 & h9itot<=205000
replace MC_B_adjustment = 142.00 if r9mstat!=1 & r9mstat!=2 & h9itot>205000 & h9itot<.

*Married, filing jointly (we assume all married respondents file jointly)
replace MC_B_adjustment = 0      if (r9mstat==1 | r9mstat==2) & h9itot<=164000
replace MC_B_adjustment = 25.80  if (r9mstat==1 | r9mstat==2) & h9itot>164000 & h9itot<=204000
replace MC_B_adjustment = 64.50  if (r9mstat==1 | r9mstat==2) & h9itot>204000 & h9itot<=306000
replace MC_B_adjustment = 103.30 if (r9mstat==1 | r9mstat==2) & h9itot>306000 & h9itot<=401000
replace MC_B_adjustment = 142.00 if (r9mstat==1 | r9mstat==2) & h9itot>401000 & h9itot<.

replace MC_B = MC_B + MC_B_adjustment if !missing(MC_B,MC_B_adjustment)

gen MC_D_1 = LN424		//monthly ss deduction
replace_mi MC_D_1 9998 9999
replace MC_D_1 = 0 if MC_D_1 == 9996	//Not Ascertained; Amount included in N014 or N040

gen MC_D_2 = LN404		//monthly direct payment
replace_mi MC_D_2 9998 9999
replace MC_D_2 = 0 if MC_D_2 == 9996	//Not Ascertained; Amount included in N014 or N040

egen MC_D = rowtotal( MC_D_1 MC_D_2 ), missing
drop MC_D_1 MC_D_2

gen private_medigap_1 = LN040_1
replace_mi private_medigap_1  99998 99999

gen private_medigap_2 = LN040_2
replace_mi private_medigap_2  99998 99999

gen private_medigap_3 = LN040_3
replace_mi private_medigap_3  9998 9999

gen long_term_care = LN079
replace_mi long_term_care 999998 999999
replace long_term_care = 0 if (long_term_care == 999995)

replace long_term_care = 1                 * long_term_care if (LN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (LN083 == 2)
replace long_term_care = 4                 * long_term_care if (LN083 == 3)
replace long_term_care = (1/12)            * long_term_care if (LN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (LN083 == 6)
replace long_term_care = . if (LN083 == 7 | LN083 == 8 | LN083 == 9) & (long_term_care!=0)

gen hospital_OOP = LN106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = LN119
replace_mi NH_OOP 9999998 9999999

gen patient_OOP = LN139
replace_mi patient_OOP 9999998 9999999

gen doctor_OOP = LN156
replace_mi doctor_OOP 9999998 9999999

gen dental_OOP = LN168
replace_mi dental_OOP 9999998 9999999

gen RX_OOP = LN180
replace_mi RX_OOP 99998 99999

gen home_OOP = LN194
replace_mi home_OOP 999998 999999

gen special_OOP = LN239
replace_mi special_OOP 9999998 9999999

*summarize
*fsum MC_HMO MC_D private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO MC_D private_medigap_* long_term_care *_OOP

*caps

scalar z = cpi2008/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap MC_D ${MC_D_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(LN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  


save $savedir/core2008_oop.dta, replace




********************************************************************************

use $savedir/core2010.dta, clear
merge 1:1 HHID PN using $savedir/core2010_months.dta, nogen keep(match)

gen MC_HMO_1 = MN266		//monthly ss deduction
replace_mi MC_HMO_1 9998 9999

gen MC_HMO_2 = MN014		//direct payment
replace_mi MC_HMO_2 9998 9999

replace MC_HMO_2 = 1      * MC_HMO_2 if MN018 == 1
replace MC_HMO_2 = (1/3)  * MC_HMO_2 if MN018 == 2
replace MC_HMO_2 = (1/6)  * MC_HMO_2 if MN018 == 3
replace MC_HMO_2 = (1/12) * MC_HMO_2 if MN018 == 4
replace MC_HMO_2 = . 				 if (MN018 == 7 | MN018 == 8 | MN018 == 9) & (MC_HMO_2!=0)

egen MC_HMO = rowtotal( MC_HMO_1 MC_HMO_2 ),m
drop MC_HMO_1 MC_HMO_2

gen MC_B = 96.4 if (MN004 == 1 & MN005 != 1 & MN007 != 1)		//rrd: inconsistency, using prior prem only here

*Income Adjustments for 2008-2010

*Using RAND HRS ver. L income (hXitot) & marital status (rXmstat), calculate adjustments:
*NOTE: Wave 10 income data is for 2009, so we use 2009 income cutoffs from SSA.

*Sources:
*http://www.ssa.gov/policy/docs/statcomps/supplement/2011/2b-2c.html#table2.c1
*http://www.ssa.gov/policy/docs/statcomps/supplement/2009/medicare.html#partBtable
//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2008/medicare.html#partBtable

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r10mstat!=1 & r10mstat!=2 & h10itot<=85000
replace MC_B_adjustment = 38.50  if r10mstat!=1 & r10mstat!=2 & h10itot>85000  & h10itot<=107000
replace MC_B_adjustment = 96.30  if r10mstat!=1 & r10mstat!=2 & h10itot>107000 & h10itot<=160000
replace MC_B_adjustment = 154.10 if r10mstat!=1 & r10mstat!=2 & h10itot>160000 & h10itot<=213000
replace MC_B_adjustment = 211.90 if r10mstat!=1 & r10mstat!=2 & h10itot>213000 & h10itot<.

*Married, filing jointly (we assume all married respondents file jointly)
replace MC_B_adjustment = 0      if (r10mstat==1 | r10mstat==2) & h10itot<=170000
replace MC_B_adjustment = 38.50  if (r10mstat==1 | r10mstat==2) & h10itot>170000 & h10itot<=214000
replace MC_B_adjustment = 96.30  if (r10mstat==1 | r10mstat==2) & h10itot>214000 & h10itot<=320000
replace MC_B_adjustment = 154.10 if (r10mstat==1 | r10mstat==2) & h10itot>320000 & h10itot<=426000
replace MC_B_adjustment = 211.90 if (r10mstat==1 | r10mstat==2) & h10itot>426000 & h10itot<.

replace MC_B = MC_B + MC_B_adjustment if !missing(MC_B,MC_B_adjustment)

tab MC_B

gen MC_D_1 = MN424		//monthly ss deduction
replace_mi MC_D_1 9998 9999
replace MC_D_1 = 0 if MC_D_1 == 9996	//Not Ascertained; Amount included in N014 or N040

gen MC_D_2 = MN404		//monthly direct payment
replace_mi MC_D_2 9998 9999
replace MC_D_2 = 0 if MC_D_2 == 9996	//Not Ascertained; Amount included in N014 or N040

egen MC_D = rowtotal( MC_D_1 MC_D_2 ), missing
drop MC_D_1 MC_D_2

gen private_medigap_1 = MN040_1
replace_mi private_medigap_1  99998 99999

gen private_medigap_2 = MN040_2
replace_mi private_medigap_2  99998 99999

gen private_medigap_3 = MN040_3
replace_mi private_medigap_3  99998 99999

gen long_term_care = MN079
replace_mi long_term_care 999998 999999
replace long_term_care = 0 if (long_term_care == 999995)

replace long_term_care = 1                 * long_term_care if (MN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (MN083 == 2)
replace long_term_care = 4                 * long_term_care if (MN083 == 3)
replace long_term_care = (1/12)            * long_term_care if (MN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (MN083 == 6)
replace long_term_care = . if (MN083 == 7 | MN083 == 8 | MN083 == 9) & (long_term_care!=0)

gen hospital_OOP = MN106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = MN119
replace_mi NH_OOP 9999998 9999999

gen patient_OOP = MN139
replace_mi patient_OOP 9999998 9999999

gen doctor_OOP = MN156
replace_mi doctor_OOP 9999998 9999999

gen dental_OOP = MN168
replace_mi dental_OOP 9999998 9999999

gen RX_OOP = MN180
replace_mi RX_OOP 99998 99999

gen home_OOP = MN194
replace_mi home_OOP 999998 999999

gen special_OOP = MN239
replace_mi special_OOP 9999998 9999999

gen other_OOP = MN333
replace_mi other_OOP 999998 999999

*summarize
*fsum MC_HMO MC_D private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO MC_D private_medigap_* long_term_care *_OOP
*caps

scalar z = cpi2010/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap MC_D ${MC_D_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(MN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  
upp_cap other_OOP ${other_OOP_cap}*z*months 


save $savedir/core2010_oop.dta, replace


********************************************************************************

use $savedir/core2012.dta, clear
merge 1:1 HHID PN using $savedir/core2012_months.dta, nogen keep(match)

*gen MC_HMO_1 = NN266		//in 2012 this doesnt exist, revert to 2008 formatt on this
*replace MC_HMO_1 = . if (MC_HMO_1 == 9998 | MC_HMO_1 == 9999)

gen MC_HMO = NN014
replace_mi MC_HMO 998 999

replace MC_HMO = 1      * MC_HMO if NN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if NN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if NN018 == 3
replace MC_HMO = (1/12) * MC_HMO if NN018 == 4
replace MC_HMO = . 				 if (NN018 == 7 | NN018 == 8 | NN018 == 9) & (MC_HMO!=0)

*egen MC_HMO = rowtotal( MC_HMO_1 MC_HMO_2 ),m
*drop MC_HMO_1 MC_HMO_2

//rrd: as before, using prior wave of rules/prems (2011)
//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2010/medicare.html#partBtable
//rrd: NOT ONTROLING FOR HOLD HARMLESS, IE IS UPPER BOUND
gen MC_B = 115.40 if (NN004 == 1 & NN005 != 1 & NN007 != 1)  //rrd: recall only if not covered by other govt

*Income Adjustments for 2008-2010
//rrd: update to 2012
*Using RAND HRS ver. L income (hXitot) & marital status (rXmstat), calculate adjustments:
*NOTE: Wave 10 income data is for 2009, so we use 2009 income cutoffs from SSA.

*Sources:
*http://www.ssa.gov/policy/docs/statcomps/supplement/2011/2b-2c.html#table2.c1
*http://www.ssa.gov/policy/docs/statcomps/supplement/2009/medicare.html#partBtable

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r10mstat!=1 & r10mstat!=2 & h10itot<=85000						//rrd: correct these to 12 when RANDHRS updated
replace MC_B_adjustment = 46.10  if r10mstat!=1 & r10mstat!=2 & h10itot>85000  & h10itot<=107000
replace MC_B_adjustment = 115.30 if r10mstat!=1 & r10mstat!=2 & h10itot>107000 & h10itot<=160000
replace MC_B_adjustment = 184.50 if r10mstat!=1 & r10mstat!=2 & h10itot>160000 & h10itot<=214000
replace MC_B_adjustment = 253.70 if r10mstat!=1 & r10mstat!=2 & h10itot>214000 & h10itot<.

*Married, filing jointly (we assume all married respondents file jointly)
replace MC_B_adjustment = 0      if (r10mstat==1 | r10mstat==2) & h10itot<=170000
replace MC_B_adjustment = 46.10  if (r10mstat==1 | r10mstat==2) & h10itot>170000 & h10itot<=214000
replace MC_B_adjustment = 115.30 if (r10mstat==1 | r10mstat==2) & h10itot>214000 & h10itot<=320000
replace MC_B_adjustment = 184.50 if (r10mstat==1 | r10mstat==2) & h10itot>320000 & h10itot<=428000
replace MC_B_adjustment = 253.70 if (r10mstat==1 | r10mstat==2) & h10itot>428000 & h10itot<.

replace MC_B = MC_B + MC_B_adjustment if !missing(MC_B,MC_B_adjustment)

tab MC_B

//rrd: following doesnt exist in 2012, see 2006
/*gen MC_D_1 = NN424		//monthly ss deduction  
replace MC_D_1 = . if (MC_D_1 == 9998 | MC_D_1 == 9999)
replace MC_D_1 = 0 if MC_D_1 == 9996	//Not Ascertained; Amount included in N014 or N040

gen MC_D_2 = NN404		//monthly direct payment
replace MC_D_2 = . if (MC_D_2 == 9998 | MC_D_2 == 9999)
replace MC_D_2 = 0 if MC_D_2 == 9996	//Not Ascertained; Amount included in N014 or N040

egen MC_D = rowtotal( MC_D_1 MC_D_2 ), missing
drop MC_D_1 MC_D_2
*/
gen MC_D = NN404
replace_mi MC_D 9998 9999

gen private_medigap_1 = NN040_1
replace_mi private_medigap_1  99998 99999

gen private_medigap_2 = NN040_2
replace_mi private_medigap_2  99998 99999

gen private_medigap_3 = NN040_3
replace_mi private_medigap_3  99998 99999

gen long_term_care = NN079
replace_mi long_term_care 999998 999999

replace long_term_care = 1                 * long_term_care if (NN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (NN083 == 2)
*replace long_term_care = 4                 * long_term_care if (NN083 == 3)
replace long_term_care = (1/12)            * long_term_care if (NN083 == 4)
*replace long_term_care = ((1/20) * (1/12)) * long_term_care if (NN083 == 6)
replace long_term_care = . if (NN083 == 7 | NN083 == 8 | NN083 == 9) & (long_term_care!=0)

gen hospital_OOP = NN106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = NN119
replace_mi NH_OOP 9999998 9999999

gen patient_OOP = NN139
replace_mi patient_OOP 9999998 9999999

gen doctor_OOP = NN156
replace_mi doctor_OOP 9999998 9999999

gen dental_OOP = NN168
replace_mi dental_OOP 9999998 9999999

gen RX_OOP = NN180
replace_mi RX_OOP 99998 99999

gen home_OOP = NN194
replace_mi home_OOP 999998 999999

gen special_OOP = NN239
replace_mi special_OOP 9999998 9999999

gen other_OOP = NN333
replace_mi other_OOP 999998 999999

*summarize
*fsum MC_HMO MC_D private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO MC_D private_medigap_* long_term_care *_OOP
*caps

scalar z = cpi2012/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap MC_D ${MC_D_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(NN001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  
upp_cap other_OOP ${other_OOP_cap}*z*months 

save $savedir/core2012_oop.dta, replace

********************************************************************************


use $savedir/core2014.dta, clear
merge 1:1 HHID PN using $savedir/core2014_months.dta, nogen keep(match)

*gen MC_HMO_1 = NN266		//in 2012 this doesnt exist, revert to 2008 formatt on this
*replace MC_HMO_1 = . if (MC_HMO_1 == 9998 | MC_HMO_1 == 9999)

gen MC_HMO = ON014
replace_mi MC_HMO 998 999

replace MC_HMO = 1      * MC_HMO if ON018 == 1
replace MC_HMO = (1/3)  * MC_HMO if ON018 == 2
replace MC_HMO = (1/6)  * MC_HMO if ON018 == 3
replace MC_HMO = (1/12) * MC_HMO if ON018 == 4
replace MC_HMO = . 				 if (ON018 == 7 | ON018 == 8 | ON018 == 9) & (MC_HMO!=0)

*egen MC_HMO = rowtotal( MC_HMO_1 MC_HMO_2 ),m
*drop MC_HMO_1 MC_HMO_2

//rrd: as before, using prior wave of rules/prems (2011)
//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2010/medicare.html#partBtable
//rrd: NOT ONTROLING FOR HOLD HARMLESS, IE IS UPPER BOUND
gen MC_B = 115.40 if (ON004 == 1 & ON005 != 1 & ON007 != 1)  //rrd: recall only if not covered by other govt

*Income Adjustments for 2008-2010
//rrd: update to 2012
*Using RAND HRS ver. L income (hXitot) & marital status (rXmstat), calculate adjustments:
*NOTE: Wave 10 income data is for 2009, so we use 2009 income cutoffs from SSA.

*Sources:
*http://www.ssa.gov/policy/docs/statcomps/supplement/2011/2b-2c.html#table2.c1
*http://www.ssa.gov/policy/docs/statcomps/supplement/2009/medicare.html#partBtable

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r10mstat!=1 & r10mstat!=2 & h10itot<=85000						//rrd: correct these to 12 when RANDHRS updated
replace MC_B_adjustment = 42.00  if r10mstat!=1 & r10mstat!=2 & h10itot>85000  & h10itot<=107000
replace MC_B_adjustment = 104.90 if r10mstat!=1 & r10mstat!=2 & h10itot>107000 & h10itot<=160000
replace MC_B_adjustment = 167.80 if r10mstat!=1 & r10mstat!=2 & h10itot>160000 & h10itot<=214000
replace MC_B_adjustment = 230.80 if r10mstat!=1 & r10mstat!=2 & h10itot>214000 & h10itot<.

*Married, filing jointly (we assume all married respondents file jointly)
replace MC_B_adjustment = 0      if (r10mstat==1 | r10mstat==2) & h10itot<=170000
replace MC_B_adjustment = 42.000  if (r10mstat==1 | r10mstat==2) & h10itot>170000 & h10itot<=214000
replace MC_B_adjustment = 104.90 if (r10mstat==1 | r10mstat==2) & h10itot>214000 & h10itot<=320000
replace MC_B_adjustment = 167.80 if (r10mstat==1 | r10mstat==2) & h10itot>320000 & h10itot<=428000
replace MC_B_adjustment = 230.80 if (r10mstat==1 | r10mstat==2) & h10itot>428000 & h10itot<.

replace MC_B = MC_B + MC_B_adjustment if !missing(MC_B,MC_B_adjustment)

tab MC_B

//rrd: following doesnt exist in 2012, see 2006
/*gen MC_D_1 = NN424		//monthly ss deduction  
replace MC_D_1 = . if (MC_D_1 == 9998 | MC_D_1 == 9999)
replace MC_D_1 = 0 if MC_D_1 == 9996	//Not Ascertained; Amount included in N014 or N040

gen MC_D_2 = NN404		//monthly direct payment
replace MC_D_2 = . if (MC_D_2 == 9998 | MC_D_2 == 9999)
replace MC_D_2 = 0 if MC_D_2 == 9996	//Not Ascertained; Amount included in N014 or N040

egen MC_D = rowtotal( MC_D_1 MC_D_2 ), missing
drop MC_D_1 MC_D_2
*/
gen MC_D = ON404
replace_mi MC_D 9998 9999

gen private_medigap_1 = ON040_1
replace_mi private_medigap_1  99998 99999

gen private_medigap_2 = ON040_2
replace_mi private_medigap_2  99998 99999

gen private_medigap_3 = ON040_3
replace_mi private_medigap_3  99998 99999

gen long_term_care = ON079
replace_mi long_term_care 999998 999999

replace long_term_care = 1                 * long_term_care if (ON083 == 1)
replace long_term_care = (1/3)             * long_term_care if (ON083 == 2)
*replace long_term_care = 4                 * long_term_care if (ON083 == 3)
replace long_term_care = (1/12)            * long_term_care if (ON083 == 4)
*replace long_term_care = ((1/20) * (1/12)) * long_term_care if (ON083 == 6)
replace long_term_care = . if (ON083 == 7 | ON083 == 8 | ON083 == 9) & (long_term_care!=0)

gen hospital_OOP = ON106
replace_mi hospital_OOP 9999998 9999999

gen NH_OOP = ON119
replace_mi NH_OOP 9999998 9999999

gen patient_OOP = ON139
replace_mi patient_OOP 9999998 9999999

gen doctor_OOP = ON156
replace_mi doctor_OOP 9999998 9999999

gen dental_OOP = ON168
replace_mi dental_OOP 9999998 9999999

gen RX_OOP = ON180
replace_mi RX_OOP 99998 99999

gen home_OOP = ON194
replace_mi home_OOP 999998 999999

gen special_OOP = ON239
replace_mi special_OOP 9999998 9999999

gen other_OOP = ON333
replace_mi other_OOP 999998 999999

*summarize
*fsum MC_HMO MC_D private_medigap_* long_term_care *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)
*sum MC_HMO MC_D private_medigap_* long_term_care *_OOP
*caps

scalar z = cpi2014/cpiBASE

upp_cap MC_HMO ${MC_HMO_cap}*z 
upp_cap MC_D ${MC_D_cap}*z 
forvalues pm=1/3{
	upp_cap private_medigap_`pm' cond(ON001==1,${private_medigap_wMC_cap}*z,${private_medigap_nMC_cap}*z)
}
upp_cap long_term_care ${long_term_care_cap}*z 
upp_cap hospital_OOP ${hospital_OOP_cap}*z*months 
upp_cap NH_OOP ${NH_OOP_cap}*z*months 
upp_cap patient_OOP ${patient_OOP_cap}*z*months 
upp_cap doctor_OOP ${doctor_OOP_cap}*z*months 
upp_cap dental_OOP ${dental_OOP_cap}*z*months 
upp_cap RX_OOP ${RX_OOP_cap}*z 
upp_cap home_OOP ${home_OOP_cap}*z*months  
upp_cap special_OOP ${special_OOP_cap}*z*months  
upp_cap other_OOP ${other_OOP_cap}*z*months 

save $savedir/core2014_oop.dta, replace

********************************************************************************
/*
use $savedir/core1992_oop.dta, clear
keep HHID PN year private_ltc
save $savedir/tmp1992.dta, replace

use $savedir/core1993_oop.dta, clear
keep HHID PN year private_ltc NH_OOP93 non_NH_OOP93
save $savedir/tmp1993.dta, replace

use $savedir/core1994_oop.dta, clear
keep HHID PN year private_medigap_* hospital_NH_doctor_OOP RX_OOP
save $savedir/tmp1994.dta, replace

use $savedir/core1995_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1995.dta, replace

use $savedir/core1996_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1996.dta, replace
*/
use $savedir/core1998_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp1998.dta, replace

use $savedir/core2000_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP
save $savedir/tmp2000.dta, replace

use $savedir/core2002_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2002.dta, replace

use $savedir/core2004_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2004.dta, replace

use $savedir/core2006_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2006.dta, replace

use $savedir/core2008_oop.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP
save $savedir/tmp2008.dta, replace

use $savedir/core2010_oop.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2010.dta, replace

use $savedir/core2012_oop.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2012.dta, replace

use $savedir/core2014_oop.dta, clear
keep HHID PN year MC_HMO MC_D private_medigap_* long_term_care RX_OOP hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP other_OOP
save $savedir/tmp2014.dta, replace

use $savedir/tmp1998.dta, clear
append using ///
/*$savedir/tmp1993.dta ///
$savedir/tmp1994.dta ///
$savedir/tmp1995.dta ///
$savedir/tmp1996.dta ///
*/$savedir/tmp1998.dta ///
$savedir/tmp2000.dta ///
$savedir/tmp2002.dta ///
$savedir/tmp2004.dta ///
$savedir/tmp2006.dta ///
$savedir/tmp2008.dta ///
$savedir/tmp2010.dta ///
$savedir/tmp2012.dta ///
$savedir/tmp2014.dta

save $savedir/core_oop.dta, replace
/*
rm $savedir/tmp1992.dta
rm $savedir/tmp1993.dta
rm $savedir/tmp1994.dta
rm $savedir/tmp1995.dta
rm $savedir/tmp1996.dta*/
rm $savedir/tmp1998.dta
rm $savedir/tmp2000.dta
rm $savedir/tmp2002.dta
rm $savedir/tmp2004.dta
rm $savedir/tmp2006.dta
rm $savedir/tmp2008.dta
rm $savedir/tmp2010.dta
rm $savedir/tmp2012.dta
rm $savedir/tmp2014.dta
