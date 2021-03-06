## how we write the .RDS file ##

prefixFile: temp file for RDS header and data.frame prefix

colFiles:  1 file per column, consisting of serialized column data

suffixFile: temp file for data.frame attributes (class, names, rownames)

## format of an .RDS file ##

This description is inferred from the file src/main/serialize.c in the R source:

```
  RDS_data_frame            = RDS_header
                              data_frame

  RDS_header                = RDS_type
                              RDS_serialization_version
                              RDS_R_writer_version
                              RDS_min_R_version

  RDS_type                  = ('A', 'B', or 'X') '\0x0a'   ## 1-byte type followed by linefeed

  RDS_serialization_version = 0x00000002 ## version 2

  RDS_R_writer_version      = 0x00030301 ## version 3.3.1

  RDS_min_R_version         = 0x00020300 ## version 2.3.0

  data_frame                = type_with_flags
                              N          ## number of columns e.g. 0x00000010 (16)
                              column_1   ## serialized 1st column of data
                              column_2   ## ...
                              ...
                              column_N
                              attr_list (names, rownames, class) ## list of attributes for dataframe;

  type_with_flags           = 0x00000313 ## type 0x13 = list() plus flags for "has attributes" (0x00000200) and "is object" (0x00000100)
  N                         = 32-bit signed integer for length, or -1 followed by 64-bit integer (LARGE VECTOR)
  column_N                  = type + flags ## SXP type 0x0d=INT, 0x0e=REAL, 0x0a=LOGICAL; flags = 0 or 0x300 for classed
                              N ## length of column = # of rows in df
                              c1...cN ## N items written as INT or DOUBLE
                              attr_list(...) ## if classed flag is present, this will be class and possibly levels


  attr_list(S1=A1...SN=AN) = repeat N times: ## (attribute names are S1, ... SN; attribute vals are string vectors A1, ... AN)
                                 0x00000402 ## type 2 = pairlist plus flag for "has tag (i.e. name)"
                                 0x00000001 ## type 1 = symbol
                                 char(SYMNAME)
                                 strvec(AI) ## i'th attribute as string vector
                              NILSXP ## 0x000000fe


  char(X)                   = 0x00000009 ## CHARSXP
                              num_char ## number of bytes in X
                              chars    ## num_char bytes

  strvec(X)                 = 0x00000010 ## STRSXP (character vector)
                              N          ## length
                              repeat N times:
                                 char(X[i])  ## i'th element of character vector as CHARSXP

  unclassed_column          = unclassed_int  OR  unclassed_double  OR unclassed_logical

  unclassed_int             = 0x000000d   ## INTSXP
                              N           ## length
                              i1, ..., iN ## 4-byte signed integers

  unclassed_double          = 0x000000e   ## REALSXP
                              N           ## length
                              r1, ..., rN ## 8-byte doubles

  unclassed_logical         = 0x000000a   ## LGLSXP
                              N           ## length
                              l1, ..., lN ## 4-byte logicals: 0 or 1

  classed_column            = classed_int  OR  classed_double  OR classed_logical  OR  factor

  classed_int             = 0x000030d          ## INTSXP + has_attribute flag (0x200) + is_object (0x100)
                            N                  ## length
                            i1, ..., iN        ## 4-byte signed integers
                            attr_list (class)  ## list of attributes for dataframe;

  classed_double          = 0x000030e          ## REALSXP + has_attribute flag (0x200) + is_object (0x100)
                            N                  ## length
                            r1, ..., rN        ## 8-byte doubles
                            attr_list (class)  ## list of attributes for dataframe;

  classed_logical         = 0x000030a          ## LGLSXP + has_attribute flag (0x200) + is_object (0x100)
                            N                  ## length
                            l1, ..., lN        ## 4-byte logicals: 0 or 1
                            attr_list (class)  ## list of attributes for dataframe;

  factor                  = 0x000030d          ## INTSXP + has_attribute flag (0x200) + is_object (0x100)
                            N                  ## length
                            i1, ..., iN        ## 4-byte signed integers
                            attr_list (levels) ## list of attributes for dataframe;
```
