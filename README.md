# Xinomorf

![Xinomorf](/misc/xinomorf.png)

## Wait What?

Terraform is awesome at enabling infrastructure as code across many many providers as well as collaboration among team members via remote state; however, its [HCL](https://github.com/hashicorp/hcl)-based language got me pulling my hair on more than one occasion. Too many weirdnesses and seemingly random things such as not being able to use a variable for a module source, no counts for modules, no easy way to work with temporary local files (aws lambda anyone?)... etc. I can go on forever. Really no shade intended, I absolutely love Terraform and I'm scared to think where I would have been without it.

Nix on the other hand is absolutely a pleasure to work with for templating (pretty sure it was designed with that in mind). Fetching stuff from all over the place is a breeze, creating ad-hoc files is straight forward and no need to about temp file names or locations (yay `/nix/store`!). So why not use Nix to generate Terraform configs?

## How?

Xinomorf doesn't really do much. Really!
Basically we take `*.tf.nix` files and term them into `*.tf` files.

### What are `*.tf.nix` files?

`tf.nix` files are simply Nix files that contain a function which returns a list of strings. For example:

```nix
{ ... }:

[
  # We can put resources together in the same string
  ''
    resource "null_resource" "hello" {}
    resource "null_resource" "sup" {}
  ''

  # ... or separately
  ''
    resource "null_resource" "bye" {}
  ''
]
```

So why the list and why the function? Terraform HCL syntax is kinda similar-ish to Nix; so I tried to make a bit of syntactic sugar. We could do:

```nix
{ resource, ... }:

[
  (resource "null_resource" "hello" {})
  (resource "null_resource" "sup"   {})
  (resource "null_resource" "bye"   {})
]
```

... not necessarily prettier but this whole thing is a WIP.

## Want!

### Prerequisites

- Nix

That's it.

### Install

```
$ git clone https://github.com/kreisys/xinomorf
$ cd xinomorf
$ nix-env -f. -iA cli
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
