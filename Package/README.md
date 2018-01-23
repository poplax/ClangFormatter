
# Update Your Code Style Config.

## Install

- Copy `.app` to `/Applications`.
- Run it and close.
- Enable it, restart Xcode.

## Usage

Update the config file *_clang-format-objc* to custom style of your own code-style.

Learn From there:
[See ClangFormatStyleOptions](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)

## Update config

**Note** 
Just copy *config file* to your .app `<Plugins-Path>` 

You can run script(The same level directory):

```shell
cp -f ./_clang-format-objc /Applications/ClangFormatter.app/Contents/PlugIns/ClangFormat.appex/Contents/Resources/_clang-format-objc
```

## TODO List.

- Edit profile features.
- More Style support.
- Imaginative features.
