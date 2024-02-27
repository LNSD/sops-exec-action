SOPS Exec action
----------------

[![License](https://img.shields.io/badge/License-MIT%20OR%20Apache%202.0-blue.svg)](#license)
[![test](https://github.com/LNSD/sops-exec-action/actions/workflows/test.yaml/badge.svg)](https://github.com/LNSD/sops-exec-action/actions/workflows/test.yaml)

A GitHub Action for securely executing commands with secrets.

This action uses [SOPS](https://getsops.io/) to decrypt secrets files encrypted with [age](https://age-encryption.org/)
and then executes the given command with the decrypted secrets injected in the subprocess environment.

> [!Warning]
> This is a work in progress and is not ready for production use.

## Prerequisites

This action requires the `sops` and `age` binaries to be available in the `PATH`.

To install `sops` and `age` in your workflow, you can use the following GitHub actions:

- _Setup SOPS_ ([nhedger/setup-sops](https://github.com/marketplace/actions/setup-sops))

  ```yaml
  - name: Setup sops
    uses: nhedger/setup-sops@v2
    with:
      version: 3.8.1 # optional, defaults to latest
  ```

- _Setup age_ ([alessiodionisi/setup-age-action](https://github.com/marketplace/actions/setup-age))

   ```yaml
    - name: Setup age
      uses: alessiodionisi/setup-age-action@v1
      with:
        version: 1.1.1 # optional, defaults to latest
    ```

## Usage

<!-- TODO: Add usage examples -->

## Customizing

### Inputs

<!-- TODO: Add inputs documentation -->

### Outputs

<!-- TODO: Add outputs documentation -->

### Environment variables

<!-- TODO: Add environment variables documentation -->

## License

<sup>
Licensed under <a href="LICENSE-APACHE">Apache License, Version 2.0</a> or <a href="LICENSE-MIT">MIT license</a>, at your option.
</sup>

<br>

<sub>
Unless you explicitly state otherwise, any contribution you intentionally submitted for inclusion in this project,
as defined in the project licenses, shall be licensed as above, without any additional terms or conditions.
</sub>
