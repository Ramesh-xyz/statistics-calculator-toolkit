# Contributing

Bug reports and pull requests are welcome.

- Keep every package dependency-free at runtime (test-only dependencies are
  fine).
- All languages follow [docs/api.md](docs/api.md). A behaviour change must
  land in every implementation, with a test in each, or be discussed in an
  issue first.
- Add or update a test for every behaviour change. In Python, check results
  against the `statistics` module where possible.
- Run the tests for the languages you touched before opening a pull request.
  Each package README lists its test command; for Python:

  ```
  PYTHONPATH=src python -m unittest discover -s tests
  ```

- If you change an example in a README, `docs/` or `examples/`, re-run it
  and paste the real output.
- New statistics are in scope only if they are about dispersion around the
  mean.
