## Resubmission
This is a resubmission. In this version we have:

* Fixed an undiscovered bug in previous sumbission

* Eliminated any use of `getwd()` within the package (functions, tests and vignettes)

* Changed the caching process to give control to user (use `tempdir()` as default)

* Added missing value parameters

* Added API references to DESCRIPTION

## R CMD check results

