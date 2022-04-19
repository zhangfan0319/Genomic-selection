for j in `cat list_100000`
do
for i in bw42_g sfw_g sfr_. afw_g afr_. bmw_g bmr_. fac_. sf_N fcr rfi ;
do
sed  s/trait/$i/g gblup_5cv.R > ${i}_5cv.R
sed s/Ginv/${j}_Ginv/g ${i}_5cv.R > ${j}_${i}_5cv.R
rm ${i}_5cv.R 
Rscript  ${j}_${i}_5cv.R &
done
wait
done
