
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- After editing, regenerate README.md with devtools::build_readme() -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/rahulsh97/asi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rahulsh97/asi/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# asi

asi is an R package that turns India’s Annual Survey of Industries
(ASI) microdata into a single, tidy, queryable database, so you do not
have to clean and merge multiple years of survey files yourself before
you can start analysing them.

## Who this is for

Researchers, students, and analysts working in R who need ASI
establishment-level data on India’s registered (formal) manufacturing
sector joined into one place and queryable with ordinary dplyr or SQL
code.

## What data this supports

The package currently covers the ASI survey years listed in
`available_datasets`: 2015-16 through 2022-23. Each year’s blocks
(establishment characteristics, employment, wages, inputs and outputs)
are included once added to the underlying database.

## What the package does and does not download or redistribute

- The package itself ships **no ASI microdata**. It ships only R code,
  the list of available survey years, and a small amount of public
  reference material (Indian state boundaries in `region-codes/`) used
  to work with the data once you have it.
- `asi_download()` fetches a maintainer-prepared, tidied DuckDB
  database from this repository’s [GitHub
  Releases](https://github.com/rahulsh97/asi/releases) and stores it
  on your own machine, under your R user data directory by default, or
  under the `ASI_PATH` environment variable if you set one. Nothing
  you do with the package uploads data anywhere.
- The underlying ASI microdata is published by the Ministry of
  Statistics and Programme Implementation (MoSPI) through the
  [microdata.gov.in](https://microdata.gov.in/NADA/index.php/catalog/ASI)
  portal. Review MoSPI’s own terms of use before publishing or
  redistributing derived work, particularly if you extend this package
  with additional survey years.
- No function in this package requires a login, API key, or other
  credential.

## Installation

``` r
# install.packages("pak")
pak::pak("rahulsh97/asi")
```

## Quick start

``` r
library(asi)

# survey years currently available
available_datasets

# download the tidied database (one-time; the file is large, so this is
# not run automatically when this README is built)
asi_download()

# path to your local copy of the database
asi_file_path()
```

## Principal functions

| Function | What it does |
|----|----|
| `available_datasets` | Character vector of the ASI survey years currently included in the database (see “What data this supports”). |
| `asi_download(ver = NULL)` | Downloads the tidied DuckDB database from this repository’s GitHub Releases and stores it locally. Skips the download if a matching local copy already exists for your installed DuckDB version. |
| `asi_file_path(dir = ...)` | Returns the local file path to the DuckDB database, without connecting to it. |
| `asi_delete(ask = TRUE)` | Deletes the local database directory. Prompts for confirmation unless `ask = FALSE`. |

## Example: querying the database

Once `asi_download()` has run, the database is a normal DuckDB file
you can query with `DBI` or `dplyr`. This example checks average
manufacturing days by rural/urban location (see the [NADA data
dictionary](https://microdata.gov.in/NADA/index.php/catalog/205/data-dictionary/F35?file_name=blkA202223)
for variable codes):

``` r
library(dplyr)
library(duckdb)

con <- dbConnect(duckdb(), asi_file_path())

dbListTables(con)

tbl(con, "2019-20-blkA") %>%
  group_by(a9) %>%
  mutate(
    a9chr = case_when(
      a9 == 1L ~ "Rural",
      a9 == 2L ~ "Urban",
      TRUE ~ as.character(NA)
    )
  ) %>%
  summarise(mwdays = mean(mwdays, na.rm = TRUE)) %>%
  collect()

dbDisconnect(con, shutdown = TRUE)
```

A second example, mapping average manufacturing days by state, uses
the boundary file in `region-codes/`; see that directory before
relying on it, as its own provenance is not yet documented in this
repository.

## Adding older or newer years

1.  Install the Nesstar Explorer (for example, the ASI 2022-23 release
    includes it).
2.  Extract the RAR files downloaded from the microdata website to
    `data-raw/202223`, or whichever year you are adding.
3.  Export the `.Nesstar` file to Stata (SAV) format with “Export
    Datasets”, and the metadata with “Export DDI”, using the Nesstar
    Explorer.
4.  Update `00-tidy-data.r` and run it.
5.  Update the available datasets in `R/available_datasets.R`.
6.  Upload the new RDS files to the “Releases” section of the GitHub
    repository.
7.  Regenerate the local database with `asi_delete()` and
    `asi_download()`.

## Relationship to the wider India data ecosystem

asi is one of a small family of R packages that tidy major Indian
government surveys into queryable DuckDB databases using the same
design: [asuse](https://github.com/rahulsh97/asuse) (Annual Survey of
Unincorporated Sector Enterprises, informal enterprises) and
[plfs](https://github.com/rahulsh97/plfs) (Periodic Labour Force
Survey, employment and labour). For an overview of these and other
public Indian datasets used in economic research, see
[india-research-stack](https://github.com/rahulsh97/india-research-stack).

## Contributing and issues

Bug reports and questions are welcome at
<https://github.com/rahulsh97/asi/issues>.

## Citation and licence

Code and the tidying pipeline are released under CC0 1.0 Universal;
see [LICENSE.md](LICENSE.md). The underlying ASI microdata remains
subject to MoSPI’s own terms of use.
