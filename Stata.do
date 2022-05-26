Do file
clear 
cd "C:\Users\U\Desktop\stata" 
import excel "C:\Users\U\Desktop\stata\moran.xlsx", sheet("Sheet1") firstrow 
import excel "C:\Users\U\Desktop\stata\HQA.xlsx", sheet("Sheet1") firstrow  // 引入变量
import excel "C:\Users\U\Desktop\stata\panael.xlsx", sheet("Sheet1") firstrow 
import excel "C:\Users\U\Desktop\stata\W0.xlsx", sheet("Sheet1") firstrow
save C:\Users\U\Desktop\stata\moran,replace
save C:\Users\U\Desktop\stata\panael,replace  // 保存变量为dta文件
save C:\Users\U\Desktop\stata\W0,replace 
save C:\Users\U\Desktop\stata\HQA,replace 
// 空间自相关测度
*spatwmat using HQA.dta,name(hqa) //加载矩阵
use HQA.dta  // 使用变量
use moran.dta
spatwmat using W0.dta,name(w) // 加载距离空间矩阵
spatgsa m1 m2 m3 m4 m5 m6 m7 m8 m9 m10,weights(w) moran // 计算变量全局莫兰
spatwmat using W0.dta,name(w) standardize // 标准化空间距离矩阵
spatlsa H,weights(w) moran graph(moran) symbol(n) // 莫兰散点图
spatlsa m1,weights(w) moran graph(moran) symbol(id) id(city) // 莫兰散点图（带地区名字）

// 面板数据
xtset id year  // 截面变量名id 时间变量名year
===============================================================================
*LM检验:检验是否退化为简单模型
clear 
cd "C:\Users\U\Desktop\stata" 
set matsize 5000
use eco
use W0
spcs2xt v1-v31,matrix(Wd) time(10)
spatwmat using Wdxt,name(Weco_310) standardize
save C:\Users\U\Desktop\stata\Wdxt,replace
clear 
cd "C:\Users\U\Desktop\stata" 
use panael_1.dta
xtset id year
spatwmat using Wdxt,name(Wd) standardize
reg Y X1 X2 X3
spatdiag,weights(Wd) // LM检验
*save C:\Users\U\Desktop\stata\Weco_310,replace
================================================================================
*Hausman检验：检验是随机效应还是固定效应
spatwmat using C:\Users\U\Desktop\stata\W0.dta,name(W2) standardize
xsmle Y X1 X2 X3,model(sdm)  wmat(W2) fe nolog
est store sdm_fe
xsmle Y X1 X2 X3,model(sdm)  wmat(W2) re nolog
est store sdm_re
hausman sdm_fe sdm_re
================================================================================
*LM检验:检验是否退化为简单模型
spatwmat using C:\Users\U\Desktop\stata\eco.dta,name(W3) standardize
xsmle Y X1 X2 X3,model(sdm)  wmat(W3) re nolog noeffects
est store sdm_a
xsmle Y X1 X2 X3,model(sar)  wmat(W3) re nolog noeffects
est store sar_a
xsmle Y X1 X2 X3,model(sem)  emat(W3) re nolog noeffects
est store sem_a
lrtest sdm_a sar_a
lrtest sdm_a sem_a
================================================================================
*LM检验：检验固定模型是那一种固定效应
spatwmat using C:\Users\U\Desktop\stata\weights.dta,name(W4) standardize
xsmle oh Intrade rGDP rpeople rRMBcd zhuanli Inpergov,model(sdm)  wmat(W3) fe type(time) nolog noeffects
est store sdm_time
xsmle oh Intrade rGDP rpeople rRMBcd zhuanli Inpergov,model(sar)  wmat(W3) fe type(ind) nolog noeffects
est store sar_ind
xsmle oh Intrade rGDP rpeople rRMBcd zhuanli Inpergov,model(sem)  emat(W3) fe type(both) nolog noeffects
est store sem_both
lrtest sdm_time sar_ind  //个体固定退化成时间固定
lrtest sdm_time sem_both  //双固定退化成时间固定 拒绝就是不可以
spatwmat using C:\Users\U\Desktop\stata\W0.dta,name(W4) standardize
xsmle Y X1 X2 X3,re model(sdm) wmat(W4) log effects
