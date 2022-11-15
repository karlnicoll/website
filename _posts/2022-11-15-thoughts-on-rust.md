---
layout: post
title: "Thoughts on Rust"
---

The past few weeks, I've been taking some time to pick up the
[Rust Book](https://doc.rust-lang.org/book/), and learn a new (programming)
language.

Amazon has big enthusiasm for Rust internally, [not without some controversy of
course](https://twitter.com/steveklabnik/status/1437441118745071617), and as
I have continued in my Amazon adventures, I've found myself coming across it
increasingly. So as a personal growth area I've been trying to learn the
language.

As I've been reading the book,
[looking at the examples](https://doc.rust-lang.org/stable/rust-by-example/),
and [doing the little quizzes](https://github.com/rust-lang/rustlings/), I've
been building a
[little toy implementation of Conway's Game of Life](https://github.com/karlnicoll/rust-game-of-life),
I've had some time to gather my thoughts on the language and programming style.

I've braindumped some of the more coherent thoughts below...

## 1. Cargo is _Lovely_

{% highlight shell %}
$ cargo build
    Updating crates.io index
  Downloaded getrandom v0.2.8
  Downloaded once_cell v1.16.0
  Downloaded rand_core v0.6.4
  ...
   Compiling game_of_life v0.1.0 (/home/karl/Development/rust-game-of-life/game_of_life)
    Finished dev [unoptimized + debuginfo] target(s) in 1m 35s
{% endhighlight %}

Cargo is the build system for Rust, and I _love_ it. Coming from C++ where
"there is not default build system" (the
[real default build system](https://cmake.org/) is still awful IMHO), Cargo is
a breath of fresh air.

It is extremely easy to use. In some ways, this ease of use makes Cargo
inflexible. That might sound like a bad thing, but in reality, it makes
building Rust code very consistent and simple to understand.

A basic `Cargo.toml` file looks like this:

{% highlight toml linenos %}
[package]
name = "hello_world"
version = "0.1.0"
edition = "2021"
description = "A brief description of the package (i.e. executable or library)"

[dependencies]
rand = "0.8.5"
{% endhighlight %}

Concise right? Compare this with some roughly equivalent CMake for
"Hello, world!" in C++17:

```cmake
cmake_minimum_required(VERSION 3.0)

project(
  MyHelloWorldProject
  VERSION
    0.1.0
  DESCRIPTION
    "A brief description of the package (i.e. executable or library)"
  LANGUAGES
    CXX
)

find_package(rand REQUIRED)

add_executable(hello_world src/main.cpp)
target_compile_features(hello_world PUBLIC cxx_std_17)
set_target_properties(hello_world PROPERTIES CXX_EXTENSIONS OFF)
target_link_libraries(hello_world rand)
```

By comparison, and obviously in my humble opinion, the CMake version is super
cryptic. And this is just a hello world project. CMake scales far worse once
you start introducing multiple build targets, lots of dependencies, lots of
code files, and so on.

Now to be fair, the comparison is a little unfair. Cargo is SPECIFIC to Rust,
while CMake is somewhat programming language agnostic. But in terms of clarity,
Cargo wins hands down.

So as to not make this look like a gripe just against CMake, Cargo compares
favourably as well compared to plenty of other languages like Python
(`setup.py`/`setup.cfg`), Ruby (Rakefiles, gemspecs), and
.NET languages (`sln` files, `csproj` etc).

## 2. Rust-Analyzer is Great Too

`rust-analyzer` is the language server for Rust, it provides fully featured
text completion for Rust projects:

![rust-analyzer enabling Rust autocompletion in Visual Studio Code](/files/rust-analyzer.png)

I use vscode for most things these days, but even with vscode having decent
extension support, I was surprised by how seamlessly the
[`rust-analyzer`](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)
extension worked.

## 3. Rust Expressions and Statements Changed How I Think About Code

The heading seems like an exaggeration, but it's literally the case. When you
begin learning Rust, you are taught very early on that idiomatic rust returns
the value of "the expression" to it's calling scope. For example:

```rust
/// Get a random number, chosen by fair die role.
fn get_random_number() {
    4
}
```

Simply by writing a line of code without a semicolon, it implicitly becomes the
return value of that scope. Equally we can do the following:

```rust
fn get_random_number2(seed: i32) {
    if seed < 5 {
        4
    } else {
        123
    }
}
```

Note that in this example, the `if/else` block functions as a single expression,
the result of which is then returned from the function.

More generally, I find that this lend's itself _very gracefully_ to the
[Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle).
You can generalize a rust function (or any scope) to something like this:

```rust
fn my_function() {
    // Code that prepares the expression parameters:
    let a = foo();
    let b = bar();
    let c = baz();

    // Execute the expression:
    a + b + c
}
```

Note that the function only "does one thing" which is return the result of a
single expression, but it may do multiple things to generate the parameters
feeding the expression.

When I initially learned this, I didn't like it, but in fact now that I am
used to it, it really makes a lot of sense, not just for Rust, but for writing
clean code in general.

## 4. Trait Scoping Sucks

C'mon Rust, if I specify a that class implements a trait, why can't rust
figure that out? The following code will fail to compile:

<figure class=highlight>
<pre><code class="language-rust" data-lang="rust"><table class="rouge-table"><tbody><tr><td class="gutter gl"><pre class="lineno">504
505
506
507
508
509
510
511
512
513
</pre></td><td class="code"><pre><span class="nd">#[cfg(test)]</span>
<span class="k">mod</span> <span class="n">foomod</span> <span class="p">{</span>
    <span class="k">use</span> <span class="k">super</span><span class="p">::</span><span class="nn">mock</span><span class="p">::</span><span class="n">MockPlotter</span><span class="p">;</span>

    <span class="nd">#[test]</span>
    <span class="k">fn</span> <span class="nf">test</span><span class="p">()</span> <span class="p">{</span>
        <span class="k">let</span> <span class="n">plotter</span> <span class="o">=</span> <span class="nn">MockPlotter</span><span class="p">::</span><span class="nf">new</span><span class="p">();</span>
        <span class="n">plotter</span><span class="nf">.flush</span><span class="p">();</span>
    <span class="p">}</span>
<span class="p">}</span></pre></td></tr></tbody></table></code></pre></figure>

In this example above, I am creating an object of type `MockPlotter`, which
implements a trait called `Plotter`. The `flush()` method is a part of the
`Plotter` trait, but Rust can't find it!

```text
error[E0599]: no method named `flush` found for struct `MockPlotter` in the current scope
   --> tui/src/lowlevel.rs:511:17
    |
277 |     fn flush(&mut self) -> Result<&mut Self, std::io::Error>;
    |        ----- the method is available for `MockPlotter` here
...
452 |     pub struct MockPlotter {
    |     ---------------------- method `flush` not found for this struct
...
511 |         plotter.flush();
    |                 ^^^^^ method not found in `MockPlotter`
    |
    = help: items from traits can only be used if the trait is in scope
help: the following trait is implemented but not in scope; perhaps add a `use` for it:
    |
506 |     use crate::lowlevel::Plotter;
    |
```

(Side note: How great are Rust compiler diagnostic messages? :D)

This error basically tells us that the `MockPlotter` struct DOES implement the
method as part of the `Plotter` trait, but it is not accessible because we
didn't bring the `Plotter` trait into scope...

_WHY?_

I'm not sure I understand why, if a trait is implemented in a class, and I bring
the class into scope, why are it's traits not just automatically brought into
scope as well?

Instead I have to manually `use` the trait:

<figure class="highlight"><pre><code class="language-rust" data-lang="rust"><table class="rouge-table"><tbody><tr><td class="gutter gl"><pre class="lineno">504
505
506
507
508
509
510
511
512
513
514
</pre></td><td class="code"><pre><span class="nd">#[cfg(test)]</span>
<span class="k">mod</span> <span class="n">foomod</span> <span class="p">{</span>
    <span class="k">use</span> <span class="k">super</span><span class="p">::</span><span class="nn">mock</span><span class="p">::</span><span class="n">MockPlotter</span><span class="p">;</span>
    <span class="k">use</span> <span class="k">super</span><span class="p">::</span><span class="n">Plotter</span><span class="p">;</span>

    <span class="nd">#[test]</span>
    <span class="k">fn</span> <span class="nf">test</span><span class="p">()</span> <span class="p">{</span>
        <span class="k">let</span> <span class="n">plotter</span> <span class="o">=</span> <span class="nn">MockPlotter</span><span class="p">::</span><span class="nf">new</span><span class="p">();</span>
        <span class="n">plotter</span><span class="nf">.flush</span><span class="p">();</span>
    <span class="p">}</span>
<span class="p">}</span>
</pre></td></tr></tbody></table></code></pre></figure>

## 5. Enums are Incredibly Expressive

Enums in C and C++ are are functional, but limited, there's no denying it. They
amount to simply a list of integral values with a concise syntax for doing
different work based on the current value. Rust enums on the other hand are
more akin to `std::variant<>` (or `union` in C) rather than actual C-style
enumerations:

```rust
enum Command {
    SendMessage(String),
    SumValues(i32, i32),
    Exit
}
```

This enum holds three possible values:

* A `SendMessage` tuple object that carries with it the message string.
* A `SumValues` tuple object that carries with it the two operands.
* An `Exit` unit type, which carries no data, but could be used to terminate
  a loop.

Traditionally, no discussion of enumerations can avoid the logical counterpart,
`match` expressions. Rather than simply evaluating an integer value, it can
do pretty expressive stuff:

{% highlight rust linenos %}
fn main() {
    let mut is_exiting = false;
    while !is_exiting {
        match get_command() {

            // Message content is accessible from the `msg` variable:
            Command::SendMessage(msg) => println!("Message: {}", msg),

            // Two matches for the `SumValues` enumeration value here, one
            // which is specialized where the left operand is <5, and another
            // to handle any other values.
            Command::SumValues(l, r) if l < 5 => println!("Total (l is less than 5): {}", l + r),
            Command::SumValues(l, r) => println!("Total: {}", l + r),

            // Sentinel value which quits the application.
            Command::Exit => is_exiting = true
        }
    }
}
{% endhighlight %}

You can find a building example
[here](https://play.rust-lang.org/?version=stable&mode=debug&edition=2021&gist=ce7b9f616b54d2aed1619053d0366f4c).

## 6. Reference Handling is Sometimes Ineloquent

### 6.1 The Ref Keyword

Interestingly, one thing I came across while playing with `match` expressions
was the `ref` keyword. Consider the following example:

```rust
let val = Some("foobarbaz".to_string);

// Match expression takes ownership of `val` here.
match val {
    Some(s) => println!("{}", s),
    _ => println!("idunno"),
}

// Compiler error, val is unavailable because it was owned by the match
// expression.
println!("Value is: {}", val);
```

We can fix this example by making the match _borrow_ the `val` variable, however
in some more complex cases, you may need to use the `ref` keyword. This example
above could be fixed by forcing the match statement to take `Some(s)` as a
reference rather than passing ownership:

```rust
let val = Some("foobarbaz".to_string);

// Match expression takes ownership of `val` here.
match val {
    Some(ref s) => println!("{}", s),  // <--- Ise of `ref` here.
    _ => println!("idunno"),
}

// Compiler error, val is unavailable because it was owned by the match
// expression.
println!("Value is: {}", val);
```

Documentation for the `ref` keyword is
[here](https://doc.rust-lang.org/1.33.0/book/ch18-03-pattern-syntax.html#legacy-patterns-ref-and-ref-mut).

In a language where we're taught 99.9% of the time to use the `&` operator,
the `ref` keyword was a sudden surprise.

Fortunately, Rust appears to have deprecated this keyword now for match
statements, however some edge cases appear to continue to exist
([see this discussion](https://internals.rust-lang.org/t/is-ref-more-powerful-than-match-ergonomics/12111/66)).

### 6.2 The `*` Operator

On the "other side", sometimes we find that we have to dereference a value in
order to perform operations on it. For example:

{% highlight rust linenos %}
fn do_thing(s: &mut String) {
    s = "Foo".to_string();
}

fn main() {
    let mut s = "some string".to_string();
    do_thing(&mut s);
    println!("{}", s);
}
{% endhighlight %}

In this example, we can see that we create a mutable string, then pass it to a
function `do_thing` which replaces the string contents. The problem is that this
doesn't compile. Instead, the compiler believes that I am trying to reassign the
`s` variable (which is an `&mut String`), but we're assigning it to `String`.

Coming from a C++ background, I would read this code to believe that `s` on line
2 is replacing the contents of the referenced variable, which is incorrect.

In this example, rust treats `s` more like a C-style pointer rather than a C++
reference. So to fix we actually have to use the `*` operator:

{% highlight rust linenos %}
fn do_thing(s: &mut String) {
    *s = "Foo".to_string();  // <--- Dereferenced here with `*`
}

fn main() {
    let mut s = "some string".to_string();
    do_thing(&mut s);
    println!("{}", s);
}
{% endhighlight %}

I accept fully that this might just be my C++ bias, but it feels very much like
Rust should've allowed the first variant, and always made reference variables
not re-assignable. Fortunately, this isn't a major deal as the compiler will
suggest this as the fix, and ultimately we can't change the behavior this late
on, so _c'est la vie_.
