
#Ce code :
  
# 1. Charge les packages nécessaires.
# 2. Définit le chemin du répertoire contenant les fichiers Excel.
# 3. Liste tous les fichiers Excel dans le répertoire.
# 4. Lit chaque fichier Excel et sélectionne les colonnes nécessaires.
# 5. Ajoute une colonne avec le nom du fichier.
# 6. Concatène tous les dataframes.
# 7. Filtre les lignes où `Total No# of IDPs Ind#` est égal à 0.
# 8. Enregistre le dataframe final dans un fichier Excel.

# Ainsi, le dataframe final n'inclura que les lignes où la colonne `Total No# of IDPs Ind#` est différente de 0.






# Charger les packages
library(readxl)
library(dplyr)

library(openxlsx)

rm(list = ls())
# Définir le chemin du répertoire contenant les fichiers Excel
dir_path <- "D:/Data OIM/"
d = rio::import('D:/Data OIM/Baseline_December_2017.xlsx')
# Lister tous les fichiers Excel dans le répertoire
file_list <- list.files(path = dir_path, pattern = "*.xlsx", full.names = TRUE)

# Initialiser une liste pour stocker les data frames
data_list <- list()
i=0
# Boucle pour importer chaque fichier Excel et sélectionner les variables nécessaires
for (file in file_list) {
 i=i+1
  # Lire le fichier Excel
  data <- read_excel(file)
  names(data)[names(data) == "Total No. of IDPs Ind."] <- "Total No# of IDPs Ind#"
  print(file)
  
  # Sélectionner les colonnes adm1, adm2, adm3
  selected_data <- data %>% select('Snapshot Date', 'Admin 1', 'Admin 2','Admin 3','Admin 3 pcode','Total No# of IDPs Ind#')
  selected_data$`Snapshot Date` <- as.Date(selected_data$`Snapshot Date`, format = "%Y-%m-%d")
  print(selected_data)
  #selected_data$`Total No# of IDPs Ind#` <- as.numeric(selected_data$`Total No# of IDPs Ind#`)
  # Ajouter le data frame sélectionné à la liste
  data_list[[length(data_list) + 1]] <- selected_data
}

# Concaténer tous les data frames pour former le data frame final
final_data <- bind_rows(data_list)

# Supprimer les lignes où 'Total No# of IDPs Ind#' est égal à 0
final_data <- final_data %>% filter(`Total No# of IDPs Ind#` > 0)
write.xlsx(final_data, file = "D:/OneDrive - CGIAR/Mali_data/Final Data/final_data0000000.xlsx")

final_data =rio::import("D:/OneDrive - CGIAR/Mali_data/Final Data/final_data01.xlsx")
library(sf)
Westafrica <- st_read("D:/Data OIM/mli_admbnda_1m_gov_20211220_v2_em/mli_admbnda_adm3_1m_gov_20211220_em.shp") 
#Westafrica <- st_read("D:/Data OIM/gadm41_MLI_shp/gadm41_MLI_3.shp") 

centroids <- st_centroid(Westafrica)

# Extract the coordinates into separate columns
centroids$longitude <- st_coordinates(centroids)[,1]
centroids$latitude <- st_coordinates(centroids)[,2]
centroids <- st_drop_geometry(centroids)

colnames(centroids)[4]= "Admin 3 pcode"
centroids <- centroids %>% select('Admin 3 pcode','longitude','latitude')

merged_df <- merge(centroids,final_data, by = 'Admin 3 pcode',all=T)
write.xlsx(merged_df, file = "D:/OneDrive - CGIAR/Mali_data/Final Data/merged_df.xlsx")
final_dataff <- merged_df %>% filter(`Admin 3`  != 'NA')



write.xlsx(final_dataff, file = "D:/OneDrive - CGIAR/Mali_data/Final Data/DATA01.xlsx")
