# Contributing

Bug reports and pull requests are welcome.

- Keep the package dependency-free: standard library only, Python 3.9+.
- Add or update a test in `tests/test_core.py` for every behaviour change.
  Where possible, check results against Python's `statistics` module.
- Run the tests before opening a pull request:

  ```
  PYTHONPATH=src python -m unittest discover -s tests
  ```

- If you change an example in `README.md`, `docs/` or `examples/`, re-run it
  and paste the real output.
- New statistics are in scope only if they are about dispersion around the
  mean.
