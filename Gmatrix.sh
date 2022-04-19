for i in 20000 40000 60000 80000 100000
do
for j in 0.5 0.2 0.1 0.05 0.01 0.005 
do
sed  s/SNPdensity/SNPdensity_${i}_${j}/g Gmatrix.R > Gmatrix_${i}_${j}.R
Rscript Gmatrix_${i}_${j}.R &
done
wait
done
