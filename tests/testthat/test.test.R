context("Testing tests")

test_that("should pass", {
  expect_equal(5, 5)
})

test_that("should fail", {
  expect_equal(5, 6)
})
