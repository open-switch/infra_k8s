# Adding a Debian Distribution to Aptly

Here's a runthrough for stretch. You'll need one source and one binary package
for the initial publish. Add these packages to `/aptly/upload` on the host.

```bash
DIST=stretch
OPX_RELEASE=2.3.0

# Create repositories
aptly repo create -comment="Unstable on $DIST" -distribution=opx opx-unstable-$DIST
aptly repo create -comment="Stable on $DIST" -distribution=opx opx-$DIST
aptly repo create -comment="Non-free on $DIST" -distribution=opx-non-free opx-non-free-$DIST

# Add initial packages from changes file
aptly repo include -no-remove-files -accept-unsigned -repo=opx-$DIST ./
aptly repo include -no-remove-files -accept-unsigned -repo=opx-unstable-$DIST ./
aptly repo include -accept-unsigned -repo=opx-non-free-$DIST ./

# Publish repositories
aptly publish repo -acquire-by-hash -component="main,opx,opx-non-free" -distribution="unstable" \
  opx-unstable-$DIST opx-unstable-$DIST opx-non-free-$DIST ${PUB}${DIST}
aptly publish repo -acquire-by-hash -component="main,opx,opx-non-free" -distribution="testing" \
  opx-$DIST opx-$DIST opx-non-free-$DIST ${PUB}${DIST}

# Create release snapshots
aptly snapshot create opx-${DIST}-${OPX_RELEASE} from repo opx-$DIST
aptly snapshot create opx-non-free-${DIST}-${OPX_RELEASE} from repo opx-non-free-${DIST}

# Publish snapshots
aptly publish snapshot -acquire-by-hash -component="main,opx,opx-non-free" -distribution="stable" \
  opx-${DIST}-${OPX_RELEASE} opx-${DIST}-${OPX_RELEASE} opx-non-free-${DIST}-${OPX_RELEASE} ${PUB}${DIST}
aptly publish snapshot -acquire-by-hash -component="main,opx,opx-non-free" -distribution="3-updates" \
  opx-${DIST}-${OPX_RELEASE} opx-${DIST}-${OPX_RELEASE} opx-non-free-${DIST}-${OPX_RELEASE} ${PUB}${DIST}
```
