# ==============================================================================
# Six-Grid Facetted Forest Plot Dashboard (Google Palette)
# ==============================================================================

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# --- 1. Load and Combine All Six Datasets ---
# Read each file and explicitly add a 'Metric' column to identify the grid panel
df_max <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/daily_maximum_temperature.csv", check.names = FALSE) %>% 
      mutate(Metric = "Max Daily Temperature")

df_mean <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/daily_mean_temperature.csv", check.names = FALSE) %>% 
      mutate(Metric = "Mean Daily Temperature")

df_min <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/daily_minimum_temperature.csv", check.names = FALSE) %>% 
      mutate(Metric = "Minimum Daily Temperature")

df_diurnal <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/diurnal_temperature_range.csv", check.names = FALSE) %>% 
      mutate(Metric = "Diurnal Temperature Range")

df_increase <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/sudden_day_to_day_temperature_increase.csv", check.names = FALSE) %>% 
      mutate(Metric = "Sudden Day-to-Day Increase")

df_decrease <- read.csv("output_visualisation/temperature_results/Main_Table2_Historical _Visit/sudden_day_to_day_temperature_decrease.csv", check.names = FALSE) %>% 
      mutate(Metric = "Sudden Day-to-Day Decrease")

# Bind them all into one massive dataframe
df_master <- bind_rows(df_mean, df_max, df_min, df_diurnal, df_increase, df_decrease)

# --- 2. Data Cleaning & Factor Ordering ---
df_clean <- df_master %>%
      # Parse the confidence intervals
      mutate(
            # Order the Lags from top to bottom
            Lag = factor(Lag, levels = rev(c("Lag 1", "Lag 2", "Lag 3", "Lag 4", "Lag 5", "Lag 6"))),
            # Order the Seasons for the legend
            Seasons = factor(Seasons, levels = c("Overall Seasons", "Hot Seasons (May-Oct)", "Not hot (Nov-Apr)")),
            # Order the 6 grid panels logically (Row 1: Absolute temps, Row 2: Variations)
            Metric = factor(Metric, levels = c(
                  "Mean Daily Temperature", "Max Daily Temperature", "Minimum Daily Temperature",
                  "Diurnal Temperature Range", "Sudden Day-to-Day Increase", "Sudden Day-to-Day Decrease"
            ))
      )

# --- 3. Define Google Style Colors ---
google_palette <- c(
      "Overall Seasons"       = "#4285F4", # Google Blue
      "Hot Seasons (May-Oct)" = "#34A853", # Google Green
      "Not hot (Nov-Apr)"     = "#F4B400", # Google Amber
      "null_red"              = "#EA4335", # Google Red 
      "text_gray"             = "#3C4043", # Google Dark Gray
      "grid_gray"             = "#F1F3F4", # Google Light Gray
      "strip_bg"              = "#E8EAED"  # Google Gray (for facet headers)
)

# --- 4. Generate the Facetted Forest Plot ---
forest_plot_6grid_his <- ggplot(df_clean, aes(x = OR, y = Lag, color = Seasons)) +
      # Null reference line
      geom_vline(xintercept = 1, linetype = "dashed", color = google_palette["null_red"], linewidth = 0.8) +
      
      # Error bars (dodged)
      geom_errorbarh(
            aes(xmin = lower, xmax = upper), 
            height = 0.4, 
            position = position_dodge(width = 0.6), 
            linewidth = 0.9
      ) +
      
      # Point estimates (dodged)
      geom_point(
            position = position_dodge(width = 0.6), 
            size = 2
      ) +
      
      # Apply colors
      scale_color_manual(values = google_palette) +
      
      # THE MAGIC: Facet into a 2x3 Grid
      facet_wrap(~ Metric, ncol = 2) +
      
      # Labels
      labs(
            x = "Odds Ratio (OR) and 95% CI",
            y = "Lag Days", 
            title = "Historical Comparison"
      ) +
      
      # Custom Theme
      theme_minimal(base_family = "sans") +
      theme(
            text = element_text(color = google_palette["text_gray"]),
            plot.title = element_text(face = "bold", size = 16, margin = margin(b = 20)),
            axis.title.x = element_text(face = "bold", margin = margin(t = 12)),
            axis.title.y = element_text(face = "bold", margin = margin(r = 12)),
            axis.text = element_text(color = google_palette["text_gray"]),
            
            # Facet Header (Strip) Customization
            strip.text = element_text(face = "bold", size = 11, color = google_palette["text_gray"], margin = margin(t = 8, b = 8)),
            strip.background = element_rect(fill = google_palette["strip_bg"], color = NA),
            panel.spacing = unit(1.5, "lines"), # Add breathing room between grids
            
            # Grid lines
            panel.grid.major.x = element_line(color = google_palette["grid_gray"]),
            panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_line(color = google_palette["grid_gray"], linetype = "dotted"),
            
            # Legend
            legend.position = "bottom",
            legend.title = element_blank(),
            legend.text = element_text(size = 11, margin = margin(r = 15)),
            
            # Margins
            plot.margin = margin(20, 20, 20, 20)
      )

# Display the dashboard
print(forest_plot_6grid_his)
ggsave("historical_forest_plot.svg", 
       plot = forest_plot_6grid_his, width = 8, height = 12, dpi = 300)
