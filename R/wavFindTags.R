#' detect tags in a .wav audio file
#'
#' A .wav file is processed to detect tag pulses, and these are run through
#' a simplified version of the tag finder to detect individual bursts from
#' Lotek coded ID tags.
#'
#' @details
#' This uses the same signal processing plugin as runs on the sensorgnome,
#' but via a stripped down vamp-host (the version on the sensorgnome
#' handles live input from attached funcubes).
#'
#' @param f path to the .wav file
#'
#' @param tdb path to the tag database file
#'
#' @param pd character scalar; which pulse detector to use.  One of
#' c("findpulsefdbatch" or "findpulsetdbatch").  Names one of the
#' VAMP plugins in the library lotek-plugins.so  Default: "findpulsetdbatch"
#'
#' @param pdpars named list of parameters to the pulse detector
#'
#' @param tfpars named list of parameters to the tag finder.
#'
#' @return a data.frame of tag detections with these columns:
#' \itemize{
#' \item ts timestamp; seconds since start of file
#' \item id; id from the database in \code{tdb}
#' \item dfreq; frequency offset, in kHz
#' \item sig; signal strength in dB max
#' }
#'
#' @param maxFreqSD maximum freqsd of returned detections; default: 0.2
#' kHz
#'
#' @note uses external programs vamp-host and find_tags_unifile, and
#' library lotek-plugins.so
#'
#' @export
#'
#' @author John Brzustowski \email{jbrzusto@@REMOVE_THIS_PART_fastmail.fm}

wavFindTags = function(f, tdb,
                       pd="findpulsetdbatch",
                       pdpars=list(minsnr=5, minfreq=0, maxfreq=24, plen=2.5),
                       tfpars=list(min_dfreq=-24, max_dfreq=24, signal_slop=30, frequency_slop=0.2, pulses_to_confirm=4, pulse_slop=1.5, max_skipped_bursts=3, default_freq=166.376, unsigned_dfreq=1), maxFreqSD=0.2
                       ){

    tmpf = tempfile(rep("file", 2))

    ## note the quoting of the path to the recording file (f)
    ## but not of the pasted parameter string.  Only the former
    ## is set by the upload user.

    safeSys("/sgm/bin/vamp-host",
            pars=paste0("-a ", names(pdpars), "=", pdpars, collapse = " "),
            paste0("/sgm/bin/lotek-plugins.so:", pd, ":pulses"),
            f,
            "-o",
            tmpf[1],
            shell=TRUE,
            quote=TRUE)

    ## read pulse finder output and add a leading antenna field, as expected by find_tags_unifile
    pulses = readLines(tmpf[1])
    writeLines(paste0("p1,", pulses), tmpf[2])

    cmd = sprintf("/sgm/bin/find_tags_unifile %s %s %s",
                  paste0("--", gsub('_', '-', names(tfpars), perl=TRUE), '=', tfpars, collapse=" "),
                  tdb,
                  tmpf[2])

    rv = tryCatch({
        x = read.csv(textConnection(safeSys(cmd, quote=FALSE)), as.is=TRUE)
        ## filter noisy detections
        x = subset(x, freq.sd <= maxFreqSD)
        x$id = as.integer(gsub("(Lotek#)|(@.*)", "", x$fullID))
        x
    },
    error = function(e) {
        data.frame(ts = numeric(0), id=integer(0), freq=numeric(0), sig=numeric(0))
    })

    return(rv[, c("ts", "id", "freq", "sig")])
}
