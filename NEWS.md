# f1dataR (development version)

* Modified testing to satisfy CRAN requirements. 

# f1dataR 1.5.1

* Added (very soft) deprecation warning to Ergast functions in advance of the Ergast API being defunct in less than 12 months.
* Deprecated support for FastF1 v < 3.1.0. Older FastF1 versions do not support all of the functions in use and may return different values from some data retrieval or calculation functions. Forcing use of up-to-date FastF1 allows for simpler bugfixes and code updates. (#198)
* Removed Ergast check for `get_current_season()` (#227)
* Improved messaging to users regarding updating FastF1 (#226)
* Named items in list returned by `load_circuit_details()`
* Changed the way that `correct_track_ratio()` works. Visually the results are the same, but now any labels/annotations added to the ggplot should be kept in the right spot.
* Added Vignette describing some `load_circuit_details()` usage.
* Code improvements (better handle variation in Ergast response, better handle Ergast connection failures) (#228)
* Testing improvements to validate our handling of internet failures (#228)
* Upgraded to use `httptest2` for testing no-internet scenarios (no affect on package performance)
* Code cleanup (removed old inaccessible code, centralized repeated steps to functions, etc.)


# f1dataR 1.5.0

* Added `load_circuit_details` (#210)
* Strengthened package testing (#212, #216)
* Bugfixes (#216)

# f1dataR 1.4.1

* Fixed a bug with cache options (#194, #195, #197)
* Fixed a build bug
* Began deprecation of support for FastF1 v < 3.1.0

# f1dataR 1.4.0

* Fully deprecated `round` and `fastest_only` arguments
* Added a function `correct_track_ratio()` to ensure plotted tracks have proper x & y ratios (#89, #179)
  * Updated `plot_fastest()` to use `correct_track_ratio()`
* Added a function to help switch between cache choices (#170, #171)
  * Ensured cache option had default (`"memory"`) (#181, #183)
* Simplified Python package `fastf1` installation (#187).
  * Virtualenv and Conda environment management is up to the user now

# f1dataR 1.3.0

* Updated documentation per requirements after CRAN review
 * Changed caching behavior per requirements after CRAN review. 
If you previously had set a cache directory `options("f1dataR.cache" = [dir])` there will be no change. 
If you had previously not specified a cache directory, the package used to use the result of `getwd()`, so you can force that directory. 
New users can specify a default file cache location by setting `options("f1dataR.cache" = "filesystem")` or specify any other (existing) directory by setting the option. 

Cache will otherwise use memory as a default until the end of the R session or for 24h (whichever comes first). 
Caching can be turned off by setting the option to "off"


# f1dataR 1.2.1

* Added additional output column to `load_schedule()` to show Sprint Race date.

# f1dataR 1.2.0

* Added a helper function for setting up `fastf1` connection.
* Improved testing coverage
* Code style and format cleanups

# f1dataR 1.1.0

* Updated load_driver_telemetry to use `laps` parameter, allowing for a choice of 'fastest', 'all', or a numbered lap. Note a numbered lap requires `fastf1` version 3.0 or greater (#78)

# f1dataR 1.0.1

* Added examples to documentation (#95)

# f1dataR 1.0.0

* Added a `NEWS.md` file to track changes to the package.
