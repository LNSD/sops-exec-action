SOPS Exec action
----------------

[![License](https://img.shields.io/badge/License-MIT%20OR%20Apache%202.0-blue.svg)](#license)
[![test](https://github.com/LNSD/sops-exec-action/actions/workflows/test.yaml/badge.svg)](https://github.com/LNSD/sops-exec-action/actions/workflows/test.yaml)

Securely execute commands with encrypted secrets in GitHub Actions.

This action uses [SOPS](https://getsops.io/) to decrypt secrets files encrypted with [age](https://age-encryption.org/)
and then executes the given command with the decrypted secrets injected in the subprocess environment.

## Prerequisites

This action requires the `sops` binary to be available in the `PATH`. In the case of using `age` or `gpg` for 
encryption, the `age` or `gpg` binary must be available in the `PATH` as well.

To install `sops` and `age` in your workflow, you can use the following GitHub actions:

- _Setup SOPS_ ([nhedger/setup-sops](https://github.com/marketplace/actions/setup-sops))

  ```yaml
  - name: Setup sops
    uses: nhedger/setup-sops@v2
    with:
      version: 3.11.0 # optional, defaults to latest
  ```

- _Setup age_ ([alessiodionisi/setup-age-action](https://github.com/marketplace/actions/setup-age))

   ```yaml
    - name: Setup age
      uses: alessiodionisi/setup-age-action@v1
      with:
        version: 1.2.1 # optional, defaults to latest
    ```

By default, GitHub actions runners already have `gpg` installed, so you don't need to install it.


## Usage

### Run a command with secrets from encrypted .env file and _age_

To run securely a command with secrets from an encrypted environment file, you should provide
to **sops** the decryption key via the `SOPS_AGE_KEY` environment variable:

```yaml
- uses: LNSD/sops-exec-action@v1
  env:
    SOPS_AGE_KEY: ${{ secrets.AGE_SECRET_KEY }}
  with:
    env_file: .env.encrypted
    run: |
      # A command that uses variables from the decrypted environment file (e.g., cargo test)
      cargo test
```

### Run a command with secrets from encrypted .env file and _gpg_

To run securely a command with secrets from an encrypted environment file, you should provide
to **sops** the fingerprint of the GPG key used to encrypt the environment file via the `SOPS_GPG_FP` 
environment variable:

> [!Warning]
> The GPG key must be available in the environment where the action is executed. If the key is not
> available, you can use the [crazy-max/ghaction-import-gpg](https://github.com/marketplace/actions/import-gpg) 
> action to import the key.

```yaml
- uses: LNSD/sops-exec-action@v1
  env:
    SOPS_GPG_FP: ${{ secrets.GPG_KEY_FP }}
  with:
    env_file: .env.encrypted
    run: |
      # A command that uses variables from the decrypted environment file (e.g., cargo test)
      cargo test
```

## Customizing

### Environment variables

One of the following environment variables **MUST** be provided as `step[*].env` key:

| Name                | Description                                                                                                                                         |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `SOPS_AGE_KEY`      | The decryption key for the encrypted environment.                                                                                                   |
| `SOPS_AGE_KEY_FILE` | The path to the file containing the decryption key for the encrypted environment.                                                                   |
| `SOPS_GPG_FP`       | The fingerprint of the GPG key used to encrypt the environment file. The key **must** be available in the environment where the action is executed. |

### Inputs

The following inputs can be used as `step[*].with` keys:

| Name       | Description                                                                                                                                                                                                                                                                                                                             | Required | Default |
|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|
| `env_file` | The path to an encrypted environment file.<br/><br/> This file, encrypted locally using _sops_ and checked into the repository, typically carries the extension `.env.encrypted`.                                                                                                                                                       | Yes      | -       |
| `run`      | The command to execute while utilizing decrypted environment variables.<br/><br/>The command is executed within a sub-shell, granting access to encrypted environment variables. Failure of the command results in the step failing, as _sops_ propagates its exit status accordingly. Moreover, the command inherits standard streams. | Yes      | -       |


## Importing GPG keys

The GPG key used to encrypt the environment file must be available in the environment where the action is executed. To 
import a GPG key, you can use the _[crazy-max/ghaction-import-gpg](https://github.com/marketplace/actions/import-gpg)_
action:

```yaml
- name: Setup GPG
  uses: crazy-max/ghaction-import-gpg@v6
  with:
    gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
    passphrase: ${{ secrets.PASSPHRASE }}
```

Read the _[action documentation](https://github.com/marketplace/actions/import-gpg)_ for more information on 
how to use the action.


## License

<sup>
Licensed under <a href="LICENSE-APACHE">Apache License, Version 2.0</a> or <a href="LICENSE-MIT">MIT license</a>, at your option.
</sup>

<br>

<sub>
Unless you explicitly state otherwise, any contribution you intentionally submitted for inclusion in this project,
as defined in the project licenses, shall be licensed as above, without any additional terms or conditions.
</sub>
