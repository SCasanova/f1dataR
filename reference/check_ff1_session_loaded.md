# Check FastF1 Session Loaded

Used to verify that the fastf1 session is loaded before trying to work
with it.

Prevents errors in automated processing code.

## Usage

``` r
check_ff1_session_loaded(session_name = "session")
```

## Arguments

- session_name:

  Name of the python session object. For internal functions, typically
  `session`.

## Value

invisible TRUE, no real return, called for effect
