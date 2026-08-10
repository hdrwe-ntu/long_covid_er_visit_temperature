# Goal: combining contemporary analyses and historical analyses results

# Package
library(ggpubr)

# Source files
# Contemporary analysis: 
source("output_visualisation/contemporary_staked_lag_plot.R")
# Historical analysis:
source("output_visualisation/historical_staked_lag_plot.R")

# Plots to wrap:
## Main analysis: forest_main_cont; forest_main_his
## Additional analysis: forest_add_cont; forest_add_his

# Combine main analyses: ----
combined_main_forest <- ggarrange(
      forest_main_cont,          # Row 1 (top)
      forest_main_his,           # Row 2 (bottom)
      nrow = 2,
      ncol = 1,
      common.legend = TRUE,      # Merge the two identical legends into one
      legend = "bottom",
      align = "v",               # Align panel widths/x-axes vertically
      labels = c("A", "B")       # Optional: panel tags for publication
)

# Save files:
ggsave(
      filename = "output_visualisation/combined_main_forest_plot.svg",
      plot = combined_main_forest,
      width = 16, height = 10
)
