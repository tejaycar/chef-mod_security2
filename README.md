# mod_security2-cookbook

# NOTICE: This cookbook is still under heavy development.  Don't use it yet.


## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['mod_security2']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### mod_security2::default

Include `mod_security2` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[mod_security2::default]"
  ]
}
```

## License and Authors

License: Apache 2.0
Author:: Tejay Cardon (<tejay.cardon@gmail.com>)
