

/*

This do-file replicates analyses presented in the study titled "Socio-economic inequalities in biological and behavioral risk factors for 
cardiovascular disease among older individuals in Colombia: results from a nationally representative".

The data come from the SABE study. The data can be requested through the Colombian Ministry of Health using the following link:
https://www.minsalud.gov.co/sites/rid/Paginas/results_advanced.aspx?k=Encuesta+Nacional+de+Salud+Mental+2015#k=Encuesta%20Nacional%20de%20Salud%20Mental%202015

Due to the data sharing policy of the Ministry of Health we are not able to share the data directly with the public.

Authors: 1) Philipp Hessel, PhD (Universidad de Los Andes), 2) Paul Rodríguez-Lesmes, PhD (Universidad del Rosario), 3) David Torres, BA (Universidad de Los Andes)

Contact: 

Philipp Hessel, PhD
Associate Professor
Alberto Lleras Camargo School of Government
University of the Andes
Bogotá, Colombia
Tel: +57 3394949 Ext. 2012
p.hessel@uniandes.edu.co


*/


* STEP 1: MERGING REQUIRED DATASETS
******************************************
******************************************

/* The data supplied by the Ministry of Health come in different datasets, each one representing one of the main chapters of topics in the questionaire/

The questionnaire is supplied alongside this do-file as supplementary material. 

For the present study we used variables from the following chapters: 1 (Cap1Parte1 & Cap1Ident), 2, 3, 5, 7, 8, 10, 12 & biomarkers

The data have a unique personal identifier in the form of the variable called "NumIdentificador" and can be merged using the latter.

*/

set graphics off

clear all

local data "/Users/philipphessel/Google Drive/Data/SABE/SABE 2015/Base dta/" // Insert here the folder-path where the datasets are stored
*global data "F:\paul.rodriguez\Drive\Salud\SABE\Base dta Encuesta SABE\Base dta"

global outpath "/Users/philipphessel/Google Drive/Projects/SABE_CVD/" // Insert here the folder-path where the final datasets shall be stored

global dataset Cap1Ident.dta Cap1.dta Cap1Parte1.dta Cap2.dta Cap3.dta Cap5.dta Cap7.dta Cap8EnfNoTrans Cap12.dta Biom.dta

/*
foreach x of local dataset {
use `data'`x'
sort NumIdentificador
save `data'`x', replace
} */

clear all

use "`data'/Cap1Parte1.dta"
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
merge 1:1 NumIdentificador using "`data'Cap8EnfNoTrans.dta", keepusing(P810) 
rename _merge merge_Cap8
merge 1:1 NumIdentificador using "`data'Cap10.dta", keepusing(P1005PESO P1006TALLA) 
rename _merge merge_Cap10
merge 1:1 NumIdentificador using "`data'Cap12.dta", keepusing(P1201T1BD P1201T1PBI  P1201T2BD P1201T3BD P1201T2BI P1201T3BI) 
rename _merge merge_Cap12
merge 1:1 NumIdentificador using "`data'Biom.dta", keepusing(COLESTEROL_TOTAL COLESTEROL_HDL) 
rename _merge merge_Biom

save final.dta, replace


* STEP 2: CREATING VARIABLES
******************************************
******************************************

* identify if observation is based on proxy interview(ee)

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
gen education_5_levels=P204
	replace education_5_levels=2 if P204==2
	replace education_5_levels=3 if P204==3
	replace education_5_levels=4 if P204==4 | P204==5 | P204==6 | P204==7
	replace education_5_levels=5 if P204==8 | P204==9 | P204==10 | P204==11
label var education_5_levels "highest educ. level achieved"
label define education 1 "None" 2 "Primary incomplete" 3 "Primary complete" ///
4 "Secondary" ///
5 "Post-secondary"
label values education_5_levels education 

* assets
gen assets_index = P315_1 + P315_2 + P315_3 + P315_4 + P315_5 + P315_6 + P315_7 + P315_8 + P315_9 + P315_10 + P315_11 + P315_12 + P315_13 + P315_14 + P315_16 + P315_17 
label var assets_index "index of household assets"
tab assets_index
hist assets_index 

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

* blood pressure and hypertension

* CHECK MEASUREMENT: hypertension_objective= P1201T1BD P1201T1PBI  P1201T2BD P1201T3BD P1201T2BI P1201T3BI
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	* blood pressure

	gen blood_pressure1right=P1201T1BD
	replace blood_pressure1right=. if blood_pressure1right==0 | blood_pressure1right==999  | blood_pressure1right==8888
	label var blood_pressure1right "systolic blood pressure in mmHg (right arm, 1st take)"	
	
	gen blood_pressure2right=P1201T2BD
	replace blood_pressure2right=. if blood_pressure2right==0 | blood_pressure2right==999  | blood_pressure2right==8888
	label var blood_pressure2right "systolic blood pressure in mmHg (right arm, 2nd take)"

	gen blood_pressure3right=P1201T3BD
	replace blood_pressure3right=. if blood_pressure3right==0 | blood_pressure3right==999  | blood_pressure3right==8888
	label var blood_pressure3right "systolic blood pressure in mmHg (right arm, 3rd take)"

	gen blood_pressure=(blood_pressure2right+blood_pressure3right)/2
	
	* objective hypertension
	gen hypertension_objective=.
	
	replace hypertension_objective=1 if blood_pressure2right>=140 & blood_pressure3right >=140 & blood_pressure2right!=. & blood_pressure3right!=.

	replace hypertension_objective=0 if hypertension_objective!=1 & blood_pressure2right!=. & blood_pressure3right!=.
	
	tab hypertension_objective 
	
	
	* controlled high blood pressure
	
	gen controlled_HBP=1 if P810==1 & P1201T2BD<140 // controlled high blood pressure, as defined in case someone has ever been diagnosed with high blood pressure, but currently blood pressure is below 140 mmHg
	replace controlled_HBP=0 if  controlled_HBP==.
	
	gen non_controlled_HBP=1 if P810==1 & P1201T2BD>=140 // controlled high blood pressure, as defined in case someone has ever been diagnosed with high blood pressure, but currently blood pressure is above or equal 140 mmHg
	replace non_controlled_HBP=0 if non_controlled_HBP==.


* cholesterol(s)

	* total 
	gen cholesterol_total=COLESTEROL_TOTAL
	replace cholesterol_total=. if cholesterol_total==0
	label var cholesterol_total "cholesterol total"

	*hdl
	gen cholesterol_hdl=COLESTEROL_HDL
	replace cholesterol_hdl=. if cholesterol_hdl==0
	label var cholesterol_hdl "cholesterol hdl"

* Framingham Risk Score (FRS) (see: https://en.wikipedia.org/wiki/Framingham_Risk_Score)

	gen Points_Age_FRS=.
	gen Points_TotalCholesterol_FRS=.
	gen Smoking_FSR=.
	gen Points_Cholesterol_hdl_FRS=.
	gen Points_SystolicBP_FRS=.
	gen FRAMINGHAM_RISK_SCORES=.
	
	* men
	
	replace Points_Age_FRS=10 if (gender==1 & age_linear>=60 & age_linear<=64)
	replace Points_Age_FRS=11 if (gender==1 & age_linear>=65 & age_linear<=69)
	replace Points_Age_FRS=12 if (gender==1 & age_linear>=70 & age_linear<=74)
	replace Points_Age_FRS=13 if (gender==1 & age_linear>=75)

	replace Points_TotalCholesterol_FRS=0 if (gender==1 & age_linear>=60 & age_linear<=69 & cholesterol_hdl<160)
	replace Points_TotalCholesterol_FRS=1 if (gender==1 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=160 & cholesterol_hdl<=199)
	replace Points_TotalCholesterol_FRS=1 if (gender==1 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=200 & cholesterol_hdl<=239)
	replace Points_TotalCholesterol_FRS=2 if (gender==1 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=240 & cholesterol_hdl<=279)
	replace Points_TotalCholesterol_FRS=3 if (gender==1 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>280)
	replace Points_TotalCholesterol_FRS=0 if (gender==1 & age_linear>70 & cholesterol_hdl<160)
	replace Points_TotalCholesterol_FRS=0 if (gender==1 & age_linear>70 & cholesterol_hdl>=160 & cholesterol_hdl<=199)
	replace Points_TotalCholesterol_FRS=0 if (gender==1 & age_linear>70 & cholesterol_hdl>=200 & cholesterol_hdl<=239)
	replace Points_TotalCholesterol_FRS=1 if (gender==1 & age_linear>70 & cholesterol_hdl>=240 & cholesterol_hdl<=279)
	replace Points_TotalCholesterol_FRS=1 if (gender==1 & age_linear>70 & cholesterol_hdl>280)

	replace Smoking_FSR=1 if (gender==1 & age_linear>=60 & age_linear<=69 & smoking==1)
	replace Smoking_FSR=1 if (gender==1 & age_linear>70 & smoking==1)
	replace Smoking_FSR=0 if (gender==1 & smoking==0)
	
	replace Points_Cholesterol_hdl_FRS=-1 if (gender==1 & cholesterol_hdl>60)
	replace Points_Cholesterol_hdl_FRS=0 if (gender==1 & cholesterol_hdl>=50 & cholesterol_hdl<=59)
	replace Points_Cholesterol_hdl_FRS=1 if (gender==1 & cholesterol_hdl>=40 & cholesterol_hdl<=49)
	replace Points_Cholesterol_hdl_FRS=2 if (gender==1 & cholesterol_hdl<40)
	
	replace Points_SystolicBP_FRS=0 if (gender==1 & controlled_HBP==0 & P1201T2BD<120)
	replace Points_SystolicBP_FRS=0 if (gender==1 & controlled_HBP==0 & P1201T2BD>=120 & P1201T2BD<=129)
	replace Points_SystolicBP_FRS=1 if (gender==1 & controlled_HBP==0 & P1201T2BD>=130 & P1201T2BD<=139)
	replace Points_SystolicBP_FRS=1 if (gender==1 & controlled_HBP==0 & P1201T2BD>=140 & P1201T2BD<=159)
	replace Points_SystolicBP_FRS=2 if (gender==1 & controlled_HBP==0 & P1201T2BD>=160)
	replace Points_SystolicBP_FRS=0 if (gender==1 & controlled_HBP==1 & P1201T2BD<120)
	replace Points_SystolicBP_FRS=1 if (gender==1 & controlled_HBP==1 & P1201T2BD>=120 & P1201T2BD<=129)
	replace Points_SystolicBP_FRS=2 if (gender==1 & controlled_HBP==1 & P1201T2BD>=130 & P1201T2BD<=139)
	replace Points_SystolicBP_FRS=2 if (gender==1 & controlled_HBP==1 & P1201T2BD>=140 & P1201T2BD<=159)
	replace Points_SystolicBP_FRS=3 if (gender==1 & controlled_HBP==1 & P1201T2BD>=160)
	
	* women

	replace Points_Age_FRS=10 if (gender==2 & age_linear>=60 & age_linear<=64)
	replace Points_Age_FRS=12 if (gender==2 & age_linear>=65 & age_linear<=69)
	replace Points_Age_FRS=14 if (gender==2 & age_linear>=70 & age_linear<=74)
	replace Points_Age_FRS=16 if (gender==2 & age_linear>=75)
	
	replace Points_TotalCholesterol_FRS=0 if (gender==2 & age_linear>=60 & age_linear<=69 & cholesterol_hdl<160)
	replace Points_TotalCholesterol_FRS=1 if (gender==2 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=160 & cholesterol_hdl<=199)
	replace Points_TotalCholesterol_FRS=2 if (gender==2 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=200 & cholesterol_hdl<=239)
	replace Points_TotalCholesterol_FRS=3 if (gender==2 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>=240 & cholesterol_hdl<=279)
	replace Points_TotalCholesterol_FRS=4 if (gender==2 & age_linear>=60 & age_linear<=69 & cholesterol_hdl>280)
	replace Points_TotalCholesterol_FRS=0 if (gender==2 & age_linear>70 & cholesterol_hdl<160)
	replace Points_TotalCholesterol_FRS=1 if (gender==2 & age_linear>70 & cholesterol_hdl>=160 & cholesterol_hdl<=199)
	replace Points_TotalCholesterol_FRS=1 if (gender==2 & age_linear>70 & cholesterol_hdl>=200 & cholesterol_hdl<=239)
	replace Points_TotalCholesterol_FRS=2 if (gender==2 & age_linear>70 & cholesterol_hdl>=240 & cholesterol_hdl<=279)
	replace Points_TotalCholesterol_FRS=2 if (gender==2 & age_linear>70 & cholesterol_hdl>280)

	replace Smoking_FSR=2 if (gender==2 & age_linear>=60 & age_linear<=69 & smoking==1)
	replace Smoking_FSR=1 if (gender==2 & age_linear>70 & smoking==1)
	replace Smoking_FSR=0 if (gender==2 & smoking==0)
	
	replace Points_Cholesterol_hdl_FRS=-1 if (gender==2 & cholesterol_hdl>60)
	replace Points_Cholesterol_hdl_FRS=0 if (gender==2 & cholesterol_hdl>=50 & cholesterol_hdl<=59)
	replace Points_Cholesterol_hdl_FRS=1 if (gender==2 & cholesterol_hdl>=40 & cholesterol_hdl<=49)
	replace Points_Cholesterol_hdl_FRS=2 if (gender==2 & cholesterol_hdl<40)

	replace Points_SystolicBP_FRS=0 if (gender==2 & controlled_HBP==0 & P1201T2BD<120)
	replace Points_SystolicBP_FRS=1 if (gender==2 & controlled_HBP==0 & P1201T2BD>=120 & P1201T2BD<=129)
	replace Points_SystolicBP_FRS=2 if (gender==2 & controlled_HBP==0 & P1201T2BD>=130 & P1201T2BD<=139)
	replace Points_SystolicBP_FRS=3 if (gender==2 & controlled_HBP==0 & P1201T2BD>=140 & P1201T2BD<=159)
	replace Points_SystolicBP_FRS=4 if (gender==2 & controlled_HBP==0 & P1201T2BD>=160)
	replace Points_SystolicBP_FRS=0 if (gender==2 & controlled_HBP==1 & P1201T2BD<120)
	replace Points_SystolicBP_FRS=3 if (gender==2 & controlled_HBP==1 & P1201T2BD>=120 & P1201T2BD<=129)
	replace Points_SystolicBP_FRS=4 if (gender==2 & controlled_HBP==1 & P1201T2BD>=130 & P1201T2BD<=139)
	replace Points_SystolicBP_FRS=5 if (gender==2 & controlled_HBP==1 & P1201T2BD>=140 & P1201T2BD<=159)
	replace Points_SystolicBP_FRS=6 if (gender==2 & controlled_HBP==1 & P1201T2BD>=160)
	
	* conversion in percentages
	
	gen Sum_Points_FRS=Points_Age_FRS + Points_TotalCholesterol_FRS + Smoking_FSR + Points_Cholesterol_hdl_FRS + Points_SystolicBP_FRS
		
		* men
		replace FRAMINGHAM_RISK_SCORES=0.01 if (gender==1 & Sum_Points_FRS>=1 & Sum_Points_FRS<=4)
		replace FRAMINGHAM_RISK_SCORES=0.02 if (gender==1 & Sum_Points_FRS>=5 & Sum_Points_FRS<=6)
		replace FRAMINGHAM_RISK_SCORES=0.03 if (gender==1 & Sum_Points_FRS==7)
		replace FRAMINGHAM_RISK_SCORES=0.04 if (gender==1 & Sum_Points_FRS==8)
		replace FRAMINGHAM_RISK_SCORES=0.05 if (gender==1 & Sum_Points_FRS==9)
		replace FRAMINGHAM_RISK_SCORES=0.06 if (gender==1 & Sum_Points_FRS==10)
		replace FRAMINGHAM_RISK_SCORES=0.08 if (gender==1 & Sum_Points_FRS==11)
		replace FRAMINGHAM_RISK_SCORES=0.1 if (gender==1 & Sum_Points_FRS==12)
		replace FRAMINGHAM_RISK_SCORES=0.12 if (gender==1 & Sum_Points_FRS==13)
		replace FRAMINGHAM_RISK_SCORES=0.16 if (gender==1 & Sum_Points_FRS==14)
		replace FRAMINGHAM_RISK_SCORES=0.2 if (gender==1 & Sum_Points_FRS==15)
		replace FRAMINGHAM_RISK_SCORES=0.25 if (gender==1 & Sum_Points_FRS==16)
		replace FRAMINGHAM_RISK_SCORES=0.3 if (gender==1 & Sum_Points_FRS>17)
	
		* women
		replace FRAMINGHAM_RISK_SCORES=0.00 if (gender==2 & Sum_Points_FRS<9)
		replace FRAMINGHAM_RISK_SCORES=0.01 if (gender==2 & Sum_Points_FRS>=9 & Sum_Points_FRS<=12)
		replace FRAMINGHAM_RISK_SCORES=0.02 if (gender==2 & Sum_Points_FRS>=13 & Sum_Points_FRS<=14)
		replace FRAMINGHAM_RISK_SCORES=0.03 if (gender==2 & Sum_Points_FRS==15)
		replace FRAMINGHAM_RISK_SCORES=0.04 if (gender==2 & Sum_Points_FRS==16)
		replace FRAMINGHAM_RISK_SCORES=0.05 if (gender==2 & Sum_Points_FRS==17)
		replace FRAMINGHAM_RISK_SCORES=0.06 if (gender==2 & Sum_Points_FRS==18)
		replace FRAMINGHAM_RISK_SCORES=0.08 if (gender==2 & Sum_Points_FRS==19)
		replace FRAMINGHAM_RISK_SCORES=0.11 if (gender==2 & Sum_Points_FRS==20)
		replace FRAMINGHAM_RISK_SCORES=0.14 if (gender==2 & Sum_Points_FRS==21)
		replace FRAMINGHAM_RISK_SCORES=0.17 if (gender==2 & Sum_Points_FRS==22)
		replace FRAMINGHAM_RISK_SCORES=0.22 if (gender==2 & Sum_Points_FRS==23)
		replace FRAMINGHAM_RISK_SCORES=0.27 if (gender==2 & Sum_Points_FRS==24)
		replace FRAMINGHAM_RISK_SCORES=0.3 if (gender==2 & Sum_Points_FRS>25)
	
	
	
* deleting variables not needed anymore & saving data


drop P204-COLESTEROL_TOTAL

save final.dta, replace

* STEP 3: SAMPLE
******************************************
******************************************


* define locals
glo controls gender region1 region3 region4 region5 region6 i.ageG
glo education i.education_5_levels
glo blood_pressure blood_pressure
glo hypertension_dummy hypertension_objective 
glo risk_factors smoking alcohol fruits_vegetables physical_activity overweight obese
glo assets i.assets_index_quartile
glo education_linear education_5_levels
glo assets_linear assets_index_quartile
* setting sample

reg $hypertension_dummy $education $assets_quartiles $blood_pressure $risk_factors

gen sample=e(sample)
keep if sample==1


* assets quartiles

xtile assets_index_quartile=assets_index,n(4) // creates quartiles of household assets
label define assets_quart 1 "1st quartile (lowest)" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile (highest)"
label values assets_index_quartile assets_quart

* define sample missings

/* 
Total N=23,694
Non proxy, with education=23,601
Non proxy, with education & BP=4,344 */
sum NumIdentificador if proxy!=1 & age_linear!=. & gender!=. & education_5_levels!=. & blood_pressure!=. & hypertension_objective!=. /* 
With height & weight=4,020 */ 
sum NumIdentificador if proxy!=1 & age_linear!=. & gender!=. & education_5_levels!=. & blood_pressure!=. & hypertension_objective!=. & bmi!=. /*
Other missings=4,007 */

* descriptives

sum age_linear
tab gender
tab RegionUT
tab education_5_levels
sum blood_pressure
tab hypertension_objective 
tab smoking 
tab alcohol 
tab fruits_vegetables 
tab physical_activity 
tab overweight 
sum FRAMINGHAM_RISK_SCORES




* STEP 4: ANALYSES
******************************************
******************************************

* association between socio-economic status and bloopd pressure & hypertension

	* blood pressure

	reg $blood_pressure $education $controls , r
		test 2.education_5_levels == 3.education_5_levels
		estadd scalar test23 = r(p)
		test 2.education_5_levels == 4.education_5_levels
		estadd scalar test24 = r(p)		
		test 2.education_5_levels == 5.education_5_levels
		estadd scalar test25 = r(p)		
		test 3.education_5_levels == 4.education_5_levels
		estadd scalar test34 = r(p)	
		test 3.education_5_levels == 5.education_5_levels
		estadd scalar test35 = r(p)			
		test 4.education_5_levels == 5.education_5_levels
		estadd scalar test45 = r(p)			
	est store bp_edu
	
	reg $blood_pressure $assets $controls ,r 
		test 2.assets_index_quartile == 3.assets_index_quartile
		estadd scalar test23 = r(p)
		test 2.assets_index_quartile == 4.assets_index_quartile
		estadd scalar test24 = r(p)		
		test 3.assets_index_quartile == 4.assets_index_quartile
		estadd scalar test34 = r(p)		
	est store bp_assets
	
	* objective hypertension

	logit $hypertension_dummy $education $controls , or
		test 2.education_5_levels == 3.education_5_levels
		estadd scalar test23 = r(p)
		test 2.education_5_levels == 4.education_5_levels
		estadd scalar test24 = r(p)		
		test 2.education_5_levels == 5.education_5_levels
		estadd scalar test25 = r(p)		
		test 3.education_5_levels == 4.education_5_levels
		estadd scalar test34 = r(p)	
		test 3.education_5_levels == 5.education_5_levels
		estadd scalar test35 = r(p)			
		test 4.education_5_levels == 5.education_5_levels
		estadd scalar test45 = r(p)	
	est store hypertens_edu

	logit $hypertension_dummy $assets $controls, or
		test 2.assets_index_quartile == 3.assets_index_quartile
		estadd scalar test23 = r(p)
		test 2.assets_index_quartile == 4.assets_index_quartile
		estadd scalar test24 = r(p)		
		test 3.assets_index_quartile == 4.assets_index_quartile
		estadd scalar test34 = r(p)			
	est store hypertens_assets
	
* association between socio-economic status and key risk factors

	* education

	foreach x of global risk_factors {
		logit `x' $education $controls, or
			test 2.education_5_levels == 3.education_5_levels
			estadd scalar test23 = r(p)
			test 2.education_5_levels == 4.education_5_levels
			estadd scalar test24 = r(p)		
			test 2.education_5_levels == 5.education_5_levels
			estadd scalar test25 = r(p)		
			test 3.education_5_levels == 4.education_5_levels
			estadd scalar test34 = r(p)	
			test 3.education_5_levels == 5.education_5_levels
			estadd scalar test35 = r(p)			
			test 4.education_5_levels == 5.education_5_levels
			estadd scalar test45 = r(p)			
		est store `x'_educ
	}

	* assets

	foreach x of global risk_factors {
		logit `x' $assets $controls, or
			test 2.assets_index_quartile == 3.assets_index_quartile
			estadd scalar test23 = r(p)
			test 2.assets_index_quartile == 4.assets_index_quartile
			estadd scalar test24 = r(p)		
			test 3.assets_index_quartile == 4.assets_index_quartile
			estadd scalar test34 = r(p)			
		est store `x'_asset
	}
	
* association between socio-economic status and FRS

reg FRAMINGHAM_RISK_SCORES $education $controls, r
margins $education
marginsplot
graph save Graph education_FRS.gph, replace

* save `outpath'education_FRS.gph, replace

reg FRAMINGHAM_RISK_SCORES $assets $controls, r
margins $assets
marginsplot
graph save Graph assets_FRS.gph, replace



* STEP 5: PRESENTING RESULTS
******************************************
******************************************


	* showing regression tables
	
	* bp
	estout bp_edu, cells("b(fmt(3)) ci(par( ( , ) )) p")  stats( test23 test24 test25 test34 test35 test45 )
	estout bp_assets, cells("b(fmt(3)) ci(par( ( , ) )) p")  stats( test23 test24 test25 test34 test35 test45 )

	* objective hypertension
	estout hypertens_edu, cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )
	estout hypertens_assets, cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )

	* table risk factors
	estout smoking_educ alcohol_educ fruits_vegetables_educ , cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )
	estout physical_activity_educ overweight_educ, cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )

	estout smoking_asset alcohol_asset fruits_vegetables_asset , cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )
	estout physical_activity_asset overweight_asset, cells("b(fmt(3)) ci(par( ( , ) )) p") eform stats( test23 test24 test25 test34 test35 test45 )

	
	
	* coefplot education	
	coefplot	(smoking_educ, label(Smoker (yes)) mcolor(black) ciopts(lcolor(black))) ///
				(alcohol_educ, label(Alcohol consumption (yes)) mcolor(gs10) ciopts(lcolor(gs10)) msymbol(D) ) ///
				(fruits_vegetables_educ, label(Fruits or vegetables (no)) mcolor(blue) ciopts(lcolor(blue)) msymbol(T) ) ///
				(physical_activity_educ, label(Physical activity (no))  msymbol(S) ) ///
				(overweight_educ, label(Overweight (yes))  msymbol(Oh) ), ///
	eform keep(2.education_5_levels 3.education_5_levels 4.education_5_levels 5.education_5_levels) xline(1, lcolor(black) lwidth(thin) lpattern(dash))  ///
	xtitle("Odds ratio") graphregion(fcolor(white)) ci(95)
	graph save Graph education_risks.gph, replace

	
	* coefplot assets	
	coefplot 	(smoking_asset, label(Smoker (yes)) mcolor(black) ciopts(lcolor(black)))  ///
				(alcohol_asset, label(Alcohol consumption (yes)) mcolor(gs10) ciopts(lcolor(gs10)) msymbol(D) ) ///
				(fruits_vegetables_asset, label(Fruits or vegetables (no)) mcolor(blue) ciopts(lcolor(blue)) msymbol(T) ) ///
				(physical_activity_asset, label(Physical activity (no))  msymbol(S) ) ///
				(overweight_asset, label(Overweight (yes)) msymbol(Oh) ), ///
	eform keep(2.assets_index_quartile 3.assets_index_quartile 4.assets_index_quartile) xline(1, lcolor(black) lwidth(thin) lpattern(dash))  ///
	xtitle("Odds ratio") graphregion(fcolor(white)) ci(95)
	graph save Graph assets_risks.gph, replace

	* graphs combine
	
	grc1leg education_risks.gph assets_risks.gph, col(2) legendfrom(education_risks.gph)

	* tests of joint significance
	
	est replay bp_edu
	test (2.education_5_levels=0) (3.education_5_levels=0) (4.education_5_levels=0) (5.education_5_levels=0)

	est replay bp_assets
	test (2.assets_index_quartile=0) (3.assets_index_quartile=0) (4.assets_index_quartile=0)

	est replay hypertens_edu
	test (2.education_5_levels=0) (3.education_5_levels=0) (4.education_5_levels=0) (5.education_5_levels=0)
	
	est replay hypertens_assets
	test (2.assets_index_quartile=0) (3.assets_index_quartile=0) (4.assets_index_quartile=0)
	

* STEP 6: End
******************************************
******************************************

/*
	save final.dta, replace

	clear all
	
*/	
	set graphics on

	
