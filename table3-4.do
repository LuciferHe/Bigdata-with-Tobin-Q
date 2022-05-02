
clear
use "E:\最终产物.dta"

//处理完 firm year//
gen firm = Stkcd
destring firm, replace

gen year = substr(Accper,1,4)
destring year, replace 

xtset firm year

//处理var//
encode Province, g(province)
encode Industry, g(industry)

gen province_year1 = Province + "_" + substr(Accper,1,4)
encode province_year1, g(province_year)

gen industry_year1 = Industry + "_" +substr(Accper,1,4)
encode industry_year1, g(industry_year)

gen bigdata_dummy = BigdataDummy
gen ln_bigdata = LnBigData

global controls_1 "l.LnAssets l.Lev l.ln_Age l.PPE_TA l.SalesGrowth l.ROA l.SOE l.Sh1 l.Board_Size"
global controls_2 "l.LnAssets l.Lev l.ln_Age l.PPE_TA l.SalesGrowth l.ROA l.SOE l.Sh1 l.Board_Size l.Education l.Fangang_index l.GDP_ret"

// page9, table3//


oprobit bigdata_dummy $controls_1 i.year i.industry i.province,r
est store t1

oprobit bigdata_dummy $controls_2 i.year i.industry ,r
est store t2


//gen ln_bigdata2 = log(bigdata_dummy+2)
//reg ln_bigdata2  $controls_3 i.firm i.province_year i.industry_year , r
reghdfe ln_bigdata  $controls_1 , absorb(i.firm i.province_year i.industry_year) 
est store t3

esttab t1 t2 t3 , se  ar2


// page10, table4//
gen tobin_q = TobinQ
global controls_3 "LnAssets Lev PPE_TA SOE SalesGrowth ROA ln_Age"

reghdfe tobin_q ln_bigdata $controls_3 , absorb(i.firm i.year) 
est store m1
reghdfe tobin_q ln_bigdata $controls_3 , absorb(i.firm i.industry_year)
est store m2
reghdfe tobin_q ln_bigdata $controls_3 , absorb(i.firm i.province_year) 
est store m3
reghdfe tobin_q ln_bigdata $controls_3 , absorb(i.firm i.province_year i.industry_year) 
est store m4
esttab m1 m2 m3 m4 , se  ar2

summarize ln_bigdata TobinQ $controls_1 , detail



