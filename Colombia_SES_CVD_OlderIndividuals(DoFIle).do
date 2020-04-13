


/*

This do-file replicates analyses presented in the study titled:
"Socio-economic inequalities in high blood pressure and additional risk factors for cardiovascular 
disease among older individuals in Colombia: results from a nationally representative study"

Full replication materials as well as additional information is available here: 
https://github.com/PhilippHessel/Colombia_SES_CVD_OlderIndividuals

Authors: 
1) Philipp Hessel, PhD (Universidad de Los Andes)
2) Paul Rodríguez-Lesmes, PhD (Universidad del Rosario)
3) David Torres, BA (Universidad de Los Andes)

Corresponding author's contact details: 

Philipp Hessel, PhD
Associate Professor
Alberto Lleras Camargo School of Government
University of the Andes
Bogotá, Colombia
Tel: +57 3394949 Ext. 2012
p.hessel@uniandes.edu.co

*/


* STEP 1: MERGING REQUIRED DATASETS
************************************************************************************
************************************************************************************
/* 

For the present study we used variables from the following chapters: 1 (Cap1Parte1 & Cap1Ident), 2, 3, 5, 7, 8, 10, 12 & biomarkers

The data have a unique personal identifier in the form of the variable called "NumIdentificador" and can be merged using the latter.
*/

clear all

cd "/Users/philipphessel/Google Drive/Projects/PLoS One Paper/PLoS_RR/Output/"

local data "/Users/philipphessel/Google Drive/Data/SABE/SABE 2015/Base dta/" // Insert here the folder-path where the datasets are stored

local dataset Cap1Ident.dta Cap1.dta Cap1Parte1.dta Cap2.dta Cap3.dta Cap5.dta Cap7.dta Cap8EnfNoTrans Cap12.dta Biom.dta


* Sorting individual ID (NumIdentificador) so that separate datasets can be merged
************************************************************************************

/*
foreach x of local dataset {
use "`data'`x'"
sort NumIdentificador
save "`data'`x'", replace
} */

clear all

* Merging datasets and selecting variables being used
************************************************************************************

use "`data'Cap1Parte1.dta"
keep NumIdentificador P121 P122EDAD
merge 1:1 NumIdentificador using "`data'Cap1Ident.dta", keepusing(RegionUT)
rename _merge merge_Cap1Ident
merge 1:1 NumIdentificador using "`data'Cap1.dta", keepusing(EDADPROXI)
rename _merge merge_Cap1
merge 1:1 NumIdentificador using "`data'Cap2.dta", keepusing(P204)
rename _merge merge_Cap2
merge 1:1 NumIdentificador using "`data'Cap3.dta", keepusing(P303 P304 P305 P306 P307 P308 P311 P315_1 P315_2 P315_3 P315_4 P315_5 P315_6 P315_7 P315_8 P315_9 P315_10 P315_11 P315_12 P315_13 P315_14 P315_15 P315_16 P315_17 P326_1 P326_2 P326_3 P326_4 P327 P328 P329)
rename _merge merge_Cap3
merge 1:1 NumIdentificador using "`data'Cap5.dta", keepusing(P511 P506 P509) 
rename _merge merge_Cap5
merge 1:1 NumIdentificador using "`data'Cap7.dta", keepusing(P719) 
rename _merge merge_Cap7
merge 1:1 NumIdentificador using "`data'Cap8EnfNoTrans.dta", keepusing(P810 P811_1 P811_2 P811_3 P811_4 P811_5 P811_6 P811_7) 
rename _merge merge_Cap8
merge 1:1 NumIdentificador using "`data'Cap10.dta", keepusing(P1005PESO P1006TALLA) 
rename _merge merge_Cap10
merge 1:1 NumIdentificador using "`data'Cap12.dta", keepusing(P1201T1BD P1201T1PBI P1201T2BD P1201T3BD P1201T2BI P1201T3BI P1201T1BD_1 P1201T2BD_1 P1201T3BD_1) 
rename _merge merge_Cap12
merge 1:1 NumIdentificador using "`data'Biom.dta", keepusing(COLESTEROL_TOTAL COLESTEROL_HDL) 
rename _merge merge_Biom

save master.dta, replace






* STEP 2: CREATING VARIABLES
************************************************************************************
************************************************************************************


* Identify if observation is based on proxy interview(ee)
************************************************************************************

gen proxy=1 if EDADPROXI!=.

* region
tab RegionUT, gen(region) // creates dummies for each of the 6 main regions of Colombia


*gender
gen gender=P121
label var gender "gender: 1=men, 2=woman" 
label define sex 1 "men" 2 "woman"
label values gender sex

*age
gen age_linear=P122EDAD
label var age_linear "age in years"
recode age (60/64 =1) ( 65/69 = 2) ( 70/74=3) (75/100=4), gen(ageG)
label var ageG "age groups"

* education
gen education_3_levels=P204
	replace education_3_levels=1 if P204==1
	replace education_3_levels=2 if P204==2 | P204==3
	replace education_3_levels=3 if P204>=4
label var education_3_levels "highest educ. level achieved"
label define education 1 "None" 2 "Primary" 3 "Secondary / Post-Secondary"
label values education_3_levels education 
tab  education_3_levels

* assets
gen assets_index = P315_1 + P315_2 + P315_3 + P315_4 + P315_5 + P315_6 + P315_7 + P315_8 + P315_9 + P315_10 + P315_11 + P315_12 + P315_13 + P315_14 + P315_16 + P315_17 
label var assets_index "index of household assets"
tab assets_index
* hist assets_index 

* smoking
gen smoking=P511
replace smoking=0 if P511==2 | P511==4
replace smoking=1 if P511==1 | P511==3
replace smoking=. if P511==8 | P511==9
label var smoking "current smoking"
label define smoking 0 "not currently" 1 "currently yes"
label values smoking smoking

* alcohol consumption
gen alcohol=P509
recode alcohol (5=0) (1/4=1)
replace alcohol=. if alcohol==8 | alcohol==9
label var alcohol "alcohol consumption"
label define alcohol 0 "never" 1 "less than every day, or more"
label values alcohol alcohol

* fruits or vegetables
gen fruits_vegetables=P506
replace fruits_vegetables=. if fruits_vegetables==0 | fruits_vegetables==8 | fruits_vegetables==9
recode fruits_vegetables (1=0) (2=1)  // NO APLICA A PROXI de la pregunta 501 a la 508
label var fruits_vegetables "eating fruits or vegetables at least once a day"
label define fruits_vegetables 0 "yes" 1 "no"
label values fruits_vegetables fruits_vegetables

* physical activity
gen physical_activity=P719
recode physical_activity (1=0) (2=1)
label var physical_activity "physical activity 3x per week"
label define physical_activity 0 "yes" 1 "no"
label values physical_activity physical_activity

* bmi, obesity & overweight

gen weight_kg=P1005PESO
replace weight_kg=. if weight_kg==777 | weight_kg==0

gen height_m=P1006TALLA/100
replace height_m=. if height_m==0 | height_m>7

gen bmi=weight_kg/height_m^2
label var bmi "body mass index"

gen overweight=bmi
recode overweight (0/25=0) (25/100=1)
label var overweight "BMI>25"

gen obese=bmi
recode obese (0/30=0) (30/100=1)
label var obese "BMI>30"

* blood pressure 
************************************************************************************

	* blood pressure (mm Hg)

	* systolic
	gen blood_pressure1right_s=P1201T1BD
	replace blood_pressure1right_s=. if blood_pressure1right_s==0 | blood_pressure1right_s==999  | blood_pressure1right_s==8888
	label var blood_pressure1right_s "systolic blood pressure in mm Hg (right arm, 1st take)"	
	
	gen blood_pressure2right_s=P1201T2BD
	replace blood_pressure2right_s=. if blood_pressure2right_s==0 | blood_pressure2right_s==999  | blood_pressure2right_s==8888
	label var blood_pressure2right_s "systolic blood pressure in mm Hg (right arm, 2nd take)"

	gen blood_pressure3right_s=P1201T3BD
	replace blood_pressure3right_s=. if blood_pressure3right_s==0 | blood_pressure3right_s==999  | blood_pressure3right_s==8888
	label var blood_pressure3right_s "systolic blood pressure in mm Hg (right arm, 3rd take)"

	* diastolic
	gen blood_pressure1right_d=P1201T1BD_1 
	replace blood_pressure1right_d=. if blood_pressure1right_d==0 | blood_pressure1right_d==999  | blood_pressure1right_d==8888
	label var blood_pressure1right_d "diastolic blood pressure in mm Hg (right arm, 1st take)"	
	
	gen blood_pressure2right_d=P1201T2BD_1
	replace blood_pressure2right_d=. if blood_pressure2right_d==0 | blood_pressure2right_d==999  | blood_pressure2right_d==8888
	label var blood_pressure2right_d "diastolic blood pressure in mm Hg (right arm, 2nd take)"

	gen blood_pressure3right_d=P1201T3BD_1
	replace blood_pressure3right_d=. if blood_pressure3right_d==0 | blood_pressure3right_d==999  | blood_pressure3right_d==8888
	label var blood_pressure3right_d "diastolic blood pressure in mm Hg (right arm, 3rd take)"
	
	* average of 2nd & 3rd measure of right arm
	gen blood_pressure_s=(blood_pressure2right_s+blood_pressure3right_s)/2 // average of 2nd and 3rd measurement
	gen blood_pressure_d=(blood_pressure2right_d+blood_pressure3right_d)/2 // average of 2nd and 3rd measurement

	* objective hypertension
	gen hypertension_objective_s=. // systolic
	gen hypertension_objective_d=. // diastolic

	* systolic
	replace hypertension_objective_s=1 if blood_pressure2right_s>=140 & blood_pressure3right_s >=140 & blood_pressure2right_s!=. & blood_pressure3right_s!=. & blood_pressure_s!=.
	replace hypertension_objective_s=0 if hypertension_objective_s!=1 & blood_pressure2right_s!=. & blood_pressure3right_s!=. & blood_pressure_s!=.
	
	* distolic
	replace hypertension_objective_d=1 if blood_pressure2right_d>=90 & blood_pressure3right_d>=90 & blood_pressure2right_d!=. & blood_pressure3right_d!=. & blood_pressure_d!=.
	replace hypertension_objective_d=0 if hypertension_objective_d!=1 & blood_pressure2right_d!=. & blood_pressure3right_d!=. & blood_pressure_d!=.
	
	* high blood pressure (HBP) dummy
	
	gen hypertension_dummy=.
	replace hypertension_dummy=1 if hypertension_objective_s==1 | hypertension_objective_d==1
	replace hypertension_dummy=0 if hypertension_objective_s==0 & hypertension_objective_d==0
	tab hypertension_dummy


* deleting variables not needed anymore 

drop P204-COLESTEROL_TOTAL






* STEP 3: SAMPLE DEFINITION
************************************************************************************
************************************************************************************

* Setting sample
************************************************************************************

reg $hypertension_dummy $education $assets_quartiles $dbp $sbp $risk_factors $controls if proxy!=1
gen hbp_sample=e(sample) // defines sample that has all variables needed for CVD analyses

* creating assets quartiles for sub-sample being used
************************************************************************************
xtile assets_index_quartile=assets_index,n(4) // creates quartiles of household assets
label define assets_quart 1 "1st quartile (most deprived)" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile (most affluent)"
label values assets_index_quartile assets_quart

* define locals
************************************************************************************
glo controls gender region4 region6 region1 region2 region3 i.ageG
glo education i.education_3_levels
glo sbp blood_pressure_s
glo dbp blood_pressure_d
glo hypertension_dummy hypertension_dummy
glo risk_factors smoking alcohol fruits_vegetables physical_activity obese
glo assets i.assets_index_quartile
glo assets_linear assets_index_quartile

* Calculate sample missings
************************************************************************************

/* 
Total N=23,694
Non proxy, with education=23,601
Non proxy, with education & BP=4,344 */
sum NumIdentificador if proxy!=1 & age_linear!=. & gender!=. & education_3_levels!=. & blood_pressure_s!=. & blood_pressure_d!=. & hypertension_dummy!=. /* 
With height & weight=4,020 */ 
sum NumIdentificador if proxy!=1 & age_linear!=. & gender!=. & education_3_levels!=. & blood_pressure_s!=. & blood_pressure_d!=. & hypertension_dummy!=. & bmi!=. /*
Other missings=4,007 */



* Keeping only HBP sample
******************************************

keep if hbp_sample==1

* Table 1: Descriptives
******************************************

bys gender: sum age_linear
bys gender: tab RegionUT
bys gender: tab education_3_levels
bys gender: sum assets_index
bys gender: sum blood_pressure_s
bys gender: sum blood_pressure_d
bys gender: tab hypertension_objective_s
bys gender: tab hypertension_objective_d
bys gender: tab hypertension_dummy
bys gender: tab smoking 
bys gender: tab alcohol 
bys gender: tab fruits_vegetables 
bys gender: tab physical_activity 
bys gender: tab obese



* STEP 4: ANALYSES MAIN
******************************************
******************************************

	
* objective hypertension
************************************************************************************

	* education

	logit $hypertension_dummy $education $controls , or
		test (1.education_3_levels=0) (2.education_3_levels=0) (3.education_3_levels=0) 
		estadd scalar testAll = r(p)		
	est store hypertens_edu
	
		* test for gender differences
		logit hypertension_dummy i.education_3_levels##i.gender $controls, or // no significant interactions

	
	* assets
	
	logit $hypertension_dummy $assets $controls, or
		test (2.assets_index_quartile=0) (3.assets_index_quartile=0) (4.assets_index_quartile=0)
		estadd scalar testAll = r(p)		
	est store hypertens_assets
	
		* test for gender differences
		logit hypertension_dummy i.assets_index_quartile##i.gender $controls, or // no significant interactions


* association between socio-economic status and key risk factors
************************************************************************************

	* education

	foreach x in $risk_factors {
		logit `x' $education $controls, or
		est store `x'_educ
	}

	* assets

	foreach x in $risk_factors  {
		logit `x' $assets $controls, or	
		est store `x'_asset
	}
	

	*  PRESENTING RESULTS
******************************************
******************************************

save master.dta, replace

* FIGURE 1:
******************************************

bys education_3_levels: tab hypertension_dummy // education
bys assets_index_quartile: tab hypertension_dummy // assets

* education
collapse (mean) hbp_mean = hypertension_dummy (sd) sd_hbp= hypertension_dummy (count) n= hypertension_dummy, by(education_3_levels)
replace hbp_mean=hbp_mean*100
replace sd_hbp=sd_hbp*100
generate hi = hbp_mean + invttail(n-1,0.025)*(sd_hbp / sqrt(n))
generate lo = hbp_mean - invttail(n-1,0.025)*(sd_hbp / sqrt(n))
graph twoway (bar hbp_mean education_3_levels) (rcap hi lo education_3_levels)
graph save Fig1_Edu.gph, replace

use master.dta, clear

* assets
collapse (mean) hbp_mean = hypertension_dummy (sd) sd_hbp= hypertension_dummy (count) n= hypertension_dummy, by(assets_index_quartile)
replace hbp_mean=hbp_mean*100
replace sd_hbp=sd_hbp*100
generate hi = hbp_mean + invttail(n-1,0.025)*(sd_hbp / sqrt(n))
generate lo = hbp_mean - invttail(n-1,0.025)*(sd_hbp / sqrt(n))
graph twoway (bar hbp_mean assets_index_quartile) (rcap hi lo assets_index_quartile)
graph save Fig1_Assets.gph, replace

grc1leg Fig1_Edu.gph Fig1_Assets.gph, col(2) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
graph save Fig1_Combined.gph, replace
graph use Fig1_Combined.gph
graph export Fig1_Combined.png, replace as(png)
graph export Fig1_Combined.eps, replace as(eps)

use master.dta, clear 


* showing regression tables
************************************************************************************
	
	* objective hypertension
	estout hypertens_edu, cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform stats(testAll )
	estout hypertens_assets, cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform stats(testAll )

	* table risk factors
	estout smoking_educ alcohol_educ fruits_vegetables_educ , cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform  stats(testAll) 
	estout physical_activity_educ obese_educ, cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform  stats(testAll) 

	estout smoking_asset alcohol_asset fruits_vegetables_asset , cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform stats( test23 test24 test25 test34 test35 test45 testAll )
	estout physical_activity_asset obese_asset, cells("b(fmt(3)) ci(par( ( ,  ) )) p") eform stats( test23 test24 test25 test34 test35 test45 testAll )

	

	* coefplot education	
	coefplot	(smoking_educ, label(Smoker (yes)) mcolor(black) ciopts(lcolor(black))) ///
				(alcohol_educ, label(Alcohol consumption (yes)) mcolor(gs10) ciopts(lcolor(gs10)) msymbol(D) ) ///
				(fruits_vegetables_educ, label(Fruits or vegetables (no)) mcolor(blue) ciopts(lcolor(blue)) msymbol(T) ) ///
				(physical_activity_educ, label(Physical activity (no))  msymbol(S) ) ///
				(obese_educ, label(Obese (yes))  msymbol(Oh) ), ///
	eform keep(2.education_3_levels 3.education_3_levels) xline(1, lcolor(black) lwidth(thin) lpattern(dash))  title("Education") ///
	xtitle("Odds ratio") ci(95) name(education_risks_RR, replace) ///
	graphregion( fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph save education_risks_RR.gph, replace

	
	* coefplot assets	
	coefplot 	(smoking_asset, label(Smoker (yes)) mcolor(black) ciopts(lcolor(black)))  ///
				(alcohol_asset, label(Alcohol consumption (yes)) mcolor(gs10) ciopts(lcolor(gs10)) msymbol(D) ) ///
				(fruits_vegetables_asset, label(Fruits or vegetables (no)) mcolor(blue) ciopts(lcolor(blue)) msymbol(T) ) ///
				(physical_activity_asset, label(Physical activity (no))  msymbol(S) ) ///
				(obese_asset, label(Obese (yes)) msymbol(Oh) ), ///
	eform keep(2.assets_index_quartile 3.assets_index_quartile 4.assets_index_quartile) xline(1, lcolor(black) lwidth(thin) lpattern(dash)) title("Assets") xlabel(0(0.5)2.5) ///
	xtitle("Odds ratio") ci(95) name(assets_risks_RR, replace) ///
	graphregion( fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph save assets_risks_RR.gph, replace
	
	* graphs combine
	
	grc1leg education_risks_RR.gph assets_risks_RR.gph, col(2) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export risks_RR.png, replace as(png)
	graph export risks_RR.eps, replace as(eps)



* STEP 5: APPENDIX
******************************************
******************************************


* association between socio-economic status and bloopd pressure & hypertension

* systolic blood pressure

	reg $sbp $education $controls , r		
		test (2.education_3_levels=0) (3.education_3_levels=0) 
		estadd scalar testAll = r(p)
	est store sbp_edu
	
	reg $sbp $assets $controls ,r 
		test (2.assets_index_quartile=0) (3.assets_index_quartile=0) (4.assets_index_quartile=0)
		estadd scalar testAll = r(p)
	est store sbp_assets
	
	
* diastolic blood pressure

	reg $dbp $education $controls , r
		test (2.education_3_levels=0) (3.education_3_levels=0) 
		estadd scalar testAll = r(p)
	est store dbp_edu
	
	reg $dbp $assets $controls ,r 
		test (2.assets_index_quartile=0) (3.assets_index_quartile=0) (4.assets_index_quartile=0)
		estadd scalar testAll = r(p)
	est store dbp_assets
	
	* output
	estout sbp_edu, cells("b(fmt(3)) ci(par( ( , ) )) p")  stats(testAll ) 
	estout sbp_assets, cells("b(fmt(3)) ci(par( ( , ) )) p") stats(testAll) 
	estout sbp_edu, cells("b(fmt(3)) ci(par( ( , ) )) p") stats (testAll) 
	estout sbp_assets, cells("b(fmt(3)) ci(par( ( , ) )) p")  stats(testAll) 

	
* STEP 6: End
******************************************
******************************************

save master.dta, replace

