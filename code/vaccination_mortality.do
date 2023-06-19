*==============================================================================*
* Project: Vaccine and Non-covid Mortality
* Task: Temporary summarized results
* Author: Dandan Zhang, Jinlei Qi, Hongbo Li 
* Createdate: 2022/08/22
* Updatedate: 2023/01/14
*==============================================================================*


clear
clear matrix
set more off
capture log close


log using $logfiles\vaccination_mortality.log, replace 

global root = "" // fill in root address here
global dofiles = "$root\dofiles"
global logfiles = "$root\logfiles"
global rawdata = "$root\rawdata"
global workingdata = "$root\workingdata"
global outputs = "$root\outputs"
global tempdata = "$root\tempdata"

global control1 = "winsmean temmean rhumean prsmean pre20t20"
global control2 = "winsmean temmean rhumean prsmean pre20t20 log_lead_delta_confirm_city"
global deathcause_list = "3 15 38 39 40 41 42 49 60 62 63 65 67 79 81 82 85 87 88 104 107 108 109 111 112 113 115 131 150 152 157"
global deathcause_list_BMJ = "1 59 60 79 81 104 106 107 108 111 112 121"
global agegroup_list ="3 18 60 80"
global agegroup_list2 ="total 3 18 60 80"

*****************************************
*** figure1: Vaccination rate by dose ***
*****************************************

*—————————————————————————— PanelA —————————————————————————————————*
	use $workingdata\summarized_vac.dta, clear

	collapse (sum) va_total_tall_d* pop_total, by(time year month)
	forvalues i = 1(1)3 {
		gen cum_va_total_tall_d`i' = sum(va_total_tall_d`i')
		gen rate_vaccine_d`i' = round(cum_va_total_tall_d`i' / pop_total * 100, 0.01)
	}
	
	* graphing
	format time %tmCCYY-NN
	set scheme s1color

	line rate_vaccine_d1 time, lc(blue*0.5) ///
	|| line rate_vaccine_d2 time, lc(red*0.8) ///
		title("A. Vaccination rate", pos(11) size(3.75) color(black)) ///
		legend(label(1 "First Dose") ///
			label(2 "Second Dose")  ///
			cols(1) order(1 2) pos(11) ring(0) rowgap(0.1) symysize(2) symxsize(5) size(small)) ///
		xlabel(731 "Dec 2020" 733 "Feb 2021" 735 "Apr 2021" 737 ///
			"Jun 2021" 739 "Aug 2021" 741 "Oct 2021" 743 "Dec 2021" 744 "Jan 2022", nogrid labsize(20pt)) ///
		xtitle("") ///
		xline(731(1)744, lstyle(grid) lp(dash) lw(0.2)) ///
		yline(0(10)100, lstyle(grid) lp(dash) lw(0.2)) ///
		ylabel(0(10)100, angle(horizontal)) ///
		ytitle("Vaccination Rate（%）") ///
		saving($outputs\figure1A_vaccination_rate.gph, replace) ///
	|| sc rate_vaccine_d1 time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_vaccine_d1) mlabp(12) mlabs(small) ///
	|| sc rate_vaccine_d2 time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_vaccine_d2) mlabp(6) mlabs(small)
	
	
*—————————————————————————— PanelB —————————————————————————————————*
	use $workingdata\summarized_vac.dta, clear

	collapse (sum) va_total_tall_d* pop_total, by(time year month)
	forvalues i = 1(1)3 {
		gen rate_vaccine_d`i' = round(va_total_tall_d`i' / pop_total * 100, 0.01)
	}

	* graphing
	format time %tmCCYY-NN
	set scheme s1color

	line rate_vaccine_d1 time, lc(blue*0.5) ///
	|| line rate_vaccine_d2 time, lc(red*0.8) ///
		xscale(noextend) ///
		title("B. Monthly vaccination rate", pos(11) size(3.75) color(black)) ///
		legend(label(1 "First Dose") ///
			label(2 "Second Dose")  ///
			cols(1) order(1 2) pos(11) ring(0) rowgap(0.1) symysize(2) symxsize(5) size(small)) ///
		xlabel(731 "Dec 2020" 733 "Feb 2021" 735 "Apr 2021" 737 ///
			"Jun 2021" 739 "Aug 2021" 741 "Oct 2021" 743 "Dec 2021" 744 "Jan 2022", nogrid labsize(20pt)) ///
		xtitle("") ///
		xline(731(1)744, lstyle(grid) lp(dash) lw(0.2)) ///
		yline(0(5)30, lstyle(grid) lp(dash) lw(0.2)) ///
		ylabel(0(5)30, angle(horizontal)) ///
		ytitle("Vaccination Rate（%）") ///
		saving($outputs\figure1B_vaccination_rate.gph, replace)
	

*—————————————————————————— PanelC —————————————————————————————————*
	use $workingdata\vac_pop.dta, clear
	keep if dose == 2 // Only keep the second dose for all vaccine types

	foreach var of varlist va_total-pop_total {
		bysort time vaccine_type: egen all_`var'_ = sum(`var')
	}
	keep time year month vaccine_type all_*
	duplicates drop time vaccine_type, force 

	replace vaccine_type = "1" if vaccine_type == "新冠疫苗（CHO细胞）"
	replace vaccine_type = "2" if vaccine_type == "新冠疫苗（Vero细胞）"
	replace vaccine_type = "3" if vaccine_type == "新冠疫苗（腺病毒载体）"
	destring vaccine_type, replace 
	reshape wide all_va*, i(time) j(vaccine_type)

	global age_group_list = "3 18 60 80 total"
	global age_group_list2 = "18 60 80 total"
	global type_list = "1 2 3 all_types"
	global type_list2 = "1 2 3"

	sort time
	foreach age_group in $age_group_list {
		gen all_va_`age_group'_all_types = all_va_`age_group'_1 + all_va_`age_group'_2 + all_va_`age_group'_3
	}

	foreach age_group in $age_group_list2 {
		foreach type in $type_list {
			gen cum_va_`age_group'_`type' = sum(all_va_`age_group'_`type')
			gen rate_`age_group'_`type' = round(cum_va_`age_group'_`type' / all_pop_`age_group' * 100, 0.01)
		}
	}

	foreach type in $type_list {
		gen cum_va_3_`type' = sum(all_va_3_`type')
		egen max_va_3_`type' = max(cum_va_3_`type')
		gen rate_3_`type' = round(cum_va_3_`type' / max_va_3_`type' * 100, 0.01)
	}

	* graphing
	format time %tmCCYY-NN
	line rate_3_all_types time, lc(blue*0.5) ///
	|| line rate_18_all_types time, lc(red*0.8) ///
	|| line rate_60_all_types time, lc(yellow*1.5) ///
	|| line rate_80_all_types time, lc(purple*0.5) ///  
		title("C. Full dose vaccination rate (age groups)", ///
		pos(11) size(3.75) color(black))  scheme(s1color) ///
		ytitle("Vaccination Rate（%）") xtitle("") ///
		xlabel(731 "Dec 2020" 733 "Feb 2021" 735 "Apr 2021" 737 ///
			"Jun 2021" 739 "Aug 2021" 741 "Oct 2021" 743 "Dec 2021" 744 "Jan 2022", nogrid labsize(20pt)) ///
		ylabel(0(10)100, angle(horizontal)) ///
		xline(731(1)744, lstyle(grid) lp(dash) lw(0.2)) ///
		yline(0(10)100, lstyle(grid) lp(dash) lw(0.2)) ///
		saving($outputs\figure2C_vaccination_rate.gph, replace) ///
		legend(label(1 "age group: 3-17") label(2 "age group: 18-59") ///
		label(3 "age group: 60-79") label(4 "age group: 80-") ///
		order(1 2 3 4) cols(1) pos(11) ring(0) rowgap(0.1) symysize(2) symxsize(5) size(small)) ///
	|| sc rate_3_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_3_all_types) mlabp(12) mlabs(small) ///
	|| sc rate_18_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_18_all_types) mlabp(12) mlabs(small) ///
	|| sc rate_60_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_60_all_types) mlabp(6) mlabs(small) ///
	|| sc rate_80_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_80_all_types) mlabp(6) mlabs(small)


*—————————————————————————— PanelD —————————————————————————————————*
	use $workingdata\vac_pop.dta, clear
	keep if dose == 3 // Only keep the third dose for all vaccine types

	foreach var of varlist va_total-pop_total {
		bysort time vaccine_type: egen all_`var'_ = sum(`var')
	}
	keep time year month vaccine_type all_*
	duplicates drop time vaccine_type, force 

	replace vaccine_type = "1" if vaccine_type == "新冠疫苗（CHO细胞）"
	replace vaccine_type = "2" if vaccine_type == "新冠疫苗（Vero细胞）"
	replace vaccine_type = "3" if vaccine_type == "新冠疫苗（腺病毒载体）"
	destring vaccine_type, replace 
	reshape wide all_va*, i(time) j(vaccine_type)

	global age_group_list = "3 18 60 80 total"
	global age_group_list2 = "18 60 80 total"
	global type_list = "1 2 all_types"
	global type_list2 = "1 2"
	foreach age_group in $age_group_list {
		gen all_va_`age_group'_all_types = all_va_`age_group'_1 + all_va_`age_group'_2
	}

	foreach age_group in $age_group_list {
		foreach type in $type_list {
			gen cum_va_`age_group'_`type' = sum(all_va_`age_group'_`type')
			gen rate_`age_group'_`type' = round(cum_va_`age_group'_`type' / all_pop_`age_group' * 100, 0.01)
		}
	}

	* graphing
	format time %tmCCYY-NN
	line rate_3_all_types time, lc(blue*0.5) ///
	|| line rate_18_all_types time, lc(red*0.8) ///
	|| line rate_60_all_types time, lc(yellow*1.5) ///
	|| line rate_80_all_types time, lc(purple*0.5) ///  
		title("D. Booster dose vaccination rate (age groups)", ///
		pos(11) size(3.75) color(black))  scheme(s1color) ///
		ytitle("Vaccination Rate（%）") xtitle("") ///
		xlabel(731 "Dec 2020" 733 "Feb 2021" 735 "Apr 2021" 737 ///
			"Jun 2021" 739 "Aug 2021" 741 "Oct 2021" 743 "Dec 2021" 744 "Jan 2022", nogrid labsize(7pt)) ///
		ylabel(0(5)50, angle(horizontal)) ///
		xline(731(1)744, lstyle(grid) lp(dash) lw(0.2)) ///
		yline(0(5)50, lstyle(grid) lp(dash) lw(0.2)) ///
		saving($outputs/figure1D_vaccination_rate.gph, replace) ///
		legend(label(1 "age group: 3-17") label(2 "age group: 18-59") ///
		label(3 "age group: 60-79") label(4 "age group: 80-") ///
		order(1 2 3 4) cols(1) pos(11) ring(0) rowgap(0.1) symysize(2) symxsize(5) size(small)) ///
	|| sc rate_3_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_3_all_types) mlabp(12) mlabs(small) ///
	|| sc rate_18_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_18_all_types) mlabp(12) mlabs(small) ///
	|| sc rate_60_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_60_all_types) mlabp(6) mlabs(small) ///
	|| sc rate_80_all_types time if year == 2022 & month == 1, ///
		msymbol(none) mlabel(rate_80_all_types) mlabp(6) mlabs(small)
	
*—————————————————————————— Combine —————————————————————————————————*
	graph combine $outputs/figure2A_vaccination_rate.gph ///
		$outputs/figure2B_vaccination_rate.gph ///
		$outputs/figure2C_vaccination_rate.gph, ///
		graphregion(fcolor(white) lcolor(white)) imargin(small) col(1) iscale(0.75) xsize(15) ysize(18)
		
		graph save $outputs/figure2_vaccination_rate.gph, replace
		graph export $outputs/figure2_vaccination_rate.eps, replace
		graph export $outputs/figure2_vaccination_rate.png, replace width(3000)
	
	
**********************************************
*** figure3: vaccination rate by province ***
**********************************************

*** Full dose ***
	use $workingdata\vac_pop.dta, clear
	keep if dose == 2 // Only keep the second dose for all vaccine types
	bysort countycode time: egen total_vaccine_county = sum(va_total)
	keep countycode time year month total_vaccine_county pop_total 
	gen province_code = floor(countycode / 10000 ) * 10000

	** match with province name
		merge m:1 province_code using $workingdata\province_code.dta // all matched
		keep if _merge == 3
		drop _merge

		duplicates drop countycode time, force
		bysort province_code time: egen total_vaccine_pro = sum(total_vaccine_county)
		bysort province_code time: egen pop_total_pro = sum(pop_total)

		keep province province_code time year month total_vaccine_pro pop_total_pro province_name
		duplicates drop province_code time, force
		format time %tm

	** gen cummulative variable
		bysort province_code: gen cum_total_vaccine_pro = sum(total_vaccine_pro)
		gen rate_vaccination_pro = cum_total_vaccine_pro / pop_total_pro * 100

		keep if year == 2022 & month == 1
		sort rate_vaccination_pro
		sort province_code
		drop if province_code == 540000

	** graphing 
		graph hbar rate_vaccination_pro, /// 
			over(province_name, sort(rate_vaccination_pro) reverse gap(*3) label(labsize(vsmall))) ///
			exclude0 scheme(s1mono) ///
			title("China's Covid-19 Vaccination Rate at Province Level") ///
			subtitle("Full Dose, by Jan 2022") ///
			ytitle("Vaccination Rate (%)") ///
			blabel(bar) ///
			yscale(range(50(10)100)) ///
			saving($outputs\figure3_vaccination_rate_pro_full.gph, replace)
		graph export $outputs\figure3_vaccination_rate_pro_full.png, replace

*** Booster dose ***
	use $workingdata\vac_pop.dta, clear
	keep if dose == 3 // Only keep first dose for all vaccine types
	bysort countycode time: egen total_vaccine_county = sum(va_total)
	keep countycode time year month total_vaccine_county pop_total 
	gen province_code = floor(countycode / 10000 ) * 10000

	** match with province name
		merge m:1 province_code using $workingdata\province_code.dta // all matched
		keep if _merge == 3
		drop _merge

		duplicates drop countycode time, force
		bysort province_code time: egen total_vaccine_pro = sum(total_vaccine_county)
		bysort province_code time: egen pop_total_pro = sum(pop_total)

		keep province province_code time year month total_vaccine_pro pop_total_pro province_name
		duplicates drop province_code time, force
		format time %tm

	** gen cummulative variable
		bysort province_code: gen cum_total_vaccine_pro = sum(total_vaccine_pro)
		gen rate_vaccination_pro = cum_total_vaccine_pro / pop_total_pro * 100

		keep if year == 2022 & month == 1
		sort rate_vaccination_pro
		sort province_code
		drop if province_code == 540000

	** graphing 
		graph hbar rate_vaccination_pro, /// 
			over(province_name, sort(rate_vaccination_pro) reverse gap(*3) label(labsize(vsmall))) ///
			exclude0 scheme(s1mono)  ///
			title("China's Covid-19 Vaccination Rate at Province Level") ///
			subtitle("Booster dose, by Jan 2022") ///
			ytitle("Vaccination Rate (%)") ///
			blabel(bar) ///
			yscale(range(20(10)60)) ///
			saving($outputs\figure3_vaccination_rate_pro_booster.gph, replace)
		graph export $outputs\figure3_vaccination_rate_pro_booster.png, replace


*------------------------------------------------------------------------------*
*--------------------------------- Table --------------------------------------*
*------------------------------------------------------------------------------*
use $workingdata\mortality_vaccination_pop.dta, clear 

	** Fixed effects
		gen citycode = floor(countycode / 100) * 100

	** central municipal cities
		replace citycode = 110000 if citycode >= 110000 & citycode < 120000
		replace citycode = 120000 if citycode >= 120000 & citycode < 130000
		replace citycode = 310000 if citycode >= 310000 & citycode < 320000
		replace citycode = 500000 if citycode >= 500000 & citycode < 510000

		gen provincecode = floor(countycode / 10000) * 10000 
		xtset countycode time

***********************************
*** Table1: baseline regression ***
***********************************


reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	
	outreg2 using $outputs\table1_baseline_hetero_age.xls, ///
	excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("ALL AGE GROUPS") ///
	nor2 ///
	replace 

reghdfe d3_0 va_3_tall_d2 va_3_tall_d3 $control2 ///
	if time >= 731, ///
	absorb(countycode time) ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	
	outreg2 using $outputs\table1_baseline_hetero_age.xls, ///
	excel keep(va_3_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("AGE GROUP 3-17") ///
	nor2 ///
	append

reghdfe d18_0 va_18_tall_d2 va_18_tall_d3 $control2 ///
	if time >= 731, absorb(countycode time)   ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	
	outreg2 using $outputs\table1_baseline_hetero_age.xls, ///
	excel keep(va_18_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("AGE GROUP 18-59") ///
	nor2 ///
	append

reghdfe d60_0 va_60_tall_d2 va_60_tall_d3 $control2 ///
	if time >= 731, absorb(countycode time)   ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	
	outreg2 using $outputs\table1_baseline_hetero_age.xls, ///
	excel keep(va_60_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("AGE GROUP 60-79") ///
	nor2 ///
	append

reghdfe d80_0 va_80_tall_d2 va_80_tall_d3 $control2 ///
	if time >= 731, absorb(countycode time)   ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	
	outreg2 using $outputs\table1_baseline_hetero_age.xls, ///
	excel keep(va_80_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("AGE GROUP 80-") ///
	nor2 ///
	append

**********************************************************
*** Table2: heterogeneous analysis on different causes ***
**********************************************************

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2 if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	local coef = e(b)[1, 1]
	
	sum va_total_tall_d2 if e(sample) == 1
	local mean_vac = r(mean)
	
	sum dtotal_0 if year == 2019
	local mean_death = r(mean)
	
	local fraction = `coef' / `mean_death' * 100 * 10000
	
	outreg2 using $outputs\table2_hetero_BMJ_cause_OLS.xls, excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp', ///
	Corresponding 2019 Mean, `mean_death', Effect(%), `fraction') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("CAUSE0") ///
	nor2 ///
	replace 

foreach j in $deathcause_list_BMJ {
	reghdfe dtotal_`j' va_total_tall_d2 va_total_tall_d3 $control2 if time >= 731, ///
	absorb(countycode time)  ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	local coef = e(b)[1, 1]
	
	sum va_total_tall_d2 if e(sample) == 1
	local mean_vac = r(mean)
	
	sum dtotal_`j' if year == 2019
	local mean_death = r(mean)
	
	local fraction = `coef' / `mean_death' * 100 * 10000
	
	outreg2 using $outputs\table2_hetero_BMJ_cause_OLS.xls, excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp', ///
	Corresponding 2019 Mean, `mean_death', Effect(%), `fraction') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("CAUSE`j'") ///
	nor2 ///
	append
}



* by age groups
foreach age in $agegroup_list {
	reghdfe d`age'_0 va_`age'_tall_d2 va_`age'_tall_d3 $control2 if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)
	
	local num_dsp = e(df_r) + 1
	local coef = e(b)[1, 1]
	
	sum va_`age'_tall_d2 if e(sample) == 1
	local mean_vac = r(mean)
	
	sum d`age'_0 if year == 2019
	local mean_death = r(mean)
	
	local fraction = `coef' / `mean_death' * 100 * 10000
	
	outreg2 using $outputs\table2_hetero_BMJ_cause_`age'_OLS.xls, excel keep(va_`age'_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp', ///
	Corresponding 2019 Mean, `mean_death', Effect(%), `fraction') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("CAUSE0") ///
	nor2 ///
	replace 

	foreach j in $deathcause_list_BMJ {
		reghdfe d`age'_`j' va_`age'_tall_d2 va_`age'_tall_d3 $control2 if time >= 731, ///
		absorb(countycode time)  ///  
		cluster(countycode)
		
		local num_dsp = e(df_r) + 1
		local coef = e(b)[1, 1]
		
		sum va_`age'_tall_d2 if e(sample) == 1
		local mean_vac = r(mean)
		
		sum d`age'_`j' if year == 2019
		local mean_death = r(mean)
		
		local fraction = `coef' / `mean_death' * 100 * 10000
		
		outreg2 using $outputs\table2_hetero_BMJ_cause_`age'_OLS.xls, excel keep(va_`age'_tall_d2) ///
		addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp', ///
		Corresponding 2019 Mean, `mean_death', Effect(%), `fraction') nocons ///
		addtext("County FE", "YES", "Year-Month FE", "YES") ///
		cttop("CAUSE`j'") ///
		nor2 ///
		append
	}
}

*************************************
*** Table 3: interaction analysis ***
*************************************

use $workingdata\mortality_vaccination_pop.dta, clear 

* Fixed effects
gen citycode = floor(countycode / 100) * 100

* central municipal cities
replace citycode = 110000 if citycode >= 110000 & citycode < 120000
replace citycode = 120000 if citycode >= 120000 & citycode < 130000
replace citycode = 310000 if citycode >= 310000 & citycode < 320000
replace citycode = 500000 if citycode >= 500000 & citycode < 510000

gen provincecode = floor(countycode / 10000) * 10000 

xtset countycode time

merge m:1 countycode using $workingdat\mean_mortality_2019.dta, nogenerate
save $tempdata\mortality_mean_2019.dta, replace 

use $tempdata\mortality_mean_2019.dta, clear
xtset countycode time

gen rural = (urb_rur == 2) if !mi(urb_rur)
gen interaction_rural = va_total_tall_d2 * rural

egen mean_per_hos_bed = mean(per_hos_bed)
gen decen_per_hos_bed = per_hos_bed - mean_per_hos_bed

gen interaction_hosbed = va_total_tall_d2 * decen_per_hos_bed


gen mean_deaths_rate_2019 = mean_deaths_2019 * 12 / pop_total * 1000

egen mean_mean_deaths_2019 = mean(mean_deaths_2019)
gen decen_mean_deaths_2019 = mean_deaths_2019 - mean_mean_deaths_2019
egen mean_mean_dr_2019 = mean(mean_deaths_rate_2019)
gen decen_mean_dr_2019 = mean_deaths_rate_2019 - mean_mean_dr_2019

gen interaction_mortality1 = va_total_tall_d2 * decen_mean_deaths_2019
gen interaction_mortality2 = va_total_tall_d2 * decen_mean_dr_2019

label var interaction_rural "Vaccination#Rural"
label var interaction_hosbed "Vaccination#MedicalResource"
label var interaction_mortality1 "Vaccination#Mortality"
label var interaction_mortality2 "Vaccination#MortalityRate"

global interaction_list = "interaction_hosbed interaction_mortality1 interaction_mortality2"

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 interaction_rural $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table3_hetero_mor_ur_hb_OLS.xls, ///
	excel keep(interaction_rural) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("#Rural") lab ///
	nor2 ///
	replace 

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 interaction_hosbed $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table3_hetero_mor_ur_hb_OLS.xls, ///
	excel keep(interaction_hosbed) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("#MedicalResource") lab ///
	nor2 ///
	append

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 interaction_mortality2 $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table3_hetero_mor_ur_hb_OLS.xls, ///
	excel keep(interaction_mortality2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("#MortalityRate") lab ///
	nor2 ///
	append

*********************************
*** Table 4: robustness check ***
*********************************

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table4_robustness_OLS.xls, ///
	excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("YEAR 2021") ///
	nor2 ///
	replace 

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2 ///
	if (time >= 732 & time <= 742) | (time >= 708 & time <= 718), ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table4_robustness_OLS.xls, ///
	excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("YEAR 2019,2021") ///
	nor2 ///
	append

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table4_robustness_OLS.xls, ///
	excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("YEAR 2019-2021") ///
	nor2 ///
	append

reghdfe dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2 ///
	if time >= 731, ///
	absorb(countycode time i.citycode#i.time) ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table4_robustness_OLS.xls, ///
	excel keep(va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("STRICT FE") ///
	nor2 ///
	append

reghdfe dtotal_0 L.va_total_tall_d2 L.va_total_tall_d3 $control2 ///
	if time >= 731, ///
	absorb(countycode time)   ///  
	cluster(countycode)

	local num_dsp = e(df_r) + 1
	outreg2 using $outputs\table4_robustness_OLS.xls, ///
	excel keep(L.va_total_tall_d2) ///
	addstat(Adj.R-Square, e(r2_a), Numbers of county, `num_dsp') nocons ///
	addtext("County FE", "YES", "Year-Month FE", "YES") ///
	cttop("LAG") ///
	nor2 ///
	append
	


**********************************
*** TableA1：summary statistics ***
**********************************

preserve 
keep dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2
outreg2 using $outputs\tableA1_summary.xls, ///
	sum(log) eqkeep(N mean sd min max) ///
	keep(dtotal_0 va_total_tall_d2 va_total_tall_d3 $control2) ///
	replace
restore
	
* summarized facts that might be used
foreach age in $agegroup_list2 {
	preserve
	keep d`age'_0 d`age'_1 d`age'_59 d`age'_60 d`age'_79 d`age'_104 d`age'_106 ///
		d`age'_107 d`age'_108 d`age'_111 d`age'_112 d`age'_121 va_`age'_tall_d2 va_`age'_tall_d3
	outreg2 using $outputs\tableA2_summary_`age'_cause.xls, ///
		sum(log) eqkeep(N mean sd min max) ///
		keep(d`age'_0 d`age'_1 d`age'_59 d`age'_60 d`age'_79 d`age'_104 d`age'_106 d`age'_107 d`age'_108 d`age'_111 d`age'_112 d`age'_121 va_`age'_tall_d2 va_`age'_tall_d3) ///
		replace 
	restore
}

preserve 
keep per_hos_bed mean_deaths_rate_2019 rural
outreg2 using $outputs\tableA3_summary_interaction.xls, ///
	sum(log) eqkeep(N mean sd min max) ///
	replace 
restore





















