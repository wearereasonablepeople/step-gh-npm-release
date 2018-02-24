# wercker-step-gh-npm-release

A wercker step for deploying new releases to Github and NPM.

## Options

* `ghtoken` needs to be set to your github API token
* `npmtoken` needs to be set to your npm auth token
* `branch` specify the branch to publish
* `access` needs to be set to either public or restricted (if you have a private npm account)
* `repo` (optional) needs to be set when used with VCS other than github

## Example

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
    - wearereasonablepeople/gh-npm-release@0.1.15:
        ghtoken: $GHTOKEN
        npmtoken: $NPMTOKEN
        branch: release
        access: restricted
```
