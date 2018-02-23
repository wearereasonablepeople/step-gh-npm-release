# wercker-step-gh-npm-release

## options

* `ghtoken` needs to be set to your github API token
* `npmtoken` needs to be set to your npm auth token
* `branch` specify the branch to publish

## example

```
publish:
  box:
    id: acroyear2/karma-box:8.5.0
  steps:
    - install-packages:
        packages: git ssh-client
    - wearereasonablepeople/gh-npm-release@0.1.10:
        ghtoken: $GITHUB_TOKEN
        npmtoken: $NPM_TOKEN
        branch: release
```
