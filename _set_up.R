##########################
## Paths to directories ##
##########################
# Check for OS
sys_path <- ifelse(Sys.info()["sysname"]=="Windows", "G:/","/Volumes/GoogleDrive/")
# Path to this project's folder
project_path <- paste0(sys_path,"Shared drives/emlab/projects/current-projects/mex-fisheries")
# Set it as an environmental variable
Sys.setenv(PROJECT_PATH = "/Volumes/GoogleDrive/Shared\ drives/emlab/projects/current-projects/mex-fisheries")

system("SET PROJECT_PATH")

# Reset theme
ggplot2::theme_set(startR::ggtheme_plot())

ggplot2::theme_update(
  axis.title.y = ggplot2::element_text(hjust = 1),
  axis.title.x = ggplot2::element_text(hjust = 1),
  axis.text.y = ggplot2::element_text(size = 12),
  axis.text.x = ggplot2::element_text(size = 12)
)


# Turn off dplyr's anoying messages
options(dplyr.summarise.inform = FALSE)
