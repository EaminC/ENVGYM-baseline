FROM rust:1.61

WORKDIR /serde_project

COPY . .

RUN echo '1.61' > .rust-version

# Verify directory structure and root manifest
RUN ls -lR .
RUN test -f Cargo.toml

# Capture verbose build logs
RUN cargo check --verbose > cargo_check.log 2>&1 || (cat cargo_check.log; false)

# Continue with build and test commands
RUN cargo test --jobs $(nproc)
RUN cargo build --features serde/rc,serde/unstable,serde_derive/deserialize_in_place --jobs $(nproc)
RUN cargo build -p serde_derive_tests_no_std --jobs $(nproc)
RUN cargo check -p serde_derive --jobs $(nproc)
RUN cargo test -p serde_test_suite --features unstable --jobs $(nproc)
RUN cargo test -p serde_test_suite --test trybuild --jobs $(nproc)

CMD ["/bin/bash"]