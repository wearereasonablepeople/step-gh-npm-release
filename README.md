# wercker-step-gh-npm-release

A wercker step for deploying new releases to Github and NPM.

## Options

* `ghtoken` needs to be set to your github API token
* `npmtoken` needs to be set to your npm auth token
* `branch` specify the branch to publish
* `packer` (optional) set to an `npm` command that creates a `NAME-VERSION.tgz` file in the same directory. when not set, `npm pack` is used for creating a tarball to publish
* `access` needs to be set to either public or restricted (if you have a private npm account)
* `repo` (optional) needs to be set when used with a service other than Github

## Example

The following example explains how you can create a automation pipeline that updates the `package.json` file (on the specified `branch`), creates a new Github tag and publishes a new release on NPM.

`wercker.yml`

```
box:
  id: acroyear2/karma-box:8.5.0

build:
  steps:
    - script:
        name: build
        code: |
          echo 42

publish:
  steps:
    - install-packages:
        packages: git ssh-client
    - wearereasonablepeople/gh-npm-release:
        ghtoken: $GHTOKEN
        npmtoken: $NPMTOKEN
        branch: release
        access: restricted
```

To set this up in the Wercker console, go to your application's `Workflows` settings:

Create `build` and `publish` pipelines.

Make sure that the `build` pipeline is hooked to Git pushes and the `branch` you deploy the releases is ignored for this pipeline, otherwise you will run into an infinite release loop.

Your workflow should look like this:

```
+-----+       +-------+
|build| +---> |publish|
+-----+       +-------+
              (runs only on master)
```

## Notes

* Only the PATCH version is updated. (see: [semver spec](https://semver.org/))
* This will run the `build` command before publishing the NPM release if it exists in your `package.json` file
