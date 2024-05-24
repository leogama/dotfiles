## Utilities ##

as_factor <- function(df, column) {
    if (missing(column)) column <- select_column(df)
    x <- as.factor(df[[column]])
    n <- length(levels(x))

    cat("> Values:", levels(x), "> Insert new labels (press Enter to skip):", sep="\n")
    new_labels <- scan(what=character(), n=n, nlines=1, quiet=TRUE)
    if (length(new_labels)) x <- factor(x, labels=new_labels)

    cat("> Insert new level order (press Enter to skip):\n")
    new_order <- scan(what=integer(), n=n, nlines=1, quiet=TRUE)
    if (length(new_order)) x <- factor(x, levels=levels(x)[new_order])
    
    x
}

# Convert excel alphabetical indexes to numeric.
EXCEL_COLS <- expand.grid(LETTERS, c('', LETTERS))
EXCEL_COLS <- stats::setNames(1L:(26L*27L), paste0(EXCEL_COLS[[2]], EXCEL_COLS[[1]]))

excel_cols <- function(...) {
    args <- toupper(as.character(list(...)))
    if (length(args) == 1) {
        # Accept indexes as a comma separated list in a character string.
        args <- strsplit(trimws(args), '[[:space:]]*,[[:space:]]*')[[1]]
    }
    valid <- grepl('^[A-Z]{1,2}(:[A-Z]{1,2})?$', args)
    if (!all(valid)) stop("Invalid column index or range:  ", paste(args[!valid], collapse=", "))

    cols <- integer()
    for (col_index in strsplit(args, ':')) {
        if (length(col_index) == 1) {
            cols <- c(cols, EXCEL_COLS[col_index[[1]]])
        } else {
            # Preserve columns' alphabetical indexes in names.
            range_begin <- EXCEL_COLS[col_index[[1]]]
            range_end <- EXCEL_COLS[col_index[[2]]]
            cols <- c(cols, EXCEL_COLS[range_begin:range_end])
        }
    }
    return(cols)
}

select_column <- function(df, prompt="Select a column number:", stdin='') {
    table_summary(df)
    cat(prompt, '')
    n <- scan(stdin, integer(), n=1L, quiet=TRUE)
    colnames(df)[n]
}

splits <- function(s) {
    strsplit(s, '(,|\\s)\\s*')[[1]]
}

table_summary <- function(df) {
    number <- sprintf(paste0('%', nchar(length(df)), 'd'), seq_along(df))
    name <- colnames(df)
    value <- sapply(lapply(head(df, n=1000), unique), paste, collapse=', ')
    cat(strtrim(paste0(number, ') ', name, ' => ', value), .term_size()$columns), sep='\n')
}

retry <- function(expr, times=5L) {
    n <- 0L
    wrapper <- function(...) {
        n <<- n + 1L
        if (n < times)
            tryCatch(expr, error=wrapper)
        else
            expr
    }
    suppressWarnings(wrapper())
}

# Test if 'command' is an executable in PATH
is_command <- function(command) {
    return(system(sprintf('command -v %s', command), ignore.stdout=TRUE) == 0)
}

# Write a table with nice defaults.
if ('package:data.table' %in% search() && 'fwrite' %in% ls('package:data.table')) {
    fwrite <- function(x, file=sprintf('%s.tsv', deparse(substitute(x))), sep='\t', ...) {
        data.table::fwrite(as.data.frame(x), file, sep=sep, ...)
    }
} else {
    fwrite <- function(df, file=sprintf('%s.tsv', deparse(substitute(df))), ...) {
        write.table(df, file, na='', quote=FALSE, row.names=FALSE, sep='\t', ...)
    }
}

#write.csv <- function(df, filename, ...) {
#  outfile <- file(filename, 'w', encoding='UTF-8')
#  utils::write.csv(df, outfile, row.names=FALSE, ...)
#  close(outfile)
#}

## Overwrite base functions ##

# Parallelized version of save
#save <- function(...,
#                 file=stop("'file' must be specified"),
#                 envir=.GlobalEnv,
#                 compress='gzip',
#                 compression_level=6,  # pixz uses a single core with level 9...
#                 ncpus=getOption('Ncpus')) {
#    cmd <- switch(compress, gzip='pigz', xz='pixz')
#    if (!is.null(cmd) && is_command(cmd)) {
#        con <- pipe(sprintf('%s -%s -p %s > %s', cmd, compression_level, ncpus, file), 'wb')
#        base::save(..., file=con, envir=envir)
#        close(con)
#    } else {
#        base::save(..., file=file, envir=envir, compress=compress, compression_level=compression_level)
#    }
#}

## Inspection ##

# List column names in numered format.
nm <- function(x) cat(sprintf('%2d: %s', seq_along(x), colnames(x)), sep='\n')

# Show the first n rows and first n columns of a data frame or matrix.
tip <- function(x, rows=5, cols=rows) {
    cols <- min(cols, ncol(x))
    rows <- min(rows, nrow(x))
    cl <- class(x)
    switch(cl[length(cl)],
        data.frame = `[.data.frame`(x, 1:rows, 1:cols),
        matrix = x[1:rows, 1:cols],
        head(x, rows)
    )
}

# Provides a way to open a data frame in a spreadsheet application.
look <- function(df, n=99, sleep=5) {
    name <- deparse(substitute(df))
    if (n > 0 && n < nrow(df)) df <- df[1:n, ]
    fname <- paste0('/tmp/', name, '.csv')
    write.csv(df, fname)

    #NOTE: alternative os info source: Sys.info()['sysname']
    open_cmd <- if (grepl('linux', R.version$os)) 'xdg-open' else 'open'
    system2(open_cmd, shQuote(fname), stderr=NULL)

    # give the application time to open it before destroying file
    Sys.sleep(sleep)
    invisible(file.remove(fname))
}

view <- function(fun) invisible(edit(fun, editor='view'))

## Listing ##

# List objects and classes.
lsa <- function() {
    obj_type <- function(x) class(get(x, envir = .GlobalEnv))[1]
    objs <- sapply(ls(envir = .GlobalEnv), obj_type)
    print.simple.list(setNames(names(objs)[order(objs)], sort(objs)))
}

# List all functions in a package.
lsp <- function(package='UtilFunctions', pattern, invert=FALSE, all.names=FALSE, ...) {
    if (!missing(package))
        package <- paste0('package:', deparse(substitute(package)))
    funs <- ls(package, all.names=all.names)
    if (!missing(pattern))
        funs <- grep(pattern, funs, invert=invert, value=TRUE, ...)
    print(funs, quote=FALSE)
}

#TODO: List signatures for a method.

#TODO: List methods for a class.

#TODO: Get source of a function/method.

#TODO: List arguments of a method.

#TODO: List big objects in workspace. (use data.table functions?)
mem <- function() {
    objs <- ls(.GlobalEnv)
    objs <- setNames(lapply(lapply(objs, get), object.size), objs)
    objs <- objs[order(as.numeric(objs), decreasing=T)]
    for (i in seq_along(objs)) if (as.numeric(objs[i]) > 1048576) {
        cat(names(objs)[i], '\t')
        print(objs[[i]], units='Mb')
    }
}

## Miscelaneous ##

# Clear console function
cl <- function() cat(rep('\n', .term_size()$lines, sep=''))

# Show text in less with word wrap
less <- function(x) {
    input <- paste(names(x), x, sep=if (length(names(x))) '\n\n' else '', collapse='\n\n')
    system(sprintf('fold -sw %d | less', .term_size()$columns), input=input)
}

# Open Finder to the current directory on Mac.
o <- function() if (Sys.info()[1] == 'Darwin') system2('open', '.')

# Read data on clipboard.
read_cb <- function(...) {
    ismac <- Sys.info()[1] == 'Darwin'
    if (!ismac) read.table(file='clipboard', ...)
    else read.table(pipe('pbpaste'), ...)
}

# Set help viewer to browser/html or pager/text
help_toggle <- function() {
    type <- switch(getOption('help_type'), html='text', text='html')
    options(help_type=type)
    cat('Help type:', type, '\n')
}

# Fix DISPLAY environment variable when in tmux.
x11_update <- function() Sys.setenv(DISPLAY=scan('~/.display', what=character(), n=1, quiet=TRUE))

## Packages ##

# Change default parameter
biocLite <- function(pkgs) BiocInstaller::biocLite(pkgs, suppressUpdates=TRUE)

# List loaded packages
loaded <- function() {
    df <- devtools::loaded_packages()
    pkgs <- df$path
    names(pkgs) <- df$package
    print.simple.list(pkgs[order(pkgs)])
}

package_descriptions <- function() {
    description <- sprintf('%s/web/packages/packages.rds', getOption('repos')['CRAN'])
    con <- file(description, 'rb')
    on.exit(close(con))
    db <- readRDS(gzcon(con))
    db <- unique(data.frame(gsub('\\s+', ' ', db[, c('Package', 'Title', 'Description')])))
    data.frame(db[, c('Title', 'Description')], row.names=db[['Package']])

}

# Unload a package
unload <- function(pkg) detach(paste0('package:', deparse(substitute(pkg))),
                               character.only=TRUE, unload=TRUE)

# Function masking...
#namespaces <- search()[-1]
#namespaces <- c(paste0('package:', pkgs)) #, 'tools:utils')
#fun <- lapply(namespaces, ls)
#fun_list <- Reduce(union, fun)
#has_fun <- function(x) sapply(fun_list, `%in%`, table = x)
#fun_table <- do.call(cbind, lapply(fun, has_fun))
#fun_conflicts <- fun_list[rowSums(fun_table) > 1]
#for (fun_name in sort(fun_conflicts)) {
#    x <- sort(sub('.+:', '', namespaces)[fun_table[fun_name, ]])
#    if (!setequal(x, c('plyr', 'dplyr')))
#        cat(fun_name, ':', x, '\n')
#}

## Internal ##

.term_size <- function() {
    as.list(stats::setNames(tryCatch({
        size <- system2('stty', 'size', stdout=TRUE, stderr=FALSE)
        scan(text=size, what=integer(), n=2, quiet=TRUE)
    }, error=function(e) {
        as.integer(Sys.getenv(c('LINES', 'COLUMNS')))
    }), c('lines', 'columns')))
}

# vi: set fen fdc=2 fdm=expr fde=getline(v\:lnum)=~'^##'?'>1'\:'=' :
