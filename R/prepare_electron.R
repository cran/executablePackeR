#' @importFrom cli cli_alert_success
prepare_electron <- function(app_name = "myapp", option) {
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  setwd(tempdir())

  system2("npx", args = c("create-electron-app", app_name))
  cli_alert_success("npx Complete")
  unlink(paste0(app_name, "/src"), recursive = TRUE)
  copy_from_inst_to_app(
    files_and_folders = c("src", "start-shiny.R"),
    subdirectory = app_name,
    app_name = app_name
  )
  cli_alert_success("Copying(copy_from_inst) complete")

  # Shiny폴더를 electron 앱 폴더 밑으로 옮김
  # Check if the source folder exists
  shiny_folder <- file.path(tempdir(), "shiny") # Replace with the actual path to the shiny folder
  myapp_folder <- file.path(tempdir(), app_name) # Replace with the actual path to the myapp folder
  destination_path <- file.path(myapp_folder, "shiny")
  if (!dir.exists(shiny_folder)) {
    stop("The source folder (shiny) does not exist.")
  }

  # Check if the destination folder exists
  if (!dir.exists(myapp_folder)) {
    stop("The destination folder (myapp) does not exist.")
  }

  success <- file.rename(shiny_folder, destination_path)
  if (!success) {
    stop("Failed to move the folder.")
  }

  os <- detect_system()
  if (os["os"] == "macOS") {
    get_r_mac(app_name = app_name, options = options)
  } else if (os["os"] == "Windows") {
    get_r_windows(app_name = app_name, options = options)
  }
  cli_alert_success("Installing R Complete")
  add_cran_binary_pkgs(app_name = app_name)
  cli_alert_success("Installing CRAN binary packages Complete")
}
