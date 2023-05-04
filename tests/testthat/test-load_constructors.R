test_that("constructors loads", {
    constructors<-.load_constructors()

    expect_equal(ncol(constructors), 3)
    expect_identical(constructors, load_constructors())
})
