mod_security2-cookbook
==============

NOTICE:
----------------
*I have not used this cookbook in production yet, and have no prior experience with mod_security*
*Please review the tests (which do pass) to ensure this cookbook meets your needs*
*Use at your own risk*


Supported Platforms
------------------
- ubuntu 12.04

Usage
--------------
This cookbook is primarily designed to be used as an LWRP library cookbook.  However, a
few recipes are provided for testing purposes, and for convenience in instances where minimal
customization is needed.

Attributes
-------------
*These attributes are used as defaults for the LWRP while also being used directly by the convenience recipes*
*If you are using the LWRP, there is no need to override node attributes, as the LWRP give you full
controll of all of these items.*

* `['mod_security2']['source']['revision']` - The git revision to use for pulling source. *default = 'v2.8.0'*
* `['mod_security2']['source']['repo']` - The URL of the git repo for source. *default = 'https://github.com/SpiderLabs/ModSecurity.git'*
* `['mod_security2']['source']['compile_flags']` - Flags to use when configuring mod_security. *default = []*
* `['mod_security2']['home']` - Home for ModSecurity installs.  <home>/versions/<revision> will be used with
a symlink from <home>/current to the current version. *default = '/opt/ModSecurity'*
* `['mod_security2']['platform']` - the webserver platform we're installing mod_security for. *default = :nginx*
<br /> <em>*currently only nginx is supported, but I'm happy to take a PR to add apache2 support</em>


Resources/Providers
--------------------
### mod_security2
#### Actions
The default action is `[:install]`

* :install - installs/compiles mod_security2 from source
* :delete - deletes a mod_security2 install.  *it does **not** remove mod_security from any webserver that may have built it in*

#### Attribute Parameters

* :version - String *(name attribute)* - *default = node['mod_security2']['source']['revision']*
* :home - String *default = `node['mod_security2']['home']`*  -__see documentation for node['mod_security2']['home']__
* :platform - [String, Symbol] *:default = :nginx* - __Currently only :nginx is supported__
* :compile_flags - [Array, String] *:default => []*
* :repo - String *default = node['mod_security2']['source']['repo']*


### mod_security2_config
#### Actions
The default action is `:create'

* :create - create a config file for mod_security
* :delete - delete a config file

#### Attribute Paramters

`base_rules`, `optional_rules`, `experimental_rules`, and `slr_rules` all refer to OWASP rule set

* path - where to put the config file
* custom_rules - a hash of custom rules  (see details below)
* base_rules - `true` to include all base rules, `false` to include none, and an array of filenames to include only some.
* optional_rules - same as for base_rules
* experimental_rules - same as for base_rules
* slr_rules - same as for base_rules
* tarball_url - url for the OWASP ruleset.  Default - https://github.com/SpiderLabs/owasp-modsecurity-crs/tarball/master

#### custom-rules
for custom rules, you provide a hash of rules to include.  Each hash entry takes a name for the key, and hash for the value.
The hash includes:
* `priority` - the priority of the rule from 0 to 99
* `type` - `:cookbook_file`, `:template`, or `:remote_file`  - The type of resource to use for building this rule
* `cookbook` - the cookbook that the template or cookbook file is found in (if `:cookbook_file` or `:template` type)
* `source` - the template or cookbook_file source (if `:cookbook_file` or `:template` type)
* `url` - the url for a remote_file

This cookbook includes a cookbook_file for enabling concurrent audit logs for mod_security

```ruby
mod_security2_config '/etc/modsecurity/mod_security.conf' do
  base_rules true
  custom_rules :concurrent_logging => {
    :type => :cookbook_file,
    :cookbook => 'mod_security2',
    :source => 'concurrent_logging.conf',
    :priority => 99
  }
end
```


Recipe usage
---------------
### mod_security2::install
Installs mod_security2 from source.

Include `mod_security2::install` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[mod_security2::install]"
  ]
}
```

### mod_security2::nginx_module
**DO NOT** use this recipe directly.  This recipe should be used in conjunction with the `nginx` cookbook by
adding `mod_security2::nginx_module` to `node['nginx']['source']['modules']`.  By doing so, you are
instructing the `nginx` cookbook to run this recipe at the appropriate time.  You may also need to add `mod_security2::default`
to your runlist to ensure that the `mod_security2` cookbook is available on your node at runtime.
Installs mod_security from source with the stand-alone-module flag.
Also updates the compile flags for nginx to ensure nginx is compiled with mod_security support.

### mod_security2::default
This is a convenience recipe which does NOTHING, but by adding it to your `run_list` you can
ensure the `mod_security2` cookbook will be loaded on your node and available to other cookbooks
at runtime.

License and Authors
--------------------

License: Apache 2.0
Author:: Tejay Cardon (<tejay.cardon@gmail.com>)
