# =============================================================================
# TP RNA-seq M2 GGB — préparation (à lancer par l'enseignant AVANT le TP)
# -----------------------------------------------------------------------------
# 1. installe les paquets
# 2. télécharge PBMC 3k (10x Genomics)
# 3. construit le sous-ensemble TCGA-BRCA (200 tumeurs, PAM50) -> data/tcga_brca_subset.rds
# Ensuite : tricoter TP_RNAseq_corrige.Rmd une fois, ce qui crée les points de reprise
# dans checkpoints/ (à copier avec data/ dans l'espace des étudiants).
# Durée : ~30-60 min selon la connexion (le téléchargement GDC est le plus long).
# =============================================================================

## 1. Paquets ------------------------------------------------------------------
cran <- c("ggplot2", "pheatmap", "dplyr", "mclust", "msigdbr", "Seurat",
          "patchwork", "BiocManager", "remotes", "rmarkdown")
bioc <- c("DESeq2", "airway", "org.Hs.eg.db", "fgsea", "TCGAbiolinks",
          "SummarizedExperiment", "apeglm")
install.packages("dplyr")
install.packages(setdiff(cran, rownames(installed.packages())))
BiocManager::install(setdiff(bioc, rownames(installed.packages())), update = FALSE)
install.packages("Seurat")

# Bonus spatial (facultatif)
# remotes::install_github("satijalab/seurat-data")
# SeuratData::InstallData("stxBrain")

dir.create("data", showWarnings = FALSE)
dir.create("checkpoints", showWarnings = FALSE)

## 2. PBMC 3k -------------------------------------------------------------------
url_pbmc <- "https://cf.10xgenomics.com/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz"
dest <- "data/pbmc3k.tar.gz"
if (!dir.exists("data/pbmc3k/filtered_gene_bc_matrices/hg19")) {
  download.file(url_pbmc, dest, mode = "wb")
  dir.create("data/pbmc3k", showWarnings = FALSE)
  untar(dest, exdir = "data/pbmc3k")
}
stopifnot(file.exists("data/pbmc3k/filtered_gene_bc_matrices/hg19/matrix.mtx"))

## 3. Sous-ensemble TCGA-BRCA ---------------------------------------------------
library(TCGAbiolinks)
library(SummarizedExperiment)
set.seed(2026)

# Sous-types PAM50 publiés (TCGA PanCancer)
sub <- TCGAquery_subtype(tumor = "brca")
sub <- sub[!is.na(sub$BRCA_Subtype_PAM50) &
           sub$BRCA_Subtype_PAM50 %in% c("LumA", "LumB", "Her2", "Basal"), ]

# 50 patientes par sous-type (Her2 : toutes si moins de 50)
choisis <- unlist(lapply(split(sub$patient, sub$BRCA_Subtype_PAM50),
                         function(p) sample(p, min(50, length(p)))))

query <- GDCquery(project = "TCGA-BRCA",
                  data.category = "Transcriptome Profiling",
                  data.type = "Gene Expression Quantification",
                  workflow.type = "STAR - Counts",
                  sample.type = "Primary Tumor",
                  barcode = choisis)
GDCdownload(query, files.per.chunk = 50)
brca_full <- GDCprepare(query)

# Une seule aliquote par patiente
brca_full <- brca_full[, !duplicated(substr(colnames(brca_full), 1, 12))]

# Comptes bruts, gènes codant des protéines, filtrage léger
brca_full <- brca_full[rowData(brca_full)$gene_type == "protein_coding", ]
cnt <- assay(brca_full, "unstranded")
keep <- rowSums(cnt >= 10) >= 20
cnt <- cnt[keep, ]
rownames(cnt) <- make.unique(rowData(brca_full)$gene_name[keep])

patient <- substr(colnames(cnt), 1, 12)
pam50 <- sub$BRCA_Subtype_PAM50[match(patient, sub$patient)]

brca <- SummarizedExperiment(
  assays  = list(counts = cnt),
  colData = S4Vectors::DataFrame(patient = patient, pam50 = factor(pam50))
)
print(table(brca$pam50))
print(dim(brca))
saveRDS(brca, "data/tcga_brca_subset.rds")

## 4. Vérification rapide ------------------------------------------------------
library(DESeq2); library(Seurat); library(airway)
data("airway"); stopifnot(ncol(airway) == 8)
message("Préparation terminée. Tricotez maintenant TP_RNAseq_corrige.Rmd pour créer checkpoints/.")
