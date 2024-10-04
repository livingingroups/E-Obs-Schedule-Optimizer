
# E-Obs Schedule Optimizer

## Overview

The **E-Obs Schedule Optimizer** is an R Shiny application designed to assist researchers in configuring the GPS and IMU schedules of E-Obs telemetry devices. It also provides tools to estimate battery life, memory consumption, and set delayed start times based on user-input settings. Additionally, the app includes timezone conversion from UTC to facilitate device deployment planning across different regions.

Please see the accompanying PDF helper sheet for a complete guide to all E-Obs input settings.

## Features

- **Battery Life Estimator**: Predict battery life based on user-defined GPS/IMU/Pinger schedule configurations.
- **Memory Usage Estimator**: Estimate memory consumption based on user-defined GPS/IMU/Pinger schedule configurations.
- **Delayed Start Calendar**: Set a future delayed start time for the device.
- **Timezone Converter**: Provides a UTC to 'local time zone' converter.

## Installation

To run this application, you need to have **R** installed on your computer. The app also requires several R packages, which will be installed automatically if they are not present.

### Required Libraries

The following R packages are used in the app:
- **shiny**: Provides the web application framework.
- **lubridate**: Simplifies working with dates and times.
- **shinyvalidate**: Adds validation checks for user inputs.
- **dplyr**: Provides tools for data manipulation.
- **shinyWidgets**: Adds custom user interface components.
- **htmltools**: Enhances UI rendering in Shiny.

### Automatic Package Installation

The app will automatically install any missing packages upon startup. If a required package is not installed, the script will install it before proceeding. You can review the package installation section in the code:

```r
# Required packages
if (!require('shiny')) { install.packages('shiny', dependencies = TRUE, type="source") }
suppressMessages(require("shiny"))
if (!require('lubridate')) { install.packages('lubridate', dependencies = TRUE, type="source") }
suppressMessages(require("lubridate"))
# (and so on for other packages...)
```

## How to Run the App

1. **Clone or Download the Repository**: 
   - Clone the repository to your local machine using Git.

2. **Open RStudio**:
   - Navigate to the directory containing `E-Obs-Schedule-Optimizer.R`.
   - Open `E-Obs-Schedule-Optimizer.R` in RStudio.

3. **Run the App**:
   - In RStudio, click the "Run App" button or run the following command:
     ```r
     shiny::runApp("E-Obs-Schedule-Optimizer.R")
     ```
   - This will launch the app in your web browser.

4. **Run Directly from GitHub**:
   - You can run the app directly from GitHub by using the following command in R:
     ```r
     shiny::runGitHub("E-Obs-Schedule-Optimizer", "your-github-username")
     ```

## Using the App

### 1. Configure GPS/IMU Settings
- Input desired GPS and IMU schedules to estimate how they will impact device battery and memory.

### 2. Delayed Start Feature
- Select a future start date from the calendar to delay the beginning of data collection. This will provide an 'Eobs Day Number' (see the accompanying PDF helper sheet).

### 3. Timezone Converter
- Convert UTC times to your desired local time zone to ensure consistency in deployment planning.

## Notes

- Make sure your system has a working internet connection to install the required packages during the first run.
- The app provides estimates for battery and memory consumption. Actual values may vary depending on device conditions.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Contact

For questions or suggestions, feel free to contact me at [rgunner@ab.mpg.de].
