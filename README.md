# Sunward detection rules

`rules.json` overrides the element names and labels Sunward looks for in each app, without an app update. Phones check it every 6 hours and whenever Sunward is opened, and only accept it if `rules.json.sig` matches the developer's signing key.

**To change a rule:** edit `rules.json`, raise `"version"` by 1, run `./sign.sh`, then commit and push both files.

**To switch an app off for everyone:** set its `"enabled"` to `false`, bump the version, sign, push. Set it back to `true` the same way.

Any value left out of the file uses the default built into the app.
