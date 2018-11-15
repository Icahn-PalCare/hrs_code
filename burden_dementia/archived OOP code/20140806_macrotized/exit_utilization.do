
********************************************************************************

use $savedir/exit1995.dta, clear
merge 1:1 HHID PN using $savedir/exit1995_months.dta, nogen keep(match)

//Note: nh_liv and loc_die contain additional utilization information for hospital_ NH_ and hospice_ not contained in the _use variables

gen cause_die = N234M1M

gen nh_liv = N249
gen loc_die = N226

gen mc_cov = N5275
gen mc_b_cov = N5276
gen md_cov = N5286
gen gov_oth_cov = N5306

gen hospital_use = N1664
gen hospital_cov = N1672

*Number of nights in hospital
gen hospital_nights = N1666
replace hospital_nights = . if hospital_nights == 997 | hospital_nights == 998 | hospital_nights == 999

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = N1681
gen nh_cov = N1686

*compute nh nights using first set of questions in section E (respondent can answer using nights, months, or since a certain date)
gen nh_nights_1 = N1674
replace nh_nights_1 = . if nh_nights_1 == 998 | nh_nights_1 == 999
gen nh_months_1 = N1675
replace nh_months_1 = . if nh_months_1 == 98 | nh_months_1 == 99
replace nh_nights_1 = round( (365/12) * nh_months_1 ) if missing(nh_nights_1)

*using NH entry date in section E & death date compute nights in NH
MAKEDATE nh_enter_date N1676 N1678
gen nh_time = curr_iw_date - nh_enter_date
replace nh_time = .  if nh_time < 0
replace nh_nights_1 = round( 365 * nh_time ) if missing(nh_nights_1)

/*
          E7.
                  (Altogether) How many nights was (he/she) a patient
                  in a nursing home (since last interview month/year/in the last two
          years before (he/she) died)?

                  USE 996  FOR CONTINUOUS SINCE ENTERED
*/

*compute NH nights using second set of questions in section E (respondent can answer in nights or months) 
gen nh_nights_2 = N1683
replace nh_nights_2 = . if nh_nights_2 == 996 | nh_nights_2 == 998 | nh_nights_2 == 999		//996: continuous since entered
gen nh_months_2 = N1684
replace nh_months_2 = . if nh_months_2 == 98 | nh_months_2 == 99
replace nh_nights_2 = round( (365/12) * nh_months_2 ) if missing(nh_nights_2)

*define the number of nights from the 2nd calculation, or from the 1st if the 2nd is missing:
gen nh_nights = nh_nights_2
replace nh_nights = nh_nights_1 if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12) * months ) if !missing(nh_nights)

recode N1709 (98 99 = .), gen(dr_visits)
recode N1709 (0=0) (1/97=1) (98=8) (99 = 9), gen(doctor_use)
gen doctor_cov = N1712

gen hospice_use = N1699
gen hospice_cov = N1702

gen rx_use = N1744
gen rx_cov = N1748

gen home_use = N1760
gen home_cov = N1762

gen special_use = N1774

gen other_use = N1791

gen non_med_use = N1804

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit1995_use.dta, replace

********************************************************************************

use $savedir/exit1996.dta, clear
merge 1:1 HHID PN using $savedir/exit1996_months.dta, nogen keep(match)

gen cause_die = P234M1M

gen nh_liv = P249
gen loc_die = P226

gen mc_cov = P2166
gen mc_b_cov = P2167
gen md_cov = P2177
gen gov_oth_cov = P2198

gen hospital_use = P1245
gen hospital_cov = P1253

*Number of nights in hospital
gen hospital_nights = P1247
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = P1238
replace hosp_tbd = . if hosp_tbd == 98 | hosp_tbd == 99
gen hosp_time_unit = P1238A
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1	//hours
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2	//days/nights
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3	//weeks
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4	//months
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5	//years
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = P1262
gen nh_cov = P1267

*compute nh nights using first set of questions in section E (respondent can answer using nights, months, or since a certain date)
gen nh_nights_1 = P1255
replace nh_nights_1 = . if nh_nights_1 == 998 | nh_nights_1 == 999
gen nh_months_1 = P1256
replace nh_months_1 = . if nh_months_1 == 98 | nh_months_1 == 99
replace nh_nights_1 = round( (365/12) * nh_months_1 ) if missing(nh_nights_1)

*using NH entry date in section E & death date compute nights in NH
MAKEDATE nh_enter_date P1257 P1259
gen nh_time = curr_iw_date - nh_enter_date
replace nh_time = .  if nh_time < 0
replace nh_nights_1 = round( 365 * nh_time ) if missing(nh_nights_1)

*compute NH nights using second set of questions in section E (respondent can answer in nights or months) 
gen nh_nights_2 = P1264
replace nh_nights_2 = . if nh_nights_2 == 996 | nh_nights_2 == 998 | nh_nights_2 == 999		//996: continuous since entered
gen nh_months_2 = P1265
replace nh_months_2 = . if nh_months_2 == 98 | nh_months_2 == 99
replace nh_nights_2 = round( (365/12) * nh_months_2 ) if missing(nh_nights_2)

*define the number of nights from the 2nd calculation, or from the 1st if the 2nd is missing:
gen nh_nights = nh_nights_2
replace nh_nights = nh_nights_1 if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12) * months ) if !missing(nh_nights)

recode P1290 (997 998 999 = .), gen(dr_visits)
recode P1290 (0=0) (1/996=1) (997=7) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = P1329

gen hospice_use = P1280
gen hospice_cov = P1283

gen rx_use = P1325
gen rx_cov = P1329

gen home_use = P1341
gen home_cov = P1343

gen special_use = P1355

gen other_use = P1372

gen non_med_use = P1385

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit1996_use.dta, replace

********************************************************************************

use $savedir/exit1998.dta, clear
merge 1:1 HHID PN using $savedir/exit1998_months.dta, nogen keep(match)

gen cause_die = Q497M1M

gen nh_liv = Q519
gen loc_die = Q491

gen mc_cov = Q2560
gen mc_b_cov = Q2561
gen md_cov = Q2562
gen gov_oth_cov = Q2572

gen hospital_use = Q1728
gen hospital_cov = Q1735

*Number of nights in hospital
gen hospital_nights = Q1730
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = Q1722
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = Q1723
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = Q1743
gen nh_cov = Q1748

*compute nh nights using first set of questions in section E (respondent can answer using nights, months, or since a certain date)
*USE 996  FOR CONTINUOUS SINCE ENTERED OR (since Q218-PREV WAVE IW MONTH / Q219-PREV WAVE IW YEAR/in the last two years)
gen nh_nights_1 = Q1736
replace nh_nights_1 = . if nh_nights_1 == 996 | nh_nights_1 == 998 | nh_nights_1 == 999
gen nh_months_1 = Q1737
replace nh_months_1 = . if nh_months_1 == 98 | nh_months_1 == 99
replace nh_nights_1 = round( (365/12) * nh_months_1 ) if missing(nh_nights_1)

*using NH entry date in section E & death date compute nights in NH
MAKEDATE nh_enter_date Q1738 Q1740
gen nh_time = curr_iw_date - nh_enter_date
replace nh_time = .  if nh_time < 0
replace nh_nights_1 = round( 365 * nh_time ) if missing(nh_nights_1)

*compute NH nights using second set of questions in section E (respondent can answer in nights or months) 
gen nh_nights_2 = Q1745
replace nh_nights_2 = . if nh_nights_2 == 996 | nh_nights_2 == 998 | nh_nights_2 == 999
gen nh_months_2 = Q1746
replace nh_months_2 = . if nh_months_2 == 98 | nh_months_2 == 99
replace nh_nights_2 = round( (365/12) * nh_months_2 ) if missing(nh_nights_2)

*define the number of nights from the 2nd calculation, or from the 1st if the 2nd is missing:
gen nh_nights = nh_nights_2
replace nh_nights = nh_nights_1 if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12) * months ) if !missing(nh_nights)

recode Q1778 (998 999 = .), gen(dr_visits)
recode Q1778 (0=0) (1/997=1) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = Q1779

gen hospice_use = Q1764
gen hospice_cov = Q1769

gen rx_use = Q1792
gen rx_cov = Q1793

gen home_use = Q1804
gen home_cov = Q1806

gen special_use = Q1808

gen other_use = Q1817

gen non_med_use = Q1843

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit1998_use.dta, replace

********************************************************************************

use $savedir/exit2000.dta, clear
merge 1:1 HHID PN using $savedir/exit2000_months.dta, nogen keep(match)

gen cause_die = R531M1M

gen nh_liv = R558
gen loc_die = R525

gen mc_cov = R2585
gen mc_b_cov = R2587
gen md_cov = R2588
gen gov_oth_cov = R2598

gen hospital_use = R1739
gen hospital_cov = R1746

*Number of nights in hospital
gen hospital_nights = R1741
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = R1735
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = R1736
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap nights
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = R1754
gen nh_cov = R1759

*compute nh nights using first set of questions in section E (respondent can answer using nights, months, or since a certain date)
*USE 996  FOR CONTINUOUS SINCE ENTERED OR (since Q218-PREV WAVE IW MONTH / Q219-PREV WAVE IW YEAR/in the last two years)
gen nh_nights_1 = R1747
replace nh_nights_1 = . if nh_nights_1 == 996 | nh_nights_1 == 998 | nh_nights_1 == 999
gen nh_months_1 = R1748
replace nh_months_1 = . if nh_months_1 == 98 | nh_months_1 == 99
replace nh_nights_1 = round( (365/12) * nh_months_1 ) if missing(nh_nights_1)

*using NH entry date in section E & death date compute nights in NH
MAKEDATE nh_enter_date R1749 R1751
gen nh_time = curr_iw_date - nh_enter_date
replace nh_time = .  if nh_time < 0
replace nh_nights_1 = round( 365 * nh_time ) if missing(nh_nights_1)

*compute NH nights using second set of questions in section E (respondent can answer in nights or months) 
gen nh_nights_2 = R1756
replace nh_nights_2 = . if nh_nights_2 == 996 | nh_nights_2 == 998 | nh_nights_2 == 999
gen nh_months_2 = R1757
replace nh_months_2 = . if nh_months_2 == 98 | nh_months_2 == 99
replace nh_nights_2 = round( (365/12) * nh_months_2 ) if missing(nh_nights_2)

*define the number of nights from the 2nd calculation, or from the 1st if the 2nd is missing:
gen nh_nights = nh_nights_2
replace nh_nights = nh_nights_1 if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12) * months ) if !missing(nh_nights)

recode R1789 (998 999 = .), gen(dr_visits)
recode R1789 (0=0) (1/997=1) (998=8) (999 = 9), gen(doctor_use)
gen doctor_cov = R1795

gen hospice_use = R1775
gen hospice_cov = R1780

gen rx_use = R1808
gen rx_cov = R1809

gen home_use = R1820
gen home_cov = R1822

gen special_use = R1824

gen other_use = R1834

gen non_med_use = R1863

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2000_use.dta, replace

********************************************************************************

use $savedir/exit2002.dta, clear
merge 1:1 HHID PN using $savedir/exit2002_months.dta, nogen keep(match)

gen cause_die = SA133M1M

gen mc_cov = SN001
gen mc_b_cov = SN004
gen md_cov = SN005
gen gov_oth_cov = SN007

gen private_medigap_plans = SN023

gen nh_liv = SA028
gen loc_die = SA124

gen hospital_use = SN099
gen hospital_cov = SN102

*impute using number of nights spent in hospital; first compute # nights, cap by time elapsed b/w IWs:
gen hospital_nights = SN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = SN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = SN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = SN114
gen nh_cov = SN118

*impute using number of nights spent in NH; first compute # nights, impute missing where possible:
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = SN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = SN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs SA065 SA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if SA028==1 | SA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (SN115==1 | SN115==. | SN115==98 | SN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 SN123_1 SN124_1
MAKEDATE nh_exit_date_1  SN125_1 SN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & SN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 SN123_2 SN124_2
MAKEDATE nh_exit_date_2  SN125_2 SN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & SN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 SN123_3 SN124_3
MAKEDATE nh_exit_date_3  SN125_3 SN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & SN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen dr_visits = SN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits SN148 SN149 SN150 SN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & SN147==998
replace doctor_use = 9 if missing(doctor_use) & SN147==999

gen doctor_cov = SN152

gen hospice_use = SN320
gen hospice_cov = SN324

*impute using number of nights spent in hospice:
gen hospice_nights = SN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = SN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = SN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = SN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = SN175
gen rx_cov = SN176

gen home_use = SN189
gen home_cov = SN190

gen other_use = SN332

gen non_med_use = SN337

gen special_use = SN202
gen special_cov = SN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2002_use.dta, replace

********************************************************************************

use $savedir/exit2004.dta, clear
merge 1:1 HHID PN using $savedir/exit2004_months.dta, nogen keep(match)

gen cause_die = TA133M1M

gen mc_cov = TN001
gen mc_b_cov = TN004
gen md_cov = TN005
gen gov_oth_cov = TN007

gen private_medigap_plans = TN023

gen nh_liv = TA167
gen loc_die = TA124

gen hospital_use = TN099
gen hospital_cov = TN102

*impute using number of nights spent in hospital; first compute # nights, cap by time elapsed b/w IWs:
gen hospital_nights = TN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = TN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = TN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = TN114
gen nh_cov = TN118

*impute using number of nights spent in NH; first compute # nights, impute missing where possible:
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = TN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = TN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs TA065 TA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if TA167==1 | TA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (TN115==1 | TN115==. | TN115==98 | TN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 TN123_1 TN124_1
MAKEDATE nh_exit_date_1  TN125_1 TN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & TN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 TN123_2 TN124_2
MAKEDATE nh_exit_date_2  TN125_2 TN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & TN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 TN123_3 TN124_3
MAKEDATE nh_exit_date_3  TN125_3 TN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & TN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen dr_visits = TN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits TN148 TN149 TN150 TN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & TN147==998
replace doctor_use = 9 if missing(doctor_use) & TN147==999

gen doctor_cov = TN152

gen hospice_use = TN320
gen hospice_cov = TN324

*impute using number of nights spent in hospice:
gen hospice_nights = TN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = TN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = TN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = TN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = TN175
gen rx_cov = TN176

gen home_use = TN189
gen home_cov = TN190

gen other_use = TN332

gen non_med_use = TN337

gen special_use = TN202
gen special_cov = TN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2004_use.dta, replace

********************************************************************************

use $savedir/exit2006.dta, clear
merge 1:1 HHID PN using $savedir/exit2006_months.dta, nogen keep(match)

gen cause_die = UA133M1M

gen mc_cov = UN001
gen mc_b_cov = UN004
gen md_cov = UN005
gen gov_oth_cov = UN007

gen private_medigap_plans = UN023

gen nh_liv = UA167
gen loc_die = UA124

gen hospital_use = UN099
gen hospital_cov = UN102

*impute using number of nights spent in hospital; first compute # nights, cap by time elapsed b/w IWs:
gen hospital_nights = UN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = UN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = UN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = UN114
gen nh_cov = UN118

*impute using number of nights spent in NH; first compute # nights, impute missing where possible:
*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = UN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = UN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs UA065 UA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if UA167==1 | UA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (UN115==1 | UN115==. | UN115==98 | UN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 UN123_1 UN124_1
MAKEDATE nh_exit_date_1  UN125_1 UN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & UN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 UN123_2 UN124_2
MAKEDATE nh_exit_date_2  UN125_2 UN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & UN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 UN123_3 UN124_3
MAKEDATE nh_exit_date_3  UN125_3 UN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & UN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen dr_visits = UN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits UN148 UN149 UN150 UN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & UN147==998
replace doctor_use = 9 if missing(doctor_use) & UN147==999

gen doctor_cov = UN152

gen hospice_use = UN320
gen hospice_cov = UN324

*impute using number of nights spent in hospice:
gen hospice_nights = UN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = UN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = UN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = UN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = UN175
gen rx_cov = UN176

gen home_use = UN189
gen home_cov = UN190

gen other_use = UN332

gen non_med_use = UN337

gen special_use = UN202
gen special_cov = UN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2006_use.dta, replace

********************************************************************************

use $savedir/exit2008.dta, clear
merge 1:1 HHID PN using $savedir/exit2008_months.dta, nogen keep(match)

gen cause_die = VA133M1M

gen mc_cov = VN001
gen mc_b_cov = VN004
gen md_cov = VN005
gen gov_oth_cov = VN007

gen private_medigap_plans = VN023

gen nh_liv = VA167
gen loc_die = VA124

gen hospital_use = VN099
gen hospital_cov = VN102

gen hospital_nights = VN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = VN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = VN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = VN114
gen nh_cov = VN118

*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = VN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = VN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs VA065 VA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if VA167==1 | VA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (VN115==1 | VN115==. | VN115==98 | VN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 VN123_1 VN124_1
MAKEDATE nh_exit_date_1  VN125_1 VN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & VN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 VN123_2 VN124_2
MAKEDATE nh_exit_date_2  VN125_2 VN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & VN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 VN123_3 VN124_3
MAKEDATE nh_exit_date_3  VN125_3 VN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & VN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen dr_visits = VN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits VN148 VN149 VN150 VN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & VN147==998
replace doctor_use = 9 if missing(doctor_use) & VN147==999

gen doctor_cov = VN152

gen hospice_use = VN320
gen hospice_cov = VN324

gen hospice_nights = VN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = VN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = VN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = VN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = VN175
gen rx_cov = VN176

gen home_use = VN189
gen home_cov = VN190

gen other_use = VN332

gen non_med_use = VN337

gen special_use = VN202
gen special_cov = VN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2008_use.dta, replace

********************************************************************************

use $savedir/exit2010.dta, clear
merge 1:1 HHID PN using $savedir/exit2010_months.dta, nogen keep(match)

gen cause_die = WA133M1M

gen mc_cov = WN001
gen mc_b_cov = WN004
gen md_cov = WN005
gen gov_oth_cov = WN007

gen private_medigap_plans = WN023

gen nh_liv = WA028
gen loc_die = WA124

gen hospital_use = WN099
gen hospital_cov = WN102

gen hospital_nights = WN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = WN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = WN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = WN114
gen nh_cov = WN118

*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = WN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = WN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs WA065 WA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if WA028==1 | WA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (WN115==1 | WN115==. | WN115==98 | WN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008,2010 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 WN123_1 WN124_1
MAKEDATE nh_exit_date_1  WN125_1 WN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & WN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 WN123_2 WN124_2
MAKEDATE nh_exit_date_2  WN125_2 WN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & WN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 WN123_3 WN124_3
MAKEDATE nh_exit_date_3  WN125_3 WN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & WN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = WN134
gen patient_cov = WN135

gen dr_visits = WN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits WN148 WN149 WN150 WN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)
replace doctor_use = 8 if missing(doctor_use) & WN147==998
replace doctor_use = 9 if missing(doctor_use) & WN147==999

gen doctor_cov = WN152

gen dental_use = WN164
gen dental_cov = WN165

gen hospice_use = WN320
gen hospice_cov = WN324

gen hospice_nights = WN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = WN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = WN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = WN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = WN175
gen rx_cov = WN176

gen home_use = WN189
gen home_cov = WN190

gen other_use = WN332

gen home_modif_use = WN267

gen special_use = WN202
gen special_cov = WN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2010_use.dta, replace

********************************************************************************

use $savedir/exit2012.dta, clear
merge 1:1 HHID PN using $savedir/exit2012_months.dta, nogen keep(match)

gen cause_die = XA133M1M

gen mc_cov = XN001
gen mc_b_cov = XN004
gen md_cov = XN005
gen gov_oth_cov = XN007

gen private_medigap_plans = XN023

gen nh_liv = XA028
gen loc_die = XA124

gen hospital_use = XN099
gen hospital_cov = XN102

gen hospital_nights = XN101
replace hospital_nights = . if hospital_nights == 998 | hospital_nights == 999

*if died in hospital, calculate time before death
gen hosp_tbd = XN301
replace hosp_tbd = . if hosp_tbd == 998 | hosp_tbd == 999
gen hosp_time_unit = XN302
replace hosp_tbd = (1/24)   * hosp_tbd if hosp_time_unit == 1
replace hosp_tbd = 1        * hosp_tbd if hosp_time_unit == 2
replace hosp_tbd = 7        * hosp_tbd if hosp_time_unit == 3
replace hosp_tbd = (365/12) * hosp_tbd if hosp_time_unit == 4
replace hosp_tbd = 365      * hosp_tbd if hosp_time_unit == 5
replace hosp_tbd = .                   if (hosp_time_unit==8 | hosp_time_unit==9) & hosp_tbd != 0
replace hosp_tbd = round(hosp_tbd)

replace hospital_nights = hosp_tbd if missing(hospital_nights)

*cap at time elapsed between interviews
replace hospital_nights = min( hospital_nights , (365/12)*months ) if !missing(hospital_nights)

gen nh_use = XN114
gen nh_cov = XN118

*IF R ANSWERS IN MONTHS RATHER THAN NIGHTS, ENTER 0 FOR NIGHTS
*IWER: ENTER 996 FOR CONTINUOUS SINCE ENTERED OR  since [PREV WAVE IW MONTH], [PREV WAVE IW YEAR]/since [PREV WAVE IW YEAR]/in the last two years)
gen nh_nights = XN116
replace nh_nights = . if nh_nights == 996 | nh_nights == 998 | nh_nights == 999
gen nh_months = XN117
replace nh_months = . if nh_months == 98 | nh_months == 99
replace nh_nights = round( (365/12) * nh_months ) if missing(nh_nights) | nh_nights==0

*using coverscreen NH entry date, compute time in NH
*if NH nights missing, R lives in NH, and # stays == 1 | missing | unknown, use this value:
MAKEDATE nh_enter_date_cs XA065 XA066
gen nh_time_cs = curr_iw_date - nh_enter_date_cs if XA028==1 | XA124==2
replace nh_time_cs = . if nh_time_cs < 0
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights) & (XN115==1 | XN115==. | XN115==98 | XN115==99)

*using NH entry & exit dates (up to 3) in section NH, do similar procedure
*if exit date missing, and R still lives in NH (exit year == 9995) (2006,2008,2010 exit IWs only), replace exit date with current IW date:
MAKEDATE nh_enter_date_1 XN123_1 XN124_1
MAKEDATE nh_exit_date_1  XN125_1 XN126_1
replace nh_exit_date_1 = curr_iw_date if nh_exit_date_1 == . & XN126_1 == 9995
gen nh_time_1 = nh_exit_date_1 - nh_enter_date_1
replace nh_time_1 = .  if nh_time_1 < 0

MAKEDATE nh_enter_date_2 XN123_2 XN124_2
MAKEDATE nh_exit_date_2  XN125_2 XN126_2
replace nh_exit_date_2 = curr_iw_date if nh_exit_date_2 == . & XN126_2 == 9995
gen nh_time_2 = nh_exit_date_2 - nh_enter_date_2
replace nh_time_2 = .  if nh_time_2 < 0

MAKEDATE nh_enter_date_3 XN123_3 XN124_3
MAKEDATE nh_exit_date_3  XN125_3 XN126_3
replace nh_exit_date_3 = curr_iw_date if nh_exit_date_3 == . & XN126_3 == 9995
gen nh_time_3 = nh_exit_date_3 - nh_enter_date_3
replace nh_time_3 = .  if nh_time_3 < 0

*sum across stays, replace nights if missing
egen nh_time_sum = rowtotal( nh_time_1 nh_time_2 nh_time_3 ), m
replace nh_nights = round( 365 * nh_time_sum ) if missing(nh_nights)

*fill in remaining missing values using coverscreen where possible if R lives in NH:
replace nh_nights = round( 365 * nh_time_cs ) if missing(nh_nights)

*cap at time elapsed between interviews
replace nh_nights = min( nh_nights , (365/12)*months ) if !missing(nh_nights)

gen patient_use = XN134
gen patient_cov = XN135

gen dr_visits = XN147
replace dr_visits = . if dr_visits == 998 | dr_visits == 999

impute_dr_visits XN148 XN149 XN150 XN151
replace dr_visits = min( dr_visits , (365/12)*months ) if !missing(dr_visits)

recode dr_visits (1/max=1), gen(doctor_use)			//rrd: correct this to use XN150 instead
replace doctor_use = 8 if missing(doctor_use) & XN147==998
replace doctor_use = 9 if missing(doctor_use) & XN147==999

gen doctor_cov = XN152

gen dental_use = XN164
gen dental_cov = XN165

gen hospice_use = XN320
gen hospice_cov = XN324

gen hospice_nights = XN322
replace hospice_nights = . if hospice_nights == 996 | hospice_nights == 998 | hospice_nights == 999

gen hospice_months = XN323
replace hospice_months = . if hospice_months == 998 | hospice_months == 999
replace hospice_nights = round( (365/12) * hospice_months ) if missing(hospice_nights)

gen hospice_tbd_days = XN315
replace hospice_tbd_days = . if (hospice_tbd_days == 998 | hospice_tbd_days == 999)
gen hospice_tbd_months = XN316
replace hospice_tbd_months = . if (hospice_tbd_months == 98 | hospice_tbd_months == 99)

replace hospice_nights = hospice_tbd_days if missing(hospice_nights)

*cap at time elapsed between IWs
replace hospice_nights = round( (365/12) * hospice_tbd_months ) if missing(hospice_nights)

gen rx_use = XN175
gen rx_cov = XN176

gen home_use = XN189
gen home_cov = XN190

gen other_use = XN332

gen home_modif_use = XN267

gen special_use = XN202
gen special_cov = XN203

keep HHID PN year *_iw_date months *_use *_liv *_die *_cov *_nights *_visits private_medigap_plans

xtile qtile_hospital = hospital_nights, nq(4)
xtile qtile_nh = nh_nights, nq(4)
xtile qtile_hospice = hospice_nights, nq(4)
xtile qtile_doctor = dr_visits, nq(4)

save $savedir/exit2012_use.dta, replace



********************************************************************************

use $savedir/exit1995_use.dta, clear

append using ///
$savedir/exit1996_use.dta ///
$savedir/exit1998_use.dta ///
$savedir/exit2000_use.dta ///
$savedir/exit2002_use.dta ///
$savedir/exit2004_use.dta ///
$savedir/exit2006_use.dta ///
$savedir/exit2008_use.dta ///
$savedir/exit2010_use.dta ///
$savedir/exit2012_use.dta

sort HHID PN year		

save $savedir/exit_use.dta, replace
