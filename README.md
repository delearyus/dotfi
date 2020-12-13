# Dotfi: A Simple Dotfile Templating Engine

## Motivations

Dotfi is a simple project that I started working on while looking
for a system to help manage my dotfiles. The primary issue that I kept
running into was this: I spend a lot of time themeing my workstation,
and I maintain and switch between multiple themes.

The basic solution which I used for a while was just to use multiple
versions of each config file, but this means that any time I wanted to
make a non-theme-specific change to a config file, I would have to
make the same change in each theme, which naturally lead to wildly
out-of-sync configuration files. I also experimented with a few other
methods, including `cat`ing together a base part and a theme part for
each file, the m4 macro processor, and even a poorly-thought-out idea
using git branches and automated rebasing (the merge conflicts of
course made this completely untennable)

As such, the only thing to do when tools don't perfectly match your
needs is to storm off angrily into the woods and make your own damn
tool, so that's what I've done here.

**Keep in mind that this is a very new project of mine and is still**
**very rough around the edges. I've gotten it to work pretty well**
**so far, but if you decide to use it make sure to make backups**
**of any config files you plan on overwriting with it. Also, make**
**sure to take advantage of the `--dry-run` flag to make sure that**
**files are going where you want them to and have the correct**
**contents.**

## Requirements

Dotfi is a racket language and therefore depends on Racket, and
currently also depends upon the beautiful-racket library, as I am
still learning racket - the beautiful-racket dependency will soon be
removed

```bash
pacman -S racket # or your distribution's equivalent
raco pkg install --auto beautiful-racket
```

## Installation

```bash
git clone [git url here]
cd [repo name]
raco pkg install
```

## Usage

Dotfi is a racket DSL for creating self-installing dotfile scripts. To
create a script, start a file with:

```racket
#!/usr/bin/env racket
#lang dotfi
```

After this header, each file is composed of one or more stanzas, each
of which corresponds to a file that will be installed to a specific
path.  The structure of each stanza looks like this:

````racket
# <filename>
```[filetype]
<file contents>
```
````

<filename> corresponds to either an absolute or relative path.
Relative paths are always assumed to be relative to $HOME, not the
current directory.

[filetype] is completely optional, but is there so that if your editor
supports markdown code-fence syntax highlighting, you can get it for
free.

<file contents> can be anything (aside from the ending
triple-backticks), and may also include snippets of racket code,
contained within dotfi's escape character (⯁) and curly braces, like
so:

```racket
I have ⯁{(+ 1 1)} apples.
```

A file written in this format comprises an executable script with the
following usage:

```
./[filename] [ <option> ... ] <theme>
 where <option> is one of
  -d, --dry-run : Template files and display without installing
  --help, -h : Show this help
```

<theme> is the path to another racket file (in any racket lang) which
will provide the bindings for the racket snippets included in the
stanzas. So, for instance, with the following theme file:

*theme.rkt*
```racket
#lang racket/base

(define color "red")
(define count 2)
```

And the following script:

*apples*
````racket
#!/usr/bin/env racket
#lang dotfi

# apples.txt
```
I have ⯁{count} ⯁{color} apples.
```
````

then running the command `./apples theme.rkt` will write the contents
"I have 2 red apples" to ~/apples.txt

An example script, `dotfi.sh`, is also included, which runs each dotfi
script in the directory where I keep all my dotfi scripts, using the
same theme for each. This is very much just an example script, and is
extremely simple, but it provides a good example for how I'm using it.

## Design Goals

I set out with a collection of specific ideals which explain some of
the admittedly-somewhat-odd design decisions, so I figured I should
collect them here, for anyone who cares about that kind of thing:

1. *Dotfi should work with any type of file without having to worry
   about escaping*. This is why dotfi uses "⯁" rather than a more
   conventional symbol like $ or #. Using a "conventional" syntax
   would mean that attempting to template a file that used the same
   syntax would require all instances of the syntax in the file to be
   escaped in some way, creating a huge hassle as well as ruining any
   syntax-highlighting for the file and making everything a little bit
   uglier.

2. *Dotfi files should be self-contained, location-agnostic modules*.
   I used GNU Stow for my dotfiles for a long time (in addition to
   all my templating stuff), as described in 
   [this article](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/),
   but that inevitably led to my dotfiles folder looking like this:

    ```
    $ tree ~/dotfiles
    ...
    ├── mpd
    │   └── .config
    │       └── mpd
    │           ├── mpd.conf
    │           └── mpd.conf.template
    ├── ncmpcpp
    │   └── .ncmpcpp
    │       ├── config
    │       └── config.template
    ├── polybar
    │   └── .config
    │       └── polybar
    │           ├── config
    │           ├── config.bak
    │           └── config.template
    ...
    ```

    and I always kind of hated having to create this whole big nested
    file structure, and having to constnatly navigate through it just
    to tell my script where to put the files. As such, each dotfi
    script is intentionally completely unreliant on its name or
    location and can be moved anywhere on the system without changing
    its functionality. Similarly, relative paths are set relative to
    the users home directory rather than the call point of the script
    to similarly aid in location-agnosticism while preserving the
    convenience of being able to use relative paths.
    
4. *dotfi files should function as valid markdown files*. This one is
   admittedly a little weird, but it came about because I noticed that
   my editor (nvim) provided syntax highlighting for fenced code
   blocks with filetype annotations. I think syntax highlighting is
   important for readability, and makes editing files much faster, and
   that was one of the big problems I was facing: how to include
   multiple files of potentially different filetypes and stil have
   them all get proper syntax highlighting? Leveraging the markdown
   format and available highlighting seemed like the right move,
   getting all that convenience for free. Plus, the format that
   following the markdown spec led to looks pretty good, and is nice
   and readable (in my opinion, at least)

## Issues / Next Steps

* *Performance* - dotfi's templating engine is a quite a big slower than
  I'd like it to be (it's definitely usable just fine, but I'm sure
  that someone who knows what they're doing in Racket a little bit
  more than I do could certainly get it running a little faster and
  with fewer calls to `string-concat`, which I'm pretty sure are what
  is hurting the performance right now the most

* *Removing beautiful-racket dependency* - A lot of the code is
  written in br/quicklang, which provides a number of convenience
  functions for newbies, but it could easily be translated to
  racket/base, removing the dependency and simplifying the install
  process

* *Error messages* - Debugging a dotfi script is currently real
  difficult, because it doesn't really provide error messages except
  for the unchecked exceptions when something goes wrong. A lot of the
  errors could be easily checked for and made more user-friendly.

* *Testing* - A test suite would provide some peace of mind with
  respect to parsing especially, as the parser code is a little bit
  shaky right now.

