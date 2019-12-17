# Contributing

## Code

Got a cool feature, or a performance improvement, or better tests maybe? Do this:

- Fork it
- create a feature branch
  - the name should either reference a github issue or your feature
- commit your work to it
  - Many short commits > a big commit. If sqashing is in order we'll ask during PR review or do it when merging.
- Add new tests as required
- cookstyle
- Ensure all kitchen tests, new and existing, pass.
- Open a pull request against this repository

During review we may ask you to rebase or modify some things.

Some things that are unlikely to be implemented if PRed:

- Adding new official platform support
  - To clarify, we'll accept changes that help support other platforms, provided they do not impact existing platform support and do not alter the `metadata.rb`'s `supports` or the kitchen suites/platforms.
- Features that introduce new external dependencies will be considered but will lean towards 'nope'
  - Keeping the dep tree simple minimizes management burden.
- Anything that would remove or damage an existing feature.
  - Any major refactor must preserve the original featureset.
- Introduce breaking changes to inputs (properties, resource names, etc...)
  - If you have reason to believe a major refactor is in order contact us directly so we can discuss it first.

## Issues

Writing code isn't the only way to help. Reporting bugs and other issues is critical to improving OSS.

- Search this repo on github for existing issues. You can +1 the post, or provide additional information if you have anything relevant. If no issue is found...
- Detail a clear reproduction case
- Get logs and/or debug/trace output of the run
  - Sanitize it! Don't post your production conf on the internet o.O
- Open an issue against this repo and add the information collected there

## Have fun coding!
