library(ASRgenomics)
library(data.table)
setwd("/storage-04/temp3/VcfDataBase/density")  ####修改工作路径
geno=fread("pop.raw",header =TRUE,sep = " ")
id <- read.table("ID.txt",header = T," ")
dim(geno)
geno1 <- geno[,c(-1:-6)]
geno1 <- as.matrix(geno1)
rownames(geno1) <- id$IID

M_filter <- qc.filtering(M = geno1, base = FALSE, ref = NULL,
                         maf = 0.01, marker.callrate = 0.2, ind.callrate = 0.2, impute = FALSE,
                         na.string = "-9", plots = TRUE)
Gmat = G <- G.matrix(M = M_filter$M.clean, method = "VanRaden", na.string = NA)$G
diag(G) = diag(G) + 0.01
Ginv <- G.inverse(G = G, sparseform = TRUE)$Ginv
write.csv(Ginv,"Ginv.csv")
