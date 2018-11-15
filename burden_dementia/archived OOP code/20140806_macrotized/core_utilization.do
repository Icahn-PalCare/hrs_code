
********************************************************************************

use $savedir/core1992.dta, clear
merge 1:1 HHID PN using $savedir/core1992_months.dta, nogen keep(match)

/*

//Respondent

        6602    R2.     Are you currently covered by any federal government
                        health insurance programs, such as Medicare,
                        Medicaid, or CHAMPUS, VA, or other military
                        programs?
        6603    R2aA.   MEDICARE
        6604    R2aB.   MEDICAID
        6605    R2aC.   VA/CHAMPUS
        6606    R2aD.   OTHER (incl. Bureau of Indian Affairs)                                                

//Spouse
                        
        6802    R20.    Is your (husband/wife/partner) currently covered by
                        any government health insurance programs such as
                        Medicare, Medicaid, or CHAMPUS, VA, or other
                        military programs?
        6803    R20aA.  MEDICARE
        6804    R20aB.  MEDICAID
        6805    R20aC.  VA/CHAMPUS
        6806    R20aD.  OTHER (incl. Bureau of Indian Affairs)                                                
                                                
*/

gen mc_cov = V6603 if PN == APN_FIN
gen md_cov = V6604 if PN == APN_FIN
gen gov_oth_cov = V6605 if PN == APN_FIN

//no MC_B information

replace mc_cov = V6803 if PN != APN_FIN
replace md_cov = V6804 if PN != APN_FIN
replace gov_oth_cov = V6805 if PN != APN_FIN

/*
        533     B45.    During the last 12 months, since (MONTH) of 1991,
        10533           have you been a patient in a hospital overnight?
                        [IMPUTED]
                        
        535     B45b.   Altogether, how many nights were you a patient in a
        10535           hospital in the last 12 months?  [IMPUTED]                        
*/

//utilization reported on individual basis

gen hospital_use = V533
gen hospital_nights = V535

/*
        536     B46.    During the last 12 months, have you been a patient
        10536           in a nursing home overnight?  [IMPUTED]

        538     B46b.   Altogether, how many nights were you a patient in a
                        nursing home in the last 12 months?        
*/

gen nh_use = V536
gen nh_nights = V538

/*
        539     B47.    (Not counting overnight hospital or nursing home
        10539           stays) During the last 12 months, since (MONTH) of
                        1991, how many times have you seen or talked to a
                        medical doctor about your health, including
                        emergency room or clinic visits?  [IMPUTED]
*/

gen dr_visits = V539
recode V539 (0=0) (1/max=1), gen(doctor_use)			//rrd: make bool

keep HHID PN year *_iw_date months *_use *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1992_use.dta, replace				//rrd: add coverage for private LTC ins

********************************************************************************

use $savedir/core1993.dta, clear
merge 1:1 HHID PN using $savedir/core1993_months.dta, nogen keep(match)

gen mc_cov = V754
gen mc_b_cov = V755
gen md_cov = V1838
gen gov_oth_cov = V1848

/*
V605R               [RESP]    E1. R IN HOSPITAL LAST 12 MOS
          E1.  During the last 12 months, since [MONTH] of (1992/1993),
               have you been a patient in a hospital overnight?
               
V610           [HH]    E4. HOSPITAL $ NOT COVERED BY INS
          E4.  Are there expenses over $500 from [your/(and your)
               (husband's/ wife's/ partner's) hospital stays that will not
               be covered by Medicare or other insurance, or by Medicaid?
*/

gen hospital_use93 = V605
gen hospital_cov93 = V610 	

*Number of nights in hospital
gen hospital_nights = V607
replace hospital_nights = . if hospital_nights == 997 | hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use93 = V622
gen nh_cov93 = V627 

*nights spent in nursing home
gen nh_nights = V624
replace nh_nights = . if nh_nights == 996 | nh_nights == 997 | nh_nights == 998 | nh_nights == 999

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

recode V640 (98 99 = .), gen(dr_visits)
gen doctor_use93 = V639
gen doctor_cov93 = V642

gen patient_use93 = V654
gen patient_cov93 = V657 

gen dental_use93 = V669
gen dental_cov93 = V672 

gen drugs_use93 = V685
gen drugs_cov93 = V689 

gen home_use93 = V701
gen home_cov93 = V703 

gen special_use93 = V715

keep HHID PN year *_iw_date months *_use93 *_cov93 *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1993_use.dta, replace

********************************************************************************

use $savedir/core1994.dta, clear
merge 1:1 HHID PN using $savedir/core1994_months.dta, nogen keep(match)

egen x = rownonmiss(W6701 W6702 W6703 W6704)			
gen mc_cov = (W6701==1 | W6702==1 | W6703==1 | W6704==1) if x>0		//rrd: note in other incidences, no is 5
gen md_cov = (W6701==2 | W6702==2 | W6703==2 | W6704==2) if x>0
gen gov_oth_cov = (W6701==3 | W6702==3 | W6703==3 | W6704==3) if x>0 //rrd: this is technically just VA, should be any other pos
drop x

//no MC_B information

gen hospital_use = W410
gen hospital_cov94 = W414

*Number of nights in hospital
gen hospital_nights = W412
replace hospital_nights = . if hospital_nights == 997 | hospital_nights == 998 | hospital_nights == 999

replace hospital_nights = 1        * hospital_nights if W413==1
replace hospital_nights = 7        * hospital_nights if W413==2
replace hospital_nights = (365/12) * hospital_nights if W413==3
replace hospital_nights = . if !missing(hospital_nights) & (W413==7 | W413==8 | W413==9)

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = W415
gen nh_cov94 = W419

*nights spent in nursing home
gen nh_nights = W417
replace nh_nights = . if nh_nights == 997 | nh_nights == 998 | nh_nights == 999

replace nh_nights = 1        * nh_nights if W413==1	//days/nights
replace nh_nights = 7        * nh_nights if W413==2	//weeks
replace nh_nights = (365/12) * nh_nights if W413==3	//years
replace nh_nights = . if !missing(nh_nights) & (W413==7 | W413==8 | W413==9)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

recode W420 (997 998 999 = .), gen(dr_visits)
recode W420 (0=0) (1/996=1) (997=7) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov94 = W421

gen rx_use = W433
gen rx_cov94 = W436

keep HHID PN year *_iw_date months *_use *_cov94 *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1994_use.dta, replace

********************************************************************************

use $savedir/core1995.dta, clear
merge 1:1 HHID PN using $savedir/core1995_months.dta, nogen keep(match)

gen mc_cov = D5144
gen mc_b_cov = D5145
gen md_cov = D5155
gen gov_oth_cov = D5175

gen hospital_use = D1664
gen hospital_cov = D1669

*Number of nights in hospital
gen hospital_nights = D1666
replace hospital_nights = . if hospital_nights == 997 | hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = D1681
gen nh_liv = D240
gen nh_cov = D1686

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = D1683
replace nh_nights = . if nh_nights == 996 | nh_nights == 997 | nh_nights == 998 | nh_nights == 999
gen nh_months = D1684
replace nh_months = . if nh_months == 97 | nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*fill in remaining missing values using coverscreen where possible if R lives in NH:
MAKEDATE nh_enter_date_cs D417 D418
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if D240==1			//rrd: this appleis only if own house still, or rent
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

recode D1689 (998 999 = .), gen(dr_visits)
recode D1689 (0=0) (1/997=1) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = D1701

gen patient_use = D1713
gen patient_cov = D1716

gen dental_use = D1728
gen dental_cov = D1731

gen rx_use = D1744
gen rx_cov = D1748

gen home_use = D1760
gen home_cov = D1762

gen special_use = D1774

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1995_use.dta, replace

********************************************************************************

use $savedir/core1996.dta, clear
merge 1:1 HHID PN using $savedir/core1996_months.dta, nogen keep(match)

gen mc_cov = E5133
gen mc_b_cov = E5134
gen md_cov = E5135
gen gov_oth_cov = E5145

gen hospital_use = E1770
gen hospital_cov = E1775

*Number of nights in hospital
gen hospital_nights = E1772
replace hospital_nights = . if hospital_nights == 997 | hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = E1776
gen nh_liv = E240
gen nh_cov = E1781

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = E1778
replace nh_nights = . if nh_nights == 996 | nh_nights == 997 | nh_nights == 998 | nh_nights == 999
gen nh_months = E1779
replace nh_months = . if nh_months == 97 | nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*fill in remaining missing values using coverscreen where possible if R lives in NH:
MAKEDATE nh_enter_date_cs E417 E418
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if E240==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

recode E1790 (997 998 999 = .), gen(dr_visits)
recode E1790 (0=0) (1/996=1) (997=7) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = E1793

gen patient_use = E1795
gen patient_cov = E1798

gen dental_use = E1800
gen dental_cov = E1803

gen rx_use = E1811
gen rx_cov = E1815

gen home_use = E1827
gen home_cov = E1829

gen special_use = E1831

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1996_use.dta, replace

********************************************************************************

use $savedir/core1998.dta, clear
merge 1:1 HHID PN using $savedir/core1998_months.dta, nogen keep(match)

gen mc_cov = F5866
gen mc_b_cov = F5867
gen md_cov = F5868
gen gov_oth_cov = F5878

gen hospital_use = F2295
gen hospital_cov = F2298

*Number of nights in hospital
gen hospital_nights = F2297
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = F2299
gen nh_liv = F517
gen nh_cov = F2304

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = F2301
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = F2302
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs F718 F719
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if F517==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (F2300==1 | F2300==. | F2300==98 | F2300==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 F2313 F2314
MAKEDATE nh_exit_date_1  F2315 F2316
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & F517==1 & F2300==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 F2319 F2320
MAKEDATE nh_exit_date_2  F2321 F2322
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & F517==1 & F2300==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 F2325 F2326
MAKEDATE nh_exit_date_3  F2327 F2328
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & F517==1 & F2300>=3 & F2300<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

recode F2331 (998 999 = .), gen(dr_visits)
recode F2331 (0=0) (1/997=1) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = F2332

gen patient_use = F2333
gen patient_cov = F2334

gen dental_use = F2335
gen dental_cov = F2336

gen rx_use = F2345
gen rx_cov = F2346

gen home_use = F2357
gen home_cov = F2359

gen special_use = F2361

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core1998_use.dta, replace

********************************************************************************

use $savedir/core2000.dta, clear
merge 1:1 HHID PN using $savedir/core2000_months.dta, nogen keep(match)

gen mc_cov = G6238
gen mc_b_cov = G6240
gen md_cov = G6241
gen gov_oth_cov = G6251

gen hospital_use = G2567
gen hospital_cov = G2570

*Number of nights in hospital
gen hospital_nights = G2569
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = G2571
gen nh_liv = G558
gen nh_cov = G2576

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = G2573
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = G2574
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs G789 G790
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if G558==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (G2572==1 | G2572==. | G2572==98 | G2572==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 G2585 G2586
MAKEDATE nh_exit_date_1  G2587 G2588
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & G558==1 & G2572==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 G2591 G2592
MAKEDATE nh_exit_date_2  G2593 G2594
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & G558==1 & G2572==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 G2597 G2598
MAKEDATE nh_exit_date_3  G2599 G2600
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & G558==1 & G2572>=3 & G2572<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = G2603
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits G2604 G2605 G2606 G2607
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & G2603==998
replace doctor_use = 9 if missing(doctor_use) & G2603==999

gen doctor_cov = G2609

gen patient_use = G2610
gen patient_cov = G2611

gen dental_use = G2612
gen dental_cov = G2613

gen rx_use = G2622
gen rx_cov = G2623

gen home_use = G2634
gen home_cov = G2636

gen special_use = G2638

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2000_use.dta, replace

********************************************************************************

use $savedir/core2002.dta, clear
merge 1:1 HHID PN using $savedir/core2002_months.dta, nogen keep(match)

gen mc_cov = HN001
gen mc_b_cov = HN004
gen md_cov = HN005
gen gov_oth_cov = HN007

gen private_medigap_plans = HN023

gen hospital_use = HN099
gen hospital_cov = HN102

*impute using number of nights spent in hospital:
gen hospital_nights = HN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = HN114
gen nh_liv = HA028
gen nh_cov = HN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = HN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = HN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs HA065 HA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if HA028==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (HN115==1 | HN115==. | HN115==98 | HN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 HN123_1 HN124_1
MAKEDATE nh_exit_date_1  HN125_1 HN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & HA028==1 & HN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 HN123_2 HN124_2
MAKEDATE nh_exit_date_2  HN125_2 HN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & HA028==1 & HN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 HN123_3 HN124_3
MAKEDATE nh_exit_date_3  HN125_3 HN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & HA028==1 & HN115>=3 & HN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = HN134
gen patient_cov = HN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = HN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits HN148 HN149 HN150 HN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & HN147==998
replace doctor_use = 9 if missing(doctor_use) & HN147==999

gen doctor_cov = HN152

gen dental_use = HN164
gen dental_cov = HN165

gen rx_use = HN175
gen rx_cov = HN176

gen home_use = HN189
gen home_cov = HN190

gen special_use = HN202
gen special_cov = HN203

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2002_use.dta, replace

********************************************************************************

use $savedir/core2004.dta, clear
merge 1:1 HHID PN using $savedir/core2004_months.dta, nogen keep(match)

gen mc_cov = JN001
gen mc_b_cov = JN004
gen md_cov = JN005
gen gov_oth_cov = JN007

gen private_medigap_plans = JN023

gen hospital_use = JN099
gen hospital_cov = JN102

*impute using number of nights spent in hospital:
gen hospital_nights = JN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = JN114
gen nh_liv = JA028
gen nh_cov = JN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = JN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = JN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs JA065 JA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if JA028==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (JN115==1 | JN115==. | JN115==98 | JN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 JN123_1 JN124_1
MAKEDATE nh_exit_date_1  JN125_1 JN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & JA028==1 & JN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 JN123_2 JN124_2
MAKEDATE nh_exit_date_2  JN125_2 JN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & JA028==1 & JN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 JN123_3 JN124_3
MAKEDATE nh_exit_date_3  JN125_3 JN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & JA028==1 & JN115>=3 & JN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = JN134
gen patient_cov = JN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = JN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits JN148 JN149 JN150 JN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & JN147==998
replace doctor_use = 9 if missing(doctor_use) & JN147==999

gen doctor_cov = JN152

gen dental_use = JN164
gen dental_cov = JN165

gen rx_use = JN175
gen rx_cov = JN176

gen home_use = JN189
gen home_cov = JN190

gen special_use = JN202
gen special_cov = JN203

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2004_use.dta, replace

********************************************************************************

use $savedir/core2006.dta, clear
merge 1:1 HHID PN using $savedir/core2006_months.dta, nogen keep(match)

gen mc_cov = KN001
gen mc_b_cov = KN004
gen md_cov = KN005
gen gov_oth_cov = KN007

gen private_medigap_plans = KN023

gen hospital_use = KN099
gen hospital_cov = KN102

*impute using number of nights spent in hospital:
gen hospital_nights = KN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = KN114
gen nh_liv = KA028
gen nh_cov = KN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = KN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = KN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs KA065 KA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if KA028==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (KN115==1 | KN115==. | KN115==98 | KN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 KN123_1 KN124_1
MAKEDATE nh_exit_date_1  KN125_1 KN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & KA028==1 & KN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 KN123_2 KN124_2
MAKEDATE nh_exit_date_2  KN125_2 KN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & KA028==1 & KN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 KN123_3 KN124_3
MAKEDATE nh_exit_date_3  KN125_3 KN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & KA028==1 & KN115>=3 & KN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = KN134
gen patient_cov = KN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = KN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits KN148 KN149 KN150 KN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & KN147==998
replace doctor_use = 9 if missing(doctor_use) & KN147==999

gen doctor_cov = KN152

gen dental_use = KN164
gen dental_cov = KN165

gen rx_use = KN175
gen rx_cov = KN176

gen home_use = KN189
gen home_cov = KN190

gen special_use = KN202
gen special_cov = KN203

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2006_use.dta, replace

********************************************************************************

use $savedir/core2008.dta, clear
merge 1:1 HHID PN using $savedir/core2008_months.dta, nogen keep(match)

gen mc_cov = LN001
gen mc_b_cov = LN004
gen md_cov = LN005
gen gov_oth_cov = LN007

gen private_medigap_plans = LN023

gen hospital_use = LN099
gen hospital_cov = LN102

*impute using number of nights spent in hospital:
gen hospital_nights = LN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = LN114
gen nh_liv = LA028
gen nh_cov = LN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = LN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = LN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs LA065 LA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if LA028==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (LN115==1 | LN115==. | LN115==98 | LN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 LN123_1 LN124_1
MAKEDATE nh_exit_date_1  LN125_1 LN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & LA028==1 & LN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 LN123_2 LN124_2
MAKEDATE nh_exit_date_2  LN125_2 LN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & LA028==1 & LN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 LN123_3 LN124_3
MAKEDATE nh_exit_date_3  LN125_3 LN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & LA028==1 & LN115>=3 & LN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = LN134
gen patient_cov = LN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = LN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits LN148 LN149 LN150 LN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & LN147==998
replace doctor_use = 9 if missing(doctor_use) & LN147==999

gen doctor_cov = LN152

gen dental_use = LN164
gen dental_cov = LN165

gen rx_use = LN175
gen rx_cov = LN176

gen home_use = LN189
gen home_cov = LN190

gen special_use = LN202
gen special_cov = LN203

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2008_use.dta, replace

********************************************************************************

use $savedir/core2010.dta, clear
merge 1:1 HHID PN using $savedir/core2010_months.dta, nogen keep(match)

gen mc_cov = MN001
gen mc_b_cov = MN004
gen md_cov = MN005
gen gov_oth_cov = MN007

gen private_medigap_plans = MN023

gen hospital_use = MN099
gen hospital_cov = MN102

*impute using number of nights spent in hospital:
gen hospital_nights = MN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = MN114
gen nh_liv = MA028
gen nh_cov = MN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = MN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = MN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs MA065 MA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if MA028==1
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (MN115==1 | MN115==. | MN115==98 | MN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 MN123_1 MN124_1
MAKEDATE nh_exit_date_1  MN125_1 MN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & MA028==1 & MN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 MN123_2 MN124_2
MAKEDATE nh_exit_date_2  MN125_2 MN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & MA028==1 & MN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 MN123_3 MN124_3
MAKEDATE nh_exit_date_3  MN125_3 MN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & MA028==1 & MN115>=3 & MN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = MN134
gen patient_cov = MN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = MN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits MN148 MN149 MN150 MN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & MN147==998
replace doctor_use = 9 if missing(doctor_use) & MN147==999

gen doctor_cov = MN152

gen dental_use = MN164
gen dental_cov = MN165

gen rx_use = MN175
gen rx_cov = MN176

gen home_use = MN189
gen home_cov = MN190

gen special_use = MN202
gen special_cov = MN203

gen other_use = MN332

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2010_use.dta, replace

********************************************************************************

use $savedir/core2012.dta, clear
merge 1:1 HHID PN using $savedir/core2012_months.dta, nogen keep(match)

gen mc_cov = NN001
gen mc_b_cov = NN004
gen md_cov = NN005
gen gov_oth_cov = NN007		//rrd: specifically mil

gen private_medigap_plans = NN023		//rrd: private or medigap

gen hospital_use = NN099
gen hospital_cov = NN102

*impute using number of nights spent in hospital:
gen hospital_nights = NN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = NN114
gen nh_liv = NA028
gen nh_cov = NN118

*nights spent in nursing home
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
gen nh_nights = NN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = NN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0		//rrd: might not want to replace 0 with mi

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs NA065 NA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if NA028==1		//rrd: time inconsistency, in this case each month is 365/12 days
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (NN115==1 | NN115==. | NN115==98 | NN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, R lives in NH, and stay is most recent stay, replace exit date with current IW date:
MAKEDATE nh_enter_date_1 NN123_1 NN124_1
MAKEDATE nh_exit_date_1  NN125_1 NN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & NA028==1 & NN115==1
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 NN123_2 NN124_2
MAKEDATE nh_exit_date_2  NN125_2 NN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & NA028==1 & NN115==2
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 NN123_3 NN124_3
MAKEDATE nh_exit_date_3  NN125_3 NN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & NA028==1 & NN115>=3 & NN115<98
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)		//rrd: does this need to be rounded?

gen patient_use = NN134
gen patient_cov = NN135

*impute using number of doctor visits, first impute missing doctor visits:
gen dr_visits = NN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits NN148 NN149 NN150 NN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & NN147==998
replace doctor_use = 9 if missing(doctor_use) & NN147==999

gen doctor_cov = NN152

gen dental_use = NN164
gen dental_cov = NN165

gen rx_use = NN175
gen rx_cov = NN176

gen home_use = NN189
gen home_cov = NN190

gen special_use = NN202
gen special_cov = NN203

gen other_use = NN332

keep HHID PN year *_iw_date months *_use *_liv *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/core2012_use.dta, replace


********************************************************************************

use $savedir/core1992_use.dta, clear

append using ///
$savedir/core1993_use.dta ///
$savedir/core1994_use.dta ///
$savedir/core1995_use.dta ///
$savedir/core1996_use.dta ///
$savedir/core1998_use.dta ///
$savedir/core2000_use.dta ///
$savedir/core2002_use.dta ///
$savedir/core2004_use.dta ///
$savedir/core2006_use.dta ///
$savedir/core2008_use.dta ///
$savedir/core2010_use.dta ///
$savedir/core2012_use.dta

sort HHID PN year		

save $savedir/core_use.dta, replace
