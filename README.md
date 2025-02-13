# Gremlins

[![Tests](https://github.com/go-gremlins/gremlins/actions/workflows/ci.yml/badge.svg)](https://github.com/go-gremlins/gremlins/actions/workflows/ci.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/go-gremlins/gremlins)](https://goreportcard.com/report/github.com/go-gremlins/gremlins)
[![Maintainability](https://api.codeclimate.com/v1/badges/70142b378bff36c23550/maintainability)](https://codeclimate.com/github/go-gremlins/gremlins/maintainability)
[![DeepSource](https://deepsource.io/gh/go-gremlins/gremlins.svg/?label=active+issues&token=posNnh5FHpZG9DhM23YH7h6d)](https://deepsource.io/gh/go-gremlins/gremlins/?ref=repository-badge)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/744b4ac720c34518b7578204cfc61997)](https://www.codacy.com/gh/go-gremlins/gremlins/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=go-gremlins/gremlins&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/go-gremlins/gremlins/branch/main/graph/badge.svg?token=MICF9A6U3J)](https://codecov.io/gh/go-gremlins/gremlins)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fgo-gremlins%2Fgremlins.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fgo-gremlins%2Fgremlins?ref=badge_shield)

**WARNING: Gremlins isn't currently supported on Windows.**

Gremlins is a mutation testing tool for Go. It has been made to work well on _smallish_ Go modules, for example
_microservices_, on which it helps validate the tests, aids the TDD process and can be used as a CI quality gate.
As of now, Gremlins doesn't work very well on very big Go modules, mainly because a run can take hours to complete.

- [What is Mutation Testing](#what-is-mutation-testing)
- [How to Use Gremlins](#how-to-use-gremlins)
  - [Obtain and install](#obtain-and-install)
  - [Usage](#usage)
- [Supported Mutations](#supported-mutations)
  - [Conditionals Boundaries](#conditionals-boundaries)
  - [Conditionals Negation](#conditionals-negation)
  - [Increment Decrement](#increment-decrement)
  - [Invert Negatives](#invert-negatives)
  - [Arithmetic Base](#arithmetic-base)
- [Current Limitations](#current-limitations)
- [What Inspired Gremlins](#what-inspired-gremlins)
- [Other Mutation Testing Tools for Go](#other-mutation-testing-tools-for-go)
- [Contributing](#contributing)
- [License](#license)

## What is Mutation Testing

Code coverage is unreliable as a measure of test quality. It is too easy to have tests that exercise a piece of code but
don't
test anything at all.
_Mutation testing_ works by mutating the code exercised by the tests and verifying if the mutation is caught by
the test suite. Imagine _gremlins_ going into your code and messing around: will your test suit catch their damage?

Here is a nice [intro to mutation testing](https://pedrorijo.com/blog/intro-mutation/).

## How to use Gremlins

### Obtain and install

#### Linux

Download a `.deb` or `.rpm` file from the [release page](https://github.com/go-gremlins/gremlins/releases/latest) and
install
with `dpkg -i` and `rpm -i` respectively.

#### MacOS

On macOS, you can use [Homebrew](https://brew.sh/) to install by first tapping the repository. As of now, we use
a homebrew tap.

```shell
brew tap go-gremlins/tap
brew install gremlins
```

#### Manual

- Download the binary appropriate for your platform from
  the [release page](https://github.com/go-gremlins/gremlins/releases/latest)
  .
- Put the `gremlins` executable somewhere in your `PATH` (ex. `/usr/local/bin`).

#### From source

To build Gremlins you need the Go compiler, make and golangci-lint for linting.
You can clone the Gremlins repository and then build it:

```shell
git clone https://github.com/go-gremlins/gremlins.git
```

Ad then:

``` 
cd gremlins
make
```

### Usage

To execute a mutation test run, from the root of a Go module execute:

```shell
$ gremlins unleash
```

Gremlins only tests mutations of parts of the code already covered by test cases. If a mutant is not covered, why bother
testing? You already know it will not be caught. In any case, Gremlins will report which mutations aren't covered.

If the Go test run needs build tags, they can be passed along:

```shell
$ gremlins unleash --tags "tag1,tag2"
```

To perform the analysis without actually running the tests:

```shell
$ gremlins unleash --dry-run
```

Gremlins will report each mutation as:

- `RUNNABLE`: In _dry-run_ mode, a mutation that can be tested.
- `NOT COVERED`: A mutation not covered by tests; it will not be tested.
- `KILLED`: The mutation has been caught by the test suite.
- `LIVED`: The mutation hasn't been caught by the test suite.
- `TIMED OUT`: The tests timed out while testing the mutation: the mutation actually made the tests fail, but not
  explicitly.
- `NOT VIABLE`: The mutation makes the build fail.

### Supported mutations

#### Conditionals Boundaries

| Original | Mutated |
|----------|---------|
| \>       | \>=     |
| \>=      | \>      |
| <        | <=      |
| <=       | <       |

Example:

```go
if a > b {
// Do something
}
```

will be changed to

```go
if a < b {
// Do something
}
```

#### Conditionals Negation

| Original | Mutated |
|----------|---------|
| ==       | !=      |
| !=       | ==      |
| \>       | \<=     |
| <=       | \>      |
| <        | \>=     |
| \>=      | <       |

Example:

```go
if a == b {
// Do something
}
```

will be changed to

```go
if a != b {
// Do something
}
```

#### Increment Decrement

| Original | Mutated |
|----------|---------|
| ++       | --      |
| --       | ++      |

Example:

```go
func incr(i int) int
return i++
}
```

will be changed to

```go
func incr(i int) int {
return i--
}
```

#### Invert Negatives

It will invert negative numbers.

Example:

```go
func negate(i int) int {
return -i
}
```

will be changed to

```go
func negate(i int) int {
return +i
}
```

#### Arithmetic Base

| Original | Mutated |
|----------|---------|
| +        | -       |
| -        | +       |
| *        | /       |
| /        | *       |
| %        | *       |

Example:

```go
a := 1 + 2
```

will be changed to

```go
a := 1 - 2
```

### Current limitations

There are some limitations on how Gremlins works right now, but rest assured we'll try to make things better.

- Gremlins can be run only from the root of a Go module and will run all the test suite. This is a problem if the tests
  are especially slow.
- For each mutation, Gremlins will run all the test suite. It would be better to only run the test cases that actually
  cover the mutation.
- Gremlins doesn't support custom test commands; if you have to do anything different from `go test [-tags t1 t2] ./...`
  to run your test suite, most probably it will not work with Gremlins.
- There is no way to implement custom mutations.
- It is not tested on Windows as of now and most probably it will not work there.

## What inspired Gremlins

Mutation testing exists since the early days of computer science, so loads of papers and articles do exists. Gremlins is
inspired from those.

Among the existing mutation testing tools, Gremlins is inspired especially by [PITest](https://pitest.org/).

### Other Mutation Testing tools for Go

There is not much around, except from:

- [go-mutesting](https://github.com/avito-tech/go-mutesting#list-of-mutators)

## Contributing

See [contributing](CONTRIBUTING.md).

## License

Gremlins is released under the [Apache 2.0 License](LICENSE).
