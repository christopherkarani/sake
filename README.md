# Sake - Swift Make

<img width="300" src="Assets/Logo.png"/>

<a href="https://travis-ci.org/xcodeswift/sake">
<img src="https://travis-ci.org/xcodeswift/sake.svg?branch=master" alt="Travis"/>
</a>
<a href="https://swift.org/package-manager">
<img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager"/>
</a>
<a href="https://twitter.com/xcodedotswift">
  <img src="https://img.shields.io/badge/contact-@xcodedotswift-blue.svg?style=flat" alt="Twitter: @xcodedotswift" />
</a>
<a href="https://github.com/xcodeswift/sake/releases">
  <img src="https://img.shields.io/github/release/xcodeswift/sake.svg"/>
</a>
<a href="https://opensource.org/licenses/MIT">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License" />
</a>
<a href="http://xcodeswift.herokuapp.com/">
  <img src="https://xcodeswift.herokuapp.com/badge.svg">
</a>

Sake is a Swift command line tool that helps you automate tasks in your projects. It's heavily inspired by [Makefile](https://en.wikipedia.org/wiki/Makefile) and [Rake](https://github.com/ruby/rake).

## Path to 1.0.0 🚴
Sake hasn't reached the first major version yet. We are still defining many things around how Sake works and how the API works. These decissions might result into breaking changes in the Sake APIs. Once we reach the version 1.0.0 we'll use [semantic versioning](https://semver.org/) ensuring that only major versions include breaking changes.

We kindly ask you to use Sake on your own responsibility during this early stage and encourage you to participate in discussions that might determine what Sake final version looks like.

## Sake & Fastlane
Although Sake & Fastlane share the same core idea, facilitate tasks automation in any project, there are some subtle differences in the implementation and the scope of the tools that is worth mentioning:

- Sake is developed entirely in Swift while Fastlane is developed in Ruby. Fastlane supports defining the lanes in Swift but it's proxy layer to talk to the Fastlane core in Ruby.
- Sake aims for simplicity. It's up to the developer to build any necessary abstraction and Sake facilitates it by providing testing and code splitting features. Fastlane on the other side also aims to provide a lot of abstractions for many tools, making them easier to use.
- Sake is installed in the system as a compiled executable with a couple of libraries and thus it's very portable. On the other side Fastlane needs to be installed using Ruby Gem or Bundler and it comes with a bunch of dependencies.
- Sake integrates well with Xcode and the tools Apple OSs developers are used to, allowing them to integrate their tasks with third party Swift dependencies esily.

There's no good or bad tool. Choosing the one for your project depends on the project and the team that will work on it.

## Motivation 💅

Why automating tasks using shell scripting or Ruby when you can do it in Swift, a language you are already familiar with?
Sake aims to provide a command line tool and the foundation to automate your tasks in Swift.

## Installation 🥑

You can easily install sake using [Homebrew](https://brew.sh/):

```
brew tap xcodeswift/sake git@github.com:xcodeswift/sake.git
brew install sake
```

## Setup ⚒

1. Git clone the project `git clone git@github.com:xcodeswift/sake.git`.
2. Build `swift build`.

## Sakefile

Sakefile is the file that defines your project tasks:

```swift
// Sakefile
import SakefileDescription
import SakefileUtils

enum Task: String, CustomStringConvertible {
  case build
  var description: String {
    switch self {
      case .build:
        return "Builds the project"
    }
  }
}

Sake<Task> {
  try $0.task(.build) { (utils) in
    // Here is where you define your build task
  }
}
```

## Usage 👩🏻‍💻

#### Creating a Sakefile.swift 📝
You can create an empty `Sakefile.swift` running the following command:

```bash
sake init
```

#### Working on the Sakefile.swift 💼
You can edit the `Sakefile.swift` using any text editor. Nonetheless, we recommend you to use Xcode since you'll get syntax highlighting and code autocompletion for free. Sake provides a command to generate the Xcode project where you can edit the `Sakefile.swift`. You can generate the command by running:

```bash
sake generate-xcodeproj
```

> :warning: Note: Xcode can only run Swift code in a `main.swift` file. Since the name of the file is `Sakefile.swift` you'll get some Xcode warnings. Ignore them!

#### Tasks ✅

##### Run a task

```bash
sake task name_of_the_task
```

##### List all the tasks

```bash
sake tasks
```

## Sakefile Guidelines 🎨

The Swift code written in the `Sakefile.swift` file should meet the following guidelines:

- It shouldn't fail the execution either using `fatalError` or force unwrapping nil values. Failing the execution causes the tool to print the stack trace in the console. Instead throw errors that are handled by `Sake` and nicely printed into th console.
- Code should be synchronous and tasks should be completed by the time the closure execution ends.


## License

```
MIT License

Copyright (c) 2017 xcode.swift

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
