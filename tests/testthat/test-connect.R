test_that("asi_file_path builds a path under the supplied directory", {
  tmp <- file.path(tempdir(), paste0("asi-test-path-", as.integer(Sys.time())))
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  path <- asi_file_path(dir = tmp)

  expect_type(path, "character")
  expect_length(path, 1)
  expect_true(startsWith(path, tmp))
  expect_match(basename(path), "^asi_duckdb_v[0-9]+\\.duckdb$")
})

test_that("asi_file_path encodes the installed duckdb version with dots removed", {
  duckdb_version <- utils::packageVersion("duckdb")
  expected_suffix <- paste0("asi_duckdb_v", gsub("\\.", "", duckdb_version), ".duckdb")

  path <- asi_file_path(dir = tempdir())

  expect_identical(basename(path), expected_suffix)
})

test_that("asi_file_path respects the ASI_PATH environment variable when dir is left at its default", {
  # asi_path() normalises backslashes to forward slashes; tempdir() returns
  # native separators on Windows, so the expected prefix must be normalised
  # the same way before comparing.
  tmp <- file.path(tempdir(), paste0("asi-test-envpath-", as.integer(Sys.time())))
  tmp_normalised <- gsub("\\\\", "/", tmp)

  old_env <- Sys.getenv("ASI_PATH", unset = NA)
  Sys.setenv(ASI_PATH = tmp)
  on.exit({
    if (is.na(old_env)) Sys.unsetenv("ASI_PATH") else Sys.setenv(ASI_PATH = old_env)
  }, add = TRUE)

  path <- asi_file_path()

  expect_true(startsWith(path, tmp_normalised))
})
