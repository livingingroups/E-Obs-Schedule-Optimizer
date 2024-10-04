# Source the main Shiny app script
source("E-Obs-Schedule-Optimizer.R")

# Check if `ui` and `server` are defined
if (exists("ui") && exists("server")) {
  # Run the Shiny app
  shinyApp(ui = ui, server = server)
} else {
  stop("ui or server not defined correctly in E-Obs-Schedule-Optimizer.R")
}