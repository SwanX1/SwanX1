# Workflows

### [update.yml](./update.yml)

This workflow will copy a directory and push it to a `raw` branch.

This is useful for projects where you want source code from one repository to be used in another.

For example, you could have a java project which utilizes a config mechanism from a seperate project.
You could copy `src/main/java/dev/cernavskis/config` to the `raw` branch and use it as a submodule in `src/main/java/dev/cernavskis/config` in another project.

This workflow came to be because git doesn't allow using a directory of a repository as a submodule, so I had to write a workflow that copies the directory to a branch.

Make sure to replace `a/b` on line 7 and 18!

To clone a project with submodules, do `git clone --recurse-submodules https://path/to/git/repo`

If another workflow utilizes [`actions/checkout`](https://github.com/marketplace/actions/checkout), it will have to use `submodules: 'recursive'`.
```yaml
  - uses: actions/checkout@v2
    with:
      submodules: 'recursive'
```

