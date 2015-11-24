******************************************************************************************
  If you are using PC-SAS, you must specify the location of the files 
  on your PC in a libname/filename statement.

LIBNAME LIBRARY "location of formats";
FILENAME IN0 "E:\hrs_code\general_data_setup\HCCsoftware07";  
LIBNAME  IN1 "E:\data\cms_DUA_24548_2012\HCC 2008";
LIBNAME  IN2 "E:\data\cms_DUA_24548_2012\HCC 2008";
LIBNAME  INCOEF "E:\hrs_code\general_data_setup\HCCsoftware07";
LIBNAME  OUT "E:\data\cms_DUA_24548_2012"; 

*OPTIONS nofmterr;
 OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";

 ***********************************************************************
 *
 *   DESCRIPTION:
 *
 * V1206D4P program creates seventy HCC variables (&CMSHCC) and three
 * score variables for each person who is present in a person file
 * supplied by a user.
 * If a person has at least one diagnosis in DIAG file (supplied by a
 * user) then HCC variables are created, otherwise HCCs are set to 0 .
 * Score variables are created using coefficients from 3 final
 * models: community, institutional, new enrollees.
 *
 * Assumptions about input files:
 *   - both files are sorted by person ID
 *
 *   - person level file has the following variables:
 *     :HICNO    - person ID variable
 *     :DOB      - date of birth
 *     :OREC     - original reason for entitlement
 *     :MCAID    - Medicaid dummy variable (base year)
 *     :NEMCAID  - Medicaid dummy variable for new enrollees (predicted
 *                 year)
 *
 *   - diagnosis level file has the following vars:
 *     :HICNO - person ID variable
 *     :DIAG   - diagnosis
 *
 * The program supplies parameters to a main macro %V1206D4M that calls
 * other external macros:
 *
 *      %AGESEXVR  - create age/sex, originally disabled, disabled vars
 *      %EDITICD9  - perform edits to diagnosis
 *      %V12H70M   - assign one ICD9 to multiple CCs
 *      %V12H70L   - assign labels to HCCs
 *      %V12H70H   - set HCC=0 according to hierarchies
 *      %SCOREVR   - calculate score variable
 *
 * Comment: the format:
 *            $I1206YC - is specific for this version of the software
 *            (12- HCC version, 06- FY 2006 ICD9 update, 0- 70 HCCs set)
 *            $I&VR.C - VR=1206Y is a macro parameter for this
 *            update of ICD9. This parameter is set as the default
 *            in V1206D4M macro.
 *            With the new update of ICD9 the new format will be created
 *            and the value of parameter VR will have to be changed.
 *
 *
 * Program steps:
 *         step1: include external macros
 *         step2: define internal macro variables
 *         step3: merge person and diagnosis files outputting one
 *                record per person for each input person level record
 *         step3.1: declaration section
 *         step3.2: bring regression coefficients
 *         step3.3: merge person and diagnosis file
 *         step3.4: for the first record for a person set CC to 0
 *                  and calculate age
 *         step3.5: if there are any diagnoses for a person
 *                  then do the following:
 *                   - create CC using format $ICD9CC
 *                   - perform ICD9 edits using macro EDITICD9
 *                   - create additional CC using MLTCCDG macro
 *         step3.6: for the last record for a person do the
 *                  following:
 *                   - create demographic variables needed
 *                     for regressions (macro AGESEXVR)
 *                   - create HCC using hierarchies (macro V12H70M)
 *                   - create HCC interaction variables
 *                   - create HCC and DISABL interaction variables
 *                   - set HCCs and interaction vars to zero if there
 *                     are no diagnoses for a person
 *                   - create score for community model
 *                   - create score for institutional model
 *                   - create score for new enrollee model
 *         step4: data checks and proc contents
 *
 *   USER CUSTOMIZATION:
 * A user must supply 2 files with the variables described above and
 * set the following parameters:
 *      INP      - SAS input person dataset
 *      IND      - SAS input diagnosis dataset
 *      OUTDATA  - SAS output dataset
 *      IDVAR    - name of person id variable (HICNO for medicare data)
 *      KEEPVAR  - variables to keep in the output dataset in addition
 *                 to 70 HCCs
 *      SEDITS   - a switch that controls whether perform edits on ICD9
 *                1-YES, 0-NO
 *      DATE_ASOF-asof date to calculate age (February 1 of prediction
 *                year)
 ***********************************************************************;


 %LET INPUTVARS=%STR(HICNO SEX DOB MCAID NEMCAID OREC);
 *demographic variables;
 %LET DEMVARS  =%STR(AGEF ORIGDS DISABL
                     F0_34  F35_44 F45_54 F55_59 F60_64 F65_69
                     F70_74 F75_79 F80_84 F85_89 F90_94 F95_GT
                     M0_34  M35_44 M45_54 M55_59 M60_64 M65_69
                     M70_74 M75_79 M80_84 M85_89 M90_94 M95_GT
                     NEF0_34  NEF35_44 NEF45_54 NEF55_59 NEF60_64
                     NEF65    NEF66    NEF67    NEF68    NEF69
                     NEF70_74 NEF75_79 NEF80_84 NEF85_89 NEF90_94
                     NEF95_GT
                     NEM0_34  NEM35_44 NEM45_54 NEM55_59 NEM60_64
                     NEM65    NEM66    NEM67    NEM68    NEM69
                     NEM70_74 NEM75_79 NEM80_84 NEM85_89 NEM90_94
                     NEM95_GT);
  *list of HCCs included in models;
 %LET CMSHCC = %STR(
      HCC1      HCC2      HCC5     HCC7       HCC8
      HCC9      HCC10     HCC15    HCC16      HCC17
      HCC18     HCC19     HCC21    HCC25      HCC26
      HCC27     HCC31     HCC32    HCC33      HCC37
      HCC38     HCC44     HCC45    HCC51      HCC52
      HCC54     HCC55     HCC67    HCC68      HCC69
      HCC70     HCC71     HCC72    HCC73      HCC74
      HCC75     HCC77     HCC78    HCC79      HCC80
      HCC81     HCC82     HCC83    HCC92      HCC95
      HCC96     HCC100    HCC101   HCC104     HCC105
      HCC107    HCC108    HCC111   HCC112     HCC119
      HCC130    HCC131    HCC132   HCC148     HCC149
      HCC150    HCC154    HCC155   HCC157     HCC158
      HCC161    HCC177    HCC164   HCC174     HCC176);

 %LET SCOREVARS=%STR(SCORE_COMMUNITY
                     SCORE_INSTITUTIONAL
                     SCORE_NEW_ENROLLEE);

  %INCLUDE IN0(V1206D4M)/SOURCE2;

  %V1206D4M(INP      =IN1.PERSON,
            IND      =IN2.DIAG,
            OUTDATA  =OUT.PERSON,
            IDVAR    =HICNO,
            KEEPVAR  =&INPUTVARS &SCOREVARS &DEMVARS &CMSHCC /*&ADDVAR*/,
            SEDITS   =1,
            DATE_ASOF="1FEB2007"D);
