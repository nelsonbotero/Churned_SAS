libname tp2 "/folders/myfolders/SEM";


data test;
input IDCLT 1 NOM $3-9 AGE 11-12 SEXE $14;
cards;
1 Jean    23 M
2 Sabrina 45 F
3 Luc     17 M
;
run;

data test;
input IDCLT  NOM $ AGE  SEXE $;
cards;
1 Jean    23 M
2 Sabrina 45 F
3 Luc     17 M
;
run;


data train;
infile '/folders/myfolders/SEM/training.csv'
                 delimiter=','
                 missover
                 firstobs=2
                 DSD
                 lrecl = 32767;
     input
                 CUSTOMER_ID $
                 COLLEGE $
                 DATA
                 INCOME
                 OVERAGE 
                 LEFTOVER 
                 HOUSE 
                 LESSTHAN600k $
                 CHILD
                 JOB_CLASS
                 REVENUE
                 HANDSET_PRICE
                 OVER_15MINS_CALLS_PER_MONTH
                 TIME_CLIENT
                 AVERAGE_CALL_DURATION
                 REPORTED_SATISFACTION $
                 REPORTED_USAGE_LEVEL $
                 CONSIDERING_CHANGE_OF_PLAN $
                 CHURNED $
     ;
 run;

/* 2 / Création dune table SAS à partir dune table SAS */

data test; 
set tp2.produit(obs=10); 
run;
data test; 
set tp2.produit(firstobs=20); 
run;

/* 3 / Les instructions KEEP, DROP et RENAME : */

data pdt; 
set tp2.produit; 
keep id nom prix; 
run;

data pdt(keep = id nom prix); 
set tp2.produit; 
run;

data pdt; 
set tp2.produit(keep = id nom prix); 
run;

data pdt; 
set tp2.produit(drop= id N); 
run;

data pdt; 
set tp2.produit; 
rename prix=prix_unitaire
		nom=produit; 
run;

data pdt; 
set tp2.produit(rename = (prix=prix_unitaire nom=produit)); 
 
run;

/* 4 / Création de nouvelles variables dans une table SAS */

data pdt; 
set tp2.produit;
format table $10. date date9.; /* ddmmyy10. */
table="produit";
TP=2;
date="02OCT2015"d;
run;

data pdt; 
set tp2.produit;
format table $10. date date9.; /* ddmmyy10. */
input table $ tp;
cards;
produit 2
;
run;

data pdt; 
format table $10. date date9.; /* ddmmyy10. */
set tp2.produit;
input table $ tp;
datalines;
produit 2
;
run;

data pdt; 
format table $10. date date9.; /* ddmmyy10. */
set tp2.produit;
input table $ tp;
cards;
produit 2
;
run;

data pdt; set tp2.produit;
prix_dollar=prix*1.12;
run;

/* 5 / linstruction IF et WHERE (le WHERE peut être utilisé également comme une option) */


data t1; 
set tp2.produit;
 where prix<5;
run;

data t2; 
set tp2.produit;
 if id="EP3";
run;

data t3; 
set tp2.produit(where = (id in ("EP3" "EP4" "EP5")));
run;

data t4; 
set tp2.produit;
 if prix*1.12>10;
run;


/* 6a / linstruction IF  THEN  ELSE */

data t6a; 
set tp2.produit;
 format Niveau_Prix $20.;
 prix_dollar=prix*1.35;
 if prix_dollar<3         then Niveau_Prix="Moins de 3$";
 else if prix_dollar<5    then Niveau_Prix="Entre 3 et 5$";
 else 						   Niveau_Prix="Supérieur à 5$";
run;

/* 6b / linstruction SELECT  WHEN  OTHERWISE */

data t6b; 
set tp2.produit;
 format Niveau_Prix $20.;
 prix_dollar=prix*1.35;
 select;
 when (prix_dollar<3) Niveau_Prix="Moins de 3$";
 when (prix_dollar<5) Niveau_Prix="Entre 3 et 5$";
 otherwise Niveau_Prix="Supérieur à 5$";
 end;
run;

proc freq data = t6b; table Niveau_Prix; run;

/* 6c / linstruction FORMAT */

proc format;
value fprix
low-3 = "Moins de 3$"
3-5 = "Entre 3 et 5$"
5-high = "Supérieur à 5$"
;
run;

data t6c; 
set tp2.produit;
format prix_dollar fprix.;
prix_dollar=prix*1.35;
prix_dollar2 = put(prix_dollar,fprix.);
run;

/* 7 / Les jointures */

/* a*/
data bo; 
set tp2.region; 
where region="Beyrouth Ouest"; 
run;

/* b */
proc freq data = tp2.age; 
table clage; 
run;

proc sort data = bo; 
by nuq; 
run;

proc sort data = tp2.age; 
by nuq; 
run;

data bo_40_50_faux;
 merge bo(in=_v1) tp2.age;
 by nuq;
 if _v1;
 where clage in ("Entre 40 et 44 ans" "Entre 45 et 50 ans"); 
run;

data bo_40_50_bon;
 merge bo(in=_v1) tp2.age(where =(clage in ("Entre 40 et 44 ans" "Entre 45 et 50 ans")));
 by nuq;
 if _v1;
run;

data bo_40_50_bon;
 merge bo(in=_v1) tp2.age;
 by nuq;
 if _v1;
 if clage in ("Entre 40 et 44 ans" "Entre 45 et 50 ans"); 
run;

/* c */

proc freq data = bo_40_50_bon; 
table clage; 
run;

proc contents data=bo_40_50_bon;
run;

proc datasets lib=work;
contents data=bo_40_50_bon;
run;
quit;

/* d */

data t6;
 merge bo(in=A) tp2.age(in=B);
 by nuq;
 if B and not A;
run;

proc freq data = t6 noprint; 
table nuq /out=liste_nuq; 
run;

proc sql;
 select count (distinct nuq) as nb_nuq from t6;
quit;

/* e */

data stat; 
set tp2.stat;
 format SF $20.;
 if value=1 then SF="Célibataire";
 else if value=2 then SF="Mariée";
 else SF="Veuve ou divorcée";
run;

/* e */

proc sort data = stat; by nuq; run;
proc sort data = tp2.region; by nuq; run;
proc sort data = tp2.age; by nuq; run;

proc freq data = tp2.age; 
table clage; 
run;

data t7;
 merge stat
       tp2.region
	   tp2.age;
 by nuq;
 if SF="Célibataire" and region="Beyrouth Ouest" 
 and clage not in ("Entre 40 et 44 ans" "Entre 45 et 50 ans");
run;









