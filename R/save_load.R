#' @title Use open data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
#' and amends the \code{.gitignore} file to exclude \code{filename}.
#' @param data A data.frame to save.
#' @param filename Character, naming the file data should be written to. By
#' default, constructs a filename from the name of the object passed to
#' \code{data}.
#' @param codebook Character, naming the file the codebook should be written to.
#' An 'R Markdown' codebook will be created and rendered to
#' \code{\link[rmarkdown]{github_document}} ('markdown' for 'GitHub').
#' By default, constructs a filename from the name of the object passed to
#' \code{data}, adding the word 'codebook'.
#' Set this argument to \code{NULL} to avoid creating a codebook.
#' @param worcs_directory Character, indicating the WORCS project directory to
#' which to save data. The default value \code{"."} points to the current
#' directory.
#' @param ... Additional arguments passed to and from functions.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' test_dir <- file.path(tempdir(), "data")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' df <- iris[1:5, ]
#' open_data(df, codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname open_data
open_data <- function(data,
                      filename = paste0(deparse(substitute(data)), ".csv"),
                      codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                      worcs_directory = ".",
                      ...){
  Args <- all_args()
  Args$open <- TRUE
  do.call(save_data, Args)
}

#' @title Use closed data in WORCS project
#' @description This function saves a data.frame as a \code{.csv} file (using
#' \code{\link[utils:write.table]{write.csv}}), stores a checksum in '.worcs',
#' appends the \code{.gitignore} file to exclude \code{filename}, and saves a
#' synthetic copy of \code{data} for public use. To generate these synthetic
#' data, the function \code{\link{synthetic}} is used.
#' @inheritParams open_data
#' @param synthetic Logical, indicating whether or not to create a synthetic
#' dataset using the \code{\link{synthetic}} function. Additional arguments for
#' the call to \code{\link{synthetic}} can be passed through \code{...}.
#' @return Returns \code{NULL} invisibly. This
#' function is called for its side effects.
#' @examples
#' old_wd <- getwd()
#' test_dir <- file.path(tempdir(), "data")
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' df <- iris[1:3, ]
#' closed_data(df, codebook = NULL)
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @seealso open_data closed_data save_data
#' @export
#' @rdname closed_data
closed_data <- function(data,
                        filename = paste0(deparse(substitute(data)), ".csv"),
                        codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                        worcs_directory = ".",
                        synthetic = TRUE,
                        ...){
  Args <- match.call()
  #browser()
  Args$open <- FALSE
  Args[[1L]] <- str2lang("worcs:::save_data")
  eval(Args, parent.frame())
}

#' @importFrom digest digest
#' @importFrom utils write.csv
save_data <- function(data,
                      filename = paste0(deparse(substitute(data)), ".csv"),
                      open,
                      codebook = paste0("codebook_", deparse(substitute(data)), ".Rmd"),
                      worcs_directory = ".",
                      verbose = TRUE,
                      synthetic = TRUE,
                      ...){
  if(grepl("[", filename, fixed = TRUE) | grepl("$", filename, fixed = TRUE)){
    stop("This filename is not allowed: ", filename, ". Please specify a legal filename.", call. = FALSE)
  }
  cl <- as.list(match.call()[-1])
  create_codebook <- !is.null(codebook)
  if(create_codebook){
    if(grepl("[", codebook, fixed = TRUE) | grepl("$", codebook, fixed = TRUE)){
    stop("This codebook filename is not allowed: ", codebook, ". Please specify a legal filename.", call. = FALSE)
    }
    fn_code <- basename(codebook)
    dn_code <- dirname(codebook)
    fn_write_codebook <- file.path(dn_code, fn_code)
  }
  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  fn_worcs <- file.path(dn_worcs, ".worcs")
  fn_gitig <- file.path(dn_worcs, ".gitignore")
  fn_original <- basename(filename)
  dn_original <- dirname(filename)
  fn_synthetic <- paste0("synthetic_", fn_original)

  if(!dn_original == "."){
    fn_synthetic <- file.path(dn_original, fn_synthetic)
  }

  fn_write_original <- file.path(dn_original, fn_original)
  fn_write_synth <- file.path(dn_original, fn_synthetic)

  # End filenames

  # Remove this when worcs can handle different types:
  if(!inherits(data, c("data.frame", "matrix"))){
    stop("Argument 'data' must be a data.frame, matrix, or inherit from these classes.")
  }
  # End remove

  # Insert three checks:
  # 1) write_func works with data object
  # 2) read_func works with data object
  # 3) result of read_func is identical to data object

# Store data --------------------------------------------------------------

  col_message("Storing original data in '", filename, "' and updating the checksum in '.worcs'.", verbose = verbose)
  write.csv(data, fn_write_original, row.names = FALSE)

  # Prepare for writing to worcs file
  to_worcs <- list(
    filename = fn_worcs,
    modify = TRUE
  )
  to_worcs$data[[filename]] <- vector(mode = "list")
  do.call(write_worcsfile, to_worcs)
  store_checksum(fn_write_original, entry_name = filename)

  if(open){
    write_gitig(fn_gitig, paste0("!", basename(fn_original)))
  } else {
    write_gitig(fn_gitig, basename(fn_original))
    # Update readme file with message about closed data
    update_textfile(file.path(dn_worcs, "README.md"),
                    "\n\n## Access to data\n\nSome of the data used in this project are not publically available.\nTo request access to the original data, [open a GitHub issue](https://docs.github.com/en/free-pro-team@latest/github/managing-your-work-on-github/creating-an-issue).\n\n<!--Clarify here how users should contact you to gain access to the data, or to submit syntax for evaluation on the original data.-->",
                    verbose = verbose)
    if(synthetic){
      # Synthetic data
      col_message("Generating synthetic data for public use. Ensure that no identifying information is included.", verbose = verbose)
      Args <- match.call()
      Args <- Args[c(1, which(names(Args) %in% names(formals("synthetic"))))]
      Args$verbose <- verbose
      Args[[1L]] <- quote(worcs::synthetic)
      synth <- eval.parent(Args)
      add_synthetic(data = synth,
                    synthetic_name = fn_synthetic,
                    original_name = filename,
                    worcs_directory = dn_worcs,
                    verbose = verbose)
    }
  }
  col_message("Updating '.gitignore'.", verbose = verbose)

# codebook ----------------------------------------------------------------
  if(create_codebook){
    Args_cb <- cl["data"]
    Args_cb$filename <- fn_write_codebook
    cb_out <- capture.output(do.call(make_codebook, Args_cb))
    # Add to gitignore
    write_gitig(filename = fn_gitig, paste0("!", gsub(".md$", "csv", basename(fn_write_codebook))))
    # Add to worcs
    to_worcs <- list(filename = fn_worcs,
                     "data" = list(list("codebook" = codebook)),
                     modify = TRUE)

    names(to_worcs[["data"]])[1] <- filename
    #to_worcs$data[[filename]]$codebook <- codebook
    do.call(write_worcsfile, to_worcs)

  }
  invisible(NULL)
}

#' @title Load WORCS project data
#' @description Scans the WORCS project file for data that have been saved using
#' \code{\link{open_data}} or \code{\link{closed_data}}, and loads these data
#' into the global (working) environment. The function will load the original
#' data if available on the current system. If only a synthetic dataset is
#' available, this function loads the synthetic data.
#' The name of the object containing the data is derived from the file name by
#' removing the file extension, and, when applicable, the prefix
#' \code{"synthetic_"}. Thus, both \code{"data.csv"} and
#' \code{"synthetic_data.csv"} will be loaded into an object called \code{data}.
#' @param worcs_directory Character, indicating the WORCS project directory from
#' which to load data. The default value \code{"."} points to the current
#' directory.
#' @param to_envir Logical, indicating whether to load objects directly into
#' the environment, or return a \code{\link{list}} containing the objects. The
#' environment is designated by argument \code{envir}. Loading
#' objects directly into the global environment is user-friendly, but has the
#' risk of overwriting an existing object with the same name, as explained in
#' \code{\link{load}}. The function \code{load_data} gives a warning when this
#' happens.
#' @param envir The environment where the data should be loaded. The default
#' value \code{parent.frame(1)} refers to the global environment in an
#' interactive session.
#' @param verbose Logical. Whether or not to print status messages to
#' the console. Default: TRUE
#' @return Returns a list invisibly. If \code{to_envir = TRUE}, this list
#' contains the loaded data files. If \code{to_envir = FALSE}, the list is
#' empty, and the loaded data files are attached directly to the global
#' environment.
#' @examples
#' test_dir <- file.path(tempdir(), "loaddata")
#' old_wd <- getwd()
#' dir.create(test_dir)
#' setwd(test_dir)
#' worcs:::write_worcsfile(".worcs")
#' df <- iris[1:5, ]
#' suppressWarnings(closed_data(df, codebook = NULL))
#' load_data()
#' data
#' rm("data")
#' file.remove("data.csv")
#' load_data()
#' data
#' setwd(old_wd)
#' unlink(test_dir, recursive = TRUE)
#' @rdname load_data
#' @export
#' @importFrom digest digest
#' @importFrom utils read.csv
#' @importFrom yaml read_yaml
load_data <- function(worcs_directory = ".", to_envir = TRUE, envir = parent.frame(1),
                      verbose = TRUE){
  #browser()
  # When users work from Rmd in a subdirectory, the working directory will be
  # set to that subdirectory. Check for .worcs file recursively, and change
  # directory if necessary.

  # Filenames housekeeping
  dn_worcs <- dirname(check_recursive(file.path(normalizePath(worcs_directory), ".worcs")))
  checkworcs(dn_worcs, iserror = TRUE)

  fn_worcs <- file.path(dn_worcs, ".worcs")
  # End filenames

  worcsfile <- read_yaml(fn_worcs)
  if(is.null(worcsfile[["data"]])){
    stop("No data found in '.worcs'.")
  }
  data <- worcsfile$data
  data_files <- names(data)
  names(data_files) <- data_files
  fn_data_files <- file.path(dn_worcs, data_files)
  data_original <- sapply(fn_data_files, function(i){file.exists(i)})
  data_files_synth <- rep(NA, length(data_files))
  if(any(!data_original)){
     for(i in data_files[!data_original]){
       if(is.null(worcsfile$data[[i]][["synthetic"]])){
         col_message("Cannot find the original data ", i, ", and there is no synthetic version on record.", success = FALSE, verbose = verbose)
       } else {
         data_files_synth <- worcsfile$data[[i]][["synthetic"]]
       }
      }

     data_files[!data_original] <- data_files_synth
     fn_data_files[!data_original] <- file.path(dn_worcs, data_files_synth)
  }
  if(anyNA(data_files)){
    col_message("No valid resource found for these files:", paste0("\n  * ", names(data_files)[is.na(data_files)]), success = FALSE, verbose = verbose)
  }
  data_files <- data_files[!(is.null(data_files)|is.na(data_files))]

  data_original <- data_original[!(is.null(data_files)|is.na(data_files))]
  if(length(data_files) == 0) stop("No valid data files found.")
  outlist <- vector(mode = "list")
  for(file_num in seq_along(data_files)){
    fn_this_file <- fn_data_files[file_num]
    data_name_this_file <- data_files[file_num]
    check_sum(fn_this_file, worcsfile$checksums[[data_name_this_file]])
    col_message("Loading ", c("synthetic", "original")[data_original[file_num]+1], " data from '", data_name_this_file, "'.", verbose = verbose)
    object_name <- sub('^(synthetic_)?(.+)\\..*$', '\\2', basename(data_name_this_file))
    # Replace this with flexible load function from .worcs file
    out <- read.csv(fn_this_file, stringsAsFactors = TRUE)
    attr(out, "type") <- c("synthetic", "original")[data_original[file_num]+1]
    class(out) <- c("worcs_data", class(out))
    if(to_envir){
      if(object_name %in% objects(envir = envir)) warning("Object '", object_name, "' already exists in the environment designated by 'envir', and will be replaced with the contents of '", data_name_this_file, "'.")
      assign(object_name, out, envir = envir)
    } else {
      outlist[[object_name]] <- out
    }
  }
  return(invisible(outlist))
}

#' @importFrom digest digest
store_checksum <- function(filename, entry_name = filename, worcsfile = ".worcs") {
  # Compute checksum on loaded data to ensure conformity
  cs <- digest(object = filename, file = TRUE)
  checkworcs(dirname(filename), iserror = FALSE)
  checksums <- list(cs)
  names(checksums) <- entry_name
  do.call(write_worcsfile,
          list(filename = worcsfile,
               checksums = checksums,
               modify = TRUE)
          )
}

checksum_data_as_csv <- function(object){
  filename <- tempfile(fileext = ".csv")
  write.csv(object, filename, row.names = FALSE)
  return(digest(object = filename, file = TRUE))
}

load_checksum <- function(filename){
  if(file.exists(".worcs")){
    cs_file <- read_yaml(".worcs")
    if(!is.null(cs_file[["checksums"]])){
      if(!is.null(cs_file[["checksums"]][[filename]])){
        return(cs_file[["checksums"]][[filename]])
      }
    }
    stop("No checksum found for file '", filename, "'.")
  } else {
    stop("No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory.")
  }
}

#' @importFrom digest digest
check_sum <- function(filename, old_cs = NULL){
  cs <- digest(object = filename, file = TRUE)
  if(is.null(old_cs)){
    old_cs <- load_checksum(filename = filename)
  }
  if(!cs == old_cs){
    stop("Checksum for file '", filename, "' did not match the checksum on record (in '.worcs'). This means that the file has changed since the checksum was stored.")
  }
}


#' @importFrom utils head
#' @export
print.worcs_data <- function(x, ...){
  if(!is.null(attr(x, "type"))){
    if(attr(x, "type") == "synthetic"){
      cat("This is a synthetic data set. The first 6 rows are:\n\n")
    }
    if(attr(x, "type") == "original"){
      cat("This is the original data set. The first 6 rows are:\n\n")
    }
    class(x) <- class(x)[-1]
  }
  print(head(x))
}

checkworcs <- function(worcs_directory, iserror = FALSE){
  if (!file.exists(file.path(worcs_directory, ".worcs"))) {
    if(iserror){
      stop(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory."
      , call. = FALSE)
    } else {
      col_message(
        "No '.worcs' file found; either this is not a worcs project, or the working directory is not set to the project directory. Writing .worcs file now."
      , success = FALSE)
      file.create(file.path(worcs_directory, ".worcs"))
      return(FALSE)
    }
  }
  return(TRUE)
}

check_recursive <- function(path){
  tryCatch({ normalizePath(path) },
           warning = function(e){
             filename <- basename(path)
             cur_dir <- dirname(path)
             parent_dir <- dirname(dirname(path))
             doesnt_exist <- any(grepl("No such file or directory", e$message))
             if(cur_dir == parent_dir){
               stop("No '.worcs' file found in this directory or any of its parent directories; either this is not a worcs project, or the working directory is not set to the project directory.", call. = FALSE)
             } else if(doesnt_exist) {
               stop("No '.worcs' file found, because the directory '", dirname(path), "' doesn't exists.", call. = FALSE)
             }
             check_recursive(file.path(parent_dir, filename))
           })
}

write_gitig <- function(filename, ..., modify = TRUE){
  new_contents <- unlist(list(...))
  if(modify & file.exists(filename)){
    old_contents <- readLines(filename, encoding = "UTF-8")
    rep_these <- sapply(gsub("^!", "", new_contents), match, gsub("^!", "", old_contents))
    old_contents[na.omit(rep_these)] <- new_contents[!is.na(rep_these)]
    new_contents <- c(old_contents, new_contents[is.na(rep_these)])

  }
  write(new_contents, filename, append = FALSE)
}

#' @title Notify the user when synthetic data are being used
#' @description This function prints a notification message when some or all of
#' the data used in a project are synthetic (see \code{\link{closed_data}} and
#' \code{\link{synthetic}}). See details for important information.
#' @details The preferred way to use this function is to provide specific data
#' objects in the function call, using the \code{...} argument.
#' If no such objects are provided, \code{notify_synthetic} will scan the
#' parent environment for objects of class \code{worcs_data}.
#'
#' This function is emphatically designed to be included in an 'R Markdown'
#' file, to dynamically generate a notification message when a third party
#' 'Knits' such a document without having access to all original data.
#' @param ... Objects of class \code{worcs_data}. The function will check if
#' these are original or synthetic data.
#' @param msg Expression containing the message to print in case not all
#' \code{worcs_data} are original. This message may refer to \code{is_synth},
#' a logical vector indicating which \code{worcs_data} objects are synthetic.
#' @return No return value. This function is called for its side effect of
#' printing a notification message.
#' @examples
#' df <- iris
#' class(df) <- c("worcs_data", class(df))
#' attr(df, "type") <- "synthetic"
#' notify_synthetic(df, msg = "synthetic")
#' @rdname notify_synthetic
#' @export
#' @seealso closed_data synthetic add_synthetic
notify_synthetic <- function(...,
                             msg = NULL){
  dots <- list(...)
  cl <- as.list(match.call()[-1])
  if(is.null(cl[["msg"]])){
    msg <- quote(c("**Note that", ifelse(all(is_synth), "all", "some"), "of the data files used to generate this document are synthetic. The original data are not available. Synthetic data can be used to evaluate the reproducibility of the analysis code, but the results should not be substantively interpreted, and will likely deviate from the results generated using the original data. Please contact the authors for more information.**"))
  }
  msg <- substitute(msg)
  if(length(dots) > 0){
    if(!all(sapply(dots, inherits, what = "worcs_data"))){
      stop("Some arguments provided to 'notify_synthetic()' are not objects of class 'worcs_data'.", call. = FALSE)
    }
    is_synth <- sapply(dots, attr, which = "type") == "synthetic"
  } else {
    worcs_data <- Filter(function(x) inherits(get(x), "worcs_data"), ls(name = parent.env(environment())))
    is_synth <- sapply(worcs_data, function(x){ attr(get(x), which = "type") }) == "synthetic"
  }
  if(any(is_synth)){
    cat(eval(msg))
  }
}

