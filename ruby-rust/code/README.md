Firstly, make sure you have Ruby and Rust installed. This project was written for Ruby 2.2
and Rust 1.2.0.

Build the Rust library.

```
cd simple && cargo build --release
```

Run the Ruby tests.

```
cd ..
ruby test.rb
```

Just for fun, you can run the Rust tests too.

```
cd simple && cargo test
```

