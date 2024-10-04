#### Eobs device battery life estimator ####

###Required packages###
if (!require('shiny')){ install.packages('shiny', dependencies = TRUE, type="source")} ; suppressMessages(require("shiny"))
if (!require('lubridate')){ install.packages('lubridate', dependencies = TRUE, type="source")} ; suppressMessages(require("lubridate"))
if (!require('shinyvalidate')){ install.packages('shinyvalidate', dependencies = TRUE, type="source")} ; suppressMessages(require("shinyvalidate"))
if (!require('dplyr')){ install.packages('dplyr', dependencies = TRUE, type="source")} ; suppressMessages(require("dplyr"))
if (!require('shinyWidgets')){ install.packages('shinyWidgets', dependencies = TRUE, type="source")} ; suppressMessages(require("shinyWidgets"))
if (!require('htmltools')){ install.packages('htmltools', dependencies = TRUE, type="source")} ; suppressMessages(require("htmltools"))

#Check that required packages are installed on the system
areinstaled=data.frame(installed.packages())

if(all(c("shiny", "lubridate", "shinyvalidate", "dplyr", "shinyWidgets", "htmltools") %in% areinstaled$Package)==FALSE){
  required_packages=c("shiny", "lubridate", "shinyvalidate", "dplyr", "shinyWidgets", "htmltools")
  missing_packages=c("shiny", "lubridate","shinyvalidate", "dplyr", "shinyWidgets", "htmltools") %in% areinstaled$Package
  stop(paste("The following packages are not installed:", required_packages[which(missing_packages==FALSE)], sep = " "))
}

#########################################################
#########################################################
ui <- navbarPage("E-Obs Schedule Optimizer", id = "navbar",
# Main Panel
tabPanel("Battery Life and Memory Estimator for eObs Devices",
         
fluidPage(
  tags$head(
    tags$style(HTML("
    .shiny-text-output {
      font-size: 0.8em; /* Adjust font size as needed */
      background-color: transparent !important;
      border: none !important;
      box-shadow: none !important;
      padding:0;
      margin: 0;
    }
    .shiny-output-error {
      background-color: transparent !important;
      border: none !important;
    }
    .shiny-output-error:before {
      content: none !important;
    }
    .developer-credit {
        text-align: left; /* Aligns the text to the lest */
        padding: 5px; /* Adds some padding */
        color: #555; /* Sets the text color */
        font-size: 1em; /* Sets the size of the text */
      }
    .readonly-background {
      background-color: #add8e6; /* light blue */
      padding: 5px 10px 5px 5px; /* top, right, bottom, left padding */
      border-radius: 5px;
      margin-bottom: 5px;
      display: inline-block; /* This will make the div only as wide as its content */
    }
.summary-background {
      background-color: #FFD8B1; /* light orange */
      border: 2px solid red; /* Red border */
      padding: 10px; /* Padding around the content */
      border-radius: 5px;
      margin-bottom: 5px;
      display: block; /* Take the full width */
    }
    .summary-text-value { 
      font-weight: bold; /* Make only the value bold */
      font-size: 1.2em; /* Larger font size for values */
    }
    .summary-text {
      font-size: 1.2em; /* Larger font size for text */
      display: inline; /* Keep text inline with the value */
    }
    /* Ensure the box spans the entire width for the summary */
    .overall-summary {
      border: 2px solid red; /* Red border */
      padding: 10px;
      border-radius: 5px;
      margin-bottom: 15px;
    }
h3 {
      text-decoration: underline; /* Underline section titles */
    }
    /* Center the main title */
    .main-title {
      text-decoration: underline;
      text-align: center;
    }
    .note-text {
      color: purple; /* or any other color you prefer */
      font-size: 0.9em; /* Adjust font size as needed */
      margin-top: 10px; /* Space above the note */
    }
  "))
  ),
  
  # titlePanel(div("Battery Life and Memory Estimator for eObs Devices", class = "main-title")),
  
  # Main layout with inputs
  fluidRow(class = "reduce-gap",
    column(4, # Adjust the width percentage as needed
           numericInput("BatteryCapacity",
                        label = HTML('<div style="font-size: 1.4em; text-decoration: underline;">Battery capacity (mAh)</div>'), #font-weight: bold
                        value = 3000, min = 0)
    ),
    column(4, # Adjust the width percentage as needed
           radioButtons("numSchedules", "Number of high-res GPS schedules",
                        choices = list("One" = 1, "Two" = 2),
                        selected = 1, inline = TRUE)
    ),
    column(4, # Adjust the width percentage as needed
           div(class = "developer-credit", 
               "App developed by Richard Michael Gunner; RGUNNER@AB.MPG.DE")
    )
  ),
  
  fluidRow(
    # GPS Low Res settings
    column(4, # Adjust the width as needed
           h3("Low Res GPS Schedule"), # Adjust title font size as needed
           numericInput("TTFFLR", "Average Time To First Fix (TTFF) with GPS LOW RES (s)", value = 30, min = 0),
           numericInput("hoursLR", "Number of Hours with GPS LOW RES", value = 0, min = 0),
           numericInput("burstsPerHourLR", "Bursts per Hour with GPS LOW RES", value = 0, min = 0),
           numericInput("burstlengthLR", "Burst length in LOW RES: Number of GPS fixes per GPS burst", value = 1, min = 0),
           tags$script(HTML("
    $(document).ready(function() {
      $('#burstlengthLR').prop('disabled', true);
    });
  ")),
           textOutput("burstsPerMinLR"),
           textOutput("burstsPerDayLR"),
           textOutput("fixesPerDayLR"),
           textOutput("secondsGPSRunningLR")
    ),
    # GPS High Res settings
    column(4,
    uiOutput("highResGPS"), # Placeholder for dynamically adjusting High Res GPS schedules
    uiOutput("burstsPerMinHR"),
    textOutput("burstsPerDayHR"),
    textOutput("fixesPerDayHR"),
    textOutput("secondsGPSRunningHR")
    ),
    
    # Concurrent GPS IMU ACC & Quat + Compass settings
    column(4, 
           h3("Concurrent GPS-IMU Sampling"), # Adjust title font size as needed
           radioButtons("imuAcc20Hz", "Concurrent IMU ACC with Samplerate 20Hz enabled", choices = c("Yes" = "yes", "No" = "no"), selected = "no"),
           radioButtons("imuQuatComp20Hz", "Concurrent IMU Quaternions and Compass with Samplerate 20Hz enabled", choices = c("Yes" = "yes", "No" = "no"),  selected = "no"),
           radioButtons("imuQuatComp1Hz", "Concurrent IMU Quaternions and Compass with Samplerate 1Hz enabled", choices = c("Yes" = "yes", "No" = "no"), selected = "no"),
           textOutput("AverageMemoryGPS"),
           textOutput("AverageCurrentConsumptionGPS")
    )
  ),
  
  hr(), # Break
  
  fluidRow(
    # 1 Hz GPS settings
    column(4, # Adjust the width as needed
           h3("GPS 1Hz Mode"), # Adjust title font size as needed
           numericInput("hours1Hz", "Number of Hours with 1 Hz GPS", value = 0, min = 0),
           radioButtons("imuAcc20HzGPS1Hz", "Concurrent 1 Hz GPS-IMU ACC with Samplerate 20Hz enabled", choices = c("Yes" = "yes", "No" = "no"), selected = "no"),
           radioButtons("imuQuatComp20HzGPS1Hz", "Concurrent 1 Hz GPS-IMU Quaternions and Compass with Samplerate 20Hz enabled", choices = c("Yes" = "yes", "No" = "no"),  selected = "no"),
           radioButtons("imuQuatComp1HzGPS1Hz", "Concurrent 1 Hz GPS-IMU Quaternions and Compass with Samplerate 1Hz enabled", choices = c("Yes" = "yes", "No" = "no"), selected = "no"),
           textOutput("fixesPerDay1Hz"),
           textOutput("AverageMemoryGPS1Hz"),
           textOutput("AverageCurrentConsumptionGPS1Hz")
    ),
    # Accelerometer
    column(4, # Adjust the width as needed
           h3("Accelerometer Settings"), # Adjust title font size as needed
           numericInput("ACCSR", "Acceleration Sample Rate (ACC SR) Divisor", value = 5, min = 0),
           numericInput("Axes", "Number of active axes (1, 2 or 3)", value = 3, min = 1),
           numericInput("AccByteCount", "Acceleration Byte Count", value = 900, min = 0),
           numericInput("AccInterval", "Acceleration Interval (min)", value = 1, min = 0),
           numericInput("ACCDutyCycle", "Duty cycle for ACC (hours ON per day)", value = 0, min = 0),
           textOutput("SampleRatePerAxis"),
           textOutput("BytesAvailablePerBurst"),
           textOutput("ConsumedMemoryPerBurst"),
           textOutput("SamplingDuration"),
           textOutput("AverageMemoryACC"),
           textOutput("AverageCurrentConsumptionACC")
    ),
    column(4, # Adjust the width as needed
           h3("IMU Standalone Settings"), # Adjust title font size as needed
           numericInput("IMUACCDatasetCount", "IMU ACC Dataset Count", value = 10, min = 0),
           numericInput("IMUQUATCOMPDatasetCount", "IMU QUAT & COMP Dataset Count", value = 20, min = 0),
           numericInput("IMUInterval", "IMU Interval (min)", value = 1, min = 0),
           numericInput("IMUDutyCycle", "Duty cycle for IMU Standalone (hours ON per day)", value = 0, min = 0),
           textOutput("ConsumedMemoryPerBurstIMU"),
           textOutput("SampleDurationIMUACC"),
           textOutput("SampleDurationIMUQUATCOMP"),
           textOutput("ResultantSamplingDurationIMU"),
           textOutput("AverageMemoryIMU"),
           textOutput("AverageCurrentConsumptionIMU")
    )
  ),
  
  hr(), # Break
  
  fluidRow(
    # Pinger 
    column(3, # Adjust the width as needed
           h3("Pinger Settings", align = "center"), # Adjust title font size as needed
           numericInput("Pulses", "Pulses Per Minute", value = 60, min = 0),
           numericInput("PingerDutyCycle", "Duty cycle for pinger (hours ON per day)", value = 8, min = 0),
           textOutput("AverageCurrentConsumptionPinger"),
    ),
    # Read-Only 'Other' Values Display
    column(4, # Adjust the width as needed
    h3("Other 'Read-Only' Settings", align = "center"), # Adjust title font size as needed
    div(textOutput("standbyCurrent"),
        textOutput("batterySelfDischarge"),
        textOutput("radioInterval"),
        textOutput("averageCurrentRadio"),
        textOutput("averageCurrentDataDownload"), class = "readonly-background",
    div(class = "note-text", 
        "Note: This app only provides a generic estimate and does not account for battery discharge since the date of manufacture/related to delayed starts, or other user-defined settings that can change sampling rates, e.g., qperiod, acc-informed GPS, etc.")
    )),
    # Overal Memory Usage and Battery Life Estimation
    column(5, # Adjust the width as needed
           h3("Overal Memory Usage and Battery Life Estimation", align = "center"), # Adjust title font size as needed
           div(uiOutput("TotalAvgMem"),
               uiOutput("TotalAvgCurrCons"),
               uiOutput("MinDwnldTime"),
               uiOutput("MemFull"),
               uiOutput("BattEmpty"), class = "summary-background")
    )
  ),
  
  hr(),
),
),

# Delayed Start Panel
tabPanel("Delayed Start Calendar and Timezone Converter",
         fluidRow(
           # Today:
           column(4, # Adjust the width as needed
                  h3("Today (your computer local time):"),
                  textOutput("DateToday"),
                  textOutput("EobsDaynumbertoday"),
                  textOutput("GPSDaynumbertoday"),
                  textOutput("GPSWeeknumbertoday"),
                  textOutput("GPSDayofweektoday"),
                  textOutput("SmartClock"),
                  textOutput("SmartClockHex"),
                  hr(),
                  h3("If you have a date and if you want to know e-obs Day number and GPS week number:"),
                  dateInput("YourDate", "Choose a date that you want device to wake up on:", value = Sys.Date(), min = Sys.Date()),
                  uiOutput("YourEobsDaynumberUI"),
                  textOutput("YourGPSDaynumber"),
                  textOutput("YourGPSWeeknumber"),
                  textOutput("GPSDayofweek"),
                  textOutput("YourSmartClock"),
                  textOutput("YourSmartClockHex")
           ),
           column(4, 
                  titlePanel("UTC to Local Timezone Converter"),
                  pickerInput("timezone", "Select Timezone:",
                                 choices = c("EST" = "America/New_York", "PST" = "America/Los_Angeles", OlsonNames()),
                                 options = list(`live-search` = TRUE, placeholder = 'Type to search for a timezone'),
                                 selected = "UTC"),
                  DT::DTOutput("timeTable")
           ),
)
)
)

#########################################################

# Server logic #
server <- function(input, output) {
  
  ### Reactive starting values ###
  v <- reactiveValues() # Reactive starting values
  
  #Battery capacity
  v$BatteryCapacity <- 3000
  
  # GPS related
  v$TTFFLR <- 30
  v$hoursLR <- 0
  v$burstsPerHourLR <- 0
  v$burstlengthLR <- 0
  #High-res schedule 1
  v$TTFFHR <- 30
  v$hoursHR <- 24
  v$burstsPerHourHR <- 2
  v$burstlengthHR <- 5
  #High-res schedule 2
  v$TTFFHR2 <- 0
  v$hoursHR2 <- 0
  v$burstsPerHourHR2 <- 0
  v$burstlengthHR2 <- 0
  #Concurrent IMU
  v$imuAcc20Hz.mem <- 0
  v$imuQuatComp20Hz.mem <- 0
  v$imuCurrentConsumption <- 0
  #1 Hz GPS
  v$hours1Hz <- 0
  v$imuAcc20Hz.memGPS1Hz <- 0
  v$imuQuatComp20Hz.memGPS1Hz <- 0
  v$imuCurrentConsumptionGPS1Hz <- 0
  # Accelerometer
  v$ACCSR <- 5
  v$Axes <- 3
  v$AccByteCount <- 900
  v$AccInterval <- 1
  v$ACCDutyCycle <- 0
  # IMU
  v$IMUACCDatasetCount <- 10
  v$IMUQUATCOMPDatasetCount <- 20
  v$IMUInterval <- 1
  v$IMUDutyCycle <- 0
  # Pinger
  v$Pulses <- 60
  v$PingerDutyCycle <- 8
  #Other 'Read-Only' Settings
  v$standbyCurrent = 0.0180
  v$batterySelfDischarge = 0.0100
  v$radioInterval = 20
  v$averageCurrentRadio = 0.0250
  
  # Overal Memory Usage and Battery Life Estimation
  v$MinDwnldTime <- 70 # 64*66/60 
  # The 64 represents the total number of units to be transferred (chunks or segments of the total memory), the 66 is the time it takes to transfer one unit in seconds, and the 60 is converting seconds to minutes.
  
  ###################################################
  
  ### Ensure positive numeric inputs are provided ###
  
  # Battery capacity
  observeEvent(input$BatteryCapacity, {
    i <- InputValidator$new()
    i$add_rule("BatteryCapacity", sv_required(message = "Positive number must be provided"))
    i$add_rule("BatteryCapacity", sv_gte(0))
    i$add_rule("BatteryCapacity", sv_lte(20000))
    i$enable()
    req(i$is_valid())
    v$BatteryCapacity <- input$BatteryCapacity
  }, ignoreNULL=FALSE)
  
  # Low GPS res inputs
  observeEvent(input$TTFFLR, {
    i <- InputValidator$new()
    i$add_rule("TTFFLR", sv_required(message = "Positive number must be provided"))
    i$add_rule("TTFFLR", sv_gte(0))
    i$add_rule("TTFFLR", sv_lte(86400))
    i$enable()
    req(i$is_valid())
    v$TTFFLR <- input$TTFFLR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$hoursLR, {
    i <- InputValidator$new()
    i$add_rule("hoursLR", sv_required(message = "Postive number must be provided"))
    i$add_rule("hoursLR", sv_gte(0))
    i$add_rule("hoursLR", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$hoursLR <- input$hoursLR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstsPerHourLR, {
    i <- InputValidator$new()
    i$add_rule("burstsPerHourLR", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstsPerHourLR", sv_gte(0))
    i$add_rule("burstsPerHourLR", sv_lte(3600))
    i$enable()
    req(i$is_valid())
    v$burstsPerHourLR <- input$burstsPerHourLR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstlengthLR, {
    i <- InputValidator$new()
    i$add_rule("burstlengthLR", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstlengthLR", sv_gte(0))
    i$add_rule("burstlengthLR", sv_lte(360))
    i$enable()
    req(i$is_valid())
    v$burstlengthLR <- input$burstlengthLR
  }, ignoreNULL=FALSE)
  
  # High GPS res inputs
  observeEvent(input$TTFFHR, {
    i <- InputValidator$new()
    i$add_rule("TTFFHR", sv_required(message = "Positive number must be provided"))
    i$add_rule("TTFFHR", sv_gte(0))
    i$add_rule("TTFFHR", sv_lte(86400))
    i$enable()
    req(i$is_valid())
    v$TTFFHR <- input$TTFFHR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$TTFFHR2, {
    # Check if the number of schedules is set to 2
    if(input$numSchedules != 2) {
      return()  # Exit early if not set to 2
    }
    i <- InputValidator$new()
    i$add_rule("TTFFHR2", sv_required(message = "Positive number must be provided"))
    i$add_rule("TTFFHR2", sv_gte(0))
    i$add_rule("TTFFHR2", sv_lte(86400)) 
    i$enable()
    req(i$is_valid())
    v$TTFFHR2 <- input$TTFFHR2
  }, ignoreNULL=FALSE)
  
  observeEvent(input$hoursHR, {
    i <- InputValidator$new()
    i$add_rule("hoursHR", sv_required(message = "Postive number must be provided"))
    i$add_rule("hoursHR", sv_gte(0))
    i$add_rule("hoursHR", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$hoursHR <- input$hoursHR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$hoursHR2, {
    # Check if the number of schedules is set to 2
    if(input$numSchedules != 2) {
      return()  # Exit early if not set to 2
    }
    i <- InputValidator$new()
    i$add_rule("hoursHR2", sv_required(message = "Postive number must be provided"))
    i$add_rule("hoursHR2", sv_gte(0))
    i$add_rule("hoursHR2", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$hoursHR2 <- input$hoursHR2
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstsPerHourHR, {
    i <- InputValidator$new()
    i$add_rule("burstsPerHourHR", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstsPerHourHR", sv_gte(0))
    i$add_rule("burstsPerHourHR", sv_lte(3600))
    i$enable()
    req(i$is_valid())
    v$burstsPerHourHR <- input$burstsPerHourHR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstsPerHourHR2, {
    # Check if the number of schedules is set to 2
    if(input$numSchedules != 2) {
      return()  # Exit early if not set to 2
    }
    i <- InputValidator$new()
    i$add_rule("burstsPerHourHR2", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstsPerHourHR2", sv_gte(0))
    i$add_rule("burstsPerHourHR2", sv_lte(3600))
    i$enable()
    req(i$is_valid())
    v$burstsPerHourHR2 <- input$burstsPerHourHR2
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstlengthHR, {
    i <- InputValidator$new()
    i$add_rule("burstlengthHR", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstlengthHR", sv_gte(0))
    i$add_rule("burstlengthHR", sv_lte(360))
    i$enable()
    req(i$is_valid())
    v$burstlengthHR <- input$burstlengthHR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$burstlengthHR2, {
    # Ensure this code block runs only if two schedules are selected
    if(input$numSchedules != 2) {
      return()  # Exit early if not set to 2
    }
    i <- InputValidator$new()
    i$add_rule("burstlengthHR2", sv_required(message = "Postive number must be provided"))
    i$add_rule("burstlengthHR2", sv_gte(0))
    i$add_rule("burstlengthHR2", sv_lte(360))
    i$enable()
    req(i$is_valid())
    v$burstlengthHR2 <- input$burstlengthHR2
  }, ignoreNULL=FALSE)
  
  # Concurrent IMU Sampling
  observe({
    # Check if any of the radio buttons is 'yes'
    if(input$imuAcc20Hz == "yes" || input$imuQuatComp20Hz == "yes" || input$imuQuatComp1Hz == "yes") {
      v$imuCurrentConsumption <- 4
    } else {
      v$imuCurrentConsumption <- 0
    }
    
    # Update memory consumption based on the radio buttons
    v$imuAcc20Hz.mem <- ifelse(input$imuAcc20Hz == "yes", 107, 0) #Bytes/s
    v$imuQuatComp20Hz.mem <- ifelse(input$imuQuatComp20Hz == "yes", 256, 0) #Bytes/s
  })
  
  # 1 Hz GPS res inputs
  observeEvent(input$hours1Hz, {
    i <- InputValidator$new()
    i$add_rule("hours1Hz", sv_required(message = "Postive number must be provided"))
    i$add_rule("hours1Hz", sv_gte(0))
    i$add_rule("hours1Hz", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$hours1Hz <- input$hours1Hz
  }, ignoreNULL=FALSE)
  
  observe({
    # Check if any of the radio buttons is 'yes'
    if(input$imuAcc20HzGPS1Hz == "yes" || input$imuQuatComp20HzGPS1Hz == "yes" || input$imuQuatComp1HzGPS1Hz == "yes") {
      v$imuCurrentConsumptionGPS1Hz <- 4
    } else {
      v$imuCurrentConsumptionGPS1Hz <- 0
    }
    
    # Update memory consumption based on the radio buttons
    v$imuAcc20Hz.memGPS1Hz <- ifelse(input$imuAcc20HzGPS1Hz == "yes", 107, 0) #Bytes/s
    v$imuQuatComp20Hz.memGPS1Hz <- ifelse(input$imuQuatComp20HzGPS1Hz == "yes", 256, 0) #Bytes/s
  })
  
  # Accelerometer
  observeEvent(input$ACCSR, {
    i <- InputValidator$new()
    i$add_rule("ACCSR", sv_required(message = "Positive number must be provided"))
    i$add_rule("ACCSR", sv_gte(1))
    i$add_rule("ACCSR", sv_lte(33))
    i$enable()
    req(i$is_valid())
    v$ACCSR <- input$ACCSR
  }, ignoreNULL=FALSE)
  
  observeEvent(input$Axes, {
    i <- InputValidator$new()
    i$add_rule("Axes", sv_required(message = "Positive number must be provided"))
    i$add_rule("Axes", sv_gte(1))
    i$add_rule("Axes", sv_lte(3))
    i$enable()
    req(i$is_valid())
    v$Axes <- input$Axes
  }, ignoreNULL=FALSE)
  
  observeEvent(input$AccByteCount, {
    i <- InputValidator$new()
    i$add_rule("AccByteCount", sv_required(message = "Positive number must be provided"))
    i$add_rule("AccByteCount", sv_gte(0))
    i$add_rule("AccByteCount", sv_lte(65535))
    i$enable()
    req(i$is_valid())
    v$AccByteCount <- input$AccByteCount
  }, ignoreNULL=FALSE)
  
  observeEvent(input$AccInterval, {
    i <- InputValidator$new()
    i$add_rule("AccInterval", sv_required(message = "Positive number must be provided"))
    i$add_rule("AccInterval", sv_gte(0))
    i$add_rule("AccInterval", sv_lte(10000))
    i$enable()
    req(i$is_valid())
    v$AccInterval <- input$AccInterval
  }, ignoreNULL=FALSE)
  
  observeEvent(input$ACCDutyCycle, {
    i <- InputValidator$new()
    i$add_rule("ACCDutyCycle", sv_required(message = "Positive number must be provided"))
    i$add_rule("ACCDutyCycle", sv_gte(0))
    i$add_rule("ACCDutyCycle", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$ACCDutyCycle <- input$ACCDutyCycle
  }, ignoreNULL=FALSE)
  
  # Standalone IMU
  observeEvent(input$IMUACCDatasetCount, {
    i <- InputValidator$new()
    i$add_rule("IMUACCDatasetCount", sv_required(message = "Positive number must be provided"))
    i$add_rule("IMUACCDatasetCount", sv_gte(0))
    i$add_rule("IMUACCDatasetCount", sv_lte(100))
    i$enable()
    req(i$is_valid())
    v$IMUACCDatasetCount <- input$IMUACCDatasetCount
  }, ignoreNULL=FALSE)
  
  observeEvent(input$IMUQUATCOMPDatasetCount, {
    i <- InputValidator$new()
    i$add_rule("IMUQUATCOMPDatasetCount", sv_required(message = "Positive number must be provided"))
    i$add_rule("IMUQUATCOMPDatasetCount", sv_gte(0))
    i$add_rule("IMUQUATCOMPDatasetCount", sv_lte(240))
    i$enable()
    req(i$is_valid())
    v$IMUQUATCOMPDatasetCount <- input$IMUQUATCOMPDatasetCount
  }, ignoreNULL=FALSE)
  
  observeEvent(input$IMUInterval, {
    i <- InputValidator$new()
    i$add_rule("IMUInterval", sv_required(message = "Positive number must be provided"))
    i$add_rule("IMUInterval", sv_gte(0))
    i$add_rule("IMUInterval", sv_lte(10000))
    i$enable()
    req(i$is_valid())
    v$IMUInterval <- input$IMUInterval
  }, ignoreNULL=FALSE)
  
  observeEvent(input$IMUDutyCycle, {
    i <- InputValidator$new()
    i$add_rule("IMUDutyCycle", sv_required(message = "Positive number must be provided"))
    i$add_rule("IMUDutyCycle", sv_gte(0))
    i$add_rule("IMUDutyCycle", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$IMUDutyCycle <- input$IMUDutyCycle
  }, ignoreNULL=FALSE)
  
  # Pinger
  observeEvent(input$Pulses, {
    i <- InputValidator$new()
    i$add_rule("Pulses", sv_required(message = "Positive number must be provided"))
    i$add_rule("Pulses", sv_gte(0))
    i$add_rule("Pulses", sv_lte(500))
    i$enable()
    req(i$is_valid())
    v$Pulses <- input$Pulses
  }, ignoreNULL=FALSE)
  
  observeEvent(input$PingerDutyCycle, {
    i <- InputValidator$new()
    i$add_rule("PingerDutyCycle", sv_required(message = "Positive number must be provided"))
    i$add_rule("PingerDutyCycle", sv_gte(0))
    i$add_rule("PingerDutyCycle", sv_lte(24))
    i$enable()
    req(i$is_valid())
    v$PingerDutyCycle <- input$PingerDutyCycle
  }, ignoreNULL=FALSE)
  
  ###################################################
  # Low Res GPS Computations
  
  # Reactive expression for fixes per day LR
  burstsPerMinLR <- reactive({
    if (v$burstsPerHourLR == 0) {
      return(0)
    } else {
      return(60 / v$burstsPerHourLR)
    }
  })
  
  burstsPerDayLR <- reactive({
    v$hoursLR * v$burstsPerHourLR
  })
  
  fixesPerDayLR <- reactive({
    burstsPerDayLR() * v$burstlengthLR
  })
  
  secondsGPSRunningLR <- reactive({
    (v$TTFFLR + v$burstlengthLR) * burstsPerDayLR()
  })
  
  # Use the reactive expression inside renderText
  output$burstsPerMinLR <- renderText({
    paste("Average number of GPS bursts every minute in LOW RES: ", format(round(burstsPerMinLR(), 1), nsmall = 1))
  })
  
  output$burstsPerDayLR <- renderText({
    paste("Average number of GPS bursts per day in LOW RES: ", format(round(burstsPerDayLR(), 0), nsmall = 0))
  })
  
  output$fixesPerDayLR <- renderText({
    paste("Average number of GPS fixes per day in LOW RES: ", format(round(fixesPerDayLR(), 0), nsmall = 0))
  })
  
  output$secondsGPSRunningLR <- renderText({
    # Use the reactive value here
    paste("Average time GPS running in LOW RES (considers TTFF): ", format(round(secondsGPSRunningLR(), 0), nsmall = 0), "s")
  })
  
  ############################################################
  # High Res GPS Computations
  
  output$highResGPS <- renderUI({
    # Dynamically set column width based on number of schedules
    scheduleWidth <- ifelse(input$numSchedules == 1, 12, 5)
  
    # Always render the first schedule's inputs
    schedule1Inputs <- tagList(
      h3("High Res GPS Schedule"),
      numericInput("TTFFHR", "Average Time To First Fix (TTFF) with GPS HIGH RES (s)", value = 30, min = 0),
      numericInput("hoursHR", "Number of Hours with GPS HIGH RES", value = 24, min = 0),
      numericInput("burstsPerHourHR", "Bursts per Hour with GPS HIGH RES", value = 2, min = 0),
      numericInput("burstlengthHR", "Burst length in HIGH RES", value = 5, min = 0),
    )
    # Conditionally render the second schedule's inputs
    schedule2Inputs <- if(input$numSchedules == 2) {
    
      tagList(
        h3("High Res GPS Schedule 2"),
        numericInput("TTFFHR2", "Average Time To First Fix (TTFF) with GPS HIGH RES (s) [2]", value = 0, min = 0),
        numericInput("hoursHR2", "Number of Hours with GPS HIGH RES [2]", value = 0, min = 0),
        numericInput("burstsPerHourHR2", "Bursts per Hour with GPS HIGH RES [2]", value = 0, min = 0),
        numericInput("burstlengthHR2", "Burst length in HIGH RES [2]", value = 0, min = 0),
        # Additional High Res GPS Schedule 2 outputs...
      )
    } else NULL
    # Render both schedules side by side or just the first one, depending on selection
    fluidRow(
      column(scheduleWidth, schedule1Inputs),
      if (!is.null(schedule2Inputs)) column(scheduleWidth, schedule2Inputs)
    )
  })
  
  # Adjusted Reactive expression for fixes per day HR, including the second schedule if selected
  burstsPerMinHR <- reactive({
    if (input$numSchedules == 1) {
      # For one schedule
      list(schedule1 = if (v$burstsPerHourHR == 0) 0 else 60 / v$burstsPerHourHR)
    } else {
      # For two schedules
      list(
        schedule1 = if (v$burstsPerHourHR == 0) 0 else 60 / v$burstsPerHourHR,
        schedule2 = if (v$burstsPerHourHR2 == 0) 0 else 60 / v$burstsPerHourHR2
      )
    }
  })
  
  burstsPerDayHR <- reactive({
    if (input$numSchedules == 1) {
      v$hoursHR * v$burstsPerHourHR
    } else {
      # Sum of both schedules
      (v$hoursHR * v$burstsPerHourHR) + (v$hoursHR2 * v$burstsPerHourHR2)
    }
  })
  
  fixesPerDayHR <- reactive({
    if (input$numSchedules == 1) {
      v$hoursHR * v$burstsPerHourHR * v$burstlengthHR
    } else {
      # Sum of fixes for both schedules
      (v$hoursHR * v$burstsPerHourHR * v$burstlengthHR) + 
        (v$hoursHR2 * v$burstsPerHourHR2 * v$burstlengthHR2)
    }
  })
  
  secondsGPSRunningHR <- reactive({
    if (input$numSchedules == 1) {
      (input$TTFFHR + input$burstlengthHR) * (input$hoursHR * input$burstsPerHourHR)
    } else {
      # Sum of running seconds for both schedules
      ((input$TTFFHR + input$burstlengthHR) * (input$hoursHR * input$burstsPerHourHR)) +
        ((input$TTFFHR2 + input$burstlengthHR2) * (input$hoursHR2 * input$burstsPerHourHR2))
    }
  })
  
  # Use the reactive expression inside renderUI to handle HTML
  output$burstsPerMinHR <- renderUI({
    bursts_data <- burstsPerMinHR()
    if (length(bursts_data) == 1) {
      # Only one schedule
      HTML(paste("<span style='font-size: 11px; font-family: Arial;'>Average number of GPS bursts per minute in HIGH RES SCHEDULE 1: ", 
                 format(round(bursts_data$schedule1, 1), nsmall = 1)))
    } else {
      # Two schedules, use HTML to format output with line breaks
      HTML(paste("<span style='font-size: 11px; font-family: Arial;'>Average number of GPS bursts per minute in HIGH RES SCHEDULE 1: ", 
                 format(round(bursts_data$schedule1, 1), nsmall = 1), 
                 "</span><br><span style='font-size: 11px; font-family: Arial;'>Average number of GPS bursts per minute in HIGH RES SCHEDULE 2: ", 
                 format(round(bursts_data$schedule2, 1), nsmall = 1),
                 sep = ""))
    }
  })
  
  output$burstsPerDayHR <- renderText({
    paste("Average number of GPS bursts per day in HIGH RES: ", format(round(burstsPerDayHR(), 0), nsmall = 0))
  })
  
  output$fixesPerDayHR <- renderText({
    paste("Average number of GPS fixes per day in HIGH RES: ", format(round(fixesPerDayHR(), 0), nsmall = 0))
  })
  
  output$secondsGPSRunningHR <- renderText({
    # Use the reactive value here
    paste("Average time GPS running in HIGH RES (considers TTFF): ", format(round(secondsGPSRunningHR(), 0), nsmall = 0), "s")
  })
  
  ############################################################
  # Concurrent GPS-IMU computations and overall battery and memory for setting so far...
  
  # Reactive expression for Average memory and current consumption based on low- and high-res GPS schedules and concurrent IMU sampling
  AverageMemoryGPS <- reactive({
    (64 * (fixesPerDayLR() + fixesPerDayHR()) + (v$imuAcc20Hz.mem + v$imuQuatComp20Hz.mem) * (fixesPerDayHR() - 1)) / 1024
  })
  
  AverageCurrentConsumptionGPS <- reactive({
    30 * (secondsGPSRunningLR() + secondsGPSRunningHR()) / 86400 + fixesPerDayHR() * v$imuCurrentConsumption / 86400
  })
  
  # Use the reactive expression inside renderText
  output$AverageMemoryGPS <- renderText({
    paste("Average memory consumption GPS: ", format(round(AverageMemoryGPS(), 1), nsmall = 1), "kBytes/Day")
  })
  
  output$AverageCurrentConsumptionGPS <- renderText({
    paste("Average current consumption GPS: ", format(round(AverageCurrentConsumptionGPS(), 4), nsmall = 4), "mA")
  })
  
  
  ############################################################
  # 1 Hz GPS computations and overall battery and memory for these....
  
  fixesPerDay1Hz <- reactive({
    v$hours1Hz * 3600
  })
  
  AverageMemoryGPS1Hz <- reactive({
    (64 * fixesPerDay1Hz() + (v$imuAcc20Hz.memGPS1Hz + v$imuQuatComp20Hz.memGPS1Hz) * fixesPerDay1Hz()) / 1024
  })
  
  AverageCurrentConsumptionGPS1Hz <- reactive({
    30 * fixesPerDay1Hz() / 86400 + fixesPerDay1Hz() * v$imuCurrentConsumptionGPS1Hz / 86400
  })
  
  output$fixesPerDay1Hz <- renderText({
    paste("Average number of GPS fixes per day in 1 Hz mode: ", format(round(fixesPerDay1Hz(), 0), nsmall = 0))
  })
  
  output$AverageMemoryGPS1Hz <- renderText({
    paste("Average memory consumption 1 Hz GPS: ", format(round(AverageMemoryGPS1Hz(), 1), nsmall = 1), "kBytes/Day")
  })
  
  output$AverageCurrentConsumptionGPS1Hz <- renderText({
    paste("Average current consumption 1 Hz GPS: ", format(round(AverageCurrentConsumptionGPS1Hz(), 4), nsmall = 4), "mA")
  })
  
  
  ############################################################
  # Accelerometer computations and overall battery and memory for this....
  
  # Resulting ACC SR (=sample rate) per axis in Hertz
  SampleRatePerAxis <- reactive({
    100 /  v$ACCSR
  })
  
  # Number of Bytes available for samples for one ACC burst
  BytesAvailablePerBurst <- reactive({
    min(max(((v$AccByteCount + 62) %/% 63) * 63 - 9, 0), 1188)
  })
  
  # Consumed on board memory for one ACC burst
  ConsumedMemoryPerBurst <- reactive({
    (BytesAvailablePerBurst() + 9) / 63 * 64
  })
  
  # Sampling duration (s)
  SamplingDuration <- reactive({
    BytesAvailablePerBurst() / (1.5 * SampleRatePerAxis() * v$Axes)
  })
  
  # Average memory+current consumption ACC
  AverageMemoryACC <- reactive({
    if(v$AccInterval == 0){
      return(0)
    } else {
      return(ConsumedMemoryPerBurst() * 1440 / v$AccInterval * v$ACCDutyCycle / 24 / 1024)
    }
  })
  
  AverageCurrentConsumptionACC <- reactive({
    if(v$AccInterval == 0){
      return(0)
    } else {
      return((SamplingDuration() * 1.20 + 0.8) / v$AccInterval / 60 * v$ACCDutyCycle / 24)
    }
  })
  
  output$SampleRatePerAxis <- renderText({
    paste("Resulting sample rate per axis: ", format(round(SampleRatePerAxis(), 2), nsmall = 2), "Hz")
  })
  
  output$BytesAvailablePerBurst <- renderText({
    paste("Number of bytes available per ACC burst: ", format(round(BytesAvailablePerBurst(), 0), nsmall = 0), "Bytes")
  })
  
  output$ConsumedMemoryPerBurst <- renderText({
    paste("Consumed on-board memory per ACC burst: ", format(round(ConsumedMemoryPerBurst(), 0), nsmall = 0), "Bytes")
  })
  
  output$SamplingDuration <- renderText({
    paste("Sampling duration: ", format(round(SamplingDuration(), 1), nsmall = 1), "s")
  })
  
  output$AverageMemoryACC <- renderText({
    paste("Average memory consumption ACC: ", format(round(AverageMemoryACC(), 1), nsmall = 1), "kBytes/Day")
  })
  
  output$AverageCurrentConsumptionACC <- renderText({
    paste("Average current consumption ACC: ", format(round(AverageCurrentConsumptionACC(), 4), nsmall = 4), "mA")
  })
  
  ############################################################
  # IMU standalone computations and overall battery and memory for this....
  
  # Consumed on board memory for one IMU Burst
  ConsumedMemoryPerBurstIMU <- reactive({
    (v$IMUQUATCOMPDatasetCount + v$IMUACCDatasetCount) * 128
  })
  
  SampleDurationIMUACC <- reactive({
    v$IMUACCDatasetCount * 1.20
  })
  
  SampleDurationIMUQUATCOMP <- reactive({
    v$IMUQUATCOMPDatasetCount * 0.50
  })
  
  ResultantSamplingDurationIMU <- reactive({
    max(SampleDurationIMUACC(),  SampleDurationIMUQUATCOMP())
  })
  
  # Average memory+current consumption IMU standalone
  AverageMemoryIMU <- reactive({
    if(v$IMUInterval == 0){
      return(0)
    } else {
      return(ConsumedMemoryPerBurstIMU() * 1440 / v$IMUInterval * v$IMUDutyCycle / 24 / 1024)
    }
  })
  
  AverageCurrentConsumptionIMU <- reactive({
    if(v$IMUInterval == 0){
      return(0)
    } else {
      return(((ResultantSamplingDurationIMU() + 2) * 4) / v$IMUInterval / 60 * v$IMUDutyCycle / 24)
    }
  })
  
  output$ConsumedMemoryPerBurstIMU <- renderText({
    paste("Consumed on-board memory per IMU burst: ", format(round(ConsumedMemoryPerBurstIMU(), 0), nsmall = 0), "Bytes")
  })
  
  output$SampleDurationIMUACC <- renderText({
    paste("Sampling duration for IMU ACC: ", format(round(SampleDurationIMUACC(), 2), nsmall = 2), "s")
  })
  
  output$SampleDurationIMUQUATCOMP <- renderText({
    paste("Sampling duration for IMU QUATERTIONS & Compass: ", format(round(SampleDurationIMUQUATCOMP(), 2), nsmall = 2), "s")
  })
  
  output$ResultantSamplingDurationIMU <- renderText({
    paste("Resulting sampling duration: ", format(round(ResultantSamplingDurationIMU(), 2), nsmall = 2), "s")
  })
  
  output$AverageMemoryIMU <- renderText({
    paste("Average memory consumption IMU standalone: ", format(round(AverageMemoryIMU(), 1), nsmall = 1), "kBytes/Day")
  })
  
  output$AverageCurrentConsumptionIMU <- renderText({
    paste("Average current consumption IMU standalone: ", format(round(AverageCurrentConsumptionIMU(), 4), nsmall = 4), "mA")
  })
  
  ############################################################
  # Pinger computations and overall battery for this....
  
  AverageCurrentConsumptionPinger <- reactive({
    30 * 0.02 * (v$PingerDutyCycle / 24) * (v$Pulses / 60)
  })
  
  output$AverageCurrentConsumptionPinger <- renderText({
    paste("Average current consumption Pinger: ", format(round(AverageCurrentConsumptionPinger(), 4), nsmall = 4), "mA")
  })
  
  #######################################################################################################################
  # Other 'Read-Only' Settings
  output$standbyCurrent <- renderText({ paste("Standby current:", v$standbyCurrent, "mA") })
  output$batterySelfDischarge <- renderText({ paste("Battery self discharge:", v$batterySelfDischarge, "mA") })
  output$radioInterval <- renderText({ paste("Radio Interval:", v$radioInterval, "s") })
  output$averageCurrentRadio <- renderText({ paste("Average current consumption for radio:", v$averageCurrentRadio, "mA") })
  
  averageCurrentDataDownload <- reactive({
    (AverageMemoryGPS() + AverageMemoryGPS1Hz() + AverageMemoryACC() + AverageMemoryIMU()) / 15 * 30 / 86400
  })
  
  output$averageCurrentDataDownload <- renderText({ paste("Average current for data download with basestation:", format(round(averageCurrentDataDownload(), 6), nsmall = 6), "mA") })
  
  #######################################################################################################################
  
  TotalAvgMem <- reactive({
    AverageMemoryGPS() + AverageMemoryGPS1Hz() + AverageMemoryACC() + AverageMemoryIMU() 
  })
  
  TotalAvgCurrCons <- reactive({
    AverageCurrentConsumptionGPS() + AverageCurrentConsumptionGPS1Hz() + AverageCurrentConsumptionACC() + AverageCurrentConsumptionIMU() + AverageCurrentConsumptionPinger() + v$standbyCurrent + v$batterySelfDischarge + v$averageCurrentRadio + averageCurrentDataDownload()
  })
  
  MemFull <- reactive({ 
    64 * 1024 / TotalAvgMem()
  })
  
  BattEmpty <- reactive({
    v$BatteryCapacity / TotalAvgCurrCons() / 24
  })
  
  output$TotalAvgMem <- renderUI({
    tags$div(
      span(class = "summary-text", "Total average memory (basestation download): "),
      span(class = "summary-text-value", format(round(TotalAvgMem(), 2), nsmall = 2), " kBytes/Day")
    )
  })
  
  output$TotalAvgCurrCons <- renderUI({
    tags$div(
      span(class = "summary-text", "Total current consumption (basestation download): "),
      span(class = "summary-text-value", format(round(TotalAvgCurrCons(), 4), nsmall = 4), " mA")
    )
  })
  
  output$MinDwnldTime <- renderUI({
    tags$div(
      span(class = "summary-text", "Minimum download time of full memory with basestation: "),
      span(class = "summary-text-value", format(round(v$MinDwnldTime, 0), nsmall = 0), " mins")
    )
  })
  
  output$MemFull <- renderUI({
    tags$div(
      span(class = "summary-text", "64MB-Memory full after: "),
      span(class = "summary-text-value", format(round(MemFull(), 1), nsmall = 1), " days")
    )
  })
  
  output$BattEmpty <- renderUI({
    tags$div(
      span(class = "summary-text", "Battery empty after (basestation download): "),
      span(class = "summary-text-value", format(round(BattEmpty(), 1), nsmall = 1), " days")
    )
  })
  
  #######################################################################################################################
  
  #########################################################################################################################
  #########################################################################################################################
  #########################################################################################################################
  #########################################################################################################################
  #########################################################################################################################
  #########################################################################################################################
  
  ################# TAB 2 - Delayed start calendar #################
  
  #TODAY
  output$DateToday <- renderText({
    paste('Date Today:', date(now()))
  })
  
  output$EobsDaynumbertoday <- renderText({
    paste('E-obs Day Number Today:', as.numeric(date(now()) - as.Date("2007-03-04")))
  })
  
  output$GPSDaynumbertoday <- renderText({
    paste('GPS Day Number Today:', as.numeric(date(now()) - as.Date("1980-01-06")), "(Days since Sunday 1980-01-06)")
  })
  
  output$GPSWeeknumbertoday <- renderText({
    paste('Your GPS Week Number:', as.integer(as.numeric(date(now()) - as.Date("1980-01-06")) / 7))
  })
  
  output$GPSDayofweektoday <- renderText({
    paste('GPS Day Of Week:', as.numeric(date(now()) - as.Date("1980-01-06")) - (as.integer(as.numeric(date(now()) - as.Date("1980-01-06")) / 7) * 7))
  })
  
  output$SmartClock <- renderText({
    paste('Smart Clock:', as.numeric(date(now()) - as.Date("2007-03-04")) * 86400)
  })
  
  output$SmartClockHex <- renderText({
    paste('Smart Clock Hex:', sprintf("%X", as.numeric(date(now()) - as.Date("2007-03-04")) * 86400))
  })
    
  # If you have a date and if you want to know e-obs Day number and GPS week number
  output$YourEobsDaynumberUI <- renderUI({
    tags$div(style = "font-weight: bold; font-size: 12.5px;",
             'Your Eobs Day Number: ', 
             as.numeric(input$YourDate - as.Date("2007-03-04")), 
             " which is: ", 
             as.numeric(input$YourDate - Sys.Date()), 
             " days from today's date")
  })
  
  output$YourGPSDaynumber <- renderText({
    paste('Your GPS Day Number:', as.numeric(input$YourDate - as.Date("1980-01-06")), "(Days since Sunday 1980-01-06)")
  })
  
  output$YourGPSWeeknumber <- renderText({
    paste('Your GPS Week Number:',  as.integer(as.numeric(input$YourDate - as.Date("1980-01-06")) / 7))
  })
  
  output$GPSDayofweek <- renderText({
    paste('Your GPS Day Of Week:',  as.numeric(input$YourDate - as.Date("1980-01-06")) - (as.integer(as.numeric(input$YourDate - as.Date("1980-01-06")) / 7) * 7))
  })
  
  output$YourSmartClock <- renderText({
    paste('Your Smart Clock:',  as.numeric(input$YourDate - as.Date("2007-03-04")) * 86400)
  })
  
  output$YourSmartClockHex <- renderText({
    paste('Your Smart Clock Hex:',  sprintf("%X", as.numeric(input$YourDate - as.Date("2007-03-04")) * 86400))
  })
  
  #####################################################
  # Time zone table
  output$timeTable <- DT::renderDT({
    # Create a dataframe with UTC hours
    utc_hours <- data.frame(UTC = sprintf("%02d:00", 0:23))
    
    # Convert UTC hours to the selected timezone
    local_hours <- utc_hours %>%
      mutate(Local = format(with_tz(ymd_h("1970-01-01 00", tz = "UTC") + hours(0:23), tzone = input$timezone), "%H:00"))
    
    # Combine and display
    utc_hours$Local <- local_hours$Local
    utc_hours
  })
  
  #####################################################
  
}





#########################################################################################################################
#########################################################################################################################

# Run the application 
shinyApp(ui = ui, server = server)
