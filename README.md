

<h1 align="center"><img src="docs/images/logo-woocommerce.svg" width="300"><br>for iOS</h1>

<p align="center">A sample weather app for iOS.</p>


<p align="center">
    <a href="#-build-instructions">Build Instructions</a> •
    <a href="#-documentation">Documentation</a> •
    <a href="#-contributing">Contributing</a> •
    <a href="#-need-help">Need Help?</a> •
    <a href="#-resources">Resources</a> •
</p>

## 🎉 Build Instructions

1. Download Xcode

    At the moment *WooCommerce for iOS* uses Swift 5.7 and requires Xcode 14 or newer. Previous versions of Xcode can be [downloaded from Apple](https://developer.apple.com/downloads/index.action).

2. Install Ruby. We recommend using [rbenv](https://github.com/rbenv/rbenv) to install it. Please refer to the [`.ruby-version` file](.ruby-version) for the required Ruby version.

    We use Ruby to manage the third party dependencies and other tools and automation.

2. Clone project in the folder of your preference

    ```bash
    git clone https://github.com/ademozsayin/WeatherApp-iOS.git
    ````

3. Enter the project directory

    ```bash
    cd WeatherApp
    ```

4. Install the third party dependencies and tools required to run the project.


    ```bash
    bundle install && bundle exec rake dependencies
    ```

    This command installs the required tools like [CocoaPods](https://cocoapods.org/). And then it installs the iOS project dependencies using CocoaPods.

5. Open the project by double clicking on `WooCommerce.xcworkspace` file, or launching Xcode and choose File > Open and browse to `WooCommerce.xcworkspace`

## 📚 Documentation

- Architecture
    - [Overview](docs/architecture-overview.md)
    - [Networking](docs/NETWORKING.md)
- Coding Guidelines
    - [Coding Style](docs/coding-style-guide.md)
    - [Naming Conventions](docs/naming-conventions.md)
        - [Protocols](docs/naming-conventions.md#protocols)
        - [String Constants in Nested Enums](docs/naming-conventions.md#string-constants-in-nested-enums)
        - [Test Methods](docs/naming-conventions.md#test-methods)
    - [Choosing Between Structures and Classes](docs/choosing-between-structs-and-classes.md)
    - [Creating Core Data Model Versions](docs/creating-core-data-model-versions.md)
    - [Localization](docs/localization.md)

## 👏 Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## 🤖 Automation
-

## 🔐 Security


## 🔗 Resources

- [Weather API Documentation (currently v3)]https://openweathermap.org/api/one-call-3)

## 📜 License




# VIPER-Module-Builder
Custom VIPER design pattern builder script

# Installation instructions

To install VIPER Xcode templates clone this repo and run the following command from root folder:

> make install_viper_templates

To uninstall Xcode template run:

> make uninstall_templates

After that, restart your Xcode if it was already opened.
