# Working with Concourse

```bash
# login with github
fly -t concourse login --team-name main --concourse-url https://concourse.k8s.openswitch.net

vault write concourse/main/bintray_username value=opxbuild
vault write concourse/main/bintray_apikey value=8cb4d425eacff3b700e1545c7f51e27e6770c47e

# set pipeline and export
make opx-logging
```
