********************************************************************************
** load_macro_lists
** rrd
** all macros for other programs
********************************************************************************

** Used thoughout various .do files
global data_types 			core exit
global core_year_list		1992	1993	1994	1995	1996	1998	2000	2002	2004	2006	2008	2010	2012 	2014
global exit_year_list		1995	1996	1998	2000	2002	2004	2006	2008	2010	2012	2014

********************************************************************************
** load_data 
** Loading Core Data
*global core_year_list		1992	1993	1994	1995	1996	1998	2000	2002	2004	2006	2008	2010	2012	2014	
global core_wave_num_list	1		1		2		2		3		4		5		6		7		8		9		10		11		12		//2012 should be updated to 11 when ready
global core_wave_let_list	A		B		C		D		E		F		G		H		J		K		L		M		N		O
global core_hh_file_list 	HOUSEHLD  BHH21	W2CS	A95CS_H	H96CS_H	H98CS_H	H00CS_H	H02A_H	H04A_H	H06A_H	H08A_H	H10A_H 	H12A_H 	H14A_H
global core_merge1m_list	HEALTH	BR21	.na		A95CS_R H96CS_R	H98CS_R H00CS_R H02A_R	H04A_R	H06A_R	H08A_R	H10A_R	H12A_R	H14A_R 	//1:m on HHSUB
global core_merge11_1_list	.na		.na		W2R		A95R_R	H96E_R	H98E_R	H00E_R	H02N_R	H04N_R	H06N_R	H08N_R	H10N_R	H12N_R	H14N_R 	//1:1 on PN
global core_merge11_2_list	.na		.na		W2B		A95PR_R	H96R_R	H98R_R	H00R_R	.na		.na		.na		.na		.na		.na		.na
global core_merge11_3_list	.na		.na		.na		A95E_R	.na		.na		.na		.na		.na		.na		.na		.na		.na		.na
global core_merge11_4_list	.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na
global core_merge11_5_list	.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na
       
** Loading Exit Data
*global exit_year_list		1995	1996	1998	2000	2002	2004	2006	2008	2010	2012	2014
global exit_wave_num_list	2		3		4		5		6		7		8		9		10		11		12	//2012 should be updated to 11 when ready
global exit_wave_let_list	N		P		Q		R		S		T		U		V		W		X		Y
global exit_hh_file_list 	x95A_R	x96A_R	x98A_R	x00A_R	x02A_R	x04A_R	X06A_R	X08A_R	X10A_R	X12A_R 	X14A_R
global exit_merge1m_list	.na		.na		.na		.na		.na		.na		.na		.na		.na		.na		.na
global exit_merge11_1_list	x95CS_R	x96CS_R	x98CS_R	x00CS_R	x02B_R	x04B_R	X06B_R	X08B_R	X10B_R	X12B_R	X14B_R //1:1 on PN
global exit_merge11_2_list	x95D_R	x96D_R	x98D_R	x00E_R	x02N_R	x04N_R	X06N_R	X08N_R	X10N_R	X12N_R	X14N_R
global exit_merge11_3_list	x95E_R	x96E_R	x98E_R	x00N_R	x02T_R	x04T_R	X06T_R	X08T_R	X10T_R	X12T_R	X14T_R
global exit_merge11_4_list	x95N_R	x96N_R	x98N_R	x00R_R	.na		.na		.na		.na		.na		.na		.na
global exit_merge11_5_list	x95R_R	x96R_R	x98R_R	x00S_R	.na		.na		.na		.na		.na		.na		.na


********************************************************************************
** add_months
global ex_prior_wave_list	C		B		A		//needs to be in reverse order		

*global exit_year_list		1995	1996	1998	2000	2002	2004	2006	2008	2010	2012	2014
global ex_co_wave_let_list	D		E		F		G		H		J		K		L		M		N		O
global death_mo_list		N223	P223	Q488	R520	SA121	TA121	UA121	VA121	WA121	XA121	YA121
global death_yr_list		N225	P225	Q490	R522	SA123	TA123	UA123	VA123	WA123	XA123	YA123


