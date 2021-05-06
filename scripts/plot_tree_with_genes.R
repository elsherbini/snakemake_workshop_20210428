library(tidyverse)
library(ggtree)

PLOT_FILE = snakemake@output[["plot"]]
TABLE_FILE = snakemake@output[["table"]]

combined_results <- snakemake@input[["hmmer_files"]] %>%
  purrr::map_dfr(read_csv) %>%
  separate(target, into=c("species","contig","orf"), sep="_") %>%
  select(species, query, contig, orf, everything()) %>%
  mutate(query = if_else(str_detect("PTHR", query), str_split(query, fixed("."), simplify=TRUE)[,1], query))

heatmap_data <- combined_results %>% select(species, query) %>%
  group_by(species, query) %>%
  summarise(hit = 1) %>%
  spread(query, hit, fill=0) %>%
  remove_rownames() %>%
  as.data.frame() %>%
  column_to_rownames("species")


gene_order <- heatmap_data %>% as.matrix %>% t %>% dist %>% hclust %>% as.dendrogram %>% order.dendrogram

heatmap_data <- combined_results %>% select(species, query) %>%
  group_by(species, query) %>%
  summarise(hit = "yes") %>%
  spread(query, hit, fill="no") %>%
  remove_rownames() %>%
  as.data.frame() %>%
  column_to_rownames("species") %>%
  select(rev(gene_order))

tree <- read.tree(snakemake@input[["tree"]])

p <- ggtree(tree) + geom_tree() + geom_tiplab(size=4, align=TRUE, linesize = 0.25, offset = 0.69) + xlim(c(0,2)) + geom_treescale(x = 0.1, offset=-1, width = 0.1, fontsize = 4)

p <- gheatmap(p, heatmap_data,colnames_angle=90,hjust=0, width=1.1, colnames_position = 'top',offset=-0.015, font.size = 4) + scale_fill_manual(values = c("#f7fcb9", "#31a354"), guide = FALSE) +ylim(-2,43)

ggsave(PLOT_FILE, p, width=9, height=9)

write_csv(combined_results, TABLE_FILE)


