## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  eval = FALSE,
  comment = "#>"
)
in_packagedown <- tryCatch({pkgdown::in_pkgdown()}, error = function(e){ FALSE })

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Conceptual workflow for this task."----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/Task2.png?raw=true")

## -----------------------------------------------------------------------------
# worcs::check_git()

## -----------------------------------------------------------------------------
# gert::git_status()

## -----------------------------------------------------------------------------
# worcs::check_github()

## -----------------------------------------------------------------------------
# worcs::check_github()

## ----eval = FALSE-------------------------------------------------------------
# worcs::git_remote_create("repository_name", private = FALSE)

## ----eval = FALSE-------------------------------------------------------------
# worcs::git_remote_connect(project_path, remote_repo = "repository_name")

## -----------------------------------------------------------------------------
# renv::snapshot()

## -----------------------------------------------------------------------------
# worcs::git_update("Preparing to archive my project")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Sign up for 'Zenodo'"----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/zenodo.png?raw=true")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Authorize  to connect with 'GitHub'"----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/_github.png?raw=true")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Enable individual 'GitHub' repositories to be archived in 'Zenodo'"----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/enabled_repos.png?raw=true")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Check that webhooks are enabled for your 'GitHub' repository."----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/webhooks.png?raw=true")

## ----eval = FALSE-------------------------------------------------------------
# worcs::git_release_publish()

## ----eval = FALSE-------------------------------------------------------------
# worcs::git_release_publish(repo = ".",
#                            tag_name = "0.2.0",
#                            release_name = "0.2.0")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Check the new release has been uploaded."----
knitr::include_graphics("https://github.com/OpenScienceMOOC/Module-5-Open-Research-Software-and-Open-Source/blob/master/content_development/images/upload_release.png?raw=true")

## ----include = in_packagedown, eval = TRUE, echo = FALSE, fig.align='center', out.width = "70%", fig.cap="Click the orange Edit button."----
knitr::include_graphics("https://github.com/cjvanlissa/theorytools/blob/master/docs/images/zenodo_edit.png?raw=true")

