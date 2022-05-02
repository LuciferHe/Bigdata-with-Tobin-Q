/*导入托宾Q*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\托宾Q.xlsx", sheet("sheet1") firstrow
keep if strmatch( Accper , "*12-31*")
rename F100901A TobinQ
label variable TobinQ "托宾Q"
destring TobinQ,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\TobinQ_title.dta"

/*导入总资产&净资产*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\总资产&所有者权益(净资产).xlsx", sheet("sheet1") firstrow clear
rename A001000000 TotalAssets
label variable TotalAssets "总资产"
rename A003000000 NetAssets
label variable NetAssets "净资产,所有者权益"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring TotalAssets NetAssets,replace
gen LnAssets = ln( TotalAssets )
 ///(3 missing values generated)///
label variable LnAssets "规模"
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\总资产&净资产.dta"

/*初步合并，删除净资产为0的观测值，并生成杠杆率*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\TobinQ_title.dta"
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\总资产&净资产.dta" ///这里我并未删除_m == 2 的观测，尽量保证我们的title中尽可能多的有公司和年度的观测///
/*

    -----------------------------------------
    not matched                         3,399
        from master                        14  (_merge==1)
        from using                      3,385  (_merge==2)

    matched                            40,944  (_merge==3)
    -----------------------------------------
*/
drop _merge
drop if NetAssets<0
///(565 observations deleted)///
gen Lev = TotalAssets/ NetAssets
label variable Lev "杠杆率"
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\剔除净资产小于0的title.dta"

/*导入ROA*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\ROA_A.xlsx", sheet("sheet1") firstrow clear
rename F050201B ROA
label variable ROA "总资产收益率"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring ROA,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\ROA.dta"

/*导入固定资产比率*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产比率.xlsx", sheet("sheet1") firstrow clear
rename F030801A PPE_TA
label variable PPE_TA "固定资产比率"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring PPE_TA,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产比率&行业.dta"

/*导入省份城市信息*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\省份城市.xlsx", sheet("sheet1") firstrow clear
rename EndDate Accper
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\省份城市.dta"

/*合并行业、省份、城市等固定效应变量*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\剔除净资产小于0的title.dta"
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产比率&行业.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        11,924
        from master                     1,286  (_merge==1)
        from using                     10,638  (_merge==2)

    matched                            42,492  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\ROA.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        11,936
        from master                     1,286  (_merge==1)
        from using                     10,650  (_merge==2)

    matched                            42,492  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\省份城市.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,892
        from master                     1,316  (_merge==1)
        from using                        576  (_merge==2)

    matched                            42,462  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
label variable Province "省份"
label variable City "城市"
rename Indcd Industry
label variable Industry "行业"
order Stkcd Accper Industry Province City TobinQ TotalAssets NetAssets LnAssets Lev PPE_TA ROA
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物1_title.dta"

/*导入IPO日期*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\IPO日期.xlsx", sheet("sheet1") firstrow
drop in 2735
gen Listyear = substr( Listdt,1,4 ) 
drop Listdt T1
drop in 4969/4970
destring Listyear,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\IPO日期.dta"
use "C:\Users\MACHENIKE\Desktop\最终产物.dta"
merge m:m Stkcd using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\IPO日期.dta"
drop if _m == 2
drop _m
gen year = substr( Accper,1,4 )
destring year,replace
gen ln_Age = ln( year- Listyear+1 )
drop year Listyear
label variable ln_Age "ln(当年-上市年+1)"
save "C:\Users\MACHENIKE\Desktop\最终产物_加了Age.dta"

/*导入销售收入增长率*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入增长率.xlsx" , sheet("sheet1") firstrow
rename F081701B SalesGrowth
label variable SalesGrowth "销售收入增长率"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring SalesGrowth,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入增长率.dta"

/*导入实际控制人性质*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\实际控制人性质.xlsx", sheet("sheet1") firstrow clear
drop S0701a S0702a S0701b
label variable S0702b "实际控制人性质"
rename S0702b SOE
bys Stkcd Reptdt:gen n = _n
drop if n >1 & SOE==""
gen temp = 1 if regexm( SOE ,"1100")|regexm( SOE ,"2000")|regexm( SOE ,"2100")|regexm( SOE ,"2120")
replace temp = 0 if temp==.
bys Stkcd Reptdt:egen temp2 = sum( temp )
drop if n>1
replace SOE = "1" if temp2>=1
replace SOE ="" if temp2 == 0
drop n temp temp2
destring SOE,replace
replace SOE=0 if SOE==.
///SOE为1代表实际控制人为国企，SOE为0代表非国企///
gen Accper = substr( Reptdt,1,4 ) +"-12-31"
drop Reptdt
bys Stkcd Accper:gen n = _n
drop if n>1
drop n
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\实际控制人性质.dta"

/*导入第一大股东持股比例*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\第一大股东持股比例.xlsx", sheet("Sheet2") firstrow clear
keep if strmatch( Reptdt , "*12-31*")
keep if strmatch( S0306a , "*1*")
drop S0301a S0306a ShareholderNature Category
rename S0304a Sh1
label variable Sh1 "第一大股东持股比例"
destring Sh1,replace
gen Accper = substr( Reptdt ,1,4)+"-12-31"
drop Reptdt
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\第一大股东持股比例.dta"

/*董事人数*/
///董事人数为年末在职董事///
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\董事人数.xlsx", sheet("sheet1") firstrow clear
keep if strmatch( StatisticalCaliber , "*1*")
drop StatisticalCaliber
gen Accper = substr(Enddate,1,4) + "-12-31"
drop Enddate
destring DirectorNumber,replace
rename DirectorNumber Board_Size
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\董事会规模.dta"

/*初步合并2*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物1_title.dta"
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入增长率.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        11,916
        from master                     1,286  (_merge==1)
        from using                     10,630  (_merge==2)

    matched                            42,492  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\实际控制人性质.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         3,397
        from master                     2,586  (_merge==1)
        from using                        811  (_merge==2)

    matched                            43,135  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\第一大股东持股比例.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,585
        from master                     1,738  (_merge==1)
        from using                      7,847  (_merge==2)

    matched                           136,093  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\董事会规模.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         2,811
        from master                     2,280  (_merge==1)
        from using                        531  (_merge==2)

    matched                            41,498  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物2_title.dta"





/*导入省份教育程度*/
///没有15-20年的数据，不清楚为什么下载下来就没有///
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省教育水平.xlsx", sheet("sheet1") firstrow clear
drop if strmatch( Prvcnm , "*中国*")
drop in 1/2
rename Pop01 年底人口数
rename Pop30 大专及以上文化程度人口数
destring 年底人口数 大专及以上文化程度人口数,replace
replace 年底人口数 = 年底人口数*10000
///此处一起运行就有bug，分布运行就没bug??///
gen Education = 大专及以上文化程度人口数/ 年底人口数
drop 年底人口数 大专及以上文化程度人口数
drop Prvcnm_id
rename Prvcnm Province
gen Accper = substr( Sgnyea,1,4 ) + "-12-31"
drop Sgnyea
replace Province= "天津市" if regexm( Province ,"天津") == 1
replace Province= "北京市" if regexm( Province ,"北京") == 1
replace Province= "河北省" if regexm( Province ,"河北") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "内蒙古自治区" if regexm( Province ,"内蒙古") == 1
replace Province= "辽宁省" if regexm( Province ,"辽宁") == 1
replace Province= "吉林省" if regexm( Province ,"吉林") == 1
replace Province= "黑龙江省" if regexm( Province ,"黑龙江") == 1
replace Province= "上海市" if regexm( Province ,"上海") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "安徽省" if regexm( Province ,"安徽") == 1
replace Province= "福建省" if regexm( Province ,"福建") == 1
replace Province= "山东省" if regexm( Province ,"山东") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "广东省" if regexm( Province ,"广东") == 1
replace Province= "广西省" if regexm( Province ,"广西") == 1
replace Province= "海南省" if regexm( Province ,"海南") == 1
replace Province= "重庆市" if regexm( Province ,"重庆") == 1
replace Province= "四川省" if regexm( Province ,"四川") == 1
replace Province= "贵州省" if regexm( Province ,"贵州") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "西藏自治区" if regexm( Province ,"西藏") == 1
replace Province= "陕西省" if regexm( Province ,"陕西") == 1
replace Province= "甘肃省" if regexm( Province ,"甘肃") == 1
replace Province= "宁夏回族自治区" if regexm( Province ,"宁夏") == 1
replace Province= "新疆维吾尔自治区" if regexm( Province ,"新疆") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "宁夏" if regexm( Province ,"宁夏") == 1
replace Province= "广西" if regexm( Province ,"广西") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "北京市" if regexm( Province ,"北京市") == 1
replace Province= "上海市" if regexm( Province ,"上海市") == 1
replace Province= "重庆市" if regexm( Province ,"重庆市") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "湖南省" if regexm( Province ,"长沙") == 1
replace Province= "浙江省" if regexm( Province ,"宁波") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "内蒙古" if regexm( Province ,"乌兰察布") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "青海省" if regexm( Province ,"青海") == 1
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省教育水平.dta"

/*导入省份市场化指数*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\市场化指数.xlsx", sheet("Sheet3") firstrow clear
tostring year,replace
rename 省份 Province
drop if strmatch( Province , "*中国*")
tostring year,replace
gen Accper = year + "-12-31"
drop year
rename 市场化总指数 Fangang_index
replace Province= "天津市" if regexm( Province ,"天津") == 1
replace Province= "北京市" if regexm( Province ,"北京") == 1
replace Province= "河北省" if regexm( Province ,"河北") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "内蒙古自治区" if regexm( Province ,"内蒙古") == 1
replace Province= "辽宁省" if regexm( Province ,"辽宁") == 1
replace Province= "吉林省" if regexm( Province ,"吉林") == 1
replace Province= "黑龙江省" if regexm( Province ,"黑龙江") == 1
replace Province= "上海市" if regexm( Province ,"上海") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "安徽省" if regexm( Province ,"安徽") == 1
replace Province= "福建省" if regexm( Province ,"福建") == 1
replace Province= "山东省" if regexm( Province ,"山东") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "广东省" if regexm( Province ,"广东") == 1
replace Province= "广西省" if regexm( Province ,"广西") == 1
replace Province= "海南省" if regexm( Province ,"海南") == 1
replace Province= "重庆市" if regexm( Province ,"重庆") == 1
replace Province= "四川省" if regexm( Province ,"四川") == 1
replace Province= "贵州省" if regexm( Province ,"贵州") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "西藏自治区" if regexm( Province ,"西藏") == 1
replace Province= "陕西省" if regexm( Province ,"陕西") == 1
replace Province= "甘肃省" if regexm( Province ,"甘肃") == 1
replace Province= "宁夏回族自治区" if regexm( Province ,"宁夏") == 1
replace Province= "新疆维吾尔自治区" if regexm( Province ,"新疆") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "宁夏" if regexm( Province ,"宁夏") == 1
replace Province= "广西" if regexm( Province ,"广西") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "北京市" if regexm( Province ,"北京市") == 1
replace Province= "上海市" if regexm( Province ,"上海市") == 1
replace Province= "重庆市" if regexm( Province ,"重庆市") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "湖南省" if regexm( Province ,"长沙") == 1
replace Province= "浙江省" if regexm( Province ,"宁波") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "内蒙古" if regexm( Province ,"乌兰察布") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "青海省" if regexm( Province ,"青海") == 1
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\市场化指数.dta"

/*导入GDP年度增速*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省GDP值.xlsx", sheet("sheet1") firstrow clear
drop Prvcnm_id 
drop in 1/2
rename Prvcnm Province
gen Accper = Sgnyea + "-12-31"
drop Sgnyea
destring Gdp0101,replace
gen Year = substr(Accper ,1,4)
destring Year,replace
encode Province, gen (province)
xtset province Year
gen l_Gdp0101=l.Gdp0101
gen GDP_ret=(Gdp0101-l_Gdp0101)/l_Gdp0101
drop Gdp0101 Year province l_Gdp0101
drop if strmatch( Province , "*中国*")
replace Province= "天津市" if regexm( Province ,"天津") == 1
replace Province= "北京市" if regexm( Province ,"北京") == 1
replace Province= "河北省" if regexm( Province ,"河北") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "内蒙古自治区" if regexm( Province ,"内蒙古") == 1
replace Province= "辽宁省" if regexm( Province ,"辽宁") == 1
replace Province= "吉林省" if regexm( Province ,"吉林") == 1
replace Province= "黑龙江省" if regexm( Province ,"黑龙江") == 1
replace Province= "上海市" if regexm( Province ,"上海") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "安徽省" if regexm( Province ,"安徽") == 1
replace Province= "福建省" if regexm( Province ,"福建") == 1
replace Province= "山东省" if regexm( Province ,"山东") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "广东省" if regexm( Province ,"广东") == 1
replace Province= "广西省" if regexm( Province ,"广西") == 1
replace Province= "海南省" if regexm( Province ,"海南") == 1
replace Province= "重庆市" if regexm( Province ,"重庆") == 1
replace Province= "四川省" if regexm( Province ,"四川") == 1
replace Province= "贵州省" if regexm( Province ,"贵州") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "西藏自治区" if regexm( Province ,"西藏") == 1
replace Province= "陕西省" if regexm( Province ,"陕西") == 1
replace Province= "甘肃省" if regexm( Province ,"甘肃") == 1
replace Province= "宁夏回族自治区" if regexm( Province ,"宁夏") == 1
replace Province= "新疆维吾尔自治区" if regexm( Province ,"新疆") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "宁夏" if regexm( Province ,"宁夏") == 1
replace Province= "广西" if regexm( Province ,"广西") == 1
replace Province= "山西省" if regexm( Province ,"山西") == 1
replace Province= "北京市" if regexm( Province ,"北京市") == 1
replace Province= "上海市" if regexm( Province ,"上海市") == 1
replace Province= "重庆市" if regexm( Province ,"重庆市") == 1
replace Province= "浙江省" if regexm( Province ,"浙江") == 1
replace Province= "江苏省" if regexm( Province ,"江苏") == 1
replace Province= "湖南省" if regexm( Province ,"长沙") == 1
replace Province= "浙江省" if regexm( Province ,"宁波") == 1
replace Province= "河南省" if regexm( Province ,"河南") == 1
replace Province= "江西省" if regexm( Province ,"江西") == 1
replace Province= "湖南省" if regexm( Province ,"湖南") == 1
replace Province= "云南省" if regexm( Province ,"云南") == 1
replace Province= "内蒙古" if regexm( Province ,"乌兰察布") == 1
replace Province= "湖北省" if regexm( Province ,"湖北") == 1
replace Province= "青海省" if regexm( Province ,"青海") == 1
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省GDP增速.dta"

/*初步合并3*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物2_title.dta"
merge m:m Province using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省教育水平.dta"
/*
 Result                           # of obs.
    -----------------------------------------
    not matched                         2,025
        from master                     1,995  (_merge==1)
        from using                         30  (_merge==2)

    matched                            41,783  (_merge==3)
    -----------------------------------------

*/
drop if _m == 2
drop _m
merge m:m Province using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\市场化指数.dta"
/*
Result                           # of obs.
    -----------------------------------------
    not matched                         2,041
        from master                     1,995  (_merge==1)
        from using                         46  (_merge==2)

    matched                            41,783  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge m:m Province using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\各省GDP增速.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         2,025
        from master                     1,995  (_merge==1)
        from using                         30  (_merge==2)

    matched                            41,783  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
sort Stkcd Accper
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物3.dta"


/*导入销售收入*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入.xlsx", sheet("sheet1") firstrow clear
rename B001101000 TFP系列1
label variable TFP系列1 "销售收入"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring TFP系列1,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入.dta"

/*导入固定资产净值*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产净值.xlsx", sheet("sheet1") firstrow clear
rename A001212000 TFP系列2
label variable TFP系列2 "固定资产净值"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring TFP系列2,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产净值.dta"

/*导入购买商品、接受劳务支付的现金*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\购买商品、接受劳务支付的现金.xlsx", sheet("sheet1") firstrow clear
rename C001014000 TFP系列3
label variable TFP系列3 "购买商品、接受劳务支付的现金"
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring TFP系列3,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\购买商品、接受劳务支付的现金.dta"

/*导入员工人数*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\员工人数.xlsx", sheet("sheet1") firstrow clear
gen Accper = substr(Reptdt,1,4) + "-12-31"
drop Reptdt
rename Y0601b TFP系列4
label variable TFP系列4 "员工人数"
drop in 1/2
destring TFP系列4,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\员工人数.dta"

/*导入研发支出*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\研发人员&研发投入金额(07年开始).xlsx", sheet("sheet1") firstrow clear
rename Symbol Stkcd
gen Accper = substr(EndDate,1,4) + "-12-31"
drop EndDate
keep if strmatch( StateTypeCode , "*1*")
drop StateTypeCode Currency Explanation
rename RDSpendSum RD_Exp
label variable RD_Exp "研发支出"
rename RDPerson RDworker
label variable RDworker "研发人员"
destring RD_Exp RDworker,replace 
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\研发人员&研发投入金额.dta"

/*导入竞争程度一坨*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\竞争程度一坨.xlsx", sheet("sheet1") firstrow clear
rename B001100000 营业总收入
rename B001101000 营业收入
rename B001200000 营业总成本
rename B001201000 营业成本
rename B001207000 营业税金及附加
keep if strmatch( Accper , "*12-31*")
keep if strmatch( Typrep , "*A*")
drop Typrep
destring 营业总收入 营业收入 营业总成本 营业成本 营业税金及附加,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\竞争程度一坨.dta"

/*导入公司经纬度*/
import excel "C:\Users\MACHENIKE\Desktop\高级资本市场数据\公司经纬度.xlsx", sheet("sheet1") firstrow clear
rename Symbol Stkcd
drop ShortName
rename Lng Firm_Long
label variable Firm_Long "经度"
rename Lat Firm_Lati
label variable Firm_Lati "纬度"
gen Accper = substr(EndDate,1,4) + "-12-31"
drop EndDate
drop in 1/2
destring Firm_Long Firm_Lati,replace
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\公司经纬度.dta"


/*初步合并4!!!!!!*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物3.dta"
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\销售收入.dta"
/*
	Result                           # of obs.
    -----------------------------------------
    not matched                           568
        from master                         3  (_merge==1)
        from using                        565  (_merge==2)

    matched                            43,775  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\固定资产净值.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           568
        from master                         3  (_merge==1)
        from using                        565  (_merge==2)

    matched                            43,775  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\购买商品、接受劳务支付的现金.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           568
        from master                         3  (_merge==1)
        from using                        565  (_merge==2)

    matched                            43,775  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\员工人数.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           568
        from master                         3  (_merge==1)
        from using                        565  (_merge==2)

    matched                            43,775  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\研发人员&研发投入金额.dta"
/*
	Result                           # of obs.
    -----------------------------------------
    not matched                        16,341
        from master                    16,204  (_merge==1)
        from using                        137  (_merge==2)

    matched                            27,574  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\竞争程度一坨.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           568
        from master                         3  (_merge==1)
        from using                        565  (_merge==2)

    matched                            43,775  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
merge 1:m Stkcd Accper using "C:\Users\MACHENIKE\Desktop\高级资本市场数据\公司经纬度.dta"
/*
	Result                           # of obs.
    -----------------------------------------
    not matched                         2,183
        from master                     1,608  (_merge==1)
        from using                        575  (_merge==2)

    matched                            42,170  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物4_g.dta"


/*构造竞争程度*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物4_g.dta"
encode City , g(CityID)
encode Industry,g( IndustryID )
gen profit=( 营业总收入- 营业总成本 - 营业税金及附加 )/营业总收入
bys IndustryID Accper :egen cl = sd( profit )
bys IndustryID Accper :gen levelofcompetition = 1/cl^2
gen center= 1 if regexm( City ,"北京市")|regexm( City ,"乌兰察布市")|regexm( Province ,"贵州省") /*改中心呢*/
replace center = 0 if center==.
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\中间产物5_g.dta"

/*整理年报关键词*/
use "C:\Users\MACHENIKE\Desktop\高级资本市场数据\年报关键词.xlsx", sheet("sheet1") firstrow
rename 股票名称 Stkcd
gen Accper = substr(年份,1,4) + "-12-31"
drop 年份
save "C:\Users\MACHENIKE\Desktop\高级资本市场数据\年报关键词.dta"
/*上面这段我不确定  我是事后默写的.....我忘了我都干啥了*/


/*最后的合并*/
use "C:\Users\ll\Desktop\高级资本市场数据\中间产物5_g.dta" 
merge 1:m Stkcd Accper using "C:\Users\ll\Desktop\高级资本市场数据\年报关键词.dta"
/* Result                           # of obs.
    -----------------------------------------
    not matched                        13,354
        from master                    10,754  (_merge==1)
        from using                      2,600  (_merge==2)

    matched                            33,024  (_merge==3)
    -----------------------------------------
*/
drop if _m == 2
drop _m
save "C:\Users\ll\Desktop\高级资本市场数据\中间产物6_g.dta"

/*label and 缩尾*/
save "C:\Users\ll\Desktop\高级资本市场数据\中间产物6_g.dta"
label variable center "是否为大数据中心"
drop cl
label variable levelofcompetition "竞争程度"
winsor2 TobinQ TobinQ NetAssets LnAssets Lev PPE_TA ROA SalesGrowth Sh1 Board_Size Education Fangang_index GDP_ret levelofcompetition LnBigData ,replace cuts(1 99)
/*全要素的我都没缩尾  全要素的我都没缩尾！*/

save "C:\Users\ll\Desktop\高级资本市场数据\最终产物.dta"