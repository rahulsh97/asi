test_that("asi_delete removes the local database directory without prompting when ask = FALSE", {
  tmp_root <- file.path(tempdir(), paste0("asi-test-delete-", as.integer(Sys.time())))
  dir.create(tmp_root)
  writeLines("dummy", file.path(tmp_root, "placeholder.duckdb"))

  old_env <- Sys.getenv("ASI_PATH", unset = NA)
  Sys.setenv(ASI_PATH = tmp_root)
  on.exit({
    if (is.na(old_env)) Sys.unsetenv("ASI_PATH") else Sys.setenv(ASI_PATH = old_env)
    unlink(tmp_root, recursive = TRUE)
  }, add = TRUE)

  expect_true(dir.exists(tmp_root))

  result <- asi_delete(ask = FALSE)

  expect_null(result)
  expect_false(dir.exists(tmp_root))
})

test_that("asi_delete is safe to call when the database directory does not exist", {
  tmp_root <- file.path(tempdir(), paste0("asi-test-missing-", as.integer(Sys.time())))

  old_env <- Sys.getenv("ASI_PATH", unset = NA)
  Sys.setenv(ASI_PATH = tmp_root)
  on.exit({
    if (is.na(old_env)) Sys.unsetenv("ASI_PATH") else Sys.setenv(ASI_PATH = old_env)
  }, add = TRUE)

  expect_false(dir.exists(tmp_root))
  expect_error(asi_delete(ask = FALSE), NA)
})
