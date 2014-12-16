# ssl-doctor

See bottom of `ssl-doctor.rb` for some terse usage documentation.


## Maintenance scripts

### `bin/build-cfssl`

Builds and commits the `cfssl` binaries for the current platform and for linux/amd64 (which is what heroku dynos run on).

It needs to be run when a new release of cfssl is available, or when running on a platform for which a binary is not already in the repo. See contents of `vendor/cfssl/bin/` for a list of existing binaries.

### `bin/update-bundles`

Pulls the newest cfssl_trust repo and commits their latest bundle files locally. These are used by `cfssl` for chain completion.

As long as the `cfssl-trust-store-*` mentioned below are in operation, this doesn't really need to be run. It's still good form to run it occasionally, such as when performing other changes to be deployed, just to ensure we have a recent static copy of the bundles in the repository.

### `bin/cfssl-trust-store-put`

Maintains a separate clone of the cfssl_trust repository. When run, it'll either create that clone or update it. It'll then store the bundle files in a redis instance.

This should be run periodically. On heroku it should be set as a scheduler process running daily. (Which sadly loses the cached clone, but such is life…)

### `bin/cfssl-trust-store-get`

Pulls the contents from the aforementioned redis issue and replaces the bundle files in `vendor/cfssl_trust`. This is run automatically by the ssl-doctor sinatra app when booting, but not otherwise.

We're relying on the fact that heroku dynos restart daily to ensure we'll have up-to-date bundles.


### `lib/cfssl-wrapper.rb`

Used internally to grab cfssl chain completions. When invoked as a script from the shell, will read a certificate from stdin or named files and print out its full chain.
