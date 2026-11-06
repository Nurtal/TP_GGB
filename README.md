# TP RNA-seq (3 h)

## Déroulé
| Temps | Partie | Message du cours mobilisé |
|---|---|---|
| 0:00 | Prise en main | matrice + métadonnées |
| 0:10 | Bulk (airway) | normalisation, ACP comme contrôle, lot dans le modèle, DEG, GSEA |
| 1:20 | Pause | |
| 1:30 | Single-cell (PBMC 3k) | QC cellulaire, HVG + ACP, graphe, UMAP « carte et non mesure », annotation |
| 2:20 | Endotypes (TCGA-BRCA, PAM50) | clustering non supervisé, stabilité, circularité |
| 2:50 | Bilan | squelette commun |
| bonus | Spatial (stxBrain) | domaines, gènes à variation spatiale |

## To Check
- `msigdbr` : l'argument est `collection = "H"` dans les versions récentes, `category = "H"` dans les anciennes (géré par un `tryCatch`).
- Seurat v4 et v5 : `GetAssayData(layer = ...)` est la syntaxe v5 (en v4 : `slot = "counts"`).
- La numérotation des clusters PBMC peut varier : le vecteur `nouveaux_noms` du corrigé suit l'ordre du tutoriel Seurat ; vérifier sur le dot plot.
- TCGA : `TCGAquery_subtype()` et la colonne `gene_type` de `rowData` selon la version de TCGAbiolinks. Her2 peut compter moins de 50 patientes.
- Les chiffres cités dans les réponses (nombre de DEG, ARI) sont des ordres de grandeur : les mettre à jour après exécution.

## Régénérer la version étudiant
Le corrigé et la version étudiant sont produits à partir d'une source unique (`src_TP.Rmd`) :
`python3 make_student.py src_TP.Rmd TP_RNAseq_etudiant.Rmd TP_RNAseq_corrige.Rmd`
Dans la source, `code  #@ code à trous` définit un trou et `<!-- REP --> … <!-- /REP -->` une réponse.


## In case of big stupid R version pb
curl -s https://raw.githubusercontent.com/eddelbuettel/r2u/master/inst/scripts/add_cranapt_noble.sh | sudo bash
