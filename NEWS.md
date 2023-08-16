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
