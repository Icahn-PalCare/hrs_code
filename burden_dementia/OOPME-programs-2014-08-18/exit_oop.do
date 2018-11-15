
********************************************************************************

use $savedir/exit1995.dta, clear
merge 1:1 HHID PN using $savedir/exit1995_months.dta, nogen keep(match)

*amount, set to missing if DK/NA/RF:
gen MC_HMO = N5324
replace MC_HMO = . if (MC_HMO == 99997 | MC_HMO == 99998 | MC_HMO == 99999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if N5325 == 1 //month
replace MC_HMO = (1/3)  * MC_HMO if N5325 == 2 //quarter
replace MC_HMO = (1/12) * MC_HMO if N5325 == 3 //year
replace MC_HMO = 0      * MC_HMO if N5325 == 4 //no premium
replace MC_HMO = . 				 if (N5325 == 7 | N5325 == 8 | N5325 == 9) & ///
									(MC_HMO!=0)

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 46.1 if (N5276 == 1 & N5286 != 1 & N5306 != 1)

*Other Insurance #1 (not counting LTC, Medicaid, other government health insurance)

*amount, set DK/NA/RF to missing:
gen private_medigap_1 = N5352
replace private_medigap_1  = . if (private_medigap_1== 99998 | private_medigap_1== 99999)

*convert payment periodicity to monthly:
replace private_medigap_1 = 1      * private_medigap_1 if (N5353 == 1)	//month
replace private_medigap_1 = (1/3)  * private_medigap_1 if (N5353 == 2)	//quarter
replace private_medigap_1 = (1/12) * private_medigap_1 if (N5353 == 3)	//year
replace private_medigap_1 = 0      * private_medigap_1 if (N5353 == 5)	//no premiums
replace private_medigap_1 = . if (N5353==7 | N5353==8 | N5353==9) & ///
								 (private_medigap_1 != 0)
								 
*Other Insurance #2

*amount, set DK/NA/RF to missing:
gen private_medigap_2 = N5364
replace private_medigap_2  = . if (private_medigap_2== 99997 | private_medigap_2== 99998 | private_medigap_2== 99999)

*convert payment periodicity to monthly:
replace private_medigap_2 = 1      * private_medigap_2 if (N5365 == 1)	//month
replace private_medigap_2 = (1/3)  * private_medigap_2 if (N5365 == 2)	//quarter
replace private_medigap_2 = (1/12) * private_medigap_2 if (N5365 == 3)	//year
replace private_medigap_2 = 0      * private_medigap_2 if (N5365 == 5)	//no premiums
replace private_medigap_2 = . if (N5365==7 | N5365==8 | N5365==9) & ///
								 (private_medigap_2 != 0)

//No LTC premiums in this wave

gen hospital_NH_OOP = N1688
replace hospital_NH_OOP = . if (hospital_NH_OOP == 999998 | hospital_NH_OOP == 999999)

gen doctor_OOP = N1732				//rrd: question labeled doctor patient detal, but wording says doctor
replace doctor_OOP = . if (doctor_OOP == 99998 | doctor_OOP == 99999)

gen hospice_OOP = N1703
replace hospice_OOP = . if (hospice_OOP == 9998 | hospice_OOP == 9999)

gen RX_OOP = N1749
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_special_OOP = N1781
replace home_special_OOP = . if (home_special_OOP == 99998 | home_special_OOP == 99999)

gen other_OOP = N1792
replace other_OOP = . if (other_OOP == 99998 | other_OOP == 99999)							  

gen non_med_OOP = N1805
replace non_med_OOP = . if (non_med_OOP == 99998 | non_med_OOP == 99999)

*summarize
*fsum MC_HMO private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi1995/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(N5275==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(N5275==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_special_OOP = min( 30000*z* months , home_special_OOP ) if !missing(home_special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit1995_oop.dta, replace

********************************************************************************

use $savedir/exit1996.dta, clear
merge 1:1 HHID PN using $savedir/exit1996_months.dta, nogen keep(match)

*amount, set to missing if DK/NA/RF:
gen MC_HMO = P2216
replace MC_HMO = . if (MC_HMO == 99998 | MC_HMO == 99999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if P2217 == 1 //month
replace MC_HMO = (1/3)  * MC_HMO if P2217 == 2 //quarter
replace MC_HMO = (1/12) * MC_HMO if P2217 == 3 //year
replace MC_HMO = 0      * MC_HMO if P2217 == 4 //no premium
replace MC_HMO = . 				 if (P2217 == 7 | P2217 == 8 | P2217 == 9) & ///
									(MC_HMO!=0)

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 42.5 if (P2167 == 1 & P2177 != 1 & P2198 != 1)

*Other Insurance #1 (not counting LTC, Medicaid, other government health insurance)

*amount, set DK/NA/RF to missing:
gen private_medigap_1 = P2244
replace private_medigap_1  = . if (private_medigap_1== 99998 | private_medigap_1== 99999)

*convert payment periodicity to monthly:
replace private_medigap_1 = 1      * private_medigap_1 if (P2245 == 1)	//month
replace private_medigap_1 = (1/3)  * private_medigap_1 if (P2245 == 2)	//quarter
replace private_medigap_1 = (1/12) * private_medigap_1 if (P2245 == 3)	//year
replace private_medigap_1 = 0      * private_medigap_1 if (P2245 == 5)	//no premiums
replace private_medigap_1 = . if (P2245==7 | P2245==8 | P2245==9) & ///
								 (private_medigap_1 != 0)
								 
*Other Insurance #2

*amount, set DK/NA/RF to missing:
gen private_medigap_2 = P2256
replace private_medigap_2  = . if (private_medigap_2== 99998 | private_medigap_2== 99999)

*convert payment periodicity to monthly:
replace private_medigap_2 = 1      * private_medigap_2 if (P2257 == 1)	//month
replace private_medigap_2 = (1/3)  * private_medigap_2 if (P2257 == 2)	//quarter
replace private_medigap_2 = (1/12) * private_medigap_2 if (P2257 == 3)	//year
replace private_medigap_2 = 0      * private_medigap_2 if (P2257 == 5)	//no premiums
replace private_medigap_2 = . if (P2257==7 | P2257==8 | P2257==9) & ///
								 (private_medigap_2 != 0)

//No LTC premiums in this wave

gen hospital_NH_OOP = P1269
replace hospital_NH_OOP = . if (hospital_NH_OOP == 999998 | hospital_NH_OOP == 999999)

gen doctor_OOP = P1313
replace doctor_OOP = . if (doctor_OOP == 99998 | doctor_OOP == 99999)

gen hospice_OOP = P1284
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

gen RX_OOP = P1330
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_special_OOP = P1362
replace home_special_OOP = . if (home_special_OOP == 99998 | home_special_OOP == 99999)

gen other_OOP = P1373
replace other_OOP = . if (other_OOP == 99998 | other_OOP == 99999)							  

gen non_med_OOP = P1386
replace non_med_OOP = . if (non_med_OOP == 99998 | non_med_OOP == 99999)

*summarize
*fsum MC_HMO private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi1996/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(P2166==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(P2166==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_special_OOP = min( 30000*z* months , home_special_OOP ) if !missing(home_special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit1996_oop.dta, replace

********************************************************************************

use $savedir/exit1998.dta, clear
merge 1:1 HHID PN using $savedir/exit1998_months.dta, nogen keep(match)

*amount, set to missing if DK/NA/RF:
gen MC_HMO = Q2579
replace MC_HMO = . if (MC_HMO == 9998 | MC_HMO == 9999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if Q2580 == 1
replace MC_HMO = (1/3)  * MC_HMO if Q2580 == 2
replace MC_HMO = (1/6)  * MC_HMO if Q2580 == 3
replace MC_HMO = (1/12) * MC_HMO if Q2580 == 4
replace MC_HMO = . 				 if (Q2580 == 7 | Q2580 == 8 | Q2580 == 9) & ///
									(MC_HMO!=0)

* makes the Medicare part B coverage variable for those whose costs are 
* not (known to be) covered by medicaid / champus VA
* Source: http://www.law.umaryland.edu/marshall/crsreports/crsdocuments/rl32582.pdf

gen MC_B = 43.8 if (Q2561 == 1 & Q2562 != 1 & Q2572 != 1)

*Employer-Provided

*amount, set DK/NA/RF to missing:
gen private_medigap_1 = Q2592
replace private_medigap_1  = . if (private_medigap_1== 9998 | private_medigap_1== 9999)

*convert payment periodicity to monthly:
replace private_medigap_1 = (1/12) * private_medigap_1 if (Q2593 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (Q2593 == 2)
replace private_medigap_1 = (1/2)  * private_medigap_1 if (Q2593 == 3)
replace private_medigap_1 = 1      * private_medigap_1 if (Q2593 == 4)
replace private_medigap_1 = 4      * private_medigap_1 if (Q2593 == 5)
replace private_medigap_1 = 2      * private_medigap_1 if (Q2593 == 6)
replace private_medigap_1 = (1/6)  * private_medigap_1 if (Q2593 == 7)
replace private_medigap_1 = 2      * private_medigap_1 if (Q2593 == 8)
replace private_medigap_1 = . if (Q2593==97 | Q2593==98 | Q2593==99) & ///
								 (private_medigap_1 != 0)
								 
*Other insurance

/*
                  Not counting long-term care insurance or Medicare
                  or any other insurance we've discussed, did (he/she) have any
                  additional insurance that pays any part of hospital or doctor
                  bills?  Sometimes this is called a Medigap or Medicare
                  Supplement policy.
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_2 = Q2612
replace private_medigap_2  = . if (private_medigap_2== 999998 | private_medigap_2== 999999)

*convert payment periodicity to monthly:
replace private_medigap_2 = 1      * private_medigap_2 if (Q2613 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (Q2613 == 2)
replace private_medigap_2 = (1/6)  * private_medigap_2 if (Q2613 == 3)
replace private_medigap_2 = (1/12) * private_medigap_2 if (Q2613 == 4)
replace private_medigap_2 = . if (Q2613 == 7 | Q2613 == 8 | Q2613 == 9) & ///
								 (private_medigap_2 != 0)
								 
*Other insurance

/*
                  Did (he/she) have any basic health insurance coverage
                  purchased directly from an insurance company or
                  through a membership organization?

                  INSURANCE FROM ORGANIZATIONS SUCH AS AARP OR
                  PROFESSIONAL ORGANIZATIONS, OR FROM STATE OR HEALTH
                  ALLIANCES ARE EXAMPLES OF SUCH INSURANCE.
*/

*amount, set DK/NA/RF to missing:
gen private_medigap_3 = Q2624
replace private_medigap_3  = . if (private_medigap_3== 999998 | private_medigap_3== 999999)

*convert payment periodicity to monthly:
replace private_medigap_3 = 1      * private_medigap_3 if (Q2625 == 1)
replace private_medigap_3 = (1/3)  * private_medigap_3 if (Q2625 == 2)
replace private_medigap_3 = (1/6)  * private_medigap_3 if (Q2625 == 3)
replace private_medigap_3 = (1/12) * private_medigap_3 if (Q2625 == 4)
replace private_medigap_3 = . if (Q2625 == 7 | Q2625 == 8 | Q2625 == 9) & ///
								 (private_medigap_3 != 0)

gen long_term_care = Q2668
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: Q2669==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = (1/12)            * long_term_care if (Q2669 == 1)
replace long_term_care = (1/3)             * long_term_care if (Q2669 == 2)
replace long_term_care = 1                 * long_term_care if (Q2669 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (Q2669 == 6)
replace long_term_care = . if (Q2669 == 7 | Q2669 == 8 | Q2669 == 9) & ///
							  (long_term_care!=0)
							  
gen hospital_NH_OOP = Q1749
replace hospital_NH_OOP = . if (hospital_NH_OOP == 9999998 | hospital_NH_OOP == 9999999)

gen doctor_OOP = Q1784
replace doctor_OOP = . if (doctor_OOP == 999998 | doctor_OOP == 999999)

gen hospice_OOP = Q1770
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

gen RX_OOP = Q1794
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_special_OOP = Q1811
replace home_special_OOP = . if (home_special_OOP == 999998 | home_special_OOP == 999999)

gen other_OOP = Q1818
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)							  

gen non_med_OOP = Q1844
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi1998/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(Q2560==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(Q2560==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(Q2560==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_special_OOP = min( 30000*z* months , home_special_OOP ) if !missing(home_special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit1998_oop.dta, replace




********************************************************************************

use $savedir/exit2000.dta, clear
merge 1:1 HHID PN using $savedir/exit2000_months.dta, nogen keep(match)

gen MC_HMO = R2605
replace MC_HMO = . if (MC_HMO == 9998 | MC_HMO == 9999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if R2606 == 1
replace MC_HMO = (1/3)  * MC_HMO if R2606 == 2
replace MC_HMO = (1/6)  * MC_HMO if R2606 == 3
replace MC_HMO = (1/12) * MC_HMO if R2606 == 4
replace MC_HMO = . 				 if (R2606 == 7 | R2606 == 8 | R2606 == 9) & ///
									(MC_HMO!=0)

gen MC_B = 45.6 if (R2587 == 1 & R2588 != 1 & R2598 != 1)
									
gen private_medigap_1 = R2620
replace private_medigap_1  = . if (private_medigap_1== 9998 | private_medigap_1== 9999)

*convert payment periodicity to monthly:
replace private_medigap_1 = (1/12) * private_medigap_1 if (R2621 == 1)
replace private_medigap_1 = (1/3)  * private_medigap_1 if (R2621 == 2)
replace private_medigap_1 = (1/2)  * private_medigap_1 if (R2621 == 3)
replace private_medigap_1 = 1      * private_medigap_1 if (R2621 == 4)
replace private_medigap_1 = 4      * private_medigap_1 if (R2621 == 5)
replace private_medigap_1 = 2      * private_medigap_1 if (R2621 == 6)
replace private_medigap_1 = (1/6)  * private_medigap_1 if (R2621 == 7)
replace private_medigap_1 = 2      * private_medigap_1 if (R2621 == 8)

gen private_medigap_2 = R2636
replace private_medigap_2  = . if (private_medigap_2== 999998 | private_medigap_2== 999999)

*convert payment periodicity to monthly:
replace private_medigap_2 = (1/12) * private_medigap_2 if (R2637 == 1)
replace private_medigap_2 = (1/3)  * private_medigap_2 if (R2637 == 2)
replace private_medigap_2 = (1/2)  * private_medigap_2 if (R2637 == 3)
replace private_medigap_2 = 1      * private_medigap_2 if (R2637 == 4)
replace private_medigap_2 = 4      * private_medigap_2 if (R2637 == 5)
replace private_medigap_2 = 2      * private_medigap_2 if (R2637 == 6)
replace private_medigap_2 = (1/6)  * private_medigap_2 if (R2637 == 7)
replace private_medigap_2 = 2      * private_medigap_2 if (R2637 == 8)

gen private_medigap_3 = R2648
replace private_medigap_3  = . if (private_medigap_3== 999998 | private_medigap_3== 999999)

*convert payment periodicity to monthly:
replace private_medigap_3 = (1/12) * private_medigap_3 if (R2649 == 1)
replace private_medigap_3 = (1/3)  * private_medigap_3 if (R2649 == 2)
replace private_medigap_3 = (1/2)  * private_medigap_3 if (R2649 == 3)
replace private_medigap_3 = 1      * private_medigap_3 if (R2649 == 4)
replace private_medigap_3 = 4      * private_medigap_3 if (R2649 == 5)
replace private_medigap_3 = 2      * private_medigap_3 if (R2649 == 6)
replace private_medigap_3 = (1/6)  * private_medigap_3 if (R2649 == 7)
replace private_medigap_3 = 2      * private_medigap_3 if (R2649 == 8)

gen long_term_care = R2704
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: R2705==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = (1/12)            * long_term_care if (R2705 == 1)
replace long_term_care = (1/3)             * long_term_care if (R2705 == 2)
replace long_term_care = 1                 * long_term_care if (R2705 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (R2705 == 6)
replace long_term_care = . if (R2705 == 7 | R2705 == 8 | R2705 == 9) & ///
							  (long_term_care!=0)
							  
gen hospital_NH_OOP = R1760
replace hospital_NH_OOP = . if (hospital_NH_OOP == 9999998 | hospital_NH_OOP == 9999999)

gen doctor_OOP = R1800
replace doctor_OOP = . if (doctor_OOP == 99998 | doctor_OOP == 99999)

gen hospice_OOP = R1781
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

gen RX_OOP = R1810
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_special_OOP = R1827
replace home_special_OOP = . if (home_special_OOP == 999998 | home_special_OOP == 999999)

gen other_OOP = R1835
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen non_med_OOP = R1864
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2000/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(R2585==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(R2585==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(R2585==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_NH_OOP = min( 30000*z*months , hospital_NH_OOP) if !missing(hospital_NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP ) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_special_OOP = min( 30000*z* months , home_special_OOP ) if !missing(home_special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

									
save $savedir/exit2000_oop.dta, replace




********************************************************************************

use $savedir/exit2002.dta, clear
merge 1:1 HHID PN using $savedir/exit2002_months.dta, nogen keep(match)

gen MC_HMO = SN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if SN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if SN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if SN018 == 3
replace MC_HMO = (1/12) * MC_HMO if SN018 == 4
replace MC_HMO = . 				 if (SN018 == 7 | SN018 == 8 | SN018 == 9) & ///
									(MC_HMO!=0)
									
gen MC_B = 54 if (SN004 == 1 & SN005 != 1 & SN007 != 1)									

gen private_medigap_1 = SN040_1
replace private_medigap_1  = . if (private_medigap_1== 998 | private_medigap_1== 999)

gen private_medigap_2 = SN040_2
replace private_medigap_2  = . if (private_medigap_2== 998 | private_medigap_2== 999)

gen private_medigap_3 = SN040_3
replace private_medigap_3  = . if (private_medigap_3== 998 | private_medigap_3== 999)

gen long_term_care = SN079
replace long_term_care = . if (long_term_care == 99998 | long_term_care == 99999)

*convert to monthly frequency 
*NOTE: SN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = (1/12)            * long_term_care if (SN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (SN083 == 2)
replace long_term_care = 1                 * long_term_care if (SN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (SN083 == 6)
replace long_term_care = . if (SN083 == 7 | SN083 == 8 | SN083 == 9) & ///
							  (long_term_care!=0)
							  
gen hospital_OOP = SN106
replace hospital_OOP = . if (hospital_OOP == 999998 | hospital_OOP == 999999)

gen NH_OOP = SN119
replace NH_OOP = . if (NH_OOP == 999998 | NH_OOP == 999999)

gen doctor_OOP = SN156
replace doctor_OOP = . if (doctor_OOP == 999998 | doctor_OOP == 999999)

gen hospice_OOP = SN328
replace hospice_OOP = . if (hospice_OOP == 9998 | hospice_OOP == 9999)

gen RX_OOP = SN180
replace RX_OOP = . if (RX_OOP == 9998 | RX_OOP == 9999)

gen home_OOP = SN194
replace home_OOP = . if (home_OOP == 99998 | home_OOP == 99999)

gen other_OOP = SN333
replace other_OOP = . if (other_OOP == 99998 | other_OOP == 99999)

gen non_med_OOP = SN338
replace non_med_OOP = . if (non_med_OOP == 99998 | non_med_OOP == 99999)

gen special_OOP = SN239
replace special_OOP = . if (SN239 == 9998 | SN239 == 9999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2002/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(SN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(SN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(SN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit2002_oop.dta, replace							  




********************************************************************************

use $savedir/exit2004.dta, clear
merge 1:1 HHID PN using $savedir/exit2004_months.dta, nogen keep(match)

gen MC_HMO = TN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if TN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if TN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if TN018 == 3
replace MC_HMO = (1/12) * MC_HMO if TN018 == 4
replace MC_HMO = . 				 if (TN018 == 7 | TN018 == 8 | TN018 == 9) & ///
									(MC_HMO!=0)
									
gen MC_B = 66.6 if (TN004 == 1 & TN005 != 1 & TN007 != 1)

gen private_medigap_1 = TN040_1
replace private_medigap_1  = . if (private_medigap_1== 9998 | private_medigap_1== 9999)

gen private_medigap_2 = TN040_2
replace private_medigap_2  = . if (private_medigap_2== 9998 | private_medigap_2== 9999)

gen private_medigap_3 = TN040_3
replace private_medigap_3  = . if (private_medigap_3== 9998 | private_medigap_3== 9999)								

gen long_term_care = TN079
replace long_term_care = . if (long_term_care == 99998 | long_term_care == 99999)

*convert to monthly frequency 
*NOTE: TN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = (1/12)            * long_term_care if (TN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (TN083 == 2)
replace long_term_care = 1                 * long_term_care if (TN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (TN083 == 6)
replace long_term_care = . if (TN083 == 7 | TN083 == 8 | TN083 == 9) & ///
							  (long_term_care!=0)
							  
gen hospital_OOP = TN106
replace hospital_OOP = . if (hospital_OOP == 99998 | hospital_OOP == 99999)

gen NH_OOP = TN119
replace NH_OOP = . if (NH_OOP == 999998 | NH_OOP == 999999)

gen doctor_OOP = TN156
replace doctor_OOP = . if (doctor_OOP == 99998 | doctor_OOP == 99999)

gen hospice_OOP = TN328
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

gen RX_OOP = TN180
replace RX_OOP = . if (RX_OOP == 9998 | RX_OOP == 9999)

gen home_OOP = TN194
replace home_OOP = . if (home_OOP == 99998 | home_OOP == 99999)

gen other_OOP = TN333
replace other_OOP = . if (other_OOP == 99998 | other_OOP == 99999)

gen non_med_OOP = TN338
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

gen special_OOP = TN239
replace special_OOP = . if (TN239 == 99998 | TN239 == 99999)							  

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2004/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(TN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(TN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(TN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit2004_oop.dta, replace	




********************************************************************************

use $savedir/exit2006.dta, clear
merge 1:1 HHID PN using $savedir/exit2006_months.dta, nogen keep(match)

gen MC_HMO = UN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if UN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if UN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if UN018 == 3
replace MC_HMO = (1/12) * MC_HMO if UN018 == 4
replace MC_HMO = . 				 if (UN018 == 7 | UN018 == 8 | UN018 == 9) & ///
									(MC_HMO!=0)

gen MC_B = 88.5 if (UN004 == 1 & UN005 != 1 & UN007 != 1)

gen private_medigap_1 = UN040_1
replace private_medigap_1  = . if (private_medigap_1== 9998 | private_medigap_1== 9999)

gen private_medigap_2 = UN040_2
replace private_medigap_2  = . if (private_medigap_2== 9998 | private_medigap_2== 9999)

gen private_medigap_3 = UN040_3
replace private_medigap_3  = . if (private_medigap_3== 9998 | private_medigap_3== 9999)

gen long_term_care = UN079
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: UN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = 1                 * long_term_care if (UN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (UN083 == 2)
replace long_term_care = (1/12)            * long_term_care if (UN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (UN083 == 6)
replace long_term_care = . if (UN083 == 7 | UN083 == 8 | UN083 == 9) & ///
							  (long_term_care!=0)

gen hospital_OOP = UN106
replace hospital_OOP = . if (hospital_OOP == 9999998 | hospital_OOP == 9999999)

gen NH_OOP = UN119
replace NH_OOP = . if (NH_OOP == 9999998 | NH_OOP == 9999999)

gen doctor_OOP = UN156
replace doctor_OOP = . if (doctor_OOP == 9999998 | doctor_OOP == 9999999)

gen hospice_OOP = UN328
replace hospice_OOP = . if (hospice_OOP == 9999998 | hospice_OOP == 9999999)

gen RX_OOP = UN180
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_OOP = UN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

gen other_OOP = UN333
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen non_med_OOP = UN338
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

gen special_OOP = UN239
replace special_OOP = . if (UN239 == 9999998 | UN239 == 9999999)							  

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2006/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(UN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(UN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(UN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit2006_oop.dta, replace	





********************************************************************************

use $savedir/exit2008.dta, clear
merge 1:1 HHID PN using $savedir/exit2008_months.dta, nogen keep(match)

gen MC_HMO = VN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if VN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if VN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if VN018 == 3
replace MC_HMO = (1/12) * MC_HMO if VN018 == 4
replace MC_HMO = . 				 if (VN018 == 7 | VN018 == 8 | VN018 == 9) & ///
									(MC_HMO!=0)
									
gen MC_B = 96.4 if (VN004 == 1 & VN005 != 1 & VN007 != 1)

*Income Adjustments for 2008-2010

*Using RAND HRS ver. L income (hXitot) & marital status (rXmstat), calculate adjustments:
*NOTE: Respondent dies before Wave 9, so we use Wave 8 income, which is recorded in 2006 for 2005.  
*We use the SSA income cutoffs for 2007, which are the earliest available.

*Sources:
*http://www.ssa.gov/policy/docs/statcomps/supplement/2011/2b-2c.html#table2.c1
*http://www.ssa.gov/policy/docs/statcomps/supplement/2007/medicare.html#partBtable

gen MC_B_adjustment = .

replace MC_B_adjustment = 0      if r8mstat!=1 & r8mstat!=2 & h8itot<=82000
replace MC_B_adjustment = 25.80  if r8mstat!=1 & r8mstat!=2 & h8itot>82000 & h8itot<=102000
replace MC_B_adjustment = 64.50  if r8mstat!=1 & r8mstat!=2 & h8itot>10200 & h8itot<=153000
replace MC_B_adjustment = 103.30 if r8mstat!=1 & r8mstat!=2 & h8itot>15300 & h8itot<=205000
replace MC_B_adjustment = 142.00 if r8mstat!=1 & r8mstat!=2 & h8itot>20500 & h8itot<.

*Married, filing jointly (we assume all married respondents file jointly)
replace MC_B_adjustment = 0      if (r8mstat==1 | r8mstat==2) & h8itot<=164000
replace MC_B_adjustment = 25.80  if (r8mstat==1 | r8mstat==2) & h8itot>164000 & h8itot<=204000
replace MC_B_adjustment = 64.50  if (r8mstat==1 | r8mstat==2) & h8itot>204000 & h8itot<=306000
replace MC_B_adjustment = 103.30 if (r8mstat==1 | r8mstat==2) & h8itot>306000 & h8itot<=401000
replace MC_B_adjustment = 142.00 if (r8mstat==1 | r8mstat==2) & h8itot>401000 & h8itot<.

replace MC_B = MC_B + MC_B_adjustment if !missing(MC_B,MC_B_adjustment)

gen private_medigap_1 = VN040_1
replace private_medigap_1  = . if (private_medigap_1== 99998 | private_medigap_1== 99999)

gen private_medigap_2 = VN040_2
replace private_medigap_2  = . if (private_medigap_2== 99998 | private_medigap_2== 99999)

gen private_medigap_3 = VN040_3
replace private_medigap_3  = . if (private_medigap_3== 998 | private_medigap_3== 999)

gen long_term_care = VN079
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: VN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = 1                 * long_term_care if (VN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (VN083 == 2)
replace long_term_care = (1/12)            * long_term_care if (VN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (VN083 == 6)
replace long_term_care = . if (VN083 == 7 | VN083 == 8 | VN083 == 9) & ///
							  (long_term_care!=0)

gen hospital_OOP = VN106
replace hospital_OOP = . if (hospital_OOP == 9999998 | hospital_OOP == 9999999)

gen NH_OOP = VN119
replace NH_OOP = . if (NH_OOP == 9999998 | NH_OOP == 9999999)

gen doctor_OOP = VN156
replace doctor_OOP = . if (doctor_OOP == 9999998 | doctor_OOP == 9999999)

gen hospice_OOP = VN328
replace hospice_OOP = . if (hospice_OOP == 9999998 | hospice_OOP == 9999999)

gen RX_OOP = VN180
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_OOP = VN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

gen other_OOP = VN333
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen non_med_OOP = VN338
replace non_med_OOP = . if (non_med_OOP == 999998 | non_med_OOP == 999999)

gen special_OOP = VN239
replace special_OOP = . if (VN239 == 9999998 | VN239 == 9999999)							  

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2008/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(VN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(VN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(VN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)
replace non_med_OOP = min( 5000*z*months , non_med_OOP ) if !missing(non_med_OOP)

save $savedir/exit2008_oop.dta, replace	





********************************************************************************

use $savedir/exit2010.dta, clear
merge 1:1 HHID PN using $savedir/exit2010_months.dta, nogen keep(match)

gen MC_HMO = WN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if WN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if WN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if WN018 == 3
replace MC_HMO = (1/12) * MC_HMO if WN018 == 4
replace MC_HMO = . 				 if (WN018 == 7 | WN018 == 8 | WN018 == 9) & ///
									(MC_HMO!=0)
									
gen MC_B = 96.4 if (WN004 == 1 & WN005 != 1 & WN007 != 1)

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

gen private_medigap_1 = WN040_1
replace private_medigap_1  = . if (private_medigap_1== 99998 | private_medigap_1== 99999)

gen private_medigap_2 = WN040_2
replace private_medigap_2  = . if (private_medigap_2== 99998 | private_medigap_2== 99999)

gen private_medigap_3 = WN040_3
replace private_medigap_3  = . if (private_medigap_3== 998 | private_medigap_3== 999)									

gen long_term_care = WN079
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: WN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = 1                 * long_term_care if (WN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (WN083 == 2)
replace long_term_care = (1/12)            * long_term_care if (WN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (WN083 == 6)
replace long_term_care = . if (WN083 == 7 | WN083 == 8 | WN083 == 9) & ///
							  (long_term_care!=0)

gen hospital_OOP = WN106
replace hospital_OOP = . if (hospital_OOP == 99998 | hospital_OOP == 99999)

gen NH_OOP = WN119
replace NH_OOP = . if (NH_OOP == 9999998 | NH_OOP == 9999999)

gen patient_OOP = WN139
replace patient_OOP = . if (patient_OOP == 9999998 | patient_OOP == 9999999)

gen doctor_OOP = WN156
replace doctor_OOP = . if (doctor_OOP == 9999998 | doctor_OOP == 9999999)

gen dental_OOP = WN168
replace dental_OOP = . if (dental_OOP == 9999998 | dental_OOP == 9999999)

gen hospice_OOP = WN328
replace hospice_OOP = . if (hospice_OOP == 9999998 | hospice_OOP == 9999999)

gen RX_OOP = WN180
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_OOP = WN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

gen other_OOP = WN333
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen home_modif_OOP = WN268
replace home_modif_OOP = . if (home_modif_OOP == 999998 | home_modif_OOP == 999999)

gen special_OOP = WN239
replace special_OOP = . if (WN239 == 9999998 | WN239 == 9999999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2010/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(WN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(WN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(WN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP ) if !missing(patient_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP ) if !missing(dental_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace home_modif_OOP = min( 5000*z*months , home_modif_OOP ) if !missing(home_modif_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)

save $savedir/exit2010_oop.dta, replace	


********************************************************************************

use $savedir/exit2012.dta, clear
merge 1:1 HHID PN using $savedir/exit2012_months.dta, nogen keep(match)

gen MC_HMO = XN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if XN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if XN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if XN018 == 3
replace MC_HMO = (1/12) * MC_HMO if XN018 == 4
replace MC_HMO = . 				 if (XN018 == 7 | XN018 == 8 | XN018 == 9) & ///
									(MC_HMO!=0)

//rrd: as before, using prior wave of rules/prems (2011)
//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2010/medicare.html#partBtable
//rrd: NOT ONTROLING FOR HOLD HARMLESS, IE IS UPPER BOUND
gen MC_B = 115.40 if (XN004 == 1 & XN005 != 1 & XN007 != 1)

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r10mstat!=1 & r10mstat!=2 & h10itot<=85000						
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

gen private_medigap_1 = XN040_1
replace private_medigap_1  = . if (private_medigap_1== 99998 | private_medigap_1== 99999)

gen private_medigap_2 = XN040_2
replace private_medigap_2  = . if (private_medigap_2== 99998 | private_medigap_2== 99999)

gen private_medigap_3 = XN040_3
replace private_medigap_3  = . if (private_medigap_3== 998 | private_medigap_3== 999)									

gen long_term_care = XN079
replace long_term_care = . if (long_term_care == 999998 | long_term_care == 999999)

*convert to monthly frequency 
*NOTE: WN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = 1                 * long_term_care if (XN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (XN083 == 2)
replace long_term_care = (1/12)            * long_term_care if (XN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (XN083 == 6)
replace long_term_care = . if (XN083 == 7 | XN083 == 8 | XN083 == 9) & ///
							  (long_term_care!=0)

gen hospital_OOP = XN106
replace hospital_OOP = . if (hospital_OOP == 9999998 | hospital_OOP == 9999999)

gen NH_OOP = XN119
replace NH_OOP = . if (NH_OOP == 9999998 | NH_OOP == 9999999)

gen patient_OOP = XN139
replace patient_OOP = . if (patient_OOP == 9999998 | patient_OOP == 9999999)

gen doctor_OOP = XN156
replace doctor_OOP = . if (doctor_OOP == 9999998 | doctor_OOP == 9999999)

gen dental_OOP = XN168
replace dental_OOP = . if (dental_OOP == 9999998 | dental_OOP == 9999999)

gen hospice_OOP = XN328
replace hospice_OOP = . if (hospice_OOP == 9999998 | hospice_OOP == 9999999)

gen RX_OOP = XN180
replace RX_OOP = . if (RX_OOP == 99998 | RX_OOP == 99999)

gen home_OOP = XN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

gen other_OOP = XN333
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen home_modif_OOP = XN268
replace home_modif_OOP = . if (home_modif_OOP == 999998 | home_modif_OOP == 999999)

gen special_OOP = XN239
replace special_OOP = . if (XN239 == 9999998 | XN239 == 9999999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2012/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(XN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(XN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(XN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP ) if !missing(patient_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP ) if !missing(dental_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace home_modif_OOP = min( 5000*z*months , home_modif_OOP ) if !missing(home_modif_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)

save $savedir/exit2012_oop.dta, replace	



********************************************************************************

use $savedir/exit2014.dta, clear
merge 1:1 HHID PN using $savedir/exit2014_months.dta, nogen keep(match)

gen MC_HMO = YN014
replace MC_HMO = . if (MC_HMO == 998 | MC_HMO == 999)

*convert to monthly frequency:
replace MC_HMO = 1      * MC_HMO if YN018 == 1
replace MC_HMO = (1/3)  * MC_HMO if YN018 == 2
replace MC_HMO = (1/6)  * MC_HMO if YN018 == 3
replace MC_HMO = (1/12) * MC_HMO if YN018 == 4
replace MC_HMO = . 				 if (YN018 == 7 | YN018 == 8 | YN018 == 9) & ///
									(MC_HMO!=0)

//rrd: as before, using prior wave of rules/prems (2011)
//rrd: http://www.ssa.gov/policy/docs/statcomps/supplement/2010/medicare.html#partBtable
//rrd: NOT ONTROLING FOR HOLD HARMLESS, IE IS UPPER BOUND
gen MC_B = 115.40 if (YN004 == 1 & YN005 != 1 & YN007 != 1)

gen MC_B_adjustment = .

*Single
replace MC_B_adjustment = 0      if r10mstat!=1 & r10mstat!=2 & h10itot<=85000						
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

gen private_medigap_1 = YN040_1
replace private_medigap_1  = . if (private_medigap_1== 9998 | private_medigap_1== 9999)

gen private_medigap_2 = YN040_2
replace private_medigap_2  = . if (private_medigap_2== 998 | private_medigap_2== 999)

gen private_medigap_3 = YN040_3
replace private_medigap_3  = . if (private_medigap_3== 998 | private_medigap_3== 999)									

gen long_term_care = YN079
replace long_term_care = . if (long_term_care == 99998 | long_term_care == 99999)

*convert to monthly frequency 
*NOTE: WN083==6 denotes "lump sum"; we assume that payment covers 20 years
replace long_term_care = 1                 * long_term_care if (YN083 == 1)
replace long_term_care = (1/3)             * long_term_care if (YN083 == 2)
replace long_term_care = (1/12)            * long_term_care if (YN083 == 4)
replace long_term_care = ((1/20) * (1/12)) * long_term_care if (YN083 == 6)
replace long_term_care = . if (YN083 == 7 | YN083 == 8 | YN083 == 9) & ///
							  (long_term_care!=0)

gen hospital_OOP = YN106
replace hospital_OOP = . if (hospital_OOP == 99998 | hospital_OOP == 99999)

gen NH_OOP = YN119
replace NH_OOP = . if (NH_OOP == 999998 | NH_OOP == 999999)

gen patient_OOP = YN139
replace patient_OOP = . if (patient_OOP == 9998 | patient_OOP == 9999)

gen doctor_OOP = YN156
replace doctor_OOP = . if (doctor_OOP == 999998 | doctor_OOP == 999999)

gen dental_OOP = YN168
replace dental_OOP = . if (dental_OOP == 99998 | dental_OOP == 99999)

gen hospice_OOP = YN328
replace hospice_OOP = . if (hospice_OOP == 99998 | hospice_OOP == 99999)

gen RX_OOP = YN180
replace RX_OOP = . if (RX_OOP == 9998 | RX_OOP == 9999)

gen home_OOP = YN194
replace home_OOP = . if (home_OOP == 999998 | home_OOP == 999999)

gen other_OOP = YN333
replace other_OOP = . if (other_OOP == 999998 | other_OOP == 999999)

gen home_modif_OOP = YN268
replace home_modif_OOP = . if (home_modif_OOP == 99998 | home_modif_OOP == 99999)

gen special_OOP = YN239
replace special_OOP = . if (YN239 == 99998 | YN239 == 99999)

*summarize
*fsum MC_HMO long_term_care private_medigap_* *_OOP, s(n miss min max mean se p5 p25 p50 p75 p95) f(%9.0f)

*caps

scalar z = cpi2014/cpiBASE

replace MC_HMO = min( MC_HMO, 400*z ) if !missing(MC_HMO)
replace private_medigap_1 = min( private_medigap_1 , cond(YN001==1,400*z,2000*z) ) if !missing(private_medigap_1)
replace private_medigap_2 = min( private_medigap_2 , cond(YN001==1,400*z,2000*z) ) if !missing(private_medigap_2)
replace private_medigap_3 = min( private_medigap_3 , cond(YN001==1,400*z,2000*z) ) if !missing(private_medigap_3)
replace long_term_care = min( long_term_care , 2000*z ) if !missing(long_term_care)
replace hospital_OOP = min( 15000*z*months , hospital_OOP) if !missing(hospital_OOP)
replace NH_OOP = min( 15000*z*months , NH_OOP) if !missing(NH_OOP)
replace patient_OOP = min( 15000*z*months , patient_OOP ) if !missing(patient_OOP)
replace doctor_OOP = min( 5000*z*months , doctor_OOP) if !missing(doctor_OOP)
replace dental_OOP = min( 1000*z*months , dental_OOP ) if !missing(dental_OOP)
replace hospice_OOP = min( 5000*z*months , hospice_OOP ) if !missing(hospice_OOP)
replace RX_OOP = min( 5000*z , RX_OOP) if !missing(RX_OOP)
replace home_OOP = min( 15000*z* months , home_OOP ) if !missing(home_OOP)
replace home_modif_OOP = min( 5000*z*months , home_modif_OOP ) if !missing(home_modif_OOP)
replace special_OOP = min( 15000*z*months , special_OOP ) if !missing(special_OOP)
replace other_OOP = min( 15000*z*months , other_OOP ) if !missing(other_OOP)

save $savedir/exit2014_oop.dta, replace	



********************************************************************************

use $savedir/exit1995_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1995.dta, replace

use $savedir/exit1996_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1996.dta, replace

use $savedir/exit1998_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp1998.dta, replace

use $savedir/exit2000_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_NH_OOP doctor_OOP hospice_OOP RX_OOP home_special_OOP other_OOP non_med_OOP
save $savedir/tmp2000.dta, replace

use $savedir/exit2002_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2002.dta, replace

use $savedir/exit2004_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2004.dta, replace

use $savedir/exit2006_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2006.dta, replace

use $savedir/exit2008_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP hospice_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
save $savedir/tmp2008.dta, replace

use $savedir/exit2010_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2010.dta, replace

use $savedir/exit2012_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2012.dta, replace

use $savedir/exit2014_oop.dta, clear
keep HHID PN year MC_HMO private_medigap_* long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP hospice_OOP RX_OOP home_OOP special_OOP ///
	other_OOP home_modif_OOP
save $savedir/tmp2014.dta, replace

use $savedir/tmp1995.dta, clear
append using ///
$savedir/tmp1996.dta ///
$savedir/tmp1998.dta ///
$savedir/tmp2000.dta ///
$savedir/tmp2002.dta ///
$savedir/tmp2004.dta ///
$savedir/tmp2006.dta ///
$savedir/tmp2008.dta ///
$savedir/tmp2010.dta ///
$savedir/tmp2012.dta ///
$savedir/tmp2014.dta 

save $savedir/exit_oop.dta, replace

rm $savedir/tmp1995.dta
rm $savedir/tmp1996.dta
rm $savedir/tmp1998.dta
rm $savedir/tmp2000.dta
rm $savedir/tmp2002.dta
rm $savedir/tmp2004.dta
rm $savedir/tmp2006.dta
rm $savedir/tmp2008.dta
rm $savedir/tmp2012.dta
rm $savedir/tmp2014.dta

